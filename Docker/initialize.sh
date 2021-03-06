#! /bin/bash

export CONFIG_FILE=/usr/share/docassemble/config.yml
source /usr/share/docassemble/local/bin/activate

function deregister {
    su -c '/usr/share/docassemble/local/bin/python -m docassemble.webapp.deregister' www-data
}

trap deregister SIGINT SIGTERM

if [ "${HOSTNAME-none}" != "none" ]; then
  sed -i'' \
      -e 's/#ServerName {{HOSTNAME}}/ServerName '"${HOSTNAME}"'/' \
      /etc/apache2/sites-available/default-ssl.conf || exit 1
  sed -i'' \
      -e 's/#ServerName {{HOSTNAME}}/ServerName '"${HOSTNAME}"'/' \
      /etc/apache2/sites-available/000-default.conf || exit 1
fi

if [ "${CONTAINERROLE-all}" == "all" ]; then
  sed -i'' \
      -e 's@{{DBPREFIX}}@'"${DBPREFIX-postgresql+psycopg2://}"'@' \
      -e 's/{{DBNAME}}/'"${DBNAME-docassemble}"'/' \
      -e 's/{{DBUSER}}/'"${DBUSER-null}"'/' \
      -e 's/{{DBPASSWORD}}/'"${DBPASSWORD-null}"'/' \
      -e 's/{{DBHOST}}/'"${DBHOST-null}"'/' \
      -e 's/{{S3ENABLE}}/'"${S3ENABLE-false}"'/' \
      -e 's/{{S3ACCESSKEY}}/'"${S3ACCESSKEY-null}"'/' \
      -e 's/{{S3SECRETACCESSKEY}}/'"${S3SECRETACCESSKEY-null}"'/' \
      -e 's/{{S3BUCKET}}/'"${S3BUCKET-null}"'/' \
      -e 's/{{EC2}}/'"${EC2-false}"'/' \
      -e 's/{{LOGSERVER}}/'"${LOGSERVER-null}"'/' \
      $CONFIG_FILE || exit 1
else
  sed -i'' \
      -e 's@{{DBPREFIX}}@'"${DBPREFIX-postgresql+psycopg2://}"'@' \
      -e 's/{{DBNAME}}/'"${DBNAME-docassemble}"'/' \
      -e 's/{{DBUSER}}/'"${DBUSER-docassemble}"'/' \
      -e 's/{{DBPASSWORD}}/'"${DBPASSWORD-abc123}"'/' \
      -e 's/{{DBHOST}}/'"${DBHOST-null}"'/' \
      -e 's/{{S3ENABLE}}/'"${S3ENABLE-false}"'/' \
      -e 's/{{S3ACCESSKEY}}/'"${S3ACCESSKEY-null}"'/' \
      -e 's/{{S3SECRETACCESSKEY}}/'"${S3SECRETACCESSKEY-null}"'/' \
      -e 's/{{S3BUCKET}}/'"${S3BUCKET-null}"'/' \
      -e 's/{{EC2}}/'"${EC2-false}"'/' \
      -e 's/{{LOGSERVER}}/'"${LOGSERVER-null}"'/' \
      $CONFIG_FILE || exit 1
fi
python -m docassemble.webapp.update_config $CONFIG_FILE || exit 1

if [ "${LOCALE-undefined}" != "undefined" ]; then
    set -- $LOCALE
    DA_LANGUAGE=$1
    grep -q "^$LOCALE" /etc/locale.gen || { echo $LOCALE >> /etc/locale.gen && locale-gen ; }
    update-locale LANG=$DA_LANGUAGE
fi

if [ "${TIMEZONE-undefined}" != "undefined" ]; then
    echo $TIMEZONE > /etc/timezone
    dpkg-reconfigure -f noninteractive tzdata
fi

if [ "${CONTAINERROLE-all}" == "all" ]; then
    supervisorctl --serverurl http://localhost:9001 start postgres || exit 1
    dbexists=`su -c "psql -tAc \"SELECT 1 FROM pg_database WHERE datname='docassemble'\"" postgres`
    if [ -z "$dbexists" ]; then
	echo "drop database if exists docassemble; drop role if exists \"www-data\"; create role \"www-data\" login; drop role if exists root; create role root login; create database docassemble owner \"www-data\";" | su -c psql postgres || exit 1
        su -c "source /usr/share/docassemble/local/bin/activate && python -m docassemble.webapp.create_tables $CONFIG_FILE" www-data || exit 1
    fi
else
    python -m docassemble.webapp.create_tables $CONFIG_FILE
fi
python -m docassemble.webapp.install_certs $CONFIG_FILE || exit 1
if [ "${USEHTTPS-false}" == "true" ]; then
    a2enmod ssl
    a2ensite default-ssl
    if [ "${USELETSENCRYPT-false}" == "true" ]; then
	cd /usr/share/docassemble/letsencrypt 
	if [ -f /usr/share/docassemble/using_lets_encrypt ]; then
	    ./letsencrypt-auto renew
	else
	    ./letsencrypt-auto --apache --quiet --email ${LETSENCRYPTEMAIL} --agree-tos -d ${HOSTNAME} && touch /usr/share/docassemble/using_lets_encrypt
	fi
	cd ~-
	/etc/init.d/apache2 stop
    fi
else
    a2dismod ssl
    a2dissite default-ssl
fi

if [ "${LOGSERVER-none}" != "none" ]; then
    supervisorctl --serverurl http://localhost:9001 start syslogng
fi    

supervisorctl --serverurl http://localhost:9001 start apache2

sleep infinity &
wait %1
