const express = require('express')
const cors = require('cors')

const app = express()

app.use(cors())

// node-vault module, https://github.com/nodevault/node-vault
process.env.DEBUG = 'node-vault';
const vault = require("node-vault")({
  apiVersion: "v1",
  endpoint: process.env.VAULT_URI || "http://vault.vault.svc.cluster.local:8200"
});

// full path to Vault secret, '/data' needs to be inserted for kv2 engine
const fullSecretPath = (process.env.VAULT_BACKEND || "secret") + "/" + 
    "data/" +
    (process.env.VAULT_CONTEXT || "webapp") + "/" +
    (process.env.VAULT_PROFILE || "config");
console.log("secret path: " + fullSecretPath);
const vaultRole = process.env.VAULT_ROLE || "myrole";
console.log("vault role: " + vaultRole);

const JWT_TOKEN_FILE="/var/run/secrets/kubernetes.io/serviceaccount/token";

// use JWT token of Kubernetes Service Account for auth to Vault server
async function doVaultLogin() {
  // read token file
  var fs = require('fs');
  const jwt = fs.readFileSync(JWT_TOKEN_FILE);
  console.log("JWT length: " + jwt.toString().length);

  // attempt kubernetes authentication, TokenReview
  const loginResult = await vault.kubernetesLogin({
    "role": vaultRole, 
    "jwt": jwt.toString()
  });
  console.log("result of Vault login");
  console.log(loginResult);
}
// async function for fetching Vault secret
let fetchSecretPromise = function(secretPath) {
    return vault.read(secretPath);
}

// test and health endpoint
app.get('/', (req, res) => {
  res.json([
    {
      "greeting": "Hello, World!"
    }
  ])
})

// returns secret
app.get('/secret', async (req,res) => {
  //fullContextPath = req.baseUrl + req.path;

  // fetch Vault secret
  let secret = null;
  try {
    secret = await vault.read(fullSecretPath);
  }catch(e) {
    if (e.response && e.response.statusCode==403) {
      console.log("Got ApiResponseError with 403 code, assuming Vault token expiration, attempting refresh");
      await doVaultLogin();
      secret = await vault.read(fullSecretPath);
    }
  }

  if (secret!=null) {
    console.log(secret.data.data);
  }else {
    console.log("ERROR could not retrieve secret.data");
  }

  // return secret key/value pairs
  res.json(secret.data.data);
})


// startup main listener
app.listen(4000, () => {
  doVaultLogin();
  console.log('Server running on port 4000')
})
