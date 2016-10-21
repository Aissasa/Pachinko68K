;led

UpdateScoreLed:

	move.l 	(Score), d0

	jsr 	GetDigits

	; display digits
	;set pen color
	move.l 	#(SET_PEN_COLOR_COMMAND), d0
	move.l 	#(WHITE), d1
	Trap 	#15

	;begin drawing third digit
	lea 	LedDigitsTable, a6
	move.b 	(a6, d7), d0
	;update start pos			
	move.l 	#(SCORE_LED_START_X), (CurrentLedStartX)
	move.l 	#(SCORE_LED_START_Y), (CurrentLedStartY)

	jsr DrawDigit

	;draw second digit
	move.b 	(a6, d6), d0
	;update start pos			
	add.l 	#(SCORE_LED_DIGIT_WIDTH), (CurrentLedStartX)
	add.l 	#(SCORE_LED_DIGIT_OFFSET), (CurrentLedStartX)

	jsr DrawDigit

	;draw third digit
	move.b 	(a6, d5), d0
	;update start pos			
	add.l 	#(SCORE_LED_DIGIT_WIDTH), (CurrentLedStartX)
	add.l 	#(SCORE_LED_DIGIT_OFFSET), (CurrentLedStartX)

	jsr DrawDigit


	rts


UpdateBallsLed:

	move.l 	(UsedBalls), d0

	jsr 	GetDigits

	; display digits
	;set pen color
	move.l 	#(SET_PEN_COLOR_COMMAND), d0
	move.l 	#(WHITE), d1
	Trap 	#15

	;begin drawing third digit
	lea 	LedDigitsTable, a6
	move.b 	(a6, d7), d0
	;update start pos			
	move.l 	#(BALLS_LED_START_X), (BallsLedStartX)
	move.l 	#(BALLS_LED_START_Y), (BallsLedStartY)

	jsr DrawDigit

	;draw second digit
	move.b 	(a6, d6), d0
	;update start pos			
	add.l 	#(BALLS_LED_DIGIT_WIDTH), (BallsLedStartX)
	add.l 	#(BALLS_LED_DIGIT_OFFSET), (BallsLedStartY)

	jsr DrawDigit

	;draw third digit
	move.b 	(a6, d5), d0
	;update start pos			
	add.l 	#(BALLS_LED_DIGIT_WIDTH), (BallsLedStartX)
	add.l 	#(BALLS_LED_DIGIT_OFFSET), (BallsLedStartY)

	jsr DrawDigitBl


	rts	


;params: d0: the number, returns d5: first digit, d6, second digit, d7: third digit
GetDigits:

	clr.l 	d5
	clr.l 	d6
	clr.l 	d7

	divu.w 	#10, d0
	swap.w 	d0
	move.w 	d0, d5			;first digit

	clr.w 	d0
	swap.w 	d0

	cmp.l 	#0, d0
	beq 	.End

	divu.w 	#10, d0
	swap.w 	d0
	move.w 	d0, d6			;second digit

	clr.w 	d0
	swap.w 	d0

	cmp.l 	#0, d0
	beq 	.End

	divu.w 	#10, d0
	swap.w 	d0
	move.w 	d0, d7			;third digit

	clr.w 	d0
	swap.w 	d0

	cmp.l 	#0, d0
	beq 	.End

.End:

	rts



DrawDigit:

	movem.l 	ALL_REG, -(sp)

	move.b 	d0, d6
	move.b 	d6, d7
	and.b 	#1, d7
	cmp.b 	#1, d7
	beq 	.DrawA

.DrawABack:
	
	lsr.b 	#1, d6
	move.b 	d6, d7
	and.b 	#1, d7
	cmp.b 	#1, d7
	beq 	.DrawB


.DrawBBack:	

	lsr.b 	#1, d6
	move.b 	d6, d7
	and.b 	#1, d7
	cmp.b 	#1, d7
	beq 	.DrawC



.DrawCBack:	

	lsr.b 	#1, d6
	move.b 	d6, d7
	and.b 	#1, d7
	cmp.b 	#1, d7
	beq 	.DrawD

.DrawDBack:	

	lsr.b 	#1, d6
	move.b 	d6, d7
	and.b 	#1, d7
	cmp.b 	#1, d7
	beq 	.DrawE

.DrawEBack:	

	lsr.b 	#1, d6
	move.b 	d6, d7
	and.b 	#1, d7
	cmp.b 	#1, d7
	beq 	.DrawF

.DrawFBack:	

	lsr.b 	#1, d6
	move.b 	d6, d7
	and.b 	#1, d7
	cmp.b 	#1, d7
	beq 	.DrawG

