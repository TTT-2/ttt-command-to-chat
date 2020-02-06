util.AddNetworkString("ttt_ctc_send_data")

CTC_string = ""

-- on server init the command file is processed
hook.Add("Initialize", "CTC_Initial_Setup", function()
	if not file.Exists("ctc", "DATA") then
		file.CreateDir("ctc")
	end
	if not file.Exists("ctc/commands.txt", "DATA") then
		file.Write("ctc/commands.txt", util.TableToJSON( CTC_DEFAULT, true ))
	end

	CTC_string = file.Read("ctc/commands.txt", "DATA")
end)

-- on player connect the command file is sent to the player
hook.Add("PlayerInitialSpawn", "CTC_Player_Connect", function(ply)
	net.Start("ttt_ctc_send_data")
	net.WriteString(CTC_string)
	net.Send(ply)
end)