-- Pause briefly after opening the audio stream so that jack-plumbing has time
-- to connect the ports.
--
-- This should theoretically be possible with --audio-wait-open, but that
-- option doesn't seem to take effect, even with --audio-stream-silence, as of
-- mpv 0.36.0.
mp.set_property("audio-stream-silence", "yes")
if mp.get_property("pause") == "no" then
	mp.set_property("pause", "yes")
	mp.register_event("file-loaded", function()
		mp.add_timeout(0.25, function()
			mp.set_property("pause", "no")
		end)
	end)
end
