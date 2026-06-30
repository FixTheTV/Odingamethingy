package game

import rl "vendor:raylib"

MAX_ENTITIES :: 100
TEXTURE_COUNT :: 3

TextureID :: enum {
    Missing,
    Player,
    Enemy,
}

TextureSlot :: struct {
    texture : rl.Texture2D,
    should_unload : bool,
}

AssetStore :: struct {
    textures : [TEXTURE_COUNT]TextureSlot,
}

ComponentFlag :: enum {
    Position,
    Velocity,
    Sprite,
    Bounds,
}
ComponentMask :: bit_set[ComponentFlag; u32]

MOVEMENT_QUERY :: ComponentMask{
	.Position, 
	.Velocity
}

COLLISION_QUERY :: ComponentMask{
	.Position, 
	.Bounds
}

RENDER_QUERY :: ComponentMask{
	.Position, 
	.Sprite
}

World :: struct {

    entity_count : int,
    entities : [MAX_ENTITIES]Entity,
    
    positions : #soa [MAX_ENTITIES]rl.Vector2,
    velocities : #soa [MAX_ENTITIES]rl.Vector2,
    masks : [MAX_ENTITIES]ComponentMask, 
    texture_ids : [MAX_ENTITIES]TextureID,

    bounds : [MAX_ENTITIES]rl.Vector2,

    play_area : rl.Rectangle,

}
