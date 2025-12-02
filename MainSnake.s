.data
last_dir: .word 3   # 0=up, 1=down, 2=left, 3=right (initial right)
x:      .word 0
y:      .word 0
blue: .word 0x04BADE
pink:   .word 0x00FF69B4
green:  .word 0x008F000
yellow: .word 0x00FFFF00
black: .word 0x000000
red: .word 0xC30010
dpadSize: .word 0x100000
upOffset: .word 0x0
up: .word 0xf0000024
downOffset: .word 0x4
down: .word 0xf0000028
leftOffset: .word 0x8
left: .word 0xf000002c
rightOffset:.word 0xc
right: .word 0xf0000030
veinte: .word 0x0000020
snake_tail_offset: .word 0
snake_head_offset: .word 24
head: .word 0
old_x: .word 0
old_y: .word 0
pink_location_x: .word 0
pink_location_y: .word 0
old_pink_location_x: .word 0
old_pink_location_y: .word 0
snake_length: .word 1                     # initial length = 1

trail_max:      .word 25             # capacity (number of entries)
# Proper fixed-length arrays
trail_x:
    .word 0,0,0,0,0,0,0,0,0,0
    .word 0,0,0,0,0,0,0,0,0,0
    .word 0,0,0,0,0
trail_y:
    .word 0,0,0,0,0,0,0,0,0,0
    .word 0,0,0,0,0,0,0,0,0,0
    .word 0,0,0,0,0
trail_start:    .word 0               # index of oldest element (0..24)
trail_count:    .word 0               # how many entries stored
trail_allow_len:.word 3               # visible pink segments (smaller = shorter)
delay_frames:   .word 1               # speed of fade (0/1 = fast)
frame_counter:  .word 0               # internal counter


.text
# --- Load device base addresses ---
lui a0, %hi(LED_MATRIX_0_BASE)
addi a0, a0, %lo(LED_MATRIX_0_BASE)

lui a1, %hi(LED_MATRIX_0_WIDTH)
addi a1, a1, %lo(LED_MATRIX_0_WIDTH)

lui a3, %hi(D_PAD_0_BASE)
addi a3, a3, %lo(D_PAD_0_BASE)

lui a4, %hi(D_PAD_0_RIGHT_OFFSET)
addi a4, a4, %lo(D_PAD_0_RIGHT_OFFSET)

lui a5, %hi(D_PAD_0_LEFT_OFFSET)
addi a5, a5, %lo(D_PAD_0_LEFT_OFFSET)

lui a6, %hi(D_PAD_0_UP_OFFSET)
addi a6, a6, %lo(D_PAD_0_UP_OFFSET)

lui a7, %hi(D_PAD_0_DOWN_OFFSET)
addi a7, a7, %lo(D_PAD_0_DOWN_OFFSET)

# --- Pointers to variables in memory ---
la s2, x
la s3, y
li a2, 5
# --- Paint initial random fruit matrix and head ---
li t0, 0
li t1, 0
fruit:
    addi t0, t0, 2
    addi t1, t1, 1
    la t6, veinte
    lw t3, 0(t6)
    bgt t0, t3, colourfirstpixel

    mul t2, t1, a1      # y*WIDTH
    add t2, t2, t0
    slli t2, t2, 2
    add t4, a0, t2

    la t6, yellow
    lw t5, 0(t6)
    sw t5, 0(t4)
    j fruit

colourfirstpixel:
    li t3, 0
    li t0, 0
    li t1, 0
    sw t0, 0(s2)
    sw t1, 0(s3)

    mul t2, t1, a1
    add t2, t2, t0
    slli t2, t2, 2
    add t3, a0, t2

    la t6, green
    lw t4, 0(t6)
    sw t4, 0(t3)   
    
    j loop

# --- Main loop ---
loop:
    #collision detection

    # read dpad to check if direction changes
    add t1, a3, a4       # right
    lw t3, 0(t1)
    li t2, 1
    beq t3, t2, setRight

    add t1, a3, a5       # left
    lw t3, 0(t1)
    li t2, 1
    beq t3, t2, setLeft

    add t1, a3, a6       # up
    lw t3, 0(t1)
    li t2, 1
    beq t3, t2, setUp

    add t1, a3, a7       # down
    lw t3, 0(t1)
    li t2, 1
    beq t3, t2, setDown
    
    #call game_is_snake_hit_self
    
