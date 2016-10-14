;GET RANDOM NUmBER

GetRandomNumber:
    movem.l d1,-(sp)
    movem.l d2,-(sp)
    
    move.l  Rand,d0
    moveq	#$AF-$100,d1
    moveq	#18,d2
.Ninc0	
	add.l	d0,d0
	bcc	.Ninc1
	eor.b	d1,d0
.Ninc1
	dbf	d2,.Ninc0
	
	move.l	d0,Rand
	
    movem.l (sp)+,d2
    movem.l (sp)+,d1
    
    rts

SeedRandomNumber:
    
    move.b  #GET_TIME_COMMAND,d0
    TRAP    #15

    move.l  d1,Rand

    rts