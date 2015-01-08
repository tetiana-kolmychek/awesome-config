function run_once(prg)
	if not prg then
		do return nil end
	end
	awful.util.spawn_with_shell("pgrep -u $USER -x " .. prg .. " || (" .. prg .. ")")
	naughty.notify({ text= "Launched: " .. prg, height = 25, timeout=4}) 
end

function run_in_shell(prg)
	if not prg then
		do return nil end
	end
	run_once(terminal .. " -e " .. prg)
end