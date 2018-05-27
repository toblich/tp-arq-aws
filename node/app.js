const express = require('express');
const got     = require('got');
const config  = require('./config');

const app     = express();

const datadogOptions = {
  'response_code': true,
  'tags':          ['app:node']
};

const connectDatadog = require('connect-datadog')(datadogOptions);

app.use(connectDatadog);

// ---

app.get('/', (req, res) => res.send('Hello World!'));

app.get('/remote', async (req, res) => {
  try {
    const response = await got(`${config.remoteServiceHost}/sleep/1`);
    res.send(response.body);
  } catch (e) {
    console.error(e);
    res.send(e);
  }
});

app.listen(3000, () => console.log('Example app listening on port 3000!'));
