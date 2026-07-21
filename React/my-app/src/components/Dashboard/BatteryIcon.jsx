// src/components/Dashboard/BatteryIcon.jsx
import React from 'react';

const BatteryIcon = ({ percentage, width = 16, height = 28 }) => {
  const clamped = Math.min(100, Math.max(0, percentage));
  
  // Dimensiones del cuerpo de la batería (coordenadas y tamaños)
  const bodyX = 1;
  const bodyY = 3;
  const bodyWidth = 14;
  const bodyHeight = 23;
  const margin = 2; // margen interior (arriba y abajo)
  const innerHeight = bodyHeight - 2 * margin; // alto útil para el relleno

  // Altura del relleno proporcional al porcentaje
  const fillHeight = (clamped / 100) * innerHeight;
  // Coordenada Y superior del relleno: base fija en (bodyY + bodyHeight - margin)
  const fillY = bodyY + bodyHeight - margin - fillHeight;

  const getColor = () => {
    if (clamped > 70) return '#4caf50';   // verde
    if (clamped > 30) return '#ff9800';   // naranja
    return '#f44336';                     // rojo
  };

  return (
    <svg width={width} height={height} viewBox="0 0 16 28" fill="none" xmlns="http://www.w3.org/2000/svg">
      {/* Cuerpo de la batería */}
      <rect
        x={bodyX}
        y={bodyY}
        width={bodyWidth}
        height={bodyHeight}
        rx="3"
        stroke="currentColor"
        strokeWidth="1.5"
        fill="none"
      />
      {/* Terminal positivo (arriba) */}
      <rect x="5" y="0.5" width="6" height="3" rx="1.5" fill="currentColor" />
      {/* Relleno de nivel (sube desde abajo) */}
      <rect
        x={bodyX + 1.5}
        y={fillY}
        width={bodyWidth - 3}
        height={fillHeight}
        rx="1.5"
        fill={getColor()}
        style={{ transition: 'height 0.3s ease' }}
      />
    </svg>
  );
};

export default BatteryIcon;