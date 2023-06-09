#include    "ti83plus.inc"
#define     progStart   $9D95
.org        progStart-2
.db         $BB,$6D
; Proc: main
    ; Look up Str1              ;
    LD HL, _constStr1Tok        ;
    bcall(_Mov9ToOP1)           ;
    bcall(_FindSym)             ; DE = findSym(Str1)
    ; Print errors if not found ;
    JP C, _eSymNotFound         ;
    LD A, B                     ;
    AND A                       ;
    JP NZ, _eSymNotInRam        ;
    ; Get size of file          ;
    LD A, (DE)                  ;
    INC DE                      ;
    LD L, A                     ;
    LD A, (DE)                  ;
    INC DE                      ;
    LD H, A                     ; FileSize = *(uint16_t *)DE
    ADD HL, DE                  ; DE += 2
    LD (_varFileEnd), HL        ; FileEnd = DE + FileSize

    LD HL, 0                    ; res (HL) = 0
_mainLoopStart:                 ; do {
    PUSH HL                     ;
    CALL Proc_HandleLine        ;
    LD B, 0                     ;
    LD C, A                     ;
    POP HL                      ;
    ADD HL, BC                  ;     HL += HandleLine(DE)
                                ;
    LD A, (_varFileEnd + 1)     ;
    CP D                        ;
    JR C, _done                 ;
    JR NZ, _mainLoopStart       ;
    LD A, (_varFileEnd)         ;
    CP E                        ;
    JR C, _done                 ;
    JR Z, _done                 ;
    JR _mainLoopStart           ; } while (DE < FileEnd)
                                ;
_done:                          ;
    LD (_varRes), HL            ;
    LD HL, _varRes              ;
    CALL Proc_PrintNum          ;
    RET                         ;


; main errors
_eSymNotFound:
    LD HL, _constNotFound
    bcall(_PutS)
    RET
_eSymNotInRam:
    LD HL, _constNotInRam
    bcall(_PutS)
    RET

; main variables
_varRes:
    .dw 0, 0
_varFileEnd:
    .dw 0

; main constants
_constNotFound: .db "Symbol not found", 0
_constNotInRam: .db "Symbol not in ram (archived)", 0
_constStr1Tok:
    .db StrngObj, tVarStrng, tStr1
    .db 0, 0, 0, 0, 0, 0 ; pad to 9

m4_define(`m4_comment', `')m4_dnl
m4_comment(`Note that we have? to define this in m4 instead of asm since spasm macros don't support taking in a register')m4_dnl
m4_comment(`Macro for reading a one or two digit number')m4_dnl
m4_comment(`Parameters are DEST_REG ($1), END_CHAR ($2), LABEL_AFTER ($3)')
m4_changequote(`[', `]')m4_dnl
m4_define([HL_READ_NUM], [
    ; generated by m4 file
    LD A, (DE)
    INC DE
    SUB '0'
    LD $1, A     ; DEST ($1) = *(DE++) - '0'

    LD A, (DE)  ;
    CP A, $2   ; if (*DE == END_CHAR ($2))
    JR Z, $3   ;   goto LABEL_AFTER ($3)
    SUB '0'
    LD IXH, A
    LD A, $1
    ADD A, A
    LD $1, A
    ADD A, A
    ADD A, A
    ADD A, $1
    ADD A, IXH   ; else
    LD $1, A     ;
    INC DE      ; DEST ($1) = DEST * 10 + *(DE++) - '0'
    ; end generated by m4 file
])m4_dnl
; Proc: HandleLine
; Desc: Read a line from the file and calculate whether or not one range fully contains the other
; Input: DE (file pointer)

;   * A (1 if overlap, 0 otherwise)
;   * DE (incremented appropriately)
; Destroys:
;   * BC, HL, IXH
Proc_HandleLine:      ; char *fp (DE)
    ; num1-num2,num3-num4 (B-C, H-L)
    HL_READ_NUM([B], ['-'], [_read2])
_read2:
    INC DE
    HL_READ_NUM([C], [','], [_read3])
_read3:
    INC DE
    HL_READ_NUM([H], ['-'], [_read4])
_read4:
    INC DE
    HL_READ_NUM([L], ['\n'], [_postRead])
_postRead:
    INC DE
    LD A, B
    CP H
    JR NC, _firstGreater ; B >= H
_secondGreater: ; B <= H
    LD A, C
    CP L
    JR NC, _contained ; L <= C
    JR _notContained
_firstGreater: ; H <= B
    LD A, L
    CP C
    JR NC, _contained ; C <= L
    LD A, B
    CP H
    JR Z, _secondGreater ; if B == H, check if C >= L also
_notContained:
    LD A, 0
    RET
_contained:
    LD A, 1
    RET

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
