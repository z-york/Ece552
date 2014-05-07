## This tests for full execution of ADD before HLT


# Initialize registers
jal RegInit
llb R15, 0

add r0, r0, r0
add r0, r0, r0
add r0, r0, r0

add r2, r1, r0
add r3, r2, r0
add r4, r3, r3
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
