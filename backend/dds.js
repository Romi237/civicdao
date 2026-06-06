const crypto = require('crypto');
const fs = require('fs');

const jwt = crypto.randomBytes(48).toString('hex');
const refresh = crypto.randomBytes(48).toString('hex');

const content = [
  "JWT_SECRET=" + jwt,
  "JWT_REFRESH_SECRET=" + refresh
].join("\n");

fs.writeFileSync('.env', content);
console.log('backend/.env created with secure secrets!');
