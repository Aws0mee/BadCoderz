function BadCoderz.ReadReport()
	local len = net.ReadUInt(16)
	local data = net.ReadData(len)
	local json = util.Decompress(data)
	local table = util.JSONToTable(json)

	return table
end

net.Receive("BadCoderz_status_request", function()
	if (net.ReadBool()) then
		local len = net.ReadUInt(16)

		while (len ~= 0) do
			BadCoderz.dangerous_hooks[net.ReadString()] = true
			len = len - 1
		end
	end

	local activeServer = net.ReadBool()
	BadCoderz.ShowUI(activeServer)
end)

if BadCoderz.owner == "{{ user_id }}" then
	concommand.Add("BadCoderz", function()
		if not LocalPlayer():CanUseBadCoderz() then -- 						ONLY TWO GENDERS
			LocalPlayer():ChatPrint("Only the person who paid for the addon ([his/her] steamid64) is allowed to use the addon.\nThis person can still export reports in .txt format to share with his/her team.")

			return
		end

		net.Start("BadCoderz_status_request")
		net.WriteBool(table.IsEmpty(BadCoderz.dangerous_hooks))
		net.SendToServer()
	end)
end

net.Receive("BadCoderz_report_request", function()
	local active = net.ReadBool()
	local report = BadCoderz.ReadReport()

	if (BadCoderz.Derma and IsValid(BadCoderz.Derma)) then
		BadCoderz.Derma.buttonServerside:UpdateAsync(active, report)
	end
end)

net.Receive("BadCoderz_serverside_file_open",function(len)
	local realPath = net.ReadString()
	local datalen = net.ReadUInt(16)
	local data = net.ReadData(datalen)
	local line;
	if (net.ReadBool()) then
		line = net.ReadUInt(13)
	end
	data = util.Decompress(data)
	if not data then error("Could not read file data from server : " .. realPath) return end

	BadCoderz.openLuaPad(data, realPath, line)

end)