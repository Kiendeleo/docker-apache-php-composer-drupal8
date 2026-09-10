# Drupal Composer (Ubuntu 24.04 / Drupal 10)

Ubuntu 24.04 LTS image with Apache, PHP 8.3, Composer 2, and a pinned Drupal 10 recommended-project install.

Drupal 8 and 9 are EOL and are not built from this branch.

## Tags

| Branch / tag | Ubuntu | PHP | Drupal |
|---|---|---|---|
| `24.04` | 24.04 LTS | 8.3 | 10.6.16 |
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

## What this branch changed

- Pinned Drupal 10.6.16 instead of whatever Packagist returns at build time
- Official Composer image instead of `curl | php`
- Dropped unused packages (`lynx`, `nano`, `git`, `php-fpm`)
- Added `php-intl` and a Drupal PHP drop-in (`display_errors=Off`, `expose_php=Off`)
- Tightened Apache (no directory listing, no 2.2 `Order` syntax, security headers, no PHP in `files/`)
- Application code owned by `root:www-data`; only `sites/default` is writable by the web user
- Healthcheck and Compose stack with MariaDB 11

Put TLS in front of this container (Caddy, Traefik, or a host reverse proxy). The image itself still listens on HTTP port 80.