.DrawGBack:		

	
	movem.l 	(sp)+, ALL_REG, 

	rts

.DrawA:	

	; set points
	move.l 	(CurrentLedStartX), d1
	move.l 	(CurrentLedStartY), d2
	move.l 	(CurrentLedStartX), d3
	move.l 	(CurrentLedStartY), d4

	add.l 	#(SCORE_LED_DIGIT_WIDTH), d3

	;draw line
	move.l 	#(DRAW_LINE_COMMAND), d0
	Trap 	#15

	jmp .DrawABack

.DrawB:	
	
	; set points
	move.l 	(CurrentLedStartX), d1
	move.l 	(CurrentLedStartY), d2
	move.l 	(CurrentLedStartX), d3
	move.l 	(CurrentLedStartY), d4

	add.l 	#(SCORE_LED_DIGIT_WIDTH), d1
	add.l 	#(SCORE_LED_DIGIT_WIDTH), d3
	add.l 	#(SCORE_LED_LINE_HEIGHT), d4

	;draw line
	move.l 	#(DRAW_LINE_COMMAND), d0
	Trap 	#15

	jmp .DrawBBack

.DrawC:	

	; set points
	move.l 	(CurrentLedStartX), d1
	move.l 	(CurrentLedStartY), d2
	move.l 	(CurrentLedStartX), d3
	move.l 	(CurrentLedStartY), d4

	add.l 	#(SCORE_LED_DIGIT_WIDTH), d1
	add.l 	#(SCORE_LED_LINE_HEIGHT), d2
	add.l 	#(SCORE_LED_DIGIT_WIDTH), d3
	add.l 	#(SCORE_LED_DIGIT_HEIGHT), d4

	;draw line
	move.l 	#(DRAW_LINE_COMMAND), d0
	Trap 	#15


	jmp .DrawCBack

.DrawD:	

	; set points
	move.l 	(CurrentLedStartX), d1
	move.l 	(CurrentLedStartY), d2
	move.l 	(CurrentLedStartX), d3
	move.l 	(CurrentLedStartY), d4

	add.l 	#(SCORE_LED_DIGIT_WIDTH), d1
	add.l 	#(SCORE_LED_DIGIT_HEIGHT), d2
	add.l 	#(SCORE_LED_DIGIT_HEIGHT), d4

	;draw line
	move.l 	#(DRAW_LINE_COMMAND), d0
	Trap 	#15


	jmp .DrawDBack

.DrawE:	

	; set points
	move.l 	(CurrentLedStartX), d1
	move.l 	(CurrentLedStartY), d2
	move.l 	(CurrentLedStartX), d3
	move.l 	(CurrentLedStartY), d4

	add.l 	#(SCORE_LED_DIGIT_HEIGHT), d2
	add.l 	#(SCORE_LED_LINE_HEIGHT), d4

	;draw line
	move.l 	#(DRAW_LINE_COMMAND), d0
	Trap 	#15


	jmp .DrawEBack

.DrawF:	

	; set points
	move.l 	(CurrentLedStartX), d1
	move.l 	(CurrentLedStartY), d2
	move.l 	(CurrentLedStartX), d3
	move.l 	(CurrentLedStartY), d4

	add.l 	#(SCORE_LED_LINE_HEIGHT), d2

	;draw line
	move.l 	#(DRAW_LINE_COMMAND), d0
	Trap 	#15


	jmp .DrawFBack

.DrawG:	

	; set points
	move.l 	(CurrentLedStartX), d1
	move.l 	(CurrentLedStartY), d2
	move.l 	(CurrentLedStartX), d3
	move.l 	(CurrentLedStartY), d4

	add.l 	#(SCORE_LED_LINE_HEIGHT), d2
	add.l 	#(SCORE_LED_DIGIT_WIDTH), d3
	add.l 	#(SCORE_LED_LINE_HEIGHT), d4

	;draw line
	move.l 	#(DRAW_LINE_COMMAND), d0
	Trap 	#15


	jmp .DrawGBack


DrawDigitBl:

	movem.l 	ALL_REG, -(sp)

	move.b 	d0, d6
	move.b 	d6, d7
	and.b 	#1, d7
	cmp.b 	#1, d7
	beq 	.DrawABl

.DrawABackBl:
	
	lsr.b 	#1, d6
	move.b 	d6, d7
	and.b 	#1, d7
	cmp.b 	#1, d7
	beq 	.DrawBBl


.DrawBBackBl:	

	lsr.b 	#1, d6
	move.b 	d6, d7
	and.b 	#1, d7
	cmp.b 	#1, d7
	beq 	.DrawCBl



.DrawCBackBl:	

	lsr.b 	#1, d6
	move.b 	d6, d7
	and.b 	#1, d7
	cmp.b 	#1, d7
	beq 	.DrawDBl

