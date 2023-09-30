ASSETS_MAP = {
    parede = love.graphics.newImage("assets/parede.png", { linear = true }),
    pacman = love.graphics.newImage("assets/pacman.png", { linear = true }),
    comida = love.graphics.newImage("assets/comida.png", { linear = true }),
    cereja = love.graphics.newImage("assets/cereja.png", { linear = true }),
    fantasma_vermelho = love.graphics.newImage("assets/fantasma_vermelho.png", { linear = true }),
    fantasma_rosa = love.graphics.newImage("assets/fantasma_rosa.png", { linear = true }),
    fantasma_azul = love.graphics.newImage("assets/fantasma_azul.png", { linear = true }),
    fantasma_amarelo = love.graphics.newImage("assets/fantasma_amarelo.png", { linear = true })
}

MapaW, MapaH = 0, 0

return {
    carregar = function()
        local i = 0
        local mapa = {}

        for lines in love.filesystem.lines("mapa.txt") do
            if i == 0 then
                for w in (lines .. ","):gmatch("(%d*),") do
                    if MapaW == 0 then
                        MapaW = tonumber(w)
                    elseif MapaH == 0 then
                        MapaH = tonumber(w)
                    end
                end
                --print("mapaW: " .. MapaW)
                --print("mapaH: " .. MapaH)

                for x = 1, MapaW do
                    mapa[x] = {}
                end

                i = i + 1
            else
                for x = 1, MapaW do
                    mapa[x][i] = lines:sub(x, x)
                end

                i = i + 1
            end
        end

        return mapa
    end,

    desenhar = function(mapa)
        for y = 1, MapaH do
            for x = 1, MapaW do
                if mapa[x][y] == 'x' then
                    love.graphics.draw(
                        ASSETS_MAP.parede,
                        (x - 1) * (16),
                        (y - 1) * (16)
                    )
                elseif mapa[x][y] == '.' then
                    love.graphics.draw(
                        ASSETS_MAP.comida,
                        (x - 1) * (16),
                        (y - 1) * (16)
                    )
                elseif mapa[x][y] == 'p' then
                    love.graphics.draw(
                        ASSETS_MAP.pacman,
                        (x - 1) * (16),
                        (y - 1) * (16)
                    )
                elseif mapa[x][y] == 'c' then
                    love.graphics.draw(
                        ASSETS_MAP.cereja,
                        (x - 1) * (16),
                        (y - 1) * (16)
                    )
                end
            end
        end
    end
}
