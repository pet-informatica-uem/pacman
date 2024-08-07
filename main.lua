-- REQUIRE ---------------------------------------------------------------------

require("conf")
local mapa = require("scripts.mapa")

-- CONSTANTES ------------------------------------------------------------------

local MAX_TEMPO_INVENCIVEL = 10
local MAX_TEMPO_PERSEGUINDO = 5
local MAX_TEMPO_RECUANDO = 10
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
local ESTADO_FANTASMA_ENUM = {
    perseguir = "perseguir",
    recuar = "recuar",
    fugir = "fugir",
    retornar = "retornar"
}

-- VARIAVEIS -------------------------------------------------------------------

local estado = ESTADOS_ENUM.jogando
local pacman = { x = 14, y = 13, direcao = 0 }
local estadoFantasma = ESTADO_FANTASMA_ENUM.perseguir
local timerFantasma = 0
local fantasmas = {
    vermelho = { x = 13, y = 8, direcao = 0, estado = ESTADO_FANTASMA_ENUM.perseguir },
    azul     = { x = 14, y = 8, direcao = 0, estado = ESTADO_FANTASMA_ENUM.perseguir },
    rosa     = { x = 15, y = 8, direcao = 0, estado = ESTADO_FANTASMA_ENUM.perseguir },
    amarelo  = { x = 16, y = 8, direcao = 0, estado = ESTADO_FANTASMA_ENUM.perseguir },
}

-- como o jogo só e atualiazado em intervalos
-- de tempo, é necessário um buffer para
-- calcular o proximo comando do jogador
local buffer = MOVIMENTO_ENUM.direita
local matriz = mapa.carregar()

-- EXERCICIO!!! ----------------------------------------------------------------

function MudaEstadoFantasmas(estado)
    estadoFantasma = estado
    for _, fantasma in pairs(fantasmas) do
        if fantasma.estado ~= ESTADO_FANTASMA_ENUM.retornar then
            fantasma.estado = estado
        end
    end
end

function AtualizarFantasmas(fantasmas, pacman, matriz, dt)
    if timerFantasma <= 0 and estadoFantasma == ESTADO_FANTASMA_ENUM.fugir then
        timerFantasma = MAX_TEMPO_RECUANDO

        MudaEstadoFantasmas(ESTADO_FANTASMA_ENUM.recuar)
    end

    if timerFantasma > 0 then
        timerFantasma = timerFantasma - dt
    else
        if estadoFantasma == ESTADO_FANTASMA_ENUM.perseguir then
            timerFantasma = MAX_TEMPO_RECUANDO

            MudaEstadoFantasmas(ESTADO_FANTASMA_ENUM.recuar)
        elseif estadoFantasma == ESTADO_FANTASMA_ENUM.recuar then
            timerFantasma = MAX_TEMPO_PERSEGUINDO

            MudaEstadoFantasmas(ESTADO_FANTASMA_ENUM.perseguir)
        end
    end

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
        local vel = 1 / 16
        fantasma.x, fantasma.y = NovaPosicao(fantasma.x, fantasma.y, fantasma.direcao, vel)
    end
end

function IAVermelho(fantasmasArr, fantasma, pacman, matriz)
    if fantasma.x == 13 and fantasma.y == 8 and fantasma.estado == ESTADO_FANTASMA_ENUM.retornar then
        fantasma.estado = ESTADO_FANTASMA_ENUM.perseguir
    end

    local alvoX, alvoY

    if fantasma.estado == ESTADO_FANTASMA_ENUM.perseguir then
        alvoX, alvoY = pacman.x, pacman.y
    elseif fantasma.estado == ESTADO_FANTASMA_ENUM.fugir then
        local randomTable = {
            { x = fantasma.x + 1, y = fantasma.y },
            { x = fantasma.x - 1, y = fantasma.y },
            { x = fantasma.x,     y = fantasma.y + 1 },
            { x = fantasma.x,     y = fantasma.y - 1 },
        }
        local valor = math.random(4)

        alvoX, alvoY = NovaPosicao(randomTable[valor].x, randomTable[valor].y, pacman.direcao)
    elseif fantasma.estado == ESTADO_FANTASMA_ENUM.recuar then
        alvoX, alvoY = MapaW, 0
    elseif fantasma.estado == ESTADO_FANTASMA_ENUM.retornar then
        alvoX, alvoY = 13, 8
    end

    IA(fantasma, alvoX, alvoY, matriz)
