require("types/class")

-- value - Значение
-- typ::string - Ожидаемый тип
-- Вызывает ошибку если тип значения не соответствует ожидаемому
function assert_type(value, typ)
    if (type(value) ~= typ)
    then 
        error("bad value type: expected " .. typ .. ", got " .. type(value))
    end
end

-- text::string Текст для разделения
-- size::number Количество символов в одной строке
-- Делит text на строки с длинной не более size, но без разрыва слов
function split_text(text, size, len)
    local splitted_text = ""
    local joined_string = ""
    local lenn = len or 0
    for split in text:gmatch("[^ ]+") do
        if (split) then
            lenn = lenn + split:len()
            if (lenn >= size) then
                lenn = split:len()
                if (splitted_text == "") then
                    splitted_text = joined_string
                else
                    splitted_text = splitted_text .. "\n"  .. joined_string
                end
                joined_string = split
            else
                if (joined_string == "") then
                    joined_string = split
                else
                    joined_string = joined_string .. " " .. split
                end
            end
        end
    end
    if (splitted_text == "") then
        return joined_string, lenn
    else
        return splitted_text .. "\n" .. joined_string, lenn
    end
end

function split_colored_text(text, size, newline)
    local cur_size = 0
    local new_text = {}
    for n, tc in pairs(text) do
        if (n%2 == 1) then
            new_text[n] = tc
        else
            if (tc:len() > size) then
                new_text[n], cur_size = split_text(tc, size, cur_size)
            elseif (tc:len() == size and newline) then
                new_text[n] = tc .. "\n"
            else
                new_text[n] = tc
                cur_size = tc:len()
            end
        end
    end
    return new_text
end

-- n::string Имя таблицы
-- t::table Таблица для вывода
-- Выводит таблицу t и все вложенные в неё таблицы
function print_table(n, t)
    if (type(t) ~= "table") then
        print(n, ":", t)
    else
        print(n, ": {")
        for n, v in pairs(t) do
            print_table(n, v)
        end
        print("}")
    end
end

engine = {
    -- Класс графического объекта, родитель для всех классов объектов
    Object = Class:new(),
    -- Класс графической сцены, хранит объекты и методы их вывода
    Scene = Class:new(),
    -- Класс игры
    Game = Class:new(),
    Colors = {
        RED = {255, 0, 0, 255},
        GREEN = {0, 255, 0, 255},
        BLUE = {0, 0, 255, 255},
        WHITE = {255, 255, 255, 255},
        BLACK = {0, 0, 0, 255},
        YELLOW = {255, 255, 0, 255},
        CYAN = {0, 255, 255, 255},
        MAGENTA = {255, 0, 255, 255},
        GRAY = {128, 128, 128, 255},
    }
}