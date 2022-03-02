FROM golang:1.14 AS build
WORKDIR /ratelimit

ENV GOPROXY=https://proxy.golang.org
COPY go.mod go.sum /ratelimit/
RUN go mod download

COPY src src
COPY script script

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH}  go build -o /go/bin/${TARGETARCH}/ratelimit -ldflags="-w -s" -v github.com/envoyproxy/ratelimit/src/service_cmd

FROM --platform=$TARGETPLATFORM alpine:3.11 AS final
RUN apk --no-cache add ca-certificates
COPY --from=build /go/bin/${TARGETARCH}/ratelimit /bin/ratelimit
