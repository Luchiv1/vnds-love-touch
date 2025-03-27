local function textPrintReplace(str_in)
    return str_in:gsub("¤", "o"):gsub("£", "K"):gsub("¢", "k")
end
return { textPrintReplace = textPrintReplace }
