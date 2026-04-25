JANELA_LARGURA = 1280
JANELA_ALTURA = 720

LARGURA_VIRTUAL = 432
ALTURA_VIRTUAL = 243

VELOCIDADE_OBJETO = 200

push = require 'push'
Class = require 'class'
Paddle = require 'Paddle'
Ball = require 'Ball'

--Carrega a janela
function love.load()
    largeFont = love.graphics.newFont('font.ttf', 32)
    smallFont = love.graphics.newFont('font.ttf', 8)
    player1Score = 0
    player2Score = 0
    servingPlayer = 1
    jogadorganhador = 0
    cpumode = false

    sounds = {
        ['ai'] = love.audio.newSource('sounds/BANK_01_INSTR_0000_SND_0103.wav', 'static'),
        ['loja'] = love.audio.newSource('sounds/shop.mp3', 'stream'),
        ['luigi'] = love.audio.newSource('sounds/win.wav', 'static'),
        ['navi'] = love.audio.newSource('sounds/navi.wav', 'static')
    }
        
        sounds['loja']:setLooping(true)
        sounds['loja']:play()


    math.randomseed(os.time())

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(LARGURA_VIRTUAL - 15, ALTURA_VIRTUAL - 30, 5, 20)

    ball = Ball(LARGURA_VIRTUAL / 2 -2, ALTURA_VIRTUAL / 2 - 2, 4, 4)

    love.window.setTitle('Ping Pong!')

    gameState = 'start'

    love.window.setMode(JANELA_LARGURA, JANELA_ALTURA, {
        resizable = true,
        vsync = true,
        fullscreen = false
    })

    push.setupScreen(LARGURA_VIRTUAL, ALTURA_VIRTUAL, { upscale = 'normal'})
end

--Detecção de teclas
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    
    elseif key == 'backspace' then
        cpumode = not cpumode
        if gameState == 'start' then
            gameState = 'serve'
        end

    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()

            player1Score = 0
            player2Score = 0

            if jogadorganhador == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.update(dt)
    if love.keyboard.isDown('w') then 
        player1.dy = -VELOCIDADE_OBJETO

    elseif love.keyboard.isDown('s') then
        player1.dy = VELOCIDADE_OBJETO 

    else
        player1.dy = 0

    end
    
    if cpumode == true then

        if ball.y < player2.y + (player2.height / 2) then
        player2.dy = -VELOCIDADE_OBJETO

        elseif ball.y > player2.y + (player2.height) then
            player2.dy = VELOCIDADE_OBJETO
        
        else 
            player2.dy = 0
        end

    else

        if love.keyboard.isDown('up') then
            player2.dy = -VELOCIDADE_OBJETO
        
        elseif love.keyboard.isDown('down') then
            player2.dy = VELOCIDADE_OBJETO
        else 
            player2.dy = 0
        end
end

    player1:update(dt)
    player2:update(dt)

    if gameState == 'play' then
        --Detecção de colisão entre a bola e os players
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.04
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else 
                ball.dy = math.random(10, 150)
            end
        sounds['ai']:play()
        end

        if ball:collides(player2) then
            
            ball.dx = -ball.dx * 1.04
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else 
                ball.dy = math.random(10, 150)
            end
        sounds['ai']:play()
        end
        --Detecção da colisão com a borda da tela
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['navi']:play()
        end

        if ball.y >= ALTURA_VIRTUAL - 4 then
            ball.y = ALTURA_VIRTUAL - 4
            ball.dy = -ball.dy
            sounds['navi']:play()
        end
        ball:update(dt)
    end
    
    if ball.x < 0 then
        servingPlayer = 1
        player2Score = player2Score + 1
        sounds['luigi']:play()
        ball:reset()

        if player2Score == 2 then
            jogadorganhador = 2
            gameState = 'done'
            cpumode = false
        else 
            gameState = 'serve'
        end
    end

    if ball.x > LARGURA_VIRTUAL then
        servingPlayer = 2
        player1Score = player1Score + 1
        sounds['luigi']:play()
        ball:reset()

        if player1Score == 2 then 
            jogadorganhador = 1
            gameState = 'done'   
            cpumode = false     
        else
            gameState = 'serve'
        end
    end
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
end

--Placar de Pontos
function displayScore()
    love.graphics.setFont(largeFont)
    love.graphics.setFont(largeFont)
    love.graphics.print(tostring(player1Score), LARGURA_VIRTUAL / 2 - 50, ALTURA_VIRTUAL / 2 - 80)
    love.graphics.print(tostring(player2Score), LARGURA_VIRTUAL / 2 + 30, ALTURA_VIRTUAL / 2 - 80)

end

--Desenha na Tela
function love.draw()
    push.start() 
    love.graphics.clear(45/255, 50/255, 70/255, 1)
    displayScore()

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Bem-Vindo ao Pong', 0, 10, LARGURA_VIRTUAL, 'center')
        love.graphics.printf('Aperter Enter para jogar com amigos! ou', 0, 20, LARGURA_VIRTUAL, 'center')
        love.graphics.printf('Aperter Backspace para jogar com a CPU!', 0, 32, LARGURA_VIRTUAL, 'center')

    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player' .. tostring(servingPlayer) .. "'serve!", 0, 10, LARGURA_VIRTUAL, 'center')
        love.graphics.printf('Aperte Enter para jogar!', 0, 20, LARGURA_VIRTUAL, 'center')
    
    elseif gameState == 'play' then

    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(jogadorganhador) .. ' Venceu!', 0, ALTURA_VIRTUAL / 2 - 40, LARGURA_VIRTUAL, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Pressione Enter para reiniciar', 0, ALTURA_VIRTUAL / 2 + 20, LARGURA_VIRTUAL, 'center')
    end

    displayFPS()
    --Desenhando objeto e posicionando na tela
    player1:render()
    player2:render()
    ball:render()

    push.finish() 
end

function love.resize(w, h)
    push.resize(w, h)
end