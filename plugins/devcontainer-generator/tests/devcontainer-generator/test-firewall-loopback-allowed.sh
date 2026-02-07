#!/bin/bash
# Test: localhost/loopback always works
if ping -c 1 -W 2 127.0.0.1 &>/dev/null; then
    echo "PASS: loopback (127.0.0.1) is accessible"
    exit 0
else
    echo "FAIL: loopback (127.0.0.1) is not accessible"
    exit 1
fi
