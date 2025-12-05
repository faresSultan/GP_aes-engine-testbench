import numpy as np
from binascii import unhexlify, hexlify

# S-Box
S_BOX = np.array([
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
])

# Inverse S-Box
INV_S_BOX = np.array([
    0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
    0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
    0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
    0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
    0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
    0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
    0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
    0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
    0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
    0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
    0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
    0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
    0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
    0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
    0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
    0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
])

# RCON (Round Constant)
RCON = np.array([
    0x01, 0x02, 0x04, 0x08, 0x10,
    0x20, 0x40, 0x80, 0x1b, 0x36
])

def sub_bytes(state):
    return [[S_BOX[b] for b in row] for row in state]

def inv_sub_bytes(state):
    return [[INV_S_BOX[b] for b in row] for row in state]

def shift_rows(state):
    state[0][1], state[1][1], state[2][1], state[3][1] = state[1][1], state[2][1], state[3][1], state[0][1]
    state[0][2], state[1][2], state[2][2], state[3][2] = state[2][2], state[3][2], state[0][2], state[1][2]
    state[0][3], state[1][3], state[2][3], state[3][3] = state[3][3], state[0][3], state[1][3], state[2][3]
    return state

def inv_shift_rows(state):
    state[0][1], state[1][1], state[2][1], state[3][1] = state[3][1], state[0][1], state[1][1], state[2][1]
    state[0][2], state[1][2], state[2][2], state[3][2] = state[2][2], state[3][2], state[0][2], state[1][2]
    state[0][3], state[1][3], state[2][3], state[3][3] = state[1][3], state[2][3], state[3][3], state[0][3]
    return state

def gmul(a, b):
    p = 0
    while b > 0:
        if b & 1:
            p ^= a
        a <<= 1
        if a & 0x100:
            a ^= 0x11b
        b >>= 1
    return p

def mix_columns(state):
    for i in range(4):
        a = state[i][:]
        state[i] = [
            gmul(0x02, a[0]) ^ gmul(0x03, a[1]) ^ a[2] ^ a[3],
            a[0] ^ gmul(0x02, a[1]) ^ gmul(0x03, a[2]) ^ a[3],
            a[0] ^ a[1] ^ gmul(0x02, a[2]) ^ gmul(0x03, a[3]),
            gmul(0x03, a[0]) ^ a[1] ^ a[2] ^ gmul(0x02, a[3]),
        ]
    return state

def inv_mix_columns(state):
    for i in range(4):
        a = state[i][:]
        state[i] = [
            gmul(0x0e, a[0]) ^ gmul(0x0b, a[1]) ^ gmul(0x0d, a[2]) ^ gmul(0x09, a[3]),
            gmul(0x09, a[0]) ^ gmul(0x0e, a[1]) ^ gmul(0x0b, a[2]) ^ gmul(0x0d, a[3]),
            gmul(0x0d, a[0]) ^ gmul(0x09, a[1]) ^ gmul(0x0e, a[2]) ^ gmul(0x0b, a[3]),
            gmul(0x0b, a[0]) ^ gmul(0x0d, a[1]) ^ gmul(0x09, a[2]) ^ gmul(0x0e, a[3]),
        ]
    return state

def add_round_key(state, key):
    return [[s ^ k for s, k in zip(state_row, key_row)] for state_row, key_row in zip(state, key)]

