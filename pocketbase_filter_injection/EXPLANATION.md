# PocketBase Filter Injection in Forum Search

## OWASP Category

[A05:2025 - Injection](https://top10.owasp.org/2025/A05_2025-Injection/)

## References

- [OWASP Cheat Sheet - Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Injection_Prevention_Cheat_Sheet.html)

## Summary

The forum search endpoint interpolates user input directly into a PocketBase filter expression, without sanitizing. By closing the string literal and appending `|| id != "`, an attacker can inject an always-true clause and override the intended filter logic, returning every record regardless of the search term.

## Proof of Concept

`exploit.sh` first searches for an unexisting word, like `zzzzzzzzz` (`/forum?search=zzzzzzzzz`). This returns 0 posts.
Then it sends the same word, but adds `" || id != "` at the end. Now it returns all posts, even if none of them match `zzzzzzzzz`.

## Impact

All forum posts are already visible to every user, so this bug alone is not dangerous. But if the same mistake exists on a page with private data, an attacker could use it to see data they should not see.

## Remediation

Never put user input directly inside the filter string. Use PocketBase's parameter binding (like `{:search}`) instead, so user input stays data and can never change the query logic.
