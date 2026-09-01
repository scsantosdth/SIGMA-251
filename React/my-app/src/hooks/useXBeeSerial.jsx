import { useCallback, useEffect, useRef, useState } from 'react';
import { WEB_SERIAL_BAUD_RATE, isWebSerialSupported, parseXBeeLine, parseSdRecordLine } from '../services/serialService.jsx';

const XBee_RECONNECT_KEY = 'sigma_xbee_reconnect';
const wait = (milliseconds) => new Promise((resolve) => window.setTimeout(resolve, milliseconds));
const MAX_SERIAL_BUFFER_LENGTH = 4096;

const initialState = {
  supported: isWebSerialSupported(),
  connected: false,
  connecting: false,
  error: null,
  lastLine: null,
  lastTimestamp: null,
  commandStatus: null,
};

export function useXBeeSerial(onMeasurement, onControlMessage) {
  const [serialState, setSerialState] = useState(initialState);
  const onMeasurementRef = useRef(onMeasurement);
  const onControlMessageRef = useRef(onControlMessage);
  const portRef = useRef(null);
  const readerRef = useRef(null);
  const keepReadingRef = useRef(false);
  const decoderRef = useRef(new TextDecoder());
  const bufferRef = useRef('');
  const partialLineTimerRef = useRef(null);

  const setReconnectPreference = useCallback((shouldReconnect) => {
    try {
      if (shouldReconnect) {
        window.localStorage.setItem(XBee_RECONNECT_KEY, 'true');
      } else {
        window.localStorage.removeItem(XBee_RECONNECT_KEY);
      }
    } catch {
      // Si localStorage no esta disponible, la conexion funciona durante la sesion actual.
    }
  }, []);

  const shouldReconnect = useCallback(() => {
    try {
      return window.localStorage.getItem(XBee_RECONNECT_KEY) === 'true';
    } catch {
      return false;
    }
  }, []);

  useEffect(() => {
    onMeasurementRef.current = onMeasurement;
    onControlMessageRef.current = onControlMessage;
  }, [onMeasurement, onControlMessage]);

  const processLine = useCallback((line) => {
    const sdRecord = parseSdRecordLine(line);
    const parsed = parseXBeeLine(line);

    setSerialState((current) => ({
      ...current,
      lastLine: line,
      lastTimestamp: new Date().toISOString(),
      error: parsed ? null : current.error,
      commandStatus: /^SD_RECORD:/i.test(line)
        ? `Registro SD recibido: ${line.slice('SD_RECORD:'.length)}`
        : /^(PONG|SYNC_ACK|SYNC_BEGIN|SYNC_END|SD_EMPTY)\s*$/i.test(line)
          ? current.commandStatus
          : current.commandStatus,
    }));

    if (sdRecord) {
      onControlMessageRef.current?.({ type: 'sd-record', record: sdRecord, line });
    } else if (/^SYNC_BEGIN\s*$/i.test(line)) {
      onControlMessageRef.current?.({ type: 'sync-begin', line });
    } else if (/^SYNC_END\s*$/i.test(line)) {
      onControlMessageRef.current?.({ type: 'sync-end', line });
    } else if (parsed) {
      onMeasurementRef.current?.(parsed, line);
    }
  }, []);

  const processBufferedPayload = useCallback(() => {
    const payload = bufferRef.current.trim();
    if (!payload || !parseXBeeLine(payload)) return;
    bufferRef.current = '';
    processLine(payload);
  }, [processLine]);

  const schedulePartialPayload = useCallback(() => {
    clearTimeout(partialLineTimerRef.current);
    partialLineTimerRef.current = setTimeout(processBufferedPayload, 120);
  }, [processBufferedPayload]);

  const readLoop = useCallback(async (port) => {
    keepReadingRef.current = true;
    decoderRef.current = new TextDecoder();
    bufferRef.current = '';

    try {
      while (port.readable && keepReadingRef.current) {
        const reader = port.readable.getReader();
        readerRef.current = reader;

        try {
          while (keepReadingRef.current) {
            const { value, done } = await reader.read();
            if (done) break;
            if (!value) continue;

            bufferRef.current += decoderRef.current.decode(value, { stream: true });

            // Una trama puede llegar fragmentada, pero el buffer nunca debe
            // crecer indefinidamente si llega ruido o una trama corrupta.
            if (bufferRef.current.length > MAX_SERIAL_BUFFER_LENGTH) {
              const nextFrame = bufferRef.current.lastIndexOf('T:');
              bufferRef.current = nextFrame >= 0
                ? bufferRef.current.slice(nextFrame)
                : '';
              setSerialState((current) => ({
                ...current,
                error: 'Se descartaron datos seriales incompletos; esperando la siguiente medicion.',
              }));
            }

            const lines = bufferRef.current.split(/\r?\n/);
            bufferRef.current = lines.pop() || '';

            lines.map((line) => line.trim()).filter(Boolean).forEach(processLine);
            // Compatibilidad temporal con firmware anterior sin salto de linea.
            // El firmware actual delimita cada payload con \n, que es la via
            // normal y evita perder tramas concatenadas.
            schedulePartialPayload();
          }
        } finally {
          reader.releaseLock();
          if (readerRef.current === reader) {
            readerRef.current = null;
          }
        }
      }
    } catch (error) {
      if (keepReadingRef.current) {
        setSerialState((current) => ({
          ...current,
          connected: false,
          connecting: false,
          error: error?.message || 'Error leyendo el puerto serial',
        }));
      }
    }
  }, [processLine, schedulePartialPayload]);

  const disconnect = useCallback(async ({ forgetPreference = true } = {}) => {
    keepReadingRef.current = false;
    clearTimeout(partialLineTimerRef.current);

    if (forgetPreference) {
      setReconnectPreference(false);
    }

    try {
      await readerRef.current?.cancel();
    } catch {
      // El reader puede estar ya cerrado.
    }

    try {
      await portRef.current?.close();
    } catch {
      // El puerto puede estar ya cerrado o esperando liberar locks.
    }

    portRef.current = null;
    readerRef.current = null;
    bufferRef.current = '';

    setSerialState((current) => ({
      ...current,
      connected: false,
      connecting: false,
    }));
  }, [setReconnectPreference]);

  const openPort = useCallback(async (port) => {
    if (!port.readable) {
      await port.open({ baudRate: WEB_SERIAL_BAUD_RATE });
    }

    portRef.current = port;
    setSerialState((current) => ({
      ...current,
      connected: true,
      connecting: false,
      error: null,
    }));
    readLoop(port);
  }, [readLoop]);

  const connect = useCallback(async () => {
    if (!isWebSerialSupported()) {
      setSerialState((current) => ({
        ...current,
        supported: false,
        error: 'Web Serial no esta disponible en este navegador. Usa Chrome o Edge.',
      }));
      return;
    }

    setSerialState((current) => ({
      ...current,
      supported: true,
      connecting: true,
      error: null,
    }));

    try {
      const port = await navigator.serial.requestPort();
      await openPort(port);
      setReconnectPreference(true);
    } catch (error) {
      await disconnect({ forgetPreference: false });
      setSerialState((current) => ({
        ...current,
        connected: false,
        connecting: false,
        error: error?.message || 'No se pudo conectar el XBee',
      }));
    }
  }, [disconnect, openPort, setReconnectPreference]);

  const sendCommand = useCallback(async (command) => {
    const port = portRef.current;
    if (!port?.writable || !serialState.connected) {
      throw new Error('Conecta primero el XBee');
    }

    const normalizedCommand = String(command || '').trim();
    if (!normalizedCommand) throw new Error('La petición está vacía');

    setSerialState((current) => ({
      ...current,
      commandStatus: `Enviando: ${normalizedCommand}`,
      error: null,
    }));

    const writer = port.writable.getWriter();
    try {
      await writer.write(new TextEncoder().encode(`${normalizedCommand}\n`));
    } finally {
      writer.releaseLock();
    }
  }, [serialState.connected]);

  // Solo se restablece la conexion cuando el usuario la dejo conectada antes
  // de recargar. Chrome/Edge conserva el permiso del puerto ya autorizado.
  useEffect(() => {
    if (!isWebSerialSupported() || !shouldReconnect()) return undefined;
    let cancelled = false;

    navigator.serial.getPorts().then(async (ports) => {
      if (cancelled || ports.length === 0 || portRef.current) return;
      setSerialState((current) => ({ ...current, connecting: true, error: null }));

      let lastError;
      for (let attempt = 0; attempt < 6 && !cancelled; attempt += 1) {
        try {
          await openPort(ports[0]);
          return;
        } catch (error) {
          lastError = error;
          await wait(500);
        }
      }

      if (!cancelled) {
        setSerialState((current) => ({
          ...current,
          connected: false,
          connecting: false,
          error: lastError?.message || 'No se pudo reconectar el XBee',
        }));
      }
    });

    return () => { cancelled = true; };
  }, [openPort, shouldReconnect]);

  useEffect(() => {
    return () => {
      // Al desmontar por una recarga se cierra el puerto, pero se conserva la
      // eleccion del usuario para que el nuevo documento pueda reconectarlo.
      disconnect({ forgetPreference: false });
    };
  }, [disconnect]);

  return {
    ...serialState,
    connect,
    disconnect,
    sendCommand,
  };
}
