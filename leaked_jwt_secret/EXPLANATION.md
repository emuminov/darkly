# Leaked JWT Secret: Forged Admin Session Token

## OWASP Category

[A04:2025 - Cryptographic Failures](https://top10.owasp.org/2025/A04_2025-Cryptographic_Failures/)

## References

- [OWASP Cheat Sheet - JSON Web Token](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_Cheat_Sheet.html)
- [OWASP Cheat Sheet - Key Management](https://cheatsheetseries.owasp.org/cheatsheets/Key_Management_Cheat_Sheet.html)

## Summary

Due to improper secret management, the JWT secret is leaked through **XXE to SSRF attack**. It can be used to gain access to *any* account on the website. On top of that, the `42network` secret is cryptographically weak and is prone to brute force attacks.

Alternatively, the `42network` secret is leaked through HTML comments.

## Proof of Concept

This attack uses a chain of vulnerabilities. First, `../xxe_to_ssrf/exploit.sh` attack makes the server leak secrets (or just parses through HTML comments in the website).
Second, `exploit.sh` forges a JWT session cookie for the admin-level user `sophie`, thus gaining access to her account.

## Impact

Critical issue: hackers are able to gain access to anyone's account. While JWTs alone don't fully compromise the website, the admin's `email` and `password` that are also leaked through improper secret management give hackers full access to the database.

## Remediation

1. The most important: introduce proper secret management. Use secure third-party applications that manage secrets and store them in environment variables.
2. JWT secret should be cryptographically secure: cryptographic algorithms like `HS256` or other long randomly generated JWT's along with rate-limiting of invalid JWT's should eliminate brute force vulnerability altogether.
