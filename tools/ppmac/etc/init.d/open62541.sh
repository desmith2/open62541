#!/bin/sh

# Getting the PID of the process
PID=$(ps -e | grep ua_server_ctt.exe | awk '{ print $1 }')
pgrepN=$(pgrep ua_server_ctt.exe | wc -l)

# Number of seconds to wait before using "kill -9"
WAIT_SECONDS=10

# Counter to keep count of how many seconds have passed
count=0

case $1 in
start)
  if [ "$pgrepN" -eq "0" ]; then
    echo 'Starting open62541 Compliance Testing Tool'
    if [ -f /usr/bin/ua_server_ctt.exe ]; then
        /usr/bin/ua_server_ctt.exe \
        /opt/open62541/pki/created/server_cert.der \
        /opt/open62541/pki/created/server_key.der \
        --enableUnencrypted --enableAnonymous >/dev/null &
    else
        echo 'open62541 Compliance Testing Tool start failed to find application ua_server_ctt.exe'
        exit 1
    fi
  fi
  ;;
stop)
  if [ "$pgrepN" -gt "0" ]; then
    echo 'Stopping open62541 OPC_UA'
    while kill -9 "$PID" >/dev/null; do
      # Wait for one second
      sleep 1
      # Increment the second counter
      count=$((count + 1))

      # Has the process been killed? If so, exit the loop.
      if ! ps -p "$PID" >/dev/null; then
        break
      fi

      # Have we exceeded $WAIT_SECONDS? If so, kill the process with "kill -9"
      # and exit the loop
      if [ $count -gt $WAIT_SECONDS ]; then
        kill -9 "$PID"
        pgrepN=$(pgrep ua_server_ctt.exe | wc -l)
        if [ "$pgrepN" -gt "0" ]; then
          echo "Unable to  open62541 OPC_UA"
        fi
        break
      fi
    done
    #echo "Process has been killed after $count seconds."
  fi
  ;;
restart)
  $0 stop
  sleep 2
  $0 start
  ;;
*)
  echo 'Proper usage is [open62541 start] to load or [open62541 stop] to shutdown'
  exit 1
  ;;
esac
