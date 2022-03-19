#!/bin/sh
set -e

log() {
  echo "[$(date +%Y-%m-%dT%H:%M:%S%:z)] $*"
}


# ------------------------------------------------------------------------------

# disable editing users data from LDAP
if [[ "${TAIGA_ENABLE_LDAP:-False}" =~ "^[Tt][Rr][Uu][Ee]$" || "${ENABLE_LDAP:-False}" =~ "^[Tt][Rr][Uu][Ee]$" ]]; then
  log "Disable update option for fields username, email, full-name."

  temp_file=$(mktemp)

  cat /usr/src/taiga-back/taiga/users/api.py | tr '\n' '\r' | sed -e 's@\r\(\r        new_email = request\.DATA\.pop(.email., None)\)@\r\r        for f in ["username", "email", "full_name"]:\r            if request.DATA.pop(f, None) is not None:\r                return response.NotAcceptable({"detail": _("Error. Changing {} not allowed.".format(f))})\r        # deny check against changing ldap values success\1@' | tr '\r' '\n' > $temp_file

  cat $temp_file > /usr/src/taiga-back/taiga/users/api.py

  rm $temp_file
fi
