# Drupal Composer (Ubuntu 24.04 / Drupal 10)

Ubuntu 24.04 LTS image with Apache, PHP 8.3, Composer 2, and a pinned Drupal 10 recommended-project install.

Drupal 8 and 9 are EOL and are not built from this branch.

## Tags

| Branch / tag | Ubuntu | PHP | Drupal |
|---|---|---|---|
| `24.04` | 24.04 LTS | 8.3 | 10.6.20 |
| `26.04` | 26.04 LTS | 8.5 | 11.4.6 |
| `22.04` | legacy branch, unmaintained | | |

## Run

```bash
docker compose up --build -d
```

Then open http://localhost:8080 and complete the Drupal installer.

Database settings for Compose:

- Host: `db`
- Database: `drupal`
- Username: `drupal`
- Password: value of `MYSQL_PASSWORD` (default `changeme`)

Copy `.env.example` to `.env` and change the passwords before any non-local use.

Single container (you must supply your own database):

```bash
docker build -t kiendeleo/drupalcomposer:24.04 .
docker run -d -p 8080:80 --name drupal10 kiendeleo/drupalcomposer:24.04
```

## Persistence

Compose already persists uploaded files and MariaDB data.

Useful bind mounts if you run the image directly:

- Site files: `/var/www/site/public/web/sites/default/files`
- PHP config: `/etc/php/8.3/`
- Apache vhost: `/etc/apache2/sites-enabled/`

## Logs

`docker logs` shows Apache and PHP. Apache's main error log, which is where `mod_php` writes warnings and fatals, goes to stderr. The access log goes to stdout. `display_errors` stays off, so a visitor does not see the error text. `/var/log/apache2/error.log` inside the container is not used.

Drupal's own watchdog messages still go to the database unless the site enables the core Syslog module.

## php2shell

Apache `mod_php` is the highest-risk SAPI for php2shell (CVE-2026-109618 and CVE-2026-109619). Ubuntu 24.04 backports the fix and `php -v` still prints 8.3.6. The package revision is what matters.

The build refuses to finish unless `libapache2-mod-php8.3` and `php8.3-common` are at least `8.3.6-0ubuntu0.24.04.13` ([USN-8948-1](https://ubuntu.com/security/notices/USN-8948-1)). Rebuild and recreate the container after pulling this change. A container that is already running keeps the old PHP until it is replaced.

There is no configuration workaround that closes both bugs. Updating the packages is the fix.

## What this branch changed

- Pinned Drupal 10.6.20, which includes the 10.6.19 security fixes (SA-CORE-2026-014 and the October 2026 core advisories), instead of whatever Packagist returns at build time
- Fail the image build if the Ubuntu PHP packages are older than the php2shell fix
- Set `zend.assertions = -1` in the PHP drop-in, which Drupal 10.6.20 recommends for production and which cannot be set from `.htaccess`
- Allow Drupal's `.htaccess` to use `Require`, `Options`, and `DirectoryIndex`. `AllowOverride FileInfo` alone makes Apache return 500 for every request
- Send Apache and PHP error logs to stderr, and the access log to stdout, so `docker logs` shows them
- Official Composer image instead of `curl | php`
- Dropped unused packages (`lynx`, `nano`, `git`, `php-fpm`)
- Added `php-intl` and a Drupal PHP drop-in (`display_errors=Off`, `expose_php=Off`)
- Tightened Apache (no directory listing, no 2.2 `Order` syntax, security headers, no PHP in `files/`)
- Application code owned by `root:www-data`; only `sites/default` is writable by the web user
- Healthcheck and Compose stack with MariaDB 11

Put TLS in front of this container (Caddy, Traefik, or a host reverse proxy). The image itself still listens on HTTP port 80.
