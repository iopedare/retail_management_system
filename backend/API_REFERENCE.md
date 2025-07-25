# API Reference – Retail Management System Backend

This document describes the REST and WebSocket API endpoints provided by the backend service.

---

## REST API Endpoints

| Method | Path         | Description                | Parameters         | Auth Required | Example Request/Response |
|--------|--------------|----------------------------|--------------------|---------------|-------------------------|
| GET    | /api/ping    | Health check               | None               | No            | ...                     |
| POST   | /api/login   | User login                 | username, password | No            | ...                     |
| ...    | ...          | ...                        | ...                | ...           | ...                     |

<!-- Add more endpoints as implemented -->

---

## WebSocket API Endpoints

| Event Name      | Description                | Payload/Parameters | Auth Required | Example Payload |
|-----------------|----------------------------|--------------------|---------------|----------------|
| connect         | Establish connection       | None               | Yes           | ...            |
| sync_update     | Sync data update           | data, timestamp    | Yes           | ...            |
| ...             | ...                        | ...                | ...           | ...            |

<!-- Add more events as implemented -->

---

*Update this file as new endpoints and events are added to the backend.* 