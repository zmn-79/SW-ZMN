import base64
from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP

def rsa_encryption():
    print("\n--- RSA Encryption ---")

    key = RSA.generate(2048)
    public_key = key.publickey()

    print("Public Key:\n", public_key.export_key().decode())
    print("Private Key:\n", key.export_key().decode())

    message = input("Enter message: ").encode()

    cipher = PKCS1_OAEP.new(public_key)
    encrypted = cipher.encrypt(message)

    print("Encrypted:", base64.b64encode(encrypted).decode())

    decipher = PKCS1_OAEP.new(key)
    decrypted = decipher.decrypt(encrypted)

    print("Decrypted:", decrypted.decode())