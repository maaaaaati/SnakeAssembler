    /* constantes.s: definiciones de periféricos (valores ficticios) */
    .section .rodata
    .global LED_MATRIX_0_BASE
LED_MATRIX_0_BASE:      .word 0xFF200000
    .global LED_MATRIX_0_WIDTH
LED_MATRIX_0_WIDTH:     .word 24

    .global D_PAD_0_BASE
D_PAD_0_BASE:           .word 0xFF200100
    .global D_PAD_0_RIGHT_OFFSET
D_PAD_0_RIGHT_OFFSET:   .word 0xC
    .global D_PAD_0_LEFT_OFFSET
D_PAD_0_LEFT_OFFSET:    .word 0x8
    .global D_PAD_0_UP_OFFSET
D_PAD_0_UP_OFFSET:      .word 0x0
    .global D_PAD_0_DOWN_OFFSET
D_PAD_0_DOWN_OFFSET:    .word 0x4

    /* Añade más símbolos si el linker los reclama */
