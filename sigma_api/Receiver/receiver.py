import serial
import requests
import re
import time
import json
import os
import socket
from datetime import datetime
from pathlib import Path
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from threading import Thread
from urllib.parse import urlparse, parse_qs

# Configuracion
API_BASE_URL = os.getenv('API_BASE_URL', 'https://sigma-251.onrender.com').rstrip('/')
MEDICIONES_URL = f'{API_BASE_URL}/api/mediciones/waspmote'
ESTADO_URL = f'{API_BASE_URL}/api/estado-sistema/waspmote'

SERIAL_PORT = 'COM8'
BAUD_RATE = 115200
LOCAL_API_HOST = os.getenv('LOCAL_API_HOST', '0.0.0.0')
LOCAL_API_PORT = int(os.getenv('LOCAL_API_PORT', '5050'))

# Almacenamiento local del receiver
BASE_DIR = Path(__file__).resolve().parent
LOCAL_DATA_DIR = BASE_DIR / 'local_data'
HISTORY_FILE = LOCAL_DATA_DIR / 'mediciones_historial.json'
LATEST_FILE = LOCAL_DATA_DIR / 'ultima_medicion.json'
PENDING_FILE = LOCAL_DATA_DIR / 'pendientes_sync.json'
JSON_FILE = LOCAL_DATA_DIR / 'datos_sensor.json'
MAX_MEDICIONES = 100
MAX_PENDING = 1000


def _ensure_local_storage():
    LOCAL_DATA_DIR.mkdir(parents=True, exist_ok=True)


def _read_json_file(path, default):
    try:
        if not path.exists():
            return default
        contenido = path.read_text(encoding='utf-8').strip()
        if not contenido:
            return default
        return json.loads(contenido)
    except (json.JSONDecodeError, ValueError, OSError):
        return default


def _write_json_file(path, data):
    _ensure_local_storage()
    temp_path = path.with_suffix(path.suffix + '.tmp')
    temp_path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding='utf-8')
    temp_path.replace(path)


def _get_local_ip():
    """Intenta obtener la IP local del PC en la red."""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
            sock.connect(('8.8.8.8', 80))
            return sock.getsockname()[0]
    except OSError:
        try:
            return socket.gethostbyname(socket.gethostname())
        except OSError:
            return '127.0.0.1'


def _build_local_api_payload():
    latest = _read_json_file(LATEST_FILE, {})
    history = _read_json_file(HISTORY_FILE, [])
    pending = _read_json_file(PENDING_FILE, [])

    return {
        'latest': latest,
        'history_count': len(history),
        'pending_count': len(pending),
        'timestamp': datetime.now().isoformat(),
    }


def guardar_en_json(medicion):
    """Guarda la medicion en archivos JSON locales del receiver."""
    try:
        _ensure_local_storage()
        mediciones = _read_json_file(HISTORY_FILE, [])

        medicion_con_timestamp = {
            **medicion,
            'timestamp': datetime.now().isoformat(),
            'id': int(datetime.now().timestamp() * 1000)
        }
        mediciones.append(medicion_con_timestamp)

        if len(mediciones) > MAX_MEDICIONES:
            mediciones = mediciones[-MAX_MEDICIONES:]

        _write_json_file(HISTORY_FILE, mediciones)
        _write_json_file(LATEST_FILE, medicion_con_timestamp)
        _write_json_file(JSON_FILE, mediciones)

        print(f'JSON local guardado: {HISTORY_FILE} ({len(mediciones)} mediciones)')
        return medicion_con_timestamp
    except Exception as e:
        print(f'Error guardando JSON local: {e}')
        return None


def guardar_pendiente(tipo, payload, endpoint, local_id=None):
    """Guarda una lectura para reintento cuando vuelva la conexion."""
    try:
        pendientes = _read_json_file(PENDING_FILE, [])
        pendiente = {
            'id': int(datetime.now().timestamp() * 1000),
            'tipo': tipo,
            'endpoint': endpoint,
            'payload': payload,
            'local_id': local_id,
            'attempts': 0,
            'last_error': None,
            'created_at': datetime.now().isoformat(),
        }
        pendientes.append(pendiente)
        if len(pendientes) > MAX_PENDING:
            pendientes = pendientes[-MAX_PENDING:]
        _write_json_file(PENDING_FILE, pendientes)
        print(f'Lectura pendiente guardada localmente ({tipo})')
        return True
    except Exception as e:
        print(f'Error guardando pendiente: {e}')
        return False


