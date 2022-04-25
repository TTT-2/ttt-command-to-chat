CTC = CTC or {
	data = {}
}

-- server sends command data to client
net.Receive("ttt_ctc_send_data", function(len)
	local data = net.ReadString()

	CTC.data = util.JSONToTable(data)

	if not CTC.data then
		Error("[CTC ERROR] Syntax of command file is not correct!")

		return
	end

	-- add to language
	for lang_id, lang_tbl in pairs(CTC.data.text) do
		for sub, lang in pairs(lang_tbl) do
			LANG.AddToLanguage(lang_id, sub, lang)
		end
	end

	-- preprocess colors
	local found_default, found_highlight = false, false

	if CTC.data.variables and CTC.data.variables.colors then
		for name, color_tbl in pairs(CTC.data.variables.colors) do
			CTC.data.variables.colors[name] = Color(
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
	CTC.data.variables = CTC.data.variables or {}
	CTC.data.variables.colors = CTC.data.variables.colors or {}

	if not found_default then
		CTC.data.variables.colors["ctc_default"] = Color(151, 211, 255, 255)
	end

	if not found_highlight then
		CTC.data.variables.colors["ctc_highlight"] = Color(215, 240, 240, 255)
	end

	-- register commands
	for name, _ in pairs(CTC.data.commands) do
		concommand.Add("ctc_" .. name, function(ply, cmd, args)
			if ply ~= LocalPlayer() then return end

			CTC:Command(name)
		end)
	end

	-- register help command
	concommand.Add("ctc_defaults_list_all", function(ply, cmd, args)
		if ply ~= LocalPlayer() then return end

		for name, command_tbl in pairs(CTC.data.commands) do
			local translated = ""

			if command_tbl.desc and command_tbl.desc.text then
				if command_tbl.desc.localized == false then
					translated = command_tbl.desc.text
				else
					translated = LANG.GetTranslation(command_tbl.desc.text)
				end
			end

			local line_tbl = {
				CTC.data.variables.colors["ctc_highlight"],
				CTC.data.settings.prefix .. name,
				CTC.data.variables.colors["ctc_default"],
				": " .. translated
			}

			chat.AddText(unpack(line_tbl))
		end
	end)

	-- make sure prefix is set
	if not CTC.data.settings then
		CTC.data.settings = {}
	end

	if not CTC.data.settings.prefix then
		CTC.data.settings.prefix = "!"
	end
end)

hook.Add("OnPlayerChat", "CTC_Player_Chat", function(ply, text, teamOnly, playerIsDead)
	if not CTC.data then return end

	local command, args = CTC:PrepareCommand(text)

	-- only run the possible command when its the correct player
	if ply ~= LocalPlayer() then return end

	if not command then return end

	-- command is valid --> execute
	chat.AddText(CTC.data.variables.colors["ctc_default"], ">> ", CTC.data.variables.colors["ctc_highlight"], text)

	CTC:RunFirst(command, args)

	return true -- prevent issued command from beeing printed to chat
end)

function CTC:PrepareCommand(text)
	local prefix_len = self.data.settings.prefix:len()

	local text_exp = string.Explode(" ", text)

	-- line starts not with prefix, therefore this is no command
	if text_exp[1]:sub(1, prefix_len) ~= self.data.settings.prefix then
		return false
	end

	local command = text_exp[1]:sub(prefix_len + 1)

	-- command is not found inside the data table
	if not self.data.commands[command] then
		return false
	end

	-- remove the first table entry (the command)
	table.remove(text_exp, 1)

	return command, text_exp
end

function CTC:RunFirst(command, args)
	if self.data.settings.run_first == "console" then
		self:RunCommand(command, args)
		self:PrintChat(command)
	else
		self:PrintChat(command)
		self:RunCommand(command, args)
	end
end

function CTC:PrintChat(command)
	-- stop if no chat prints are needed
	if not self.data.commands[command].chat then return end

	for _, line in ipairs(self.data.commands[command].chat) do
		local print_string

		-- translate if needed
		if self.data.commands[command].localized == false then
			print_string = line
		else
			print_string = LANG.GetParamTranslation(line, self.data.variables.strings or {})
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
			if self.data.variables.colors[v] then
				print_string_ex_color[k] = self.data.variables.colors[v]
			end
		end

		chat.AddText(unpack(print_string_ex_color))
	end
end

function CTC:RunCommand(command)
	-- stop if no commands are needed
	if not self.data.commands[command].console then return end

	for _, line in ipairs(self.data.commands[command].console) do
		if type(line) == "string" then
		RunConsoleCommand(line)
		return end
		-- handle commands with arguments
		RunConsoleCommand(line[1], unpack(line, 2))
	end
end

function CTC:Command(command, args)
	-- command is not found inside the data table
	if not self.data.commands[command] then return end

	-- command is valid --> execute
	self:RunFirst(command, unpack(args))
end
