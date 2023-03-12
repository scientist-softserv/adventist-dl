# Hyku, the Hydra-in-a-Box Repository Application

Code:
[![Build Status](https://circleci.com/gh/samvera/hyku.svg?style=svg)](https://circleci.com/gh/samvera/hyku)
[![Coverage Status](https://coveralls.io/repos/samvera/hyku/badge.svg?branch=master&service=github)](https://coveralls.io/github/samvera/hyku?branch=master)
[![Stories in Ready](https://img.shields.io/waffle/label/samvera/hyku/ready.svg)](https://waffle.io/samvera/hyku)

Docs:
[![Documentation](http://img.shields.io/badge/DOCUMENTATION-wiki-blue.svg)](https://github.com/samvera/hyku/wiki)
[![Contribution Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./CONTRIBUTING.md)
[![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)

Jump In: [![Slack Status](http://slack.samvera.org/badge.svg)](http://slack.samvera.org/)

----
## Table of Contents

  * [Running the stack](#running-the-stack)
    * [For development](#for-development)
    * [For testing](#for-testing)
    * [On AWS](#on-aws)
    * [With Docker](#with-docker)
    * [With Vagrant](#with-vagrant)
    * [With Kubernetes](#with-kubernetes)
  * [Universal Viewer Manifest](#universal-viewer-manifest)
  * [New Tenants](#new-tenants)
  * [Single Tenant Mode](#single-tenancy)
  * [Switching accounts](#switching-accounts)
  * [Development dependencies](#development-dependencies)
    * [Postgres](#postgres)
  * [Importing](#importing)
    * [Enable Bulkrax](#enable-bulkrax)
    * [from CSV](#from-csv)
    * [from purl](#from-purl)
  * [Compatibility](#compatibility)
  * [Product Owner](#product-owner)
  * [Help](#help)
  * [Acknowledgments](#acknowledgments)

----

## Running the stack

### For development / testing with Docker

#### Dory

On OS X or Linux we recommend running [Dory](https://github.com/FreedomBen/dory). It acts as a proxy allowing you to access domains locally such as hyku.test or tenant.hyku.test, making multitenant development more straightforward and prevents the need to bind ports locally. Be sure to [adjust your ~/.dory.yml file to support the .test tld](https://github.com/FreedomBen/dory#config-file).  You can still run in development via docker with out Dory. To do so, copy `docker-compose.override-nodory.yml` to `docker-compose.override.yml` before starting doing docker-compose up.  You can then see the application at the loopback domain 'lvh.me:3000'.

```bash
gem install dory
dory up
```

#### Basic steps

```bash
docker-compose up web
```

This command starts the whole stack in individual containers allowing Rails to be started or stopped independent of the other services.  Once that starts (you'll see the line `Passenger core running in multi-application mode.` to indicate a successful boot), you can view your app in a web browser with at either hyku.test or localhost:3000 (see above).  When done `docker-compose stop` shuts down everything.

#### Tests in Docker

The full spec suite can be run in docker locally. There are several ways to do this, but one way is to run the following:

```bash
docker-compose exec web rake
```

### With out Docker

Please note that this is unused by most contributors at this point and will likely become unsupported in a future release of Hyku unless someone in the community steps up to maintain it.

#### For development

```bash
solr_wrapper
fcrepo_wrapper
postgres -D ./db/postgres
redis-server /usr/local/etc/redis.conf
bin/setup
DISABLE_REDIS_CLUSTER=true bundle exec sidekiq
DISABLE_REDIS_CLUSTER=true bundle exec rails server -b 0.0.0.0
```
#### For testing

See the [Hyku Development Guide](https://github.com/samvera/hyku/wiki/Hyku-Development-Guide) for how to run tests.

### Working with Translations

You can log all of the I18n lookups to the Rails logger by setting the I18N_DEBUG environment variable to true. This will add a lot of chatter to the Rails logger (but can be very helpful to zero in on what I18n key you should or could use).

```console
$ I18N_DEBUG=true bin/rails server
```

### On AWS

AWS CloudFormation templates for the Hyku stack are available in a separate repository:

https://github.com/hybox/aws

### With Docker

We distribute two `docker-compose.yml` configuration files.  The first is set up for development / running the specs. The other, `docker-compose.production.yml` is for running the Hyku stack in a production setting. . Once you have [docker](https://docker.com) installed and running, launch the stack using e.g.:

```bash
docker-compose up -d web
```

Note: You may need to add your user to the "docker" group.

```sudo gpasswd -a $USER docker
newgrp docker
```

### With Vagrant

The [samvera-vagrant project](https://github.com/samvera-labs/samvera-vagrant) provides another simple way to get started "kicking the tires" of Hyku (and [Hyrax](http://hyr.ax/)), making it easy and quick to spin up Hyku. (Note that this is not for production or production-like installations.) It requires [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/).

### With Kubernetes

Hyku relies on the helm charts provided by Hyrax. See [Deployment Info](https://github.com/samvera/hyrax/blob/main/CONTAINERS.md#deploying-to-production) for more information. We also provide a basic helm [deployment script](bin/helm_deploy). Hyku currently needs some additional volumes and ENV vars over the base Hyrax. See (ops/review-deploy.tmpl.yaml) for an example of what that might look like.

## New Tenants
New tenants on the Dev or Production servers will need to be assigned an ingress as well an SSL cert manually before the tenant is created. Software Services does not have access to the DNS servers, so a wildcard cert is not possible. Before a tenant is created, a developer will need to add the domain to the dev-deploy.tmpl.yaml or production-deploy.tmpl.yaml under the ingress.host field && ingress.tls.hosts field.

## Single Tenant Mode

Much of the default configuration in Hyku is set up to use multi-tenant mode.  This default mode allows Hyku users to run the equivielent of multiple Hyrax installs on a single set of resources. However, sometimes the subdomain splitting multi-headed complexity is simply not needed.  If this is the case, then single tenant mode is for you.  Single tenant mode will not show the tenant sign up page, or any of the tenant management screens. Instead it shows a single Samvera instance at what ever domain is pointed at the application.

To enable single tenant, in your settings.yml file change multitenancy/enabled to `false` or set `SETTINGS__MULTITENANCY__ENABLED=false` in your `docker-compose.yml` and `docker-compose.production.yml` configs. After changinig this setting, run `rails db:seed` to prepopulate the single tenant.

In single tenant mode, both the application root (eg. localhost, or hyku.test) and the tenant url single.* (eg. single.hyku.test) will load the tenant. Override the root host by setting multitenancy/root_host in settings.yml or `SETTINGS__MULTITENANCY__ROOT_HOST`.

To change from single- to multi-tenant mode, change the multitenancy/enabled flag to true and restart the application. Change the 'single' tenant account cname in the Accounts edit interface to the correct hostname.

## Switching accounts
There are three recommend ways to switch your current session from one account to another by using:
```ruby
switch!(Account.first)
# or
switch!('my.site.com')
# or
switch!('myaccount')
```

## Development Dependencies

### Postgres

Hyku supports multitenancy using the `apartment` gem. `apartment` works best with a postgres database.

## Importing
### Enable Bulkrax:

- Set bulkrax -> enabled to true in the [config/settings.yml](config/settings.yml) and [.env](.env) files
- Add `  require bulkrax/application` to app/assets/javascripts/application.js and app/assets/stylesheets/application.css files.

(in a `docker-compose exec web bash` if you're doing docker otherwise in your terminal)
```bash
bundle exec rails db:migrate
```

### from CSV:

```bash
./bin/import_from_csv localhost spec/fixtures/csv/gse_metadata.csv ../hyku-objects
```

### from purl:

```bash
./bin/import_from_purl ../hyku-objects bc390xk2647 bc402fk6835 bc483gc9313
```

## Compatibility

* Ruby 2.7+ is recommended.  Later versions may also work.
* Rails 5 is required. We recommend the latest Rails 5.1 release.

### Product Owner

[orangewolf](https://github.com/orangewolf)

## Help

The Samvera community is here to help. Please see our [support guide](./SUPPORT.md).

## Acknowledgments

This software was developed by the Hydra-in-a-Box Project (DPLA, DuraSpace, and Stanford University) under a grant from IMLS.

This software is brought to you by the Samvera community.  Learn more at the
[Samvera website](http://samvera.org/).

![Samvera Logo](https://wiki.duraspace.org/download/thumbnails/87459292/samvera-fall-font2-200w.png?version=1&modificationDate=1498550535816&api=v2)