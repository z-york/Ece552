## This test checks for proper use of lw/sw immediates,
## tests all branch instructions, as well as jal and jr.
##
## Note: Loads and Stores clobber some instructions, but
## not until well past their execution, so I'm not going
## to bother fixing it (especially since some tests want
## the calculated address to be zero to test flag setting)
llb R1, 17
lhb R1, 17
llb R2, 34
lhb R2, 34
llb R3, 51
lhb R3, 51
llb R4, 68
lhb R4, 68
llb R5, 85
lhb R5, 85
llb R6, 102
lhb R6, 102
llb R7, 119
lhb R7, 119
llb R8, 136
lhb R8, 136
llb R9, 153
lhb R9, 153
llb R10, 170
lhb R10, 170
llb R11, 187
lhb R11, 187
llb R12, 204
lhb R12, 204
llb R13, 221
lhb R13, 221
llb R14, 238
lhb R14, 238
llb R15, 255
lhb R15, 255

## Test load/store immediates
sw R15, R5, 7
llb R1, 1               # R1 = 0001
add R5, R5, R1        
lw R2, R5, 6            # R2 = ffff
sw R15, R5, -8
sub R5, R5, R1        
lw R3, R5, -7           # R3 = ffff

## Test JAL and JR
llb R4, 1
llb R8, 44
jal label        
add R4, R4, R8          # R4 = 000e     not 000f, not 0000
jr R4
label: llb R4, 0
jr R15
b uncond, label2
llb R4, 0

label2:

## Test b neq
add R8, R8, R1          # Z is set to 0, none of the following should reset
llb R14, 0              # R14 = 0000 This is the error flag register
sw R8, R0, 0
lw R8, R0, 0
jal flagtest
b neq, bneqtest
add R14, R14, R1        # signal error
bneqtest:

## Test b eq and b gte and b lte
add R8, R0, R0          # Z is set to 1, none of the following should reset
sw R8, R4, 1
lw R8, R4, 1
jal flagtest
b eq, beqtest
add R14, R14, R1        # signal error
beqtest:
b gte, bgtetest1
add R14, R14, R1        # signal error
bgtetest1:
b lte, bltetest1
add R14, R14, R1        # signal error
bltetest1:

## Test b gt and b gte
add R8, R1, R1          # N is set to 0, none of the following should reset
llb R7, -5
sw R7, R4, -1
lw R7, R4, -1
and R7, R7, R7
nor R7, R8, R0
sll R7, R2, 1
srl R7, R2, 0
sra R7, R2, 4
add R8, R8, R1          # Z is set to 0, none of the following should reset
sw R8, R0, 0
lw R8, R0, 0
jal flagtest
b gt, bgttest
add R14, R14, R1        # signal error
bgttest:
b gte, bgtetest2
add R14, R14, R1        # signal error
bgtetest2:

## Test b lt and b lte
add R7, R2, R0          # N is set to 1, none of the following should reset
llb R8, 5
sw R8, R4, 6
lw R8, R4, 6
and R8, R8, R8
sll R8, R1, 1
nor R8, R7, R0
srl R8, R2, 8
sra R8, R1, 0           # Z is set to 0, so we are only testing N=1
jal flagtest
b lt, blttest        
add R14, R14, R1        # signal error
blttest:
b lte, bltetest2
add R14, R14, R1        # signal error
bltetest2:

## Test b ovfl
add R8, R1, R1          # ov is 0
b ovfl, bad
b uncond, good
bad:
add R14, R14, R1
good:
add R7, R9, R9          # ov is set to 1, none of the following should reset
sw R8, R4, 6            # R7 = ffff
lw R8, R4, 6
and R8, R8, R8
sll R8, R1, 1
nor R8, R2, R0
srl R8, R2, 8
sra R8, R1, 0           # R8 = 0001
jal flagtest
b ovfl, bovfltest
add R14, R14, R1
bovfltest:

## Test b uncond
b uncond, finished
flagtest: jr R15
finished:
hlt
