# This is a multistage Dockerfile

# Stage 1  - Build the Client
FROM node:20-alpine AS client-builder
WORKDIR /usr/src/app/client
COPY client/package*.json
RUN npm install
COPY client/ ./
RUN npm run build

# Stage 2 - Build Production Server
FROM node:20-alpine AS production
WORKDIR /usr/src/app/server
COPY server/package*.json
RUN npm install --omit=dev
COPY server/ ./

# Copy only the built client assets from Stage 1
COPY --from=client-builder /usr/src/app/client/public ./public

ENV NODE_ENV=production

RUN addground -S appgroup && adduser -S appuser -G appgroup
RUN chowm -R appuser:appgroup /usr/src/app

USER appuser

EXPOSE 5000

CMD ["npm","start"]
