COMO EXECUTAR :
>ghci main.hs
>main1
>main2
>main3
>main4

**Programa 1: Resp = A + B - 2**

Código Assembly:
000: LOD 240  ; Carrega o valor de A (endereço 240) no ACC
002: ADD 241  ; Adiciona o valor de B (endereço 241) ao ACC
004: SUB 245  ; Subtrai o valor da constante 2 (endereço 245) do ACC
006: STO 251  ; Armazena o resultado em Resp (endereço 251)
008: HLT      ; Para o programa
010: NOP      ; Nenhuma operação (preenchimento)

; DADOS

240: 5        ; A = 5
241: 3        ; B = 3
245: 2        ; Constante 2
251: 0        ; Resp (inicialmente 0)



**Programa 2: Resp = A * B**

Código Assembly:
000: LOD 245  ; Carrega Const 0 no ACC (ACC = 0)
002: STO 251  ; Armazena ACC (0) em Resp (Resp = 0)
004: LOD 241  ; Carrega B no ACC
006: STO 242  ; Armazena B em Temp
008: LOD 242  ; Carrega Temp no ACC
010: SUB 245  ; Subtrai Const 0 do ACC (para ativar a flag EQZ)
012: JMZ 028  ; Se Temp == 0, pula para o final (HLT)
014: LOD 251  ; Carrega Resp no ACC
016: ADD 240  ; Adiciona A ao ACC
018: STO 251  ; Armazena ACC em Resp
020: LOD 242  ; Carrega Temp no ACC
022: SUB 246  ; Subtrai Const 1 de Temp
024: STO 242  ; Armazena Temp de volta na memória
026: JMP 008  ; Pula para o início do loop
028: HLT      ; Para
030: NOP      ; Nenhuma operação

; DADOS

240: 2        ; A = 2
241: 3        ; B = 3
242: 0        ; Temp = 0
245: 0        ; Const 0 = 0
246: 1        ; Const 1 = 1
251: 0        ; Resp = 0



**Programa 3: A = 0; Resp = 1; while(A < 5) { A = A + 1; Resp = Resp + 2; }**

Código Assembly:
000: LOD 245  ; Carrega Const 1 no ACC
002: STO 251  ; Armazena ACC em Resp (Resp = 1)
004: LOD 245  ; Carrega Const 1 no ACC
006: SUB 245  ; Subtrai Const 1 do ACC (ACC = 0)
008: STO 240  ; Armazena ACC em A (A = 0)
010: LOD 240  ; Carrega A no ACC
012: SUB 247  ; Subtrai Const 5 do ACC
014: JMZ 030  ; Se A == 5, pula para o final (HLT)
016: LOD 240  ; Carrega A no ACC
018: ADD 245  ; Adiciona Const 1 ao ACC
020: STO 240  ; Armazena ACC em A
022: LOD 251  ; Carrega Resp no ACC
024: ADD 246  ; Adiciona Const 2 ao ACC
026: STO 251  ; Armazena ACC em Resp
028: JMP 010  ; Pula para o início do loop
030: HLT      ; Para
032: NOP      ; Nenhuma operação

; DADOS

240: 0        ; A = 0
245: 1        ; Const 1 = 1
246: 2        ; Const 2 = 2
247: 5        ; Const 5 = 5
251: 0        ; Resp = 0



**Programa 4: Ordena A e B**

Código Assembly:
000: LOD 242  ; LOD a
002: STO 240  ; STO temp_a
004: LOD 243  ; LOD b
006: STO 241  ; STO temp_b

; INÍCIO LOOP

008: LOD 246  ; LOD const_0
010: CPE 240  ; CPE temp_a
012: JMZ 050  ; JMZ fim_loop
014: LOD 246  ; LOD const_0
016: CPE 241  ; CPE temp_b
018: JMZ 052  ; JMZ trocaAB

; temp_a = temp_a - 1

020: LOD 240  ; LOD temp_a
022: SUB 247  ; SUB const_1
024: STO 240  ; STO temp_a

; temp_b = temp_b - 1

026: LOD 241  ; LOD temp_b
028: SUB 247  ; SUB const_1
030: STO 241  ; STO temp_b

; volta para início do loop

032: JMP 008  ; JMP para início do loop

; FIM_LOOP (não troca)

050: JMP 072  ; JMP ir para impressão

; TROCAR A e B

052: LOD 242  ; LOD a
054: STO 244  ; STO temp = a
056: LOD 243  ; LOD b
058: STO 242  ; a = b
060: LOD 244  ; LOD temp
062: STO 243  ; b = temp

; zerar temporários

064: LOD 246  ; LOD const_0
066: STO 240  ; temp_a = 0
068: STO 241  ; temp_b = 0
070: STO 244  ; temp = 0

; EXIBIR EM TELA

072: LOD 242  ; LOD a
074: STO 251  ; tela[251]
076: LOD 243  ; LOD b
078: STO 252  ; tela[252]
080: HLT      ; HLT
082: NOP      ; NOP

; DADOS

240: 0        ; temp_a
241: 0        ; temp_b
242: 111      ; a
243: 45       ; b
244: 0        ; temp
246: 0        ; const_0
247: 1        ; const_1