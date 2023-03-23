#!/usr/bin/bash
#Ubuntu 20, 22 LTS - Dehydrated Let's Encrypt Client Configuration

echo "### Install dependency packages"
apt-get -qq update; apt-get -qq -y install git curl publicsuffix jq bind9-utils

ORIGDIR=$(pwd)
TEMPDIR=$(mktemp -d)

cd $TEMPDIR

echo "### Download and Install"
git clone https://github.com/dehydrated-io/dehydrated -q
mkdir -p /etc/dehydrated/hooks /etc/dehydrated/domains.d /etc/pki/acme /var/www/dehydrated /etc/nginx/snippets
cp dehydrated/dehydrated /sbin
if [ -f /etc/dehydrated/config ] && [ -f /etc/dehydrated/domains.txt ]; then
	echo "Running config detected, skip config copy."
else
	cp dehydrated/docs/examples/{config,domains.txt} /etc/dehydrated
	sed -i 's|#CERTDIR="${BASEDIR}/certs"|CERTDIR="/etc/pki/acme"|' /etc/dehydrated/config 2>&1 >/dev/null
	sed -i 's|#DOMAINS_D=|DOMAINS_D="${BASEDIR}/domains.d"|' /etc/dehydrated/config 2>&1 >/dev/null
fi

echo "### Install Cloud Flare Hook"
curl -s https://raw.githubusercontent.com/socram8888/dehydrated-hook-cloudflare/master/cf-hook.sh --output /etc/dehydrated/hooks/cloudflare.sh
chmod +x /etc/dehydrated/hooks/cloudflare.sh

echo "### Install cron script"
curl -s https://raw.githubusercontent.com/NimbusNetworkBR/CakeRecipes/prod/acme/conf/acme-renew --output /etc/cron.daily/acme-renew
chmod +x /etc/cron.daily/acme-renew

echo "### Install ACME Nginx snippet"
curl -s https://raw.githubusercontent.com/NimbusNetworkBR/CakeRecipes/prod/acme/conf/acme-nginx.conf --output /etc/nginx/snippets/acme.conf

echo "### Register Server"
dehydrated --register --accept-terms

echo "### Clean Temp Files"
if [ -d $TEMPDIR ];then
	cd $ORIGDIR
	rm -rf $TEMPDIR;
fi
