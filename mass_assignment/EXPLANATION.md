# Mass Assignment: Role Field on /api/profile

## OWASP Category

[OWASP API3:2023 - Broken Object Property Level Authorization](https://owasp.org/API-Security/editions/2023/en/0xa3-broken-object-property-level-authorization/)

## References

- [OWASP Cheat Sheet - Mass Assignment](https://cheatsheetseries.owasp.org/cheatsheets/Mass_Assignment_Cheat_Sheet.html)

## Summary

The `/api/profile` endpoint accepts a `role` property in the PATCH request. The `role` of a user should only be decided by the administration, but nothing stops a regular user from sending it and assigning himself a privileged role (`cadet`).

## Proof of Concept

`exploit.sh` logs in as a regular student (`jdoe`), then sends `PATCH /api/profile` with `{"role":"cadet"}`. The server accepts the change, and `/staff/dashboard` becomes available, where the flag is.

## Impact

Any authenticated user can escalate their privileges and access staff-only pages such as `/staff/dashboard`. This happens due to the endpoint blindly assigning all client-supplied properties to the user object, including the ones (`role`) that were never meant to be client-controlled.

## Remediation

Explicitly allowlist the properties that a user is allowed to change on `/api/profile` (e.g. name, avatar) and silently ignore everything else, `role` in particular.
