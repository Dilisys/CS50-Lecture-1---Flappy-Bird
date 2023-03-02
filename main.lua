push = require 'push'
Class = require 'class'

require 'Bird'
require 'Pipe'
require 'PipePair'

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

local bird = Bird()

local pipePairs = {}

local pipeTimer = 0

local lastY = -PIPE_HEIGHT + math.random(80) + 20

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')

	love.window.setTitle('Legally Distinct Flappy Bird')

	math.randomseed(os.time())

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,
		{vync = true,
		fullscreen = false,
		resizable = true
	})

	love.keyboard.keysPressed = {}
end

function love.resize(w, h)
	push:resize(w, h)
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

function love.update(dt)
	pipeTimer = pipeTimer + dt

	if pipeTimer > 2 then

		local y = math.max(-PIPE_HEIGHT + 10,
			math.min(lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
		lastY = y 

		table.insert(pipePairs, PipePair(y))
		pipeTimer = 0
	end

	backgroundscroll = (backgroundscroll + BACKGROUND_SCROLL_SPEED * dt)
		% BACKGROUND_LOOPING_POINT

	groundscroll = (groundscroll + GROUND_SCROLL_SPEED * dt)
		% VIRTUAL_WIDTH

	bird:update(dt)

	for k, pair in pairs(pipePairs) do
		pair:update(dt)
	end

	for k, pair in pairs(pipePairs) do
		if pair.remove then
			table.remove(pipePairs, k)
		end
	end

	love.keyboard.keysPressed = {}
end

function love.draw()
	push:start()

	love.graphics.draw(background, -backgroundscroll, 0)
	
	for k, pair in pairs(pipePairs) do
		pair:render()
	end

	love.graphics.draw(ground, -groundscroll, VIRTUAL_HEIGHT - 16)

	bird:render()

	push:finish()
end