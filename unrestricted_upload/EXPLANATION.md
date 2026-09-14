# Unrestricted File Upload: Avatar Endpoint Accepts Any File Type

## OWASP Category

[A06:2025 - Insecure Design](https://top10.owasp.org/2025/A06_2025-Insecure_Design/) (CWE-434 is mapped to this category)

## References

- [OWASP Cheat Sheet - File Upload](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html)

## Summary

The `/upload/avatar` endpoint is supposed to accept avatar images, but it performs no validation at all: any file type is accepted, the original filename and extension are kept, and the file is stored under `/static/uploads/` where anyone can download it.

## Proof of Concept

`exploit.sh` logs in as `jdoe` and uploads its own `exploit.sh` shell script as the avatar. The upload succeeds, and the server even returns the flag in the redirect when a forbidden type is uploaded. The file is then available under `/static/uploads/{user_id}_exploit.sh`.

```
POST /upload/avatar (exploit.sh)                      -> 302 /profile/me/settings?upload_flag=FLAG{unr3str1ct3d_upl0ad_g0_brrr}
GET  /static/uploads/z4p1cnx47mfy50f_exploit.sh       -> 200 text/x-sh
GET  /static/uploads/z4p1cnx47mfy50f_xsstest.html     -> 200 text/html
```

## Impact

An attacker can host arbitrary content on the trusted origin: an uploaded `.html` file is served with `text/html`, which is a second stored XSS vector (same consequences as `stored_xss`), and any other file type can be spread from the website's domain. This happens due to the file extension and content never being checked against a whitelist.

## Remediation

Validate the uploaded file: accept only image formats, verify the content (magic bytes) and not just the extension, generate a safe random filename, and serve uploads with a neutral content type (or force `Content-Disposition: attachment`).
