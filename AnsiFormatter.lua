--!strict
--[[
	AnsiFormatter.lua
	
	Lua 5.4, Bespoke ANSI formatting util
	by hammercroft
]]

local AnsiFormatter = {}

AnsiFormatter.DEFAULT_ESCAPE_CODES = {

	----------------------------------------------------------------
	-- RESET / STATE CONTROL
	----------------------------------------------------------------

	-- Reset all formatting and colours.
	-- Commonly emitted after coloured text blocks.
	reset = "\27[0m",

	-- Clear screen and move cursor to home position.
	-- Useful for TUIs and terminal redraw systems.
	clear_screen = "\27[2J",

	-- Reset cursor position to top-left.
	cursor_home = "\27[H",

	----------------------------------------------------------------
	-- TEXT STYLE / EMPHASIS
	----------------------------------------------------------------

	-- Bold / increased intensity.
	-- Widely supported.
	bold = "\27[1m",

	-- Faint / dim text.
	-- Not universally supported.
	dim = "\27[2m",

	-- Italic text.
	-- Some terminals fake this using colour changes.
	italic = "\27[3m",

	-- Underlined text.
	underline = "\27[4m",

	-- Slow blinking text.
	-- Often disabled in modern terminals.
	blink = "\27[5m",

	-- Reverse foreground/background colours.
	inverse = "\27[7m",

	-- Hidden/invisible text.
	-- Sometimes used for password masking.
	hidden = "\27[8m",

	-- Strikethrough text.
	-- Not supported everywhere.
	strikethrough = "\27[9m",

	----------------------------------------------------------------
	-- FOREGROUND COLOURS (STANDARD 8)
	----------------------------------------------------------------

	fg_black = "\27[30m",
	fg_red = "\27[31m",
	fg_green = "\27[32m",
	fg_yellow = "\27[33m",
	fg_blue = "\27[34m",
	fg_magenta = "\27[35m",
	fg_cyan = "\27[36m",
	fg_white = "\27[37m",

	----------------------------------------------------------------
	-- BRIGHT FOREGROUND COLOURS
	----------------------------------------------------------------

	fg_bright_black = "\27[90m",
	fg_bright_red = "\27[91m",
	fg_bright_green = "\27[92m",
	fg_bright_yellow = "\27[93m",
	fg_bright_blue = "\27[94m",
	fg_bright_magenta = "\27[95m",
	fg_bright_cyan = "\27[96m",
	fg_bright_white = "\27[97m",

	----------------------------------------------------------------
	-- BACKGROUND COLOURS (STANDARD 8)
	----------------------------------------------------------------

	bg_black = "\27[40m",
	bg_red = "\27[41m",
	bg_green = "\27[42m",
	bg_yellow = "\27[43m",
	bg_blue = "\27[44m",
	bg_magenta = "\27[45m",
	bg_cyan = "\27[46m",
	bg_white = "\27[47m",

	----------------------------------------------------------------
	-- BRIGHT BACKGROUND COLOURS
	----------------------------------------------------------------

	bg_bright_black = "\27[100m",
	bg_bright_red = "\27[101m",
	bg_bright_green = "\27[102m",
	bg_bright_yellow = "\27[103m",
	bg_bright_blue = "\27[104m",
	bg_bright_magenta = "\27[105m",
	bg_bright_cyan = "\27[106m",
	bg_bright_white = "\27[107m"
}

