import hashlib
def find_max():
    numbers = input("Enter numbers separated by space: ")
    nums = list(map(int, numbers.split()))
    
    max_num = nums[0]  # نفترض أول رقم هو الأكبر
    
    for num in nums:
        if num > max_num:
            max_num = num
        else:
            continue
    
    return max_num

print("Max number is:", find_max())
def sort_numbers():
    numbers = input("Enter numbers separated by space: ")
    
    # تحويل الإدخال إلى قائمة أرقام
    numbers_list = list(map(int, numbers.split()))
    
    numbers_list.sort()
    
    return numbers_list

print(sort_numbers())
def hash_function():
    print("\n Hash Function ")
    

    message = input("Enter message: ")

    hash1 = hashlib.sha256(message.encode()).hexdigest()
    print("Hash:", hash1)

    print("\nChanging one character...")
    modified = message + "a"    #  1111
    hash2 = hashlib.sha256(modified.encode()).hexdigest()
    print("New Hash:", hash2)