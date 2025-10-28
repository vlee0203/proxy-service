const http = require('http');
const httpProxy = require('http-proxy');
const { HttpsProxyAgent } = require('https-proxy-agent')

const targetUrl = process.env.TARGET || 'https://marketplace.dify.ai';
const httpsProxyUrl = process.env.HTTPS_PROXY || process.env.https_proxy;

const proxy = httpProxy.createProxyServer({
  target: targetUrl,
  agent: httpsProxyUrl ? new HttpsProxyAgent(httpsProxyUrl) : undefined,
  changeOrigin: true,
  secure: true
});

const server = http.createServer((req, res) => {
  proxy.web(req, res, (err) => {
    console.error('Proxy error:', err);
    res.writeHead(500);
    res.end('Proxy error: ' + err.message);
  });
});

server.on('error', (err) => {
  console.error('Server error:', err);
  process.exit(1);
});

server.listen(8080, () => {
  console.log('Proxy running on http://0.0.0.0:8080');
});

