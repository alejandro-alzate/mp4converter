-- args[1] → system
io.stdout:setvbuf("no")
JOBS = {}
local args = { ... }
print("Worker started", ...)
local socket = require("socket")

local system = args[1]

--local love = require("love")
local commands = require("commands")

local jobChannel = love.thread.getChannel("jobChannel")
local statusChannel = love.thread.getChannel("statusChannel")
local commandOutputChannel = love.thread.getChannel("commandOutputChannel")

local function sleep(seconds)
	socket.sleep(seconds)
end

local function updateStatus()
	print("update status")
	statusChannel:clear()
	statusChannel:push(JOBS)
end

local function startJob(job)
	local command = commands[system].convert:format(job.file, job.file)
	job.status = "running"
	print("Attempting conversion: " .. command)
	local handle = assert(io.popen(command, "w"))
	updateStatus()
	job.output = handle:read("*a")
	commandOutputChannel:push(job.output)
	print(job.output)
	job.rc = { handle:close() }
	job.status = "done"
end


while true do
	JOBS = jobChannel:pop()
	if type(JOBS) == "table" then
		for i, job in ipairs(JOBS) do
			startJob(job)
			updateStatus()
		end
	end
end
