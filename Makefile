IMAGE_TAG     ?= latest
K8S_NAMESPACE ?= $(shell echo $(USER) | sed 's/[.]/-/g')

.PHONY: blog-mvc-image
blog-mvc-image:
	docker build -t blog.mvc:$(IMAGE_TAG) -f blog.mvc/Dockerfile .

.PHONY: deploy-blog-prod
deploy-blog-prod:
	@helm upgrade blog-ui ./helm/blog-mvc \
		--install \
		--namespace $(K8S_NAMESPACE)

.PHONY: deploy-sql-server
deploy-sql-server:
	helm upgrade sql-server ./helm/sql-server \
		--install \
		--namespace $(K8S_NAMESPACE) \
		--set secrets.sa_sql_server="$(shell cat secrets/sql-server.txt)"
