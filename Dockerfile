FROM node:18-alpine AS base

FROM base as deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json yarn.lock ./
RUN \
    if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
    else echo "Lockfile not found." && exit 1; \
    fi

FROM base as runner
WORKDIR /app
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 wildanazz
COPY --chown=wildanazz:nodejs . ./
COPY --from=deps --chown=wildanazz:nodejs /app/node_modules ./node_modules
USER wildanazz
EXPOSE 3000
CMD ["yarn", "start"]