; set stack base address
mov r1 $40
wsp r1

; load 256-color palette
mov r1 'color_palette'
mov r2 $20000020
load_palette:
cpw r2+ r1+
cmp r2 $20000800
bne [r0,'load_palette']

; set GPU mode - 320x200 - 8b color pallette
mov r1 $06
stb r1 [r0,$20000000]

; set GPU page 1 address
mov r1 GPU_PAGE
stw r1 [r0,$20000004]

; set GPU page 2 address
add r1 GPU_PAGE_SIZE
stw r1 [r0,$20000008]

; enable GPU rendering
; enable V-blank & H-blank interrupts
mov r1 %11
stb r1 [r0,$20000001]

; setup interrupt table
mov r1 'IRQ_1_handler'
stw r1 [r0,4]
mov r1 'IRQ_4_handler'
stw r1 [r0,16]

jmp [r0,'main_loop']
