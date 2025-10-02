-- SHAW Simulator
-- this thing sucks so far lol

math.randomseed(os.time())

Player = {}
Player.x = 390
Player.y = 370
Player.speed = 5
Player.w = 16
Player.h = 16

Attack = {}
Attack.__index = Attack
Attack.speed = 17
Attack.interval = 1.15

attack_order = {}
asset_order = {}

bw = 752 -- right side of Attack box
bh = 458 -- bottom
obw = 48 -- left
obh = 308 -- top

hit = false
death_delay = 1
game_over = false

function love.load()
    love.window.setTitle("GIT GUD!")

    Player.sprite = love.graphics.newImage("sprites/SOUL.png")
    Death = love.graphics.newImage("sprites/SOUL-dead.png")
    Background = love.graphics.newImage("sprites/template.png")
    Needle = love.graphics.newImage("sprites/needle.png")
    Bugs = love.graphics.newImage("sprites/bugs.png")

    survival_timer = 0
    respawn_timer = Attack.interval

    -- Attack:new(50, 325, 1, love.graphics.newImage("sprites/needle.png"), 3)
end

function table.find(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function Attack:new(x, y, vector, sprite, scale) -- vector needs to be 1 to face right or -1 to face left
    local instance  = setmetatable({}, Attack)
    instance.x = x
    instance.y = y
    instance.vector = vector
    instance.sprite = sprite
    instance.w = sprite:getWidth()
    instance.h = sprite:getHeight()
    instance.scale = scale
    table.insert(attack_order, instance)
end

function generate_attack(num, duplicates) -- enter how many
    local sprite
    local randint
    local n = num
    local dupes = duplicates or {}
    w,_ = love.graphics.getDimensions()

    randint = math.random(10)
    if randint == 1 then
        sprite = Bugs
    else
        sprite = Needle
    end

    local i = true
    while i do
        randint = math.random(6)
        if table.find(dupes, randint) then 
            goto continue
        end
        table.insert(dupes, randint)
        i = false
        ::continue::
    end

    if randint == 1 then
        Attack:new(0 - 50, 322, 1, sprite, 3)
    elseif randint == 2 then
        Attack:new(0 - 50, 370, 1, sprite, 3)
    elseif randint == 3 then
        Attack:new(0 - 50, 417, 1, sprite, 3)
    elseif randint == 4 then
        Attack:new(w + 50, 417, -1, sprite, 3)
    elseif randint == 5 then
        Attack:new(w + 50, 370, -1, sprite, 3)
    else
        Attack:new(w + 50, 322, -1, sprite, 3)
    end

    n = n - 1
    if n > 0 then
        generate_attack(n, dupes)
    end
end

function attack_updates()
    if respawn_timer < 0 then
        generate_attack(2)
        respawn_timer = Attack.interval
    end

    for i, attack in ipairs(attack_order) do
        if attack.vector == 1 and attack.x >= obw then
            attack.x = attack.x + (attack.vector * attack.speed)
        elseif attack.vector == 1 and attack.x >= bw then
            table.remove(attack_order, i)
        elseif attack.vector == -1 and attack.x <= bw then
            attack.x = attack.x + (attack.vector * attack.speed)
        elseif attack.vector == -1 and attack.x <= obw then
            table.remove(attack_order, i)
        else
            attack.x = attack.x + (attack.vector * (attack.speed - 13))
        end
    end
end

function check_collisions()
    local hb1 = {
        x = Player.x,
        y = Player.y,
        w = Player.w,
        h = Player.h
    }
    local hb2 = {}

    for _, attack in ipairs(attack_order) do
        hb2 = {
            x = attack.x + 2,
            y = attack.y + 2,
            w = attack.sprite:getWidth() * attack.scale - 4,
            h = attack.sprite:getHeight() * attack.scale - 4
        }

        if (attack.vector == 1 and
            hb1.x < hb2.x + hb2.w and
            hb1.x + hb1.w > hb2.x and
            hb1.y < hb2.y + hb2.h and
            hb1.h + hb1.y > hb2.y) or
            (attack.vector == -1 and
            hb1.x < hb2.x and
            hb1.x + hb1.w > hb2.x - hb2.w and
            hb1.y < hb2.y + hb2.h and
            hb1.h + hb1.y > hb2.y)
        then
            Player.sprite = Death
            hit = true
            break
        end
    end
end

function love.update(dt)
    -- w,h = love.graphics.getDimensions()
    if hit then
        death_delay = death_delay - dt
        if death_delay <= 0 then game_over = true end
        goto skip
    end

    local speed
    survival_timer = survival_timer + dt
    respawn_timer = respawn_timer - dt

    if love.keyboard.isDown("lshift") then
        speed = Player.speed * 2
    elseif love.keyboard.isDown("lctrl") then
        speed = 1
    else
        speed = Player.speed 
    end

    if love.keyboard.isDown("right") then 
        if ((Player.x + speed) + Player.w) <= bw then
            Player.x = Player.x + speed
        else
            Player.x = bw - Player.w
        end
    end
    if love.keyboard.isDown("left") then 
        if (Player.x - speed) >= obw then
            Player.x = Player.x - speed
        else
            Player.x = obw
        end
    end
    if love.keyboard.isDown("up") then 
        if (Player.y - speed) >= obh then
            Player.y = Player.y - speed
        else 
            Player.y = obh
        end
    end
    if love.keyboard.isDown("down") then 
        if ((Player.y + speed) + Player.h) <= bh then
            Player.y = Player.y + speed
        else 
            Player.y = bh - Player.h
        end
    end

    check_collisions()

    attack_updates()

    check_collisions()

    ::skip::
end

function game_window()
    love.graphics.draw(Background, 0, 0, 0, 0.4175, 0.4)
    love.graphics.draw(Player.sprite, Player.x, Player.y, 0, 0.03, 0.03)
    -- love.graphics.print(tostring(Player.x) .. ", " .. tostring(Player.y), 500, 310)
    for _, attack in ipairs(attack_order) do
        love.graphics.draw(attack.sprite, attack.x, attack.y, 0, attack.scale * attack.vector, attack.scale)
    end
end

function game_over_window()
    love.graphics.print("G A M E  O V E R", 50, 50, 0, 4, 4)
    love.graphics.print(tostring(math.floor(survival_timer / 3600 + 0.5)) .. ":" ..
                        tostring(math.floor((survival_timer % 3600) / 60 + 0.5)) .. ":" ..
                        tostring(math.floor((survival_timer % 60) / 1 + 0.5)), 50, 120, 0, 2, 2)
end

function love.draw()
    if game_over then
        game_over_window()
    else
        game_window()
    end
end