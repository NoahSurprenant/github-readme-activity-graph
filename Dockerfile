# Builds the activity-graph server: TypeScript compiled in one stage, then only dist/ and the
# production dependencies in the image that runs. Listens on $PORT (default 5100); needs a GitHub
# token in $TOKEN.
FROM docker.io/library/node:24-alpine@sha256:ebfe2f90462722a7a4de65e91990e97fe0d401c70e0e762c5b53302f905ec1c1 AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts --no-audit --no-fund
COPY tsconfig.json ./
COPY src ./src
RUN npm run build && npm prune --omit=dev

FROM docker.io/library/node:24-alpine@sha256:ebfe2f90462722a7a4de65e91990e97fe0d401c70e0e762c5b53302f905ec1c1
WORKDIR /app
ENV NODE_ENV=production PORT=5100
COPY --from=build /app/package.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
# The node image's unprivileged user (uid 1000).
USER node
EXPOSE 5100
CMD ["node", "dist/main.js"]