end

function IAAzul(fantasmasArr, fantasma, pacman, matriz)
end

function IARosa(fantasmasArr, fantasma, pacman, matriz)
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

function IA(fantasma, alvoX, alvoY, matriz)
    local possiveis = PossiveisMovimentos(fantasma, pacman, matriz)

    local melhor = MOVIMENTO_ENUM.baixo
    local melhorDist = 99999

    for _, dir in pairs(possiveis) do
        local novoX, novoY = NovaPosicao(fantasma.x, fantasma.y, dir)
        local dist = math.sqrt((alvoX - novoX) ^ 2 + (alvoY - novoY) ^ 2)

        if dist < melhorDist then
            melhor = dir
            melhorDist = dist
        end
    end

    fantasma.direcao = melhor
end

-- FUNCOES PRINCIPAIS ----------------------------------------------------------

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
end

local acc = 0
function love.update(dt)
    acc = acc + dt
    while acc > 1/60 do
        if estado == ESTADOS_ENUM.jogando then
            AtualizarJogo(dt)
        end
        acc = acc - 1/60
    end
end

function AtualizarJogo(dt)
    VerificaBuffer()

    matriz[math.floor(pacman.x + 0.5)][math.floor(pacman.y + 0.5)] = ' '

    if not VerificarColisao(pacman.x, pacman.y, pacman.direcao, matriz) then
        pacman.x, pacman.y = NovaPosicao(pacman.x, pacman.y, pacman.direcao)

        if matriz[math.floor(pacman.x + 0.5)][math.floor(pacman.y + 0.5)] == 'c' then
            MudaEstadoFantasmas(ESTADO_FANTASMA_ENUM.fugir)
            timerFantasma = MAX_TEMPO_INVENCIVEL
        end
    end

    AtualizarFantasmas(fantasmas, pacman, matriz, dt)

    local fantasma = ChecarDerrota(fantasmas)
    if fantasma then
        if fantasma.estado == ESTADO_FANTASMA_ENUM.fugir or fantasma.estado == ESTADO_FANTASMA_ENUM.retornar then
            fantasma.estado = ESTADO_FANTASMA_ENUM.retornar
        else
            estado = ESTADOS_ENUM.derrota
        end
    end
end

function love.draw()
    love.graphics.clear()

    if estado == ESTADOS_ENUM.jogando then
        love.graphics.scale(SCALE, SCALE)
        mapa.desenhar(matriz)
        DesenharPacman(pacman)
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
    dist = dist or (1 / 16)

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

    for y = math.floor(novoY), math.ceil(novoY) do
        for x = math.floor(novoX), math.ceil(novoX) do
            if matriz[x][y] == 'x' then
                return true
            end
        end
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

function ChecarDerrota(fantasmas)
    for _, fantasma in pairs(fantasmas) do
        -- intersecta fantasma e pacman
        if (fantasma.x - pacman.x) ^ 2 + (fantasma.y - pacman.y) ^ 2 < 0.5 then
            return fantasma
        end
    end

    return nil
end

function DesenharFantasmas(fantasmas)
    for k, fantasma in pairs(fantasmas) do
        if fantasma.estado == ESTADO_FANTASMA_ENUM.fugir then
            love.graphics.setColor(0, 0, 1)
        else
            love.graphics.setColor(1, 1, 1)
        end

        if fantasma.estado == ESTADO_FANTASMA_ENUM.retornar then
            love.graphics.rectangle(
                "fill",
                (fantasma.x - 1) * (16),
                (fantasma.y - 1) * (16),
                16,
                16
            )
        else
            love.graphics.draw(
                ASSETS_MAP["fantasma_" .. k],
                (fantasma.x - 1) * (16),
                (fantasma.y - 1) * (16)
            )
        end
    end
    love.graphics.setColor(1, 1, 1)
end

function DesenharPacman(pacman)
    love.graphics.draw(
        ASSETS_MAP.pacman,
        (pacman.x - 1) * 16,
        (pacman.y - 1) * 16
    )
end
