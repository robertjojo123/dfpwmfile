-- Define the schematic data
local schematic = {
    width = 2,
    height = 1,
    length = 6,
    {x = 0, y = 0, z = 0, block = 'dirt'},
    {x = 0, y = 0, z = 1, block = 'dirt'},
    {x = 0, y = 0, z = 2, block = 'grass'},
    {x = 0, y = 0, z = 3, block = 'dirt'},
    {x = 0, y = 0, z = 4, block = 'dirt'},
    {x = 0, y = 0, z = 5, block = 'dirt'},
    {x = 1, y = 0, z = 0, block = 'dirt'},
    {x = 1, y = 0, z = 1, block = 'dirt'},
    {x = 1, y = 0, z = 2, block = 'dirt'},
    {x = 1, y = 0, z = 3, block = 'dirt'},
    {x = 1, y = 0, z = 4, block = 'dirt'},
    {x = 1, y = 0, z = 5, block = 'dirt'}
}

-- Start by setting the turtle's current position at (0, 0, 0)
local turtle_position = {x = 0, y = 0, z = 0}

-- Function to move the turtle to a given position (x, y, z)
local function move_to_position(x, y, z)
    local dx = x - turtle_position.x
    local dy = y - turtle_position.y
    local dz = z - turtle_position.z

    -- Move in x direction
    if dx > 0 then
        for i = 1, dx do
            turtle.forward()
        end
    elseif dx < 0 then
        for i = 1, -dx do
            turtle.back()
        end
    end

    -- Move in y direction (vertical movement)
    if dy > 0 then
        for i = 1, dy do
            turtle.up()
        end
    elseif dy < 0 then
        for i = 1, -dy do
            turtle.down()
        end
    end

    -- Move in z direction (horizontal movement)
    if dz > 0 then
        for i = 1, dz do
            turtle.turnRight()
            turtle.forward()
            turtle.turnLeft()
        end
    elseif dz < 0 then
        for i = 1, -dz do
            turtle.turnLeft()
            turtle.forward()
            turtle.turnRight()
        end
    end

    -- Update the turtle's position
    turtle_position.x = x
    turtle_position.y = y
    turtle_position.z = z
end

-- Function to place the block
local function place_block(block_name)
    -- Check if the turtle has the block in its inventory
    local success, data = turtle.inspectDown()
    if not success or data.name ~= block_name then
        -- Try to get the correct block from the turtle's inventory
        local found_block = false
        for i = 1, 16 do
            turtle.select(i)
            local success, data = turtle.getItemDetail()
            if success and data.name == block_name then
                found_block = true
                break
            end
        end
        
        -- If the block was found, place it
        if found_block then
            turtle.placeDown()
        else
            print("Error: No " .. block_name .. " in inventory.")
        end
    else
        -- Place the block if it's already the correct one
        turtle.placeDown()
    end
end

-- Build the schematic by iterating through the schematic data
local function build_schematic()
    for _, block_data in ipairs(schematic) do
        -- Move to the position of each block and place it
        move_to_position(block_data.x, block_data.y, block_data.z)
        place_block(block_data.block)
    end
end

-- Start building the schematic
build_schematic()
