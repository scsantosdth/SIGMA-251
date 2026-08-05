import { useCallback, useEffect, useRef, useState } from 'react';
import { WEB_SERIAL_BAUD_RATE, isWebSerialSupported, parseXBeeLine } from '../services/serialService.jsx';

const initialState = {
  supported: isWebSerialSupported(),
  connected: false,
  connecting: false,
  error: null,
  lastLine: null,
  lastTimestamp: null,
};

export function useXBeeSerial(onMeasurement) {
  const [serialState, setSerialState] = useState(initialState);
  const onMeasurementRef = useRef(onMeasurement);
  const portRef = useRef(null);
  const readerRef = useRef(null);
  const keepReadingRef = useRef(false);
  const decoderRef = useRef(new TextDecoder());
  const bufferRef = useRef('');

  useEffect(() => {
    onMeasurementRef.current = onMeasurement;
  }, [onMeasurement]);

  const processLine = useCallback((line) => {
    const parsed = parseXBeeLine(line);

    setSerialState((current) => ({
      ...current,
      lastLine: line,
      lastTimestamp: new Date().toISOString(),
      error: parsed ? null : current.error,
    }));

    if (parsed) {
      onMeasurementRef.current?.(parsed, line);
    }
  }, []);

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
            const lines = bufferRef.current.split(/\r?\n/);
            bufferRef.current = lines.pop() || '';

            lines.map((line) => line.trim()).filter(Boolean).forEach(processLine);
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
  }, [processLine]);

  const disconnect = useCallback(async () => {
    keepReadingRef.current = false;

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
  }, []);

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
      await port.open({ baudRate: WEB_SERIAL_BAUD_RATE });

      portRef.current = port;
      setSerialState((current) => ({
        ...current,
        connected: true,
        connecting: false,
        error: null,
      }));

      readLoop(port);
    } catch (error) {
      await disconnect();
      setSerialState((current) => ({
        ...current,
        connected: false,
        connecting: false,
        error: error?.message || 'No se pudo conectar el XBee',
      }));
    }
  }, [disconnect, readLoop]);

  useEffect(() => {
    return () => {
      disconnect();
    };
  }, [disconnect]);

  return {
    ...serialState,
    connect,
    disconnect,
  };
}
