package game

import "core:fmt"
import rl "vendor:raylib"
import random "core:math/rand"
import la "core:math/linalg"


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
    direction: rl.Vector2,
    speed: f32,
    collision: rl.Rectangle,
}

main :: proc() {
    win_width  : f32 = 1280
    win_height : f32 = 720

    box_width  : f32 = 600
    box_height : f32 = 600


    box := rl.Rectangle{
        (win_width - box_width) * 0.5,
        (win_height - box_height) * 0.5,
        box_width,
        box_height,
    }


    chara_width  : f32 = 60
    chara_height : f32 = 60

    rl.InitWindow(i32(win_width), i32(win_height), "Son")
    defer rl.CloseWindow()

    player := Player{}
    player.texture = load_texture("player.png")
    defer rl.UnloadTexture(player.texture)
    player.direction.x = random.float32_range(-1, 1)
    player.direction.y = random.float32_range(-1, 1)
    player.speed = 50
    player.pos = {
        box.x + box.width  * 0.5 - chara_width  * 0.5,
        box.y + box.height * 0.5 - chara_height * 0.5,
    }




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

        player.pos += la.normalize0(player.direction) * 250 * rl.GetFrameTime()

        right  := box.x + box.width
        bottom := box.y + box.height

        if player.pos.x < box.x {
            player.pos.x = box.x
            player.direction.x *= -1
        } else if player.pos.x + chara_width > right {
            player.pos.x = right - chara_width
            player.direction.x *= -1
        }

        if player.pos.y < box.y {
            player.pos.y = box.y
            player.direction.y *= -1
        } else if player.pos.y + chara_height > bottom {
            player.pos.y = bottom - chara_height
            player.direction.y *= -1
        }

        player.collision = {
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

        rl.DrawRectangle(i32(player.collision.x),i32(player.collision.y),i32(player.collision.width),i32(player.collision.height),{0,255,0,100})
        rl.DrawRectangleLinesEx(box, 5, rl.BLACK)

        rl.EndDrawing()
    }
}