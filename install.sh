#!/bin/bash
if [ -z "$1" ]
then
    echo -e "Instance name is missing. Try to run:\n $0 newmagento2";
    exit;
fi

echo "Reading config..." >&2
source conf.cfg;


MAGENTO_SOURCE_CODE="source/$1"


if [ ! -d "$MAGENTO_SOURCE_CODE" ]; then
    echo "Downloading Magento $1 ..."
    
    if [ ! -d "source" ]; then
        mkdir source
    fi

    if [ ! -f "~/.config/composer/auth.json" ]; then
        # Copy the source file to the destination directory
        cp auth.json ~/.config/composer/auth.json
        echo "Copy auth.json to ~/.config/composer/auth.json"
    fi

    cd source
    composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition $1 $1
    cd ..
fi


VERSION_WITHOUT_DOTS=$(echo "$1" | tr -d '.')
VERSION_WITHOUT_DOTS=$(echo "$VERSION_WITHOUT_DOTS" | tr -d '-')

DB_NAME="m2_${VERSION_WITHOUT_DOTS}";

echo "${WWW_DIR}/${DB_NAME}-root"

if [ -d "${WWW_DIR}/${DB_NAME}-root" ]; then
    DB_NAME="m2_${VERSION_WITHOUT_DOTS}v"
    if [ -d "${WWW_DIR}/${DB_NAME}2-root" ]; then
        version_suffix=3
        while [ -d "${WWW_DIR}/${DB_NAME}${version_suffix}-root" ]; do
            ((version_suffix++))
        done

        DB_NAME="m2_${VERSION_WITHOUT_DOTS}v${version_suffix}"
    else
        DB_NAME="m2_${VERSION_WITHOUT_DOTS}v2"
    fi  
fi


echo "Creating Magento 2 web directory (${WWW_DIR}/${DB_NAME})..." >&2
mkdir ${WWW_DIR}/${DB_NAME}-root;
echo "Copying Magento 2 files..." >&2
cp -r $MAGENTO_SOURCE_CODE/* ${WWW_DIR}/${DB_NAME}-root

cp auth.json ${WWW_DIR}/${DB_NAME}-root/auth.json

echo "Creating new database..." >&2
echo ${DB_NAME}
echo "create database ${DB_NAME}" | mysql -u $DB_USER -p$DB_PASSWORD


echo "Installing Magento 2..." >&2
#php ${WWW_DIR}/${DB_NAME}-root/bin/magento setup:install --admin-firstname=root --admin-lastname=root --admin-email=root@test.com --admin-user=root --admin-password=root123 --db-password=$DB_PASSWORD --db-host=localhost --db-name=${DB_NAME} --db-user=$DB_USER --base-url="http://127.0.0.1/${DB_NAME}/" --backend-frontname=admin --db-prefix=mym2 --elasticsearch-host=127.0.0.1
php ${WWW_DIR}/${DB_NAME}-root/bin/magento setup:install --admin-firstname=root --admin-lastname=root --admin-email=root@test.com --admin-user=root --admin-password=root123 --db-password=$DB_PASSWORD --db-host=localhost --db-name=${DB_NAME} --db-user=$DB_USER --base-url="http://127.0.0.1/${DB_NAME}/" --backend-frontname=admin 

ln -s ${WWW_DIR}/${DB_NAME}-root/pub/ ${WWW_DIR}/${DB_NAME}


php ${WWW_DIR}/${DB_NAME}-root/bin/magento sampledata:deploy
php ${WWW_DIR}/${DB_NAME}-root/bin/magento setup:upgrade
php ${WWW_DIR}/${DB_NAME}-root/bin/magento deploy:mode:set developer

echo "Done" >&2
exit
