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
    ;jsr DrawBall
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

    
HandleInput:  

    ;reset PlayerInput
    move.l  #0,(PlayerInput)
    ;Set the inputs    
    move.l  #(INPUT_COMMAND),d0
    ;d1: $00202527 => space, left arrow, right arrow
    ;move.l  $20<<$16+$25<<$8+$27,d1
    move.l  #(SPACE_KEY),d1
    lsl.l   #8,d1
    move.b  #(LEFT_ARROW),d1
    lsl.l   #8,d1
    move.b  #(RIGHT_ARROW),d1

    Trap    #15

    ;check if ball is droped, if yes skip
    cmpi.b  #(TRUE),(BallDropped)
    beq     EndHandleInput

    ;check the pressed key and call subroutines accordingly
    btst.l  #(SPACE_KEY_LOCATION), d1       
    bne     DropBallInput

    btst.l  #(LEFT_ARROW_LOCATION), d1       
    bne     MoveBallToLeftInput

    btst.l  #(RIGHT_ARROW_LOCATION), d1       
    bne     MoveBallToRightInput

EndHandleInput:

    rts

DropBallInput:

    move.l #1,(PlayerInput)

    jmp EndHandleInput

MoveBallToLeftInput:
    
    ;if both arrows are pressed, do nothing
    btst.l  #(RIGHT_ARROW_LOCATION), d1       
    bne     EndHandleInput

    move.l #2,(PlayerInput)

    jmp     EndHandleInput

MoveBallToRightInput:
    
    move.l #3,(PlayerInput)  

    jmp     EndHandleInput
  

UpdateBallPosition:

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
    
    jmp     NoBallUpdate

MoveBallToLeft:

    move.l  (BallXPosition),d0
    lsl.l   #8,d0
    sub.l   #(BALL_X_VELOCITY), d0
    move.l  d0, (BallXPositionFixed)
    ;lsr.l   #8,d0
    ;move.l  d0, (BallXPosition)

    jmp     NoBallUpdate

MoveBallToRight:

    move.l  (BallXPosition),d0
    lsl.l   #8,d0
    add.l   #(BALL_X_VELOCITY), d0
    move.l  d0, (BallXPositionFixed)
    ;lsr.l   #8,d0
    ;move.l  d0, (BallXPosition)

    jmp     NoBallUpdate

    include "drawingModule.X68"



;bitmaps
BackgroundBitmap    INCBIN "bg.bmp"
BallBitmap          INCBIN  "ironBall.bmp"

;input
PlayerInput         dc.l    0 ;nothing

;ball variables
BallCalls           dc.l    NoBallUpdate, DropBall, MoveBallToLeft, MoveBallToRight
BallDropped         dc.b    (FALSE)
BallXPosition       dc.l    (BALL_INITIAL_X_POS)     
BallXPositionFixed  dc.l    (BALL_INITIAL_X_POS<<FRACTION_BITS)
BallYPosition       dc.l    (BALL_INITIAL_Y_POS)     
BallYPositionFixed  dc.l    (BALL_INITIAL_Y_POS<<FRACTION_BITS)    

    END    START

        























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
