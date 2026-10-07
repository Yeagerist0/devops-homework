const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    app: 'Secured DevSecOps Microservice',
    status: 'Healthy',
    student: 'Hitarth Jain (24BCS10399)',
    securityChecks: ['SAST', 'SCA', 'SecretScan', 'TrivyContainerScan']
  });
});

app.get('/healthz', (req, res) => res.status(200).send('OK'));

if (require.main === module) {
  app.listen(PORT, () => console.log(`DevSecOps service active on port ${PORT}`));
}

module.exports = app;
