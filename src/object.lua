require("src/engine")

-- name::string - Имя объекта
-- obj::table - Необработанный объект из .scene файла
-- Извлекает тип объекта и нормализует его
-- return (имя объекта)::string, (тип объекта)::Class
function type_from_obj(name, obj)
    local typ
    if (obj.type and (type(obj.type) == "string" or type(obj.type) == "table")) then
        typ = obj.type
        obj.type = nil
    elseif (obj[1] and (type(obj[1]) == "string"  or type(obj[1]) == "table")) then
        typ = obj[1]
        obj[1] = nil
    else
        print_table("n", obj)
        error("Expected type in object", name)
    end
    if (type(typ) == "table") then
        typ = typ.__name
        if (not typ) then
            error("Bad type in object " .. name)
        end
    end
    if (game.types[typ]) then
        return typ, game.types[typ]
    else
        error("Type " .. typ .. " not found")
    end
end

-- load_obj::Object - необработанный объект
-- issimple::bool - является ли объект "простым", то есть не содержащим handler'ов
-- type::stirng - ожидаемый тип (необязательно)
-- Обрабатывает сырой объект из .scene файла
-- return (Обработанный объект)::(Object или его потомок)
function load_object(load_obj, issimple, type)
    local type_name, typ = type_from_obj(name, load_obj)
    if (type) then
        if (type ~= type_name) then
            error("Expected type: " .. type .. ", get" .. type_name)
        end
    end
    local obj = typ:new()

    for n, t in pairs(load_obj) do
        obj[n] = t
    end

    if (obj.coord) then
        obj.coord.x, obj.coord.y = obj.coord.x or 0, obj.coord.y or 0
    else
        obj.coord = { x = 0, y = 0 }
    end

    obj.scaling = { x = 1, y = 1 }
    if (obj.scale) then
        obj.scaling.x, obj.scaling.y = obj.scale.x or 1, obj.scale.y or 1
        obj.scale = nil
    end


    if (issimple) then
        if (obj.handlers) then
            error("Subobject must not has handlers")
        end
    end

    if (obj.load) then
        obj:load()
    end

    return obj
end

-- Создает новый объект
-- return объект::Object
function engine.Object:new()
    local obj = self:__new {
        -- Координаты объекта
        coord = { x = 0, y = 0 },
        -- Угол объекта в радианах
        rotation = 0,
        -- Масштаб объекта
        scaling = { x = 1, y = 1 },
    }
    return obj
end

-- x::number, y::number
-- Устанавливает координаты объекта в (x,y)
function engine.Object:set_coord(x, y)
    self.coord.x = x
    self.coord.y = y
    return self
end

-- x::number, y::number
-- Устанавливает масштаб объекта в (x,y)
function engine.Object:set_scale(x, y)
    self.scaling.x = x
    self.scaling.y = y
    return self
end

-- r::number
-- Устанавливает угол поворота объекта в r
function engine.Object:set_rotate(r)
    self.rotate = r
    return self
end

-- x::number, y::number
-- Двигает объект по осям x и y
function engine.Object:move(x, y)
    self.coord.x = self.coord.x + x
    self.coord.y = self.coord.y + y
end

-- dr::number
-- Поворачивает объект на dr радиан
function engine.Object:rotate(dr)
    self.rotation = self.rotation + dr
end

-- sx::number, sy::number
-- Растягивает объект по осям x и y
function engine.Object:stretch(sx, sy)
    self.scaling.x = self.scaling.x * sx
    self.scaling.y = self.scaling.y * sy
end

-- x::number, y::number
-- проверят содержится ли точка (x,y) в объекте
-- return результат::bool
function engine.Object:contains(x, y)
    local demx, demy = self:get_dimensions()
    return ((x >= self.coord.x) and (x <= (self.coord.x + demx * self.scaling.x)))
           and ((y >= self.coord.y) and (y <= (self.coord.y + demy * self.scaling.y)))
end

-- Возвращает матрицу преобразования объекта (см love.graphics.Transform)
-- return _::love.graphics.Transform
function engine.Object:get_transformation()
    return love.math.newTransform(self.coord.x, self.coord.y, self.rotation, self.scaling.x, self.scaling.y)
end