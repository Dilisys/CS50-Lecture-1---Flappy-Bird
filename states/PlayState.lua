PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

function PlayState:init()
	self.bird = Bird()
	self.pipePairs = {}
	self.pipeTimer = 0

	self.score = 0

	self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:update(dt)
	self.pipeTimer = self.pipeTimer + dt

	if self.pipeTimer > 2 then

		local y = math.max(-PIPE_HEIGHT + 10,
			math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
		self.lastY = y 

		table.insert(self.pipePairs, PipePair(y))
		
		self.pipeTimer = 0
	end

	self.bird:update(dt)

	--updates the process function of all the pipePairs
	--also checks to see if the bird collides with any of the pipes, and, if so, pushes the player to the title screen
	for k, pair in pairs(self.pipePairs) do
		if not pair.scored then
			if pair.x + PIPE_WIDTH < self.bird.x then
				self.score = self.score + 1
				pair.scored = true
				sounds['score']:play()
			end
		end


		pair:update(dt)
		for l, pipe in pairs(pair.pipes) do
			if self.bird:collides(pipe) then
				sounds['explosion']:play()
				sounds['hurt']:play()

				gStateMachine:change('score', {score = self.score})
			end
		end
	end

	--removes pipes from the pipePairs table when they reach the left side of the screen
	for k, pair in pairs(self.pipePairs) do
		if pair.remove then
			table.remove(self.pipePairs, k)
		end
	end

	--game over state if the bird touches the ground
	if self.bird.y > VIRTUAL_HEIGHT - 15 then
		sounds['explosion']:play()
		sounds['hurt']:play()

		gStateMachine:change('score', {score = self.score})
	end

end

function PlayState:render()
	for k, pair in pairs(self.pipePairs) do
		pair:render()
	end

	love.graphics.setFont(flappyFont)
	love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

	self.bird:render()
end