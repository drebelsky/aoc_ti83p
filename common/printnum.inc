; Proc: PrintNum
; Desc: Print out a number in decimal
; Input: HL (pointer to 32 bit LE value)
; Output: None
; Destroys:
;   * Op1, Op2, AF, BC, DE,  HL, IX
Proc_PrintNum:
                          ; Load Op1 (big endian) from LE value
    LD A, (HL)            ;
    LD (Op1 + 3), A       ;
    INC HL                ;
    LD A, (HL)            ;
    LD (Op1 + 2), A       ;
    INC HL                ;
    LD A, (HL)            ;
    LD (Op1 + 1), A       ;
    INC HL                ;
    LD A, (HL)            ;
    LD (Op1), A           ; Op1 = *(uint32_t *)HL (with byte swap from LE to BE)
                          ;
    LD DE, 10             ;
    LD HL, _varNum + 9    ; HL = (char *)_varNum + 9
_loop32:                  ; while(true) {
        PUSH HL           ;
        bcall(_Div32By16) ;   Op1, Op2 = divmod(Op1, 10)
        POP HL            ;
        LD A, (Op2 + 3)   ;
        ADD A, '0'        ;
        LD (HL), A        ;
        DEC HL            ;   *(HL--) = Op2 + '0'
        LD A, (Op1)       ;
        OR A              ;
        JR NZ, _loop32    ;
        LD A, (Op1 + 1)   ;
        OR A              ;
        JR NZ, _loop32    ;   if (Op1 & 0xffff == Op1) break; // if we can fit in 16 bits
                          ; }
    LD D, H               ;
    LD E, L               ; DE = HL
    LD HL, (Op1 + 2)      ;
    LD A, H               ;
    LD H, L               ;
    LD L, A               ; HL = Op1 w/ byte swap from BE to LE
_loop16:                  ; while (HL != 0) {
        LD A, H           ;
        OR A              ;
        JR NZ, _l16_cont  ;
        LD A, L           ;
        OR A              ;
        JR Z, _print      ;
_l16_cont:                ;
        bcall(_DivHLBy10) ;   HL, A = divmod(HL, 16)
        ADD A, '0'        ;
        LD (DE), A        ;
        DEC DE            ;   *(DE--) = A + '0'
        JR _loop16        ; }
_print:                   ;
        INC DE            ;
        LD H, D           ;
        LD L, E           ;
        bcall(_PutS)      ; PutS(DE + 1)
        RET               ; return

; PrintNum Vars
_varNum:
    .fill 10 ; maximum base 10 representation of a 32 bit number is 10 digits long
    .db 0    ; null terminate
