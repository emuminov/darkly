# Darkly Audit Walkthrough

How the 42 Network website was broken into, step by step.

Run everything at once:

    ./hack.sh

It runs 13 exploits in order and prints all captured flags at the end.
The website must run on `http://localhost:4942` and PocketBase on
`http://localhost:8090`.

## Step 0 - Website leaks its own secrets

- `robots.txt` lists hidden paths: `/admin`, `/staff`, `/internal`, `/backup`, `/api/grades`. Visiting them gives various results.
- HTML comments on every page mention internals: the JWT secret, a disabled `defusedxml` library, a removed upload whitelist.
- Every response has the header `x-pocketbase: http://localhost:8090`.

## Step 1 - `idor`

Profile pages have no access control. `/profile/k1asdfeditojrb4` is the profile of the staff user `wil`. Anyone can open it without logging in and read his private note.

Flag: `FLAG{1d0r_ur_pr0f1l3_1s_m1n3}`

## Step 2 - `open_redirect`

`/redirect?next=<url>` sends the visitor to any website. A link that starts on the trusted site can be used for phishing. No flag.

## Step 3 - `reflected_xss`

The newsletter subscription page (`POST /newsletter`) puts the `email` parameter into the success message without escaping it. A `<script>` tag sent as the email runs in the browser of anyone who opens the crafted link. No login needed. No flag.

## Step 4 - `no_brute_force_protection`

The `POST /login` endpoint has no rate limiting and no lockout. A dictionary of the 10000 worst passwords finds the password of `jdoe` (`123456`). The site also accepts weak passwords: the only rule is 5 characters minimum. No flag.

## Step 5 - `predictable_password_reset`

The reset token is `md5(email)`. Anyone who knows the email of a student can compute the token and set a new password via `POST /reset-password/confirm`. Staff accounts are protected. We reset the password of `benjamin@student.42.tech`, log in as him, and his `/profile/me/settings` page shows his recovery code.

Flag: `FLAG{r3s3t_t0k3n_w4s_just_md5_lol}`

## Step 6 - `broken_access_control_api`

`/api/grades` returns our own grades with a hidden `flag` field that the website never shows. It also accepts `?student=<id>` without a check, so we can read the grades of any student.

Flag: `FLAG{md5_1s_4_n4m3pl4t3_n0t_4_l0ck}`

## Step 7 - `mass_assignment`

`PATCH /api/profile` accepts a `role` field. We send `{"role":"cadet"}` and become staff. The `/staff/dashboard` page opens.

Flag: `FLAG{just_p4tch_y0ur_0wn_r0l3_lol}`

## Step 8 - `stored_xss`

The forum stores post content without cleaning it and the post page (`/forum/{id}`) runs it as HTML. We post a `<script>` that sends the cookies of the reader to `/api/collect`. A moderation bot reads the forum, the script runs in its browser, and we read its session cookie and the flag from `/api/collect`. The session cookie has no `HttpOnly` flag.

Flag: `FLAG{xss_st0r3d_1s_n0t_4_f34tur3_w1l}`

## Step 9 - `path_traversal`

`/projects/download` joins the `file` parameter with a directory without checks. `../private_notes.txt` reads a file outside the projects directory. The `/backup` page tells the file name in the `x-backup-exclude` response header.

Flag: `FLAG{d0t_d0t_sl4sh_4ll_th3_w4y_d0wn}`

## Step 10 - `unrestricted_upload`

The `/upload/avatar` endpoint accepts any file type and keeps the original name. A shell script upload works and the server returns the flag in the redirect (`upload_flag=...`). An uploaded `.html` file is served from `/static/uploads/` as `text/html`. This can be used as an attack vector: for example, store HTML file with malicious script and send it to the victim.

Flag: `FLAG{unr3str1ct3d_upl0ad_g0_brrr}`

## Step 11 - `xxe_to_ssrf`

The `/agenda/import` endpoint parses uploaded XML and allows external entities. We put an entity that points to `/internal/config` in the XML. The server fetches that page itself and puts its content into the agenda it shows us. The page contains the PocketBase admin login, the JWT secret, and a flag. XXE + SSRF + poor secrets management.

Flag: `FLAG{d3fus3dxml_n3xt_spr1nt_pr0m1s3}`

## Step 12 - `leaked_jwt_secret`

Sessions are JWT cookies signed with the secret `42network` from step 11. We build our own token for the user `sophie` with role `god` and the website accepts it on `/admin`. This can be used to hack anyone, and unliked `md5`, everyone can be hacked this way.

Flag: `FLAG{md5_1s_4_n4m3pl4t3_n0t_4_l0ck}` (same string as step 6)

## Step 13 - `pocketbase_admin_access`

The config from step 11 also contains the PocketBase admin email and password. We log into the database on port `8090` (`POST /api/admins/auth-with-password`) and get full access to all collections. The `internal_audit` collection holds the last flag.

Flag: `FLAG{th3_und3rsc0r3_sl4sh_kn0ws_th3_w4y}`

## Summary

9 flags total. The site leaks its own map (`robots.txt`, comments, headers). Some pages check nothing (`idor`, the grades API). Passwords and sessions are weak (brute force, `md5(email)` reset token, `role` patching). Uploaded content is trusted (forum posts, avatars, XML). One XML upload leaks all secrets, and the secrets give full control of the website and the database.

Each step has its own folder with `exploit.sh` and `EXPLANATION.md`.
