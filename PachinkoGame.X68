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
    
    jsr HandleInput
    
    jsr UpdateBallPosition

    jsr DrawBackgroundChunk
    jsr DrawBall

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

    move.b  #(TRUE), (BallMoved)

    move.l  (BallXPosition),d0
    lsl.l   #8,d0
    sub.l   #(BALL_X_VELOCITY), d0
    move.l  d0, (BallXPositionFixed)

    jmp     NoBallUpdate

MoveBallToRight:

    cmp.b   #(TRUE), (BallDropped)
    beq     NoBallUpdate                ; change this after making the game work

    move.b  #(TRUE), (BallMoved)

    move.l  (BallXPosition),d0
    lsl.l   #8,d0
    add.l   #(BALL_X_VELOCITY), d0
    move.l  d0, (BallXPositionFixed)

    jmp     NoBallUpdate


    include "InputHandler.x68"
    include "drawingModule.X68"



;bitmaps
BackgroundBitmap    INCBIN "bg.bmp"
BallBitmap          INCBIN  "ironBall.bmp"

;input
PlayerInput         dc.l    0 ;nothing

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
