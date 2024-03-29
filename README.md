Rundeck
=======

## What is Rundeck?

RunDeck is cross-platform open source software that helps you automate ad-hoc and routine procedures in data center or cloud environments. RunDeck allows you to run tasks on any number of nodes from a web-based or command-line interface. RunDeck also includes other features that make it easy to scale up your scripting efforts including: access control, workflow building, scheduling, logging, and integration with external sources for node and option data.

This repository contains the source for the [Rundeck](http://rundeck.org/) [docker](https://docker.io) image.

# Image details

1. Based on debian:stretch
1. Supervisor, MariaDB, and rundeck
1. It can take anywhere from 30 seconds to a few minutes for Rundeck to start depending on the available resources for the container (and host VM).
1. No SSH.  Use docker exec or [nsenter](https://github.com/jpetazzo/nsenter)
1. If RUNDECK_PASSWORD is not supplied, it will be randomly generated and shown via stdout.
1. Supply the EXTERNAL_SERVER_URL or it will default to https://0.0.0.0:4443
1. As always, update passwords for pre-installed accounts
1. I sometimes get connection reset by peer errors when building the Docker image from the Rundeck download URL.  Trying again usually works.

## How to use

### Clone the repo

```
git clone https://github.com/I12crash/co-rundeck
```

Make sure you change your current folder to Rundeck's project folder

### Build your Rundeck image

```
./build.sh
```

### Create your new rundeck container

```
sudo docker run -p 4440:4440 -e EXTERNAL_SERVER_URL=http://MY.HOSTNAME.COM:4440 --name rundeck -t co-rundeck:latest
```

# SSL
Start a new container, bind to host's port 4443, and enable SSL.   Note: Make sure to update /etc/rundeck/ssl/keystore and /etc/rundeck/ssl/truststore for Production systems as the default certificate is self-signed. Set KEYSTORE_PASS & TRUSTSTORE_PASS to the passwords of those files. Both files can be volume mounted.
```
sudo docker run -p 4443:4443 -e EXTERNAL_SERVER_URL=https://MY.HOSTNAME.COM:4443 -e RUNDECK_WITH_SSL=true --name rundeck -t co-rundeck:latest
```

# Rundeck plugins
To add (external) plugins, add the jars to the /opt/rundeck-plugins volume and they will be copied over to Rundeck's libext directory at container startup

# Docker secrets
Reference: https://docs.docker.com/engine/swarm/secrets/
The entrypoint run script will check for docker secrets set for RUNDECK_ADMIN_PASSWORD, RUNDECK_PASSWORD, DATABASE_ADMIN_PASSWORD, KEYSTORE_PASS, and TRUSTSTORE_PASS.  If the secret has not been set, it will then check for the environment variable and finally default to generating a random value.

# Environment variables

```
SERVER_URL (deprecated - Use EXTERNAL_SERVER_URL) - Full URL in the form http://MY.HOSTNAME.COM:4440, http//123.456.789.012:4440, etc

EXTERNAL_SERVER_URL - Use this if you are running rundeck behind a proxy.  This is useful if you run rundeck through some kind of external network gateway/load balancer.  Note that utilities like rd-jobs and rd-projects will no longer work and you will need to use the newer [rd](https://github.com/rundeck/rundeck-cli) command line utility.

RDECK_JVM_SETTINGS - Additional parameters sent to the rundeck JVM (ex: -Xmx1024m -Xms256m -XX:MaxMetaspaceSize=256m -server -Dfile.encoding=UTF-8 -Dserver.web.context=/rundeck)

DATABASE_URL - For use with (container) external database (ex: jdbc:mysql://<HOSTNAME>:<PORT>/rundeckdb?autoReconnect=true)

RUNDECK_UID - The unix user ID to be used for the rundeck account when rundeck is booted.  This is useful for embedding this docker container into your development environment sharing files via docker volumes between the container and your host OS.  RUNDECK_GID also needs to be defined for this overload to take place.

RUNDECK_GID - The unix group ID to be used for the rundeck account when rundeck is booted.  This is useful for embedding this docker container into your development environment sharing files via docker volumes between the container and your host OS.  RUNDECK_UID also needs to be defined for this overload to take place.

RUNDECK_WITH_SSL - Enable SSL

RUNDECK_PASSWORD - MySQL 'rundeck' user password

RUNDECK_ADMIN_PASSWORD - The rundeck server admin password

RUNDECK_STORAGE_PROVIDER - Options file (default) or db.  See: http://rundeck.org/docs/plugins-user-guide/configuring.html#storage-plugins

RUNDECK_PROJECT_STORAGE_TYPE - Options file (default) or db.  See: http://rundeck.org/docs/administration/setting-up-an-rdb-datasource.html

GUI_BRAND_HTML - HTML to show as title in app header. See: http://rundeck.org/docs/administration/gui-customization.html. Useful to show Rundeck environment where multiple Rundeck instances are deployed, e.g. GUI_BRAND_HTML='<span class="title">QA Environment</span>'

SMTP_HOST - The SMTP server host to use for email notifications.

SMTP_PORT - THe SMTP server port to use for email notifications.

SMTP_USERNAME - The SMTP server username to use for email notifications if authentication is required.

SMTP_PASSWORD - The SMTP server password to use for email notifications if authentication is required

SMTP_DEFAULT_FROM - The from address to use for email notifications.

NO_LOCAL_MYSQL - false (default).  Set to true if using an external MySQL container or instance.  Make sure to set DATABASE_URL and RUNDECK_PASSWORD (used for JDBC connection to MySQL).  Further details for setting up MYSQL: http://rundeck.org/docs/administration/setting-up-an-rdb-datasource.html

LOGIN_MODULE - RDpropertyfilelogin(default) or ldap. See: http://rundeck.org/docs/administration/authenticating-users.html

JAAS_CONF_FILE - ldap configuration file name if ldap. You will need to mount the same file at /etc/rundeck/<filename of ldap>. See: http://rundeck.org/docs/administration/authenticating-users.html

SKIP_DATABASE_SETUP - Set to true if database is already setup and/or database admin password is not known
```

# Volumes

```
/etc/rundeck
/var/rundeck
/var/lib/rundeck - Not recommended to use as a volume as it contains webapp.  For SSH key you can use the this volume: /var/lib/rundeck/.ssh
/var/lib/mysql
/var/log/rundeck
/opt/rundeck-plugins - For adding external plugins
/var/lib/rundeck/logs
/var/lib/rundeck/var/storage
```

# Working behind a web proxy
If you are running Rundeck behind a web proxy, use the following:
```
sudo docker run -p 4440:4440 \
  -e EXTERNAL_SERVER_URL=http://MY.HOSTNAME.COM:4440 \
  -e HTTP_PROXY="http://WEBPROXY:PORT" \
  -e HTTPS_PROXY="http://WEBPROXY:PORT" \
  -e RDECK_JVM_SETTINGS="-Djava.net.useSystemProxies=true" \
  --name rundeck -t jordan/rundeck:latest
```
# External database instances
The container starts it's own MySQL/MariaDB instance by default.  If you prefer to use an external database, you must set the following environment variables
```
SKIP_DATABASE_SETUP=true
DATABASE_URL=<MYSQL_OR_POSTGRES_JDBC_URL>
DATABASE_ADMIN_USER=<DATABASE_ADMIN_USER>
DATABASE_ADMIN_PASSWORD=<DATABASE_ADMIN_PASSWORD>
```

# Using an SSL Terminated Proxy
See: http://rundeck.org/docs/administration/configuring-ssl.html#using-an-ssl-terminated-proxy

# Upgrading
See: http://rundeck.org/docs/upgrading/index.html

# Default credentials
admin/admin
