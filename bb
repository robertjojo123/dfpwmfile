-- Define schematic data (can be read from a file in real use case)
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

-- Positions of chests for fuel and materials
local fuel_chest_position = {x = 0, y = 0, z = -1}  -- Chest for fuel is behind the turtle
local material_chest_position = {x = 0, y = 0, z = -2}  -- Chest for materials is two blocks behind the turtle

-- Turtle's current position (we'll update this as the turtle moves)
local turtle_position = {x = 0, y = 0, z = 0}

-- Function to check if an item is a fuel source
local function is_fuel(item)
    return item.name == "minecraft:coal" or item.name == "minecraft:charcoal"
end

-- Function to access chest behind the turtle
local function access_chest(chest_position)
    -- Move to the chest position and align
    move_to_position(chest_position.x, chest_position.y, chest_position.z)
end

-- Function to refuel the turtle
local function refuel_turtle()
    if turtle.getFuelLevel() == "unlimited" then return true end

    access_chest(fuel_chest_position)

    while turtle.getFuelLevel() < 1000 do -- Ensure enough fuel for the task
        for slot = 1, 16 do
            local item = turtle.getItemDetail(slot)
            if item and is_fuel(item) then
                turtle.select(slot)
                turtle.refuel(1) -- Refuel one unit at a time
                print("Refueled with " .. item.name)
                return true
            end
        end
    end
    return false
end

-- Function to restock materials from the material chest
local function restock_from_chest(target_name, min_count)
    access_chest(material_chest_position)

    local attempts = 0
    while attempts < 5 do
        for slot = 1, 16 do
            if turtle.suck(slot) then
                local item = turtle.getItemDetail()
                if item and item.name == "minecraft:" .. target_name then
                    if turtle.getItemCount() >= min_count then
                        return true
                    end
                else
                    turtle.drop()  -- Drop unwanted items
                end
            end
        end
        attempts = attempts + 1
    end
    return false
end

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

-- Function to find and select the correct block
local function select_block(block_name)
    -- Search through the turtle's inventory for the correct block type
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and item.name == "minecraft:" .. block_name then
            turtle.select(slot)
            return true
        end
    end
    return false
end

-- Function to place the block
local function place_block(block_name)
    if select_block(block_name) then
        turtle.placeDown()  -- Place the block below the turtle
    else
        print("No " .. block_name .. " in inventory!")
    end
end

-- Function to build the schematic
local function build_schematic()
    for i, block_data in ipairs(schematic) do
        -- Move to the position of each block in the schematic
        move_to_position(block_data.x, block_data.y, block_data.z)
        
        -- Ensure the turtle has enough fuel and materials before placing the block
        refuel_turtle()
        restock_from_chest(block_data.block, 64)  -- Restock each block as needed
        
        -- Place the block
        place_block(block_data.block)
    end
end

-- Start building the schematic
build_schematic()
