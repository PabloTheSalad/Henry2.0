require("types/dialog")

newtype "Button"

function Button:draw()
	love.graphics.push()
	love.graphics.applyTransform(self:get_transformation())
	self.image:draw()
    self.text:draw()
    love.graphics.pop()
end

function Button:load()
	self.image = load_object(self.image, true, "Static")
	self.text = load_object(self.text, true, "Text")
	local iw, ih = self.image.image:getDimensions()
	local tw, th = self.text.text:getDimensions()
	self.text.coord.x = iw/2 * self.image.scaling.x - tw/2
	self.text.coord.y = ih/2 * self.image.scaling.y - th/2
	self.text.rotation = self.image.rotation
end

function Button:get_dimensions()
	return self.image:get_dimensions()
end

newtype "DialogText"

function DialogText:draw()
	self.text:draw()
end

function DialogText:load()
	self.text = load_object(self.text, true, "Text")
	self:update_text()
end

function DialogText:dialog_handler(key)
	if (key == "space") then
		self.dialog:pop()
		self:update_text()
	end
	key = tonumber(key)
	if (key) then
		if(self.dialog:find(key)) then
			self.dialog:push(key)
			self:update_text()
		end
	end
end

function DialogText:update_text()
	local x, y = self.dialog:get_text()
	local z = self.dialog:get_answers()
	local ans = ""
	for i = 1, #z do
		ans = ans .. "\n" .. i .. "." .. z[i]
	end

	if (x and y) then
		self.text:raw_set({engine.Colors.GREEN, "YOU: " .. x, engine.Colors.BLUE, "\nIT: " .. y, engine.Colors.WHITE, ans})
	elseif (x) then
		self.text:raw_set({engine.Colors.GREEN, "YOU: " .. x, engine.Colors.WHITE, ans})
	else
		self.text:raw_set({engine.Colors.BLUE, "IT: " .. y, engine.Colors.WHITE, ans})
	end
end

function DialogText:get_dimensions()
	return self.text:get_dimensions()
end