const http = require("http");

let requests = 0;
const startTime = new Date();
const host = process.env.HOSTNAME || "unknown";
const version = process.env.APP_VERSION || "v1";

const server = http.createServer((request, response) => {
  requests += 1;
  response.writeHead(200, { "Content-Type": "text/plain; charset=utf-8" });
  response.end(`Hello Kubernetes! | Running on: ${host} | ${version}\n`);
  console.log(
    `Running On: ${host} | Version: ${version} | Total Requests: ${requests}` +
      ` | App Uptime: ${(new Date() - startTime) / 1000} seconds` +
      ` | Path: ${request.url}`
  );
});

server.listen(8080, "0.0.0.0", () => {
  console.log(`Kubernetes App Started At: ${startTime.toISOString()} | Running On: ${host} | ${version}`);
});

