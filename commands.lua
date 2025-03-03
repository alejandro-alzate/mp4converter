local commands = {
	linux = {
		convert = "./ffmpeg-linux64/bin/ffmpeg -y -i \'%s\' -c:v libx264 -c:a aac -strict -2 \'%s.mp4\'",
		version = "./ffmpeg-linux64/bin/ffmpeg -version",
	},
	windows = {
		convert = ".\\ffmpeg-windows\\bin\\ffmpeg.exe -y -i \'%s\' -c:v libx264 -c:a aac -strict -2 \'%s.mp4\'",
		version = ".\\ffmpeg-windows\\bin\\ffmpeg.exe -version",
	},
}

return commands