move_auto:
    # no button pressed ? move in last_dir
    la t5, last_dir
    lw t4, 0(t5)

    li t0, 0
    beq t4, t0, moveUp
    li t0, 1
    beq t4, t0, moveDown
    li t0, 2
    beq t4, t0, moveLeft
    li t0, 3
    beq t4, t0, moveRight

    j loop

# --- Direction setters ---
setUp:
    li t4, 0
    la t5, last_dir
    sw t4, 0(t5)
    j move_auto

setDown:
    li t4, 1
    la t5, last_dir
    sw t4, 0(t5)
    j move_auto

setLeft:
    li t4, 2
    la t5, last_dir
    sw t4, 0(t5)
    j move_auto

setRight:
    li t4, 3
    la t5, last_dir
    sw t4, 0(t5)
    j move_auto

# --- Movements ---
moveRight:
    lw t0, 0(s2)    # x
    lw t1, 0(s3)    # y

    la t6, old_x
    sw t0, 0(t6)
    la t6, old_y
    sw t1, 0(t6)

    # clear old head pixel
    mul t2, t1, a1
    add t2, t2, t0
    slli t2, t2, 2
    add t3, a0, t2
    li t4, 0x00FF69B4 #pink
    sw t4, 0(t3)
    
    jal add_trail_and_erase
    
    # update x
    lw t2, 0(s2)
    addi t2, t2, 1
    sw t2, 0(s2)

    # store direction = right (3)
    li t4, 3
    la t5, last_dir
    sw t4, 0(t5)
    
    #computing address of pink pixel
    
    mul t6, t2, a1    # t6 = y*width
    add t6, t6, t1
    slli t5, t6, 2
    add t5, a0, t5
    
    j paint

moveLeft:
    lw t0, 0(s2)
    lw t1, 0(s3)

    la t6, old_x
    sw t0, 0(t6)
    la t6, old_y
    sw t1, 0(t6)

    mul t2, t1, a1
    add t2, t2, t0
    slli t2, t2, 2
    add t3, a0, t2
    li t4, 0x00FF69B4 #pink
    sw t4, 0(t3)

    jal add_trail_and_erase

    lw t2, 0(s2)
    addi t2, t2, -1
    sw t2, 0(s2)

    # store direction = left (2)
    li t4, 2
    la t5, last_dir
    sw t4, 0(t5)

    j paint

moveUp:
    lw t0, 0(s2)
    lw t1, 0(s3)

    la t6, old_x
    sw t0, 0(t6)
    la t6, old_y
    sw t1, 0(t6)

    mul t2, t1, a1
    add t2, t2, t0
    slli t2, t2, 2
    add t3, a0, t2
    li t4, 0x00FF69B4 #pink
    sw t4, 0(t3)

    jal add_trail_and_erase

    lw t3, 0(s3)
    addi t3, t3, -1
    sw t3, 0(s3)

    # store direction = up (0)
    li t4, 0
    la t5, last_dir
    sw t4, 0(t5)

    j paint

moveDown:
    lw t0, 0(s2)
    lw t1, 0(s3)

    la t6, old_x
    sw t0, 0(t6)
    la t6, old_y
    sw t1, 0(t6)

    mul t2, t1, a1
    add t2, t2, t0
    slli t2, t2, 2
    add t3, a0, t2
    li t4, 0x00FF69B4 #pink
    sw t4, 0(t3)

    jal add_trail_and_erase


    lw t3, 0(s3)
    addi t3, t3, 1
    sw t3, 0(s3)

    # store direction = down (1)
    li t4, 1
    la t5, last_dir
    sw t4, 0(t5)

    j paint
    


