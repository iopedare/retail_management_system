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

---

For more details, see the main project documentation and PRD.
