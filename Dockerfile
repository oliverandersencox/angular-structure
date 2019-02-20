FROM node:10 AS build

# Allow the use of a caching proxy without trusted SSL
ARG NPM_PROXY=""
RUN echo 'strict-ssl=false' >> ~/.npmrc
WORKDIR /app
# Copy package lock and manifest to restore as separate step
COPY package-lock.json package.json ./
RUN HTTP_PROXY=${NPM_PROXY} HTTPS_PROXY=${NPM_PROXY} npm install
COPY . .

RUN npm run build -- --prod

RUN npm audit || true
# /build

FROM nginx AS frontend
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist/myn2o/. /usr/share/nginx/html
# /frontend
