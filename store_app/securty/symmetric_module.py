import os
import base64
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad

def symmetric_encryption():
    print("\n Symmetric Encryption (AES)")
    message = input("Enter message: ").encode()

    key = os.urandom(16)
    cipher = AES.new(key, AES.MODE_CBC)
    ciphertext = cipher.encrypt(pad(message, AES.block_size))

    print("Encrypted:", base64.b64encode(ciphertext).decode())

    # Decryption
    decipher = AES.new(key, AES.MODE_CBC, cipher.iv)
    decrypted = unpad(decipher.decrypt(ciphertext), AES.block_size)

    print("Decrypted:", decrypted.decode())