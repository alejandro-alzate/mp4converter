local commands = require("commands")

local queue = {}
local method = "ffmpeg"
local conversionInProgress = false
local workerThread = love.thread.newThread("worker.lua")
local videoWhiteList = require("videoWhiteList")

local jobChannel = love.thread.getChannel("jobChannel")
local statusChannel = love.thread.getChannel("statusChannel")
local commandOutputChannel = love.thread.getChannel("commandOutputChannel")

local jobTerminalOutput = ""
local lastStatusString = ""

local system =
	love.system.getOS() == "Windows" and "windows"
	or love.system.getOS() == "Mac OS" and "mac"
	or "linux"

function os.capture(cmd, raw)
	local handle = assert(io.popen(cmd, 'r'))
	local s = assert(handle:read('*a'))
	handle:close()
	if raw then return s end
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end

local function checkMethod()
	if method == "ffmpeg" then
		local command = commands[system].version
		local handle = io.popen(command)
		if handle then
			local version = handle:read("*a")
			handle:close()
			if not version then
				love.system.showMessageBox("Error", "FFmpeg not found or not working.")
				print("FFmpeg not found or not working.")
				return
			end
			print(version:sub(1, version:find("\n") - 1))
		else
			print("FFmpeg not found or not working.")
		end

		print("Using ffmpeg")
	else
		print("Invalid method")
	end
end

local function startConversion()
	if conversionInProgress then
		print("Conversion already in progress")
		return
	end
	jobChannel:push(queue)

	conversionInProgress = true
	print("Starting conversion")
end

local function stopConversion()
	if not conversionInProgress then
		print("No conversion in progress")
		return
	end

	conversionInProgress = false
	print("Stopping conversion")
end

local function startJob(job)
	local command = commands[system].convert:format(job.file, job.file)
	job.status = "running"
	print("Attempting conversion: " .. command)
	job.handle = assert(io.popen(command, "r"))
	job.output = assert(job.handle:read("*a"))
	job.rc = { job.handle:close() }
	job.status = "done"
end

local function startWorker()
	print("Starting worker")
	workerThread = love.thread.newThread("worker.lua")
	workerThread:start(system)
end

local function isVideo(filename)
	for _, pattern in ipairs(videoWhiteList) do
		if filename:match(pattern) then
			--print("Accepted:", filename)
			return true
		end
	end
	--print("Rejected:", filename)
	return false
end

local function pushToQueue(filename)
	if isVideo(filename) then
		local name = type(filename) == "string" and filename or filename:getFilename()
		table.insert(queue, { status = "pending", file = name, })
	end
end

function love.load()
	checkMethod()
	startWorker()
end

function love.filedropped(file)
	--print("File dropped:", file:getFilename())
	pushToQueue(file:getFilename())
end

function love.directorydropped(folder)
	--print("Folder dropped:", folder)
	love.filesystem.mount(folder, folder)
	local info = love.filesystem.getInfo(folder)
	if not info then
		print("Error getting info for folder:", folder)
		return
	end
	if info.type == "directory" then
		for _, file in ipairs(love.filesystem.getDirectoryItems(folder)) do
			--print("File:", file)
			pushToQueue(folder .. "/" .. file)
		end
	end
end

function love.update(dt)
	if commandOutputChannel:peek() ~= nil then
		if commandOutputChannel:peek() ~= jobTerminalOutput then
			print("askldjaskljdklj", type(commandOutputChannel:pop()))
		end
	end

	if statusChannel:peek() ~= nil then
		if statusChannel:peek() ~= queue then
			queue = statusChannel:pop()
		end
	end
end

function love.draw()
	local tip =
	"Drop a file or folder to convert all its video contents into .mp4 discord complaint format\npress Space to start.\nPress S to stop"
	local pendingCount = 0
	local runningCount = 0
	local doneCount = 0
	local list = ""
	for i, v in ipairs(queue) do
		if v.status == "pending" then
			pendingCount = pendingCount + 1
		elseif v.status == "running" then
			runningCount = runningCount + 1
		elseif v.status == "done" then
			doneCount = doneCount + 1
		end
		if v.status == "done" and #queue > 30 then
			-- Skip all done files if the queue is too large
		else
			list = list .. string.format("%s: %4.d %s\n", v.status, i, v.file)
		end
	end
	local countTip = string.format("Files to process: %d/%d", pendingCount, #queue)

	love.graphics.print(jobTerminalOutput ..
		"\n" .. tip .. "\n" .. countTip .. "\n" .. string.format("Method: %s", method) .. "\n" .. list)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end

	if key == "space" then
		startConversion()
	end

	if key == "s" then
		stopConversion()
	end

	if key == "f5" then
		love.event.quit("restart")
	end
end

function love.threaderror(...)
	print(...)
	love.event.quit("restart")
end
