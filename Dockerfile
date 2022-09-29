ARG GO_VERSION=1.17

FROM golang:${GO_VERSION}-alpine AS builder

RUN apk update && apk add alpine-sdk git && rm -rf /var/cache/apk/*

RUN mkdir -p /builder
WORKDIR /builder

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .
RUN go build -o ./server ./cmd/main.go

FROM alpine:latest

WORKDIR /
COPY --from=builder /builder/server .

WORKDIR /
COPY --from=builder /builder/common.yaml common.yaml

WORKDIR /
COPY --from=builder /builder/.env .env

EXPOSE 9000

CMD ["./server"]
