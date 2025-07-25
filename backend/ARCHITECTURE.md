# Architecture – Retail Management System Backend

This document provides an overview of the backend architecture, including system components, master-client sync logic, and data flow.

---

## High-Level Architecture
- Flask + Flask-SocketIO backend
- Modular structure: app (models, routes, services, utils), tests, requirements
- SQLite for local storage (offline-first)
- REST and WebSocket APIs

## Master-Client Sync Logic
- Each device maintains its own SQLite DB
- Master node aggregates and broadcasts updates
- Devices sync with master when network is available
- Conflict resolution: last-writer-wins or master priority

## Key Modules
- Models: ORM/database models
- Routes: REST API endpoints
- Services: Business logic and sync
- Utils: Utility functions

## Data Flow Overview
1. Client sends request (REST/WebSocket)
2. Backend processes request, updates DB
3. Sync queue updated for offline/online
4. Master node broadcasts updates as needed

---

*Update this file as the architecture evolves or new modules are added.* 