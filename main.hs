-- Bibliotecas para printar na tela
import System.IO.Unsafe (unsafePerformIO)
import Text.Printf (printf)

-- Definição do tipo memoria
type Memoria = [(Int, Int)]

--
-- Funções de leitura e escrita de memória !
--

-- Lê o conteúdo de um endereço da memória
readMem :: Memoria -> Int -> Int
readMem [] _ = 0 -- Not in memory = 0
readMem ((e,v):ms) addr
    | e == addr = v
    | otherwise = readMem ms addr

-- Escreve um valor em um endereço da memória
writeMem :: Memoria -> Int -> Int -> Memoria
writeMem [] addr val = [(addr, val)]
writeMem ((e,v):ms) addr val
    | e == addr = (e, val) : ms
    | otherwise = (e, v) : writeMem ms addr val

--
-- Execução de instruções !
--

-- NOP: Não faz nada
execNOP :: (Memoria, Int, Int) -> (Memoria, Int, Int)
execNOP (mem, acc, eqz) = (mem, acc, eqz)

-- LOD: Carrega valor da memória no acumulador
execLOD :: Int -> (Memoria, Int, Int) -> (Memoria, Int, Int)
execLOD end (mem, _, _) = (mem, acc, if acc == 0 then 1 else 0)
  where acc = readMem mem end

-- STO: Armazena valor do acumulador na memória
execSTO :: Int -> (Memoria, Int, Int) -> (Memoria, Int, Int)
execSTO end (mem, acc, eqz) = (writeMem mem end acc, acc, eqz)

-- ADD: Soma conteúdo de um endereço com o ACC
execADD :: Int -> (Memoria, Int, Int) -> (Memoria, Int, Int)
execADD end (mem, acc, _) = (mem, r, if r == 0 then 1 else 0)
  where r = (acc + readMem mem end) `mod` 256

-- SUB: Subtrai conteúdo de um endereço do ACC
execSUB :: Int -> (Memoria, Int, Int) -> (Memoria, Int, Int)
execSUB end (mem, acc, _) = (mem, r, if r == 0 then 1 else 0)
  where r = (acc - readMem mem end) `mod` 256

-- CPE: Compara com ACC
execCPE :: Int -> (Memoria, Int, Int) -> (Memoria, Int, Int)
execCPE end (mem, acc, _) = (mem, if acc == readMem mem end then 0 else 1, if acc == readMem mem end then 1 else 0)

executarInstrucao :: Int -> Int -> Int -> (Memoria, Int, Int) -> (Bool, Int, (Memoria, Int, Int))
executarInstrucao pc opcode addr estado@(mem, acc, eqz) =  -- @ usar a tupla inteira e/ou seus elementos.
  case opcode of 
    2  -> (False, pc + 2, execLOD addr estado) -- LOD
    4  -> (False, pc + 2, execSTO addr estado) -- STO
    6  -> (False, addr, estado)  -- JMP
    8  -> if eqz == 1 then (False, addr, estado) else (False, pc + 2, estado)  -- JMZ
    10 -> (False, pc + 2, execCPE addr estado) -- CPE
    14 -> (False, pc + 2, execADD addr estado) -- ADD
    16 -> (False, pc + 2, execSUB addr estado) -- SUB
    18 -> (False, pc + 2, execNOP estado) -- NOP
    20 -> (True, pc + 2, estado)  -- HLT
    _  -> (False, pc + 2, estado) -- Instrução inválida é ignorada

