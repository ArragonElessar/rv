    .text
    .global _start
    
_start:
    
    addi x6, x0, 10    # Counter for fibonacci numbers needed
    addi x7, x0, 0x48  # Starting location to store fib numbers, memory pointer
    
    # Store the first fib number
    sw x0, 0(x7)
    addi x7, x7, 4
    
    # Store the second fib number
    addi x8, x0, 1
    sw x8, 0(x7)
    
    # Reduce the fib number counter variable
    addi x6, x6, -2
    
    loop:
        
        # load the previous two fib numbers into registers
        lw x9, 0(x7)
        lw x10, -4(x7)
        
        # Calculate the next fib number
        add x8, x9, x10
        
        # Store it into memory 
        sw x8, 4(x7)
        
        # Update the counters
        addi x7, x7, 4
        addi x6, x6, -1
        
        # Stop when necessary
        bne x6, x0, loop
    