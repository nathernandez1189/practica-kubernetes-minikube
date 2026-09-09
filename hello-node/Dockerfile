FROM node:22-alpine

WORKDIR /app

ARG APP_VERSION=v1
ENV APP_VERSION=$APP_VERSION

COPY server.js ./

EXPOSE 8080

CMD ["node", "server.js"]

