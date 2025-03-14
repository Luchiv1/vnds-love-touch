local ispause = false
on("mouse_input", function(x, y, btn)
    if (btn == 1) then
        dispatch("input", "a")
    elseif (btn == 2) then
        if (ispause) then
            dispatch("input", "b")
        else
            dispatch("input", "start")
        end
    end
end)
