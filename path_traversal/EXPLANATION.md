# Path Traversal

## OWASP Category

[A05:2025 - Injection](https://top10.owasp.org/2025/A05_2025-Injection/)

## References

- [OWASP Cheat Sheet - Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Injection_Prevention_Cheat_Sheet.html)

## Summary

The `/projects/download` endpoint serves project files by joining the user-controlled `file` parameter with a server-side directory. The path is not validated, so `../` sequences escape the projects directory and files outside of it can be read.

## Proof of Concept

`exploit.sh` first requests `/projects/download?file=..`, which makes the server try to open a directory as a file and crash with an unhandled error (HTTP 500) - proof that the parameter escapes the intended directory. Then it reads the `/backup` page, whose `x-backup-exclude` header reveals the name of a sensitive file (`data/private_notes.txt`), and downloads it through the traversal (`file=../private_notes.txt`), where the flag is.

```
/projects/download?file=..                   -> 500 (escaped, is a directory)
/projects/download?file=../..                -> 403 (deeper traversal blocked)
/projects/download?file=missing.txt          -> 404 (does not exist)
/projects/download?file=../private_notes.txt -> 200 (file outside projects dir)
```

## Impact

An attacker can read files that lie above the projects directory, such as `private_notes.txt`. The response codes also leak information about the server filesystem: 500 means the path exists and is a directory, 403 means the traversal was blocked, 404 means the file does not exist. This happens due to the backend concatenating the raw `file` parameter with the projects directory (e.g. `os.path.join(projects_dir, file)`) without checking that the resolved path stays inside it, and without handling errors.

## Remediation

Validate the resolved path before serving: canonicalize it with `os.path.realpath` and reject anything that does not start with the canonical projects directory. Additionally, reject directories and map requests to an allowlist of known project files instead of raw filesystem names.
