#!/bin/bash
# Based on script created by camilb's (github.com/camilb)  
# Source: https://github.com/camilb/kube-mysqldump-cron/blob/master/Docker/dump.sh

# DB_USER=${DB_USER:-${MYSQL_ENV_DB_USER}}
# DB_PASS=${DB_PASS:-${MYSQL_ENV_DB_PASS}}
# DB_NAME=${DB_NAME:-${MYSQL_ENV_DB_NAME}}
# DB_HOST=${DB_HOST:-${MYSQL_ENV_DB_HOST}}
ALL_DATABASES=false
IGNORE_DATABASE=${IGNORE_DATABASE}
GS_STORAGE_BUCKET=kube-mysql-dump-bucket
DB_USER=hcl
DB_PASS=hcl
DB_NAME=hcldemo
DB_HOST=mysqlservice

VAR_2=$(date +%s) #unix time
VAR_date_time=$(date +%Y-%d-%b-%H:%M:%S)
echo "Echo Date - "$VAR_date_time;

if [[ ${DB_USER} == "" ]]; then
	echo "Missing DB_USER env variable"
	exit 1
fi
if [[ ${DB_PASS} == "" ]]; then
	echo "Missing DB_PASS env variable"
	exit 1
fi
if [[ ${DB_HOST} == "" ]]; then
	echo "Missing DB_HOST env variable"
	exit 1
fi

if [[ ${GS_STORAGE_BUCKET} == "" ]]; then
    echo "Missing GS_BUCKET env variable"
    exit 1
fi

if [[ ${ALL_DATABASES} == "" ]]; then
	if [[ ${DB_NAME} == "" ]]; then
		echo "Missing DB_NAME env variable"
		exit 1
	fi
	mysqldump --user="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" "$@" "${DB_NAME}" > "${DB_NAME}"-$VAR_date_time.sql
    gcloud auth activate-service-account --key-file /root/service_key.json 
	gsutil cp "${DB_NAME}"-$VAR_date_time.sql gs://$GS_STORAGE_BUCKET
else
	databases=`mysql --user="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`
for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "$IGNORE_DATABASE" ]]; then
        echo "Dumping database: $db"
        mysqldump --user="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" --databases $db > $db-$VAR_date_time.sql
        gcloud auth activate-service-account --key-file /root/service_key.json 
		gsutil cp "${DB_NAME}"-$VAR_date_time.sql gs://$GS_STORAGE_BUCKET
    fi
done
fi