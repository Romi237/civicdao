const crypto = require('crypto');
const fs = require('fs');

const jwt = crypto.randomBytes(48).toString('hex');
const refresh = crypto.randomBytes(48).toString('hex');

const content = [
  "NODE_ENV=development",
  "PORT=3000",
  "MONGODB_URI=mongodb://localhost:27017/civicdao",
  "JWT_SECRET=" + jwt,
  "JWT_REFRESH_SECRET=" + refresh,
  "JWT_EXPIRY=1h",
  "REFRESH_TOKEN_EXPIRY=7d",
  "BCRYPT_SALT_ROUNDS=12",
  "CORS_ORIGIN=*"
].join("\n");

fs.writeFileSync('.env', content);
console.log('backend/.env created with secure secrets!');