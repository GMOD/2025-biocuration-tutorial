#!/usr/bin/env bash

sudo apt update
sudo apt install --yes gnupg curl nano unzip
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
  sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
  --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo apt update
sudo apt install --yes apache2 nodejs mongodb-org


sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_wstunnel
# Add the following to /etc/apache2/sites-available/000-default.conf
# ProxyPass "/config.json" "http://localhost:3999/jbrowse/config.json"
# ProxyPassReverse "/config.json" "http://localhost:3999/jbrowse/config.json"
# ProxyPassMatch "^/apollo/(.*)$" "http://localhost:3999/$1" upgrade=websocket connectiontimeout=3600 timeout=3600
# ProxyPassReverse "/apollo/" "http://localhost:3999/"
sudo service apache2 restart
# Change the following in /etc/mongod.conf
# replication:
#   replSetName: rs0
curl -fsSL https://raw.githubusercontent.com/mongodb/mongo/master/debian/init.d | sudo tee /etc/init.d/mongod
sudo chmod +x /etc/init.d/mongod
service mongod start
# run in mongosh
# rs.initiate()

sudo corepack enable
curl -fsSL https://github.com/GMOD/Apollo3/archive/refs/tags/v0.3.4.tar.gz > apollo.tar.gz
tar xvf apollo.tar.gz
mv Apollo3-*/ Apollo/
cd Apollo/
yarn
cd packages/apollo-collaboration-server/
touch .env
cat << EOF > .env
URL=http://localhost:27655/apollo/
NAME=My Apollo Instance
MONGODB_URI=mongodb://localhost:27017/apolloTestDb?directConnection=true&replicaSet=rs0
FILE_UPLOAD_FOLDER=/home/ubuntu/data/uploads
JWT_SECRET=some-secret-value
SESSION_SECRET=some-other-secret-value
ALLOW_ROOT_USER=true
ROOT_USER_PASSWORD=some-secret-password
ALLOW_GUEST_USER=true
EOF
yarn build
yarn start:prod

cd ~
mkdir jbrowse-web
cd jbrowse-web/
curl -fsSL https://github.com/GMOD/jbrowse-components/releases/download/v3.2.0/jbrowse-web-v3.2.0.zip > jbrowse-web.zip
unzip jbrowse-web.zip
rm jbrowse-web.zip
sudo mv * /var/www/html/
cd ..
rmdir jbrowse-web

curl -fsSL https://registry.npmjs.org/@apollo-annotation/jbrowse-plugin-apollo/-/jbrowse-plugin-apollo-0.3.4.tgz | \
  tar --extract --gzip --file=- --strip=2 package/dist/jbrowse-plugin-apollo.umd.production.min.js
sudo mv jbrowse-plugin-apollo.umd.production.min.js /var/www/html/apollo.js
curl -fsSL https://github.com/The-Sequence-Ontology/SO-Ontologies/raw/refs/heads/master/Ontology_Files/so.json > so.json
sudo mv so.json /var/www/html/sequence_ontology.json
