-- File: Основные типы графических объектов
--[[ 
    Каждый тип графического объекта создается с помощью функции newtype
    и должен сожержать данные поля:
        draw() - отвечает за вывод объекта на экран
        load() - отвечает за обработку объекта загруженого из .scene файла
        get_dimensions() - возвращает высоту и ширину объекта

    Необязательные поля:
        pre_update(dt) - функция вызывается перед вызовом функции update(dt)

]]

-- Тип выводимого на экран текста
newtype {
    name = "Text",
    fields = {
        text = "string",
    }
}
--[[
    -- Пример объекта класса Text в .scene файле
    text = { Text, -- Класс объекта
        text = "Text", -- Текст который необходимо вывести (обязательно)
        width = 30, -- Максимальная ширина текста
        font = "arial", -- Название шрифта из папки Fonts
        font_size = 30, -- Размер шрифта
        color = {200, 123, 140, 255} -- Цвет текста
    }
]]

function Text:draw()
	transformation = love.math.newTransform(self.coord.x, self.coord.y, self.rotation, self.scaling.x, self.scaling.y)
    love.graphics.draw(self.text, transformation)
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
    self.raw_text = {color, texti}
    if (self.font) then
        self.text = love.graphics.newText(love.graphics.newFont("fonts/" .. self.font .. ".ttf", self.font_size), {color, texti})
    elseif (self.font_size) then
        self.text = love.graphics.newText(love.graphics.newFont(game.main_font_path, self.font_size), {color, texti})
    end
end

-- clr::{r, g, b, a} - цвет
-- text::string
-- Заменяет текст на text цвета clr
function Text:set_text(text, clr)
    if (type(text) ~= "table") then
        self.raw_text = {сlr, split_text(text, self.width)}
        self.raw_text[1] = clr
        self.text:set(self.raw_text)
    else
        self.raw_text = split_colored_text(text, self.width)
        self.text:set(self.raw_text)
    end
end

-- text::string
-- newline::bool
-- Добавляет к тексту text разделяя их символом новой строки
function Text:add_text(text, newline)
    if (type(text) ~= "table") then
        local text = {сlr, "\n" .. split_text(text, self.width)}
        text[1] = clr
        self:add_raw_text(text)
        self.text:add(self.raw_text)
    else
        local text = split_colored_text(text, self.width)
        text[2] = "\n" .. text[2]
        self:add_raw_text(text)
        self.text:set(self.raw_text)
    end
end

function Text:add_raw_text(text)
    for _, t in pairs(text) do
        self.raw_text[#self.raw_text + 1] = t
    end
end

-- t::love.grphics.Text
-- Устанавливает в текст значение t
function Text:raw_set(t)
    self.text:set(t)
end

function Text:get_dimensions(x, y)
    return self.text:getDimensions()
end

-- Тип для статичных изображений
newtype {
    name = "Static",
    fields = {
        image = "string"
    }
}
--[[
    -- Пример объекта класса Static в .scene файле
    background = { Static, -- Класс объекта
        image = "img/moon.jpg", -- Изображение для вывода
    }
]]

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

-- Тип для анимированных изображений
newtype {
    name = "Animated",
    fields = {
        animations = "table",
        start_animation = "string",
    }
}
--[[
    -- Пример объекта класса Animated в .scene файле
    player = { Animated, -- Класс объекта
        start_animation = "main", -- Имя начальной анимации
        animations = { -- Таблица содержащая все анимации
            main = { -- Создание новой анимации с именем main
                file = "img/genri.png", -- Файл с спрайтами для анимации
                size = { x = 64, y = 64 }, -- Размер одного спрайта
                range = { from = 0, to = 1 }, -- Интервал спрайтов
                duration = 0.2 -- Длительность анимации в секундах
            }
        }
    }
]]

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

-- name::string - имя новой анимации
-- filename::string - имя файла с спрайтами анимации
-- sx::number - ширина кадра
-- sy::number - высота кадра
-- rfrom::number, rto::number - с какого и по какой кадр идет анимация (счет с нуля)
-- dt::number - длительность анимации в секундах
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

-- name::string - имя анимации
-- Устанавливает анимацию с именем name как текущую
function Animated:set_animation(name)
	self.animation.current_animation_name = name
	self.animation.current_animation = self.animation.animations[name]
	self.animation.current_frame = self.animation.current_animation.range.from
	self.animation.current_time = 0
	self:update_animation_frame()
end

-- Обновляет кадр анимации
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

newtype "Physical"

function Physical:draw()
    if (self.image) then
        love.graphics.push()
        love.graphics.applyTransform(self:get_transformation())
        self.image:draw()
        love.graphics.pop()
    end
end

function Physical:load()
    local world
    if (not game.__load_scene.world) then
        world = love.physics.newWorld(0, 9.81*64/4)
        game.__load_scene.world = world
    else
        world = game.__load_scene.world
    end
    self.dcoord = { x = 0, y = 0 }
    if (self.image) then
        self.image = load_object(self.image)
        self.width, self.height = self.image:get_dimensions()
    end
    
    self.width, self.height = self.width * self.scaling.x, self.height * self.scaling.y
    self.last_body_coord = { x = self.coord.x + self.width/2, y = self.coord.y + self.height/2 }
    self.body = love.physics.newBody(world, self.coord.x + self.width/2, self.coord.y + self.height/2, self.ptype)
    self.shape = love.physics.newRectangleShape(self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.body:setFixedRotation(true)
end

function Physical:pre_update(dt)
    if (self.ptype == "dynamic") then
        local bcoord = {}
        bcoord.x = self.last_body_coord.x
        bcoord.y = self.last_body_coord.y
        self.last_body_coord = { x = self.body:getX(), y = self.body:getY()}
        self.coord.x = self.coord.x + (self.last_body_coord.x - bcoord.x)
        self.coord.y = self.coord.y + (self.last_body_coord.y - bcoord.y)
    end
    if (self.image and self.image.pre_update) then
        self.image:pre_update(dt)
    end
end

function Physical:get_dimensions()
    if (self.image) then
        return self.image:get_dimensions()
    else
        return self.width, self.height
    end
end

function Physical:mirror(px, py)
    if (px) then
        if (self.scaling.x > 0) then
            self:move(self.width, 0)
        else
            self:move(-self.width, 0)
        end
        self:stretch(-1, 1)
    end
    if (py) then
        if (self.scaling.y > 0) then
            self:move(0, self.height)
        else
            self:move(0, -self.height)
        end
        self:stretch(1, -1)
    end
end