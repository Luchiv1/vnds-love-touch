on("load", function()
    love.window.setMode(1280, 720)
    pprint(love.window.getMode())
    if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' then
        love.window.setMode(0, 0, { fullscreen = true })
    end
end)
MENU_ACT = false

function love.draw()
    dispatch_often("draw_background")
    dispatch_often("draw_foreground")
    dispatch_often("draw_text")
    dispatch_often("draw_ui")
    dispatch_often("draw_debug")
    dispatch_often("draw_choice")
end

SCROLL_OFFSET = 0
OLD_SCROLL_OFFSET = 0
SCROLL_ACTIVE = false
SCROLL_LOCKED = false
SCROLLED = false
SCROLL_MIN = 0
SCROLL_MAX = 0
function love.mousepressed(x, y, button, istouch)
    SCROLL_ACTIVE = true
end

function love.mousemoved(x, y, dx, dy)
    if SCROLL_ACTIVE and not SCROLL_LOCKED then
        local tmp = SCROLL_OFFSET + dy
        if tmp < SCROLL_MIN then
            SCROLL_OFFSET = SCROLL_MIN
        elseif tmp > SCROLL_MAX then
            SCROLL_OFFSET = SCROLL_MAX
        else
            SCROLL_OFFSET = tmp
        end
        SCROLLED = true
    end
end

function love.mousereleased(x, y, button, istouch)
    SCROLL_ACTIVE = false
    if not SCROLLED then
        -- No movement happened. We clicked on item and thats all.
        dispatch("click", x, y, button)
    end
    SCROLLED = false
end

local touches = {}

function love.touchpressed(id)
    touches[#touches + 1] = id

    if #touches == 2 then
        if MENU_ACT then
            dispatch("input", "b")
        else
            dispatch("input", "start")
        end
    end
end

function love.touchreleased(id)
    for i, t in ipairs(touches) do
        if t == id then
            table.remove(touches, i) -- note: Use table.remove so it shifts the elements.
        end
    end
end

on("click", function(x, y, button, istouch)
    if not istouch then
        if button == 1 then
            dispatch("input", "a")
        elseif button == 2 then
            dispatch("input", "start")
        end
    else
    end
end)
BUTTON_MARGIN = 5
BUTTON_PADDING = 15
BUTTON_WIDTH = love.graphics.getWidth() - BUTTON_MARGIN * 2
local function create_listbox(self)
    MENU_ACT = true
    local winwidth = love.graphics.getWidth()
    local font = love.graphics.getFont()
    local text = love.graphics.newText(font)
    local draw_evt, input_evt
    self.selected = self.selected or 1
    if self.choices[self.selected].onchange then
        self.choices[self.selected].onchange(self.choices[self.selected])
    end
    self.closable = self.closable or false
    self.allow_menu = self.allow_menu or false
    local function close()
        draw_evt:remove()
        input_evt:remove()
        dispatch("play")
        MENU_ACT = false
    end
    self.onclose = self.onclose or close
    self.media = self.media
    dispatch("pause")
    local buttons = {}
    SCROLL_OFFSET = 0
    SCROLL_MIN = 0
    SCROLL_MAX = 0
    SCROLL_LOCKED = false
    local height_offset = 0
    for _, v in ipairs(self.choices) do
        local width, wrapped_text_seq = font:getWrap(v.text, winwidth - BUTTON_PADDING * 2)
        local wrapped_text = ""
        if (#wrapped_text_seq == 1) then
            wrapped_text = wrapped_text_seq[1]
        else
            for _, v in ipairs(wrapped_text_seq) do
                wrapped_text = wrapped_text .. v .. '\n'
            end
        end
        local button_height = font:getHeight() * #wrapped_text_seq + BUTTON_MARGIN * 2
        height_offset = height_offset + button_height
    end
    SCROLL_MIN = -(height_offset - love.graphics.getHeight()) - 200
    if height_offset < love.graphics.getHeight() then
        SCROLL_LOCKED = true
        SCROLL_OFFSET = love.graphics.getHeight() / 2 - height_offset / 2
    end
    draw_evt = on("draw_choice", function()
        text:clear()
        buttons = {}
        local last_y = SCROLL_OFFSET

        for _, v in ipairs(self.choices) do
            local width, wrapped_text_seq = font:getWrap(v.text, winwidth - BUTTON_PADDING * 2)
            local wrapped_text = ""
            if (#wrapped_text_seq == 1) then
                wrapped_text = wrapped_text_seq[1]
            else
                for _, v in ipairs(wrapped_text_seq) do
                    wrapped_text = wrapped_text .. v .. '\n'
                end
            end
            local button_width = winwidth - BUTTON_MARGIN * 2
            local button_height = font:getHeight() * #wrapped_text_seq + BUTTON_MARGIN * 2
            local y = last_y + BUTTON_MARGIN
            table.insert(buttons, ({
                y_start = y,
                y_end = y + button_height,
                choice = v
            }))
            text:add(wrapped_text, math.floor(winwidth / 2 - width / 2), math.floor(y))
            love.graphics.setColor(1, 1, 1, .5)
            love.graphics.rectangle("fill", BUTTON_MARGIN, y,
                button_width, button_height, 10, 10)
            love.graphics.setColor(.5, .5, .5, .5)

            love.graphics.rectangle("line", BUTTON_MARGIN, y,
                button_width, button_height, 10, 10)
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.draw(text)
            last_y = y + button_height
        end
    end)
    input_evt = on("click", function(x, y, button, istouch)
        if istouch and love.touch.getTouches() > 1 then return true end
        if button == 1 then
            for _, v in ipairs(buttons) do
                if (y >= v.y_start and y <= v.y_end) then
                    local outcome = v.choice.action(v.choice, close)
                    close()
                    self:onclose()
                    break
                end
            end
        else
            if self.closable then close() end
            self:onclose()
        end
        return false
    end)

    -- local container = luis.newFlexContainer(grid_width, grid_height, 1, 1, nil, "choice")
    -- for i, v in ipairs(self.choices) do
    --     local button1 = luis.newButton(v.text, grid_width, 1, function() end,
    --         function()
    --             local outcome = v.action(v, close)
    --             luis.removeElement(choice_layer, container)
    --             if self.closable and outcome then close() end
    --             if not self.closable then close() end
    --         end, 5, 2)
    --     container:addChild(button1)
    -- end
    -- pprint(luis.gridSize)
    -- container:resize(luis.gridSize, 9)
    -- luis.createElement(choice_layer, "FlexContainer", container)
    -- luis.setCurrentLayer("choice")
end

return { create_listbox = create_listbox, luis = luis }
