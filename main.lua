function love.load()
    --what da helly pls work

    --pixel perfect
    love.graphics.setDefaultFilter("nearest","nearest")

    --window config
    love.window.setMode(600,800,{resizable=false})
    love.window.setTitle("slime tower")
    width,height=love.graphics.getDimensions()

    --load 16x16 sprite
    tile=love.graphics.newImage("background.png")

    --make image repeat instead of stretching
    tile:setWrap("repeat","repeat")

    --create quad to match window size
    quad=love.graphics.newQuad(
        0,0,
        width,height,
        tile:getWidth(), tile:getHeight()
    )
    tscale=6

    -- physics world (gravity points downward)
    world = love.physics.newWorld(0,1200,true)

    --player config
    slime1 = love.graphics.newImage("slime1.png")
    slime2 = love.graphics.newImage("slime2.png")
    player={
        speed=400,
        scale=4,
        sprite=slime1
    }
    
    --create physics body for player
    player.body=love.physics.newBody(world,100,100,"dynamic")
    player.shape=love.physics.newRectangleShape(16*player.scale,16*player.scale)
    player.fixture=love.physics.newFixture(player.body,player.shape)
    player.fixture:setRestitution(0)--no bounce
    player.fixture:setFriction(0.5)
    player.body:setFixedRotation(true)--prevents flipping over

    --platforms config
    wall1=love.graphics.newImage("wall1.png")
    wall1_flip=love.graphics.newImage("wall1_flip.png")
    wall2=love.graphics.newImage("wall2.png")
    wall2_flip=love.graphics.newImage("wall2_flip.png")

    --list to hold multiple platforms
    platformList={}

    --platform add function
    local function addPlatform(x,y,sprite,scale)
        local p={}
        p.x=x
        p.y=y
        p.scale=scale
        p.sprite=sprite

        local w=sprite:getWidth()*p.scale
        local h=sprite:getHeight()*p.scale

        p.body = love.physics.newBody(world, x + w/2, y, "static")
        p.shape = love.physics.newRectangleShape(w, h)
        p.fixture = love.physics.newFixture(p.body, p.shape)

        table.insert(platformList, p)
    end

    --add platforms
    addPlatform(0, 200, wall1, 4)
    addPlatform(0, 450, wall2, 4)
    addPlatform(344, 600, wall1_flip, 4)
    addPlatform(408, 300, wall2_flip, 4)

    -- Create static boundary walls
    walls = {}

    --left wall
    walls.left = {}
    walls.left.body = love.physics.newBody(world, 0, height/2, "static")
    walls.left.shape = love.physics.newEdgeShape(0, -height/2, 0, height/2)
    walls.left.fixture = love.physics.newFixture(walls.left.body, walls.left.shape)

    -- Right wall
    walls.right = {}
    walls.right.body = love.physics.newBody(world, width, height/2, "static")
    walls.right.shape = love.physics.newEdgeShape(0, -height/2, 0, height/2)
    walls.right.fixture = love.physics.newFixture(walls.right.body, walls.right.shape)

    --game start state
    gamestart=false

    --main menu
    title=love.graphics.newImage("title.png")
    playbutton=love.graphics.newImage("play.png")
    starttext=love.graphics.newImage("starttext.png")
end

function love.update(dt)
    --physics
    world:update(dt)
    local vx,vy=player.body:getLinearVelocity()

    --movement
    if love.keyboard.isDown("right", "d") then
        player.body:setLinearVelocity(player.speed, vy)
        player.sprite = slime1
    elseif love.keyboard.isDown("left", "a") then
        player.body:setLinearVelocity(-player.speed, vy)
        player.sprite = slime2
    else
        player.body:setLinearVelocity(0, vy)
    end

    -- instant jump
    if love.keyboard.isDown("space", "up", "w") and math.abs(vy) < 0.1 then
        -- set vertical velocity instantly
        player.body:applyLinearImpulse(0,-2000)-- negative = up
    end

    --gamestart check
    if love.keyboard.isDown("space") then
        gamestart=true
    end
end

function love.draw()

    --draw background
    love.graphics.draw(tile,quad,0,0,0,tscale,tscale)

    --draw main menu
    love.graphics.draw(title,50,50,0,5,5)
    love.graphics.draw(playbutton,200,400,0,5,5)
    love.graphics.draw(starttext,-20,200,0,5,5)

    if gamestart==true then

        --clear screen
        love.graphics.draw(tile,quad,0,0,0,tscale,tscale)

        -- draw platforms
        for _, p in ipairs(platformList) do
            local w = p.sprite:getWidth() * p.scale
            local h = p.sprite:getHeight() * p.scale
            love.graphics.draw(p.sprite, p.body:getX() - w/2, p.body:getY() - h/2, 0, p.scale, p.scale)
        end

       -- draw player
        love.graphics.draw(player.sprite,
            player.body:getX() - (16 * player.scale) / 2,
            player.body:getY() - (16 * player.scale) / 2,
            0, player.scale, player.scale)
    end
end
