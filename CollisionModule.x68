;Collision stuff file

CheckWallCollision:

	;check if in bounds
    cmp.l   #(TOP_LEFT_BOARD_X_POS), (BallXPosition)
    ble     .Collided

    cmp.l   #(BOTTOM_RIGHT_BOARD_X_POS-BALL_WIDTH), (BallXPosition)
    bge     .Collided

    move.l 	#(FALSE),d0

    jmp	.EndCheck

.Collided:

	move.l 	#(TRUE), d0

.EndCheck:

	rts


CheckPegCollision:
	
	;movem.l	ALL_REG, -(sp)
	;set params
	move.l	(BallXPosition), d0
	add.l 	#(BALL_RADIUS), d0 	;shift to center
	move.l	(BallYPosition), d1
	add.l 	#(BALL_RADIUS), d1 	;shift to center

	move.l	CURRENT_PEG_X_STACK_OFFSET(sp),d2
	move.l 	CURRENT_PEG_Y_STACK_OFFSET(sp),d3

	;check if we even should do collision check
	;dy is first
	cmp.l	d1,d3 
	bge		.SubBallYPegY ; if peg y bigger
	
	sub.l	d3,d1
	move.l	d1,d5				;dy
	jmp		.CheckDy

.SubBallYPegY:

	sub.l	d1,d3
	move.l 	d3, d5				;dy

.CheckDy:

	cmp.l	#(MIN_DY_TO_CHECK_COLLISION), d5
	bgt		.DidntCollide

	;dx is second
	cmp.l	d0,d2 
	bge		.SubBallXPegX ; if peg x bigger
	
	sub.l	d2,d0
	move.l	d0,d4				;dx
	jmp		.CheckDx

.SubBallXPegX:

	sub.l	d0,d2
	move.l 	d2, d4				;dx

.CheckDx:

	cmp.l	#(MIN_DX_TO_CHECK_COLLISION), d4
	bgt		.DidntCollide

	;store the closest peg coor
	move.l	CURRENT_PEG_X_STACK_OFFSET(sp),(ClosestPegX)
	move.l 	CURRENT_PEG_Y_STACK_OFFSET(sp),(ClosestPegY)

	;if we're here. we check for collision
	move.l	d4,d0	;dx
	mulu.w 	d4,d0	;d0 = dx^2
	move.l	d5,d1	;dy
	mulu.w 	d5,d1	;d1 = dy^2

	add.l	d0, d1	;d1 = dx^2 + dy^2
	lsl.l 	#2, d1 	
	lea 	(Sqrts), a6

	move.l	(a6, d1), d0  	;d0 = sqrt(dx^2 + dy^2) with no byte swap
	
	jsr 	SwapBytes 		;d0 bytes are swapped, so it has the correct sqrt

	lsr.l 	#(FRACTION_BITS),d0

	;combine radiuses
	move.l 	#(BALL_RADIUS), d1
	add.l 	#(PEG_RADIUS), d1

	cmp.l 	d1, d0
	bgt		.DidntCollide

	move.l 	#(TRUE), d0

	jmp		.CheckEnd


.DidntCollide:

	move.l 	#(FALSE), d0

.CheckEnd:
	;movem.l	(sp)+, ALL_REG

	rts


BounceBallOffWall:

	move.l 	(BallXVelocity), d0
	muls.w 	#(HALF), d0		
    asr.l   #(FRACTION_BITS),d0		;soften collision

    neg.l 	d0
    move.l 	d0, (BallXVelocity)

    rts



BounceBallOffPeg:

	;set tangent vect
	move.l 	(ClosestPegY),d0
	sub.l 	(BallYPosition), d0		
	add.l 	#(BALL_RADIUS), d0		;d0 = tgX = Ypeg - Yball
	move.l 	(BallXPosition), d1
	sub.l 	(ClosestPegX), d1		
	add.l 	#(BALL_RADIUS), d1		;d1 = tgY = Xball - Xpeg


	;get vect length
	move.l 	d0, d6
	move.l 	d1, d7

	muls.w 	d0, d6					;d6 = tgX ^ 2
	muls.w 	d1, d7					;d7 = tgY ^ 2

	add.l 	d6, d7					;d7 = tgX ^ 2 + tgY ^ 2

	lsl.l 	#2, d7 	
	lea 	(Sqrts), a6

	move.l	(a6, d7), d2  			;d2 = TgMag = sqrt(tgX ^ 2 + tgY ^ 2) with no byte swap

	move.l 	d0, d7					;store tgX
	move.l 	d2, d0
	
	jsr 	SwapBytes 				
	lsr.l 	#(FRACTION_BITS),d0

	move.l 	d0, d2					;d2 bytes are swapped, so it has the correct sqrt
	move.l 	d7, d0					;restore d0


	;get normalized tangent
	divs.w 	d2, d0					;Xtg
	swap 	d0
	clr.w 	d0
	swap 	d0
	divs.w 	d2, d1					;Ytg
	swap 	d1
	clr.w 	d1
	swap 	d1


	;get length by calculating the dot product
	;copy x and y
	move.l 	d0, d2 					;Xtg
	move.l 	d1, d3 					;Ytg

	;get velocity
	move.l 	(BallXVelocity), d6
	move.l 	(BallYVelocity), d7
	; dot product
	muls.w 	d6, d2					
	muls.w 	d7, d3

	asr.l 	#(FRACTION_BITS),d2
	asr.l 	#(FRACTION_BITS),d3


	add.l 	d2, d3 					
	move.l 	d3, d4					;d4 = length

	;get the velocity comp parallel to the tg
	;copy x and y of tg
	move.l 	d0, d2 					;Xtg
	move.l 	d1, d3 					;Ytg

	muls.w 	d4, d2					;d2 = Xparal = length * Xtg
	muls.w 	d4, d3					;d3 = Yparal = length * Ytg

	;get velocity
	move.l 	(BallXVelocity), d0 	;Xvel
	move.l 	(BallYVelocity), d1 	;Yvel

	;get the velocity comp perpendicular to the tg
	sub.l 	d2, d0					;d0 = Xper = Xvel - Xparal
	sub.l 	d3, d1					;d1 = Yper = Yvel - Yparal

	;get the new velocity
	asl.l 	#2, d0 	
	asl.l 	#2, d1

	move.l 	(BallXVelocity), d2 	;Xvel
	move.l 	(BallYVelocity), d3 	;Yvel
 	 	
	sub.l 	d0, d2					;d2 = NewXvel = Xvel - 2 * Xper
	sub.l 	d1, d3					;d3 = NewYvel = Yvel - 2 * Yper

	muls.w 	#(HALF), d2		;soften collision
    asr.l   #(FRACTION_BITS),d2	
    muls.w 	#(ONE_TENTH), d3
    asr.l   #(FRACTION_BITS),d3


	;update the velocity
	move.l 	d2, (BallXVelocity)
	move.l 	d3, (BallYVelocity)


	rts










