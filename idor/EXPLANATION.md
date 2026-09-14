# Insecure Direct Object Reference (IDOR)

## OWASP Category

[A01:2025 - Broken Access Control](https://top10.owasp.org/2025/A01_2025-Broken_Access_Control/)

## References

- [OWASP Cheat Sheet - Insecure Direct Object Reference Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Insecure_Direct_Object_Reference_Prevention_Cheat_Sheet.html)

## Summary

Staff-level user `wil` has a private note in his profile that is not supposed to be visible to other users.

## Proof of Concept

`exploit.sh` simply requests `/profile/k1asdfeditojrb4` and extracts the `FLAG{...}` pattern from the resulting HTML.

## Impact

Any user, even an anonymous one, can access a resource that they are not supposed to see.

The server performs no authorization check on `/profile/{user_id}`: the private note section is rendered for every requester, regardless of session or role.

## Remediation

Enforce object-level authorization on `/profile/{user_id}`: make private notes visible only to the resource owner (`wil`) or to users with a certain privilege level (`staff` and above).
