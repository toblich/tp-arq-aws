const express = require('express');
const app     = express();

const datadogOptions = {
  'response_code': true,
  'tags':          ['app:node']
};

const connectDatadog = require('connect-datadog')(datadogOptions);

app.use(connectDatadog);

// ---

app.get('/', (req, res) => res.send('Hello World!'));

app.listen(3000, () => console.log('Example app listening on port 3000!'));
