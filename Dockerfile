FROM node:14-alpine AS base


RUN apk add \
    make \
    g++ \
    python3 \
    python 

WORKDIR /app

FROM base AS deps
ADD package.json yarn.lock ./
RUN yarn install --frozen-lockfile --prefer-offline --cache-folder .yarn

FROM deps AS code
ADD . ./


FROM code AS development


FROM base as production
ADD package.json yarn.lock ./
RUN yarn install --production --frozen-lockfile --prefer-offline --cache-folder .yarn
ADD . ./
ENTRYPOINT ["yarn", "start:prod"]


