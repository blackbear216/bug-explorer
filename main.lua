-- maybe make collision more efficient than aabb
-- make it so i can collide with walls and distinguish them from floors

require "levels"
require "player"

TILE_SIZE = 16
WIDTH = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()
SCALE_FACTOR = 2.5
GRAVITY = 250

VIRTUAL_WIDTH = WIDTH / SCALE_FACTOR
VIRTUAL_HEIGHT = HEIGHT / SCALE_FACTOR

function love.load()
    player.load()

    current_level = meadow
    current_sublevel = meadow.x0y0
    sublevel_tiles = load_sublevel(meadow.x0y0)
end

function love.update(dt)
    apply_gravity(dt)
    player.update(dt)
end

function love.draw()
    love.graphics.scale(SCALE_FACTOR)
    player.draw()
    for i, tile in ipairs(sublevel_tiles) do
        love.graphics.rectangle("line", tile.x, tile.y, tile.width, tile.height)
    end

    love.graphics.rectangle("line", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

function handle_collision(a, b)
    a.grounded = true
    a.y = b.y - a.height
end

function apply_gravity(dt)
    if not player.grounded then
        player.y_vel = player.y_vel + GRAVITY * dt
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

function copy_table(old_table)
    local new_table = {}

    for i,v in ipairs(old_table) do
        table.insert(new_table, v)
    end

    return new_table
end
