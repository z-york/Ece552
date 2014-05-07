# Andrew Gailey
# HW3 Problem 4
# Testing LHB, SLL, AND, and NOR
# With the assumption that LLB, SUB, and B EQ are functioning properly

    llb R1, 0
    llb R2, 0
    llb R3, 0
    llb R4, 0
    llb R5, 0
    llb R6, 0
    llb R7, 0
    llb R8, 0
    llb R9, 0
    llb R10, 0
    llb R11, 0
    llb R12, 0
    llb R13, 0
    llb R14, 0
    llb R15, -1             # Set Flag register to xFFFF

### First test LHB ###
## Check that lhb loads something ##
    llb R1, 0               # R1 = 0
    lhb R1, 1               ## Check that lhb loads something ##
    sub R1, R1, R0          # R1 - R0 should not be 0
    b eq, fail1             # If it is then fail
    sub R1, R0, R0          # set zero flag for unconditional branch
                            # (bc I'm assuming only LLB, SUB, and B EQ
                            # are guaranteed)
    b eq, pass1             # If this is reached, lhb didn't fail
fail1:
    llb R14, 1              # R14 = 1
    sub R15, R15, R14       # Flag error with last bit of R15
pass1:
## Check that lhb clears all top bits ##
    llb R1, -128            # Set R1 to xFF80
    llb R2, 127             # Set R2 to x007F
    llb R3, -1              # Set R3 to xFFFF
    sub R2, R2, R3          # R2 is now x0080
    lhb R1, 0               ## Check that lhb clears all top bits ##
    sub R1, R1, R2          # R1 - R2 should be 0
    b eq, pass2
    llb R14, 2              # R14 = 2
    sub R15, R15, R14       # Flag error with second to last bit of R15
pass2:
## Check that lhb sets all top bits ##
    llb R1, -128            # Set R1 to xFF80
    llb R2, 127             # Set R2 to x007F
    llb R3, -1              # Set R3 to xFFFF
    sub R2, R2, R3          # R2 is now x0080
    lhb R2, -1              ## Check that lhb sets all top bits ##
    sub R1, R1, R2          # R1 - R2 should be 0
    b eq, pass3
    llb R14, 4              # R14 = 4
    sub R15, R15, R14       # Flag error with third to last bit of R15
pass3:
## Check that lhb doesn't affect R0 ##
    llb R1, 0               # R1 = 0
    lhb R0, -1              ## Check that lhb doesn't affect R0 ##
    sub R1, R0, R1          # R0 - R1 should be 0
    b eq, pass4
    llb R14, 8              # R14 = 8
    sub R15, R15, R14       # Flag error with fourth to last bit of R15
pass4:

### Now test SLL ###
## Check that 15 0's are shifted in on the right ##
    llb R2, 0               # R2 = 0
    lhb R2, -128            # Set R2 to x8000
    llb R1, -1              # Set R1 to xFFFF
    sll R1, R1, 15          ## Check that 15 0's are shifted in on the right ##
    sub R1, R1, R2          # R1 - R2 should be 0
    b eq, pass5
    llb R14, 16             # R14 = 16
    sub R15, R15, R14       # Flag error with fifth to last bit of R15
pass5:
## Check that each bit shifts properly ##
    llb R2, 0xAA
    lhb R2, 0xAA            # R2 is now xAAAA
    llb R1, 0x55
    lhb R1, 0x55            # R1 is now x5555
    sll R1, R1, 1           ## Check that each bit shifts properly ##
    sub R1, R1, R2          # R1 - R2 should be 0
    b eq, pass6
    llb R14, 32             # R14 = 32
    sub R15, R15, R14       # Flag error with sixth to last bit of R15
