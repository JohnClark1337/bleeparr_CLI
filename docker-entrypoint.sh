#!/bin/sh
set -eu

CACHE_ROOT="${HOME}/.cache"
if [ -d "$CACHE_ROOT" ] && [ ! -w "$CACHE_ROOT" ]; then
  printf 'ERROR: %s is not writable by uid %s inside the container.\n' "$CACHE_ROOT" "$(id -u)" >&2
  printf 'Fix on the host: sudo chown -R $(id -u):$(id -g) <host dir bound to that path>\n' >&2
  exit 1
fi

if [ "${1:-}" = "bleeparr" ]; then
  shift
fi

case "${1:-}" in
  models)
    shift
    exec python /app/fetch_models.py "$@"
    ;;
  bash|sh)
    shift
    exec "$@"
    ;;
esac

exec python /app/bleeparr.py "$@"