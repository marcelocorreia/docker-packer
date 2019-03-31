NAME := packer
NAMESPACE := marcelocorreia
VERSION := $(shell cat version)
SOURCE_GITHUB_USER := hashicorp
GITHUB_USER := marcelocorreia

ifdef GITHUB_TOKEN
TOKEN_FLAG := -H "Authorization: token $(GITHUB_TOKEN)"
endif

build: _update-version
	docker build -t $(NAMESPACE)/$(NAME) .
	docker build -t $(NAMESPACE)/$(NAME):$(VERSION) .
.PHONY: build

push:
	docker push $(NAMESPACE)/$(NAME)
	docker push $(NAMESPACE)/$(NAME):$(VERSION)

release:
	github-release release -u $(GITHUB_USER) -r $(REPO_NAME) --tag $(VERSION) --name $(VERSION)
	$(make) build push

_get-last-release:
	@$(eval export OUT=$(shell curl -s $(TOKEN_FLAG) https://api.github.com/repos/$(SOURCE_GITHUB_USER)/$(NAME)/tags | jq ".[]|.name" | head -n1 | sed 's/\"//g' | sed 's/v*//g'))
	@echo $(OUT)
	@echo $(OUT) > version



_update-version:
	cat Dockerfile | sed  's/ARG $(NAME)_version=".*"/ARG $(NAME)_version="$(VERSION)"/' > /tmp/Dockerfile.tmp
	cat /tmp/Dockerfile.tmp > Dockerfile
	rm /tmp/Dockerfile.tmp


_git-push:
	git add .; git commit -m "Image Version $(VERSION)"; git push

