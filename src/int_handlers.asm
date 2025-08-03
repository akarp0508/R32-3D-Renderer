IRQ_1_handler:
; set GPU mode to text on V-blank
; set GPU page to text page
; increment frame counter
psh r1
ldbu r1 [r0,FRAME_COUNTER]
inc r1
stb r1 [r0,FRAME_COUNTER]
pop r1
iret

IRQ_4_handler:
psh r1
ldw r1 [r0,$40000000]
cmp r1 $1A ; Z?
beq [r0,'IRQ_4_store_makecode']
cmp r1 $22 ; X?
beq [r0,'IRQ_4_store_makecode']
cmp r1 $E072 ; down?
beq [r0,'IRQ_4_store_makecode']
cmp r1 $E06B ; left?
beq [r0,'IRQ_4_store_makecode']
cmp r1 $E074 ; right?
beq [r0,'IRQ_4_store_makecode']
pop r1
iret
IRQ_4_store_makecode:
stb r1 [r0,KEY_MAKECODE]
pop r1
iret
