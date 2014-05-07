## This tests for full execution of control instrs before HLT


# Initialize registers
jal RegInit
llb R15, 0

add r0, r0, r0
add r0, r0, r0
add r0, r0, r0

b eq, label1
hlt

label1:
add R5, R5, R1
add r0, r1, r0
b neq, label2
hlt

label2:
add R5, R5, R1
b gt, label3
hlt

label3:
add R5, R5, R1
b gte, label4
hlt

label4:
add R5, R5, R1
sub r0, r0, r1
b lt, label5
hlt

label5:
add R5, R5, R1
sub r0, r0, r1
b lte, label6
hlt

label6:
add R5, R5, R1
b uncond, label7
hlt

label7:
add R5, R5, R1
sub r13, r13, r1
b ovfl, label8:
hlt

label8:
add R5, R5, R1
jal label9
hlt

label9:
add R5, R5, R1      # R5 <= 9
jr r15
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
hlt
