// src/components/Dashboard/BatteryIcon.jsx
import React from 'react';

const BatteryIcon = ({ percentage, width = 16, height = 28 }) => {
  const clamped = Math.min(100, Math.max(0, percentage));
  const innerHeight = height - 6; // espacio para el terminal
  const fillHeight = (clamped / 100) * innerHeight;
  const y = height - 4 - fillHeight; // relleno desde abajo

  const getColor = () => {
    if (clamped > 70) return '#4caf50';
    if (clamped > 30) return '#ff9800';
    return '#f44336';
  };

  return (
    <svg width={width} height={height} viewBox="0 0 16 28" fill="none">
      {/* Cuerpo de la batería */}
      <rect x="1" y="3" width="14" height="23" rx="3" stroke="currentColor" strokeWidth="1.5" />
      {/* Terminal positivo (arriba) */}
      <rect x="5" y="0.5" width="6" height="3" rx="1.5" fill="currentColor" />
      {/* Relleno de nivel (sube desde abajo) */}
      <rect
        x="2.5"
        y={y}
        width="11"
        height={fillHeight}
        rx="2"
        fill={getColor()}
        style={{ transition: 'height 0.3s ease' }}
      />
    </svg>
  );
};

export default BatteryIcon;