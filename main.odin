package game

import "core:fmt"
import random "core:math/rand"
import la "core:math/linalg"
import rl "vendor:raylib"

Entity :: distinct u32

WINDOW_WIDTH  :: f32(1280)
WINDOW_HEIGHT :: f32(720)

BOX_WIDTH  :: f32(600)
BOX_HEIGHT :: f32(600)

ComponentFlag :: enum {
    Position,
    Velocity,
    Sprite,
    Bound,
}

ComponentMask :: bit_set[ComponentFlag; u32]

MOVEMENT_MASK :: ComponentMask{.Position, .Velocity}
COLLISION_MASK :: ComponentMask{.Position, .Bound}
RENDER_MASK :: ComponentMask{.Position, .Sprite}

BattleField :: struct {

    entityCount : int,
    entities : [100]Entity,
    
    positions : #soa [100]rl.Vector2,
    velocities : #soa [100]rl.Vector2,
    masks : [100]ComponentMask, 
    textures: [100]rl.Texture2D,

    entityBound : [100]rl.Vector2,

    box : rl.Rectangle,

}


movementSystem :: proc(field : ^BattleField, dt : f32){
    for i in 0..<field.entityCount{
        if MOVEMENT_MASK <= field.masks[i]{
            field.positions[i] += field.velocities[i] * dt 
        }
    }
}


renderSystem :: proc(field: ^BattleField){
    for i in 0..<field.entityCount{
        if RENDER_MASK <= field.masks[i]{

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

        if COLLISION_MASK <= field.masks[i]{

            if field.positions[i].x < field.box.x {

                field.positions[i].x = field.box.x
                field.velocities[i].x *= -1

            }   else if field.positions[i].x + field.entityBound[i].x > right {

                field.positions[i].x = right - field.entityBound[i].x
                field.velocities[i].x *= -1

            }

            if field.positions[i].y < field.box.y {

                field.positions[i].y = field.box.y
                field.velocities[i].y *= -1

            } else if field.positions[i].y + field.entityBound[i].y > bottom {

                field.positions[i].y = bottom - field.entityBound[i].y
                field.velocities[i].y *= -1

            }
        }


    }
}


getEntityRect :: proc(field : ^BattleField, index : int) -> rl.Rectangle {
    return {
        field.positions[index].x,
        field.positions[index].y,
        field.entityBound[index].x,
        field.entityBound[index].y,
    }
}

loadTexture :: proc(name: cstring) -> rl.Texture2D {
    fallback := rl.LoadTexture("textures/no.jpg")

    path := fmt.ctprintf("textures/%s", name)

    if rl.FileExists(path) {
        fmt.println("Loaded:", name)
        return rl.LoadTexture(path)
    }

    fmt.println("Missing texture:", path)
    return fallback
}

createEntity :: proc (field : ^BattleField) -> int{
    index := field.entityCount
    field.entities[index] = Entity(index)
    field.entityCount += 1
    return index
}

addPosition :: proc (field : ^BattleField, entity : int, pos : rl.Vector2){
    field.positions[entity] = pos

    field.masks[entity] += ComponentMask{.Position}
}

addVelocity :: proc (field: ^BattleField, entity : int, vel : rl.Vector2){
    field.velocities[entity] = vel

    field.masks[entity] += ComponentMask{.Velocity}
}

addBound :: proc (field: ^BattleField, entity : int, bound: rl.Vector2){
    field.entityBound[entity].x = bound.x
    field.entityBound[entity].y = bound.y

    field.masks[entity] += ComponentMask{.Bound}
}

addSprite :: proc (field: ^BattleField, entity: int, sprite : rl.Texture2D){
    field.textures[entity] = sprite

    field.masks[entity] += ComponentMask{.Sprite}
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


    rl.InitWindow(
        i32(WINDOW_WIDTH),
        i32(WINDOW_HEIGHT),
        "Son",
    )

    player := createEntity(&gameMap)

    addBound(&gameMap,player,{60,60})
    addPosition(&gameMap, player, {gameMap.box.x + gameMap.box.width * 0.5 - gameMap.entityBound[player].x * 0.5, gameMap.box.y + gameMap.box.height * 0.5 - gameMap.entityBound[player].y * 0.5})
    addSprite(&gameMap,player,loadTexture(fmt.caprintf("%i.png", player)))
    defer rl.UnloadTexture(gameMap.textures[player])
    addVelocity(&gameMap,player,{random.float32_range(-1,1), random.float32_range(-1,1)}*250)


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