--- Converts text lines and formatting ranges into formatting VM instructions.
---
--- @param linesOfText {string}
--- @param formattingRanges {{
---     type: string,
---     start: number,
---     ["end"]: number
--- }}
--- @return {string}
function AnsiFormatter.toAnsiFormattingSteps(linesOfText, formattingRanges)
	local text = table.concat(linesOfText, "\n")

	local events = {}

	for _, range in ipairs(formattingRanges) do
		table.insert(events, {
			pos = range.start,
			action = "start",
			ftype = range.type
		})

		table.insert(events, {
			pos = range["end"] + 1,
			action = "end",
			ftype = range.type
		})
	end

	table.sort(events, function(a, b)
		if a.pos ~= b.pos then
			return a.pos < b.pos
		end

		if a.action ~= b.action then
			return a.action == "start"
		end

		return false
	end)

	local steps = {}
	local lastPos = 1

	local function writeSegment(segment)
		local startIdx = 1

		while true do
			local newlinePos = string.find(segment, "\n", startIdx, true)

			if not newlinePos then
				local remaining = string.sub(segment, startIdx)

				if remaining ~= "" then
					table.insert(steps, "write")
					table.insert(steps, remaining)
				end

				break
			end

			local lineText = string.sub(segment, startIdx, newlinePos - 1)

			if lineText ~= "" then
				table.insert(steps, "write")
				table.insert(steps, lineText)
			end

			table.insert(steps, "endl")

			startIdx = newlinePos + 1
		end
	end

	for _, event in ipairs(events) do
		if event.pos > lastPos then
			local segment = string.sub(text, lastPos, event.pos - 1)
			writeSegment(segment)
		end

		if event.action == "start" then
			table.insert(steps, "start_" .. string.lower(event.ftype))
		else
			table.insert(steps, "end_" .. string.lower(event.ftype))
		end

		lastPos = event.pos
	end

	if lastPos <= #text then
		local segment = string.sub(text, lastPos)
		writeSegment(segment)
	end

	return steps
end

--- Executes formatting VM instructions and emits ANSI escape-coded text.
---
--- @param formattingSteps {string}
--- @param escapeCodeDictionary {[string]: string}
--- @return string
function AnsiFormatter.toTextWithEscapeCodes(formattingSteps, escapeCodeDictionary)
	if escapeCodeDictionary == nil then escapeCodeDictionary = AnsiFormatter.DEFAULT_ESCAPE_CODES end
	local result = ""
	local state = {}

	for ftype, _ in pairs(escapeCodeDictionary) do
		if ftype ~= "reset" then
			state[ftype] = false
		end
	end

	local i = 1

	while i <= #formattingSteps do
		local step = formattingSteps[i]

		if string.match(step, "^start_") then
			local ftype = string.match(step, "^start_(.+)$")

			state[ftype] = true

			if escapeCodeDictionary[ftype] then
				result = result .. escapeCodeDictionary[ftype]
			end

		elseif string.match(step, "^end_") then
			local ftype = string.match(step, "^end_(.+)$")

			state[ftype] = false

			result = result .. escapeCodeDictionary.reset

			for activeFtype, isActive in pairs(state) do
				if isActive and escapeCodeDictionary[activeFtype] then
					result = result .. escapeCodeDictionary[activeFtype]
				end
			end

		elseif step == "write" then
			i = i + 1
			result = result .. formattingSteps[i]

		elseif step == "endl" then
			result = result .. "\n"
		end

		i = i + 1
	end

	return result
end

--- Demonstration / validation routine.
function AnsiFormatter.demo()
	local text =
		"I am bold and italic. " ..
		"Next I lost my boldness. " ..
		"In the end I stopped being bold and italic."

	local formattingRanges = {
		{
			type = "bold",
			start = 1,
			["end"] = 21
		},

		{
			type = "italic",
			start = 1,
			["end"] = 46
		}
	}

	print("=== ORIGINAL TEXT ===")
	print(text)
	print()

	print("=== FORMATTING RANGES ===")

	for i, range in ipairs(formattingRanges) do
		print(string.format(
			"%d: %s [%d-%d]",
			i,
			range.type,
			range.start,
			range["end"]
		))
	end

	print()

	print("=== VM INSTRUCTIONS ===")

	local program = AnsiFormatter.toAnsiFormattingSteps(
		{text},
		formattingRanges
	)

	for i, instr in ipairs(program) do
		print(i, instr)
	end

	print()

	print("=== ANSI OUTPUT ===")

	local result = AnsiFormatter.toTextWithEscapeCodes(
		program,
		AnsiFormatter.DEFAULT_ESCAPE_CODES
	)

	print(result)
	print()

	print("=== EXPECTED OUTPUT ===")

	local expected =
		"\27[1m\27[3mI am bold and italic." ..
		"\27[0m\27[3m Next I lost my boldness." ..
		"\27[0m In the end I stopped being bold and italic."

	print(expected)
	print()

	print("=== MATCH CHECK ===")
	print("Match:", result == expected)
end

AnsiFormatter.demo() -- REMOVE AFTER USE

return AnsiFormatter
