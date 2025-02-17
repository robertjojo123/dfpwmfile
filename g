import json
import struct

# Block ID to Block Name Mapping (only a few blocks listed for now)
block_names = {
    1: "stone", 2: "grass", 3: "dirt", 4: "cobblestone",
    5: "planks", 6: "sapling", 7: "bedrock", 8: "water",
    9: "lava", 10: "sand", 11: "gravel", 12: "gold_ore",
    13: "iron_ore", 14: "coal_ore", 15: "wood", 16: "leaves",
    17: "wooden_planks", 18: "wool", 19: "saplings", 20: "wooden_door",
}

# Function to get block name from block ID
def get_block_name(block_id):
    return block_names.get(block_id, "unknown")

# Function to read the schematic file in binary
def read_schematic_binary(filename):
    with open(filename, 'rb') as file:
        # Read the first 2 bytes to determine the format
        header = file.read(2)
        print(f"File header: {header}")  # Debugging line to print header
        if header != b'\x00\x00':  # Check the header for WorldEdit .schematic format
            raise ValueError("Not a valid WorldEdit .schematic file")

        # Seek to where we find the data length (from the format spec)
        file.seek(0x08)  # Skipping to the block data section in the file
        width = struct.unpack('>H', file.read(2))[0]
        length = struct.unpack('>H', file.read(2))[0]
        height = struct.unpack('>H', file.read(2))[0]
        print(f"Schematic Dimensions - Width: {width}, Height: {height}, Length: {length}")  # Debugging line
        
        # Blocks (reads the entire block data as bytes)
        file.seek(0x10)  # Skipping ahead to the block data section
        blocks = file.read(width * height * length)
        return width, height, length, blocks

# Load the schematic file
def load_schematic(filename):
    width, height, length, blocks = read_schematic_binary(filename)
    
    block_list = []
    for i, block_id in enumerate(blocks):
        if block_id != 0:  # Skip air blocks
            x = i % width
            y = (i // width) % height
            z = i // (width * height)
            block_name = get_block_name(block_id)
            block_list.append({
                'x': x,
                'y': y,
                'z': z,
                'block': block_name
            })

    return block_list, width, height, length

# Convert the schematic data into a Lua table format
def convert_to_lua(blocks, width, height, length):
    lua_table = f"local schematic = {{\n    width = {width},\n    height = {height},\n    length = {length},\n"
    for block in blocks:
        lua_table += f"    {{x={block['x']}, y={block['y']}, z={block['z']}, block='{block['block']}'}}},\n"
    lua_table += "}\n"
    return lua_table

# Save the Lua table to a file
def save_lua_file(lua_code, filename="schematic.lua"):
    with open(filename, 'w') as file:
        file.write(lua_code)
    print(f"Lua file saved as {filename}")

# Main function to load, convert, and save
def main():
    schematic_file = input("Enter the path to the schematic file: ")
    blocks, width, height, length = load_schematic(schematic_file)
    lua_code = convert_to_lua(blocks, width, height, length)
    save_lua_file(lua_code)

if __name__ == "__main__":
    main()
