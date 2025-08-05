    .text
    .globl _start

_start:
    # Initialize loop counter
    addi t0, zero, 5      # t0 = 5 (loop counter)

    # Initialize value and base address
    addi t1, zero, 0x200    # t1 = 100 (value to store)
    addi t2, zero, 0x48     # t2 = 48 (base memory address)

    # Store initial value
    sw t1, 0(t2)

loop:
    # Load, update, store, and update loop counter
    lw t1, 0(t2)          # load value from address in t2 to t1
    addi t2, t2, 4        # increment memory address
    addi t1, t1, -4       # decrement value by 5
    sw t1, 0(t2)          # store updated value back
    addi t0, t0, -1       # decrement loop counter
    bne t0, zero, loop    # loop if t0 != 0

    # Done
