FROM golang:1.13-alpine AS builder
RUN mkdir /dist
WORKDIR /dist
COPY . .
RUN apk --no-cache add ca-certificates
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o app
RUN adduser -D -g '' -u 4000 appuser
RUN mkdir /data

FROM scratch
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --chown=4000:0 --from=builder /data /data
COPY --chown=0:0 --from=builder /dist/app /app
USER appuser
WORKDIR /data
ENTRYPOINT ["/app"]
