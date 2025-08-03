main_loop:
    ; render triangles
    ;call [r0,'draw_all_triangles']
    ; change PAGE_INDEX
    mov r1 $00200020
    mov r2 $00400050
    mov r3 $00500030
    mov r4 0
    stw r1 [r4,PROJECTED_VERTICES]
    add r4 4
    stw r2 [r4,PROJECTED_VERTICES]
    add r4 4
    stw r3 [r4,PROJECTED_VERTICES]
    mov r1 $00000102
    call [r0,'generate_wireframe']
    jmp [r0,'main_loop']
wait_for_gpu:
    ldbu r2 [r0,GPU_FLAGS]
    lsr r2 3
    cmp r1 r2
    beq [r0,'wait_for_gpu']
