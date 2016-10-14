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
    jsr DrawLoading
    jsr SetSomeVars 
    jsr EnableDoubleBuffer
    jsr DrawAllBackground
    jsr DrawBallFirstTime
    jsr UpdateScoreLed
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

	;see if we have to RestartGame
	cmp.b 	#(TRUE), (HaveToRestart)
	beq 	RestartGame

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
	bne		.BallNotColWithWall 

	cmp.b 	#(TRUE), (BallJustWallCol)
    bne 	.JustWallCollided

    jmp 	.ContinueBallUpdate

.BallNotColWithWall:

	move.b 	#(FALSE), (BallJustWallCol)
	jmp 	.MoveOnToPegs

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
    cmp.b 	#(TRUE), (BallJustPegCol)
    bne 	.JustPegCollided

    jmp 	.ContinueBallUpdate

.NotColliding:

	move.b 	#(FALSE), (BallJustPegCol)
	jmp 	.ContinueBallUpdate

.JustWallCollided:	

	;bounce
    jsr BounceBallOffWall

    lea 	WallCollisionSound, a1
	jsr 	PlaySound


	move.b 	#(TRUE), (BallJustWallCol)
	jmp 	.DontMove


.JustPegCollided:	

	;bounce
    jsr BounceBallOffPeg

    ;set sound to play to a1
	lea 	CollisionSound, a1
	jsr 	PlaySound

	move.b 	#(TRUE), (BallJustPegCol)
	jmp 	.DontMove

.ContinueBallUpdate:
.SkipBounceOffPeg:

    cmp.l   #(BOTTOM_RIGHT_BOARD_Y_POS-BALL_HEIGHT), (BallYPosition)
    bge     .AddScore 

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

.AddScore:
	
	move.l 	#(EndScoresInGame-ScoresInGame), d0
	lea 	ScoresBounds, a6

	clr.l 	d3 		;counter
	move.l (BallXPosition), d4
	add.l 	#(BALL_WIDTH),d4

.ScoreLoop:

	move.l (a6)+, d1
	move.l (a6)+, d2

	cmp.l 	d4, d1
	bgt 	.NextIteration

	cmp.l 	d4, d2
	bge 	.FoundScore


.NextIteration:

	add.l 	#1, d3
	sub.l 	#1, d0
	bne 	.ScoreLoop

	jmp 	.ExitLoop 		

.FoundScore:

	clr.l 	d1
	lea 	ScoresInGame, a6
	add.l 	d3, a6
	move.b 	(a6), d1
	add.l 	d1, (Score)

.ExitLoop:
	
	;set sound to play to a1
	lea 	ScoreSound, a1
	jsr 	PlaySound

	move.b 	#(TRUE), (HaveToRestart)
    jmp     EndBallUpdate

RestartGame:

	add.b 	#1, (UsedBalls)
	move.b 	#(FALSE), (HaveToRestart)
	move.b 	#(TRUE), (BallMoved)
	move.b 	#(FALSE), (BallDropped)

	;reset pos
	move.l 	#(BALL_INITIAL_X_POS), d0
	lsl.l 	#(FRACTION_BITS), d0
	move.l 	d0, (BallXPositionFixed)

	move.l 	#(BALL_INITIAL_Y_POS), d0
	lsl.l 	#(FRACTION_BITS), d0
	move.l 	d0, (BallYPositionFixed)


	;reset velocity
	move.l 	#0, BallXVelocity
	move.l 	#0, BallYVelocity


	jsr OverrideScore
	jsr UpdateScoreLed



    jmp   	EndBallUpdate


PlaySound:

	move.l 	#(PLAY_SOUND_COMMAND), d0
	Trap 	#15

	rts


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
    include	"Led.x68"



;bitmaps
BackgroundBitmap    INCBIN "bg.bmp"
BallBitmap          INCBIN "ironBall.bmp"
LoadingBitmap       INCBIN "loading.bmp"

;Sounds 
CollisionSound 		dc.b	'Collision.wav', 0
WallCollisionSound 	dc.b	'WallCollision.wav', 0
ScoreSound 			dc.b	'Score.wav', 0

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
BallJustPegCol		dc.b 	(FALSE)
BallJustWallCol		dc.b 	(FALSE)
BallXPosition       dc.l    (BALL_INITIAL_X_POS)     
BallXPositionFixed  dc.l    (BALL_INITIAL_X_POS<<FRACTION_BITS)
BallYPosition       dc.l    (BALL_INITIAL_Y_POS)     
BallYPositionFixed  dc.l    (BALL_INITIAL_Y_POS<<FRACTION_BITS)
BallXVelocity       dc.l    (BALL_INIT_X_VELOCITY)
BallYVelocity       dc.l    (BALL_INIT_Y_VELOCITY)

PegsXs				dc.l 	394, 545, 696 			
					dc.l 	340, 473, 616, 742
					dc.l 	394, 545, 696 			
					dc.l 	340, 473, 616, 742
					dc.l 	374, 490, 606, 708     		; for the lower part of the board


PegsYs				dc.l 	167, 167, 167
					dc.l 	297, 297, 297, 297
					dc.l 	430, 430, 430
					dc.l 	564, 564, 564, 564
					dc.l 	700, 700, 700, 700			; for the lower part of the board			

ClosestPegX			dc.l 	0
ClosestPegY			dc.l 	0
NumberOfPegs		dc.l 	(PegsYs-PegsXs)>>2
LoopCounter			dc.l 	0

Rand 				ds.l 	1

HaveToRestart 		dc.l 	(FALSE)

LedDigitsTable 		dc.b 	$3f, $06,$5b, $4f, $66, $6d, $7d, $07, $7f, $67
CurrentLedStartX 	dc.l  	0
CurrentLedStartY 	dc.l  	0

UsedBalls 			dc.l 	0

Score 				dc.l 	0
ScoresBounds 		dc.l 	385, 480, 500, 596, 618, 698
ScoresInGame 		dc.b 	2, 5, 3 	 		
EndScoresInGame
    
    END    START

        




















































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
