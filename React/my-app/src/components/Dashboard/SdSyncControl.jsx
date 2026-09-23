import '../../styles/Layout.css';

function SdSyncControl({ syncDate, onSyncDateChange, onSyncClick, isMeasuring, isSyncingSd, serialConnected }) {
  return (
    <div className="sd-sync-card">
      <h3>Sincronizar SD</h3>
      <div className="storage-content">
        <label className="sync-date-control">
          <span>Fecha SD</span>
          <input
            type="date"
            value={syncDate}
            onChange={(event) => onSyncDateChange(event.target.value)}
            disabled={isMeasuring || isSyncingSd}
            aria-label="Fecha que se sincronizara desde la tarjeta SD"
          />
        </label>
        <button
          className="manual-measure-button sync-sd-button"
          onClick={onSyncClick}
          disabled={!serialConnected || isMeasuring || isSyncingSd || !syncDate}
          title={isSyncingSd
            ? 'Sincronización de la SD en curso…'
            : isMeasuring
              ? 'Detén las medidas antes de sincronizar la memoria SD'
              : 'Sincronizar registros conservados en la memoria SD'}
        >
          {isSyncingSd ? 'Sincronizando…' : 'Sincronizar SD'}
        </button>
      </div>
    </div>
  );
}

export default SdSyncControl;