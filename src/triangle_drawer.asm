draw_all_triangles:
    ; iterate over triangles
    
draw_triangle:
    ; given data about projected points and color draw a triangle -
    ; triangles are coded this way 0B-P1 1B-P2 2B-P3 3B-Color
    ; r1 should hold the triangle values
    ; first lets get all the points values
    mov r2 r1
    mov r3 r1
    mov r4 r1
    and r1 $000000FF
    and r2 $0000FF00
    and r3 $00FF0000
    lsl r1 2 ; *4
    lsr r2 6 ; shift right by 8 and *4
    lsr r3 14; shift right by 16 and *4
    lsr r4 24; shift right by 24
    psh r4 ; push the color value since it will be needed for filling the triangle
    ldw r1 [r1,PROJECTED_VERTICES]
    ldw r2 [r2,PROJECTED_VERTICES]
    ldw r3 [r3,PROJECTED_VERTICES]
    call [r0,'calc_min_max_x_of_current_triangle']
    call [r0,'calc_min_max_y_of_every_x_in_triangle']
    pop r4 ; pop the color with which triangle should be filled
    call [r0,'fill_triangle']
    ret

calc_min_max_x_of_current_triangle:
    mov r5 319 ; let's assume border condition - min x = 319
    mov r6 0 ; let's assume the other border condition - max x = 0
    mov r4 r1
    call [r0,'compare_current_x']
    mov r4 r2
    call [r0,'compare_current_x']
    mov r4 r3
    call [r0,'compare_current_x']
    ; make the values be contained inside 0-319 range
    cmp r5 0
    bge [r0,'min_x_override_skip']
    mov r5 0
min_x_override_skip:
    sth r5 [r0,TRIANGLE_X_MIN]
    cmp r6 319
    ble [r0,'max_x_override_skip']
    mov r6 319
max_x_override_skip:
    sth r6 [r0,TRIANGLE_X_MAX]
    ret

compare_current_x:
    and r4 $0000FFFF
    cmp r4 r5
    bge [r0,'compare_current_x_skip_min'] ; if r4 < r5 do:
    mov r5 r4 ; store r4 as new x min
compare_current_x_skip_min:
    cmp r4 r6
    ble [r0,'compare_current_x_skip_max'] ; if r4 > r6 do:
    mov r6 r4 ; store r4 as new x min
compare_current_x_skip_max:
    ret

fill_triangle:
    ret

calc_min_max_y_of_every_x_in_triangle: ; this does not draw anything - it just stores the y start and stop values in x indexed array
    ; at this point all the points should be in R1 R2 and R3
    ; now we need to run bresenham's algorithm on all points combinations and store the results in an array
    psh r1
    psh r2
    psh r2
    psh r3
    call [r0,'bresenham'] ; r1 r3
    pop r1
    pop r3
    call [r0,'bresenham'] ; r3 r2
    pop r1
    pop r3
    call [r0,'bresenham'] ; r2 r1
    ret

store_x_min_max_values:
    ; we have x in r1 and y in r2
    ; we can use r4 as its overriden in the loop, 
    ; but for any other register we need to stash its value
    mov r4 r2
    mltl r4 320
    add r4 r1
    mov r6 15
    stb r6 [r4,GPU_PAGE]
    ret
    
bresenham: ; this uses bresenham's algorithm to follow the line of two givem points on r1 and r2
    ; the max and min y value gets saved on x-indexed 
    ; make r1 = x0 and r2 = y0
    mov r2 r1
    and r1 $0000FFFF
    lsr r2 16
    ; make r3 = x1 and r4 = y1
    mov r4 r3
    and r3 $0000FFFF
    lsr r4 16
    ; optimization trick - let's push r4 to the stack
    psh r4
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
    ; at this point we should have y1, dx, sx, dy, sy in stack
    ; and we still should have x0, y0, x1 in r1-r3
    ; and temporary y1 should be in r4
    ; now lets calculate err
    ; err = dx + dy
    mov r5 r6
    add r5 r7 ; r5 = err = dx + dy
    mov r7 0
    adsp r7
bresenham_main_loop:
    ; use the x and y values of current point
    call [r0,'store_x_min_max_values']
    ; if x0 == x1 and y0 == y1:
    ;   break;
    cmp r1 r3 ; continue if x0 != x1
    bne [r0,'bresenham_main_loop_continue']
    ; for this check we need r4 = y1 so we need to get this value from stack
    ldw r4 [r7,-20]
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
    ldw r4 [r7,-8] ; r4 = dy
    ; now lets do the check
    cmp r6 r4
    ble [r0,'bresenham_e2dy_if_skip'] ; jmp if false
    ; err += dy
    ; since r5 = err and r4 = dy
    add r5 r4
    ; x0 += sx
    ldw r4 [r7,-12]
    add r1 r4
bresenham_e2dy_if_skip:
    ; if e2 < dx:
    ; to check this condition first we need to get dx
    ldw r4 [r7,-16] ; r4 = dx
    ; now lets do the check
    cmp r6 r4
    bge [r0,'bresenham_e2dx_if_skip'] ; jmp if false
    ; err += dx
    ; since r5 = err and r4 = dy
    add r5 r4
    ldw r4 [r7,-4]
    add r2 r4
bresenham_e2dx_if_skip:
    jmp [r0,'bresenham_main_loop']
bresenham_main_loop_finished:
    sub r7 20
    wsp r7
    ret
