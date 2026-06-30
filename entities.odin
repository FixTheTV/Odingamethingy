package game

import rl "vendor:raylib"


Entity :: distinct u32

create_entity :: proc (world : ^World) -> int{
    index := world.entity_count
    world.entities[index] = Entity(index)
    world.entity_count += 1
    return index
}


add_position :: proc (world : ^World, entity : int, position : rl.Vector2){
    world.positions[entity] = position

    world.masks[entity] += ComponentMask{.Position}
}


add_velocity :: proc (world: ^World, entity : int, velocity : rl.Vector2){
    world.velocities[entity] = velocity

    world.masks[entity] += ComponentMask{.Velocity}
}


add_bounds :: proc (world: ^World, entity : int, bounds: rl.Vector2){
    world.bounds[entity].x = bounds.x
    world.bounds[entity].y = bounds.y

    world.masks[entity] += ComponentMask{.Bounds}
}


add_sprite :: proc (world: ^World, entity: int, texture_id : TextureID){
    world.texture_ids[entity] = texture_id

    world.masks[entity] += ComponentMask{.Sprite}
}
