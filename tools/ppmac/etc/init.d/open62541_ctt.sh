#!/bin/sh

# Note that ps returns only one character after the '.'
TARGET="ua_server_ctt.e"

# Getting the PID of the process
PID=$(ps -e | grep "$TARGET" | awk '{ print $1 }')
pgrepN=$(pgrep "$TARGET" | wc -l)

# Number of seconds to wait before using "kill -9"
WAIT_SECONDS=10

# Counter to keep count of how many seconds have passed
count=0

case $1 in
start)
  count=0
  if [ $pgrepN = 0 ]; then
    echo 'Starting open62541 Compliance Testing Tool'
    ua_server_ctt.exe \
      /opt/open62541/pki/created/server_cert.der \
      /opt/open62541/pki/created/server_key.der \
      --enableUnencrypted --enableAnonymous &
  else
    echo 'open62541 Compliance Testing Tool already running'
    exit 1
  fi
  ;;  
stop)
  count=0
  if [ $pgrepN -gt 0 ]; then
    echo 'Stopping open62541 Compliance Testing Tool'
    kill -2 "$PID" >/dev/null
    while ps -p "$PID" >/dev/null; do
      # Wait for one second
      sleep 1
      # Increment the second counter
      count=$((count + 1))
      # Have we exceeded $WAIT_SECONDS? If so, kill the process with "kill -9"
      # and exit the loop
      if [ $count -gt $WAIT_SECONDS ]; then
        kill -9 "$PID"
        pgrepN=$(pgrep "$TARGET" | wc -l)
        if [ $pgrepN -gt 0 ]; then
          echo -e "\nProcess has been killed after $count seconds."
        fi
        break
      fi
    done
    echo ""
  fi
  ;;  
restart)
  $0 stop
  sleep 2
  $0 start
  ;;
*)
  echo 'Proper usage is [open62541_ctt start] to load or [open62541_ctt stop] to shutdown'
  exit 1
  ;;
esac
