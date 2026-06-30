package game

import "core:fmt"
import rl "vendor:raylib"

movement_system :: proc(world : ^World, delta_time : f32){
    for i in 0..<world.entity_count{
        if MOVEMENT_QUERY <= world.masks[i]{
            world.positions[i] += world.velocities[i] * delta_time 
        }
    }
}

render_system :: proc(world: ^World, assets: ^AssetStore){
    for i in 0..<world.entity_count{
        if RENDER_QUERY <= world.masks[i]{
            texture := assets.textures[int(world.texture_ids[i])].texture

            source := rl.Rectangle{
                0,
                0,
                f32(texture.width),
                f32(texture.height),
            }


            rl.DrawTexturePro(
                texture,
                source,
                get_entity_rect(world, i),
                {0, 0},
                0,
                rl.WHITE,
            )

        }
    }
}


collision_system :: proc (world: ^World){

    right := world.play_area.x + world.play_area.width
    bottom := world.play_area.y + world.play_area.height

    for i in 0..<world.entity_count{

        if COLLISION_QUERY <= world.masks[i]{

            if world.positions[i].x < world.play_area.x {

                world.positions[i].x = world.play_area.x
                world.velocities[i].x *= -1

            }   else if world.positions[i].x + world.bounds[i].x > right {

                world.positions[i].x = right - world.bounds[i].x
                world.velocities[i].x *= -1

            }

            if world.positions[i].y < world.play_area.y {

                world.positions[i].y = world.play_area.y
                world.velocities[i].y *= -1

            } else if world.positions[i].y + world.bounds[i].y > bottom {

                world.positions[i].y = bottom - world.bounds[i].y
                world.velocities[i].y *= -1

            }
        }


    }
}


get_entity_rect :: proc(world : ^World, index : int) -> rl.Rectangle {
    return {
        world.positions[index].x,
        world.positions[index].y,
        world.bounds[index].x,
        world.bounds[index].y,
    }
}



load_texture_slot :: proc(name: cstring, fallback: rl.Texture2D) -> TextureSlot {

    path := fmt.ctprintf("textures/%s", name)

    if rl.FileExists(path) {
        fmt.println("Loaded:", path)
        return {rl.LoadTexture(path), true}
    }
    
    fmt.println("Missing texture:", path)
    return {fallback, false}
}


load_assets :: proc() -> AssetStore {
    assets := AssetStore{}

    missing := rl.LoadTexture("textures/no.jpg")
    
    assets.textures[int(TextureID.Missing)] = {missing, true}
    assets.textures[int(TextureID.Player)] = load_texture_slot("player.png", missing)
    assets.textures[int(TextureID.Enemy)] = load_texture_slot("enemy.png", missing)

    return assets
}


unload_assets :: proc(assets: ^AssetStore) {
    for i in 0..<TEXTURE_COUNT {
        if assets.textures[i].should_unload {
            rl.UnloadTexture(assets.textures[i].texture)
        }
    }
}




