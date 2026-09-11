#!/usr/bin/python3

import base64
import hashlib
import hmac
import json
import sys


def b64url(data):
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def jwt_encode(payload, key):
    header = b64url(
        json.dumps({"alg": "HS256", "typ": "JWT"}, separators=(",", ":")).encode()
    )
    body = b64url(json.dumps(payload, separators=(",", ":")).encode())
    signature = b64url(
        hmac.new(key.encode(), f"{header}.{body}".encode(), hashlib.sha256).digest()
    )
    return f"{header}.{body}.{signature}"


print(
    jwt_encode(
        payload={
            "sub": "enplwhu8jfo56oi",
            "login": "sophie",
            "role": "god",
            "exp": 3789740569,
        },
        key=sys.argv[1],
    )
)
