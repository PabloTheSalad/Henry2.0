require("src/scene")

function engine.Game:new()
	local game = {
		name = nil,
		version = nil,
		scenes = {},
		types = {},
	}
	self.__index = self
    return setmetatable(game, self)
end

function engine.Game:add_scene(name, scene)
	if (scene) then
		self.scenes[name] = scene
	else
		local scene = engine.Scene:new()
		scene:load(name)
		self.scenes[name] = scene
	end
end

function engine.Game:set_scene(name)
	if (type(name) == "string") then
		self.scene = self.scenes[name]
	else
		self.scene = name
	end
end

function engine.Game:load_file(file)
	local chunk = love.filesystem.load(file .. ".lua")
	chunk()
end

function engine.Game:set_main_font(name, size)
	self.main_font_path = "fonts/" .. name .. ".ttf"
	local font = love.graphics.newFont(self.main_font_path, size) --Metroplex Shadow.ttf
    love.graphics.setFont(font)
end

function engine.Game:new_type(type_name, parent)
	local class = Class:new(parent)
	class.__name = type_name
	_G[type_name] = class
	self.types[type_name] = class
end

function newtype(type_name, parent)
	if (not parent) then
		game:new_type(type_name, engine.Object)
	else
		game:new_type(type_name, parent)
	end
end

function engine.Game:draw()
	self.scene:draw()
end

function engine.Game:update(dt)
	self.scene:update(dt)
end

function engine.Game:quit()
	love.event.quit()
end

game = engine.Game:new()

function love.load()
	game:load_file("types/main_types")
	game:load()
	local name, version
	if (game.name) then
		name = game.name
	else
		game = "game"
	end
	if (game.version) then
		version = game.version
	else
		version = ""
	end
	love.window.setTitle(name .. " " .. version)
end

function love.draw()
    game:draw()
end

function love.update(dt)
    game:update(dt)
end

function love.mousepressed(x, y, button, istouch)
    game.scene:mouse_pressed_handler(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    game.scene:mouse_released_handler(x, y, button, istouch)
end

function love.keypressed(key, scancode, isrepeat)
    game.scene:key_pressed_handler(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode, isrepeat)
    game.scene:key_released_handler(key, scancode, isrepeat)
end