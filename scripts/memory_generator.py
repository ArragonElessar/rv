import argparse
import os
import sys

def ensure_output_dir():
    output_dir = os.path.join("sw", "mem")
    os.makedirs(output_dir, exist_ok=True)
    return output_dir

def bin_to_hex_converter(bin_file):
    with open(bin_file, 'rb') as f:
        data = f.read()
    return [format(byte, '02X') for byte in data]

def format_32bit_words(hex_arr):
    # Here we are explicitly reversing the order - little endian instructions will be generated
    words = []
    for i in range(0, len(hex_arr), 4):
        word = hex_arr[i:i+4]
        while len(word) < 4:
            word.append("00")
        # Reverse the byte order within the 4-byte word:
        reversed_word = word[::-1]
        words.append("".join(reversed_word))
    return words

def print_big_endian(hex_arr_data):
    print("\nBig-endian word view (4 bytes per line):")
    for i in range(0, len(hex_arr_data), 4):
        word = ' '.join(hex_arr_data[i:i + 4])
        print(f"{i:04X}: {word}")

def generate_coe_file(filepath, data):
    with open(filepath, "w") as f:
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        f.write(",\n".join(data) + ";\n")

def generate_mem_file(filepath, word_data):
    with open(filepath, "w") as f:
        for word in word_data:
            f.write(word + "\n")

def generate_hex_file(filepath, data):
    with open(filepath, 'w') as f:
        f.write(' '.join(data))

def show_usage():
    print("""
memory_generator: Binary File Viewer & Memory Format Converter

Usage:
  python memory_generator.py <file>.bin [options]

Note:
  Reads binary files from the 'sw/bin/' directory.
  Output files are saved to the 'sw/mem/' directory.

Options:
  --big-endian         Print contents in big-endian 32-bit word format
  --coe [file.coe]     Generate COE file with hex data (default: <name>.coe)
  --mem [file.mem]     Generate MEM file with 32-bit words (default: <name>.mem)
  --hex                Generate a HEX dump (default: <name>.hex)
  -h, --help           Show this help message and exit

Examples:
  python memory_generator.py program.bin --hex
  python memory_generator.py firmware.bin --big-endian --coe out.coe --mem
""")

def main():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("bin_file", nargs="?", help="Input binary file under sw/bin/")
    parser.add_argument("--big-endian", action="store_true", help="Print contents as big-endian words")
    parser.add_argument("--coe", nargs='?', const=True, metavar="out.coe", help="Generate COE file")
    parser.add_argument("--mem", nargs='?', const=True, metavar="out.mem", help="Generate MEM file")
    parser.add_argument("--hex", action="store_true", help="Generate HEX dump")
    parser.add_argument("-h", "--help", action="store_true", help="Show help message and exit")

    args = parser.parse_args()

    if args.help or not args.bin_file:
        show_usage()
        return

    bin_path = os.path.join("sw", "bin", args.bin_file)
    if not os.path.exists(bin_path):
        print(f"❌ Error: File '{bin_path}' not found.")
        return

    output_dir = ensure_output_dir()
    base_name = os.path.splitext(os.path.basename(args.bin_file))[0]

    hex_data = bin_to_hex_converter(bin_path)
    word_data = format_32bit_words(hex_data)

    if args.big_endian:
        print_big_endian(hex_data)

    if args.hex:
        hex_filename = os.path.join(output_dir, f"{base_name}.hex")
        generate_hex_file(hex_filename, hex_data)
        print(f"✅ HEX file saved to {hex_filename}")

    if args.coe:
        if isinstance(args.coe, str):
            coe_filename = os.path.join(output_dir, args.coe)
        else:
            coe_filename = os.path.join(output_dir, f"{base_name}.coe")
        generate_coe_file(coe_filename, word_data)
        print(f"✅ COE file saved to {coe_filename}")

    if args.mem:
        if isinstance(args.mem, str):
            mem_filename = os.path.join(output_dir, args.mem)
        else:
            mem_filename = os.path.join(output_dir, f"{base_name}.mem")
        generate_mem_file(mem_filename, word_data)
        print(f"✅ MEM file saved to {mem_filename}")

if __name__ == "__main__":
    main()
