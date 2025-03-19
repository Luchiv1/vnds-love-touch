local choice_layer = "choice"


local initLuis = require("luis.init")

-- Direct this to your widgets folder.
luis = initLuis("luis/widgets")
local function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
-- register flux in luis, some widgets need it for animations
luis.flux = require("luis.3rdparty.flux")
local clickthrough_layer = "clickthrough"
on("load", function()
    luis.newLayer(clickthrough_layer)
    luis.newLayer(choice_layer)

    luis.setCurrentLayer(clickthrough_layer)

    love.window.setMode(1280, 1024)
end)

local time = 0
on("update", function(dt)
    time = time + dt
    if time >= 1 / 60 then
        luis.flux.update(time)
        time = 0
    end

    luis.update(dt)
end)

function love.draw()
    dispatch_often("draw_background")
    dispatch_often("draw_foreground")
    dispatch_often("draw_text")
    dispatch_often("draw_choice")
    dispatch_often("draw_ui")
    dispatch_often("draw_debug")
    luis.draw()
end

function love.mousepressed(x, y, button, istouch)
    luis.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    luis.mousereleased(x, y, button, istouch)
    if tablelength(luis.elements[luis.currentLayer]) == 0 then
        if button == 1 then
            dispatch("input", "a")
        elseif button == 2 then
            dispatch("input", "start")
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        if luis.currentLayer == "main" then
            love.event.quit()
        end
    elseif key == "tab" then -- Debug View
        luis.showGrid = not luis.showGrid
        luis.showLayerNames = not luis.showLayerNames
        luis.showElementOutlines = not luis.showElementOutlines
    else
        luis.keypressed(key)
    end
end

function create_listbox(self)
    self.selected = self.selected or 1
    if self.choices[self.selected].onchange then
        self.choices[self.selected].onchange(self.choices[self.selected])
    end
    self.closable = self.closable or false
    self.allow_menu = self.allow_menu or false
    local function close()
        dispatch("play")
    end
    self.onclose = self.onclose or close
    self.media = self.media

    local container = luis.newFlexContainer(32, 32, 1, 1, nil, "choice")
    for i, v in ipairs(self.choices) do
        local button1 = luis.newButton(v.text, 15, 3, function() end,
            function()
                local outcome = v.action(v, close)
                luis.removeElement(choice_layer, container)
                if self.closable and outcome then close() end
                if not self.closable then close() end
            end, 5, 2)
        container:addChild(button1)
    end
    luis.createElement(choice_layer, "FlexContainer", container)
    luis.setCurrentLayer("choice")
end

return { create_listbox = create_listbox, luis = luis }
