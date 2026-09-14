# Predictable Password Reset Token

## OWASP Category

[A04:2025 - Cryptographic Failures](https://top10.owasp.org/2025/A04_2025-Cryptographic_Failures/)

## References

- [OWASP Cheat Sheet - Forgot Password](https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html)

## Summary

The password reset token is just the MD5 hash of the user's email address. An attacker who knows the email of a victim can compute the token himself and set a new password, without ever receiving the reset email.

## Proof of Concept

`exploit.sh` computes `md5(email)` and sends `POST /reset-password/confirm` with the email, the computed token and a new password of choice. The server does check the token (a wrong value is rejected with `Invalid token`), but the correct value is fully predictable.

```
token = md5("jdoe@student.42.tech") -> 5ae99e7ca0a3fd84337cecfa705f5321
POST /reset-password/confirm (email, token, new_password) -> login?success=Password+updated
```

## Impact

Critical issue: any student account can be taken over by anyone who knows the victim's email: the token contains no randomness at all, so it never expires, cannot be invalidated and can be replayed forever. Staff and god accounts are protected ("42 SSO" error), but combined with `no_brute_force_protection` every student account on the website is compromisable.

## Remediation

Generate reset tokens with a cryptographically secure random generator, deliver them by email, make them single-use and short-lived, and validate the new password before confirming the change.
