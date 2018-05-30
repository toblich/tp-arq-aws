module.exports = {
  // Flag to determine whether to log debug information or not
  debug: true,

  // Base uri for remote python service
  remoteBaseUri: 'http://localhost:8000',

  // Options for creating redis client
  redis: {
    host: 'localhost',
    port: '1234'
  },

  datadog: {
    'response_code': true,
    'tags':          ['app:node']
  }
}
