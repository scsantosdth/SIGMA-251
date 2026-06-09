import serial
import requests
import re
import time
import json
import os
from datetime import datetime

# Configuracion
API_BASE_URL = os.getenv('API_BASE_URL', 'https://sigma-251.onrender.com').rstrip('/')
MEDICIONES_URL = f'{API_BASE_URL}/api/mediciones/waspmote'
ESTADO_URL = f'{API_BASE_URL}/api/estado-sistema/waspmote'

SERIAL_PORT = 'COM8'
BAUD_RATE = 115200

# Configuracion JSON para frontend
JSON_FILE = r'C:\Users\scsan\Documents\UIS\2026-1\TG2\Codigos\SIGMA-251\React\my-app\public\datos_sensor.json'
MAX_MEDICIONES = 100


def guardar_en_json(medicion):
    """Guarda la medicion en un archivo JSON para el frontend."""
    try:
        os.makedirs(os.path.dirname(JSON_FILE), exist_ok=True)

        if not os.path.exists(JSON_FILE):
            with open(JSON_FILE, 'w', encoding='utf-8') as f:
                json.dump([], f)
            mediciones = []
        else:
            try:
                with open(JSON_FILE, 'r', encoding='utf-8') as f:
                    contenido = f.read().strip()
                    if contenido:
                        mediciones = json.loads(contenido)
                    else:
                        mediciones = []
            except (json.JSONDecodeError, ValueError):
                print('Archivo JSON corrupto, creando nuevo')
                mediciones = []

        medicion_con_timestamp = {
            **medicion,
            'timestamp': datetime.now().isoformat(),
            'id': int(datetime.now().timestamp() * 1000)
        }
        mediciones.append(medicion_con_timestamp)

        if len(mediciones) > MAX_MEDICIONES:
            mediciones = mediciones[-MAX_MEDICIONES:]

        with open(JSON_FILE, 'w', encoding='utf-8') as f:
            json.dump(mediciones, f, indent=2)

        print(f'JSON guardado: {JSON_FILE} ({len(mediciones)} mediciones)')
        return True
    except Exception as e:
        print(f'Error guardando JSON: {e}')
        return False


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
        guardar_en_json(sensor_data)

        mediciones_data = {
            'temperatura': sensor_data['temperatura'],
            'humedad': sensor_data['humedad'],
            'luminosidad': sensor_data['luminosidad'],
            'humedad_suelo': sensor_data['humedad_suelo']
        }

        print(f'Enviando mediciones a API: {mediciones_data}')
        response_mediciones = requests.post(
            MEDICIONES_URL,
            json=mediciones_data,
            timeout=5
        )

        if response_mediciones.status_code == 200:
            print('Mediciones enviadas exitosamente')
        else:
            print(f'Error enviando mediciones: {response_mediciones.text}')
            return False

        if sensor_data.get('bateria') is not None:
            estado_data = {
                'dispositivo_id': 1,
                'bateria': sensor_data['bateria']
            }

            print(f'Enviando estado de bateria: {sensor_data["bateria"]}%')
            response_estado = requests.post(
                ESTADO_URL,
                json=estado_data,
                timeout=5
            )

            if response_estado.status_code == 200:
                print('Estado de bateria enviado exitosamente')
            else:
                print(f'Error enviando bateria: {response_estado.text}')

        return True

    except Exception as e:
        print(f'Error de conexion: {e}')
        print('Guardando backup en archivo de texto...')
        with open('sensor_backup.txt', 'a', encoding='utf-8') as f:
            f.write(f'{datetime.now()}: {sensor_data}\n')
        return False


def main():
    try:
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
