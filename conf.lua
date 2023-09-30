SCALE = 2
WIDTH = SCALE * 16 * 28
HEIGHT = SCALE * 16 * 15

function love.conf(t)
    t.window.width = WIDTH
    t.window.height = HEIGHT
    t.window.msaa = 0
end