executar :: Memoria -> (Memoria, [String])
executar mem0 = loop mem0 0 0 0 []
  where
    loop mem pc acc eqz log =
      let opcode = readMem mem pc
          addr   = readMem mem (pc + 1)
          instrStr = instrucaoNome opcode addr
          estadoAntes = (mem, acc, eqz)
          (halt, nextPC, (mem', acc', eqz')) = executarInstrucao pc opcode addr estadoAntes
          linha = printf "<%-7s> PC=%03d OP=%03d ADDR=%03d | ACC=%03d EQZ=%d"
                instrStr pc opcode addr acc eqz
          novoLog = log ++ [linha]
      in if halt
         then (mem', novoLog)
         else loop mem' nextPC acc' eqz' novoLog

executarIO :: Memoria -> IO Memoria
executarIO prog = do
  let (memFinal, logExec) = executar prog
  mapM_ putStrLn logExec
  putStrLn "------------------------------------------------"
  putStr "Memoria final:"
  print memFinal
  return memFinal         

--            
-- Funções auxiliares
--

instrucaoNome :: Int -> Int -> String
instrucaoNome op addr = case op of
  2  -> "LOD " ++ show addr
  4  -> "STO " ++ show addr
  6  -> "JMP " ++ show addr
  8  -> "JMZ " ++ show addr
  10 -> "CPE " ++ show addr
  14 -> "ADD " ++ show addr
  16 -> "SUB " ++ show addr
  18 -> "NOP"
  20 -> "HLT"
  _  -> "INV"  -- Instrução inválida

--
-- Programas !
--

prog1 :: [(Int, Int)] -- 1) Resp = A + B – 2;
prog1 = [ -- Resposta esperada: 5 + 3 - 2 = 6
    (0,2), (1,240),  -- LOD 240 (A)
    (2,14), (3,241), -- ADD 241 (B)
    (4,16), (5,245), -- SUB 245 (const 2)
    (6,4), (7,251),  -- STO 251 (Resp)
    (8,20), (9,18),  -- HLT NOP

    -- Dados
    (240,5), (241,3), -- A = 5, B = 3
    (245,2), (251,0)  -- Const 2
    ]

prog2 :: [(Int, Int)] -- 2) Resp = A * B;
prog2 = [ -- Resposta esperada: 2 * 3 = 6
  (0,  2), (1, 245),   -- LOD Const 0 → ACC := 0
  (2,  4), (3, 251),   -- STO Resp := 0 → Resp := 0
  (4,  2), (5, 241),   -- LOD B
  (6,  4), (7, 242),   -- STO Temp

  (8,  2), (9, 242),   -- LOD Temp
  (10,16), (11,245),  -- SUB Const 0 (para ativar EQZ)
  (12,8), (13,28),    -- JMZ FIM (se Temp == 0)

  (14,2), (15,251),   -- LOD Resp
  (16,14), (17,240),  -- ADD A
  (18,4), (19,251),   -- STO Resp

  (20,2), (21,242),   -- LOD Temp
  (22,16), (23,246),  -- SUB Const 1
  (24,4), (25,242),   -- STO Temp

  (26,6), (27,8),     -- JMP LOOP

  (28,20), (29,18),   -- HLT NOP

  -- Dados
  (240, 2),   -- A = 2
  (241, 3),   -- B = 3
  (242, 0),   -- Temp
  (245, 0),   -- Const 0
  (246, 1),   -- Const 1
  (251, 0)    -- Resp
 ]

prog3 :: [(Int, Int)] -- 3) A = 0; Resp = 1; while(A < 5) { A = A + 1; Resp = Resp + 2; }
prog3 = [ -- Resposta esperada: A = 5, Resp = 11
  (0,  2), (1, 245),   -- LOD Const 1
  (2,  4), (3, 251),   -- STO Resp := 1
  (4,  2), (5, 245),   -- LOD Const 1
  (6, 16), (7, 245),   -- SUB Const 1 → ACC = 0
  (8,  4), (9, 240),   -- STO A := 0

  (10,2), (11,240),   -- LOD A
  (12,16), (13,247),  -- SUB Const 5
  (14,8), (15,30),    -- JMZ FIM (se A == 5)

  (16,2), (17,240),   -- LOD A
  (18,14), (19,245),  -- ADD Const 1
  (20,4), (21,240),   -- STO A

  (22,2), (23,251),   -- LOD Resp
  (24,14), (25,246),  -- ADD Const 2
  (26,4), (27,251),   -- STO Resp

  (28,6), (29,10),    -- JMP LOOP

  (30,20), (31,18),   -- HLT NOP

  -- Dados
  (240,0),    -- A
  (245,1),    -- Const 1
  (246,2),    -- Const 2
  (247,5),    -- Const 5
  (251,0)     -- Resp
 ]

