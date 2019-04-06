require("types/class")

function assert_type(value, typ)
    if (type(value) ~= typ)
    then 
        error("bad value type: expected " .. typ .. ", got " .. type(value))
    end
end

function split_text(text, size)
    local splitted_text = ""
    local joined_string = ""
    local lenn = 0
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
        return joined_string
    else
        return splitted_text .. "\n" .. joined_string
    end
end

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
    Object = Class:new(),
    Scene = Class:new(),
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