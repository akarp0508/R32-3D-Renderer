draw_all_triangles:
    ; iterate over triangles
    
draw_triangle:
    ; given data about projected points and color draw a triangle -
    ; triangles are coded this way 0B-P1 1B-P2 2B-P3 3B-Color



generate_wireframe: ; this does not draw anything - it just stores the y start and stop values in x indexed array
    ; r1 should hold the triangle values
    ; first lets get all the points values
    mov r2 r1
    mov r3 r1
    and r1 $000000FF
    and r2 $0000FF00
    and r3 $00FF0000
    lsl r1 2 ; *4
    lsr r2 6 ; shift right by 8 and *4
    lsr r3 14; shift right by 16 and *4
    ldw r1 [r1,PROJECTED_VERTICES]
    ldw r2 [r2,PROJECTED_VERTICES]
    ldw r3 [r3,PROJECTED_VERTICES]
    ; at this point all the points should be in R1 R2 and R3
    ; now we need to run bresenham's algorithm on all points combinations and store the results in an array
    psh r1
    psh r2
    psh r2
    psh r3
    call [r0,'follow_the_line'] ; r1 r3
    pop r1
    pop r3
    call [r0,'follow_the_line'] ; r3 r2
    pop r1
    pop r3
    call [r0,'follow_the_line'] ; r2 r1
    ret
    
follow_the_line: ; this uses bresenham's algorithm to follow the line of two givem points on r1 and r2
    ; the max and min y value gets saved on x-indexed 
    ; make r1 = x0 and r2 = y0
    mov r2 r1
    and r1 $0000FFFF
    lsr r2 16
    ; make r3 = x1 and r4 = y1
    mov r4 r3
    and r3 $0000FFFF
    lsr r4 16
    ; dx = abs(x1 - x0)
    mov r6 r3 ; r6 = x1
    sub r6 r1 ; r6 = x1 - x2
    bps [r0,'bresenham_dx_neg_skip'] ; skip if r6 is positive
    neg r6
bresenham_dx_neg_skip:
    ; dy = -abs(y1 - y0)
    mov r7 r4 ; r7 = y1
    sub r7 r2 ; r7 = y1 - y2
    bng [r0,'bresenham_dy_neg_skip'] ; skip if r7 is negative
    neg r7
bresenham_dy_neg_skip:
    ; let's store dx in the stack
    psh r6
    ; sx = 1 if x0 < x1 else -1
    ; lets now put sx in r5
    mov r5 1
    cmp r1 r3
    bls [r0,'bresenham_sx_neg_skip'] ; skip if x0<x1
    neg r5 ; if its not make r5 = -1
bresenham_sx_neg_skip:
    psh r5 ; push it for future reference
    ; let's store -dy in the stack
    psh r7
    ; sy = 1 if y0 < y1 else -1
    ; let's do the same but for sy
    mov r5 1
    cmp r2 r4
    bls [r0,'bresenham_sy_neg_skip'] ; skip if y0<y1
    neg r5 ; if its not make r5 = -1
bresenham_sy_neg_skip:
    psh r5
    ; at this point we should have dx, sx, dy, sy in stack
    ; and we still should have x0, y0, x1, y1 in r1-r4
    ; now lets calculate err
    ; err = dx + dy
    mov r5 r6
    add r5 r7 ; r5 = err = dx + dy
bresenham_main_loop:
    ; TODO store the pixel values
    ; TEMP drawing the points on screen
    mov r7 r2
    mltl r7 320
    add r7 r1
    mov r6 15
    stb r6 [r7,GPU_PAGE]
    ; if x0 == x1 and y0 == y1:
    ;   break;
    cmp r1 r3 ; continue if x0 != x1
    bne [r0,'bresenham_main_loop_continue']
    cmp r2 r4 ; continue if y0 != y1
    bne [r0,'bresenham_main_loop_continue']
    ; break if x0 == x1 and y0 == y1
    jmp [r0,'bresenham_main_loop_finished'] 
bresenham_main_loop_continue:
    ; e2 = 2 * err
    mov r6 r5 ; r6 = r5 = err
    lsl r6 1 ; r6 = e2 = err * 2
    ; if e2 > dy:
    ; to check this condition first we need to get dy
    mov r7 -8
    adsp r7
    ldw r7 [r7,0] ; r7 = dy
    ; now lets do the check
    cmp r6 r7
    ble [r0,'bresenham_e2dy_if_skip'] ; jmp if false
    ; err += dy
    ; since r5 = err and r7 = dy
    add r5 r7
    ; x0 += sx
    mov r7 -4
    adsp r7
    ldw r7 [r7,0]
    add r1 r7
bresenham_e2dy_if_skip:
    ; if e2 < dx:
    ; to check this condition first we need to get dx
    mov r7 -16
    adsp r7
    ldw r7 [r7,0] ; r7 = dx
    ; now lets do the check
    cmp r6 r7
    bge [r0,'bresenham_e2dx_if_skip'] ; jmp if false
    ; err += dx
    ; since r5 = err and r7 = dy
    add r5 r7
    mov r7 -12
    adsp r7
    ldw r7 [r7,0]
    add r2 r7
bresenham_e2dx_if_skip:
    jmp [r0,'bresenham_main_loop']
bresenham_main_loop_finished:
    pop r7
    pop r7
    pop r7
    pop r7
    ret
