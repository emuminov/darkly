# Open Redirect via /redirect?next=

## OWASP Category

[A01:2025 - Broken Access Control](https://top10.owasp.org/2025/A01_2025-Broken_Access_Control/)

## References

- [OWASP Cheat Sheet - Unvalidated Redirects and Forwards](https://cheatsheetseries.owasp.org/cheatsheets/Unvalidated_Redirects_and_Forwards_Cheat_Sheet.html)

## Summary

The `/redirect` endpoint takes a `next` parameter and redirects the user to whatever URL is placed there. The value is not validated in any way: absolute URLs to any external website are accepted, and the endpoint does not even require a login.

## Proof of Concept

`exploit.sh` requests `/redirect?next=https://evil.example.com` and checks that the response is a `307` redirect whose `Location` is exactly the attacker's URL.

```
/redirect?next=https://evil.example.com            -> 307 https://evil.example.com
/redirect?next=https://anything.example.net/path   -> 307 https://anything.example.net/path
/redirect?next=/login                              -> 307 /login
```

## Impact

Open redirects are mainly used for phishing: the victim sees a link that begins with the trusted website, and does not notice the jump to a page controlled by the attacker. It can also leak sensitive data if the application ever appends tokens or parameters to the redirect URL. This happens due to the endpoint using the raw client-supplied `next` value as the redirect target, without checking that it is a relative path inside the website.

## Remediation

Do not redirect to absolute URLs from user input. Validate that `next` is a relative path (no scheme, no `//`), or check it against an allowlist of known destinations, and fall back to `/` when the value is missing or invalid.

Example: allow `next` to be something like `/me/profile` or `/forum`, never full absolute link.
