;Collision stuff file

CheckCollision:
	
	;movem.l	ALL_REG, -(sp)
	;set params
	move.l	(BallXPosition), d0
	move.l	(BallYPosition), d1

	;clr.l 	d2
	;clr.l	d3
	move.l	(PegsXs),d2
	move.l 	(PegsYs),d3

	;check if we even should do collision check
	;dy is first
	cmp.l	d1,d3 
	bge		.SubBallYFromPegY ; if peg y bigger
	
	sub.l	d3,d1
	move.l	d1,d5				;dy
	jmp		.CheckDy

.SubBallYFromPegY:

	sub.l	d1,d3
	move.l 	d3, d5				;dy

.CheckDy:

	cmp.l	#(MIN_DY_TO_CHECK_COLLISION), d5
	bgt		.DidntCollide

	;dx is second
	cmp.l	d0,d2 
	bge		.SubBallXFromPegX ; if peg x bigger
	
	sub.l	d2,d0
	move.l	d0,d4				;dx
	jmp		.CheckDx

.SubBallXFromPegX:

	sub.l	d0,d2
	move.l 	d2, d4				;dx

.CheckDx:

	cmp.l	#(MIN_DX_TO_CHECK_COLLISION), d4
	bgt		.DidntCollide

	
	;if we're here. we check for collision
	;move.l	d4,d0	;dx
	;mulu.w 	d4,d0	;d0 = dx^2
	;move.l	d5,d1	;dy
	;mulu.w 	d5,d1	;d1 = dy^2

	;add.l	d0, d1	;d1 = dx^2 + dy^2

	;lea 	(Sqrts), a6
	;move.l	(a6, d1), d0  ;d0 = sqrt(dx^2 + dy^2) with now byte swap
	
	;jsr 	SwapBytes 		;d0 bytes are swapped, so it has the correct sqrt

	;lsr.l 	#(FRACTION_BITS),d0


	;comnine radiuses
	;move.l 	#(BALL_RADIUS), d1
	;add.l 	#(PEG_RADIUS), d1

	;cmp.l 	d1, d0
	;bgt		.DidntCollide

	move.l 	#(TRUE), d0

	jmp		.CheckEnd


.DidntCollide:

	move.l 	#(FALSE), d0

.CheckEnd:
	;movem.l	(sp)+, ALL_REG

	rts













