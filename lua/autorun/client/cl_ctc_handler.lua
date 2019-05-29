if CLIENT then
    CTC = {}

    -- server sends command data to client
    net.Receive('ttt_ctc_send_data', function(len)
        local data = net.ReadString()
        CTC = util.JSONToTable(data)

        -- add to language
        for lang_id, lang_tbl in pairs(CTC.text) do
            for sub, lang in pairs(lang_tbl) do
                LANG.AddToLanguage(lang_id, sub, lang)
            end
        end

        -- preprocess colors
        print("===================================================================================")
        PrintTable(CTC.variables.colors)
        print("===================================================================================")
        for name, color_tbl in pairs(CTC.variables.colors) do
            print("in loop")
            print(name)
            PrintTable(color_tbl)
            CTC.variables.colors[name] = Color(color_tbl[1] or 255, color_tbl[2] or 255, color_tbl[3] or 255, color_tbl[4] or 255)
            PrintTable(CTC.variables.colors[name])
        end
    end)

    hook.Add('OnPlayerChat', 'CTC_Player_Chat', function(player, text, teamOnly, playerIsDead)
        local prefix_len = CTC.settings.prefix:len()

        -- line starts not with prefix, therefore this is no command
        if text:sub(1, prefix_len) ~= CTC.settings.prefix then return end

        local command = text:sub(prefix_len +1)

        -- command is not found inside the data table
        if CTC.commands[command] == nil then return end

        -- command is valid --> execute
        CTC_PrintChat(command)

        return true -- prevent issued command from beeing printed to chat
    end)

    function CTC_PrintChat(command)
        -- stop if no chat prints are needed
        if CTC.commands[command].chat == nil then return end

        for _, line in ipairs(CTC.commands[command].chat) do
            local print_string
            
            -- translate if needed
            if CTC.commands[command].localized == false then
                print_string = line
            else
                print_string = LANG.GetParamTranslation(line, CTC.variables.strings)
            end

            -- replace special placeholders
            local print_string_ex = string.Explode('$', print_string)
            print_string = '' -- clear string

            for k, v in ipairs(print_string_ex) do
                if v == 'p' then
                    print_string_ex[k] = tostring(LocalPlayer():Nick())
                end
                if v == 't' then
                    print_string_ex[k] = tostring(os.date("%H:%M:%S" , os.time()))
                end
                if v == 'd' then
                    print_string_ex[k] = tostring(os.date("%d/%m/%Y" , os.time()))
                end

                -- concat
                print_string = print_string .. print_string_ex[k]
            end

            -- handle colors
            local print_string_ex = string.Explode('%', print_string)
            for k, v in ipairs(print_string_ex) do
                if CTC.variables.colors[v] ~= nil then
                    print_string_ex[k] = CTC.variables.colors[v]
                end
            end

            chat.AddText(unpack(print_string_ex))
        end
    end

end