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
	love.graphics.push()
	love.graphics.applyTransform(self:get_transformation())
	self.text:draw()
	love.graphics.pop()
end

function DialogText:load()
	self.text = load_object(self.text, true, "Text")
	if (not self.names) then
		self.names = {
			{"First", engine.Colors.WHITE}, 
			{"Second", engine.Colors.BLUE}
		}	
	end
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

function DialogText:get_name(n)
	return self.names[n][1] .. " -- "
end

function DialogText:get_color(n)
	return self.names[n][2]
end

function DialogText:update_text()
	local x, y = self.dialog:get_text()
	local z = self.dialog:get_answers()
	local ans = ""
	for i = 1, #z do
		if (i == 1) then
			ans = i .. "." .. z[i]
		else
			ans = ans .. "\n" .. i .. "." .. z[i]
		end
	end

	if (x and y) then
		self.text:set_text({self:get_color(1), self:get_name(1) .. x})
		_, width = self.text:get_dimensions()
		self.text:add_text({self:get_color(2), self:get_name(2) .. y})
	elseif (x) then
		self.text:set_text({self:get_color(1), self:get_name(1) .. x})
	else
		self.text:set_text({self:get_color(2), self:get_name(2) .. y})
	end
	self.text:add_text({engine.Colors.WHITE, ans})
end

function DialogText:get_dimensions()
	return self.text:get_dimensions()
end