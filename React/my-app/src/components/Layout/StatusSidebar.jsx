// src/components/Layout/StatusSidebar.jsx
import StorageLevel from '../Dashboard/StorageLevel.jsx';
import OfflineStorageIndicator from '../Dashboard/OfflineStorageIndicator.jsx';
import '../../styles/index.css';

function StatusSidebar({ batteryData }) {
  return (
    <div className="status-sidebar">
      <StorageLevel batteryData={batteryData} />
      <OfflineStorageIndicator compact={false} />
    </div>
  );
}

export default StatusSidebar;