# --- Paint function ---
paint:
    lw t2, 0(s2)   # x
    lw t3, 0(s3)   # y

    # Compute address of head pixel
    mul t6, t3, a1
    add t6, t6, t2
    slli t5, t6, 2
    add t5, a0, t5

        # --- Collision detection ---
    lw t0, 0(t5)          # load current color at this pixel

    # --- check if pink (self collision)
    la t6, pink
    lw t1, 0(t6)
    beq t0, t1, collisionDetection

    # --- check if yellow (fruit collision)
    la t6, yellow
    lw t1, 0(t6)
    beq t0, t1, fruit_collision

    # --- otherwise, no collision ---
    j paint_head

fruit_collision:
    # increase trail_allow_len by 1
    la t0, trail_allow_len
    lw t1, 0(t0)
    addi t1, t1, 1
    sw t1, 0(t0)

    # erase eaten fruit (paint black)
    la t6, black
    lw t4, 0(t6)
    sw t4, 0(t5)

    # paint head green again
    la t6, green
    lw t4, 0(t6)
    sw t4, 0(t5)

    # spawn a new yellow pixel nearby
    lw t2, 0(s2)
    lw t3, 0(s3)
    addi t2, t2, 3
    la t6, veinte
    lw t4, 0(t6)
    blt t2, t4, no_wrap_spawn
    li t2, 0
no_wrap_spawn:
    mul t6, t3, a1
    add t6, t6, t2
    slli t6, t6, 2
    add t6, a0, t6
    la t0, yellow
    lw t1, 0(t0)
    sw t1, 0(t6)

    j paint_head

paint_head:
    # Paint new head
    la t6, green
    lw t4, 0(t6)
    sw t4, 0(t5)
    j loop
    
collisionDetection:
    # Show collision by painting the head red and halting
    la t6, red
    lw t4, 0(t6)
    sw t4, 0(t5)      # paint current pixel red

    # Infinite loop to stop movement
collision_loop:
    j collision_loop

blackPainter:
	mv t0, t3
	li t4, 0 #black
    sw t4, 0(t0)

	ret
add_trail_and_erase:
    # --- Save old_x, old_y in trail buffer ---
    la   t0, trail_start
    lw   t1, 0(t0)          # t1 = start
    la   t0, trail_count
    lw   t2, 0(t0)          # t2 = count

    add  t3, t1, t2         # t3 = end_index
    la   t0, trail_max
    lw   t4, 0(t0)          # t4 = MAX
    blt  t3, t4, no_wrap
    sub  t3, t3, t4
no_wrap:

    # store old_x into trail_x[index]
    slli t5, t3, 2
    la   t0, trail_x
    add  t0, t0, t5
    la   t6, old_x
    lw   t4, 0(t6)
    sw   t4, 0(t0)

    # store old_y into trail_y[index]
    la   t0, trail_y
    add  t0, t0, t5
    la   t6, old_y
    lw   t4, 0(t6)
    sw   t4, 0(t0)

    # increment count and store
    addi t2, t2, 1
    la   t0, trail_count
    sw   t2, 0(t0)

    # load allow_len (desired tail length)
    la   t0, trail_allow_len
    lw   t4, 0(t0)          # t4 = allowed visible length (e.g. 3)

erase_loop:
    # erase until count == allow_len
    ble  t2, t4, done_add

    # load start index (oldest pixel)
    la   t0, trail_start
    lw   t1, 0(t0)
    slli t5, t1, 2

    # load tail x, y
    la   t0, trail_x
    add  t0, t0, t5
    lw   t6, 0(t0)
    la   t0, trail_y
    add  t0, t0, t5
    lw   t5, 0(t0)

    # compute framebuffer address = a0 + ((y * width) + x) * 4
    mul  t3, t5, a1
    add  t3, t3, t6
    slli t3, t3, 2
    add  t3, a0, t3

    # write black pixel
    la   t0, black
    lw   t0, 0(t0)
    sw   t0, 0(t3)

    # advance start = (start + 1) % MAX
    la   t0, trail_start
    lw   t1, 0(t0)
    addi t1, t1, 1
    la   t0, trail_max
    lw   t0, 0(t0)
    blt  t1, t0, no_wrap2
    li   t1, 0
no_wrap2:
    la   t0, trail_start
    sw   t1, 0(t0)

    # decrement count
    addi t2, t2, -1
    la   t0, trail_count
    sw   t2, 0(t0)

    j erase_loop

done_add:
    ret
