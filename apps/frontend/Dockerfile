FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

ARG API_BASE_URL

RUN flutter build web \
    --release \
    --dart-define=API_BASE_URL=${API_BASE_URL}

FROM node:22-alpine AS runner

WORKDIR /app

RUN npm install --global serve

COPY --from=builder /app/build/web ./build/web

CMD ["sh", "-c", "serve -s build/web -l tcp://0.0.0.0:${PORT:-3000}"]
