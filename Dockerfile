FROM alpine:3.5

RUN apk --update add ncurses-libs

WORKDIR /app

ADD events.tar.gz ./

EXPOSE 3000

ENTRYPOINT ["/app/bin/events", "foreground"]
