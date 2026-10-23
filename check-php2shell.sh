#!/bin/sh
# Compare installed Ubuntu PHP packages with PHP_MIN_PACKAGE.
# php -v stays on the upstream number; the package revision carries the fix.
set -eu

modphp_pkg="libapache2-mod-php${PHP_VERSION}"
common_pkg="php${PHP_VERSION}-common"
modphp_ver=$(dpkg-query -W "$modphp_pkg" | cut -f2)
common_ver=$(dpkg-query -W "$common_pkg" | cut -f2)

if ! dpkg --compare-versions "$modphp_ver" ge "$PHP_MIN_PACKAGE" \
  || ! dpkg --compare-versions "$common_ver" ge "$PHP_MIN_PACKAGE"; then
  echo "PHP is older than ${PHP_MIN_PACKAGE} (php2shell CVE-2026-109618 CVE-2026-109619, USN-8948-1). ${modphp_pkg}=${modphp_ver} ${common_pkg}=${common_ver}" >&2
  exit 1
fi

echo "php2shell check ok: ${modphp_pkg}=${modphp_ver} ${common_pkg}=${common_ver}"
