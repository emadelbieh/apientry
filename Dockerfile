FROM alpine:3.5

RUN apk --update add ncurses-libs

WORKDIR /app

<<<<<<< HEAD
ADD apientry.tar.gz ./

EXPOSE 3000

ENTRYPOINT ["/app/bin/apientry", "foreground"]
=======
ADD events.tar.gz ./

EXPOSE 3000

ENTRYPOINT ["/app/bin/events", "foreground"]
>>>>>>> 9f653c641a4f39b65d67c57568882b14f394b9a1
