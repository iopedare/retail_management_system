from flask_socketio import SocketIO, emit, join_room, leave_room
from flask import request

# SocketIO instance will be initialized in app/__init__.py

"""
This module defines SocketIO event handlers for real-time sync operations.
"""

connected_devices = {}
master_device_id = None

def register_socketio_events(socketio: SocketIO):
    """Register all sync-related SocketIO event handlers."""

    @socketio.on('connect')
    def handle_connect():
        """Handle new device connection."""
        # TODO: Add authentication/registration logic
        emit('connected', {'message': 'Connected to sync server'})

    @socketio.on('disconnect')
    def handle_disconnect():
        """Handle device disconnection."""
        # TODO: Handle cleanup if needed
        print('Client disconnected')

    @socketio.on('critical_event')
    def handle_critical_event(data):
        """Broadcast a critical sync event to all connected clients."""
        # Validate required fields for a critical event
        required_fields = ['event_type', 'payload', 'device_id']
        missing = [f for f in required_fields if f not in data]
        if missing:
            emit('error', {'error': f'Missing fields: {", ".join(missing)}'})
            return
        # Log the event (could also queue in DB if needed)
        print(f"Broadcasting critical event: {data}")
        # Broadcast to all clients
        emit('critical_event', data, broadcast=True)

    @socketio.on('acknowledge')
    def handle_acknowledge(data):
        """Handle client acknowledgement of a critical event (optional, for reliability/audit)."""
        # Log acknowledgement for audit
        print(f"Acknowledgement received: {data}")
        # Optionally, update event status in DB or perform other logic
        emit('acknowledged', {'message': 'Acknowledgement received'})

    @socketio.on('register_device')
    def handle_register_device(data):
        """Register a device and announce its role (master/client)."""
        device_id = data.get('device_id')
        role = data.get('role', 'client')
        if not device_id:
            emit('error', {'error': 'Missing device_id'})
            return
        connected_devices[device_id] = {'sid': request.sid, 'role': role}
        global master_device_id
        if role == 'master':
            master_device_id = device_id
        emit('registered', {'device_id': device_id, 'role': role})

    @socketio.on('heartbeat')
    def handle_heartbeat(data):
        """Handle heartbeat from device to detect master failure."""
        device_id = data.get('device_id')
        # Update last seen timestamp, etc. (for demo, just acknowledge)
        emit('heartbeat_ack', {'device_id': device_id})

    @socketio.on('master_election')
    def handle_master_election(data):
        """Notify all devices of new master after failover."""
        new_master_id = data.get('new_master_id')
        global master_device_id
        master_device_id = new_master_id
        emit('master_elected', {'new_master_id': new_master_id}, broadcast=True) 