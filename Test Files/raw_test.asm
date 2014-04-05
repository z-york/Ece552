###############################################################################
# Andrew Gailey and Zach York
# 
# This tests for proper forwarding and stalling for all RAW dependecies.
# Not all combinations of operations needs to be tested. We can simply test
# both read ports for two of the three possible writeback sources: the ALU,
# and memory. The 3rd writeback source, PC+1, used with JAL, will incur a
# stall which eliminates any potential RAWs. JAL will be tested elsewhere.
# We will need to test several different cases for each combination,
# one for each stage the register value is being forwarded from. Also, we
# will need to test for proper stalling with load/use hazards. NOPs are used
# throughout to ensure forwarding only occurs when we're testing it.
#
# Note: R14 is being used as a flag register. Significance of the final bits:
#            0th bit: src0, from ALU in previous instr
#            1st bit: src0, from ALU in 2nd to last instr
#            2nd bit: src1, from ALU in previous instr
#            3rd bit: src1, from ALU in 2nd to last instr
#            4th bit: src0, from MEM in previous instr (load/use stall)
#            5th bit: src0, from MEM in 2nd to last instr
#            6th bit: src1, from MEM in previous instr (load/use stall)
#            7th bit: src1, from MEM in 2nd to last instr
###############################################################################

# Initialize registers
jal RegInit
llb R15, 0

#### ALU writeback ####
## src0
# forwarded from previous instr
add R0, R0, R0       # NOP
add R0, R0, R0       # NOP
add R2, R1, R0       # R2 <= 1
add R14, R14, R2     # Add 1 if no error
add R0, R0, R0       # NOP
add R0, R0, R0       # NOP
sll R14, R14, 1      # Shift the bit over

# forwarded from 2nd to last instr
add R3, R1, R0       # R3 <= 1
add R0, R0, R0       # NOP
add R14, R14, R3     # Add 1 if no error
add R0, R0, R0       # NOP
add R0, R0, R0       # NOP
sll R14, R14, 1      # Shift the bit over

## src1
# forwarded from previous instr
add R0, R0, R0       # NOP
add R4, R1, R0       # R4 <= 1
add R14, R4, R14     # Add 1 if no error
add R0, R0, R0       # NOP
add R0, R0, R0       # NOP
sll R14, R14, 1      # Shift the bit over

# forwarded from 2nd to last instr
add R5, R1, R0       # R5 <= 1
add R0, R0, R0       # NOP
add R14, R5, R14     # Add 1 if no error
add R0, R0, R0       # NOP
add R0, R0, R0       # NOP
sll R14, R14, 1      # Shift the bit over
#### /ALU writeback ####

#### Memory writeback ####
# Setup
sw R1, R13, 0        # MEM[x8000] <= 1

## src0
# load/use stall then forward
lw R6, R13, 0        # R6 <= 1
add R14, R14, R6     # Add 1 if no error
add R0, R0, R0       # NOP
add R0, R0, R0       # NOP
sll R14, R14, 1      # Shift the bit over

# forwarded from 2nd to last instr
lw R7, R13, 0        # R7 <= 1
add R0, R0, R0       # NOP
add R14, R14, R7     # Add 1 if no error
add R0, R0, R0       # NOP
add R0, R0, R0       # NOP
sll R14, R14, 1      # Shift the bit over

## src1
# load/use stall then forward
add R0, R0, R0       # NOP
lw R8, R13, 0        # R8 <= 1
add R14, R8, R14     # Add 1 if no error
add R0, R0, R0       # NOP
add R0, R0, R0       # NOP
sll R14, R14, 1      # Shift the bit over

# forwarded from 2nd to last instr
lw R9, R13, 0        # R9 <= 1
add R0, R0, R0       # NOP
add R14, R9, R14     # Add 1 if no error
add R0, R0, R0       # NOP
add R0, R0, R0       # NOP
#### /Memory writeback ####

# Format R14
lhb R14, -1
add R0, R0, R0       # NOP
add R0, R0, R0       # NOP
nor R14, R14, R0     # swap flag bits so 1's denote errors
add R0, R0, R0       # NOP
add R0, R0, R0       # NOP
add R0, R0, R0       # NOP
hlt

#################################
# Reg initialization procedure  #
#################################
RegInit:
llb R1, 1            # R1 <= x0001
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
lhb R13, -128        # R13 <= x8000
llb R14, 0
jr R15
