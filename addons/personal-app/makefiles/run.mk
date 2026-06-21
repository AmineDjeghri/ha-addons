# Run targets
# This file contains targets for running the application

.PHONY: run-frontend run-backend run-frontend-backend run-app pre-commit-install pre-commit

run-frontend: ## Run the frontend (NiceGUI)
	@echo "${YELLOW}Running frontend...${NC}"
	$(UV) run --project frontend frontend/src/personal_app_frontend/main.py

run-backend: ## Run the backend (FastAPI)
	@echo "${YELLOW}Running backend...${NC}"
	$(UV) run --no-sync --project backend backend/src/personal_app_backend/app.py

run-app: ## Run the full application (frontend + backend)
	make run-frontend run-backend -j2
