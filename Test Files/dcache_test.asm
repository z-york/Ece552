## This tests the Dcache implementation
## It tests read and write hits and misses with a long array store
## followed by a reading it back. It tests to make sure evictions
## perform the proper writeback. It tests to make sure memory
## address calculations do no saturation

# Initialize registers
jal RegInit
llb R15, 0

# Write an array of 100 1's
lhb R2, 0x7f
llb R3, 100
add R3, R2, R3      # R3 <= x7f64
writeloop:
sw R1, R2, 0
add R2, R2, R1
sub R0, R2, R3
b neq, writeloop

# Load the array back, check sum
llb R2, 0
lhb R2, 0x7f
readloop:
lw R4, R2, 0
add R5, R5, R4
add R2, R2, R1
sub R0, R2, R3
b neq, readloop     # R5 <= x0064

# Write something then evict it
llb R2, 0
lhb R2, 0x7f
sw R5, R2, 5
lw R6, R13, 5       # x8005 evicts x7f05, writeback should occur

# Load evicted entry, check if written back
lw R7, R2, 5        # R7 <= x0064

# Test that addresses are not saturated
sw R5, R13, -1      # should store in x7fff, not saturated x8000
llb R2, 0xff
lhb R2, 0x7f
lw R8, R2, 0        # R8 <= x0064
sw R2, R2, 1        # should store in x8000, not saturated x7fff
lw R9, R13, 0       # R9 <= x7fff

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
