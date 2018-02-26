IMAGE_TAG     ?= latest
GCR 			  ?= eu.gcr.io/development-186617
K8S_NAMESPACE ?= $(shell echo $(USER) | sed 's/[.]/-/g')

.PHONY: blog-mvc-image
blog-mvc-image:
	@docker build -t blog.mvc:$(IMAGE_TAG) -f blog.mvc/Dockerfile .

.PHONY: blog-mvc-push
blog-mvc-push:
	@docker tag blog.mvc:$(IMAGE_TAG) $(GCR)/blog.mvc:$(IMAGE_TAG)
	@gcloud docker -- push $(GCR)/blog.mvc:$(IMAGE_TAG)

.PHONY: deploy-blog-prod
deploy-blog-prod:
	@helm upgrade blog-ui ./helm/blog-mvc \
		--install \
		--namespace $(K8S_NAMESPACE) \
		--set blog.imageTag=$(IMAGE_TAG)

.PHONY: deploy-sql-server
deploy-sql-server:
	@helm upgrade sql-server ./helm/sql-server \
		--install \
		--namespace $(K8S_NAMESPACE) \
		--set secrets.sa_sql_server="$(shell cat secrets/sql-server.txt)"

.PHONY: build-deploy-all
build-deploy-all: deploy-sql-server blog-mvc-image blog-mvc-push deploy-blog-prod
