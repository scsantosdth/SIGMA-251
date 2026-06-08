import serial
import requests
import re
import time
from datetime import datetime

# Configuración - NUEVOS ENDPOINTS
API_BASE_URL = 'http://localhost:8000'
MEDICIONES_URL = f'{API_BASE_URL}/api/mediciones/waspmote'
ESTADO_URL = f'{API_BASE_URL}/api/estado-sistema/waspmote'

SERIAL_PORT = 'COM8'
BAUD_RATE = 115200

def convert_watermark_to_percentage(watermark_hz):
    """Convierte Hz del Watermark a porcentaje - ESCALA INVERSA CORRECTA"""
    if watermark_hz < 50:
        watermark_hz = 50
    elif watermark_hz > 10000:
        watermark_hz = 10000
    
    porcentaje = 100.0 - ((watermark_hz - 50) / 99.5) * 100.0
    return max(0.0, min(100.0, porcentaje))

def clean_sensor_data(raw_string):
    """Limpia los caracteres extraños y extrae los datos del sensor"""
    try:
        print(f"📨 Dato crudo recibido: {repr(raw_string)}")
        
        # Buscar el patrón T: número, H: número, L: número, W: número, B: número
        pattern = r'T:\s*([\d.-]+),\s*H:\s*([\d.-]+),\s*L:\s*([\d.-]+),\s*W:\s*([\d.-]+),\s*B:\s*([\d.-]+)'
        match = re.search(pattern, raw_string)
        
        if match:
            temperature = float(match.group(1))
            humidity = float(match.group(2))
            luminosity = float(match.group(3))
            watermark_hz = float(match.group(4))
            battery = float(match.group(5))
            
            # Convertir Watermark Hz a porcentaje
            humedad_suelo_porcentaje = convert_watermark_to_percentage(watermark_hz)
            
            # Validar rangos razonables
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
            else:
                print("⚠️  Datos fuera de rango válido")
                return None
        else:
            # Intentar con patrón anterior (sin batería) para compatibilidad
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
                else:
                    print("⚠️  Datos fuera de rango válido")
                    return None
            else:
                print("❌ No se encontró patrón de sensor")
                return None
            
    except Exception as e:
        print(f"❌ Error limpiando datos: {e}")
        return None

# En la función send_to_api, modifica así:

def send_to_api(sensor_data):
    """Enviar datos a la API - ESTRUCTURA CORREGIDA"""
    try:
        # Enviar mediciones de sensores
        mediciones_data = {
            'temperatura': sensor_data['temperatura'],
            'humedad': sensor_data['humedad'], 
            'luminosidad': sensor_data['luminosidad'],
            'humedad_suelo': sensor_data['humedad_suelo']
        }
        
        print(f"📤 Enviando mediciones a API: {mediciones_data}")
        response_mediciones = requests.post(
            'http://localhost:8000/api/mediciones/waspmote',  # URL directa
            json=mediciones_data, 
            timeout=5
        )
        
        if response_mediciones.status_code == 200:
            print("✅ Mediciones enviadas exitosamente")
        else:
            print(f"❌ Error enviando mediciones: {response_mediciones.text}")
            return False
        
        # Enviar estado de batería si está disponible
        if sensor_data.get('bateria') is not None:
            estado_data = {
                'dispositivo_id': 1,  # Waspmote principal
                'bateria': sensor_data['bateria']
            }
            
            print(f"🔋 Enviando estado de batería: {sensor_data['bateria']}%")
            response_estado = requests.post(
                'http://localhost:8000/api/estado-sistema/waspmote',  # URL directa
                json=estado_data,
                timeout=5
            )
            
            if response_estado.status_code == 200:
                print("✅ Estado de batería enviado exitosamente")
            else:
                print(f"⚠️ Error enviando batería: {response_estado.text}")
        
        return True
            
    except Exception as e:
        print(f"🌐 Error de conexión: {e}")
        return False

def main():
    try:
        # Configurar puerto serial
        ser = serial.Serial(
            port=SERIAL_PORT,
            baudrate=BAUD_RATE,
            timeout=1,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE
        )
        
        print(f"🔌 Conectado a {SERIAL_PORT} a {BAUD_RATE} baudios")
        print("📡 Esperando datos del sensor... (Ctrl+C para detener)")
        print("💡 Formato esperado: T:25.50,H:60.20,L:450.00,W:51.90,B:85.50")
        print("💡 Watermark: 50Hz=100%, 10000Hz=0% (escala inversa)")
        print("💡 Batería: 0-100%")
        
        while True:
            try:
                if ser.in_waiting > 0:
                    # Leer línea
                    raw_line = ser.readline()
                    
                    # Intentar decodificar
                    try:
                        decoded_line = raw_line.decode('utf-8').strip()
                    except UnicodeDecodeError:
                        decoded_line = raw_line.decode('latin-1').strip()
                    
                    if decoded_line:
                        # Limpiar y procesar datos
                        sensor_data = clean_sensor_data(decoded_line)
                        
                        if sensor_data:
                            success = send_to_api(sensor_data)
                            if not success:
                                print("💾 Guardando localmente (modo respaldo)...")
                                with open("sensor_backup.txt", "a") as f:
                                    f.write(f"{datetime.now()}: {sensor_data}\n")
                
                time.sleep(0.1)
                
            except Exception as e:
                print(f"⚠️  Error en loop: {e}")
                time.sleep(1)
                
    except serial.SerialException as e:
        print(f"❌ Error de puerto serial: {e}")
    except KeyboardInterrupt:
        print("\n🛑 Programa detenido por el usuario")
    finally:
        if 'ser' in locals() and ser.is_open:
            ser.close()
            print("🔒 Puerto serial cerrado")

if __name__ == "__main__":
    main()