# build app
FROM golang:alpine AS gobuild
RUN apk update && \
    apk add ca-certificates gcc git make musl-dev
RUN mkdir /home/build
COPY . /home/build
WORKDIR /home/build
RUN go mod tidy && go build -o app

FROM alpine:latest
ARG PUID=2000
ARG PGID=2000

# Run App
RUN addgroup -g ${PGID} devicemanagerb && \
    adduser -H -D -u ${PUID} -G devicemanagerb devicemanagerb

WORKDIR /home/build

COPY --from=gobuild /home/build/app app
COPY --from=gobuild /home/build/www www

RUN chown -R ${PUID}:${PGID} /home/build

USER devicemanagerb
ENV mode=managedbyedge
CMD ["/home/build/app"]