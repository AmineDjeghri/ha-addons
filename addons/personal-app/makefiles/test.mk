N ?= 4

.PHONY: check test-local test-all test-unit test-installation

check: ## Run static checks, comprehensive software validation and strict docs
	@$(MAKE) pre-commit-status
	@$(MAKE) pre-commit
	@$(MAKE) test-all
	@$(MAKE) docs-build

test-local: test-unit ## Run all self-contained software tests

test-all: ## Run the unit tests and the built-wheel smoke (no integration tests exist yet)
	$(if $(strip $(ARGS)),$(error test-all requires the full suite; use a focused target for ARGS))
	@$(MAKE) test-local
	@$(MAKE) test-installation

test-unit: ## Run unit tests with pytest (N=4 workers; empty selection fails)
	@$(UV) run pytest tests/unit --numprocesses=$(N) $(ARGS)

test-installation: build-package ## Install the built wheels in a throwaway env and import both packages
	@backend=$$(ls -t dist/personal_app_backend-*.whl | head -1); \
	frontend=$$(ls -t dist/personal_app_frontend-*.whl | head -1); \
	$(UV) run --isolated --no-project --with "$$backend" --with "$$frontend" python -c \
		"import personal_app_backend.backend_settings, personal_app_frontend.frontend_settings; print('OK personal_app_backend, personal_app_frontend')"
