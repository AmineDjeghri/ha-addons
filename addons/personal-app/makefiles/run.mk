# Run targets
# This file contains targets for running the application

.PHONY: run-frontend run-backend run-frontend-backend run

run-frontend: ## Run the frontend (NiceGUI)
	@printf '%b\n' "${CYAN}Running frontend...${NC}" >&2
	@$(UV) run --no-sync --project frontend frontend/src/personal_app_frontend/main.py
	@printf '%b\n' "${GREEN}run-frontend complete${NC}" >&2

run-backend: ## Run the backend (FastAPI)
	@printf '%b\n' "${CYAN}Running backend...${NC}" >&2
	@$(UV) run --no-sync --project backend backend/src/personal_app_backend/app.py
	@printf '%b\n' "${GREEN}run-backend complete${NC}" >&2

run-frontend-backend: ## Run frontend and backend together
	@printf '%b\n' "${CYAN}=========> run-frontend-backend...${NC}" >&2
	@$(MAKE) run-frontend run-backend -j2
	@printf '%b\n' "${GREEN}run-frontend-backend complete${NC}" >&2

run: run-frontend-backend ## Run backend and frontend (http://localhost:8080)
