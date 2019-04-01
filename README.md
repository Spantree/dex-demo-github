# Minikube dex

## Prerequisites

* Clone the tutorial repo `git clone <repourl> ~/dex-demo`
* Run `go get -v github.com/dexidp/dex` and `cd $GOPATH/src/github.com/dexidp/dex/` and `make`.
* Minikube 0.33.1 or 1.0.0 installed on your workstation or machine that you are using for this demo
* Create a new OAuth app setting in github `https://github.com/organizations/[YOURORG]/settings/applications` and save the client id and the client secret for later use.

It should look like this:

![image](https://user-images.githubusercontent.com/91633/55295620-9beb0e00-53e5-11e9-8a79-725ca3560084.png)

## Installation instructions

* Run ./gencert.sh to create the certificates for dex (it will create the necessary certs for the demo)

* Make the certificate file available inside the minikube vm

```bash
mkdir -p ~/.minikube/files/var/lib/minikube/certs/ && \
 cp -a ./ssl/* ~/.minikube/files/var/lib/minikube/certs/
```

* Create the minikube cluster.

```bash
minikube start --vm-driver=virtualbox --memory=4096 \
--network-plugin=cni \
--enable-default-cni \
--extra-config=apiserver.authorization-mode=RBAC \
--extra-config=apiserver.oidc-issuer-url=https://dex.example.com:32000 \
--extra-config=apiserver.oidc-username-claim=email \
--extra-config=apiserver.oidc-ca-file=/var/lib/minikube/certs/ca.pem \
--extra-config=apiserver.oidc-client-id=example-app \
--extra-config=apiserver.oidc-groups-claim=groups
```

The option `--extra-config=apiserver.apiserver.oidc-client-id=example-app` will match the default value (`example-app`) of the example app that comes with dex.

* Add `dex.example.com` to `/etc/hosts`: `sudo -v && echo $(minikube ip) dex.example.com | sudo tee -a /etc/hosts`
* Add the TLS certs to kubernetes `./create-dex-tls.sh`
* Add the github clientid and clientsecret `create-github-credentials.sh <clientid> <clientsecret>`
* Edit the file `/etc/hosts` of the minikube host by using `minikube ssh -- "echo '127.0.2.1 dex.example.com' | sudo tee -a /etc/hosts"`.
* Install and configure Dex `kubectl apply -f dex.yaml`
* Verify dex is running by doing `kubectl logs deploy/dex -f`
* Create cluster role binding for your user `kubectl create clusterrolebinding github-feniix --clusterrole=cluster-admin --user=feniix@gmail.com`

## Run the example client app

* `cd $GOPATH/src/github.com/coreos/dex/`
* `./bin/example-app --issuer=https://dex.example.com:32000 --issuer-root-ca=/Users/otaegui/dex-demo/ssl/ca.pem`
* Hit `http://127.0.0.1:5555` in your web browser

* Click on login

![image](https://user-images.githubusercontent.com/91633/55295640-d18ff700-53e5-11e9-982b-1a57e351362d.png)

* Click on Grant

![image](https://user-images.githubusercontent.com/91633/55295700-8d512680-53e6-11e9-9b12-082e68d80402.png)

* Copy the ID Token somewhere (that is your token for access)

![image](https://user-images.githubusercontent.com/91633/55295715-b8d41100-53e6-11e9-8df4-173313095136.png)

## Configure and test `kubectl`

* Open ~/.kube/config and search for `- name: minikube`
* Delete the entries for `client-certificate` and `client-key` from the config
* Run `kubectl --token=<Token copied earlier> get pods`
