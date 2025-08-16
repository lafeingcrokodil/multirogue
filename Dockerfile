FROM golang:1 AS builder
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN make build

FROM alpine AS final
COPY --from=builder /build/bin /bin
COPY --from=builder /build/public /public
EXPOSE 8080
ENTRYPOINT ["/bin/multirogue"]
