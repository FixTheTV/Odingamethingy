package game

import "core:fmt"
import rl "vendor:raylib"

load_texture :: proc(name: cstring) -> rl.Texture2D {
    fallback := rl.LoadTexture("textures/no.jpg")

    path := fmt.ctprintf("textures/%s", name)

    if rl.FileExists(path) {
        fmt.println("Loaded:", name)
        return rl.LoadTexture(path)
    }

    fmt.println("Missing texture:", name)
    return fallback
}

Player :: struct {
    texture: rl.Texture2D,
    pos: rl.Vector2,
}

main :: proc() {
    win_width  : f32 = 1280
    win_height : f32 = 720

    box_width  : f32 = 600
    box_height : f32 = 600

    chara_width  : f32 = 60
    chara_height : f32 = 60

    rl.InitWindow(i32(win_width), i32(win_height), "Son")
    defer rl.CloseWindow()

    box := rl.Rectangle{
        (win_width - box_width) * 0.5,
        (win_height - box_height) * 0.5,
        box_width,
        box_height,
    }

    player := Player{}
    player.texture = load_texture("plaer.png")

    player.pos = {
        box.x + box.width  * 0.5 - chara_width  * 0.5,
        box.y + box.height * 0.5 - chara_height * 0.5,
    }

    defer rl.UnloadTexture(player.texture)

    source := rl.Rectangle{
        0,
        0,
        f32(player.texture.width),
        f32(player.texture.height),
    }

    for !rl.WindowShouldClose() {
        dest := rl.Rectangle{
            player.pos.x,
            player.pos.y,
            chara_width,
            chara_height,	
        }

        rl.BeginDrawing()
        rl.ClearBackground({160, 200, 255, 255})

        rl.DrawTexturePro(
            player.texture,
            source,
            dest,
            {0, 0},
            0,
            rl.WHITE,
        )

        rl.DrawRectangleLinesEx(box, 5, rl.BLACK)

        rl.EndDrawing()
    }
}