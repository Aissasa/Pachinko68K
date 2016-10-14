; this module contains drawing related subroutines

DrawAllBackground:
    
    lea BackgroundBitmap, a0

    jsr SetFirstDrawParams
    jsr DrawPic

    rts

DrawLoading:

    lea LoadingBitmap, a0

    jsr SetFirstDrawParams
    jsr DrawPic


DrawBackgroundChunk:
    
    cmp.b #(FALSE),(BallMoved)
    beq .DontDraw
    
    ;override the ball
    jsr SetBgDrawParams
    jsr DrawPic



.DontDraw:
    rts

OverrideScore:

    ;override the score
    jsr SetBgDrawParamsSc
    jsr DrawPic

    rts    

DrawBallFirstTime:

    move.b  #(TRUE), (BallMoved)

    jmp     DrawBall

DrawBall:

    cmp.b #(FALSE),(BallMoved)
    beq .DontDraw

    jsr SetBallDrawParams
    jsr DrawPic

.DontDraw:
    rts


SetFirstDrawParams:

    ;set draw start position to 0,0    
    move.l  #(OUTPUT_WINDOW_HEIGHT),d1  ;y
    swap    d1
    move.w  #0,d1                       ;x
    
    ;set chunk start position to 0,0    
    move.l  #0,d2                       ;y
    swap    d2
    move.w  #0,d2                       ;x
    
    ;set chunk width and height to the screen resol
    move.l  #(OUTPUT_WINDOW_WIDTH),d3
    swap    d3
    move.w  #(OUTPUT_WINDOW_HEIGHT),d3
    
    rts

SetBgDrawParams:

    lea BackgroundBitmap, a0

    ;set draw start position   
    move.l  (BallYPosition),d1           
    add.l   #(BALL_HEIGHT),d1               ;y
    swap    d1
    add.l   (BallXPosition),d1              ;x
    ;sub.l   #(BALL_OFFSET),d1
    
    ;set chunk start position
    move.l  (BallYPosition),d2              ;y          
    swap    d2
    add.l  (BallXPosition),d2               ;x
    
    ;set chunk width and height
    move.l  #(BALL_WIDTH),d3                
    swap    d3
    move.w  #(BALL_HEIGHT),d3               
    
    rts

SetBgDrawParamsSc:

    lea BackgroundBitmap, a0

    ;set draw start position   
    move.l  #(SCORE_LED_START_Y_OVER),d1           
    add.l   #(SCORE_LED_DIGIT_HEIGHT_OV),d1    ;y
    swap    d1
    add.l  #(SCORE_LED_START_X_OVER),d1         ;x  

    
    ;set chunk start position
    move.l  #(SCORE_LED_START_Y_OVER),d2          ;y    
    swap    d2
    add.l  #(SCORE_LED_START_X_OVER),d2           ;x

    ;set chunk width and height
    move.l  #(SCORE_LED_DIGIT_WIDTH_OV),d3     
    swap    d3
    move.w  #(SCORE_LED_DIGIT_HEIGHT_OV),d3
               
    
    rts

SetBallDrawParams:

    lea BallBitmap, a0

    ;set draw start position   
    move.l  #(BALL_HEIGHT),d1
    move.l  (BallYPositionFixed),d7
    lsr.l   #(FRACTION_BITS),d7
    add.l   d7,d1
    ;update the y position
    move.l  d7, (BallYPosition)
          
    swap    d1

    move.l  (BallXPositionFixed),d7
    lsr.l   #(FRACTION_BITS),d7
    move.w  d7, d1
    ;update the x position
    move.l  d7, (BallXPosition)

    
    ;set chunk start position
    move.l  #0,d2 
    
    ;set chunk width and height
    move.l  #(BALL_WIDTH),d3
    swap    d3
    move.w  #(BALL_HEIGHT),d3
    
    rts

     
*params:
*a0: bitmap
*d1: start draw pos(x,y)
*d2: chunk pos(x,y)
*d3: chunk width and height(width,height)      
DrawPic:
    ;push the first pixel pos
    move.l  a0, a6
    jsr GetFirstPixelAddress
    move.l  a6, -(sp)                               
    
    ;push image width
    move.l  a0, a6
    jsr GetImageWidth
    move.l  d0,-(sp)
    
    ;push image height
    move.l  a0, a6
    jsr GetImageHeight
    move.l  d0,-(sp)

    ;push the draw start pos
    clr.l   d4
    move.w  d1, d4
    move.l  d4,-(sp)    ;push x
    swap    d1
    move.w  d1,d4
    move.l  d4,-(sp)    ;push y
    
    ;push the chunk start pos
    move.w  d2,d4
    move.l  d4,-(sp)    ;push x
    ;convert the y pos of chunk to bitmap coor
    swap    d2
    move.w  d2,d4
    add.w   d3,d4           ;add chunk height
    ;d0 have the image height
    move.l  d0,d1 
    sub.l   d4,d1
    move.l  d1, -(sp)   ;push y
    
    ;push the chunk dimensions
    swap    d3
    move.w  d3, d4  
    move.l  d4,-(sp)    ;push width
    swap    d3
    move.w  d3, d4
    move.l  d4,-(sp)    ;push height
 
    jsr DrawAChunk
    
    ;reinit the stack pointer
    add.l   #(STACK_OFFSET_WHEN_DRAWING),sp
    rts                
    
