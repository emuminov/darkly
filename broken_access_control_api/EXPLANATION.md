# Broken Access Control for API Endpoint

## OWASP Category

[A01:2025 - Broken Access Control](https://top10.owasp.org/2025/A01_2025-Broken_Access_Control/)

Also: OWASP API1:2023 - Broken Object Level Authorization

## References

- [OWASP Cheat Sheet - Authorization](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html)

## Summary

`/api/grades` is listed as `Disallow` in `/robots.txt`, signaling it holds sensitive data. It does require a logged-in session, but it performs no authorization check on top of that: any authenticated user, regardless of role, can call it and receive **every student's** grades, not just their own.

## Proof of Concept

`exploit.sh` sources `../login_as_johndoe.sh` to obtain an authenticated session, then requests `/api/grades` with that session's cookie and extracts the `FLAG{...}` pattern from the JSON response.

## Impact

Any authenticated student can read all students' grades and project results, a clear violation of data confidentiality between students.
```sh
/api/grades              # own student grades
/api/grades?student={id} # grades of student with {id}
```

This happens due to server not having proper authorization *object-level authorization* check for `/api/grades` endpoint.

## Remediation

Enforce object-level authorization on `/api/grades?student={id}`. Ensure that student can see only their own grades, or that the session of a user who tries to access grades of other student has staff/admin role.
