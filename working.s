addi $r9, $r0, 0 // initialize not moving
addi $r15, $r0, 0
addi $r20, $r0, 0
nop
nop
process_inputs:
nop
nop
lw $r1, 4000($r0) 	// buttons pressed
lw $r2, 4001($r0)
lw $r3, 4002($r0)
lw $r4, 4003($r0)
sw $r0, 4005($r0)	// reset all inputs
nop
nop
sw $r15, 4030($r0)
sw $r16, 4031($r0)
sw $r17, 4032($r0)
sw $r18, 4033($r0)
nop
nop
nop
process_buttons:
add $r5, $r1, $r2	 
add $r6, $r3, $r4 	// calculate dest
add $r7, $r5, $r6 	// calculate input destination
nop
nop
nop
bne $r7, $r0, process_push // if(button input != 0) push to queue
nop
j determine_move	// else determine moves
nop
nop
nop
process_push:
nop
bne $r25, $r7, shift_in		// if most recent != input destination, push to queue fr
nop
nop
nop
bne $r20, $r0, determine_move
nop
nop
nop
j process_inputs		// if input == current destination read next input
nop
nop
shift_in:
nop
bne $r20, $r0, determine_move
nop
nop
addi $r20, $r7, 0		// next destination = input
nop
nop
addi $r25, $r7, 0		// keep track of most recent
nop
nop
shift1:
nop
nop
nop
bne $r19, $r0, determine_move	// if next in queue != null, cancel
nop
nop
addi $r19, $r20, 0
addi $r20, $r0, 0
nop
nop
shift2:
nop
nop
nop
bne $r18, $r0, determine_move
nop
nop
addi $r18, $r19, 0
addi $r19, $r0, 0
nop
nop
shift3:
nop
nop
nop
bne $r17, $r0, determine_move
nop
nop
addi $r17, $r18, 0
addi $r18, $r0, 0
nop
nop
shift4:
nop
nop
nop
bne $r16, $r0, determine_move
nop
nop
addi $r16, $r17, 0
addi $r17, $r0, 0
nop
nop
shift6:
nop
nop
nop
bne $r15, $r0, determine_move
nop
nop
addi $r15, $r16, 0
addi $r16, $r0, 0
nop
nop
determine_move:
nop
nop
nop
bne $r15, $r0, move_to_dst 	// if destination != 0, attempt move
nop
nop
addi $r9, $r0, 0		// if destination == 0, stop moving
nop
j process_inputs
nop
move_to_dst:
nop
lw $r8, 4004($r0) 	// current floor
nop
nop
nop
bne $r15, $r8, motor_on 	// if current destination != current floor, move
nop
nop
motor_off:
nop
addi $r9, $r0, 0		// if current destination == current floor, stop and shift queue
addi $r11, $r0, 0
nop
addi $r15, $r16, 0
addi $r16, $r17, 0
addi $r17, $r18, 0
addi $r18, $r19, 0
addi $r19, $r20, 0
addi $r20, $r0, 0
nop
j send_move
nop
nop
motor_on:
nop
addi $r9, $r0, 1   		// start moving
sub $r10, $r15, $r8 		// calculate direction
nop
blt $r10, $r0, clockwise
nop
nop
counterclockwise:
addi $r12, $r0, 170
addi $r13, $r0, 1000
nop
nop
nop
mul $r11, $r12, $r13
nop
j send_move
nop
clockwise:
nop
addi $r12, $r0, 130
addi $r13, $r0, 1000
nop
nop
nop
mul $r11, $r12, $r13
send_move:
nop
sw $r15, 4020($r0)   // SEND DESTINATION
sw $r10, 4021($r0)  // SEND DIRECTION
sw $r9, 4022($r0)  // SEND MOVING
sw $r11, 4023($r0)  // SEND DUTY CYCLE
nop
nop

j process_inputs
