# No Brute Force Protection: Dictionary Attack on Login

## OWASP Category

[A07:2025 - Authentication Failures](https://top10.owasp.org/2025/A07_2025-Authentication_Failures/)

## References

- [OWASP Cheat Sheet - Authentication](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [OWASP Cheat Sheet - Credential Stuffing Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Credential_Stuffing_Prevention_Cheat_Sheet.html)

## Summary

The `/login` endpoint has no brute force protection: there is no rate limiting, no temporary lockout and no CAPTCHA, so an attacker can try unlimited passwords in a row. On top of that, the website allows users to choose weak passwords: the only rule is a minimum length of 5 characters, and dictionary passwords such as `123456` are accepted without any check against common password lists.

## Proof of Concept

`exploit.sh` reads `Resources/10k-worst-passwords.txt` line by line and sends a login request for `jdoe@student.42.tech` with each password, until the response redirects to `/` instead of the login error page. In a verification run, 40 rapid failed attempts in a row produced no lockout or delay, and the correct password still worked immediately after.

## Impact

Any account that uses a dictionary password can be taken over in minutes. Combined with `predictable_password_reset`, which lets anyone set a new weak password for an account, this makes every account on the website compromisable. This happens due to the login endpoint accepting unlimited unthrottled authentication attempts, and due to the absence of a real password policy: no rules beyond a 5-character minimum and no check against lists of common passwords.

## Remediation

1. Introduce rate limiting on `/login`: after several failed attempts, slow down or block further tries (per account and per IP), or require a CAPTCHA.
2. Enforce a password policy: reject passwords from common password lists and raise the minimum length.
3. Optionally alert the user when repeated failures are detected on their account.
