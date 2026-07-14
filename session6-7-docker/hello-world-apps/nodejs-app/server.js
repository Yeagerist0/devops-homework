const http = require("http");

http.createServer((_request, response) => {
  response.writeHead(200, { "Content-Type": "text/plain; charset=utf-8" });
  response.end("Hello World from Node.js\n");
}).listen(3000, "0.0.0.0");
