require("src/game") --Подключение модуля с функциями для игры

function game.load()
    game:set_main_font("Pixel Sans Serif Condensed", 20)
    love.keyboard.setKeyRepeat(true)
    game.version = "0.0.1"
    game.name = "GAME!"
    game:load_file("types/gui_types")
    game:add_scene("menu")
    game:add_scene("main")
    game:set_scene("menu")
end