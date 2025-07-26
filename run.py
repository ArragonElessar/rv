#!/usr/bin/env python33
import argparse
import subprocess
from pathlib import Path

# === Argument Parsing ===
parser = argparse.ArgumentParser(
    description="python3 build tool for Verilog simulation",
    formatter_class=argparse.RawTextHelpFormatter
)

parser.add_argument('--tb', help='Testbench name without .v (e.g., adder32_tb)', default='adder32_tb')
parser.add_argument('--rtl', help='RTL module name without .v (e.g., adder32)', default=None)
parser.add_argument('--run', action='store_true', help='Compile and simulate')
parser.add_argument('--wave', action='store_true', help='Open GTKWave')
parser.add_argument('--all', action='store_true', help='Run compile, simulate, and open waveform')
parser.add_argument('--clean', action='store_true', help='Clean compiled and waveform files')

args = parser.parse_args()

tb_name = args.tb
rtl_name = args.rtl if args.rtl else tb_name.replace('_tb', '')

# === Paths ===
tb_file = f"testbench/basic/{tb_name}.v"
rtl_file = f"rtl/alu/{rtl_name}.v"
sim_out = f"sim/runs/{tb_name}"
vcd_file = f"sim/waves/{rtl_name}.vcd"

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
    subprocess.run(["iverilog", "-o", sim_out, tb_file, rtl_file], check=True)

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
