# Path Traversal

## OWASP Category

A03:2021 - Injection

## Summary

`/projects/download?file=<name>` joins the user-controlled `file` parameter with a server-side directory to serve project files, without validating or sanitizing the path. Requesting `..` makes the backend try to open a directory as a file, which crashes with an unhandled `IsADirectoryError` and leaks an HTTP 500 — direct evidence that the parameter escapes the intended file scope.

## Proof of Concept

`exploit.sh` sources `../login_as_johndoe.sh` to obtain an authenticated session, then requests `/projects/download?file=..` and asserts the response is an unhandled HTTP 500.

```
/projects/download?file=..   → 500 Internal Server Error
```

## Impact

An attacker can manipulate the path component (`../`) to probe the server filesystem outside the projects directory: response codes distinguish between existing/forbidden/missing paths (500/403/404), enabling blind file enumeration and potential disclosure of arbitrary readable files such as source code, configuration or secrets.

## Root Cause

The backend concatenates the raw `file` parameter with a base directory (e.g. `os.path.join(projects_dir, file)`) and passes the result directly to a file-serving call, with no canonicalization check against the base directory and no error handling.

## Remediation

Validate the resolved path before serving: canonicalize with `os.path.realpath` and reject anything not starting with the canonical base directory (allowlist approach). Additionally, reject directories and map requests to an allowlist of known project files instead of raw filesystem names.
