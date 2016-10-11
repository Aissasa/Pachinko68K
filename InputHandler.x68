

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
  
