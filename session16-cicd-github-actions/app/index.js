const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    status: 'success',
    message: 'CI/CD Pipeline Demo is Running Smoothly!',
    version: '1.0.0',
    student: 'Hitarth Jain (24BCS10399)',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Application listening on port ${PORT}`);
  });
}

module.exports = app;
