import StorageLevel from '../Dashboard/StorageLevel.jsx';
import OfflineStorageIndicator from '../Dashboard/OfflineStorageIndicator.jsx';
import SdSyncControl from '../Dashboard/SdSyncControl.jsx';
import '../../styles/index.css';

function StatusSidebar({ batteryData, syncDate, onSyncDateChange, onSyncClick, onSyncCancel, isMeasuring, isSyncingSd, serialConnected }) {
  return (
    <div className="status-sidebar">
      <StorageLevel batteryData={batteryData} />
      <OfflineStorageIndicator compact={false} />
      <SdSyncControl
        syncDate={syncDate}
        onSyncDateChange={onSyncDateChange}
        onSyncClick={onSyncClick}
        onSyncCancel={onSyncCancel}
        isMeasuring={isMeasuring}
        isSyncingSd={isSyncingSd}
        serialConnected={serialConnected}
      />
    </div>
  );
}

export default StatusSidebar;