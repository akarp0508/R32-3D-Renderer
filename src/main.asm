#org $1000
#varspace $2000

; gpu constants
.const GPU_FLAGS $20000001

.const GPU_PAGE $10C00
.const GPU_PAGE_SIZE $FA00

.var PAGE_INDEX 1
.var FRAME_COUNTER 1
.var RENDERABLE_TRIANGLES_COUNT 1
.var TRIANGLE_POINTS_COUNT 1
.var TRIANGLE_X_MIN 2
.var TRIANGLE_X_MAX 2
.var KEY_MAKECODE 2
.var PLACEHOLDER 2 ; used only to allign vars to 4 bits
.var PROJECTED_VERTICES 1024
.var PROJECTED_TRIANGLES 1024 ; each triangle 0B - addr of P1, 1B-addr of P2, 2B-addr of P3, 3B - color
.var TRIANGLE_DISTANCE_FROM_CAMERA 1024
.var TEMP_VARS 512

#include "src/init.asm"
#include "src/main_loop.asm"
#include "src/triangle_drawer.asm"
#include "src/int_handlers.asm"
#include "src/data.asm"
