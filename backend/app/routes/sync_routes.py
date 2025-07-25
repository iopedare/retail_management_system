from flask import Blueprint, request, jsonify, current_app
from app import db
from app.models.sync_event import SyncEvent
import datetime
from app.models.sync_audit_log import SyncAuditLog

sync_bp = Blueprint('sync', __name__)

@sync_bp.route('/sync/push', methods=['POST'])
def push_sync_event():
    """Endpoint for clients to push new sync events to the master node."""
    data = request.get_json()
    # Validate required fields
    required_fields = ['event_type', 'payload', 'device_id']
    missing = [f for f in required_fields if f not in data]
    if missing:
        return jsonify({'error': f'Missing fields: {", ".join(missing)}'}), 400

    # Create SyncEvent instance
    try:
        event = SyncEvent(
            event_type=data['event_type'],
            payload=data['payload'],
            device_id=data['device_id'],
            user_id=data.get('user_id'),
            timestamp=data.get('timestamp', datetime.datetime.utcnow()),
            status='pending'
        )
        db.session.add(event)
        db.session.commit()
        # Log audit
        log = SyncAuditLog(
            event_type=data['event_type'],
            operation='push',
            status='success',
            device_id=data['device_id'],
            user_id=data.get('user_id'),
            details=f'Event {event.id} pushed'
        )
        db.session.add(log)
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        # Log the error for debugging and audit
        log = SyncAuditLog(
            event_type=data.get('event_type'),
            operation='push',
            status='error',
            device_id=data.get('device_id'),
            user_id=data.get('user_id'),
            details=str(e)
        )
        db.session.add(log)
        db.session.commit()
        return jsonify({'error': f'Failed to queue event: {str(e)}'}), 500

    # (Optional) Trigger immediate sync for critical events
    # if event.event_type in ["stock_update", "critical_event"]:
    #     current_app.sync_manager.perform_immediate_sync(event)

    return jsonify({'message': 'Event queued', 'event_id': event.id}), 200

@sync_bp.route('/sync/pull', methods=['GET'])
def pull_sync_events():
    """Endpoint for clients to pull pending sync events from the master node."""
    from app.models.sync_event import SyncEvent
    from app import db
    import datetime

    device_id = request.args.get('device_id')
    since = request.args.get('since')

    # Validate device_id
    if not device_id:
        return jsonify({'error': 'Missing device_id parameter'}), 400

    # Build query for pending events not from this device
    query = SyncEvent.query.filter(SyncEvent.device_id != device_id, SyncEvent.status == 'pending')
    if since:
        try:
            since_dt = datetime.datetime.fromisoformat(since)
            query = query.filter(SyncEvent.timestamp > since_dt)
        except Exception:
            return jsonify({'error': 'Invalid since timestamp format. Use ISO format.'}), 400

    events = query.order_by(SyncEvent.timestamp.asc()).all()

    # Serialize events
    def serialize_event(event):
        return {
            'id': event.id,
            'event_type': event.event_type,
            'payload': event.payload,
            'timestamp': event.timestamp.isoformat() if event.timestamp else None,
            'status': event.status,
            'device_id': event.device_id,
            'user_id': event.user_id
        }
    events_json = [serialize_event(e) for e in events]

    return jsonify({'events': events_json}), 200

@sync_bp.route('/sync/status', methods=['GET'])
def sync_status():
    """Endpoint to query sync status/history for a device/user."""
    from app.models.sync_event import SyncEvent
    from app import db
    import datetime

    device_id = request.args.get('device_id')
    user_id = request.args.get('user_id')
    limit = int(request.args.get('limit', 20))  # Limit history to last N events

    # Require at least one identifier
    if not device_id and not user_id:
        return jsonify({'error': 'Missing device_id or user_id parameter'}), 400

    # Build query for events
    query = SyncEvent.query
    if device_id:
        query = query.filter(SyncEvent.device_id == device_id)
    if user_id:
        query = query.filter(SyncEvent.user_id == user_id)
    events = query.order_by(SyncEvent.timestamp.desc()).limit(limit).all()

    # Summarize status
    total = query.count()
    pending = query.filter(SyncEvent.status == 'pending').count()
    synced = query.filter(SyncEvent.status == 'synced').count()
    failed = query.filter(SyncEvent.status == 'failed').count()

    # Serialize events
    def serialize_event(event):
        return {
            'id': event.id,
            'event_type': event.event_type,
            'payload': event.payload,
            'timestamp': event.timestamp.isoformat() if event.timestamp else None,
            'status': event.status,
            'device_id': event.device_id,
            'user_id': event.user_id
        }
    events_json = [serialize_event(e) for e in events]

    return jsonify({
        'summary': {
            'total': total,
            'pending': pending,
            'synced': synced,
            'failed': failed
        },
        'history': events_json
    }), 200

@sync_bp.route('/device/register', methods=['POST'])
def register_device():
    """Endpoint for device registration from frontend."""
    data = request.get_json()
    device_id = data.get('device_id')
    role = data.get('role')
    if not device_id or not role:
        return jsonify({'error': 'Missing device_id or role'}), 400
    # Here you could add logic to store or validate the device
    return jsonify({'status': 'registered', 'device_id': device_id, 'role': role}), 200 