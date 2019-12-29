FROM golang:1 AS build
COPY . /workspace
WORKDIR /workspace
RUN make build

FROM debian:stable-slim
RUN apt-get update && apt-get install -y ca-certificates git && rm -rf /var/lib/apt/lists/*
COPY --from=build /workspace/bin /bin
COPY --from=build /workspace/public /srv/http/public
WORKDIR /srv/http
CMD [ "multirogue" ]
