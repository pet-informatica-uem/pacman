-- DISCLAIMER
-- Este código foi feito para fins de estudo e aprendizado.
-- Algumas coisas como:
--     - Argumentos de funcoes com o mesmo nome de variaveis
--       definidas anteriormente é uma má prática de programação
--       porém foi feito desse jeito para deixar as funções mais puras
--       possiveis e facilitar o entendimento

-- REQUIRE ---------------------------------------------------------------------

require("conf")
local mapa = require("scripts.mapa")

-- CONSTANTES ------------------------------------------------------------------

local MAX_TEMPO_INVENCIVEL = 3
local STEP = 1/4
local MOVIMENTO_ENUM = {
    cima = "cima",
    direita = "direita",
    baixo = "baixo",
    esquerda = "esquerda",
}
local ESTADOS_ENUM = {
    jogando = "jogando",
    vitoria = "vitoria",
    derrota = "derrota",
}

-- VARIAVEIS -------------------------------------------------------------------

local estado = ESTADOS_ENUM.jogando
local pacman = {x = 14, y = 13, direcao=0}
local pontos = 0
local tempoInvencivel = 0
local invencivel = false
local fantasmas = {
    vermelho = {x = 13, y = 8, direcao=0},
    azul     = {x = 14, y = 8, direcao=0},
    rosa     = {x = 15, y = 8, direcao=0},
    amarelo  = {x = 16, y = 8, direcao=0},
}

-- como o jogo só e atualiazado em intervalos
-- de tempo, é necessário um buffer para
-- calcular o proximo comando do jogador
local buffer = MOVIMENTO_ENUM.direita
local contador = 0
local matriz = mapa.carregar()

-- EXERCICIO!!! ----------------------------------------------------------------

function AtualizarFantasmas(fantasmas, x, y, matriz)
    IAVermelho(fantasmas, fantasmas.vermelho, pacman, matriz)
    IAAzul(fantasmas, fantasmas.azul, pacman, matriz)
    IARosa(fantasmas, fantasmas.rosa, pacman, matriz)
    IAAmarelo(fantasmas, fantasmas.amarelo, pacman, matriz)

    for _, fantasma in pairs(fantasmas) do
        MoverFantasma(fantasma, matriz)
    end
end

-- 1) Crie uma função para mover um determinado fantasma
function MoverFantasma(fantasma, matriz)
    if not VerificarColisao(fantasma.x, fantasma.y, fantasma.direcao, matriz) then
        fantasma.x, fantasma.y = NovaPosicao(fantasma.x, fantasma.y, fantasma.direcao)
    end
end

function IAVermelho(fantasmasArr, fantasma, pacman, matriz)
    local alvoX, alvoY = NovaPosicao(pacman.x, pacman.y, pacman.direcao)

    local possiveis = PossiveisMovimentos(fantasma, pacman, matriz)

    local melhor = MOVIMENTO_ENUM.baixo
    local melhorDist = math.huge

    for _, dir in pairs(possiveis) do
        local novoX, novoY = NovaPosicao(fantasma.x, fantasma.y, dir)
        local dist = math.sqrt((alvoX - novoX)^2 + (alvoY - novoY)^2)

        if dist < melhorDist then
            melhor = dir
            melhorDist = dist
        end
    end

    fantasma.direcao = melhor
end

function IAAzul(fantasmasArr, fantasma, pacman, matriz)
    
end

function IARosa(fantasmasArr, fantasma, pacman, matriz)
    local alvoX, alvoY = NovaPosicao(pacman.x, pacman.y, pacman.direcao, 2)

    local possiveis = PossiveisMovimentos(fantasma, pacman, matriz)

    local melhor = MOVIMENTO_ENUM.baixo
    local melhorDist = math.huge

    for _, dir in pairs(possiveis) do
        local novoX, novoY = NovaPosicao(fantasma.x, fantasma.y, dir)
        local dist = math.sqrt((alvoX - novoX)^2 + (alvoY - novoY)^2)

        if dist < melhorDist then
            melhor = dir
            melhorDist = dist
        end
    end

    fantasma.direcao = melhor
end

function IAAmarelo(fantasmasArr, fantasma, pacman, matriz)
    
end

function PossiveisMovimentos(fantasma, pacman, matriz)
    local possiveis = {}

    if not VerificarColisao(fantasma.x, fantasma.y, MOVIMENTO_ENUM.cima, matriz) and fantasma.direcao ~= MOVIMENTO_ENUM.baixo then
        table.insert(possiveis, MOVIMENTO_ENUM.cima)
    end

    if not VerificarColisao(fantasma.x, fantasma.y, MOVIMENTO_ENUM.direita, matriz) and fantasma.direcao ~= MOVIMENTO_ENUM.esquerda then
        table.insert(possiveis, MOVIMENTO_ENUM.direita)
    end

    if not VerificarColisao(fantasma.x, fantasma.y, MOVIMENTO_ENUM.esquerda, matriz) and fantasma.direcao ~= MOVIMENTO_ENUM.direita then
        table.insert(possiveis, MOVIMENTO_ENUM.esquerda)
    end

    if not VerificarColisao(fantasma.x, fantasma.y, MOVIMENTO_ENUM.baixo, matriz) and fantasma.direcao ~= MOVIMENTO_ENUM.cima then
        table.insert(possiveis, MOVIMENTO_ENUM.baixo)
    end

    return possiveis
