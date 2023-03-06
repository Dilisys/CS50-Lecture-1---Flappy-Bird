push = require 'push'
Class = require 'class'

require 'Bird'
require 'Pipe'
require 'PipePair'

require 'StateMachine'
require 'states/BaseState'
require 'states/PlayState'
require 'states/TitleScreenState'
require 'states/ScoreState'
require 'states/CountdownState'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background = love.graphics.newImage('background.png')
local backgroundscroll = 0

local ground = love.graphics.newImage('ground.png')
local groundscroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 413
local GROUND_LOOPING_POINT = 514

local scrolling = true

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')

	love.window.setTitle('Legally Distinct Flappy Bird')

	--instantiate new fonts
	smallFont = love.graphics.newFont('fonts/font.ttf', 8)
	mediumFont = love.graphics.newFont('fonts/flappy.ttf', 14)
	flappyFont = love.graphics.newFont('fonts/flappy.ttf', 28)
	scoreFont = love.graphics.newFont('fonts/flappy.ttf', 56)
	love.graphics.setFont(flappyFont)

	--initialize the sounds table
	sounds = {
		['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
		['explosion'] = love.audio.newSource('sounds/explosion.wav', 'static'),
		['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
		['score'] = love.audio.newSource('sounds/score.wav', 'static'),

		['music'] = love.audio.newSource('sounds/marios_way.mp3', 'static')
	}

	sounds['music']:setLooping(true)
	sounds['music']:play()

	math.randomseed(os.time())

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,
		{vync = true,
		fullscreen = false,
		resizable = true
	})

	--instantiate state machine table here
	gStateMachine = StateMachine {
		['title'] = function() return TitleScreenState() end,
		['play'] = function() return PlayState() end,
		['score'] = function() return ScoreState() end,
		['countdown'] = function() return CountdownState() end,
	}

	gStateMachine:change('title')

	love.mouse.buttonsPressed = {}
	love.keyboard.keysPressed = {}
end

function love.resize(w, h)
	push:resize(w, h)
end

function love.mousepressed(x, y, button)
	love.mouse.buttonsPressed[button] = true
end

function love.keypressed(key)
	love.keyboard.keysPressed[key] = true

	if key == 'escape' then
		love.event.quit()
	end
end

function love.keyboard.wasPressed(key)
	if love.keyboard.keysPressed[key] then
		return true
	else
		return false
	end
end

function love.mouse.wasPressed(button)
	if love.mouse.buttonsPressed[button] then
		return true
	else
		return false
	end
end

function love.update(dt)

	--dt = math.min(dt, 1/60)

	backgroundscroll = (backgroundscroll + BACKGROUND_SCROLL_SPEED * dt)
		% BACKGROUND_LOOPING_POINT

	groundscroll = (groundscroll + GROUND_SCROLL_SPEED * dt)
		% GROUND_LOOPING_POINT

	gStateMachine:update(dt)

	love.mouse.buttonsPressed = {}
	love.keyboard.keysPressed = {}
end

function love.draw()
	push:start()

	love.graphics.draw(background, -backgroundscroll, 0)
	
	gStateMachine:render()

	love.graphics.draw(ground, -groundscroll, VIRTUAL_HEIGHT - 16)

	push:finish()
end