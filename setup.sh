#!/bin/bash
set -eu
# Converts the .p12 file to .crt and .key files
# Creates the eduroam.8021x config

if [ "$#" -ne 3 ]; then
	echo "Usage: $0 <person_code> <cert_file> <cert_pass>"
	exit 1
fi

CP=$1 
CERT_FILE=$2
CERT_PASS=$3

# Avoid overwriting existing files
if [ -f eduroam.crt.pem ] || [ -f eduroam.key.pem ] || [ -f eduroam.8021x ]; then
	echo "Files eduroam.crt.pem, eduroam.key.pem or eduroam.8021x already exist"
	exit 1
fi

# iwd does uses client key and cert in .pem format
openssl pkcs12 -in "$CERT_FILE" -out eduroam.crt.pem -clcerts -nokeys -passin pass:"$CERT_PASS" -legacy
openssl pkcs12 -in "$CERT_FILE" -out eduroam.key.pem -nocerts -nodes -passin pass:"$CERT_PASS" -legacy

# The config needs the person code
skeleton=$(cat <<EOF
[Security]
EAP-Method=TLS
EAP-Identity=$CP@polimi.it
EAP-TLS-CACert=/var/lib/iwd/eduroam.pem
EAP-TLS-ServerDomainMask=wifi.polimi.it
EAP-TLS-ClientCert=/var/lib/iwd/eduroam.crt.pem
EAP-TLS-ClientKey=/var/lib/iwd/eduroam.key.pem
EOF
)

echo "$skeleton" > eduroam.8021x

echo 'Successfully created eduroam.8021x, eduroam.crt.pem, eduroam.key.pem: move these files to /var/lib/iwd/'
echo 'You can do this by running `sudo mv -vn eduroam.8021x eduroam.crt.pem eduroam.key.pem /var/lib/iwd/`'
echo 'You also need to move the "ca.pem" file generated by the eduroam Python script to /var/lib/iwd/eduroam.pem'
echo 'You can do this by running `sudo mv -vn ca.pem /var/lib/iwd/eduroam.pem`'
echo 'If you also want to configure "polimi-protected", run `sudo cp -vn eduroam.8021x /var/lib/iwd/polimi-protected.8021x`'