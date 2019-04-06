require("types/class")

Dialog = Class:new()

function Dialog:new(d)
	local dialog = self:__new(d)
	dialog.stack = {}
	return dialog
end

function Dialog:is_empty_phrase(phrase)
	local s = 1
	if (type(phrase[1]) == "string") then
		s = 3
	end
	for i = s, #phrase do
		if (self:is_enabled_phrase(phrase, i)) then
			return false
		end
	end
	return true
end

function Dialog:is_enabled_phrase(phrase, i)
	return not (phrase[i].enable == false or (phrase.used and (phrase.used[i]
			or (phrase.only and #phrase.used ~= 0 and phrase[i].always ~= true)))
			or (phrase[i].cond and phrase[i].cond(self) == false))
end

function Dialog:simple_find(phrase, n)
	local s = 1
	if (type(phrase[1]) == "string") then
		s = 3
	end
	for i = s, #phrase do
		if (not self:is_enabled_phrase(phrase, i)) then
			n = n + 1
		end
		if (n == 1) then
			return phrase[i], i
		end
		n = n - 1
	end
	return nil, nil
end

function Dialog:find(n)
	if (#self.stack == 0) then
		return self:simple_find(self.phr, n)
	else
		return self:simple_find(self.stack[#self.stack], n)
	end
end

function Dialog:push(n)
	local phrase, real_n = self:find(n)
	local cur_phr = self.stack[#self.stack] or self.phr
	self.stack[#self.stack + 1] = phrase
	if (real_n and cur_phr and phrase and phrase.always ~= true) then
		if (not cur_phr.used) then
			cur_phr.used = {}
		end
		cur_phr.used[real_n] = true
	end
end

function Dialog:pop()
	self.stack[#self.stack] = nil
end

function Dialog:get_text()
	local phr = self.stack[#self.stack]
	if (#self.stack == 0) then
		if (type(self.enter) == "function") then
			return self.enter(self)
		else 
			return self.enter
		end
	else
		if (self:is_empty_phrase(phr)) then
			if (phr.onempty) then
				return phr.onempty(self)
			end
		end
		local first, second
		if (type(phr[1]) == "function") then
			first = phr[1](self)
		else
			first = phr[1]
		end
		if (type(phr[2]) == "function") then
			second = phr[2](self)
		else
			second = phr[2]
		end
		return first, second
	end
end

function Dialog:peek()
	if (#self.stack == 0) then
		return self.phr, 1
	else
		return self.stack[#self.stack], 3
	end
end

function Dialog:get_answers()
	local phr, n = self:peek()
	local res = {}
	for i = n, #phr do
		if (self:is_enabled_phrase(phr, i)) then
			if (type(phr[i][1]) == "function") then
				res[#res + 1] = phr[i][1](self)
			else
				res[#res + 1] = phr[i][1]
			end
		end
	end
	return res
end

function dlg(d)
	return Dialog:new(d)
end

D = dlg {
	enter = "Start Dialog",
	phr = {
		{cond = function() return 2 + 2 == 4 end, "Who are you?", "I'm CATMAN!"},
		{enable = false, "Who are you?", "I'm FISHMAN!"},
		{"Who are you?", "I'm FROGMAN!",
			{"Really?!", function(self) return "YEZZ" .. " JEZZZ" end},
			onempty = function(self)
				self:pop()
				return "BYE MAN *vanish in air*"
			end
		},
	}
}