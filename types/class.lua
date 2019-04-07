-- Объект класса от которого наследуются все остальные классы
Class = {
	__type = "Class",
	__new = function(self, obj)
		self.__index = self
		if (obj) then
			return setmetatable(obj, self)
		else
			return setmetatable({}, self)
		end
	end
}

-- Возвращает родителя текущего объекта/класса
function Class:__parent()
	return getmetatable(self).__index
end

-- class::Class - класс родитель
-- создает новый класс наследующийся от class, 
-- если class == nil, наследуется от Class
function Class:new(class)
 	if (class) then
 		class.__index = class
 		return setmetatable({}, class)
 	else
 		self.__index = self
 		return setmetatable({}, self)
 	end
end