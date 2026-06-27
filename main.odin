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

Entity :: distinct u32


BattleField :: struct {
    isMoveable : [100]bool,
    isDrawable: [100]bool,

    entityCount : int,
    speeds : [100]f32,
    entities : [100]Entity,
    positions : #soa [100]rl.Vector2,
    directions : #soa [100]rl.Vector2,
    textures : #soa [100]rl.Texture2D,

    box : rl.Rectangle

}


movementSystem :: proc(field : ^BattleField, dt : f32){
    for i in 0..<field.entityCount{
        if field.isMoveable[i]{
            field.positions[i] += field.directions[i] * field.speeds[i] * dt 
        }
    }
}


renderSystem :: proc(field: ^BattleField){
    for i in 0..<field.entityCount{
        if field.isDrawable[i]{

            source := rl.Rectangle{
                0,
                0,
                f32(field.textures[i].width),
                f32(field.textures[i].height),
            }


            rl.DrawTexturePro(
                field.textures[i],
                source,
                getEntityRect(field, i),
                {0, 0},
                0,
                rl.WHITE,
            )

        }
    }
}


collisionSystem :: proc (field: ^BattleField){

    right := field.box.x + field.box.width
    bottom := field.box.y + field.box.height

    for i in 0..<field.entityCount{

        if field.positions[i].x < field.box.x {

            field.positions[i].x = field.box.x
            field.directions[i].x *= -1

        } else if field.positions[i].x + PLAYER_WIDTH > right {

            field.positions[i].x = right - PLAYER_WIDTH
            field.directions[i].x *= -1

        }

        if field.positions[i].y < field.box.y {

            field.positions[i].y = field.box.y
            field.directions[i].y *= -1

        } else if field.positions[i].y + PLAYER_HEIGHT > bottom {

            field.positions[i].y = bottom - PLAYER_HEIGHT
            field.directions[i].y *= -1

        }
    }
}

getEntityRect :: proc(field : ^BattleField, index : int) -> rl.Rectangle {
    return {
        field.positions[index].x,
        field.positions[index].y,
        PLAYER_WIDTH,
        PLAYER_HEIGHT,
    }
}

loadTexture :: proc(name: cstring) -> rl.Texture2D {
    fallback := rl.LoadTexture("textures/no.jpg")

    path := fmt.ctprintf("textures/%s", name)

    if rl.FileExists(path) {
        fmt.println("Loaded:", name)
        return rl.LoadTexture(path)
    }

    fmt.println("Missing texture:", name)
    return fallback
}



main :: proc() {

    rl.SetConfigFlags({.VSYNC_HINT})
    rl.SetTargetFPS(60)

    gameMap := BattleField {} 

    gameMap.box = {
        (WINDOW_WIDTH - BOX_WIDTH) * 0.5,
        (WINDOW_HEIGHT - BOX_HEIGHT) * 0.5,
        BOX_WIDTH,
        BOX_HEIGHT,
    }

    entityIndex01 := gameMap.entityCount
    gameMap.entities[entityIndex01] = Entity(001)
    gameMap.positions[entityIndex01] = {gameMap.box.x + gameMap.box.width * 0.5 - PLAYER_WIDTH * 0.5, gameMap.box.y + gameMap.box.height * 0.5 - PLAYER_HEIGHT * 0.5}
    gameMap.directions[entityIndex01] = {random.float32_range(-1,1), random.float32_range(-1,1)}
    gameMap.speeds[entityIndex01] = f32(250)
    gameMap.isDrawable[entityIndex01] = true
    gameMap.isMoveable[entityIndex01] = true
    gameMap.entityCount += 1



    entityIndex02 := gameMap.entityCount
    gameMap.entities[entityIndex02] = Entity(002)
    gameMap.positions[entityIndex02] = {gameMap.positions[entityIndex01].x, gameMap.positions[entityIndex01].y}
    gameMap.directions[entityIndex02] = {0,0}
    gameMap.speeds[entityIndex02] = f32(0)
    gameMap.isDrawable[entityIndex02] = true
    gameMap.isMoveable[entityIndex02] = false
    gameMap.entityCount += 1


    rl.InitWindow(
        i32(WINDOW_WIDTH),
        i32(WINDOW_HEIGHT),
        "Son",
    )

    gameMap.textures[entityIndex01] = loadTexture("player.png")
    defer rl.UnloadTexture(gameMap.textures[entityIndex01])
    gameMap.textures[entityIndex02] = loadTexture("enemy.png")
    defer rl.UnloadTexture(gameMap.textures[entityIndex02])

    defer rl.CloseWindow()


    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()

        movementSystem(&gameMap,dt)
        collisionSystem(&gameMap)

        rl.BeginDrawing()

        rl.ClearBackground({160, 200, 255, 255})
        rl.DrawRectangleLinesEx(gameMap.box, 5, rl.BLACK)

        renderSystem(&gameMap)

        rl.DrawFPS(0,0)
        rl.EndDrawing()


    }
}