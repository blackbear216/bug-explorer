player = {}

function player.load()
    player.width = TILE_SIZE
    player.height = TILE_SIZE
    player.x = VIRTUAL_WIDTH / 2
    player.y = VIRTUAL_HEIGHT / 2
    player.prev_x = player.x
    player.prev_y = player.y
    player.x_vel = 0
    player.y_vel = 0
    player.grounded = false
    player.left = false
    player.right = false
    player.up = false
    player.down = false
end

function player.update(dt)
    player.move(dt)
    --player.check_collision_tiles()
    --player.handle_collision(dt)
end

function player.draw()
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    love.graphics.print(player.x, 100, 100)
    love.graphics.print(player.y, 200, 100)

    for i=1, #current_sublevel.logic do
        for j=1, #current_sublevel.logic[i] do
            love.graphics.print(current_sublevel.logic[i][j], (j-1) * TILE_SIZE, (i-1) * TILE_SIZE)
        end
    end
end

function player.move(dt)
    -- this move function double dips
    -- so first i move to x location
    -- then my collision detector checks the location AFTER that move i alraedy made
    -- this is causing collision errors
    -- before i do a move here i have to do a full collision check
    -- then either do the move if its clear
    -- or handle the collision if it would make a collision

    player.prev_x = player.x

    if love.keyboard.isDown('a', 'left') 
    and love.keyboard.isDown('d', 'right') then
        player.x_vel = 0
    elseif love.keyboard.isDown('a', 'left') then
        player.x_vel = -100
    elseif love.keyboard.isDown('d', 'right') then
        player.x_vel = 100
    else
        player.x_vel = 0
    end

    if love.keyboard.isDown('w', 'up', 'space') then
        player.jump()
    end

    player.decide_direction()

    player.x = player.next_move(dt, "x")--player.x + player.x_vel * dt

    if not player.grounded then
        player.prev_y = player.y
        player.y = player.next_move(dt, "y")--player.y - player.y_vel * dt
    end
end

function player.jump()
    player.grounded = false
    player.y_vel = -100
end

function player.check_collision_tiles()
    for i,tile in ipairs(sublevel_tiles) do
        if check_collision(player, tile) then
            handle_collision(player, tile)
            break
        end
    end
end

function player.decide_direction()
    if player.x_vel > 0 then
        player.right = true
        player.left = false
    elseif player.x_vel < 0 then
        player.right = false
        player.left = true
    else
        player.right = false
        player.left = false
    end

    if player.y_vel > 0 then
        player.down = true
        player.up = false
    elseif player.y_vel < 0 then
        player.down = false
        player.up = true
    else
        player.down = false
        player.up = false
    end
end

function player.check_collision(dt, axis)
    if axis == "x" then
        if player.left then
            if player.x - (player.x_vel * dt) >= 0 then
                local next_top_left = {math.ceil((player.x + (player.x_vel * dt)) / TILE_SIZE), math.ceil((player.y + 1) / TILE_SIZE)}
                local next_bottom_left = {math.ceil((player.x + (player.x_vel * dt)) / TILE_SIZE), math.ceil((player.y + player.height) / TILE_SIZE)}
                if current_sublevel.logic[next_top_left[2]][next_top_left[1]] == 1 then
                    return {"left", copy_table(next_top_left)}
                elseif current_sublevel.logic[next_bottom_left[2]][next_bottom_left[1]] == 1 then
                    return {"left", copy_table(next_bottom_left)}
                end
            end
        end
        if player.right then
            if player.x + player.width + (player.x_vel * dt) <= VIRTUAL_WIDTH then
                local next_top_right = {math.ceil(((player.x + player.width) + (player.x_vel * dt)) / TILE_SIZE), math.ceil((player.y + 1) / TILE_SIZE)}
                local next_bottom_right = {math.ceil(((player.x + player.width) + (player.x_vel * dt)) / TILE_SIZE), math.ceil((player.y + player.height) / TILE_SIZE)}
                if current_sublevel.logic[next_top_right[2]][next_top_right[1]] == 1 then
                    return {"right", copy_table(next_top_right)}
                elseif current_sublevel.logic[next_bottom_right[2]][next_bottom_right[1]] == 1 then
                    return {"right", copy_table(next_bottom_right)}
                end
            end
        end
    end

    if axis == "y" then
        if player.up then
            if player.y - (player.y_vel * dt) >= 0 then
                local next_top_left = {math.ceil((player.x + 1) / TILE_SIZE), math.ceil((player.y + (player.y_vel * dt)) / TILE_SIZE)}
                local next_top_right = {math.ceil((player.x - 1 + player.width) / TILE_SIZE), math.ceil((player.y + (player.y_vel * dt)) / TILE_SIZE)}
                if current_sublevel.logic[next_top_left[2]][next_top_left[1]] == 1 then
                    return {"up", copy_table(next_top_left)}
                elseif current_sublevel.logic[next_top_right[2]][next_top_right[1]] == 1 then
                    return {"up", copy_table(next_top_right)}
                end
            end
        end
        if player.down then
            if player.y + player.height + (player.y_vel * dt) <= VIRTUAL_HEIGHT then
                local next_bottom_left = {math.ceil((player.x + 1) / TILE_SIZE), math.ceil(((player.y + player.height) + (player.y_vel * dt)) / TILE_SIZE)}
                local next_bottom_right = {math.ceil((player.x - 1 + player.width) / TILE_SIZE), math.ceil(((player.y + player.height) + (player.y_vel * dt)) / TILE_SIZE)}
                if current_sublevel.logic[next_bottom_left[2]][next_bottom_left[1]] == 1 then
                    return {"down", copy_table(next_bottom_left)}
                elseif current_sublevel.logic[next_bottom_right[2]][next_bottom_right[1]] == 1 then
                    return {"down", copy_table(next_bottom_right)}
                end
            end
        end
    end

    return false
end

function player.resolve_collision(collision)
    if collision[1] == "left" then
        return collision[2][1] * TILE_SIZE
    elseif collision[1] == "right" then
        return collision[2][1] * TILE_SIZE - TILE_SIZE - player.width
    elseif collision[1] == "up" then
        player.y_vel = 0
        return collision[2][2] * TILE_SIZE
    elseif collision[1] == "down" then
        player.set_grounded()
        return collision[2][2] * TILE_SIZE - TILE_SIZE - player.height
    end
end

function player.next_move(dt, axis)
    local collision = player.check_collision(dt, axis)
    if collision then
        return player.resolve_collision(collision)
    else
        if axis == "x" then
            return player.x + player.x_vel * dt
        elseif axis == "y" then
            return player.y + player.y_vel * dt
        end
    end
end

function player.set_grounded()
    player.grounded = true
    player.y_vel = 0
end