# Setting up Apollo

A full installation of Apollo involves four components:

- JBrowse
- The Apollo JBrowse plugin
- The Apollo Collaboration Server
- A database

You can read more about these components
[in the Apollo docs](https://apollo.jbrowse.org/docs/getting-started/deployment/background).

## Set up JBrowse

Before installing anything, just to make sure the repositories are up to date,
run

```sh
sudo apt update
```

Now install the tools we need by running

```sh
sudo apt install -y apache2 curl unzip
```

This installs:

- apache2, which is the web server we'll use to server JBrowse
- curl, for fetching the JBrowse installation files from the web
- unzip, for decompressing the JBrowse installation files

By default, apache2 serves files located in the `/var/www/html` directory. Let's
prepare the JBrowse installation files and move them to that directory.

```sh
mkdir jbrowse-web
cd jbrowse-web/
curl -fsSL https://github.com/GMOD/jbrowse-components/releases/download/v3.2.0/jbrowse-web-v3.2.0.zip > jbrowse-web.zip
unzip jbrowse-web.zip
rm jbrowse-web.zip
sudo mv * /var/www/html/
cd ..
rmdir jbrowse-web
```

Now open <http://localhost:27655> in your browser. You should see the JBrowse
setup screen.

## Set up Apollo JBrowse plugin

To add the Apollo plugin, we'll first fetch the plugin source file and place it
in a file called `apollo.js` in the directory with the other JBrowse files.

```sh
curl -fsSL https://registry.npmjs.org/@apollo-annotation/jbrowse-plugin-apollo/-/jbrowse-plugin-apollo-0.3.4.tgz | \
  tar --extract --gzip --file=- --strip=2 package/dist/jbrowse-plugin-apollo.umd.production.min.js
sudo mv jbrowse-plugin-apollo.umd.production.min.js /var/www/html/apollo.js
```

In order to test that this worked, we'll need to create a temporary JBrowse
config file. We'll use the text editor `nano` in this tutorial, but feel free to
use whatever text editor you like.

First install `nano` and use it to open a file

```sh
sudo apt install -y nano
nano config.json
```

That will open the `nano` editor. Paste or type the following into the file:

```json
{
  "plugins": [
    {
      "name": "Apollo",
      "url": "apollo.js"
    }
  ]
}
```

To save the file, press <kbd>Ctrl</kbd> + <kbd>O</kbd> and then
<kbd>Enter</kbd>, and to exit `nano`, press <kbd>Ctrl</kbd> + <kbd>X</kbd> and
then <kbd>Enter</kbd>.

Now move the `config.json` file to where it needs to go:

```sh
sudo mv config.json /var/www/html/
```

Open up JBrowse you should see an "Apollo" menu at the top. You can use some
basic Apollo functionality like editing annotations small local GFF3 files with
just the plugin, but to enable the full functionality of Apollo we'll need to
add the last two components. Delete the `config.json` for now, as we won't need
it anymore.

```sh
sudo rm config.json
```

## Set up the database

Apollo uses MongoDB to store its data. In this example we'll set up MongoDB
running on the same server as everything else, but it could just as easily be an
externally managed database.

These installation instructions for MongoDB are based on
[the installation instructions](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/)
in the MongoDB documentation.

MongoDB is not available for `apt` to install by default, so we'll need to do
some configuration to enable that. First we'll need to install `gnupg` and use
it to import the MongoDB public key.

```sh
sudo apt install -y gnupg
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
```

Now we can configure `apt` to be able to find MongoDB

```sh
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo apt update
```

And now install MongoDB

```sh
sudo apt install -y mongodb-org
```

Apollo requires MongoDB to be configured in a replica set configuration. You can
have multiple replicas of your database, but in this example we'll use a single
one.

Using `nano` or another text editor, edit the file `/etc/mongod.conf` (e.g.
`sudo nano /etc/mongod.conf`). In the file where it says `# replication`, change
it to

```conf
replication:
  replSetName: rs0
```

In this next part we need to fix what appears to be a bug in the installation of
MongoDB on Ubuntu. The service file for MongoDB doesn't get added, so we need to
download it.

```sh
curl -fsSL https://raw.githubusercontent.com/mongodb/mongo/master/debian/init.d | sudo tee /etc/init.d/mongod
sudo chmod +x /etc/init.d/mongod
```

Now we can start MongoDB by running

```sh
sudo service mongod start
```

The last step is to initialize the replica set. To do this, run the command
`mongosh` and in the shell that appears, run the command

```js
rs.initiate()
```

Then press <kbd>Ctrl</kbd> + <kbd>D</kbd> to exit.

## Set up Apollo Collaboration Server

The first step in setting up the collaboration server is to furthe configure the
apache2 server we installed when setting up JBrowse. We're going to use apache2
as a "gateway" (a.k.a. "forward and reverse proxy") server. This is so that the
same server can handle requests for the JBrowse static files and forward
requests for the Apollo Collaboration Server to our running server process
(which we will set up shortly). It does this by inspecting the request and if
the path starts with `apollo/` or is for `config.json`, it forwards the request
to the Apollo Collaboration Server, otherwise it handles the request as a static
file server.

To set this up, we first need to enable some mods on our apache2 server.

```sh
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_wstunnel
```

Using `nano` or another text editor, edit the file
`/etc/apache2/sites-available/000-default.conf` (e.g.
`/etc/apache2/sites-available/000-default.conf`). Add these lines near the
bottom of the file, above the `</VirtualHost>` line.

```txt
  ProxyPass "/config.json" "http://localhost:3999/jbrowse/config.json"
  ProxyPassReverse "/config.json" "http://localhost:3999/jbrowse/config.json"
  ProxyPassMatch "^/apollo/(.*)$" "http://localhost:3999/$1" upgrade=websocket connectiontimeout=3600 timeout=3600
  ProxyPassReverse "/apollo/" "http://localhost:3999/"
```

Now we need to restart the apache2 server.

```sh
sudo service apache2 restart
```

The next thing we need to do is add a file that defines feature types for
Apollo. This is usally the Sequence Ontology.

```sh
curl -fsSL https://github.com/The-Sequence-Ontology/SO-Ontologies/raw/refs/heads/master/Ontology_Files/so.json > so.json
sudo mv so.json /var/www/html/sequence_ontology.json
```

Now we need to install Node.js on the server. The default Node.js available via
`apt` can have some problems, so we'll configure `apt` to install a different
version.

```sh
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt update
sudo apt install -y nodejs
```

Now we'll fetch the Apollo installation files.

```sh
curl -fsSL https://github.com/GMOD/Apollo3/archive/refs/tags/v0.3.4.tar.gz > apollo.tar.gz
tar xvf apollo.tar.gz
mv Apollo3-*/ Apollo/
```

To install Apollo, we'll need the tool `yarn`, which can be enabled through
Node.js by running

```sh
sudo corepack enable
```

Then install Apollo by running

```sh
cd Apollo/
yarn
cd packages/apollo-collaboration-server/
yarn build
```

Now that Apollo is installed, we need to configure it before starting it. We can
do that by adding a file called `.env` in the
`packages/apollo-collaboration-server/` directory (e.g. by using `nano`) and
adding these contents to that file.

```env
URL=http://localhost:27655/apollo/
NAME=My Apollo Instance
MONGODB_URI=mongodb://localhost:27017/apolloTestDb?directConnection=true&replicaSet=rs0
FILE_UPLOAD_FOLDER=/home/ubuntu/data/uploads
JWT_SECRET=some-secret-value
SESSION_SECRET=some-other-secret-value
ALLOW_ROOT_USER=true
ROOT_USER_PASSWORD=some-secret-password
ALLOW_GUEST_USER=true
```

You can find more configuration options in the
[Apollo docs](https://apollo.jbrowse.org/docs/getting-started/deployment/configuration-options).

Now we can start Apollo by running

```sh
yarn start:prod
```

Open <http://localhost:27655> in your browser. Congratulations, Apollo is now
ready to use!
