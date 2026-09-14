# PocketBase Admin Access via Leaked Credentials

## OWASP Category

[A06:2025 - Insecure Design](https://top10.owasp.org/2025/A06_2025-Insecure_Design/) (CWE-256, unprotected storage of credentials, is mapped to this category)

## References

- [OWASP Cheat Sheet - Password Storage](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)

## Summary

The PocketBase database of the website listens on port `8090` with its admin API open. We know about its existence because it is leaked through header: `x-pocketbase: http://localhost:8090`. Its superuser credentials are stored in plaintext in `/internal/config`, which `xxe_to_ssrf` leaks: email `admin@42network.local`, password `Darkly42Admin!`. Logging in as the database admin gives full control over the database.

## Proof of Concept

`exploit.sh` first runs the `xxe_to_ssrf` exploit to get the admin email and password, then logs into `http://localhost:8090/api/admins/auth-with-password` and uses the returned token to read the `internal_audit` collection, which answers 403 without the token and contains the flag.

```
POST /api/admins/auth-with-password (leaked creds)      -> 200 + admin token
GET  /api/collections/internal_audit/records (no token) -> 403
GET  /api/collections/internal_audit/records (token)    -> records with FLAG{th3_und3rsc0r3_sl4sh_kn0ws_th3_w4y}
```

## Impact

The attacker becomes the database superuser: every collection is readable and writable (`users`, `posts`, `comments`, `projects`, `grades`, `newsletter`, `agenda_imports`, `internal_audit`), so accounts can be modified, grades changed and data destroyed. This happens due to the database credentials being stored in plaintext in a file that the webserver can be tricked into serving.

## Remediation

Do not store database credentials in files that the application can serve (`/internal/config`), rotate them after any suspected leak, and keep the PocketBase admin API on an internal interface that is never exposed next to the website. Use a strong generated password instead of a human-readable one.
