*In this file, we store the equtes we need in our gane 

ALL_REG						REG d0-d7/a0-a6

TRUE                        EQU 1
FALSE                       EQU 0

GREEN                       EQU $00FF00

;math
FRACTION_BITS				EQU 8
ONE_TENTH					EQU 26
TWO_TENTH					EQU 51
EIGHT_TENTH					EQU 205
HALF						EQU 128

;output window
OUTPUT_WINDOW_WIDTH         EQU 1071		;the output screen width in pixels
OUTPUT_WINDOW_HEIGHT        EQU 800			;the output screen height in pixels

;pachinko board dimesions and key points
TOP_LEFT_BOARD_X_POS        EQU 313
TOP_LEFT_BOARD_Y_POS        EQU 42
BOTTOM_RIGHT_BOARD_X_POS    EQU 757
BOTTOM_RIGHT_BOARD_Y_POS    EQU 666
BOARD_WIDTH                 EQU (BOTTOM_RIGHT_BOARD_X_POS-TOP_LEFT_BOARD_X_POS)
BOARD_HEIGHT                EQU (BOTTOM_RIGHT_BOARD_Y_POS-TOP_LEFT_BOARD_Y_POS)

;ball
BALL_WIDTH					EQU 30
BALL_HEIGHT					EQU 30
BALL_RADIUS					EQU 15
BALL_INITIAL_X_POS			EQU TOP_LEFT_BOARD_X_POS
BALL_INITIAL_Y_POS			EQU TOP_LEFT_BOARD_Y_POS


BALL_SLIDE_VELOCITY			EQU $250

BALL_Y_ACCELERATION			EQU $15

BALL_INIT_X_VELOCITY		EQU 0	   ;****************************** make random between -2,2***************************************************************
BALL_INIT_Y_VELOCITY		EQU 0


;pegs
PEG_WIDTH					EQU 14
PEG_HEIGHT					EQU 14
PEG_RADIUS					EQU 7


;collision
MIN_DX_TO_CHECK_COLLISION	EQU 2+(BALL_RADIUS+PEG_RADIUS)
MIN_DY_TO_CHECK_COLLISION	EQU 2+(BALL_RADIUS+PEG_RADIUS)


;commands
GET_TIME_COMMAND			EQU 8		;get current time trap code
INPUT_COMMAND               EQU 19      ;get input keys    
SET_OUTPUT_WINDOW_COMMAND   EQU 33      ;set output trap code
SET_PEN_COLOR_COMMAND       EQU 80      ;set pen color trap code
DRAW_A_PIXEL_COMMAND        EQU 82      ;draw pixel trap code
SET_DRAWING_MODE_COMMAND    EQU 92      ;set drawing mode used for enabeling double buffering
REPAINT_SCREEN_COMMAND      EQU 94      ;repaints screen command from a buffer

DOUBLE_BUFFERING_MODE       EQU 17      ;double buffering mode option

;offsets in the bitmap
OFFSET_TO_PIXEL_ARRAY       EQU $0A      ;the offset to the address containing the pixel array starting byte
OFFSET_IMAGE_WIDTH          EQU $12		 ;the offset to the address containing the image width
OFFSET_IMAGE_HEIGHT         EQU $16		 ;the offset to the address containing the image height


;Stack pointers for drawing chunks
FIRST_PIXEL_ADDRESS_STACK_OFFSET    EQU 36
IMAGE_WIDTH_STACK_OFFSET            EQU 32
IMAGE_HEIGHT_STACK_OFFSET           EQU 28
DRAW_X_POS_STACK_OFFSET             EQU 24
DRAW_Y_POS_STACK_OFFSET             EQU 20
CHUNK_X_POS_STACK_OFFSET            EQU 16
CHUNK_Y_POS_STACK_OFFSET            EQU 12
CHUNK_WIDTH_STACK_OFFSET            EQU 8
CHUNK_HEIGHT_STACK_OFFSET           EQU 4
STACK_OFFSET_WHEN_DRAWING           EQU FIRST_PIXEL_ADDRESS_STACK_OFFSET+CHUNK_HEIGHT_STACK_OFFSET

;stack pointers for checking peg collision
CURRENT_PEG_X_STACK_OFFSET          EQU 8
CURRENT_PEG_Y_STACK_OFFSET          EQU 4
STACK_OFFSET_IN_PEG_COL           	EQU CURRENT_PEG_X_STACK_OFFSET



;input keycodes
SPACE_KEY   EQU $20
LEFT_ARROW  EQU $25
RIGHT_ARROW EQU $27

;input location of keycode in d1
SPACE_KEY_LOCATION   EQU 16
LEFT_ARROW_LOCATION  EQU 8
RIGHT_ARROW_LOCATION EQU 0

;frame rate
TIME_PER_FRAME		 EQU 1








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
