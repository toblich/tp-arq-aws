// Import libraries
const express     = require('express');
const got         = require('got');
const redis       = require('redis');
const {promisify} = require('util');

// Load config
const config   = require('./config');
const cacheKey = 'key';

// Create redis client and monkey-patch it to use Promises
config.redis.retryStrategy = (options) => {
  if (options.error.code === 'ECONNREFUSED') {
    // This will suppress the ECONNREFUSED unhandled exception
    // that results in app crash
    console.log('Swallowing error of trying to connect to non-existing Redis server');
    return;
  }
  console.log('Got another error when starting redis:', options.error);
};
const redisClient = redis.createClient(config.redis);
for (let method of ['set', 'get', 'del']) {
  redisClient[method] = promisify(redisClient[method]);
}

// Initialize datadog client
const connectDatadog = require('connect-datadog')(config.datadog);

// Create app
const app = express();

// Set app to use the datadog middleware
app.use(connectDatadog);

// Routes
app.get('/', (req, res) => res.send('Hello World!'));
app.get('/remote', getRemote);
app.get('/remote/cached', getCached);
app.delete('/remote/cached', delCached);

// Start app
app.listen(3000, () => console.log('Example app listening on port 3000!'));


// --- Request handlers ---

async function getRemote(req, res) {
  const value = await getRemoteValue();
  res.send(value);
}


async function getCached(req, res) {
  // Id to be used just for debugging, to identify which request a
  const reqId = Math.random().toString().slice(2, 11);

  debug(reqId, 'checking cache...');
  let value = await redisClient.get(cacheKey);

  if (!value) {
    debug(reqId, 'hitting remote service to set cache...');
    value = await getRemoteValue();

    debug(reqId, 'setting cache...');
    redisClient.set(cacheKey, value).then(() => debug(reqId, 'cache set.'));
  }

  debug(reqId, 'answering');
  res.send(value);
}


async function delCached(req, res) {
  try {
    await redisClient.del(cacheKey);
    res.status(204).send();
  } catch (error) {
    res.status(500).send(error);
  }
}


// --- helper functions ---

async function getRemoteValue() {
  const response = await got(`${config.remoteBaseUri}/sleep/1`);
  return response.body;
}

function debug(...args) {
  if (!config.debug) {
    return;
  }

  console.log(...args);
}
