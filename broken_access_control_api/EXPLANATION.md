# Broken Access Control for API Endpoint

## OWASP Category

A01:2021 - Broken Access Control

## Summary

`/api/grades` is listed as `Disallow` in `/robots.txt`, signaling it holds sensitive data. It does require a logged-in session, but it performs no authorization check on top of that: any authenticated user, regardless of role, can call it and receive **every student's** grades, not just their own.

## Proof of Concept

`exploit.sh` sources `../login_as_johndoe.sh` to obtain an authenticated session, then requests `/api/grades` with that session's cookie and extracts the `FLAG{...}` pattern from the JSON response.

## Impact

Any authenticated student can read all students' grades and project results, a clear violation of data confidentiality between students.

## Root Cause

The `/api/grades` endpoint checks that a valid session exists, but never checks that the requesting user is authorized to see the specific grade records returned (e.g. scoping the query to `student == current_user.id`, or requiring a staff/admin role).

## Remediation

Enforce object-level authorization on `/api/grades`: filter results to the authenticated student's own grades, or require a staff/admin role for the unfiltered listing.