end

-- FUNCOES PRINCIPAIS ----------------------------------------------------------

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
end

function love.update(dt)
    if estado == ESTADOS_ENUM.jogando then
        AtualizarJogo(dt)
    end
end

function AtualizarJogo(dt)
    if tempoInvencivel > 0 then
        tempoInvencivel = tempoInvencivel - dt
        invencivel = true
    else
        invencivel = false
    end

    contador = contador + dt

    if contador < STEP then
        return
    end

    VerificaBuffer()

    matriz[pacman.x][pacman.y] = ' '

    if not VerificarColisao(pacman.x, pacman.y, pacman.direcao, matriz) then
        pacman.x, pacman.y = NovaPosicao(pacman.x, pacman.y, pacman.direcao)

        ChecarPontuacao(pacman.x, pacman.y, matriz)
    end

    matriz[pacman.x][pacman.y] = 'p'

    AtualizarFantasmas(fantasmas, pacman.x, pacman.y, matriz)
    if ChecarDerrota(fantasmas) then
        estado = ESTADOS_ENUM.derrota
    end

    contador = 0
end

function love.draw()
    love.graphics.clear()

    if estado == ESTADOS_ENUM.jogando then
        love.graphics.scale(SCALE, SCALE)
        mapa.desenhar(matriz)
    
        DesenharFantasmas(fantasmas)
    elseif estado == ESTADOS_ENUM.derrota then
        love.graphics.print("Você perdeu!", 10, 10)
    elseif estado == ESTADOS_ENUM.vitoria then
        love.graphics.print("Você venceu!", 10, 10)
    end
end

function love.keypressed(key)
    if key == love.keyboard.getKeyFromScancode("w") then
        buffer = MOVIMENTO_ENUM.cima
    elseif key == love.keyboard.getKeyFromScancode("d") then
        buffer = MOVIMENTO_ENUM.direita
    elseif key == love.keyboard.getKeyFromScancode("s") then
        buffer = MOVIMENTO_ENUM.baixo
    elseif key == love.keyboard.getKeyFromScancode("a") then
        buffer = MOVIMENTO_ENUM.esquerda
    end
end

-- FUNCOES AUXILIARES ----------------------------------------------------------

function VerificaBuffer()
    if not VerificarColisao(pacman.x, pacman.y, buffer, matriz) then
        pacman.direcao = buffer
    end
end

---Determina a nova posição do passado com a determinada direcao
---note que a funcao retorna dois valores
---o novo x e o novo y
function NovaPosicao(x, y, mov, dist)
    dist = dist or 1

    local novoX = x
    local novoY = y

    if mov == MOVIMENTO_ENUM.cima then
        novoY = novoY - dist
    elseif mov == MOVIMENTO_ENUM.direita then
        novoX = novoX + dist
    elseif mov == MOVIMENTO_ENUM.baixo then
        novoY = novoY + dist
    elseif mov == MOVIMENTO_ENUM.esquerda then
        novoX = novoX - dist
    end

    -- reduz 1 pois a matriz começa em 1 e não em 0
    return ((novoX - 1) % MapaW) + 1, ((novoY - 1) % MapaH) + 1
end

---Verifica se ocorrera colisao na nova posicao
function VerificarColisao(x, y, mov, matriz)
    local novoX, novoY = NovaPosicao(x, y, mov)

    if novoX < 1 or novoX > MapaW or novoY < 1 or novoY > MapaH then
        return false
    end

    if matriz[novoX][novoY] == 'x' then
        return true
    end

    return false
end

function VerificaIntersecao(x, y, matriz)
    local n = 0
    for i = x - 1, x + 1 do
        for j = y - 1, y + 1 do
            if i >= 1 and i <= MapaW and j >= 1 and j <= MapaH then
                if matriz[i][j] ~= 'x' then
                    n = n + 1
                end

                if n > 3 then
                    return true
                end
            end
        end
    end

    return false
end

function ChecarPontuacao(x, y, matriz)
    if matriz[x][y] == '.' then
        pontos = pontos + 100
    elseif matriz[x][y] == 'c' then
        pontos = pontos + 1000
        tempoInvencivel = MAX_TEMPO_INVENCIVEL
    end
end

function ChecarDerrota(fantasmas)
    for _, posicaoFantasma in pairs(fantasmas) do
        if posicaoFantasma.x == pacman.x and posicaoFantasma.y == pacman.y then
            return true
        end
    end
    
    return false
end

function DesenharFantasmas(fantasmas)
    love.graphics.draw(
        ASSETS_MAP.fantasma_vermelho, 
        (fantasmas.vermelho.x-1)*(16), 
        (fantasmas.vermelho.y-1)*(16)
    )

    love.graphics.draw(
        ASSETS_MAP.fantasma_azul, 
        (fantasmas.azul.x-1)*(16), 
        (fantasmas.azul.y-1)*(16)
    )

    love.graphics.draw(
        ASSETS_MAP.fantasma_rosa, 
        (fantasmas.rosa.x-1)*(16), 
        (fantasmas.rosa.y-1)*(16)
    )

    love.graphics.draw(
        ASSETS_MAP.fantasma_amarelo, 
        (fantasmas.amarelo.x-1)*(16), 
        (fantasmas.amarelo.y-1)*(16)
    )
end