#!/usr/bin/env python3
"""
Simple test script to create an order and fetch its delivery status.
Usage:
  python scripts/test_order_flow.py <user_id>

This avoids shell quoting issues in PowerShell/curl.
"""
import sys
import requests

if len(sys.argv) < 2:
    print("Usage: python scripts/test_order_flow.py <user_id>")
    sys.exit(1)

user_id = sys.argv[1]

CREATE_URL = f"http://localhost:8003/order/create?user_id={user_id}"

print(f"POST {CREATE_URL}")
try:
    r = requests.post(CREATE_URL, timeout=5)
except Exception as e:
    print("Error calling cart-order-service:", e)
    sys.exit(2)

print("Status:", r.status_code)
print(r.text)

if r.status_code >= 200 and r.status_code < 300:
    try:
        data = r.json()
        order_id = data.get("order_id")
        if not order_id:
            print("No order_id in response")
            sys.exit(0)
        STATUS_URL = f"http://localhost:8004/order/{order_id}/status"
        print(f"GET {STATUS_URL}")
        try:
            s = requests.get(STATUS_URL, timeout=5)
            print("Status code:", s.status_code)
            print(s.text)
        except Exception as e:
            print("Error calling delivery-service:", e)
    except ValueError:
        print("Response is not JSON")
else:
    sys.exit(1)
