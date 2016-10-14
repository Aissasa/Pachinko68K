;math

;param:d1, returns d0 as the abs
GetAbsoluteValue:

	movem.l d1,-(sp)
	movem.l d6,-(sp)
    movem.l d7,-(sp)


	move.l 	d1, d6		;y = x
	asr.l 	#8,d6	
	asr.l 	#8,d6	
	asr.l 	#8,d6	
	asr.l 	#7,d6		;y >>> 31

	move.l 	d6, d7		;store y
	eor.l 	d1, d6		;x xor y

	sub.l 	d7, d6		;(x xor y) - y

	move.l 	d6, d0

	movem.l (sp)+,d7
	movem.l (sp)+,d6
    movem.l (sp)+,d1


	rts