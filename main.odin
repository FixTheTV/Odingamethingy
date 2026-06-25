package game

import "core:fmt"
import random "core:math/rand"
import la "core:math/linalg"
import rl "vendor:raylib"

WINDOW_WIDTH  :: f32(1280)
WINDOW_HEIGHT :: f32(720)

BOX_WIDTH  :: f32(600)
BOX_HEIGHT :: f32(600)

PLAYER_WIDTH  :: f32(60)
PLAYER_HEIGHT :: f32(60)

Player :: struct {
    texture: rl.Texture2D,
    pos: rl.Vector2,
    direction: rl.Vector2,
    speed: f32,
}

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

player_rect :: proc(player: Player) -> rl.Rectangle {
    return {
        player.pos.x,
        player.pos.y,
        PLAYER_WIDTH,
        PLAYER_HEIGHT,
    }
}

create_player :: proc(box: rl.Rectangle) -> Player {
    player := Player{}

    player.texture = load_texture("player.png")
    player.speed = 250

    player.direction.x = random.float32_range(-1,1)
    player.direction.y = random.float32_range(-1,1)

    player.pos = {
        box.x + box.width * 0.5 - PLAYER_WIDTH * 0.5,
        box.y + box.height * 0.5 - PLAYER_HEIGHT * 0.5,
    }

    return player
}

update_player :: proc(player: ^Player, dt: f32) {
    player.pos += player.direction * player.speed * dt
}

handle_player_collision :: proc(player: ^Player, box: rl.Rectangle) {
    right := box.x + box.width
    bottom := box.y + box.height

    if player.pos.x < box.x {
        player.pos.x = box.x
        player.direction.x *= -1
    } else if player.pos.x + PLAYER_WIDTH > right {
        player.pos.x = right - PLAYER_WIDTH
        player.direction.x *= -1
    }

    if player.pos.y < box.y {
        player.pos.y = box.y
        player.direction.y *= -1
    } else if player.pos.y + PLAYER_HEIGHT > bottom {
        player.pos.y = bottom - PLAYER_HEIGHT
        player.direction.y *= -1
    }
}

draw_player :: proc(player: Player) {
    source := rl.Rectangle{
        0,
        0,
        f32(player.texture.width),
        f32(player.texture.height),
    }

    rl.DrawTexturePro(
        player.texture,
        source,
        player_rect(player),
        {0, 0},
        0,
        rl.WHITE,
    )
}

draw_debug :: proc(player: Player, box: rl.Rectangle) {
    rect := player_rect(player)

    rl.DrawRectangle(
        i32(rect.x),
        i32(rect.y),
        i32(rect.width),
        i32(rect.height),
        {0, 255, 0, 100},
    )
}

main :: proc() {
    rl.InitWindow(
        i32(WINDOW_WIDTH),
        i32(WINDOW_HEIGHT),
        "Son",
    )
    defer rl.CloseWindow()

    box := rl.Rectangle{
        (WINDOW_WIDTH - BOX_WIDTH) * 0.5,
        (WINDOW_HEIGHT - BOX_HEIGHT) * 0.5,
        BOX_WIDTH,
        BOX_HEIGHT,
    }

    player := create_player(box)
    defer rl.UnloadTexture(player.texture)

    for !rl.WindowShouldClose() {

        dt := rl.GetFrameTime()

        update_player(&player, dt)
        handle_player_collision(&player, box)

        rl.BeginDrawing()
        rl.ClearBackground({160, 200, 255, 255})

        rl.DrawRectangleLinesEx(box, 5, rl.BLACK)

        rl.DrawFPS(0,0)

        draw_player(player)

        rl.EndDrawing()
    }
}