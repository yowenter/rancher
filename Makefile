TARGETS := $(shell ls scripts)

replace_base:
	sed -i "s/{DockerImageBase}/${BASE_IMAGE}/g" Dockerfile.dapper



.dapper: replace_base
ifneq ("$(wildcard $(.dapper))","")
	@echo dapper exsits, download ignore
else
	@echo Downloading dapper
	@curl -sL https://releases.rancher.com/dapper/latest/dapper-`uname -s`-`uname -m` > .dapper.tmp
	@@chmod +x .dapper.tmp
	@./.dapper.tmp -v
	@mv .dapper.tmp .dapper
endif

base:
	docker build -f Dockerfile.base -t ${REPOSITORY}/${BASE_NAMESPACE}/${BASE_IMAGE} .
	docker push ${REPOSITORY}/${BASE_NAMESPACE}/${BASE_IMAGE}


$(TARGETS): .dapper
	./.dapper $@

trash: .dapper
	./.dapper -m bind trash

trash-keep: .dapper
	./.dapper -m bind trash -k

deps: trash

.DEFAULT_GOAL := ci

.PHONY: $(TARGETS)
