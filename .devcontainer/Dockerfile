FROM ubuntu:noble
RUN <<EOF
apt-get update
# Set up ubuntu user
apt-get install -y sudo
echo ubuntu ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/ubuntu
EOF

USER ubuntu

RUN <<EOF
set -e
cd ~ || exit 1

# Configure timezone and locale to avoid interactive prompt
sudo ln -s /usr/share/zoneinfo/America/Chicago /etc/localtime
sudo apt-get install -y locales tzdata
sudo sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen
sudo locale-gen

# Install dependencies
sudo apt-get install -y apache2 curl unzip gnupg jq git

# Configure apache
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_wstunnel
cd /etc/apache2/sites-available/ || exit 1
head -n -1 000-default.conf | sudo tee tmp.conf
sudo tee -a tmp.conf <<END
	ProxyPass "/config.json" "http://localhost:3999/jbrowse/config.json"
	ProxyPassReverse "/config.json" "http://localhost:3999/jbrowse/config.json"
	ProxyPassMatch "^/apollo/(.*)$" "http://localhost:3999/\$1" upgrade=websocket connectiontimeout=3600 timeout=3600
	ProxyPassReverse "/apollo/" "http://localhost:3999/"
END
tail -n 1 000-default.conf | sudo tee -a tmp.conf
sudo mv tmp.conf 000-default.conf
cd ~ || exit 1

# Install MongoDB
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
curl -fsSL https://raw.githubusercontent.com/mongodb/mongo/master/debian/init.d | sudo tee /etc/init.d/mongod
sudo chmod +x /etc/init.d/mongod
sudo touch /var/run/mongod.pid
sudo chown mongodb:mongodb /var/run/mongod.pid
sudo tee -a /etc/mongod.conf <<END
replication:
  replSetName: rs0
END
sudo service mongod start
mongosh --eval 'rs.initiate()'

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt-get install -y nodejs

# Install Node.js global packages
sudo corepack enable
yes | yarn global bin
echo 'export PATH="$(yarn global bin):$PATH"' >> ~/.bashrc
PATH="$(yarn global bin):$PATH"
export PATH
yarn global add @apollo-annotation/cli @jbrowse/cli

# Install JBrowse
sudo chown -R "$(whoami)" /var/www/html/
cd /var/www/html/ || exit 1
rm index.html
curl -fsSL https://github.com/GMOD/jbrowse-components/releases/download/v3.2.0/jbrowse-web-v3.2.0.zip > jbrowse-web.zip
unzip jbrowse-web.zip
rm jbrowse-web.zip

# Add Apollo plugin and related files
curl -fsSL https://registry.npmjs.org/@apollo-annotation/jbrowse-plugin-apollo/-/jbrowse-plugin-apollo-0.3.5.tgz | \
  tar --extract --gzip --file=- --strip=2 package/dist/jbrowse-plugin-apollo.umd.production.min.js
mv jbrowse-plugin-apollo.umd.production.min.js apollo.js
cd /var/www/html/ || exit 1
curl -fsSL https://github.com/The-Sequence-Ontology/SO-Ontologies/raw/refs/heads/master/Ontology_Files/so.json > sequence_ontology.json

# Install Apollo server
cd ~ || exit 1
curl -fsSL https://github.com/GMOD/Apollo3/archive/refs/tags/v0.3.5.tar.gz > apollo.tar.gz
tar xvf apollo.tar.gz
rm apollo.tar.gz
mv Apollo3-*/ Apollo/
cd Apollo/ || exit 1
yes | yarn
cd packages/apollo-collaboration-server/ || exit 1
yarn build
cat << END > .env
URL=<forwarded address>/apollo/
NAME=My Apollo Instance
MONGODB_URI=mongodb://localhost:27017/apolloDb?directConnection=true&replicaSet=rs0
FILE_UPLOAD_FOLDER=/home/ubuntu/data/uploads
JWT_SECRET=some-secret-value
SESSION_SECRET=some-other-secret-value
ALLOW_ROOT_USER=true
ROOT_USER_PASSWORD=some-secret-password
ALLOW_GUEST_USER=true
GUEST_USER_ROLE=admin
END
EOF
