# Reflected XSS

## OWASP Category

[A05:2025 - Injection](https://top10.owasp.org/2025/A05_2025-Injection/)

## References

- [OWASP Cheat Sheet - Cross Site Scripting Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)

## Summary

Subscribing to the newsletter (`POST /newsletter`) redirects back to the page with the email in the query string, and the success banner renders it without escaping: `You're now subscribed with: <email>`. A `<script>` tag sent as the email is reflected into the page as raw HTML and executes in the browser of whoever opens the link. The page does not even require a login.

## Proof of Concept

`exploit.sh` submits the subscription form with `<script>alert("hello")</script>` as the email, follows the redirect back and checks that the banner contains the payload unescaped (the server template inserts it as raw HTML).

```
POST /newsletter (email=<script>alert("hello")</script>)
  -> 302 /newsletter?email=%3Cscript%3Ealert(%22hello%22)%3C/script%3E&msg=subscribed
  -> "You're now subscribed with: <script>alert("hello")</script>"   (unescaped, executes)
```

## Impact

An attacker can send a victim a link that runs arbitrary JavaScript in their browser on the trusted website: steal the session cookie (it has no `HttpOnly`, as in `stored_xss`), act as the victim, or display fake content. Unlike `stored_xss`, this requires the victim to open the crafted link. This happens due to the email being echoed into the banner as raw HTML instead of escaped text - the input field on the same page escapes the very same value correctly.

An attacker can also obfuscate the link via URL shortener.

## Remediation

1. Before inserting, escape the `email` URL param on the server.
2. Add a `Content-Security-Policy` header that blocks inline scripts.
