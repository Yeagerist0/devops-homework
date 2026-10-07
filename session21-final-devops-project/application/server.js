const express = require('express');
const client = require('prom-client');

const app = express();
const PORT = process.env.PORT || 8080;

// Prometheus Metrics setup
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({ timeout: 5000 });

const httpRequestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total count of incoming HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

app.use((req, res, next) => {
  res.on('finish', () => {
    httpRequestCounter.inc({
      method: req.method,
      route: req.path,
      status_code: res.statusCode
    });
  });
  next();
});

app.get('/', (req, res) => {
  res.json({
    status: 'online',
    message: 'Welcome to Final DevOps End-to-End Capstone Project',
    author: 'Hitarth Jain',
    enrollment: '24BCS10399',
    environment: process.env.NODE_ENV || 'production',
    database_connected: true,
    version: '2.5.0'
  });
});

app.get('/healthz', (req, res) => res.status(200).send('OK'));
app.get('/ready', (req, res) => res.status(200).send('Ready'));

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

if (require.main === module) {
  app.listen(PORT, () => console.log(`Final application running on port ${PORT}`));
}

module.exports = app;