.DrawDBackBl:	

	lsr.b 	#1, d6
	move.b 	d6, d7
	and.b 	#1, d7
	cmp.b 	#1, d7
	beq 	.DrawEBl

.DrawEBackBl:	

	lsr.b 	#1, d6
	move.b 	d6, d7
	and.b 	#1, d7
	cmp.b 	#1, d7
	beq 	.DrawFBl

.DrawFBackBl:	

	lsr.b 	#1, d6
	move.b 	d6, d7
	and.b 	#1, d7
	cmp.b 	#1, d7
	beq 	.DrawGBl

.DrawGBackBl:		

	
	movem.l 	(sp)+, ALL_REG, 

	rts

.DrawABl:	

	; set points
	move.l 	(BallsLedStartX), d1
	move.l 	(BallsLedStartY), d2
	move.l 	(BallsLedStartX), d3
	move.l 	(BallsLedStartY), d4

	add.l 	#(BALLS_LED_DIGIT_WIDTH), d3

	;draw line
	move.l 	#(DRAW_LINE_COMMAND), d0
	Trap 	#15

	jmp .DrawABackBl

.DrawBBl:	
	
	; set points
	move.l 	(BallsLedStartX), d1
	move.l 	(BallsLedStartY), d2
	move.l 	(BallsLedStartX), d3
	move.l 	(BallsLedStartY), d4

	add.l 	#(BALLS_LED_DIGIT_WIDTH), d1
	add.l 	#(BALLS_LED_DIGIT_WIDTH), d3
	add.l 	#(BALLS_LED_LINE_HEIGHT), d4

	;draw line
	move.l 	#(DRAW_LINE_COMMAND), d0
	Trap 	#15

	jmp .DrawBBackBl

.DrawCBl:	

	; set points
	move.l 	(BallsLedStartX), d1
	move.l 	(BallsLedStartY), d2
	move.l 	(BallsLedStartX), d3
	move.l 	(BallsLedStartY), d4

	add.l 	#(BALLS_LED_DIGIT_WIDTH), d1
	add.l 	#(BALLS_LED_LINE_HEIGHT), d2
	add.l 	#(BALLS_LED_DIGIT_WIDTH), d3
	add.l 	#(BALLS_LED_DIGIT_HEIGHT), d4

	;draw line
	move.l 	#(DRAW_LINE_COMMAND), d0
	Trap 	#15


	jmp .DrawCBackBl

.DrawDBl:	

	; set points
	move.l 	(BallsLedStartX), d1
	move.l 	(BallsLedStartY), d2
	move.l 	(BallsLedStartX), d3
	move.l 	(BallsLedStartY), d4

	add.l 	#(BALLS_LED_DIGIT_WIDTH), d1
	add.l 	#(BALLS_LED_DIGIT_HEIGHT), d2
	add.l 	#(BALLS_LED_DIGIT_HEIGHT), d4

	;draw line
	move.l 	#(DRAW_LINE_COMMAND), d0
	Trap 	#15


	jmp .DrawDBackBl

.DrawEBl:	

	; set points
	move.l 	(BallsLedStartX), d1
	move.l 	(BallsLedStartY), d2
	move.l 	(BallsLedStartX), d3
	move.l 	(BallsLedStartY), d4

	add.l 	#(BALLS_LED_DIGIT_HEIGHT), d2
	add.l 	#(BALLS_LED_LINE_HEIGHT), d4

	;draw line
	move.l 	#(DRAW_LINE_COMMAND), d0
	Trap 	#15


	jmp .DrawEBackBl

.DrawFBl:	

	; set points
	move.l 	(BallsLedStartX), d1
	move.l 	(BallsLedStartY), d2
	move.l 	(BallsLedStartX), d3
	move.l 	(BallsLedStartY), d4

	add.l 	#(BALLS_LED_LINE_HEIGHT), d2

	;draw line
	move.l 	#(DRAW_LINE_COMMAND), d0
	Trap 	#15


	jmp .DrawFBackBl

.DrawGBl:	

	; set points
	move.l 	(BallsLedStartX), d1
	move.l 	(BallsLedStartY), d2
	move.l 	(BallsLedStartX), d3
	move.l 	(BallsLedStartY), d4

	add.l 	#(BALLS_LED_LINE_HEIGHT), d2
	add.l 	#(BALLS_LED_DIGIT_WIDTH), d3
	add.l 	#(BALLS_LED_LINE_HEIGHT), d4

	;draw line
	move.l 	#(DRAW_LINE_COMMAND), d0
	Trap 	#15


	jmp .DrawGBackBl






	




