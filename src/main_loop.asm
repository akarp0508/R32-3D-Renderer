main_loop:
    ; render triangles
    ;call [r0,'draw_all_triangles']
    ; change PAGE_INDEX
    mov r1 $005F002F
    mov r3 $001F001F
    call [r0,'follow_the_line']
    jmp [r0,'main_loop']
wait_for_gpu:
    ldbu r2 [r0,GPU_FLAGS]
    lsr r2 3
    cmp r1 r2
    beq [r0,'wait_for_gpu']
