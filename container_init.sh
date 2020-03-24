#!/bin/bash

echo "Setting up the password for User A..."
htpasswd -c /authconfig/.htpasswd usera
echo "...Done."

echo ""
echo ""

echo "Setting up the password for User B..."
htpasswd /authconfig/.htpasswd userb
echo "...Done."

echo ""
echo ""

echo "Setting up SSL/TLS..."
mkdir -p /etc/cert/
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/cert/certificatekey.key -out /etc/cert/certificate.crt
echo "...Done."

echo ""
echo ""
echo "############################################################################"
echo ""

echo "Please note this value to validate the authenticity of the HTTPS connection"
openssl x509 -in /etc/cert/certificate.crt -noout -sha256 -fingerprint

echo ""
echo "############################################################################"
echo ""
echo ""

echo "Starting Apache2..."
service apache2 start
echo "...Done."

echo ""
echo ""

echo "Starting NodeJS relay servers..."
cd /relayserver
(nodejs nodejs_relay.js 4 127.0.0.1 8000 2>/dev/null >/dev/null) &
(nodejs nodejs_relay.js 4 127.0.0.1 8001 2>/dev/null >/dev/null) &

echo "...relay servers started. Press CTRL+C to exit."
read -r -d '' _ </dev/tty
