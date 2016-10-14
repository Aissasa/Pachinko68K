*-----------------------------------------------------------
* Title      : Pachinko Game
* Written by : Aissa Ben Zayed
* Date       : 10-7-2016
* Description: 
*
*-----------------------------------------------------------

*

START  ORG    $1000

    include "equates.X68"

Main:
    
    jsr SetOutputWindow
    jsr SetSomeVars 
    jsr EnableDoubleBuffer
    jsr DrawAllBackground
    jsr DrawBallFirstTime
    jsr PaintScreenBuffer
    
GameLoop:
    
    jsr SetFrameBeginTime

    jsr HandleInput
    
    jsr UpdateBallPosition

    jsr DrawBackgroundChunk
    jsr DrawBall

    jsr WaitToEndFrame
    
    jsr PaintScreenBuffer

    jmp GameLoop          
    
    STOP    #$3000                     

SetOutputWindow:

    ;set the output window dimensions
    move.l  #SET_OUTPUT_WINDOW_COMMAND, d0
    move.l  #OUTPUT_WINDOW_WIDTH, d1
    swap.w  d1
    move.w  #OUTPUT_WINDOW_HEIGHT, d1
    Trap    #15

    rts


UpdateBallPosition:

    ;initialize ball moved to false
    move.b  #(FALSE), (BallMoved)

    ;see if the ball is already dropped
    cmp.b   #(TRUE), (BallDropped)
    beq     BallDropping
    
    ;depending on user input, call drop or Move
    move.l  (PlayerInput), d0
    lsl.l   #2,d0
    lea BallCalls, a1
    move.l  (a1, d0),d1
    
    ;avoid null calls
    cmpi.l  #0, d1
    beq     EndBallUpdate
    
    move.l  d1,a2
    jmp     (a2)

EndBallUpdate:
    
    rts

DropBall:

    move.b  #(TRUE), (BallDropped)

    jmp     EndBallUpdate

MoveBallToLeft:

    ;check if in bounds
    cmp.l   #(TOP_LEFT_BOARD_X_POS), (BallXPosition)
    ble     .DontMove

    move.l  (BallXPosition),d0
    lsl.l   #8,d0

    sub.l   #(BALL_SLIDE_VELOCITY), d0
    move.l  d0, (BallXPositionFixed)

    ;ball moved
    move.b  #(TRUE), (BallMoved)

.DontMove:

    jmp     EndBallUpdate

MoveBallToRight:

    ;check if in bounds
    cmp.l   #(BOTTOM_RIGHT_BOARD_X_POS-BALL_WIDTH), (BallXPosition)
    bge     .DontMove

    move.l  (BallXPosition),d0
    lsl.l   #8,d0
    
    add.l   #(BALL_SLIDE_VELOCITY), d0
    move.l  d0, (BallXPositionFixed)

    ;ball moved
    move.b  #(TRUE), (BallMoved)

.DontMove:

    jmp     EndBallUpdate


BallDropping:

	jsr		CheckWallCollision
	cmp.l 	#(TRUE), d0
	bne		.MoveOnToPegs 

	cmp.b 	#(TRUE), (BallJustCollided)
    bne 	.JustWallCollided

    ;jmp 	.ContinueBallUpdate


.MoveOnToPegs:
    ;check collisions with pegs

    lea 	PegsXs, a1
	lea 	PegsYs, a2
    move.l 	(NumberOfPegs), d7

.NextPeg:
	
	;get current peg
	move.l (LoopCounter), d0
	lsl.l 	#2, d0
	move.l 	(a1, d0), -(sp) ;push y to the stack
	move.l 	(a2, d0), -(sp) ;push x to the stack

    jsr		CheckPegCollision
    ;free stack
    add.l 	#(STACK_OFFSET_IN_PEG_COL), sp

    cmp.l 	#(TRUE), d0		;if colliding, end the loop
    beq 	.EndPegLoop

    add.l 	#1, (LoopCounter) 
    sub.l 	#1, d7			;else, if there are other oegs, check them, else no collision in this frame
    bne		.NextPeg

    ;reinit loop counter
    move.l 	#0, (LoopCounter)

    jmp 	.NotColliding

.EndPegLoop:
    ;check if it just collided
    cmp.b 	#(TRUE), (BallJustCollided)
    bne 	.JustPegCollided

    jmp 	.ContinueBallUpdate

.NotColliding:

	move.b 	#(FALSE), (BallJustCollided)
	jmp 	.ContinueBallUpdate

.JustWallCollided:	

	;bounce
    jsr BounceBallOffWall

	move.b 	#(TRUE), (BallJustCollided)
	jmp 	.DontMove
	;jmp 	.ContinueBallUpdate
	;jmp 	.MoveOnToPegs


.JustPegCollided:	

	;bounce
    jsr BounceBallOffPeg

	move.b 	#(TRUE), (BallJustCollided)
	jmp 	.DontMove
	;jmp 	.ContinueBallUpdate

