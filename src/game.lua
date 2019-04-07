require("src/scene")

-- Создает новый объект игры
function engine.Game:new()
	local game = self:__new {
		name = nil, -- Имя игры
		version = nil, -- Версия игры
		scenes = {}, -- Список сцен игры
		types = {}, -- Список типов игровых объектов
	}
	return game
end

-- name::string - Имя сцены - строка
-- scene::Scene - Объект сцены
-- Добавляет сцену scene с именем name к игре
function engine.Game:add_scene(name, scene)
	if (scene) then
		self.scenes[name] = scene
	else
		local scene = engine.Scene:new()
		scene:load(name)
		self.scenes[name] = scene
	end
end

-- name::string имя сцены
-- Устанавливает сцену с именем name как текущую
function engine.Game:set_scene(name)
	if (type(name) == "string") then
		self.scene = self.scenes[name]
	else
		self.scene = name
	end
end

-- file::string - имя файла
-- загружает файл в движок, полезно при добавлении новых типов
function engine.Game:load_file(file)
	local chunk = love.filesystem.load(file .. ".lua")
	chunk()
end

-- name::string - имя шрифта хранящегося в папке fonts
-- size::number - размер шрифта
-- Устанавливает шрифт по умолчанию в игре
function engine.Game:set_main_font(name, size)
	self.main_font_path = "fonts/" .. name .. ".ttf"
	local font = love.graphics.newFont(self.main_font_path, size) --Metroplex Shadow.ttf
    love.graphics.setFont(font)
end

-- type_name::string - Имя нового типа объекта
-- parent::Class - родитель типа объекта (то есть новый тип наследуется от данного)
-- Добавляет новый тип type_name с родителем parent, если parent == nil, то наследуется
-- от Object, также добавляет глобальную переменную с именем типа
function engine.Game:new_type(type_name, parent)
	local class = Class:new(parent)
	class.__name = type_name
	_G[type_name] = class
	self.types[type_name] = class
end

-- type_name::string - Имя нового типа объекта
-- parent::Class - родитель типа объекта (то есть новый тип наследуется от данного)
-- Добавляет новый тип type_name с родителем parent, если parent == nil, то наследуется
-- от Object, также добавляет глобальную переменную с именем типа
function newtype(type_name, parent)
	if (not parent) then
		game:new_type(type_name, engine.Object)
	else
		game:new_type(type_name, parent)
	end
end

-- Выводит текущую сцену на экран
function engine.Game:draw()
	self.scene:draw()
end

-- dt::number - время прошедшее с последнего обновления в секундах
-- обновляет текущую сцену
function engine.Game:update(dt)
	self.scene:update(dt)
end

-- Заверщает работу движка
function engine.Game:quit()
	love.event.quit()
end

-- Глобальная переменная хранящая основной объект игры
game = engine.Game:new()

-- О том что ниже смотри документацию Love2D 

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