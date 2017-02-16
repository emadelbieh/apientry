#!/usr/bin/env bash

wait_for_psql () {
  while true; do
    sleep 1
    env PGPASSWORD="$3" \
      psql -h localhost -p "$1" -U "$2" "$4" \
      -c "select 1;" >/dev/null 2>/dev/null
    if [[ "$?" == "0" ]]; then break; fi
  done
}

KEYFILE="${0%/*}/../ansible/keys/admin2.pem"
chmod 600 "$KEYFILE"
ssh-add "$KEYFILE" 2>/dev/null

echo "Waiting for connection..." >&2

ssh ubuntu@54.172.78.10 -N \
  -L "20002:autoscale-apientry-rds.c1snflmeflqw.us-east-1.rds.amazonaws.com:5432" &
SSH_PID=$!

wait_for_psql 20002 apientry fxuJbaisGapsBacroarh apientry_production

echo "SSH tunnel available [$SSH_PID]" >&2
echo $SSH_PID
exit
