#!/bin/sh

### update postgresql password using ENV 

set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: update-pg-password.sh NewPassword"
    exit
fi

newPassword=$1
psql -U postgres -c "ALTER USER postgres WITH PASSWORD '"$newPassword"';"