def _actualizar_historial_local(mediciones):
    """Reescribe el historial local con las mediciones pendientes que siguen sin sincronizar."""
    try:
        if not mediciones:
            _write_json_file(HISTORY_FILE, [])
            _write_json_file(LATEST_FILE, {})
            _write_json_file(JSON_FILE, [])
            return True

        _write_json_file(HISTORY_FILE, mediciones)
        _write_json_file(LATEST_FILE, mediciones[-1])
        _write_json_file(JSON_FILE, mediciones)
        return True
    except Exception as e:
        print(f'Error actualizando almacenamiento local: {e}')
        return False


def reintentar_pendientes():
    """Intenta reenviar lecturas guardadas cuando vuelve la conexion."""
    pendientes = _read_json_file(PENDING_FILE, [])
    if not pendientes:
        return {'synced': 0, 'failed': 0, 'cleared': False}

    restantes = []
    synced = 0
    failed = 0
    synced_local_ids = set()
    for pendiente in pendientes:
        try:
            response = requests.post(
                pendiente['endpoint'],
                json=pendiente['payload'],
                timeout=5
            )
            if response.status_code in (200, 201):
                print(f"Pendiente reenviado: {pendiente['tipo']} ({pendiente['id']})")
                synced += 1
                if pendiente.get('local_id') is not None:
                    synced_local_ids.add(pendiente['local_id'])
                continue

            pendiente['attempts'] = pendiente.get('attempts', 0) + 1
            pendiente['last_error'] = response.text
            restantes.append(pendiente)
            failed += 1
        except requests.RequestException as e:
            pendiente['attempts'] = pendiente.get('attempts', 0) + 1
            pendiente['last_error'] = str(e)
            restantes.append(pendiente)
            failed += 1

    _write_json_file(PENDING_FILE, restantes)
    cleared = False
    if synced_local_ids:
        remaining_local_ids = {
            pendiente.get('local_id')
            for pendiente in restantes
            if pendiente.get('local_id') is not None
        }
        removable_local_ids = {
            local_id for local_id in synced_local_ids
            if local_id not in remaining_local_ids
        }

        if removable_local_ids:
            historico = _read_json_file(HISTORY_FILE, [])
            historico_restante = [
                medicion for medicion in historico
                if medicion.get('id') not in removable_local_ids
            ]
            if len(historico_restante) != len(historico):
                cleared = _actualizar_historial_local(historico_restante)

    return {'synced': synced, 'failed': failed, 'cleared': cleared}


class LocalApiHandler(BaseHTTPRequestHandler):
    def _set_json_headers(self, status=200):
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.end_headers()

    def do_OPTIONS(self):
        self._set_json_headers()

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path
        query = parse_qs(parsed.query)

        # Ruta raíz o health
        if path in ('/', '/health'):
            payload = {
                'status': 'ok',
                'service': 'receiver-local-api',
                'host': LOCAL_API_HOST,
                'port': LOCAL_API_PORT,
                **_build_local_api_payload(),
            }
            self._set_json_headers()
            self.wfile.write(json.dumps(payload, ensure_ascii=False).encode('utf-8'))
            return

        # Endpoints locales propios
        if path == '/api/local/latest':
            latest = _read_json_file(LATEST_FILE, {})
            self._set_json_headers()
            self.wfile.write(json.dumps(latest, ensure_ascii=False).encode('utf-8'))
            return

        if path == '/api/local/history':
            history = _read_json_file(HISTORY_FILE, [])
            limit = query.get('limit', [None])[0]
            try:
                limit = int(limit) if limit is not None else None
            except ValueError:
                limit = None
            if limit and limit > 0:
                history = history[-limit:]
            self._set_json_headers()
            self.wfile.write(json.dumps(history, ensure_ascii=False).encode('utf-8'))
            return

        if path == '/api/local/pending':
            pending = _read_json_file(PENDING_FILE, [])
            self._set_json_headers()
            self.wfile.write(json.dumps(pending, ensure_ascii=False).encode('utf-8'))
            return

        # ======== NUEVOS ENDPOINTS PARA EMULAR FastAPI ========
        if path == '/api/mediciones/waspmote/latest':
            latest = _read_json_file(LATEST_FILE, {})
            self._set_json_headers()
            self.wfile.write(json.dumps(latest, ensure_ascii=False).encode('utf-8'))
            return

        if path == '/api/estado-sistema/waspmote/latest':
            latest = _read_json_file(LATEST_FILE, {})
            bateria = latest.get('bateria') if isinstance(latest, dict) else None
            respuesta = {'bateria': bateria, 'timestamp': latest.get('timestamp')} if bateria is not None else {}
            self._set_json_headers()
            self.wfile.write(json.dumps(respuesta, ensure_ascii=False).encode('utf-8'))
            return

        if path == '/api/mediciones/waspmote/historical':
            history = _read_json_file(HISTORY_FILE, [])
            horas = query.get('horas', [None])[0]
            if horas is not None:
                try:
                    limit = int(horas) * 10  # aprox 10 mediciones por hora
                    history = history[-limit:]
                except:
                    pass
            self._set_json_headers()
            self.wfile.write(json.dumps(history, ensure_ascii=False).encode('utf-8'))
            return
        # ====================================================

        # Si ninguna ruta coincide
        self._set_json_headers(404)
        self.wfile.write(json.dumps({'detail': 'Not Found'}, ensure_ascii=False).encode('utf-8'))
    

    def log_message(self, format, *args):
        return


