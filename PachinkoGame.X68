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

    jsr PaintScreenBuffer

    jsr WaitToEndFrame

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

    ;depending on user input, call drop or Move
    move.l  (PlayerInput), d0
    lsl.l   #2,d0
    lea BallCalls, a1
    move.l  (a1, d0),d1
    
    cmpi.l  #0, d1
    beq     NoBallUpdate
    
    move.l  d1,a2
    jmp     (a2)

NoBallUpdate:
    
    rts

DropBall:

    ;add drop ball code
    
    move.b  #(TRUE), (BallDropped)

    jmp     NoBallUpdate

MoveBallToLeft:

    cmp.b   #(TRUE), (BallDropped)
    beq     NoBallUpdate                ; change this after making the game work

    ;check if in bounds
    cmp.l   #(TOP_LEFT_BOARD_X_POS), (BallXPosition)
    ble     .DontMove

    move.l  (BallXPosition),d0
    lsl.l   #8,d0

    sub.l   #(BALL_X_VELOCITY), d0
    move.l  d0, (BallXPositionFixed)

    ;ball moved
    move.b  #(TRUE), (BallMoved)

.DontMove:

    jmp     NoBallUpdate

MoveBallToRight:

    cmp.b   #(TRUE), (BallDropped)
    beq     NoBallUpdate                ; change this after making the game work

    ;check if in bounds
    cmp.l   #(BOTTOM_RIGHT_BOARD_X_POS-BALL_WIDTH), (BallXPosition)
    bge     .DontMove

    move.l  (BallXPosition),d0
    lsl.l   #8,d0
    
    add.l   #(BALL_X_VELOCITY), d0
    move.l  d0, (BallXPositionFixed)

    ;ball moved
    move.b  #(TRUE), (BallMoved)

.DontMove:

    jmp     NoBallUpdate


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




    include "InputHandler.x68"
    include "drawingModule.X68"



;bitmaps
BackgroundBitmap    INCBIN "bg.bmp"
BallBitmap          INCBIN  "ironBall.bmp"

;input
PlayerInput         dc.l    0 ;nothing

;frame rate
FrameBeginTime  dc.l    0

;ball variables
BallCalls           dc.l    NoBallUpdate, DropBall, MoveBallToLeft, MoveBallToRight
BallDropped         dc.b    (FALSE)
BallMoved           dc.b    (FALSE)
BallXPosition       dc.l    (BALL_INITIAL_X_POS)     
BallXPositionFixed  dc.l    (BALL_INITIAL_X_POS<<FRACTION_BITS)
BallYPosition       dc.l    (BALL_INITIAL_Y_POS)     
BallYPositionFixed  dc.l    (BALL_INITIAL_Y_POS<<FRACTION_BITS)    

    END    START

        





























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
