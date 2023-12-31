# NodeJS Express web app using node-vault module to fetch secrets directly from HashiCorp Vault server

blog: https://fabianlee.org/2023/11/13/vault-nodejs-express-web-app-using-node-vault-to-fetch-secrets/

This project is a NodeJS Express web application using the [node-vault](https://github.com/nodevault/node-vault) library to fetch secrets directly from a HashiCorp
Vault server.

This code assumes the Vault Server uses the Kubernetes auth method, which means the NodeJS app should be deployed into a Kubernetes cluster running under a specific Kubernetes service account so it presents the correct JWT.

This app can fetch a secret from a remote or in-cluster Vault server without the need for a Vault sidecar by using the node-vault module. Generally, it is preferrable to communicate direcly to Vault so no intermediate secret representations are stored.


## (Optional) Vault sidecar

Even though the node-vault modules allow a NodeJS application to fetch secrets directly from a Vault server, there are multiple reasons you may want still to run a Vault sidecar:

* Your particular app language does not have a fully-featured Vault client library
* You want to shield your application from Vault server configuration details
* You have a legacy application that must continue reading config/secrets from the filesystem/environment
* You want auto-rotation of Vault secrets/certs

This project supports pointing at the Vault sidecar as well, http://localhost:8082


## Creating OCI image with Docker manually

```
sudo apt install -y npm
npm init -y
npm install express cors node-vault

# if you want to test basic syntax locally
node --check index.js

# builds 'latest' image and pushes to DockerHub
./docker-build.sh
```

# Creating tag, which runs GitHub Action to build image and upload

```
newtag=v1.0.1
git commit -a -m "changes for new tag $newtag" && git push -o ci.skip
git tag $newtag && git push origin $newtag
```

# Deleting tag

```
# delete single local tag, then remote
todel=v1.0.1; git tag -d $todel && git push -d origin $todel
```