def key_schedule(key, print_keys=False):
    round_keys = [list(key[i:i + 4]) for i in range(0, len(key), 4)]
   
    for i in range(4, 44):
        temp = round_keys[i - 1][:]
        if i % 4 == 0:
            temp = temp[1:] + temp[:1]
            temp = [S_BOX[b] for b in temp]
            temp[0] ^= RCON[i // 4 - 1]
        round_keys.append([round_keys[i - 4][j] ^ temp[j] for j in range(4)])
    
    return [round_keys[i:i + 4] for i in range(0, 44, 4)]

def write_state_to_file(state, path="testbench/data_out.txt"):
    # Flatten 4×4 matrix → bytes
    output_bytes = bytes(sum(state, []))
    with open(path, "a") as file:
        file.write(output_bytes.hex() + "\n")

def aes_encrypt(plaintext, key):
    state = [list(plaintext[i:i + 4]) for i in range(0, len(plaintext), 4)]
    round_keys = key_schedule(key)
    
    state = add_round_key(state, round_keys[0])

    open("testbench/data_out.txt", "w").close()   # clears data_out.txt file
    for round in range(1, 10):
        state = sub_bytes(state)
        state = shift_rows(state)
        state = mix_columns(state)
        write_state_to_file(state)  # write the rounds outputs line by line in  data_out.txt
        state = add_round_key(state, round_keys[round])
    
    state = sub_bytes(state)
    state = shift_rows(state)
    state = add_round_key(state, round_keys[10])
    write_state_to_file(state)      # append the final round output to the file data.txt, now the file have the outputs of each round line by line

def read_inputs_and_encrypt(plaintext_path="testbench/data_in.txt",
                            key_path="testbench/key_in.txt"):
    """
    Reads plaintext hex from one file and key hex from another file,
    converts both to bytes, and runs AES encryption.
    """

    with open(plaintext_path, 'r') as f_data:
        data_hex = f_data.read().strip()

    with open(key_path, 'r') as f_key:
        key_hex = f_key.read().strip()

    data = bytes.fromhex(data_hex)
    key  = bytes.fromhex(key_hex)
    aes_encrypt(data, key)

read_inputs_and_encrypt()

##########################################################################################
# def aes_decrypt(ciphertext, key):
#     state = [list(ciphertext[i:i + 4]) for i in range(0, len(ciphertext), 4)]
#     round_keys = key_schedule(key)
    
#     state = add_round_key(state, round_keys[10])
    
#     for round in range(9, 0, -1):
#         state = inv_shift_rows(state)
#         state = inv_sub_bytes(state)
#         state = add_round_key(state, round_keys[round])
#         state = inv_mix_columns(state)
    
#     state = inv_shift_rows(state)
#     state = inv_sub_bytes(state)
#     state = add_round_key(state, round_keys[0])
    
#     return bytes(sum(state, []))

##################################################################################################3
# def get_user_input(prompt, input_type='hex'):
#     while True:
#         try:
#             user_input = input(prompt).strip()
            
#             if input_type == 'hex':
#                 user_input = user_input.replace(' ', '').replace('0x', '')
#                 if len(user_input) % 2 != 0:
#                     raise ValueError("Hex string must have even number of characters")
#                 return unhexlify(user_input)
            
#             elif input_type == 'bytes':
#                 return user_input.encode('utf-8')
            
#             elif input_type == 'binary':
#                 user_input = user_input.replace(' ', '')
#                 if not all(c in '01' for c in user_input):
#                     raise ValueError("Binary string must contain only 0s and 1s")
#                 if len(user_input) % 8 != 0:
#                     raise ValueError("Binary string length must be multiple of 8")
#                 return int(user_input, 2).to_bytes(len(user_input) // 8, byteorder='big')
            
#         except ValueError as e:
#             print(f"Invalid input: {e}. Please try again.")

# def main():
#     print("AES-128 Encryption/Decryption")
#     print("=" * 30)
    
#     print("\nChoose input format for key and plaintext:")
#     print("1. Hexadecimal (e.g., '2b7e151628aed2a6abf7158809cf4f3c')")
#     print("2. Text/bytes (e.g., 'Thats my Kung Fu')")
#     print("3. Binary (e.g., '00101011 01111110 ...')")
    
#     format_choice = input("Enter choice (1/2/3): ").strip()
#     input_type = 'hex'
    
#     if format_choice == '1':
#         input_type = 'hex'
#         example = "32 hex characters (e.g., '2b7e151628aed2a6abf7158809cf4f3c')"
#     elif format_choice == '2':
#         input_type = 'bytes'
#         example = "16 characters (e.g., 'Thats my Kung Fu')"
#     elif format_choice == '3':
#         input_type = 'binary'
#         example = "128 bits (e.g., '00101011 01111110 ...')"
#     else:
#         print("Invalid choice. Defaulting to hexadecimal input.")
#         example = "32 hex characters (e.g., '2b7e151628aed2a6abf7158809cf4f3c')"
    
#     print(f"\nPlease enter {example}")

#     while True:
#         try:
#             key = get_user_input("Enter 128-bit key: ", input_type)
#             if len(key) != 16:
#                 print("Key must be exactly 16 bytes (128 bits)")
#                 continue
                
#             plaintext = get_user_input("Enter 128-bit plaintext: ", input_type)
#             if len(plaintext) != 16:
#                 print("Plaintext must be exactly 16 bytes (128 bits)")
#                 continue
                
#             break
#         except ValueError as e:
#             print(f"Error: {e}")

#     print("\nEncrypting...")
#     ciphertext = aes_encrypt(plaintext, key)
#     print("\nCiphertext (hex):", hexlify(ciphertext).decode())
    
#     print("\nDecrypting...")
#     decrypted = aes_decrypt(ciphertext, key)
#     print("\nDecrypted (hex):", hexlify(decrypted).decode())
#     try:
#         print("Decrypted (text):", decrypted.decode('utf-8'))
#     except UnicodeDecodeError:
#         print("Decrypted (text): [non-UTF-8 data]")

# if __name__ == "__main__":
#     main()