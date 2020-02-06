CTC = {}

-- server sends command data to client
net.Receive("ttt_ctc_send_data", function(len)
	local data = net.ReadString()

	CTC = util.JSONToTable(data)

	if CTC == nil then
		Error("[CTC ERROR] Syntax of command file is not correct!")
		return
	end

	-- add to language
	for lang_id, lang_tbl in pairs(CTC.text) do
		for sub, lang in pairs(lang_tbl) do
			LANG.AddToLanguage(lang_id, sub, lang)
		end
	end

	-- preprocess colors
	local found_default, found_highlight = false, false

	if CTC.variables ~= nil and CTC.variables.colors ~= nil then
		for name, color_tbl in pairs(CTC.variables.colors) do
			CTC.variables.colors[name] = Color(
				color_tbl[1] or 255,
				color_tbl[2] or 255,
				color_tbl[3] or 255,
				color_tbl[4] or 255
			)

			if name == "ctc_default" then
				found_default = true
			end

			if name == "ctc_highlight" then
				found_highlight = true
			end
		end
	end

	-- make sure the two default colors are always set
	CTC.variables = CTC.variables or {}
	CTC.variables.colors = CTC.variables.colors or {}

	if not found_default then
		CTC.variables.colors["ctc_default"] = Color(151, 211, 255, 255)
	end

	if not found_highlight then
		CTC.variables.colors["ctc_highlight"] = Color(215, 240, 240, 255)
	end

	-- register commands
	for name, _ in pairs(CTC.commands) do
		concommand.Add("ctc_" .. name, function(ply, cmd, args)
			if ply ~= LocalPlayer() then return end

			CTC_Command(name)
		end)
	end

	-- register help command
	concommand.Add("ctc_defaults_list_all", function(ply, cmd, args)
		if ply ~= LocalPlayer() then return end

		for name, command_tbl in pairs(CTC.commands) do
			local translated = ""

			if command_tbl.desc ~= nil and command_tbl.desc.text ~= nil then
				if command_tbl.desc.localized == false then
					translated = command_tbl.desc.text
				else
					translated = LANG.GetTranslation(command_tbl.desc.text)
				end
			end

			local line_tbl = {
				CTC.variables.colors["ctc_highlight"],
				CTC.settings.prefix .. name,
				CTC.variables.colors["ctc_default"],
				": " .. translated
			}

			chat.AddText(unpack(line_tbl))
		end
	end)

	-- make sure prefix is set
	if not CTC.settings then
		CTC.settings = {}
	end

	if not CTC.settings.prefix then
		CTC.settings.prefix = "!"
	end
end)

hook.Add("OnPlayerChat", "CTC_Player_Chat", function(ply, text, teamOnly, playerIsDead)
	if not CTC then return end

	-- only run the possible command when its the correct player
	if ply ~= LocalPlayer() then return end

	local prefix_len = CTC.settings.prefix:len()

	-- line starts not with prefix, therefore this is no command
	if text:sub(1, prefix_len) ~= CTC.settings.prefix then return end

	local command = text:sub(prefix_len + 1)

	-- command is not found inside the data table
	if not CTC.commands[command] then return end

	-- command is valid --> execute
	chat.AddText(CTC.variables.colors["ctc_default"], ">> ", CTC.variables.colors["ctc_highlight"], text)
	CTC_RunFirst(command)

	return true -- prevent issued command from beeing printed to chat
end)

function CTC_RunFirst(command)
	if CTC.settings.run_first == "console" then
		CTC_Run_Command(command)
		CTC_PrintChat(command)
	else
		CTC_PrintChat(command)
		CTC_Run_Command(command)
	end
end

function CTC_PrintChat(command)
	-- stop if no chat prints are needed
	if not CTC.commands[command].chat then return end

	for _, line in ipairs(CTC.commands[command].chat) do
		local print_string

		-- translate if needed
		if CTC.commands[command].localized == false then
			print_string = line
		else
			print_string = LANG.GetParamTranslation(line, CTC.variables.strings or {})
		end

		-- replace special placeholders
		local print_string_ex_placeholder = string.Explode("$", print_string)
		print_string = "" -- clear string

		for k, v in ipairs(print_string_ex_placeholder) do
			if v == "p" then
				print_string_ex_placeholder[k] = tostring(LocalPlayer():Nick())
			end
			if v == "t" then
				print_string_ex_placeholder[k] = tostring(os.date("%H:%M:%S" , os.time()))
			end
			if v == "d" then
				print_string_ex_placeholder[k] = tostring(os.date("%d/%m/%Y" , os.time()))
			end
			if v == "s" then
				print_string_ex_placeholder[k] = tostring(GetHostName())
			end

			-- concat
			print_string = print_string .. print_string_ex_placeholder[k]
		end

		-- handle colors
		local print_string_ex_color = string.Explode("%", print_string)
		for k, v in ipairs(print_string_ex_color) do
			if CTC.variables.colors[v] then
				print_string_ex_color[k] = CTC.variables.colors[v]
			end
		end

		chat.AddText(unpack(print_string_ex_color))
	end
end

function CTC_Run_Command(command)
	-- stop if no commands are needed
	if not CTC.commands[command].console then return end

	for _, line in ipairs(CTC.commands[command].console) do
		RunConsoleCommand(line)
	end
end

function CTC_Command(command)
	-- command is not found inside the data table
	if not CTC.commands[command] then return end

	-- command is valid --> execute
	CTC_RunFirst(command)
end