*parameters:
*first pixel address 
*image width 
*image height 
*draw start x 
*draw start y, 
*chunk start x 
*chunk start y 
*chunk width 
*chunk height
DrawAChunk:
    
    move.l  IMAGE_WIDTH_STACK_OFFSET(sp),d7                 ;get the image width into d7
    andi.l  #3,d7                                           ;get the rest of division by 4, which is the padding     
    
    move.l  FIRST_PIXEL_ADDRESS_STACK_OFFSET(sp),a4         ;a4 points to the first pixel
    
    move.l  IMAGE_WIDTH_STACK_OFFSET(sp),d1                 ;image width into d1
    move.l  d1, d2                                          ;temp value to avoid mul
    add.l   d2, d1
    add.l   d2, d1                                          ;get the width number of bytes
    add.l   d1,d7                                           ;width bytes
    
    move.l  d7, d2                                          ;store width bytes into d2
    
    move.l  CHUNK_Y_POS_STACK_OFFSET(sp),d1                 ;get the chunk y pos
    mulu.w  d1,d2                                           ;mutiply the y with the width bytes to get the y bytes offset
    
    move.l  CHUNK_X_POS_STACK_OFFSET(sp),d0                 ;put chunk x start pos into d0
    move.l  d0, d1                                          ;temp value to avoid mul
    add.l   d1, d0
    add.l   d1, d0                                          ;get the x number of bytes
    
    add.l   d0,d2                                           ;add the x bytes to the y bytes offset to have the total offset
    
    add.l   d2, a4                                          ;add the offset to get the new first position
    
    move.l  #0, d5                                          ;x counter
    move.l  #0, d6                                          ;y counter
    
    
DrawColumn:
    ;set pen color
    clr.l d1
    move.b   (a4)+,d1                                       ;set blue
    lsl.l   #8,d1                                           ;shift the byte to the left
    move.b  (a4)+,d1                                        ;set green
    lsl.l   #8,d1                                           ;shift the byte to the left
    move.b  (a4)+,d1                                        ;set red    => d1 has 00BBGGRR
    
    ;if green, skip that pixel
    cmp.l   #(GREEN),d1
    beq     NextPixel
    
    move.l  #SET_PEN_COLOR_COMMAND, d0
    Trap #15
    
    ;draw a pixel
    ;set x in d1 and y in d2
    clr.l   d1
    move.l  DRAW_X_POS_STACK_OFFSET(sp),d1                                               
    add.l   d5,d1                                           ;set x position on screen
    
    move.l  DRAW_Y_POS_STACK_OFFSET(sp),d2
    sub.l   d6,d2                                           ;set the y position on screen
    
    move.l  #DRAW_A_PIXEL_COMMAND, d0
    Trap #15

NextPixel:    
    addi.l  #1, d5                                          ;increment x counter
    move.l  CHUNK_WIDTH_STACK_OFFSET(sp),d0
    cmp.l  d0,d5
    bne DrawColumn                                          ;if not done with the column, continue drawing
    
    addi.l  #1, d6                                          ;increment y counter
    move.l  CHUNK_HEIGHT_STACK_OFFSET(sp),d0
    cmp.l   d0,d6
    beq     DrawEnd                                         ;if done with the rows, then stop drawing
    
    move.l  #0, d5                                          ;reset x counter
    move.l  CHUNK_WIDTH_STACK_OFFSET(sp),d1                 ;put chunk width in d1
    move.l  d1, d0                                          ;d0 has the temp to avoid mul
    add.l   d0, d1
    add.l   d0, d1                                          ;multiply it by 3 to get the bytes number
    
    move.l  d7, d0                                          ;d0 = width bytes
    sub.l   d1,d0                                           ;sub the chunk bytes from the width bytes
    add.l   d0, a4                                          ;and then add it to a4 to get the next pixel
    
    jmp DrawColumn                                          ;draw next column

DrawEnd:

    rts


EnableDoubleBuffer:
    ;double buffering mode enabled
    move.l  #SET_DRAWING_MODE_COMMAND, d0
    move.l  #DOUBLE_BUFFERING_MODE, d1
    Trap    #15

    rts

PaintScreenBuffer:
    ;repaint screen from buffer
    move.l  #REPAINT_SCREEN_COMMAND, d0
    Trap    #15
        
    rts    

;param a6:image address
GetFirstPixelAddress:
    add.l   #(OFFSET_TO_PIXEL_ARRAY),a6                     ;a6 has the pixel offset address
    move.l  (a6),d0                                         ;put it in d0
    jsr SwapBytes                                           ;swap to get the right value
    add.l   d0,a6                                           ;a6 has the 0, h-1 pixel address
    sub.l   #(OFFSET_TO_PIXEL_ARRAY),a6
    
    rts

;param a6:imaage address, return d0: image width

GetImageWidth:
    add.l   #(OFFSET_IMAGE_WIDTH),a6                        ;a6 has the image width address
    move.l  (a6),d0                                         ;put it in d0
    jsr SwapBytes                                           ;swap to get the right value
    
    rts

;param a6:imaage address, return d0: image height
GetImageHeight:
    add.l   #(OFFSET_IMAGE_HEIGHT),a6                       ;a6 has the image width address
    move.l  (a6),d0                                         ;put it in d0
    jsr SwapBytes                                           ;swap to get the right value

    rts


SwapBytes:
    ;DDCCBBAA
    rol.w   #8,d0   ;DDCCAABB
    swap.w    d0    ;AABBDDCC
    rol.w   #8,d0   ;AABBCCDD
    
    rts


        










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
