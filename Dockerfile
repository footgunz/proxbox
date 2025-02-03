FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -ldflags="-s -w" -o proxbox

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/proxbox .
EXPOSE 8889 8890
ENTRYPOINT ["/app/proxbox"] 