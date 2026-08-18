import os
import base64
from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP, AES
from Crypto.Util.Padding import pad, unpad

def session_key_distribution():
    print("\n--- Session Key Distribution ---")

    # Generate RSA Keys
    key = RSA.generate(2048)
    public_key = key.publickey()

    # Generate Session Key
    session_key = os.urandom(16)
    print("Generated Session Key:", base64.b64encode(session_key).decode())

    # Encrypt Session Key with RSA
    cipher_rsa = PKCS1_OAEP.new(public_key)
    encrypted_session = cipher_rsa.encrypt(session_key)
    print("Encrypted Session Key:", base64.b64encode(encrypted_session).decode())

    # Decrypt Session Key
    decipher_rsa = PKCS1_OAEP.new(key)
    decrypted_session = decipher_rsa.decrypt(encrypted_session)

    print("Decrypted Session Key:", base64.b64encode(decrypted_session).decode())

    # Use Session Key with AES
    message = input("Enter message to encrypt: ").encode()
    cipher_aes = AES.new(decrypted_session, AES.MODE_CBC)
    ciphertext = cipher_aes.encrypt(pad(message, AES.block_size))

    print("Encrypted with Session Key:", base64.b64encode(ciphertext).decode())

    decipher_aes = AES.new(decrypted_session, AES.MODE_CBC, cipher_aes.iv)
    decrypted = unpad(decipher_aes.decrypt(ciphertext), AES.block_size)

    print("Decrypted:", decrypted.decode())