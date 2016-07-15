#!/usr/bin/env sh

finish () {
  PID=$(cat $PIDFILE)
  echo "Cleaning up ${PID}..."
  kill $PID
}

PIDFILE="pid.$RANDOM"
LOCAL_DATABASE_URL="postgres://apientry:fxuJbaisGapsBacroarh@localhost:20002/apientry_production"
"${0%/*}/connect-to-rds.sh" > $PIDFILE
env DATABASE_URL="$LOCAL_DATABASE_URL" mix ecto.migrate
trap finish EXIT
