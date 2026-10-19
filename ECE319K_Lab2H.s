// ****************** ECE319K_Lab2H.s ***************
// Your solution to Lab 2 in assembly code
// Author: Melinda Dai
// Last Modified: 02/06/2026
// ECE319H Spring 2026 (ECE319K students do Lab2)


    .include "../inc/msp.s"


        .data
        .align 2
// Declare global variables here if needed
// with the .space assembly directive


        .text
        .thumb
        .align 2
        .global EID
EID:    .string "MMD3728" // replace ZZZ123 with your EID here
        .align 2
  .equ N100ms, 2000000
  .equ N300ms, 6000000
  .equ dot, 100
  .equ dash, 3*dot
  .equ shortgap,(2*dot)  // because it will send an interelement too
  .equ interelement,dot

  Morse:
  .long  dot,  dash,    0,    0, 0 // A
  .long  dash,  dot,  dot,  dot, 0 // B
  .long  dash,  dot, dash,  dot, 0 // C
  .long  dash,  dot,  dot,    0, 0 // D
  .long  dot,     0,    0,    0, 0 // E
  .long  dot,   dot, dash,  dot, 0 // F
  .long  dash, dash,  dot,    0, 0 // G
  .long  dot,   dot,  dot,  dot, 0 // H
  .long  dot,   dot,    0,    0, 0 // I
  .long  dot,  dash, dash, dash, 0 // J
  .long  dash,  dot, dash,    0, 0 // K
  .long  dot,  dash,  dot,  dot, 0 // L
  .long  dash, dash,    0,    0, 0 // M
  .long  dash,  dot,    0,    0, 0 // N
  .long  dash, dash, dash,    0, 0 // O
  .long  dot,  dash, dash,  dot, 0 // P
  .long  dash, dash,  dot, dash, 0 // Q
  .long  dot,  dash,  dot,    0, 0 // R
  .long  dot,   dot,  dot,    0, 0 // S
  .long  dash,    0,    0,    0, 0 // T
  .long  dot,   dot, dash,    0, 0 // U
  .long  dot,   dot,  dot, dash, 0 // V
  .long  dot,  dash, dash,    0, 0 // W
  .long  dash,  dot,  dot, dash, 0 // X
  .long  dash,  dot, dash, dash, 0 // Y
  .long  dash, dash,  dot,  dot, 0 // Z


  .align 2
  .global Lab2Grader
  .global Lab2
  .global Debug_Init // Lab3 programs
  .global Dump       // Lab3 programs

// Switch input: PB2 PB1 or PB0, depending on EID
// LED output:   PB18 PB17 or PB16, depending on EID
// logic analyzer pins PB18 PB17 PB16 PB2 PB1 PB0
// analog scope pin PB20
Lab2:
// Initially the main program will
//   set bus clock at 80 MHz,
//   reset and power enable both Port A and Port B
// Lab2Grader will
//   configure interrupts  on TIMERG0 for grader or TIMERG7 for TExaS
//   initialize ADC0 PB20 for scope,
//   initialize UART0 for grader or TExaS
    // MOVS R0, #1   // 0 for info, 1 for debug with logic analyzer, 2 debug with scope, 10 for grade
    // BL Lab2Grader
    BL   Lab2Init   // you initialize input pin and output pin
    BL   Debug_Init // your Lab3
loop:
    // wait 1 sec
    // BL Delay300
    // BL Delay300
    // BL  Dot  // L is dot,dash,dot,dot
    //  BL  Dash
    //  BL  Dot
    //  BL  Dot
    // BL loop

    
    // BL Off    // wait for button pressed
    // BL On   // wait for button released
    
    MOVS R0, #10    // 0 for info, 1 for debug with logic analyzer, 2 debug with scope, 10 for grade
    BL Lab2Grader
    MOVS R0, #'H'
    // MOVS R0, #'O'
    
    BL Letter_Translate
    B loop

// Initialization

