package game

import random "core:math/rand"
import rl "vendor:raylib"


WINDOW_WIDTH  :: f32(1280)
WINDOW_HEIGHT :: f32(720)

PLAY_AREA_WIDTH  :: f32(600)
PLAY_AREA_HEIGHT :: f32(600)

main :: proc() {

    rl.SetConfigFlags({.VSYNC_HINT})
    rl.SetTargetFPS(60)

    world := World {} 

    world.play_area = {
        (WINDOW_WIDTH - PLAY_AREA_WIDTH) * 0.5,
        (WINDOW_HEIGHT - PLAY_AREA_HEIGHT) * 0.5,
        PLAY_AREA_WIDTH,
        PLAY_AREA_HEIGHT,
    }


    rl.InitWindow(
        i32(WINDOW_WIDTH),
        i32(WINDOW_HEIGHT),
        "Son",
    )

    defer rl.CloseWindow()

    assets := load_assets()
    defer unload_assets(&assets)

    player := create_entity(&world)

    add_bounds(&world, player, {60, 60})
    add_position(&world, player, {
        world.play_area.x + world.play_area.width * 0.5 - world.bounds[player].x * 0.5,
        world.play_area.y + world.play_area.height * 0.5 - world.bounds[player].y * 0.5,
    })
    add_sprite(&world, player, .Player)
    add_velocity(&world, player, {random.float32_range(-1,1), random.float32_range(-1,1)}*250)

    enemy := create_entity(&world)

    add_bounds(&world, enemy, {60, 60})
    add_position(&world, enemy, {
        world.play_area.x + world.play_area.width * 0.5 - world.bounds[enemy].x * 0.5,
        world.play_area.y + world.play_area.height * 0.5 - world.bounds[enemy].y * 0.5,
    })
    add_sprite(&world, enemy, .Enemy)
    add_velocity(&world, enemy, {random.float32_range(-1,1), random.float32_range(-1,1)}*250)


    for !rl.WindowShouldClose() {
        delta_time := rl.GetFrameTime()

        movement_system(&world, delta_time)
        collision_system(&world)

        rl.BeginDrawing()

        rl.ClearBackground({160, 200, 255, 255})
        rl.DrawRectangleLinesEx(world.play_area, 5, rl.BLACK)

        render_system(&world, &assets)

        rl.DrawFPS(0,0)
        rl.EndDrawing()


    }
}
