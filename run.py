#!/usr/bin/env python33
import argparse
import subprocess
from pathlib import Path
import os

# === Argument Parsing ===
parser = argparse.ArgumentParser(
    description="python3 build tool for Verilog simulation",
    formatter_class=argparse.RawTextHelpFormatter
)

parser.add_argument('--tb', help='Testbench name without .v (e.g., adder32_tb)', default='basic/adder32_tb')
parser.add_argument('--rtl', help='RTL module name without .v (e.g., adder32)', default='basic/adder32')
parser.add_argument('--run', action='store_true', help='Compile and simulate')
parser.add_argument('--wave', action='store_true', help='Open GTKWave')
parser.add_argument('--all', action='store_true', help='Run compile, simulate, and open waveform')
parser.add_argument('--clean', action='store_true', help='Clean compiled and waveform files')
parser.add_argument('--add_program_binary', help="Pull a binary from the windows file system to sw/src & sw/bin")

args = parser.parse_args()

tb = args.tb
if tb:
    tb_type, tb_name = tb.split('/')

src_program = args.add_program_binary if args.add_program_binary else None

rtl = args.rtl
if rtl:
    rtl_type, rtl_name = rtl.split('/')

# === Paths ===
tb_file = f"testbench/{tb_type}/{tb_name}.v"
rtl_file = f"rtl/{rtl_type}/{rtl_name}.v"
sim_out = f"sim/runs/{tb_name}"
vcd_file = f"sim/waves/{rtl_name}.vcd"

if src_program:
    sw_program_bin_file = f"/mnt/c/Users/prana/Documents/ripes_programs/{src_program}.bin"
    sw_program_src_file = f"/mnt/c/Users/prana/Documents/ripes_programs/{src_program}.s"
    sw_program_bin_dest = "sw/bin"
    sw_program_src_dest = "sw/src"

# === Directory Setup ===
Path("sim/runs").mkdir(parents=True, exist_ok=True)
Path("sim/waves").mkdir(parents=True, exist_ok=True)

# === Clean Rule ===
if args.clean:
    print(f"[clean] Removing {sim_out} and {vcd_file}")
    Path(sim_out).unlink(missing_ok=True)
    Path(vcd_file).unlink(missing_ok=True)
    exit(0)

# === Run Rule ===
def compile_and_simulate():
    print(f"[1/3] Compiling {tb_file} and {rtl_file}")

     # Collect all .v files from rtl/ and subdirectories
    rtl_dir = "rtl"
    verilog_files = []
    for root, _, files in os.walk(rtl_dir):
        for file in files:
            if file.endswith(".v"):
                full_path = os.path.join(root, file)
                # Exclude rtl_file and tb_file
                if os.path.abspath(full_path) not in (
                    os.path.abspath(rtl_file), os.path.abspath(tb_file)
                ):
                    verilog_files.append(full_path)

    subprocess.run(["iverilog", "-o", sim_out, tb_file, rtl_file] + verilog_files, check=True)

    print(f"[2/3] Simulating {sim_out}")
    subprocess.run(["vvp", sim_out], check=True)

# === Waveform View ===
def open_waveform():
    print(f"[3/3] Opening GTKWave: {vcd_file}")
    subprocess.run(["gtkwave", vcd_file])

# === Execution Dispatcher ===
if args.all:
    compile_and_simulate()
    open_waveform()
elif args.run:
    compile_and_simulate()
elif args.wave:
    open_waveform()
elif src_program:
    print(f"Args program binary: {src_program}")
    subprocess.run(["cp", sw_program_bin_file, sw_program_bin_dest])
    subprocess.run(["cp", sw_program_src_file, sw_program_src_dest])
else:
    print(
        f"""🛠️  Usage: python3 run.py [options]

Examples:
  python3 run.py --all                      # Compile, simulate and open waveform
  python3 run.py --tb=mult_tb --all         # Run for mult_tb.v and mult.v
  python3 run.py --tb=alu_tb --rtl=alu      # Custom TB/RTL pairing
  python3 run.py --clean                    # Delete sim output + vcd

Available options:""")
    parser.print_help()
