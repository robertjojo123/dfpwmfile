import json
import struct

# Block ID to Block Name Mapping
block_names = {
    1: "stone", 2: "grass", 3: "dirt", 4: "cobblestone",
    5: "planks", 6: "sapling", 7: "bedrock", 8: "water",
    9: "lava", 10: "sand", 11: "gravel", 12: "gold_ore",
    13: "iron_ore", 14: "coal_ore", 15: "wood", 16: "leaves",
    17: "wooden_planks", 18: "wool", 19: "saplings", 20: "wooden_door",
    21: "beacon", 22: "black_wool", 23: "block_of_gold", 24: "block_of_quartz",
    25: "block_of_redstone", 26: "allium", 27: "azure_bluet", 28: "blue_orchid",
    29: "bricks", 30: "brick_slab", 31: "chiseled_quartz_block", 32: "chiseled_sandstone",
    33: "chiseled_stone_bricks", 34: "clay", 35: "cobblestone", 36: "cobblestone_stairs",
    37: "cobblestone_wall", 38: "dandelion", 39: "dirt", 40: "double_tallgrass", 
    41: "fern", 42: "glowstone", 43: "granite", 44: "grass", 45: "grass_block",
    46: "gravel", 47: "jungle_leaves", 48: "large_fern", 49: "lever", 50: "light_gray_wool",
    51: "lilac", 52: "lily_pad", 53: "moss_stone", 54: "mossy_stone_bricks", 55: "netherrack",
    56: "oak_fence", 57: "oak_leaves", 58: "oak_wood", 59: "oak_wood_planks", 60: "orange_tulip",
    61: "oxeye_daisy", 62: "packed_ice", 63: "peony", 64: "pillar_quartz_block", 65: "pink_tulip",
    66: "poppy", 67: "quartz_slab", 68: "quartz_stairs", 69: "red_tulip", 70: "redstone_lamp",
    71: "rose_bush", 72: "sand", 73: "sandstone", 74: "sandstone_slab", 75: "sandstone_stairs",
    76: "smooth_sandstone", 77: "snow_layer", 78: "snow_block", 79: "spruce_wood_planks",
    80: "spruce_wood_slab", 81: "spruce_wood_stairs", 82: "stone", 83: "stone_brick_stairs",
    84: "stone_bricks", 85: "stone_brick_slab", 86: "sunflower", 87: "vines", 88: "water",
    89: "water_bucket", 90: "white_tulip", 91: "white_wool"
}

# Function to get block name from block ID
def get_block_name(block_id):
    return block_names.get(block_id, "unknown")

# Function to read the schematic file in binary
def read_schematic_binary(filename):
    with open(filename, 'rb') as file:
        # Read the first 2 bytes to determine the format
        file.seek(0)  # Rewind in case we're past the beginning
        header = file.read(2)
        if header != b'\x00\x00':  # Check the header for WorldEdit .schematic format
            raise ValueError("Not a valid WorldEdit .schematic file")

        # Seek to where we find the data length (from the format spec)
        file.seek(0x08)  # Skipping the header part
        width = struct.unpack('>H', file.read(2))[0]
        length = struct.unpack('>H', file.read(2))[0]
        height = struct.unpack('>H', file.read(2))[0]

        # Blocks
        file.seek(0x10)  # Skipping to the block data
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
