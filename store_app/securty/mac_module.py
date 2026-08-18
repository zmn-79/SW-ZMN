import hashlib
import hmac

def mac_function():
    print("\n HMAC-")

    message = input("Enter message: ").encode()
    secret_key = input("Enter secret key: ").encode()

    mac = hmac.new(secret_key, message, hashlib.sha256).hexdigest()
    print("Generated MAC:", mac)