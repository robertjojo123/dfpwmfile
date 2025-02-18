import nbtlib
import os
import numpy as np
import time

MINECRAFT_CHUNK_SIZE = 16  # 16x16 chunk size
MAX_BLOCKS_PER_FILE = 25000  # Max blocks per Lua file

# Function to map block IDs to names
def get_block_name(block_id):
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
        41: "fern", 42: "glowstone", 43: "granite", 44: "grass (plant)", 45: "grass_block",
        46: "gravel", 47: "jungle_leaves", 48: "large_fern", 49: "lever", 50: "light_gray_wool",
        51: "lilac", 52: "lily_pad", 53: "moss_stone", 54: "mossy_stone_bricks", 55: "netherrack",
        56: "oak_fence", 57: "oak_leaves", 58: "oak_wood", 59: "oak_wood_planks", 60: "orange_tulip",
        61: "oxeye_daisy", 62: "packed_ice", 63: "peony", 64: "pillar_quartz_block", 65: "pink_tulip",
        66: "poppy", 67: "quartz_slab", 68: "quartz_stairs", 69: "red_tulip", 70: "redstone_lamp",
        71: "rose_bush", 72: "sand", 73: "sandstone", 74: "sandstone_slab", 75: "sandstone_stairs",
        76: "smooth_sandstone", 77: "snow (layer)", 78: "snow (block)", 79: "spruce_wood_planks",
        80: "spruce_wood_slab", 81: "spruce_wood_stairs", 82: "stone", 83: "stone_brick_stairs",
        84: "stone_bricks", 85: "stone_brick_slab", 86: "sunflower", 87: "vines", 88: "water",
        89: "water_bucket", 90: "white_tulip", 91: "white_wool"
    }
    return block_names.get(block_id, f"unknown ({block_id})")

# Load schematic and process block data in 16x16 chunks
def load_schematic(filename):
    if not os.path.isfile(filename):
        print(f"❌ File not found: {filename}")
        return None, None, None, None

    print("📂 Loading schematic file...")
    start_time = time.time()

    schematic_data = nbtlib.load(filename)
    width, height, length = int(schematic_data['Width']), int(schematic_data['Height']), int(schematic_data['Length'])
    blocks = np.array(schematic_data.get('Blocks', []), dtype=np.uint8)

    print(f"✅ Schematic loaded in {time.time() - start_time:.2f} seconds.")

    structured_chunks = {}

    print("\n🔄 Processing blocks into 16x16 chunks...")

    for chunk_x in range(0, width, MINECRAFT_CHUNK_SIZE):
        for chunk_z in range(0, length, MINECRAFT_CHUNK_SIZE):
            chunk_key = (chunk_x, chunk_z)
            structured_chunks[chunk_key] = []

            for y in range(height):
                for x in range(chunk_x, min(chunk_x + MINECRAFT_CHUNK_SIZE, width)):
                    for z in range(chunk_z, min(chunk_z + MINECRAFT_CHUNK_SIZE, length)):
                        i = y * width * length + z * width + x
                        block_id = int(blocks[i])
                        if block_id != 0:
                            structured_chunks[chunk_key].append({
                                'x': x,
                                'y': y,
                                'z': z,
                                'block': get_block_name(block_id)
                            })

    print(f"✅ All blocks sorted into {len(structured_chunks)} chunks.\n")
    return structured_chunks, width, height, length

# Convert block data to Lua format
def convert_to_lua(structured_chunks, width, height, length):
    print("📝 Converting to Lua format...")
    lua_files = []
    file_index = 1
    chunk_list = list(structured_chunks.values())

    while chunk_list:
        chunk_set = []
        block_count = 0

        while chunk_list and block_count + len(chunk_list[0]) <= MAX_BLOCKS_PER_FILE:
            chunk_set.extend(chunk_list.pop(0))
            block_count += len(chunk_set)

        lua_table = f"local schematic = {{\n    width = {width},\n    height = {height},\n    length = {length},\n    blocks = {{\n"
        lua_table += ",\n".join(
            f"        {{x={b['x']}, y={b['y']}, z={b['z']}, block='{b['block']}'}}"
            for b in chunk_set
        )
        lua_table += "\n    }\n}\n\n"

        lua_table += """function build()
    for i, block in ipairs(schematic.blocks) do
        turtle.goTo(block.x, block.y, block.z)
        turtle.place(block.block)
    end
end

build()
"""

        filename = f"schematic_{file_index}.lua"
        lua_files.append((filename, lua_table))
        file_index += 1

    print(f"✅ Lua conversion complete. {file_index - 1} files created.\n")
    return lua_files

# Save Lua files
def save_lua_files(lua_files):
    for filename, lua_code in lua_files:
        with open(filename, 'w') as file:
            file.write(lua_code)
        print(f"✅ Saved {filename}")

# Main function
def main():
    schematic_file = input("Enter schematic file path: ").strip()
    structured_chunks, width, height, length = load_schematic(schematic_file)

    if structured_chunks:
        lua_files = convert_to_lua(structured_chunks, width, height, length)
        save_lua_files(lua_files)
    else:
        print("❌ No valid blocks found. Exiting.")

if __name__ == "__main__":
    main()
