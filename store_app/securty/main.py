from symmetric_module import symmetric_encryption
from rsa_module import rsa_encryption
from session_module import session_key_distribution
from hash_module import hash_function
from mac_module import mac_function

def main():
    while True:
        print("\n===== Cryptography Software System =====")
        print("1. Symmetric Encryption")
        print("2. Asymmetric Encryption (RSA)")
        print("3. Session Key Distribution")
        print("4. Hash Function")
        print("5. Message Authentication Code")
        print("6. Exit")

        choice = input("Choose an option: ")

        if choice == "1":
            symmetric_encryption()
        elif choice == "2":
            rsa_encryption()
        elif choice == "3":
            session_key_distribution()
        elif choice == "4":
            hash_function()
        elif choice == "5":
            mac_function()
        elif choice == "6":
            print("Exiting program...")
            break
        else:
            print("Invalid choice. Try again.")

if __name__ == "__main__":
    main()