.ContinueBallUpdate:
.SkipBounceOffPeg:

    cmp.l   #(BOTTOM_RIGHT_BOARD_Y_POS-BALL_HEIGHT), (BallYPosition)
    bge     .DontMove ;reached destination, do something **************************************************************

    ;update x pos
    move.l  (BallXPosition),d0
    lsl.l   #8,d0
    
    add.l   (BallXVelocity), d0
    move.l  d0, (BallXPositionFixed)


    ;update Y vel
    add.l   #(BALL_Y_ACCELERATION), (BallYVelocity)

    ;add the velocity to the y pos
    move.l  (BallYPosition),d0
    lsl.l   #8,d0
    
    add.l   (BallYVelocity), d0
    move.l  d0, (BallYPositionFixed)

    move.b  #(TRUE), BallMoved


.DontMove:

    jmp     EndBallUpdate



SetFrameBeginTime:

    ;get current time
    move.l  #(GET_TIME_COMMAND), d0
    Trap    #15
    ;set FrameBeginTime
    move.l  d1, (FrameBeginTime)

    rts


WaitToEndFrame:

    move.l  (FrameBeginTime),d2

.LoopAgain:
    ;get current time
    move.l  #(GET_TIME_COMMAND), d0
    Trap    #15
    
    ;get DeltaTime in d1
    sub.l   d2,d1

    cmp.l   #(TIME_PER_FRAME), d1
    blt     .LoopAgain

    rts

SetSomeVars:

	jsr 	SeedRandomNumber
	jsr 	RandomizeXVel

	rts


RandomizeXVel:

	jsr 	GetRandomXVel
	move.l 	d0, (BallXVelocity)

	rts



    include "InputHandler.x68"
    include "drawingModule.X68"
    include	"CollisionModule.x68"
    include	"RandomNumberGenerator.x68"
    include	"Math.x68"



;bitmaps
BackgroundBitmap    INCBIN "bg.bmp"
BallBitmap          INCBIN "ironBall.bmp"

;sqrts
Sqrts 				INCBIN  "Sqrts.bin"	

;input
PlayerInput         dc.l    0 ;nothing

;frame rate
FrameBeginTime      dc.l    0

;ball variables
BallCalls           dc.l    EndBallUpdate, DropBall, MoveBallToLeft, MoveBallToRight
BallDropped         dc.b    (FALSE)
BallMoved           dc.b    (FALSE)
BallJustCollided	dc.b 	(FALSE)
BallXPosition       dc.l    (BALL_INITIAL_X_POS)     
BallXPositionFixed  dc.l    (BALL_INITIAL_X_POS<<FRACTION_BITS)
BallYPosition       dc.l    (BALL_INITIAL_Y_POS)     
BallYPositionFixed  dc.l    (BALL_INITIAL_Y_POS<<FRACTION_BITS)
BallXVelocity       dc.l    (BALL_INIT_X_VELOCITY)
BallYVelocity       dc.l    (BALL_INIT_Y_VELOCITY)

PegsXs				;dc.l 	356, 407, 458, 509, 560, 612, 663, 714 			
					dc.l 	384, 435, 486, 538, 589, 640, 691
					dc.l 	356, 407, 458, 509, 560, 612, 663, 714
					dc.l 	384, 435, 486, 538, 589, 640, 691
					dc.l 	356, 407, 458, 509, 560, 612, 663, 714
					dc.l 	384, 435, 486, 538, 589, 640, 691
					dc.l 	356, 407, 458, 509, 560, 612, 663, 714
					dc.l 	384, 435, 486, 538, 589, 640, 691
					dc.l 	356, 407, 458, 509, 560, 612, 663, 714
					dc.l 	384, 435, 486, 538, 589, 640, 691
					dc.l 	356, 407, 458, 509, 560, 612, 663, 714
					dc.l 	384, 435, 486, 538, 589, 640, 691
					dc.l 	356, 407, 458, 509, 560, 612, 663, 714     		; for the lower part of the board


PegsYs				;dc.l 	84, 84, 84, 84, 84, 84, 84, 84
					dc.l 	129, 129, 129, 129, 129, 129, 129
					dc.l 	174, 174, 174, 174, 174, 174, 174, 174
					dc.l 	219, 219, 219, 219, 219, 219, 219
					dc.l 	264, 264, 264, 264, 264, 264, 264, 264
					dc.l 	309, 309, 309, 309, 309, 309, 309
					dc.l 	354, 354, 354, 354, 354, 354, 354, 354
					dc.l 	399, 399, 399, 399, 399, 399, 399
					dc.l 	444, 444, 444, 444, 444, 444, 444, 444
					dc.l 	489, 489, 489, 489, 489, 489, 489
					dc.l 	534, 534, 534, 534, 534, 534, 534, 534
					dc.l 	580, 580, 580, 580, 580, 580, 580
					dc.l 	653, 653, 653, 653, 653, 653, 653, 653			; for the lower part of the board			

ClosestPegX			dc.l 	0
ClosestPegY			dc.l 	0
NumberOfPegs		dc.l 	(PegsYs-PegsXs)
LoopCounter			dc.l 	0

Rand 				ds.l 	1

    END    START

        















































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