pass6:
## Check that each bit shifts properly ##
    llb R2, 0x54
    lhb R2, 0x55            # R2 is now x5554
    llb R1, 0xAA
    lhb R1, 0xAA            # R1 is now xAAAA
    sll R1, R1, 1           ## Check that each bit shifts properly ##
    sub R1, R1, R2          # R1 - R2 should be 0
    b eq, pass7
    llb R14, 64             # R14 = 64
    sub R15, R15, R14       # Flag error with seventh to last bit of R15
pass7:
## Check that sll doesn't affect R0 ##
    llb R1, 0               # R1 = 0
    llb R2, -1              # R2 set to xFFFF
    sll R0, R2, 1           ## Check that sll doesn't affect R0 ##
    sub R1, R0, R1          # R0 - R1 should be 0
    b eq, pass8
    llb R14, 127
    sub R14, R14, R2        # R14 = 127 -(-1) = 128
    sub R15, R15, R14       # Flag error with eighth to last bit of R15
pass8:

### Now test AND ###
## Check that and isn't nand ##
    and R1, R0, R0          ## Check that and isn't nand ##
    b eq, pass9
    llb R14, 0
    lhb R14, 1              # Set R14 to x0100
    sub R15, R15, R14       # Flag error with ninth to last bit of R15
pass9:
## Check that and isn't or ##
    llb R2, -1              # R1 = x0000, R2 = xFFFF
    and R1, R0, R2          ## Check that and isn't or ##
    b eq, pass10
    llb R14, 0
    lhb R14, 2              # Set R14 to x0200
    sub R15, R15, R14       # Flag error with tenth to last bit of R15
pass10:
## Check that and works on all bits ##
    llb R1, -1
    llb R2, -1              # R1 and R2 are xFFFF
    and R3, R1, R2          ## Check that and works on all bits ##
    sub R1, R3, R1          # R3 - R1 should be 0
    b eq, pass11
    llb R14, 0
    lhb R14, 4              # Set R14 to x0400
    sub R15, R15, R14       # Flag error with eleventh to last bit of R15
pass11:
## Check that and doesn't affect R0 ##
    llb R3, 0               # R3 = 0
    llb R1, -1              # R1 is xFFFF, R2 is still xFFFF from last test
    and R0, R1, R2          ## Check that and doesn't affect R0 ##
    sub R3, R0, R3          # R0 - R3 should be 0
    b eq, pass12
    llb R14, 0
    lhb R14, 8              # Set R14 to x0800
    sub R15, R15, R14       # Flag error with twelfth to last bit of R15
pass12:

### Now test NOR ###
## Check that nor works on all bits ##
    nor R1, R0, R0          ## Check that nor works on all bits ##
    sub R1, R1, R2          # R2 still xFFFF; R1 - R2 should be 0
    b eq, pass13
    llb R14, 0
    lhb R14, 16             # Set R14 to x1000
    sub R15, R15, R14       # Flag error with thirteenth to last bit of R15
pass13:
## R2 is still xFFFF; Check that nor is not or ##
    nor R1, R0, R2          ## R2 is still xFFFF; Check that nor is not or ##
    b eq, pass14
    llb R14, 0
    lhb R14, 32             # Set R14 to x2000
    sub R15, R15, R14       # Flag error with fourteenth to last bit of R15
pass14:
## R2 is still xFFFF; Check that nor is not and ##
    nor R1, R2, R2          ## R2 is still xFFFF; Check that nor is not and ##
    b eq, pass15
    llb R14, 0
    lhb R14, 64             # Set R14 to x4000
    sub R15, R15, R14       # Flag error with fifteenth to last bit of R15
pass15:
## Check that nor doesn't affect R0 ##
    llb R1, 0               # R1 = 0
    nor R0, R0, R0          ## Check that nor doesn't affect R0 ##
    sub R1, R0, R1          # R0 - R1 should be 0
    b eq, pass16
    llb R14, 0
    lhb R14, -128           # Set R14, to x8000
    sub R15, R15, R14       # Flag error with top bit of R15
pass16:

hlt                         # Done, print registers
