# Docker targets
# The Dockerfile is the Home Assistant add-on image: the Supervisor builds it from build.json and
# runs it with bashio, so it cannot run standalone. This target checks that the image builds.

.PHONY: docker-build

IMAGE_NAME = personal-app
BASE_IMAGE ?= ghcr.io/home-assistant/base:latest

docker-build: ## Build the add-on image locally (BASE_IMAGE=... overrides the base image)
	@printf '%b\n' "${CYAN}Building docker image...${NC}" >&2
	@docker build --build-arg BUILD_FROM=$(BASE_IMAGE) -t $(IMAGE_NAME) --progress=plain .
	@printf '%b\n' "${GREEN}docker-build complete${NC}" >&2
