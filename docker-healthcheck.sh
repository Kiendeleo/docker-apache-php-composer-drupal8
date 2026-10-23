#!/bin/sh
# Volumes often hide /var/www/site and sites-enabled, so the image's
# healthz.txt and vhost may not be the ones running. Drupal also returns
# 400 for Host 127.0.0.1 when trusted_host_patterns does not include it.
# That 400 still means Apache and PHP answered.
code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://127.0.0.1/healthz.txt || true)
if [ "$code" = "200" ]; then
  exit 0
fi
code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://127.0.0.1/ || true)
case "$code" in
  200|301|302|400) exit 0 ;;
  *) exit 1 ;;
esac