def start_local_api_server():
    server = ThreadingHTTPServer((LOCAL_API_HOST, LOCAL_API_PORT), LocalApiHandler)
    thread = Thread(target=server.serve_forever, daemon=True)
    thread.start()
    print(f'API local activa en http://127.0.0.1:{LOCAL_API_PORT}')
    print(f'API local accesible en red en http://{_get_local_ip()}:{LOCAL_API_PORT}')
    return server


def convert_watermark_to_percentage(watermark_hz):
    """Convierte Hz del Watermark a porcentaje - escala inversa."""
    if watermark_hz < 50:
        watermark_hz = 50
    elif watermark_hz > 10000:
        watermark_hz = 10000

    porcentaje = 100.0 - ((watermark_hz - 50) / 99.5) * 100.0
    return max(0.0, min(100.0, porcentaje))


def clean_sensor_data(raw_string):
    """Limpia caracteres extraños y extrae los datos del sensor."""
    try:
        print(f'Dato crudo recibido: {repr(raw_string)}')

        pattern = r'T:\s*([\d.-]+),\s*H:\s*([\d.-]+),\s*L:\s*([\d.-]+),\s*W:\s*([\d.-]+),\s*B:\s*([\d.-]+)'
        match = re.search(pattern, raw_string)

        if match:
            temperature = float(match.group(1))
            humidity = float(match.group(2))
            luminosity = float(match.group(3))
            watermark_hz = float(match.group(4))
            battery = float(match.group(5))

            humedad_suelo_porcentaje = convert_watermark_to_percentage(watermark_hz)

            if (-40 <= temperature <= 80 and
                0 <= humidity <= 100 and
                0 <= luminosity <= 20000 and
                0 <= watermark_hz <= 20000 and
                0 <= battery <= 100):
                return {
                    'temperatura': round(temperature, 2),
                    'humedad': round(humidity, 2),
                    'luminosidad': round(luminosity, 2),
                    'humedad_suelo': round(humedad_suelo_porcentaje, 1),
                    'bateria': round(battery, 1)
                }

            print('Datos fuera de rango valido')
            return None

        pattern_old = r'T:\s*([\d.-]+),\s*H:\s*([\d.-]+),\s*L:\s*([\d.-]+),\s*W:\s*([\d.-]+)'
        match_old = re.search(pattern_old, raw_string)

        if match_old:
            temperature = float(match_old.group(1))
            humidity = float(match_old.group(2))
            luminosity = float(match_old.group(3))
            watermark_hz = float(match_old.group(4))

            if (-40 <= temperature <= 80 and
                0 <= humidity <= 100 and
                0 <= luminosity <= 20000 and
                0 <= watermark_hz <= 20000):
                humedad_suelo_porcentaje = convert_watermark_to_percentage(watermark_hz)
                return {
                    'temperatura': round(temperature, 2),
                    'humedad': round(humidity, 2),
                    'luminosidad': round(luminosity, 2),
                    'humedad_suelo': round(humedad_suelo_porcentaje, 1),
                    'bateria': None
                }

            print('Datos fuera de rango valido')
            return None

        print('No se encontro patron de sensor')
        return None

    except Exception as e:
        print(f'Error limpiando datos: {e}')
        return None


