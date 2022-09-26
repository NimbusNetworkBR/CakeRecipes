#!/usr/bin/bash
#Ubuntu 20, 22 LTS - Dehydrated Let's Encrypt Client Configuration

echo "Install dependency packages"
apt-get -qq update; apt-get -qq -y install git curl publicsuffix jq wget bind9-utils

ORIGDIR=$(pwd)
TEMPDIR=$(mktemp -d)

cd $TEMPDIR

echo "Download and Install"
git clone https://github.com/dehydrated-io/dehydrated
mkdir -p /etc/dehydrated/hooks /etc/dehydrated/domains.d /etc/pki/acme /var/www/dehydrated
cp dehydrated/dehydrated /sbin
if [ -f /etc/dehydrated/config ] && [ -f /etc/dehydrated/domains.txt ]; then
	echo "Running config detected, skip config copy."
else
	cp dehydrated/docs/examples/{config,domains.txt} /etc/dehydrated
fi

curl -s https://raw.githubusercontent.com/socram8888/dehydrated-hook-cloudflare/master/cf-hook.sh --output /etc/dehydrated/hooks/cloudflare.sh
chmod +x /etc/dehydrated/hooks/cloudflare.sh 2>&1 >/dev/null

sed -i 's|#CERTDIR="${BASEDIR}/certs"|CERTDIR=/etc/pki/acme|' /etc/dehydrated/config 2>&1 >/dev/null
sed -i 's|#DOMAINS_D|DOMAINS_D=/etc/dehydrated/domains.d|' /etc/dehydrated/config 2>&1 >/dev/null

dehydrated --register --accept-terms 2>&1 >/dev/null

#Clean Temp Files
if [ -d $TEMPDIR ];then
	cd $ORIGDIR
	rm -rf $TEMPDIR;
fi