Lab2Init:
    PUSH {R4-R7, LR}

    // PB1 = GPIO input
    LDR  R0, =IOMUXPB1
    MOVS R1, #0x81 

    MOVS R2, #1
    LSLS R2, R2, #18     // R2 = (1<<18) input enable, input buffer
    ORRS R1, R1, R2
    STR  R1, [R0]

    // PB17 = GPIO output
    LDR  R0, =IOMUXPB17
    MOVS R1, #0x81 // software controlled
    STR  R1, [R0]

    // Enable PB17 output driver
    LDR  R0, =GPIOB_DOE31_0
    LDR  R1, [R0]

    MOVS R2, #1
    LSLS R2, R2, #17      // R2 = (1<<17)
    ORRS R1, R1, R2
    STR  R1, [R0]

    POP  {R4-R7, PC}

// Switch routines (PB1)

Off:
    PUSH {R4-R7, LR}
OffLoop:
    LDR R0, =GPIOB_DIN31_0
    LDR R1, [R0]
    LDR R2, =(1<<1) // PB1
    ANDS R1, R2
    CMP R1, #0
    BNE OffLoop
    POP {R4-R7, PC}

On:
    PUSH {R4-R7, LR}
OnLoop:
    LDR R0, =GPIOB_DIN31_0
    LDR R1, [R0]
    LDR R2, =(1<<1)
    ANDS R1, R2
    CMP R1, #0
    BEQ OnLoop
    POP {R4-R7, PC}

// LED routines (PB17)

LED_On:
    PUSH {R4-R7, LR}
    LDR R4, =GPIOB_DOUT31_0
    LDR R5, [R4]

    MOVS R6, #1
    LSLS R6, R6, #17  // R6 = (1<<17)

    ORRS R5, R5, R6
    STR R5, [R4]

    BL  Dump 

    POP {R4-R7, PC}

LED_Off:
    PUSH {R4-R7, LR}
    LDR R4, =GPIOB_DOUT31_0
    LDR R5, [R4]

    MOVS R6, #1
    LSLS R6, R6, #17  // R6 = (1<<17) // PB17 output

    BICS R5, R5, R6 // clear the bit, 
    STR R5, [R4]

    BL  Dump 

    POP {R4-R7, PC}

Dot: 
    PUSH {R4-R7, LR}
    MOVS R0, #1
    BL LED_On
    BL Delay100
    BL LED_Off
    BL Delay100
    POP {R4-R7, PC}

Dash: 
    PUSH {R4-R7, LR}
    MOVS R0, #1
    BL LED_On
    BL Delay300
    BL LED_Off
    BL Delay100
    POP {R4-R7, PC}

Letter_Translate:
    PUSH {R4-R7, LR}

    LDR  R6, =Morse  // base pointer, first address of morse 
    MOVS R1, #'A'
    SUBS R3, R0, R1  // R3 = letter index (0..25),  = input - 'A'

    MOVS R4, #20
    MULS R3, R4     // R3 *= 20 bytes per letter
    ADDS R6, R6, R3 // R6 = &Morse[index*20]

    MOVS R7, #5   // max 5 symbols

Translate_Loop:
    LDR R4, [R6]
    CMP R4, #0
    BEQ Done_Translating

    MOVS R5, #dot
    CMP R4, R5
    BNE CallDash
    BL Dot
    B Next

CallDash:
    BL Dash
    B Next

Next:
    ADDS R6, R6, #4 // next .long (symbol)
    SUBS R7, R7, #1 // max symbols - 1
    BNE Translate_Loop // if not equal to max symbols, keep looping

Done_Translating:
    POP {R4-R7, PC}

// Delay routines

Delay100:
    PUSH {R4, LR}
    LDR  R4, =N100ms
D100:
    SUBS R4, #1
    NOP
    BNE  D100
    POP  {R4, PC}

Delay300:
    PUSH {R4, LR}
    LDR  R4, =N300ms
D300:
    SUBS R4, #1
    NOP
    BNE  D300
    POP  {R4, PC}





    

    .end
