require "levels"

TILE_SIZE = 16
WIDTH = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()
SCALE_FACTOR = 2.5

VIRTUAL_WIDTH = WIDTH / SCALE_FACTOR
VIRTUAL_HEIGHT = HEIGHT / SCALE_FACTOR

player = {}

function love.load()
    player.width = TILE_SIZE
    player.height = TILE_SIZE
    player.x = WIDTH / 2
    player.y = HEIGHT / 2
    player.x_vel = 100
    player.y_vel = 0
    player.grounded = true

    gravity = 250
    ground = 400
    current_level = meadow
    current_sublevel = meadow.x0y0
    sublevel_tiles = load_sublevel(meadow.x0y0)
end

function love.update(dt)
    player.move(dt)
    apply_gravity(dt)
    player.check_collision_tiles()
end

function love.draw()
    --love.graphics.scale(SCALE_FACTOR)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    for i, tile in ipairs(sublevel_tiles) do
        love.graphics.rectangle("line", tile.x, tile.y, tile.width, tile.height)
    end

    love.graphics.rectangle("line", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

function player.move(dt)
    if love.keyboard.isDown('a', 'left') then
        player.x = player.x - player.x_vel * dt
    end
    if love.keyboard.isDown('d', 'right') then
        player.x = player.x + player.x_vel * dt
    end
    if love.keyboard.isDown('w', 'up', 'space') then
        player.jump()
    end
    player.y = player.y - player.y_vel * dt
end

function player.jump()
    player.grounded = false
    player.y_vel = 100
end

function player.check_collision_tiles()
    for i,tile in ipairs(sublevel_tiles) do
        if check_collision(player, tile) then
            handle_collision(player, tile)
            break
        end
    end
end

function handle_collision(a, b)
    a.grounded = true
    a.y = b.y - a.height
end

function apply_gravity(dt)
    if not player.grounded then
        player.y_vel = player.y_vel - gravity * dt
    end
end

function check_collision(a, b)
    local a_left = a.x
    local a_right = a.x + a.width
    local a_top = a.y
    local a_bottom = a.y + a.height

    local b_left = b.x
    local b_right = b.x + b.width
    local b_top = b.y
    local b_bottom = b.y + b.height

    return a_right > b_left
    and a_left < b_right
    and a_bottom > b_top
    and a_top < b_bottom
end

function load_sublevel(sublevel)
    local sublevel_tiles = {}
    for i=1, #sublevel.logic do
        for j=1, #sublevel.logic[i] do
            if sublevel.logic[i][j] ~= 0 then
                local tile = {}
                tile.x = (j - 1) * TILE_SIZE
                tile.y = (i - 1) * TILE_SIZE
                tile.width = TILE_SIZE
                tile.height = TILE_SIZE
                table.insert(sublevel_tiles, tile)
            end
        end
    end

    return sublevel_tiles
end
