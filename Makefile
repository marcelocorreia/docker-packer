REPOSITORY=packer
CONTAINER=packer
NAMESPACE=marcelocorreia
VERSION=$(shell cat version)
SOURCE_GITHUB_USER := hashicorp
GITHUB_USER := marcelocorreia

ifdef GITHUB_TOKEN
TOKEN_FLAG := -H "Authorization: token $(GITHUB_TOKEN)"
endif

build: _update-version
	docker build -t $(NAMESPACE)/$(CONTAINER) .
	docker build -t $(NAMESPACE)/$(CONTAINER):$(VERSION) .
.PHONY: build

push:
	docker push $(NAMESPACE)/$(CONTAINER)
	docker push $(NAMESPACE)/$(CONTAINER):$(VERSION)

release:
	github-release release -u $(GITHUB_USER) -r $(REPO_NAME) --tag $(VERSION) --name $(VERSION)

_get-last-release:
	@OUT=$(shell curl -s $(TOKEN_FLAG) https://api.github.com/repos/$(SOURCE_GITHUB_USER)/$(CONTAINER)/tags | jq ".[]|.name" | head -n1 | sed 's/\"//g' | sed 's/v*//g') && \
	echo $${OUT}

_check-new-version:
	@LAST=$(shell make _get-last-release) && \
	 if [ $(VERSION) != $$LAST ];then \
	 	printf "Updating $(CONTAINER) :: $(VERSION) -> $$LAST"; \
		echo "$$LAST" > version; \
		$(MAKE) _update-version; \
	else \
	 	printf "Container $(CONTAINER) already up to date - Version: $(VERSION)"; \
	fi

_update-version: _check-new-version
	cat Dockerfile | sed  's/ARG packer_version=".*"/ARG packer_version="$(VERSION)"/' > /tmp/Dockerfile.tmp
	cat /tmp/Dockerfile.tmp > Dockerfile
	rm /tmp/Dockerfile.tmp


_git-push:
	git add .; git commit -m "Image Version $(VERSION)"; git push