def send_to_api(sensor_data):
    """Enviar datos a la API."""
    try:
        mediciones_data = {
            'temperatura': sensor_data['temperatura'],
            'humedad': sensor_data['humedad'],
            'luminosidad': sensor_data['luminosidad'],
            'humedad_suelo': sensor_data['humedad_suelo']
        }

        registro_local = None

        print(f'Enviando mediciones a API: {mediciones_data}')
        try:
            response_mediciones = requests.post(
                MEDICIONES_URL,
                json=mediciones_data,
                timeout=5
            )
            if response_mediciones.status_code == 200:
                print('Mediciones enviadas exitosamente')
            else:
                print(f'Error enviando mediciones: {response_mediciones.text}')
                if registro_local is None:
                    registro_local = guardar_en_json(sensor_data)
                guardar_pendiente('mediciones', mediciones_data, MEDICIONES_URL, registro_local.get('id') if registro_local else None)
        except requests.RequestException as e:
            print(f'Error de conexion enviando mediciones: {e}')
            if registro_local is None:
                registro_local = guardar_en_json(sensor_data)
            guardar_pendiente('mediciones', mediciones_data, MEDICIONES_URL, registro_local.get('id') if registro_local else None)

        if sensor_data.get('bateria') is not None:
            estado_data = {
                'dispositivo_id': 1,
                'bateria': sensor_data['bateria']
            }

            print(f'Enviando estado de bateria: {sensor_data["bateria"]}%')
            try:
                response_estado = requests.post(
                    ESTADO_URL,
                    json=estado_data,
                    timeout=5
                )
                if response_estado.status_code == 200:
                    print('Estado de bateria enviado exitosamente')
                else:
                    print(f'Error enviando bateria: {response_estado.text}')
                    if registro_local is None:
                        registro_local = guardar_en_json(sensor_data)
                    guardar_pendiente('bateria', estado_data, ESTADO_URL, registro_local.get('id') if registro_local else None)
            except requests.RequestException as e:
                print(f'Error de conexion enviando bateria: {e}')
                if registro_local is None:
                    registro_local = guardar_en_json(sensor_data)
                guardar_pendiente('bateria', estado_data, ESTADO_URL, registro_local.get('id') if registro_local else None)

        reintentar_pendientes()
        return True

    except Exception as e:
        print(f'Error de conexion: {e}')
        print('Guardando backup en archivo de texto...')
        with open('sensor_backup.txt', 'a', encoding='utf-8') as f:
            f.write(f'{datetime.now()}: {sensor_data}\n')
        return False


def main():
    try:
        _ensure_local_storage()
        start_local_api_server()

        ser = serial.Serial(
            port=SERIAL_PORT,
            baudrate=BAUD_RATE,
            timeout=1,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE
        )

        print(f'Conectado a {SERIAL_PORT} a {BAUD_RATE} baudios')
        print('Esperando datos del sensor... (Ctrl+C para detener)')
        print('Formato esperado: T:25.50,H:60.20,L:450.00,W:51.90,B:85.50')
        print('Watermark: 50Hz=100%, 10000Hz=0% (escala inversa)')
        print('Bateria: 0-100%')
        print(f'Guardando JSON en: {JSON_FILE}')

        while True:
            try:
                if ser.in_waiting > 0:
                    raw_line = ser.readline()

                    try:
                        decoded_line = raw_line.decode('utf-8').strip()
                    except UnicodeDecodeError:
                        decoded_line = raw_line.decode('latin-1').strip()

                    if decoded_line:
                        sensor_data = clean_sensor_data(decoded_line)
                        if sensor_data:
                            send_to_api(sensor_data)

                time.sleep(0.1)

            except Exception as e:
                print(f'Error en loop: {e}')
                time.sleep(1)

    except serial.SerialException as e:
        print(f'Error de puerto serial: {e}')
    except KeyboardInterrupt:
        print('\nPrograma detenido por el usuario')
    finally:
        if 'ser' in locals() and ser.is_open:
            ser.close()
            print('Puerto serial cerrado')


if __name__ == '__main__':
    main()
