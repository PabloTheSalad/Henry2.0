require("src/object")

function engine.Scene:new()
    local scene = self:__new {
        objects = {},
        layers = {
            main = {}
        },
        handlers = {
            mouse = {},
            mouse_pressed = {},
            mouse_released = {},
            key_pressed = {},
            key_released = {}
        }
    }
    return scene
end

local spec_func = function(table) --Специальная функция с замыкание для обработки таблиц с нажатиями кнопок
    local func = function(self, key, scancode, isrepeat)
        for name, func in pairs(table) do
            if (name == key or name == "always" or (name == "enter" and key == "return")) then
                func(self, key, scancode, isrepeat)
            end
        end
    end
    return func
end

function engine.Scene:load_obj(name, load_obj)
    local obj = load_object(load_obj)

    if (obj.handlers) then
        if (obj.handlers.key_pressed and type(obj.handlers.key_pressed) == "table") then
            obj.handlers.key_pressed = spec_func(obj.handlers.key_pressed)
        end
        if (obj.handlers.key_released and type(obj.handlers.key_released) == "table") then
            obj.handlers.key_released = spec_func(obj.handlers.key_released)
        end
    end

    self:add_object(name, obj.layer, obj)
end

function engine.Scene:load(file)
    local chunk = love.filesystem.load("scenes/" .. file .. ".scene")
    local result = chunk()
    for name, obj in pairs(result.objects) do
        self:load_obj(name, obj)
    end
    if (result.handlers) then
        self.handlers = {}
        if (result.handlers.mouse) then
            self.handlers.mouse = result.handlers.mouse
        end
        if (result.handlers.mouse_pressed) then
            self.handlers.mouse_pressed = result.handlers.mouse_pressed
        end
        if (result.handlers.mouse_released) then
            self.handlers.mouse_released = result.handlers.mouse_released
        end
        if (result.handlers.key_pressed) then
            if (type(result.handlers.key_pressed) == "function") then
                self.handlers.key_pressed = result.handlers.key_pressed
            elseif (type(result.handlers.key_pressed) == "table") then
                self.handlers.key_pressed = spec_func(result.handlers.key_pressed)
            else
                error("Expected table or function, got " .. type(result.handlers.key_pressed))
            end
        end
        if (result.handlers.key_released) then
            if (type(result.handlers.key_released) == "function") then
                self.handlers.key_released = result.handlers.key_released
            elseif (type(result.handlers.key_released) == "table") then
                self.handlers.key_released = spec_func(result.handlers.key_released)
            else
                error("Expected table or function, got " .. type(result.handlers.key_released))
            end
        end
    end
end

function engine.Scene:mouse_handler(x, y)
    if (self.handlers and self.handlers.mouse) then
        self.handlers.mouse(self, x, y, button, istouch)
    end
    for name, obj in pairs(self.objects) do
        if (obj:contains(x, y) and obj.handlers and obj.handlers.mouse) then
            obj.handlers.mouse(self.objects[name], x, y)
        end
    end
end

function engine.Scene:mouse_pressed_handler(x, y, button, istouch)
    if (self.handlers and self.handlers.mouse_pressed) then
        self.handlers.mouse_pressed(self, x, y, button, istouch)
    end
    for name, obj in pairs(self.objects) do
        if (obj:contains(x, y) and obj.handlers and obj.handlers.mouse_pressed) then
            obj.handlers.mouse_pressed(self.objects[name], x, y, button, istouch)
        end
    end
end

function engine.Scene:mouse_released_handler(x, y, button, istouch)
    if (self.handlers and self.handlers.mouse_released) then
        self.handlers.mouse_released(self, x, y, button, istouch)
    end
    for name, obj in pairs(self.objects) do
        if (obj:contains(x, y) and obj.handlers and obj.handlers.mouse_released) then
            obj.handlers.mouse_released(self.objects[name], x, y, button, istouch)
        end
    end
end

function engine.Scene:key_pressed_handler(key, scancode, isrepeat)
    if (self.handlers and self.handlers.key_pressed) then
        self.handlers.key_pressed(self, key, scancode, isrepeat)
    end
    for name, obj in pairs(self.objects) do
        if (obj.handlers and obj.handlers.key_pressed) then
            obj.handlers.key_pressed(self.objects[name], key, scancode, isrepeat)
        end
    end
end

function engine.Scene:key_released_handler(key, scancode, isrepeat)
    if (self.handlers and self.handlers.key_released) then
        self.handlers.key_released(self, key, scancode, isrepeat)
    end
    for name, obj in pairs(self.objects) do
        if (obj.handlers and obj.handlers.key_released) then
            obj.handlers.key_released(self.objects[name], key, scancode, isrepeat)
        end
    end
end

function engine.Scene:add_object(name, layer, obj)
    if (layer) then
        assert_type(layer, "number")
    end

    if (obj) then
        self.objects[name] = obj
    else
        self.objects[name] = engine.Object:new()
    end

    if (layer) then
        if (not self.layers[layer])
        then
            self.layers[layer] = {}
        end
        self.layers[layer][name] = self.objects[name]
    else
        self.layers["main"][name] = self.objects[name]
    end
end

function engine.Scene:draw()
    main_layer = self.layers["main"]
    for _, layer in pairs(self.layers) do
        for _, obj in pairs(layer) do
            obj:draw()
        end
    end
    for _, obj in pairs(main_layer) do
        obj:draw()
    end
end

function engine.Scene:update(dt)
    local x, y = love.mouse.getPosition()
    self:mouse_handler(x, y)
    for name, obj in pairs(self.objects)
    do
        if (obj.pre_update) then
            obj:pre_update(dt)
        end
        if (obj.update) then
            obj:update(dt)
        end
    end
end