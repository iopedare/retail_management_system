# Retail Management System – Backend

This is the backend service for the Retail Management System, built with Flask and Flask-SocketIO. It provides REST and WebSocket APIs, handles business logic, and manages data storage and synchronization for offline-first retail operations.

## Features
- User authentication and role management
- Inventory and batch tracking
- POS and order processing
- Real-time sync and offline support
- Reporting and analytics

## Project Structure
- `app/` – Main application code (models, routes, services, utils, config)
- `tests/` – Unit and integration tests
- `requirements.txt` – Python dependencies
- `.gitignore` – Git ignore rules
- `README.md` – Project documentation
- `run.py` – Application entry point

## Setup
1. Create and activate a Python virtual environment:
   ```bash
   python -m venv venv
   source venv/Scripts/activate  # On Windows
   # or
   source venv/bin/activate      # On macOS/Linux
   ```
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Run the backend server:
   ```bash
   python run.py
   ```

## Documentation & References
- [Business Logic](../docs/business_logic.md)
- [Implementation Plan](../docs/implementation_plan.md)
- [Project Workflow](../docs/workflow.md)
- [Project Rules](../docs/PROJECT_RULES.md)
- [Project Checklist](../docs/PROJECT_CHECKLIST.md)

## API Reference
- See `API_REFERENCE.md` (to be created) for details on REST and WebSocket endpoints, parameters, and examples.

## Architecture
- See `ARCHITECTURE.md` (to be created) for backend architecture, master-client sync, and data flow.

---

For more details, see the main project documentation and PRD.
