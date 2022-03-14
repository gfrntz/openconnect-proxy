#!/bin/sh

sed "s/^Port .*$/Port 8888/" -i /etc/tinyproxy.conf
/usr/bin/tinyproxy -c /etc/tinyproxy.conf

/usr/local/bin/microsocks -i 0.0.0.0 -p 8889 &

run () {
  # Start openconnect
  if [[ -z "${OPENCONNECT_PASSWORD}" -a -z ${OPENCONNECT_BASE64_PASSWORD} ]]; then
  # Ask for password
    openconnect -u "$OPENCONNECT_USER" $OPENCONNECT_OPTIONS $OPENCONNECT_URL
  elif [[ ! -z "${OPENCONNECT_PASSWORD}" ]] && [[ ! -z "${OPENCONNECT_MFA_CODE}" ]]; then
  # Multi factor authentication (MFA)
    (echo $OPENCONNECT_PASSWORD; echo $OPENCONNECT_MFA_CODE) | openconnect -u "$OPENCONNECT_USER" $OPENCONNECT_OPTIONS --passwd-on-stdin $OPENCONNECT_URL
  elif [[ ! -z "${OPENCONNECT_PASSWORD}" ]]; then
  # Standard authentication
    echo $OPENCONNECT_PASSWORD | openconnect -u "$OPENCONNECT_USER" $OPENCONNECT_OPTIONS --passwd-on-stdin $OPENCONNECT_URL
  elif [[ ! -z "${OPENCONNECT_BASE64_PASSWORD}" ]]; then
    echo $OPENCONNECT_BASE64_PASSWORD | base64 -d | openconnect -u "$OPENCONNECT_USER" $OPENCONNECT_OPTIONS --passwd-on-stdin $OPENCONNECT_URL
  fi
}

until (run); do
  echo "openconnect exited. Restarting process in 60 seconds…" >&2
  sleep 60
done
