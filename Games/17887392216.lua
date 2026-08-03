local function DownloadFile(Path, Function)
	if not isfile(Path) then
		local Success, Result = pcall(function()
			return game:HttpGet(`https://raw.githubusercontent.com/fluidnarrator30/Tidal-Wave/refs/heads/main/{Path:gsub("TidalWave/", "")}`, true)
		end)
        if Success and Result ~= "404: Not Found" then
            writefile(Path, Result)
        end
	end
    return (Function or readfile)(Path)
end

loadstring(DownloadFile('TidalWave/Games/17887390746.lua'))()