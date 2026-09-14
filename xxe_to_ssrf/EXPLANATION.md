# XXE to SSRF in Agenda Import

## OWASP Category

[A01:2025 - Broken Access Control](https://top10.owasp.org/2025/A01_2025-Broken_Access_Control/) (SSRF was rolled into this category in the 2025 edition; the XXE vector itself falls under [A02:2025 - Security Misconfiguration](https://top10.owasp.org/2025/A02_2025-Security_Misconfiguration/))

## References

- [OWASP Cheat Sheet - XML External Entity Prevention](https://cheatsheetseries.owasp.org/cheatsheets/XML_External_Entity_Prevention_Cheat_Sheet.html)
- [OWASP Cheat Sheet - Server-Side Request Forgery Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html)

## Summary

The `/agenda/import` endpoint parses user-uploaded XML with external entities enabled (the HTML comments admit that `defusedxml` was "disabled temporarily"). A `<!ENTITY>` pointing at an internal URL makes the server itself fetch that URL and paste the response into the imported agenda - a classic XXE turned into SSRF.

## Proof of Concept

`exploit.sh` uploads `Resources/ssrf.xml`, which declares an entity for `http://127.0.0.1:4942/internal/config` (we know that `internal` exists from `robots.txt` and `/internal/config` from comments from HTML). The server fetches the endpoint, which is not reachable directly (it answers `{"error":"forbidden"}` to any outside request), and sends its JSON into the agenda page: the flag, the PocketBase admin email and password, and the JWT secret.

```
ENTITY SYSTEM "http://127.0.0.1:4942/internal/config"  -> config JSON stored into agenda
GET /internal/config (direct)                          -> 403 {"error":"forbidden"}
```

## Impact

The attacker can make the server request internal-only endpoints and read the responses: `/internal/config` leaks the database admin credentials and the JWT secret, which are then reused by `leaked_jwt_secret` and `pocketbase_admin_access` to fully compromise the website. This happens due to the XML parser resolving external entities from untrusted uploads instead of rejecting DTDs outright.

## Remediation

1. Parse untrusted XML with a hardened library or disable DTDs and external entities in the parser.
2. Remove the `/internal/config` endpoint so that no secrets can be fetched at all. This is pointed out in `leaked_jwt_secret`: the server has no proper secrets management.
