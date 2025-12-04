const express = require('express');
const cors = require('cors');
const http = require('http');
const { URL } = require('url');

const app = express();
const PORT = 3001;

// Enable CORS for all routes
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: false
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

console.log('⏳ Starting CORS Proxy...');

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Unified proxy middleware for both API and static assets
const proxyHandler = (req, res) => {
  const targetUrl = new URL(`http://wisatalembung.test${req.originalUrl}`);

  const isImage = req.path.includes('/assets/') || req.path.includes('/storage/');
  console.log(`\n📡 [${new Date().toISOString()}] ${req.method} ${req.path}`);
  console.log(`   → ${targetUrl.toString()} ${isImage ? '🖼️ IMAGE' : ''}`);

  const options = {
    hostname: targetUrl.hostname,
    port: targetUrl.port || 80,
    path: targetUrl.pathname + targetUrl.search,
    method: req.method,
    headers: {},
  };

  // Set appropriate headers based on request type
  if (isImage) {
    options.headers['Accept'] = 'image/*,*/*';
  } else {
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
  }

  // Copy relevant headers
  Object.keys(req.headers).forEach(key => {
    if (key !== 'host' && key !== 'content-length' && key !== 'origin') {
      options.headers[key] = req.headers[key];
    }
  });

  const proxyReq = http.request(options, (proxyRes) => {
    console.log(`   ✅ Status: ${proxyRes.statusCode}`);

    // Add CORS headers
    const responseHeaders = {
      ...proxyRes.headers,
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, Accept',
    };

    res.writeHead(proxyRes.statusCode, responseHeaders);
    proxyRes.pipe(res);
  });

  proxyReq.setTimeout(10000, () => {
    console.error(`   ❌ Timeout`);
    proxyReq.destroy();
    if (!res.headersSent) {
      res.status(504).json({ error: 'Gateway timeout' });
    }
  });

  proxyReq.on('error', (err) => {
    console.error(`   ❌ Error: ${err.message}`);
    if (!res.headersSent) {
      res.status(500).json({ error: 'Proxy error', message: err.message });
    }
  });

  // Only send body data for non-GET requests with JSON content
  if (req.method !== 'GET' && req.body && Object.keys(req.body).length > 0) {
    proxyReq.write(JSON.stringify(req.body));
  }

  proxyReq.end();
};

// Proxy API requests
app.all('/api/*', proxyHandler);

// Proxy static assets (images)
app.all('/assets/*', proxyHandler);
app.all('/storage/*', proxyHandler);

// Handle preflight
app.options('*', cors());

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not Found' });
});

app.listen(PORT, '127.0.0.1', () => {
  console.log(`✅ CORS Proxy running at http://127.0.0.1:${PORT}`);
  console.log(`📡 Proxying to http://wisatalembung.test`);
  console.log(`🏥 Health: http://127.0.0.1:${PORT}/health\n`);
});
