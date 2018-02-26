Prerequisites
=============
* kubectl installed
* IDE - any text editor will suffice

Lesson 1 - Setup
=================================
The blog.mvc app will need to be dockerized and pushed to a cloud repo. For this example, I am using Google cloud (GCR & GKE) and my project is referenced as the default value for `GCR` in the `Makefile`. We will deploy an instance of SQL Server and a font end web app (*blogs.mvc*) into GKE (Google Kubernetes Engine).
* Log into [Google Cloud Console](https://console.cloud.google.com)
* Choose `Kubernetes Engine` and create a cluster. __Note: Choose standard machines if deploying SQL Server.__
* `Connect` to the cluster and copy the connection string displayed to the clipboard
* Paste the copied connection string into a console and run it - this will create a kubernetes context - stored by default in `$Home/.kube/config`
* List all contexts `kubectl config get-contexts`
* Choose the context created `kubectl config use-context ...`


Lesson 2 - Building the web app container
=========================================
There are 2 changes to the codebase as created in last [meet-up's workshop](https://github.com/dockerlimerick/meetups-repo/tree/master/meetups/meetup.2018-01-16) 
* The `Dockerfile` has port 80 explicitly exposed.
* The database connection string populated from Envronment variables.
Everything else remains the same.


Lesson 3 - Makefile targets
===========================
The `blog-mvc-image` make target will build the blog.mvc image with the `latest` tag as default.
`make IMAGE_TAG=master-01 blog-mvc-image` will build the image and tag is as `master-01`

The `blog-mvc-push` make target will tag the image and push it to the default cloud repo (GCR in this example).
`make IMAGE_TAG=master-01 blog-mvc-push` will tag the local image as `master-01` and push it to `eu.gcr.io/development-186617/`

The `deploy-blog-prod` make target uses helm to deploy the app config to kubernetes.
`make IMAGE_TAG=master-01 deploy-blog-prod` will schedule kubernetes to deploy the app.

The `deploy-sql-server` make target will deploy an instance of SQL Server and expose it as a ClusterIP on port 1433. It references a `secrets/sql-server.txt` file that contains the SA password. This secret is kept in local file as an example but a real password would most likely be pulled from a secrets vault when required.

The `build-deploy-all` make target combines all the previous functionality into a single command.
`make IMAGE_TAG=master-01 build-deploy-all` will build the container, tag it, push it to GCR and deploy both the SQL Server back end and web app front ends.


Lesson 4 - Helm commands
========================
* helm install ...
* helm upgrade --install ...
* helm delete ... --purge
* helm history ...
* helm rollback ...