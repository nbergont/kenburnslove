Fade = Object:extend()

function Fade:new(fade_in, duration, fade_out)
	self:reset()
	self:set(fade_in, duration, fade_out)
end

function Fade:set(fade_in, duration, fade_out)
	self.fade_in = fade_in
    self.duration = duration
    self.fade_out = fade_out
	self.total_duration = self.fade_in + self.duration + self.fade_out
end

function Fade:reset()
	self.alpha = 0
    self.elapsed = 0
end

function Fade:isFadeIn()
	return self.elapsed <= self.fade_in
end

function Fade:isFinished()
	return self.elapsed > self.total_duration
end

function Fade:isFadeOut()
	return self.elapsed >= (self.fade_in + self.duration)
end

function Fade:progress()
	return math.min(1.0, self.elapsed/self.total_duration)
end

function Fade:update(dt)
    self.elapsed = self.elapsed + dt
	
	if self:isFinished() then
		self.alpha = 0.0
	elseif self:isFadeIn() then
		self.alpha = self.elapsed/self.fade_in
	elseif self:isFadeOut() then
		self.alpha = (self.total_duration - self.elapsed)/self.fade_out
	else
		self.alpha = 1.0
	end

end
