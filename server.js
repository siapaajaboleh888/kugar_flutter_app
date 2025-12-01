const express = require('express');
const path = require('path');
const app = express();
const PORT = 8080;

// Serve static files from build/web directory
app.use(express.static(path.join(__dirname, 'build', 'web')));

// SPA fallback - serve index.html for all routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'web', 'index.html'));
});

app.listen(PORT, '127.0.0.1', () => {
  console.log(`🚀 Flutter Web Server running at http://127.0.0.1:${PORT}`);
  console.log(`📡 Serving files from build/web`);
});
