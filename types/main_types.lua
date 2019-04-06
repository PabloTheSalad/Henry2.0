
newtype "Text"

function Text:draw()
	if (type(self.text) == "string") then
	    love.graphics.print(self.text)
	else
	    transformation = love.math.newTransform(self.coord.x, self.coord.y, self.rotation, self.scaling.x, self.scaling.y)
	    love.graphics.draw(self.text, transformation)
	end
end

function Text:load()
    local texti = ""
    if (self.width) then
       	texti = split_text(self.text, self.width)
    else
    	texti = self.text
    end
    local color = {0, 0, 0}
    if (self.color) then
        color = self.color
    end
    if (self.font) then
        self.text = love.graphics.newText(love.graphics.newFont("fonts/" .. self.font .. ".ttf", self.font_size), {color, texti})
    elseif (self.font_size) then
        self.text = love.graphics.newText(love.graphics.newFont(game.main_font_path, self.font_size), {color, texti})
    end
end

function Text:set_text(clr, text)
    if (type(self.text) == "string") then
        self.text = {сlr, split_text(text, self.width)}
    else
    	local text = {сlr, split_text(text, self.width)}
    	text[1] = clr
        self.text:set(text)
    end
end

function Text:raw_set(t)
    if (type(self.text) ~= "string") then
        -- print_table("1", t)
        self.text:set(t)
    else
        self.text = t
    end
end

function Text:get_dimensions(x, y)
    return self.text:getDimensions()
end

newtype "Static"

function Static:draw()
	local transformation = self:get_transformation()
	love.graphics.draw(self.image, transformation)
end

function Static:load()
	if (type(self.image) == "string") then
		self.image = love.graphics.newImage(self.image)
	end
end

function Static:get_dimensions(x, y)
    return self.image:getDimensions()
end

newtype "Animated"

function Animated:draw()
	local tr = love.math.newTransform(self.coord.x, self.coord.y, self.rotation, self.scaling.x, self.scaling.y)
    love.graphics.draw(self.animation.current_animation.sprites, self.animation.current_quad, tr)
end

function Animated:load()
	for name, anim in pairs(self.animations) do
        self:add_animation(name, anim.file, anim.size.x, anim.size.y, anim.range.from, anim.range.to, anim.duration)
   	end
    self.animations = nil
    self:set_animation(self.start_animation)
end

function Animated:pre_update(dt)
	self.animation.current_time = self.animation.current_time + dt
    if (self.animation.current_time >= self.animation.current_animation.duration) then
        self.animation.current_frame = self.animation.current_frame + 1
        if (self.animation.current_frame > self.animation.current_animation.range.to) then
            self.animation.current_frame = self.animation.current_animation.range.from
        end
        self:update_animation_frame()
        self.animation.current_time = self.animation.current_time - self.animation.current_animation.duration
    end
end

function Animated:add_animation(name, filename, sx, sy, rfrom, rto, dt)
    if (not self.animation) then
        self.animation = {
            current_time = 0,
            current_frame = 0,
            current_quad = nil,
            current_animation = nil,
            current_animation_name = nil,
            animations = {}
        }
    end
	self.animation.animations[name] = {
   		sprites = love.graphics.newImage(filename),
   		size = { x = sx, y = sy},
   		range = { from = rfrom, to = rto },
   		duration = dt
	}
end

function Animated:set_animation(name)
	self.animation.current_animation_name = name
	self.animation.current_animation = self.animation.animations[name]
	self.animation.current_frame = self.animation.current_animation.range.from
	self.animation.current_time = 0
	self:update_animation_frame()
end

function Animated:update_animation_frame()
	local i, j = self.animation.current_animation.sprites:getDimensions()
	i, j = i / self.animation.current_animation.size.x, j / self.animation.current_animation.size.y
	i, j = math.floor(i), math.floor(j)
	y, x = self.animation.current_frame % j, math.floor(self.animation.current_frame / j)
	local size = self.animation.current_animation.size
	self.animation.current_quad = love.graphics.newQuad(x*size.x, y*size.y, size.x, size.y, 
	self.animation.current_animation.sprites:getDimensions())	
end

function Animated:get_dimensions(x, y)
    local _, _, demx, demy = self.animation.current_quad:getViewport()
    return demx, demy
end