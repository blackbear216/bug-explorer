TILE_SIZE = 16
WIDTH = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()

player = {}

function love.load()
    player.width = TILE_SIZE
    player.height = TILE_SIZE
    player.x = WIDTH / 2
    player.y = HEIGHT / 2
    player.x_vel = 100
    player.y_vel = 100
    player.dir = 0
    player.last_pressed = ''
end

function love.update(dt)
    player.move(dt)
end

function love.draw()
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
end

function player.move(dt)
    if love.keyboard.isDown('a', 'left') then
        player.x = player.x - player.x_vel * dt
    end
    if love.keyboard.isDown('d', 'right') then
        player.x = player.x + player.x_vel * dt
    end
end
