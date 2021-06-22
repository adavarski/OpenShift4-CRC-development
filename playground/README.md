
Ref: [OpenShift Cheatsheet](https://github.com/adavarski/OpenShift4-CRC-development/blob/main/playground/README-openshift-cheatsheet.md)

## Demo1: Using oc apply and DockerHub images

### Create new project (OPTIONAL)
```
$ oc new-project h2o
```
We will use "default" project for this demo.
```
$ oc project default
```
### Deploy H2O cluster
```
$ oc apply -f ./h2o-jupyter/k8s/h2o/40-h2o-statefulset.yaml  -f ./h2o-jupyterk8s/h2o/50-h2o-headless-service.yaml
```

### Jupyter environment

Build custom JupyterLab docker image and pushing it into DockerHub container registry.
```
$ cd ./h2o-jupyter/jupyterlab-docker
$ docker build -t jupyterlab-h2o .
$ docker tag jupyterlab-h2o:latest davarski/jupyterlab-h2o:latest
$ docker login 
$ docker push davarski/jupyterlab-h2o:latest

```
Run Jupyter Notebook inside k8s as pod:
```
$ oc apply -f ./h2o-jupyterk8s/k8s/jupyter/jupyter-notebook.pod.yaml -f ./h2o-jupyterk8s/k8s/jupyter/jupyter-notebook.svc.yaml

```
Check pods:
```
$ oc get po
NAME                 READY   STATUS    RESTARTS   AGE
h2o-stateful-set-0   1/1     Running   0          7m9s
h2o-stateful-set-1   0/1     Running   0          7m9s
h2o-stateful-set-2   0/1     Pending   0          7m9s
jupyter-notebook     1/1     Running   0          59m
```
Once the Pod is running, copy the generated token from the pod output logs.
```
$ oc logs jupyter-notebook
[I 15:18:56.720 LabApp] Writing notebook server cookie secret to /home/jovyan/.local/share/jupyter/runtime/notebook_cookie_secret
[I 15:19:20.084 LabApp] JupyterLab extension loaded from /opt/conda/lib/python3.7/site-packages/jupyterlab
[I 15:19:20.084 LabApp] JupyterLab application directory is /opt/conda/share/jupyter/lab
[W 15:19:24.906 LabApp] JupyterLab server extension not enabled, manually loading...
[I 15:19:24.938 LabApp] JupyterLab extension loaded from /opt/conda/lib/python3.7/site-packages/jupyterlab
[I 15:19:24.938 LabApp] JupyterLab application directory is /opt/conda/share/jupyter/lab
[I 15:19:24.940 LabApp] Serving notebooks from local directory: /home/jovyan
[I 15:19:24.940 LabApp] The Jupyter Notebook is running at:
[I 15:19:24.940 LabApp] http://(jupyter-notebook or 127.0.0.1):8888/?token=9e4fdbe311669a5be13da45ad7d2d6d40ececaf5f81c96e6
[I 15:19:24.940 LabApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[C 15:19:24.986 LabApp] 
    
    To access the notebook, open this file in a browser:
        file:///home/jovyan/.local/share/jupyter/runtime/nbserver-1-open.html
    Or copy and paste one of these URLs:
        http://(jupyter-notebook or 127.0.0.1):8888/?token=9e4fdbe311669a5be13da45ad7d2d6d40ececaf5f81c96e6
```
```
oc expose svc/jupyter-notebook
$ oc get route
NAME               HOST/PORT                                   PATH   SERVICES           PORT       TERMINATION   WILDCARD
jupyter-notebook   jupyter-notebook-default.apps-crc.testing          jupyter-notebook   8888                     None
$ nc -z -v jupyter-notebook-default.apps-crc.testing 80
```
Note: Jupyter Notebooks are a browser-based (or web-based) IDE (integrated development environments)

Browser: http://jupyter-notebook-default.apps-crc.testing (use generated token from the pod output logs) or http://jupyter-notebook-default.apps-crc.testing/?token=9e4fdbe311669a5be13da45ad7d2d6d40ececaf5f81c96e6

### Example H2O AutoML jupyter notebooks:

- AutoML example: https://github.com/adavarski/OpenShift4-CRC-development/blob/main/playground/h2o-jupyter/notebooks/h2o-automl.ipynb 


- [Coursera-examples](https://github.com/adavarski/OpenShift4-CRC-development/tree/main/playground/h2o-jupyter/notebooks/Coursera-examples)

Clean: 

```
$ oc delete route jupyter-notebook
$ oc apply -f ./h2o-jupyter/k8s/h2o/40-h2o-statefulset.yaml  -f ./h2o-jupyter/k8s/h2o/50-h2o-headless-service.yaml
$ oc delete -f ./h2o-jupyter/k8s/jupyter/jupyter-notebook.pod.yaml -f ./h2o-jupyter/k8s/jupyter/jupyter-notebook.svc.yaml

### oc delete project h2o (if using h2o project)
```

## Demo2: Using DockerHub image and OpenShift(CRC) internal docker registry

Setup docker:

Run [script](https://github.com/adavarski/OpenShift4-CRC-ubuntu/blob/main/utils/docker-install.sh) to install docker 
```
$ ../utils/docker-install.sh
```
Note: You can install podman if you want to use it instead of docker. For this playground we will use docker.


Setup host docker registry:

```
$ cat /etc/docker/daemon.json
{
  "insecure-registries" : ["default-route-openshift-image-registry.apps-crc.testing"]
}

$ docker login -u kubeadmin -p $(oc whoami -t) default-route-openshift-image-registry.apps-crc.testing 
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /home/davar/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

$ oc new-project demo
$ docker pull quay.io/libpod/alpine
Using default tag: latest
latest: Pulling from libpod/alpine
9d16cba9fb96: Pull complete 
Digest: sha256:fa93b01658e3a5a1686dc3ae55f170d8de487006fb53a28efcd12ab0710a2e5f
Status: Downloaded newer image for quay.io/libpod/alpine:latest
quay.io/libpod/alpine:latest
$ docker images
REPOSITORY              TAG       IMAGE ID       CREATED         SIZE
quay.io/libpod/alpine   latest    961769676411   20 months ago   5.58MB
$ docker tag quay.io/libpod/alpine:latest default-route-openshift-image-registry.apps-crc.testing/demo/alpine:latest
$ docker push default-route-openshift-image-registry.apps-crc.testing/demo/alpine:latest 
The push refers to repository [default-route-openshift-image-registry.apps-crc.testing/demo/alpine]
03901b4a2ea8: Pushed 
latest: digest: sha256:acd3ca9941a85e8ed16515bfc5328e4e2f8c128caa72959a58a127b7801ee01f size: 528

### Get imagestreams and verify that the pushed image is listed:
$ oc get is
NAME     IMAGE REPOSITORY                                                      TAGS     UPDATED
alpine   default-route-openshift-image-registry.apps-crc.testing/demo/alpine   latest   47 seconds ago

### Enable image lookup in the imagestream:
$ oc set image-lookup alpine

$ oc run demo --image=alpine --command -- sleep 600s
pod/demo created
$ oc get po
NAME   READY   STATUS    RESTARTS   AGE
demo   1/1     Running   0          16s
```
### Demo3: Using DockerHub Bitnami’s non-ROOT images/containers OpenShift(CRC) example
Ref: https://github.com/bitnami/bitnami-docker-nginx
```
$ oc project default
Now using project "default" on server "https://api.crc.testing:6443".

$ oc new-app --name=nginx --docker-image=bitnami/nginx
--> Found container image 0c7eb3e (22 hours old) from Docker Hub for "bitnami/nginx"

    * An image stream tag will be created as "nginx:latest" that will track this image

--> Creating resources ...
    imagestream.image.openshift.io "nginx" created
    deployment.apps "nginx" created
    service "nginx" created
--> Success
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose service/nginx' 
    Run 'oc status' to view your app.
$ oc get po
NAME                     READY   STATUS    RESTARTS   AGE
nginx-7b69f4f588-w24jd   1/1     Running   0          18h

$ oc logs nginx-7b69f4f588-w24jd
nginx 16:43:32.05 
nginx 16:43:32.06 Welcome to the Bitnami nginx container
nginx 16:43:32.06 Subscribe to project updates by watching https://github.com/bitnami/bitnami-docker-nginx
nginx 16:43:32.06 Submit issues and feature requests at https://github.com/bitnami/bitnami-docker-nginx/issues
nginx 16:43:32.06 
nginx 16:43:32.07 INFO  ==> ** Starting NGINX setup **
nginx 16:43:32.08 INFO  ==> Validating settings in NGINX_* env vars
nginx 16:43:32.10 INFO  ==> Initializing NGINX

nginx 16:43:32.11 INFO  ==> ** NGINX setup finished! **
nginx 16:43:32.13 INFO  ==> ** Starting NGINX **

### Tiny issue is that the new-app wrapper automatically created a service with a targetPort of 80, when our container exposes on 8080. 

$ oc get svc
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP                            PORT(S)             AGE
kubernetes   ClusterIP      10.217.4.1    <none>                                 443/TCP             16d
nginx        ClusterIP      10.217.4.86   <none>                                 8080/TCP,8443/TCP   4m57s
openshift    ExternalName   <none>        kubernetes.default.svc.cluster.local   <none>              16d


### So you have to edit the service to change that.
oc edit svc nginx


# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
kind: Service
metadata:
  annotations:
    openshift.io/generated-by: OpenShiftNewApp
  creationTimestamp: "2021-04-24T16:42:10Z"
  labels:
    app: nginx
    app.kubernetes.io/component: nginx
    app.kubernetes.io/instance: nginx
  name: nginx
  namespace: default
  resourceVersion: "114506"
  selfLink: /api/v1/namespaces/default/services/nginx
  uid: b1931bd8-ebcb-4478-a07a-2331112ae804
spec:
  clusterIP: 10.217.4.86
  clusterIPs:
  - 10.217.4.86
  ports:
  - name: 8080-tcp
    port: 80
    protocol: TCP
    targetPort: 8080
  - name: 8443-tcp
    port: 443
    protocol: TCP
    targetPort: 8443
  selector:
    deployment: nginx
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}

$ oc get svc
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP                            PORT(S)          AGE
kubernetes   ClusterIP      10.217.4.1    <none>                                 443/TCP          16d
nginx        ClusterIP      10.217.4.86   <none>                                 80/TCP,443/TCP   6m41s
openshift    ExternalName   <none>        kubernetes.default.svc.cluster.local   <none>           16d

$ oc expose svc/nginx
$ oc status
In project default on server https://api.crc.testing:6443

svc/openshift - kubernetes.default.svc.cluster.local
svc/kubernetes - 10.217.4.1:443 -> 6443

http://nginx-default.apps-crc.testing to pod port 8080-tcp (svc/nginx)
  deployment/nginx deploys istag/nginx:latest 
    deployment #1 running for 18 hours - 1 pod


1 info identified, use 'oc status --suggest' to see details.
davar@devops:~/OPENSHIFT$ oc get route
NAME    HOST/PORT                        PATH   SERVICES   PORT       TERMINATION   WILDCARD
nginx   nginx-default.apps-crc.testing          nginx      8080-tcp                 None
```

### Demo4: Examples applications from GitHub repositories (using source code/odo)

Creating new apps
You can create a new OpenShift application using the web console or by running the oc new-app command from the CLI. With the OpenShift CLI there are four ways to create a new application, by specifying either:

- DockerHub images
- source code (with oc new-app and odo)
- OpenShift templates


Setup access to registry.redhat.io ( Ref: https://access.redhat.com/RegistryAuthentication )

```
$ docker login registry.redhat.io (using previous RH account used for CRC download)

$ cat /etc/docker/daemon.json
{
  "insecure-registries" : ["default-route-openshift-image-registry.apps-crc.testing"]
}

$ docker login -u kubeadmin -p $(oc whoami -t) default-route-openshift-image-registry.apps-crc.testing 
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /home/davar/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

$ cat $HOME/.docker/config.json
{
	"auths": {
		"default-route-openshift-image-registry.apps-crc.testing": {
			"auth": "a3ViZWFkbWluOnNoYTI1Nn4xbGZtZWxYY2FpeC11emJUY0tTTzlkNXFjSWlMWEhMS05aTnhfNEdYSGsw"
		},
		"registry.redhat.io": {
			"auth": "YWRhdmFyc2tpOktyMGswZGlsIQ=="
		}
	}
}

$ oc create secret generic redhat.registry.pull \
    --from-file=.dockerconfigjson=/home/davar/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson
secret/redhat.registry.pull created

$ oc secrets link default redhat.registry.pull --for=pull
$ oc secrets link builder redhat.registry.pull

### If the imagestreamsecret is not present in openshift namespace, create it using:
$ oc create secret generic imagestreamsecret --from-file=.dockerconfigjson=/home/davar/.docker/config.json --type=kubernetes.io/dockerconfigjson -n openshift
secret/imagestreamsecret created

$ oc get secrets
NAME                       TYPE                                  DATA   AGE
builder-dockercfg-jfpvl    kubernetes.io/dockercfg               1      16d
builder-token-fkk5b        kubernetes.io/service-account-token   4      16d
builder-token-lbcsn        kubernetes.io/service-account-token   4      16d
default-dockercfg-d442b    kubernetes.io/dockercfg               1      16d
default-token-c7fm7        kubernetes.io/service-account-token   4      16d
default-token-xgtx7        kubernetes.io/service-account-token   4      16d
deployer-dockercfg-jfgc9   kubernetes.io/dockercfg               1      16d
deployer-token-9tmnn       kubernetes.io/service-account-token   4      16d
deployer-token-dmg9q       kubernetes.io/service-account-token   4      16d
redhat.registry.pull       kubernetes.io/dockerconfigjson        1      33m
```
OpenShift Do (`odo`) is a fast and easy-to-use CLI tool for creating applications on OpenShift Container Platform. `odo` allows developers to concentrate on creating applications without the need to administrate an OpenShift Container Platform cluster itself. Creating deployment configurations, build configurations, service routes and other OpenShift Container Platform elements are all automated by odo.

Existing tools such as `oc` are more operations-focused and require a deep understanding of Kubernetes and OpenShift Container Platform concepts. `odo` abstracts away complex Kubernetes and OpenShift Container Platform concepts allowing developers to focus on what is most important to them: code.
```
### odo install: 

$ sudo curl -L https://mirror.openshift.com/pub/openshift-v4/clients/odo/latest/odo-linux-amd64 -o /usr/local/bin/odo
$ sudo chmod +x /usr/local/bin/odo
$ odo catalog list components
Odo Devfile Components:
NAME                          DESCRIPTION                                                         REGISTRY
java-maven                    Upstream Maven and OpenJDK 11                                       DefaultDevfileRegistry
java-openliberty              Open Liberty microservice in Java                                   DefaultDevfileRegistry
java-quarkus                  Upstream Quarkus with Java+GraalVM                                  DefaultDevfileRegistry
java-springboot               Spring Boot® using Java                                             DefaultDevfileRegistry
java-vertx                    Upstream Vert.x using Java                                          DefaultDevfileRegistry
java-wildfly                  Upstream WildFly                                                    DefaultDevfileRegistry
java-wildfly-bootable-jar     Java stack with WildFly in bootable Jar mode, OpenJDK 11 and...     DefaultDevfileRegistry
nodejs                        Stack with NodeJS 12                                                DefaultDevfileRegistry
python                        Python Stack with Python 3.7                                        DefaultDevfileRegistry
python-django                 Python3.7 with Django                                               DefaultDevfileRegistry

Odo S2I Components:
NAME       PROJECT       TAGS                                                             SUPPORTED
java       openshift     latest,openjdk-11-el7,openjdk-11-ubi8,openjdk-8-el7              YES
nodejs     openshift     12-ubi8,14-ubi8,latest                                           YES
dotnet     openshift     2.1-el7,2.1-ubi8,3.1-el7,3.1-ubi8                                NO
golang     openshift     1.13.4-ubi7,1.14.7-ubi8,latest                                   NO
httpd      openshift     2.4-el7,2.4-el8,latest                                           NO
java       openshift     openjdk-8-ubi8                                                   NO
nginx      openshift     1.14-el8,1.16-el7,1.16-el8,1.18-ubi7,1.18-ubi8,latest            NO
nodejs     openshift     10-ubi7,10-ubi8,12-ubi7,14-ubi7                                  NO
perl       openshift     5.26-el7,5.26-ubi8,5.30-el7,5.30-ubi8,latest                     NO
php        openshift     7.2-ubi8,7.3-ubi7,7.3-ubi8,7.4-ubi8,latest                       NO
python     openshift     2.7-ubi7,2.7-ubi8,3.6-ubi8,3.8-ubi7,3.8-ubi8,latest              NO
ruby       openshift     2.5-ubi7,2.5-ubi8,2.6-ubi7,2.6-ubi8,2.7-ubi7,2.7-ubi8,latest     NO
```


Creating new apps using source code (oc new-app and odo).

#### python

##### python github source
```
$ oc new-app centos/python-35-centos7~https://github.com/sclorg/django-ex
$ oc logs -f buildconfig/django-ex

$ oc status
In project default on server https://api.crc.testing:6443

svc/django-ex - 10.217.5.98:8080
  deployment/django-ex deploys istag/django-ex:latest <-
    bc/django-ex source builds https://github.com/sclorg/django-ex on istag/python-35-centos7:latest 
    deployment #2 running for 4 minutes - 1 pod
    deployment #1 deployed 8 minutes ago

svc/openshift - kubernetes.default.svc.cluster.local
svc/kubernetes - 10.217.4.1:443 -> 6443

http://nginx-default.apps-crc.testing to pod port 8080-tcp (svc/nginx)
  deployment/nginx deploys istag/nginx:latest 
    deployment #1 running for 5 hours - 1 pod

$ oc get po
NAME                         READY   STATUS      RESTARTS   AGE
django-ex-1-build            0/1     Completed   0          9m2s
django-ex-6d84858568-lh5wz   1/1     Running     0          4m50s
nginx-7b69f4f588-w24jd       1/1     Running     0          4h40m
$ oc get svc
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP                            PORT(S)          AGE
django-ex    ClusterIP      10.217.5.98   <none>                                 8080/TCP         9m20s
kubernetes   ClusterIP      10.217.4.1    <none>                                 443/TCP          16d
nginx        ClusterIP      10.217.4.86   <none>                                 80/TCP,443/TCP   4h41m
openshift    ExternalName   <none>        kubernetes.default.svc.cluster.local   <none>           16d
$ oc get routes
NAME    HOST/PORT                        PATH   SERVICES   PORT       TERMINATION   WILDCARD
nginx   nginx-default.apps-crc.testing          nginx      8080-tcp                 None
$ oc expose service/django-ex
route.route.openshift.io/django-ex exposed
$ oc get routes
NAME        HOST/PORT                            PATH   SERVICES    PORT       TERMINATION   WILDCARD
django-ex   django-ex-default.apps-crc.testing          django-ex   8080-tcp                 None
nginx       nginx-default.apps-crc.testing              nginx       8080-tcp                 None
$ oc get routes
NAME        HOST/PORT                            PATH   SERVICES    PORT       TERMINATION   WILDCARD
django-ex   django-ex-default.apps-crc.testing          django-ex   8080-tcp                 None
nginx       nginx-default.apps-crc.testing              nginx       8080-tcp                 None

### Clean
$ oc delete all -l app=django-ex
service "django-ex" deleted
deployment.apps "django-ex" deleted
buildconfig.build.openshift.io "django-ex" deleted
build.build.openshift.io "django-ex-1" deleted
imagestream.image.openshift.io "django-ex" deleted
imagestream.image.openshift.io "python-35-centos7" deleted
route.route.openshift.io "django-ex" deleted
```
##### python github source (odo)
```
$ mkdir python-app-odo; cd python-app-odo
$ odo create python --s2i --git https://github.com/openshift/django-ex.git
Validation
Validation
Warning: python is not fully supported by odo, and it is not guaranteed to work
 ✓  Validating component [12ms]

Please use `odo push` command to create the component with source deployed
$ cat .odo/config.yaml 
kind: LocalConfig
apiversion: odo.dev/v1alpha1
ComponentSettings:
  Type: python
  SourceLocation: https://github.com/openshift/django-ex.git
  SourceType: git
  Ports:
  - 8080/TCP
  Application: app
  Project: default
  Name: python-bhcf

$ odo push
Validation
 ✓  Checking component [19ms]

Configuration changes
 ✓  Initializing component
 ✓  Creating component [873ms]
 ✓  Triggering build from git [322ms]
 ✓  Waiting for build to finish [4m]
 ✓  Deploying component python-bhcf [1m]

Applying URL changes
 ✓  URLs are synced with the cluster, no changes are required.

Pushing to component python-bhcf of type git
 ✓  Changes successfully pushed to component

$ odo list
S2I Components: 
APP     NAME            PROJECT     TYPE       SOURCETYPE     STATE
app     python-bhcf     default     python     git            Pushed
$ oc get po
NAME                       READY   STATUS      RESTARTS   AGE
nginx-7b69f4f588-w24jd     1/1     Running     0          19h
python-bhcf-app-1-build    0/1     Completed   0          8m10s
python-bhcf-app-1-deploy   0/1     Completed   0          4m23s
python-bhcf-app-1-qsh6h    1/1     Running     0          4m4s
$ oc get svc
NAME              TYPE           CLUSTER-IP     EXTERNAL-IP                            PORT(S)          AGE
kubernetes        ClusterIP      10.217.4.1     <none>                                 443/TCP          17d
nginx             ClusterIP      10.217.4.86    <none>                                 80/TCP,443/TCP   19h
openshift         ExternalName   <none>         kubernetes.default.svc.cluster.local   <none>           17d
python-bhcf-app   ClusterIP      10.217.5.204   <none>                                 8080/TCP         9m57s
$ oc expose service/python-bhcf-app
route.route.openshift.io/python-bhcf-app exposed
$ oc get routes
NAME              HOST/PORT                                  PATH   SERVICES          PORT       TERMINATION   WILDCARD
nginx             nginx-default.apps-crc.testing                    nginx             8080-tcp                 None
python-bhcf-app   python-bhcf-app-default.apps-crc.testing          python-bhcf-app   8080-tcp                 None

### Clean 
$ odo delete python-bhcf
This component has following urls that will be deleted with component
URL named  with host python-bhcf-app-default.apps-crc.testing having protocol http at port 0
? Are you sure you want to delete python-bhcf from app? Yes
 ✓  Deleting component python-bhcf [210ms]
 ✓  Component python-bhcf from application app has been deleted
$ oc get po
NAME                     READY   STATUS    RESTARTS   AGE
nginx-7b69f4f588-w24jd   1/1     Running   0          19h
$ oc get routes
NAME              HOST/PORT                                  PATH   SERVICES          PORT       TERMINATION   WILDCARD
nginx             nginx-default.apps-crc.testing                    nginx             8080-tcp                 None
python-bhcf-app   python-bhcf-app-default.apps-crc.testing          python-bhcf-app   8080-tcp                 None
$ oc delete route python-bhcf-app
route.route.openshift.io "python-bhcf-app" deleted
$ oc get routes
NAME    HOST/PORT                        PATH   SERVICES   PORT       TERMINATION   WILDCARD
nginx   nginx-default.apps-crc.testing          nginx      8080-tcp                 None
```
#### nodejs
```
$ oc new-app nodejs~https://github.com/openshift/nodejs-ex.git
$ oc new-app https://github.com/sclorg/nodejs-ex -l name=myapp
$ odo create nodejs --s2i --git https://github.com/openshift/nodejs-ex.git
```
#### java
```
$ oc new-app https://github.com/spring-projects/spring-petclinic.git
$ odo create java --s2i --git https://github.com/spring-projects/spring-petclinic.git
```
#### php
```
$ oc new-app https://github.com/sclorg/cakephp-ex
$ odo create php --s2i --git https://github.com/openshift/cakephp-ex.git

### Example:
$ oc new-app https://github.com/sclorg/cakephp-ex
...
Successfully pushed image-registry.openshift-image-registry.svc:5000/default/cakephp-ex@sha256:764fdb47694a8831d97bfcea95ebb38da778210fed34c26abb8b332a8d603460
Push successful
$ oc get po
NAME                          READY   STATUS      RESTARTS   AGE
cakephp-ex-1-build            0/1     Completed   0          8m16s
cakephp-ex-5f4889b7bc-52hk4   1/1     Running     0          3m49s
nginx-7b69f4f588-w24jd        1/1     Running     0          14h

#### Clean 
$ oc delete all -l app=cakephp-ex
service "cakephp-ex" deleted
deployment.apps "cakephp-ex" deleted
buildconfig.build.openshift.io "cakephp-ex" deleted
build.build.openshift.io "cakephp-ex-1" deleted
imagestream.image.openshift.io "cakephp-ex" deleted
```

### Demo5: Get started with Jenkins CI/CD in RedHat Openshift 4
```
oc version 
Client Version: 4.x.x
Server Version: 4.x.x
Kubernetes Version: v1.xx.x

```

#### Create project pipelineproject

```
oc new-project pipelineproject

```

#### Search for Jenkins template
```
oc get templates -n openshift | grep jenkins 
jenkins-ephemeral                               Jenkins service, without persistent storage....                                    8 (all set)       6
jenkins-ephemeral-monitored                     Jenkins service, without persistent storage....                                    9 (all set)       7
jenkins-persistent                              Jenkins service, with persistent storage....                                       10 (all set)      7
jenkins-persistent-monitored                    Jenkins service, with persistent storage....                                       11 (all set)      8

```

#### View template

```
oc get template/jenkins-ephemeral -o json -n openshift

```

#### Process all parameters for a given openshift template 

```
oc process --parameters  -n openshift  jenkins-ephemeral # jenkins-persistent
NAME                              DESCRIPTION                                                                                                                                                                                                           GENERATOR           VALUE
JENKINS_SERVICE_NAME              The name of the OpenShift Service exposed for the Jenkins container.                                                                                                                                                                      jenkins
JNLP_SERVICE_NAME                 The name of the service used for master/slave communication.                                                                                                                                                                              jenkins-jnlp
ENABLE_OAUTH                      Whether to enable OAuth OpenShift integration. If false, the static account 'admin' will be initialized with the password 'password'.                                                                                                     true
MEMORY_LIMIT                      Maximum amount of memory the container can use.                                                                                                                                                                                           1Gi
NAMESPACE                         The OpenShift Namespace where the Jenkins ImageStream resides.                                                                                                                                                                            openshift
DISABLE_ADMINISTRATIVE_MONITORS   Whether to perform memory intensive, possibly slow, synchronization with the Jenkins Update Center on start.  If true, the Jenkins core update monitor and site warnings monitor are disabled.                                            false
JENKINS_IMAGE_STREAM_TAG          Name of the ImageStreamTag to be used for the Jenkins image.                                                                                                                                                                              jenkins:2
JENKINS_UC_INSECURE               Whether to allow use of a Jenkins Update Center that uses invalid certificate (self-signed, unknown CA). If any value other than 'false', certificate check is bypassed. By default, certificate check is enforced.                       false

```

#### Deploy Jenkins using jenkins-ephemeral template

```
oc new-app jenkins-ephemeral
--> Deploying template "openshift/jenkins-ephemeral" to project bookinfo

     Jenkins (Ephemeral)
     ---------
     Jenkins service, without persistent storage.
     
     WARNING: Any data stored will be lost upon pod destruction. Only use this template for testing.

     A Jenkins service has been created in your project.  Log into Jenkins with your OpenShift account.  The tutorial at https://github.com/openshift/origin/blob/master/examples/jenkins/README.md contains more information about using this template.

     * With parameters:
        * Jenkins Service Name=jenkins
        * Jenkins JNLP Service Name=jenkins-jnlp
        * Enable OAuth in Jenkins=true
        * Memory Limit=1Gi
        * Jenkins ImageStream Namespace=openshift
        * Disable memory intensive administrative monitors=false
        * Jenkins ImageStreamTag=jenkins:2
        * Allows use of Jenkins Update Center repository with invalid SSL certificate=false

--> Creating resources ...
    route.route.openshift.io "jenkins" created
    deploymentconfig.apps.openshift.io "jenkins" created
    serviceaccount "jenkins" created
    rolebinding.authorization.openshift.io "jenkins_edit" created
    service "jenkins-jnlp" created
    service "jenkins" created
--> Success
    Access your application via route 'jenkins-pipelineproject.apps-crc.testing' 
    Run 'oc status' to view your app.

```

#### Verify the depliyment is completed. 

```
oc get all
NAME                   READY   STATUS      RESTARTS   AGE
pod/jenkins-1-deploy   0/1     Completed   0          96s
pod/jenkins-1-xbpcm    1/1     Running     0          87s

NAME                              DESIRED   CURRENT   READY   AGE
replicationcontroller/jenkins-1   1         1         1       96s

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)     AGE
service/jenkins        ClusterIP   172.30.157.171   <none>        80/TCP      97s
service/jenkins-jnlp   ClusterIP   172.30.134.17    <none>        50000/TCP   97s

NAME                                         REVISION   DESIRED   CURRENT   TRIGGERED BY
deploymentconfig.apps.openshift.io/jenkins   1          1         1         config,image(jenkins:2)

NAME                               HOST/PORT                                                        PATH   SERVICES   PORT    TERMINATION     WILDCARD
route.route.openshift.io/jenkins   jenkins-pipelineproject.apps-crc.testing                         jenkins    <all>   edge/Redirect   None

```

#### Setup Jenkins job
* We need to set up a pipeline to build our software, but we want to use the build that is built into OpenShift. The following command will create a build configuration (or “build config,” which is an object of type “BuildConfig”), which has the instructions we give to OpenShift to tell it how to build our application. In this particular case, we’re creating a pipeline that, in turn, has the build instructions:

```
oc create -f https://raw.githubusercontent.com/openshift/origin/master/examples/jenkins/pipeline/nodejs-sample-pipeline.yaml
```

#### List builds

```
oc get buildconfigs 
NAME                     TYPE              FROM   LATEST
nodejs-mongodb-example   Source            Git    1
nodejs-sample-pipeline   JenkinsPipeline          1

```

#### Start build

```
oc start-build nodejs-sample-pipeline
```

#### Understanding build configurations
* https://docs.openshift.com/container-platform/4.4/builds/build-strategies.html#builds-tutorial-pipeline_build-strategies
* https://docs.openshift.com/container-platform/4.4/builds/understanding-buildconfigs.html

#### Note: 
* OpenShift Pipelines Now Available as Technology Preview - https://www.openshift.com/blog/openshift-pipelines-tech-preview-blog 
* Creating Pipelines with OpenShift 4.4’s new Pipeline Builder and Tekton Pipelines - https://developers.redhat.com/blog/2020/04/30/creating-pipelines-with-openshift-4-4s-new-pipeline-builder-and-tekton-pipelines/
* External Jenkins (`../utils/jenkins-install.sh && scp/rsync/sudo cp -a ~/.kube /var/lib/jenkins` -> use oc CLI in pipelines -> (Optional) Install OpenShift&k8s Plugins). After logging in with the CLI(oc) for the first time, OpenShift creates a ~/.kube/config file if one does not already exist.

#### Resources: 
* Using build strategies  - https://docs.openshift.com/container-platform/4.4/builds/build-strategies.html#builds-tutorial-pipeline_build-strategies
* Using templates 	  - https://access.redhat.com/documentation/en-us/openshift_container_platform/4.4/html/images/using-templates
* Build Strategy Tutorial - https://docs.openshift.com/container-platform/4.4/builds/build-strategies.html#builds-tutorial-pipeline_build-strategies
* https://www.youtube.com/watch?v=kbbK0VEy2qM - Demo video.