prog4 :: [(Int, Int)]  -- 4) Ordena A e B decrementando cada variavel para ver quem chega a zero primeiro : 45, 111
prog4 = [
  -- temp_a := a
  (0, 2), (1, 242),     -- LOD a
  (2, 4), (3, 240),     -- STO temp_a

  -- temp_b := b
  (4, 2), (5, 243),     -- LOD b
  (6, 4), (7, 241),     -- STO temp_b

  -- INÍCIO LOOP
  -- if temp_a == 0 → fim (a <= b)
  (8, 2), (9, 246),     -- LOD const_0
  (10,10), (11, 240),   -- CPE temp_a
  (12,8), (13, 50),     -- JMZ fim_loop

  -- if temp_b == 0 → b terminou antes → A > B → troca
  (14, 2), (15, 246),   -- LOD const_0
  (16,10), (17, 241),   -- CPE temp_b
  (18,8), (19, 52),     -- JMZ trocaAB

  -- temp_a = temp_a - 1
  (20,2), (21, 240),    -- LOD temp_a
  (22,16),(23, 247),    -- SUB const_1
  (24,4), (25, 240),    -- STO temp_a

  -- temp_b = temp_b - 1
  (26,2), (27, 241),    -- LOD temp_b
  (28,16),(29, 247),    -- SUB const_1
  (30,4), (31, 241),    -- STO temp_b

  -- volta para início do loop
  (32,6), (33, 8),      -- JMP para início do loop

  -- FIM_LOOP (não troca)
  (50,6), (51, 72),     -- JMP ir para impressão

  -- TROCAR A e B
  (52,2), (53, 242),    -- LOD a
  (54,4), (55, 244),    -- STO temp = a

  (56,2), (57, 243),    -- LOD b
  (58,4), (59, 242),    -- a = b

  (60,2), (61, 244),    -- LOD temp
  (62,4), (63, 243),    -- b = temp

  -- zerar temporários
  (64,2), (65, 246),    -- LOD const_0
  (66,4), (67, 240),    -- temp_a = 0
  (68,4), (69, 241),    -- temp_b = 0
  (70,4), (71, 244),    -- temp = 0

  -- EXIBIR EM TELA
  (72,2), (73, 242),    -- LOD a
  (74,4), (75, 251),    -- tela[251]

  (76,2), (77, 243),    -- LOD b
  (78,4), (79, 252),    -- tela[252]

  (80,20), (81,18),     -- HLT NOP

  -- DADOS
  (240, 0),   -- temp_a
  (241, 0),   -- temp_b
  (242, 111),  -- a
  (243, 45),   -- b
  (244, 0),   -- temp 
  (246, 0),   -- const_0
  (247, 1)    -- const_1
 ]

  

-- Execução dos programas
main1 :: IO ()
main1 = do
  putStrLn "\n\tResp = A + B - 2 | A = 5, B = 3"
  putStrLn "------------------------------------------------"
  memFinal <- executarIO prog1
  imprimeTela memFinal

main2 :: IO ()
main2 = do
  putStrLn "\n\tResp = A * B | A = 2, B = 3"
  putStrLn "------------------------------------------------"
  memFinal <- executarIO prog2
  imprimeTela memFinal

main3 :: IO ()
main3 = do
  putStrLn "\n\tA = 0;\n\tResp = 1;\n\twhile (A < 5) {\n\t A = A + 1;\n\t Resp = Resp + 2;\n\t}"
  putStrLn "------------------------------------------------"
  memFinal <- executarIO prog3
  imprimeTela memFinal

main4 :: IO ()
main4 = do
  putStrLn "\n\t Ordena A e B \tA = 111, B = 45"
  putStrLn "------------------------------------------------"
  memFinal <- executarIO prog4
  imprimeTela memFinal

-- Controlador de video
imprimeTela :: Memoria -> IO ()
imprimeTela mem = do
  let resposta = readMem mem 251
  putStrLn "-------------------"
  mapM_ (\i -> printf "| Tela[%03d] = %3d |\n" i (readMem mem i)) [251..255]
  putStrLn "-------------------"
  printf "RESPOSTA = %d\n" resposta

--- Leitura de aqruivos para entrada -> instrução de uso = executarArquivo "nome_do_arquivo.txt"
executarArquivo :: FilePath -> IO ()
executarArquivo arquivo = do
  putStrLn $ "\nExecutando programa do arquivo '" ++ arquivo ++ "'\n"
  conteudo <- readFile arquivo
  let memoria = map read (lines conteudo) :: Memoria
  memFinal <- executarIO memoria
  imprimeTela memFinal