# Minikube dex

## Prerequisites

* Clone the tutorial repo `git clone <repourl> ~/dex-demo`
* Run `go get -v github.com/coreos/dex` and `cd $GOPATH/src/github.com/coreos/dex/` and `make`.
* Minikube installed on the test machine.
* Create a new OAuth app setting in github `https://github.com/organizations/[YOURORG]/settings/applications` and save the client id and the client secret for later use.

## Installation instructions

* Run ./gencert.sh to create the certificates for dex (it will create the necessary certs for the demo)

* Create the minikube cluster replacing the path `otaegui` with your username (minikube mounts the directory /Users into /Users inside its VM by default).

```bash
minikube start --vm-driver=virtualbox --memory=4096 --extra-config=apiserver.authorization-mode=RBAC --network-plugin=cni --extra-config=apiserver.oidc-issuer-url=https://dex.example.com:32000 --extra-config=apiserver.oidc-username-claim=email --extra-config=apiserver.oidc-ca-file=/var/lib/localkube/certs/dex/ca.pem --extra-config=apiserver.oidc-client-id=example-app --extra-config=apiserver.oidc-groups-claim=groups
```

You will have to mount the directory containing the generated certs into /var/lib/localkube/certs (inside minikube)

```bash
minikube mount "$(pwd)/ssl:/var/lib/localkube/certs/dex"
```

The option `--extra-config=apiserver.apiserver.oidc-client-id=example-app` will match the default value (`example-app`) of the example app that comes with dex.

* Add `dex.example.com` to `/etc/hosts`: `echo $(minikube ip) dex.example.com | sudo tee -a /etc/hosts`
* Fix kube-dns RBAC permissions: `kubectl apply -f auth-kubedns.yaml`
* Add the TLS certs to kubernetes `./create-dex-tls.sh`
* Add the github clientid and clientsecret `create-github-credentials.sh <clientid> <clientsecret>`
* Edit the file `/etc/hosts` of the minikube host by using `minikube ssh` and add `127.0.2.1   dex.example.com` to the file.
* Install and configure Dex `kubectl apply -f dex.yaml`
* Verify dex is running by doing `kubectl logs deploy/dex -f`
* Create cluster role binding for your user `kubectl create clusterrolebinding github-feniix --clusterrole=cluster-admin --user=feniix@gmail.com`

## Run the example client app

* `cd $GOPATH/src/github.com/coreos/dex/`
* `./bin/example-app --issuer=https://dex.example.com:32000 --issuer-root-ca=/Users/otaegui/dex-demo/ssl/ca.pem`
* Hit `http://127.0.0.1:5555` in your web browser
* Follow the instructions of the website

## Configure and test `kubectl`

* Open ~/.kube/config and search for `- name: minikube`
* Delete the entries for `client-certificate` and `client-key` from the config
* Run `kubectl --token=<TOKEN FROM the example client app> get pods`
