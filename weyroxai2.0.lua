-- WeyroxHub AI | Arayuzden API key girilen, cok saglayicili AI script asistani

local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local req = (syn and syn.request) or (http and http.request) or http_request or request
if not req then
	warn("[WeyroxHub] Executor request fonksiyonunu desteklemiyor"-- WeyroxHub AI | Arayuzden API key girilen, cok saglayicili AI script asistani

local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local req = (syn and syn.request) or (http and http.request) or http_request or request
if not req then
	warn("[WeyroxHub] Executor request fonksiyonunu desteklemiyor")
	return
end

local SYSTEM = [[Sen Roblox Luau uzmanisin. Kullanici bir executor'da calisacak istemci tarafi script ister.
Cevabinda tek bir ```lua kod blogu ver, altina en fazla 2 cumle Turkce aciklama yaz.
Kod LocalPlayer uzerinden calismali, loop'lar icin task.wait kullan, mumkunse kapatma/acma (toggle) ekle.]]

-- Saglayicilar (url/model alanlari arayuzden degistirilebilir)
local PROVIDERS = {
	{name = "Gemini", type = "gemini", url = "", model = "gemini-2.5-flash", needKey = true},
	{name = "OpenRouter", type = "openai", url = "https://openrouter.ai/api/v1/chat/completions", model = "meta-llama/llama-3.3-70b-instruct:free", needKey = true},
	{name = "OpenAI", type = "openai", url = "https://api.openai.com/v1/chat/completions", model = "gpt-4o-mini", needKey = true},
	{name = "Groq", type = "openai", url = "https://api.groq.com/openai/v1/chat/completions", model = "llama-3.3-70b-versatile", needKey = true},
	{name = "Ollama", type = "openai", url = "http://127.0.0.1:11434/v1/chat/completions", model = "llama3", needKey = false},
	{name = "Ozel", type = "openai", url = "", model = "", needKey = false},
}

-- Kayitli ayarlar
local FILE = "WeyroxHubAI.json"
local cfg = {provider = "Gemini", p = {}}
pcall(function()
	if isfile and isfile(FILE) then
		local d = HttpService:JSONDecode(readfile(FILE))
		if type(d) == "table" then cfg = d; cfg.p = cfg.p or {} end
	end
end)
local function saveCfg()
	pcall(function() if writefile then writefile(FILE, HttpService:JSONEncode(cfg)) end end)
end
local function curProv()
	for _, p in ipairs(PROVIDERS) do if p.name == cfg.provider then return p end end
	return PROVIDERS[1]
end
local function conf(p)
	cfg.p[p.name] = cfg.p[p.name] or {key = "", model = p.model, url = p.url}
	return cfg.p[p.name]
end

-- Tema
local BG = Color3.fromRGB(10, 18, 32)
local PANEL = Color3.fromRGB(18, 30, 50)
local ACCENT = Color3.fromRGB(0, 220, 190)
local TEXT = Color3.fromRGB(225, 235, 245)
local MUTED = Color3.fromRGB(130, 150, 175)
local RED = Color3.fromRGB(255, 100, 100)

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end

local guiParent = (gethui and gethui()) or game:GetService("CoreGui")
local okp = pcall(function() return guiParent.Name end)
if not okp then guiParent = Players.LocalPlayer:WaitForChild("PlayerGui") end

local old = guiParent:FindFirstChild("WeyroxHubAI")
if old then old:Destroy() end

local gui = new("ScreenGui", {Name = "WeyroxHubAI", ResetOnSpawn = false}, guiParent)
local win = new("Frame", {
	Size = UDim2.new(0, 360, 0, 420),
	Position = UDim2.new(0.5, -180, 0.5, -210),
	BackgroundColor3 = BG, BorderSizePixel = 0,
}, gui)
new("UICorner", {CornerRadius = UDim.new(0, 10)}, win)
new("UIStroke", {Color = ACCENT, Thickness = 1}, win)

local bar = new("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = PANEL, BorderSizePixel = 0}, win)
new("UICorner", {CornerRadius = UDim.new(0, 10)}, bar)
new("TextLabel", {
	Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 12, 0, 0),
	BackgroundTransparency = 1, Text = "WeyroxHub AI", TextColor3 = ACCENT,
	Font = Enum.Font.Code, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left,
}, bar)
local close = new("TextButton", {
	Size = UDim2.new(0, 36, 1, 0), Position = UDim2.new(1, -36, 0, 0),
	BackgroundTransparency = 1, Text = "X", TextColor3 = TEXT,
	Font = Enum.Font.Code, TextSize = 16,
}, bar)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Surukleme
do
	local dragging, startPos, startInput
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, startPos, startInput = true, win.Position, i.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startInput
			win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- Sohbet alani
local log = new("ScrollingFrame", {
	Size = UDim2.new(1, -16, 1, -150), Position = UDim2.new(0, 8, 0, 44),
	BackgroundColor3 = PANEL, BorderSizePixel = 0, ScrollBarThickness = 4,
	CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, win)
new("UICorner", {CornerRadius = UDim.new(0, 8)}, log)
new("UIListLayout", {Padding = UDim.new(0, 6)}, log)
new("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6)}, log)

-- Ayar paneli
local settings = new("Frame", {
	Size = log.Size, Position = log.Position,
	BackgroundColor3 = PANEL, BorderSizePixel = 0, Visible = false,
}, win)
new("UICorner", {CornerRadius = UDim.new(0, 8)}, settings)

local function field(y, placeholder)
	local t = new("TextBox", {
		Size = UDim2.new(1, -16, 0, 32), Position = UDim2.new(0, 8, 0, y),
		BackgroundColor3 = BG, BorderSizePixel = 0, Text = "", PlaceholderText = placeholder,
		PlaceholderColor3 = MUTED, TextColor3 = TEXT, Font = Enum.Font.Code, TextSize = 13,
		ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, settings)
	new("UICorner", {CornerRadius = UDim.new(0, 6)}, t)
	new("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, t)
	return t
end

local provBtn = new("TextButton", {
	Size = UDim2.new(1, -16, 0, 32), Position = UDim2.new(0, 8, 0, 8),
	BackgroundColor3 = BG, BorderSizePixel = 0, Text = "",
	TextColor3 = ACCENT, Font = Enum.Font.Code, TextSize = 14,
}, settings)
new("UICorner", {CornerRadius = UDim.new(0, 6)}, provBtn)
local urlBox = field(48, "API URL (OpenAI uyumlu / Ollama / ngrok)")
local keyBox = field(88, "API Key")
local modelBox = field(128, "Model adi")
local saveBtn = new("TextButton", {
	Size = UDim2.new(1, -16, 0, 34), Position = UDim2.new(0, 8, 0, 172),
	BackgroundColor3 = ACCENT, BorderSizePixel = 0, Text = "Kaydet",
	TextColor3 = BG, Font = Enum.Font.Code, TextSize = 14,
}, settings)
new("UICorner", {CornerRadius = UDim.new(0, 8)}, saveBtn)
new("TextLabel", {
	Size = UDim2.new(1, -16, 0, 50), Position = UDim2.new(0, 8, 0, 212),
	BackgroundTransparency = 1, TextColor3 = MUTED, Font = Enum.Font.Code, TextSize = 12,
	TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
	Text = "Gemini icin URL gerekmez. Ollama: key bos birakilabilir, Colab ngrok linkini URL'ye yaz (sonu /v1/chat/completions).",
}, settings)

local function loadFields()
	local p = curProv()
	local c = conf(p)
	provBtn.Text = "Saglayici: " .. p.name .. "  (degistir)"
	urlBox.Text = c.url or ""
	keyBox.Text = c.key or ""
	modelBox.Text = c.model or ""
end
local function storeFields()
	local c = conf(curProv())
	c.url, c.key, c.model = urlBox.Text, keyBox.Text, modelBox.Text
end

provBtn.MouseButton1Click:Connect(function()
	storeFields()
	local idx = 1
	for i, p in ipairs(PROVIDERS) do if p.name == cfg.provider then idx = i end end
	cfg.provider = PROVIDERS[idx % #PROVIDERS + 1].name
	loadFields()
end)

-- Alt kisim
local input = new("TextBox", {
	Size = UDim2.new(1, -16, 0, 36), Position = UDim2.new(1, -8, 1, -98),
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = PANEL, BorderSizePixel = 0, Text = "", PlaceholderText = "Ne istiyorsun? (orn: hiz 100 yap)",
	PlaceholderColor3 = MUTED, TextColor3 = TEXT, Font = Enum.Font.Code, TextSize = 14,
	ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
}, win)
new("UICorner", {CornerRadius = UDim.new(0, 8)}, input)
new("UIPadding", {PaddingLeft = UDim.new(0, 8)}, input)

local function button(text, x, w)
	local b = new("TextButton", {
		Size = UDim2.new(0, w, 0, 34), Position = UDim2.new(0, x, 1, -50),
		BackgroundColor3 = ACCENT, BorderSizePixel = 0, Text = text,
		TextColor3 = BG, Font = Enum.Font.Code, TextSize = 13,
	}, win)
	new("UICorner", {CornerRadius = UDim.new(0, 8)}, b)
	return b
end

local sendBtn = button("Gonder", 8, 80)
local runBtn = button("Calistir", 96, 80)
local autoBtn = button("Oto: KAPALI", 184, 100)
autoBtn.BackgroundColor3 = PANEL
autoBtn.TextColor3 = TEXT
local setBtn = button("Ayar", 292, 60)
setBtn.BackgroundColor3 = PANEL
setBtn.TextColor3 = ACCENT

local function addMsg(who, text, color)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Text = who .. ": " .. text, TextColor3 = color or TEXT,
		Font = Enum.Font.Code, TextSize = 13, TextWrapped = true, TextSelectable = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
	}, log)
	task.defer(function() log.CanvasPosition = Vector2.new(0, 1e6) end)
end

local function setSettingsOpen(open)
	settings.Visible = open
	log.Visible = not open
end
setBtn.MouseButton1Click:Connect(function() setSettingsOpen(not settings.Visible) end)
saveBtn.MouseButton1Click:Connect(function()
	storeFields()
	saveCfg()
	setSettingsOpen(false)
	addMsg("Sistem", "Kaydedildi: " .. cfg.provider .. " / " .. (conf(curProv()).model or ""), ACCENT)
end)

-- AI istegi
local history, lastCode, autoRun, busy = {}, nil, false, false

local function runCode(code)
	local fn, err = loadstring(code)
	if not fn then addMsg("Hata", tostring(err), RED) return end
	local s, e = pcall(fn)
	if s then addMsg("Sistem", "Script calistirildi", ACCENT)
	else addMsg("Hata", tostring(e), RED) end
end

local function askAI(prompt)
	local p = curProv()
	local c = conf(p)
	if p.needKey and (c.key or "") == "" then error("API key yok. Ayar'dan " .. p.name .. " key'ini gir.") end
	if (c.model or "") == "" then error("Model adi bos. Ayar'dan gir.") end

	table.insert(history, {role = "user", text = prompt})
	while #history > 10 do table.remove(history, 1) end

	local url, headers, body
	if p.type == "gemini" then
		local contents = {}
		for _, h in ipairs(history) do
			table.insert(contents, {role = h.role == "user" and "user" or "model", parts = {{text = h.text}}})
		end
		url = "https://generativelanguage.googleapis.com/v1beta/models/" .. c.model .. ":generateContent?key=" .. c.key
		headers = {["Content-Type"] = "application/json"}
		body = {systemInstruction = {parts = {{text = SYSTEM}}}, contents = contents}
	else
		if (c.url or "") == "" then error("URL bos. Ayar'dan gir.") end
		local messages = {{role = "system", content = SYSTEM}}
		for _, h in ipairs(history) do
			table.insert(messages, {role = h.role, content = h.text})
		end
		url = c.url
		headers = {["Content-Type"] = "application/json", ["ngrok-skip-browser-warning"] = "true"}
		if (c.key or "") ~= "" then headers["Authorization"] = "Bearer " .. c.key end
		body = {model = c.model, messages = messages, stream = false}
	end

	local res = req({Url = url, Method = "POST", Headers = headers, Body = HttpService:JSONEncode(body)})
	local okj, data = pcall(HttpService.JSONDecode, HttpService, res.Body)
	if not okj then error("Gecersiz cevap: " .. tostring(res.Body):sub(1, 200)) end

	local text
	if p.type == "gemini" then
		text = data.candidates and data.candidates[1] and data.candidates[1].content.parts[1].text
	else
		text = data.choices and data.choices[1] and data.choices[1].message.content
	end
	if not text then error(tostring(res.Body):sub(1, 300)) end
	table.insert(history, {role = "assistant", text = text})
	return text
end

local function send()
	if busy or input.Text == "" then return end
	busy = true
	local prompt = input.Text
	input.Text = ""
	setSettingsOpen(false)
	addMsg("Sen", prompt, MUTED)
	local ok2, text = pcall(askAI, prompt)
	if not ok2 then
		addMsg("Hata", tostring(text), RED)
	else
		addMsg("AI", text)
		local code = text:match("```lua\n(.-)```") or text:match("```\n?(.-)```")
		if code then
			lastCode = code
			if autoRun then runCode(code) end
		end
	end
	busy = false
end

sendBtn.MouseButton1Click:Connect(send)
input.FocusLost:Connect(function(enter) if enter then send() end end)
runBtn.MouseButton1Click:Connect(function()
	if lastCode then runCode(lastCode) else addMsg("Sistem", "Henuz kod yok", MUTED) end
end)
autoBtn.MouseButton1Click:Connect(function()
	autoRun = not autoRun
	autoBtn.Text = autoRun and "Oto: ACIK" or "Oto: KAPALI"
end)

loadFields()
addMsg("Sistem", "WeyroxHub AI hazir. Ayar'dan saglayici ve API key sec.", ACCENT)

	return
end

local SYSTEM = [[Sen Roblox Luau uzmanisin. Kullanici bir executor'da calisacak istemci tarafi script ister.
Cevabinda tek bir ```lua kod blogu ver, altina en fazla 2 cumle Turkce aciklama yaz.
Kod LocalPlayer uzerinden calismali, loop'lar icin task.wait kullan, mumkunse kapatma/acma (toggle) ekle.]]

-- Saglayicilar (url/model alanlari arayuzden degistirilebilir)
local PROVIDERS = {
	{name = "Gemini", type = "gemini", url = "", model = "gemini-2.5-flash", needKey = true},
	{name = "OpenRouter", type = "openai", url = "https://openrouter.ai/api/v1/chat/completions", model = "meta-llama/llama-3.3-70b-instruct:free", needKey = true},
	{name = "OpenAI", type = "openai", url = "https://api.openai.com/v1/chat/completions", model = "gpt-4o-mini", needKey = true},
	{name = "Groq", type = "openai", url = "https://api.groq.com/openai/v1/chat/completions", model = "llama-3.3-70b-versatile", needKey = true},
	{name = "Ollama", type = "openai", url = "http://127.0.0.1:11434/v1/chat/completions", model = "llama3", needKey = false},
	{name = "Ozel", type = "openai", url = "", model = "", needKey = false},
}

-- Kayitli ayarlar
local FILE = "WeyroxHubAI.json"
local cfg = {provider = "Gemini", p = {}}
pcall(function()
	if isfile and isfile(FILE) then
		local d = HttpService:JSONDecode(readfile(FILE))
		if type(d) == "table" then cfg = d; cfg.p = cfg.p or {} end
	end
end)
local function saveCfg()
	pcall(function() if writefile then writefile(FILE, HttpService:JSONEncode(cfg)) end end)
end
local function curProv()
	for _, p in ipairs(PROVIDERS) do if p.name == cfg.provider then return p end end
	return PROVIDERS[1]
end
local function conf(p)
	cfg.p[p.name] = cfg.p[p.name] or {key = "", model = p.model, url = p.url}
	return cfg.p[p.name]
end

-- Tema
local BG = Color3.fromRGB(10, 18, 32)
local PANEL = Color3.fromRGB(18, 30, 50)
local ACCENT = Color3.fromRGB(0, 220, 190)
local TEXT = Color3.fromRGB(225, 235, 245)
local MUTED = Color3.fromRGB(130, 150, 175)
local RED = Color3.fromRGB(255, 100, 100)

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end

local guiParent = (gethui and gethui()) or game:GetService("CoreGui")
local okp = pcall(function() return guiParent.Name end)
if not okp then guiParent = Players.LocalPlayer:WaitForChild("PlayerGui") end

local old = guiParent:FindFirstChild("WeyroxHubAI")
if old then old:Destroy() end

local gui = new("ScreenGui", {Name = "WeyroxHubAI", ResetOnSpawn = false}, guiParent)
local win = new("Frame", {
	Size = UDim2.new(0, 360, 0, 420),
	Position = UDim2.new(0.5, -180, 0.5, -210),
	BackgroundColor3 = BG, BorderSizePixel = 0,
}, gui)
new("UICorner", {CornerRadius = UDim.new(0, 10)}, win)
new("UIStroke", {Color = ACCENT, Thickness = 1}, win)

local bar = new("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = PANEL, BorderSizePixel = 0}, win)
new("UICorner", {CornerRadius = UDim.new(0, 10)}, bar)
new("TextLabel", {
	Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 12, 0, 0),
	BackgroundTransparency = 1, Text = "WeyroxHub AI", TextColor3 = ACCENT,
	Font = Enum.Font.Code, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left,
}, bar)
local close = new("TextButton", {
	Size = UDim2.new(0, 36, 1, 0), Position = UDim2.new(1, -36, 0, 0),
	BackgroundTransparency = 1, Text = "X", TextColor3 = TEXT,
	Font = Enum.Font.Code, TextSize = 16,
}, bar)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Surukleme
do
	local dragging, startPos, startInput
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, startPos, startInput = true, win.Position, i.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startInput
			win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- Sohbet alani
local log = new("ScrollingFrame", {
	Size = UDim2.new(1, -16, 1, -150), Position = UDim2.new(0, 8, 0, 44),
	BackgroundColor3 = PANEL, BorderSizePixel = 0, ScrollBarThickness = 4,
	CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, win)
new("UICorner", {CornerRadius = UDim.new(0, 8)}, log)
new("UIListLayout", {Padding = UDim.new(0, 6)}, log)
new("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6)}, log)

-- Ayar paneli
local settings = new("Frame", {
	Size = log.Size, Position = log.Position,
	BackgroundColor3 = PANEL, BorderSizePixel = 0, Visible = false,
}, win)
new("UICorner", {CornerRadius = UDim.new(0, 8)}, settings)

local function field(y, placeholder)
	local t = new("TextBox", {
		Size = UDim2.new(1, -16, 0, 32), Position = UDim2.new(0, 8, 0, y),
		BackgroundColor3 = BG, BorderSizePixel = 0, Text = "", PlaceholderText = placeholder,
		PlaceholderColor3 = MUTED, TextColor3 = TEXT, Font = Enum.Font.Code, TextSize = 13,
		ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, settings)
	new("UICorner", {CornerRadius = UDim.new(0, 6)}, t)
	new("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, t)
	return t
end

local provBtn = new("TextButton", {
	Size = UDim2.new(1, -16, 0, 32), Position = UDim2.new(0, 8, 0, 8),
	BackgroundColor3 = BG, BorderSizePixel = 0, Text = "",
	TextColor3 = ACCENT, Font = Enum.Font.Code, TextSize = 14,
}, settings)
new("UICorner", {CornerRadius = UDim.new(0, 6)}, provBtn)
local urlBox = field(48, "API URL (OpenAI uyumlu / Ollama / ngrok)")
local keyBox = field(88, "API Key")
local modelBox = field(128, "Model adi")
modelBox.Size = UDim2.new(1, -108, 0, 32)
local fetchBtn = new("TextButton", {
	Size = UDim2.new(0, 84, 0, 32), Position = UDim2.new(1, -92, 0, 128),
	BackgroundColor3 = ACCENT, BorderSizePixel = 0, Text = "Modelleri Cek",
	TextColor3 = BG, Font = Enum.Font.Code, TextSize = 11, TextWrapped = true,
}, settings)
new("UICorner", {CornerRadius = UDim.new(0, 6)}, fetchBtn)
local saveBtn = new("TextButton", {
	Size = UDim2.new(1, -16, 0, 34), Position = UDim2.new(0, 8, 0, 172),
	BackgroundColor3 = ACCENT, BorderSizePixel = 0, Text = "Kaydet",
	TextColor3 = BG, Font = Enum.Font.Code, TextSize = 14,
}, settings)
new("UICorner", {CornerRadius = UDim.new(0, 8)}, saveBtn)
new("TextLabel", {
	Size = UDim2.new(1, -16, 0, 50), Position = UDim2.new(0, 8, 0, 212),
	BackgroundTransparency = 1, TextColor3 = MUTED, Font = Enum.Font.Code, TextSize = 12,
	TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
	Text = "Gemini icin URL gerekmez. Ollama: key bos birakilabilir, Colab ngrok linkini URL'ye yaz (sonu /v1/chat/completions).",
}, settings)

-- Model secici
local picker = new("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = PANEL, BorderSizePixel = 0, Visible = false}, settings)
new("UICorner", {CornerRadius = UDim.new(0, 8)}, picker)
local pickTitle = new("TextButton", {
	Size = UDim2.new(1, -16, 0, 32), Position = UDim2.new(0, 8, 0, 8),
	BackgroundColor3 = BG, BorderSizePixel = 0, Text = "Model sec  (kapat)",
	TextColor3 = ACCENT, Font = Enum.Font.Code, TextSize = 14,
}, picker)
new("UICorner", {CornerRadius = UDim.new(0, 6)}, pickTitle)
pickTitle.MouseButton1Click:Connect(function() picker.Visible = false end)
local pickList = new("ScrollingFrame", {
	Size = UDim2.new(1, -16, 1, -52), Position = UDim2.new(0, 8, 0, 44),
	BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
	CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, picker)
new("UIListLayout", {Padding = UDim.new(0, 4)}, pickList)

local function pickClear()
	for _, c in ipairs(pickList:GetChildren()) do
		if c:IsA("GuiObject") then c:Destroy() end
	end
end
local function pickNote(text, color)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Text = text, TextColor3 = color or MUTED,
		Font = Enum.Font.Code, TextSize = 12, TextWrapped = true, TextSelectable = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
	}, pickList)
end

local function loadFields()
	local p = curProv()
	local c = conf(p)
	provBtn.Text = "Saglayici: " .. p.name .. "  (degistir)"
	urlBox.Text = c.url or ""
	keyBox.Text = c.key or ""
	modelBox.Text = c.model or ""
end
local function storeFields()
	local c = conf(curProv())
	c.url, c.key, c.model = urlBox.Text, keyBox.Text, modelBox.Text
end

local fetching = false
local function fetchModels()
	if fetching then return end
	fetching = true
	storeFields()
	local p = curProv()
	local c = conf(p)
	picker.Visible = true
	pickClear()
	pickNote("Yukleniyor...", MUTED)

	local ok, res = pcall(function()
		local url
		local headers = {["ngrok-skip-browser-warning"] = "true"}
		if p.type == "gemini" then
			if (c.key or "") == "" then error("Once API key gir.", 0) end
			url = "https://generativelanguage.googleapis.com/v1beta/models?pageSize=1000&key=" .. c.key
		else
			local u = c.url or ""
			if u == "" then error("Once URL gir.", 0) end
			url = (u:gsub("/chat/completions/?$", "/models"))
			if url == u then error("URL /chat/completions ile bitmeli.", 0) end
			if (c.key or "") ~= "" then headers["Authorization"] = "Bearer " .. c.key end
		end

		local r = req({Url = url, Method = "GET", Headers = headers})
		local okj, data = pcall(HttpService.JSONDecode, HttpService, r.Body)
		if not okj or type(data) ~= "table" then error("Gecersiz cevap: " .. tostring(r.Body):sub(1, 200), 0) end

		local names = {}
		if p.type == "gemini" then
			for _, m in ipairs(data.models or {}) do
				local can = false
				for _, meth in ipairs(m.supportedGenerationMethods or {}) do
					if meth == "generateContent" then can = true end
				end
				if can then table.insert(names, (m.name:gsub("^models/", ""))) end
			end
		else
			for _, m in ipairs(data.data or data.models or {}) do
				table.insert(names, m.id or m.name)
			end
		end
		if #names == 0 then error(tostring(r.Body):sub(1, 300), 0) end
		table.sort(names)
		return names
	end)

	pickClear()
	if not ok then
		pickNote("Hata: " .. tostring(res), RED)
	else
		for _, name in ipairs(res) do
			local b = new("TextButton", {
				Size = UDim2.new(1, -6, 0, 30), BackgroundColor3 = BG, BorderSizePixel = 0,
				Text = name, TextColor3 = TEXT, Font = Enum.Font.Code, TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
			}, pickList)
			new("UICorner", {CornerRadius = UDim.new(0, 6)}, b)
			new("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, b)
			b.MouseButton1Click:Connect(function()
				modelBox.Text = name
				picker.Visible = false
			end)
		end
	end
	fetching = false
end
fetchBtn.MouseButton1Click:Connect(fetchModels)

provBtn.MouseButton1Click:Connect(function()
	storeFields()
	local idx = 1
	for i, p in ipairs(PROVIDERS) do if p.name == cfg.provider then idx = i end end
	cfg.provider = PROVIDERS[idx % #PROVIDERS + 1].name
	loadFields()
end)

-- Alt kisim
local input = new("TextBox", {
	Size = UDim2.new(1, -16, 0, 36), Position = UDim2.new(1, -8, 1, -98),
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = PANEL, BorderSizePixel = 0, Text = "", PlaceholderText = "Ne istiyorsun? (orn: hiz 100 yap)",
	PlaceholderColor3 = MUTED, TextColor3 = TEXT, Font = Enum.Font.Code, TextSize = 14,
	ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
}, win)
new("UICorner", {CornerRadius = UDim.new(0, 8)}, input)
new("UIPadding", {PaddingLeft = UDim.new(0, 8)}, input)

local function button(text, x, w)
	local b = new("TextButton", {
		Size = UDim2.new(0, w, 0, 34), Position = UDim2.new(0, x, 1, -50),
		BackgroundColor3 = ACCENT, BorderSizePixel = 0, Text = text,
		TextColor3 = BG, Font = Enum.Font.Code, TextSize = 13,
	}, win)
	new("UICorner", {CornerRadius = UDim.new(0, 8)}, b)
	return b
end

local sendBtn = button("Gonder", 8, 80)
local runBtn = button("Calistir", 96, 80)
local autoBtn = button("Oto: KAPALI", 184, 100)
autoBtn.BackgroundColor3 = PANEL
autoBtn.TextColor3 = TEXT
local setBtn = button("Ayar", 292, 60)
setBtn.BackgroundColor3 = PANEL
setBtn.TextColor3 = ACCENT

local function addMsg(who, text, color)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Text = who .. ": " .. text, TextColor3 = color or TEXT,
		Font = Enum.Font.Code, TextSize = 13, TextWrapped = true, TextSelectable = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
	}, log)
	task.defer(function() log.CanvasPosition = Vector2.new(0, 1e6) end)
end

local function setSettingsOpen(open)
	settings.Visible = open
	log.Visible = not open
	picker.Visible = false
end
setBtn.MouseButton1Click:Connect(function() setSettingsOpen(not settings.Visible) end)
saveBtn.MouseButton1Click:Connect(function()
	storeFields()
	saveCfg()
	setSettingsOpen(false)
	addMsg("Sistem", "Kaydedildi: " .. cfg.provider .. " / " .. (conf(curProv()).model or ""), ACCENT)
end)

-- AI istegi
local history, lastCode, autoRun, busy = {}, nil, false, false

local function runCode(code)
	local fn, err = loadstring(code)
	if not fn then addMsg("Hata", tostring(err), RED) return end
	local s, e = pcall(fn)
	if s then addMsg("Sistem", "Script calistirildi", ACCENT)
	else addMsg("Hata", tostring(e), RED) end
end

local function askAI(prompt)
	local p = curProv()
	local c = conf(p)
	if p.needKey and (c.key or "") == "" then error("API key yok. Ayar'dan " .. p.name .. " key'ini gir.") end
	if (c.model or "") == "" then error("Model adi bos. Ayar'dan gir.") end

	table.insert(history, {role = "user", text = prompt})
	while #history > 10 do table.remove(history, 1) end

	local url, headers, body
	if p.type == "gemini" then
		local contents = {}
		for _, h in ipairs(history) do
			table.insert(contents, {role = h.role == "user" and "user" or "model", parts = {{text = h.text}}})
		end
		url = "https://generativelanguage.googleapis.com/v1beta/models/" .. c.model .. ":generateContent?key=" .. c.key
		headers = {["Content-Type"] = "application/json"}
		body = {systemInstruction = {parts = {{text = SYSTEM}}}, contents = contents}
	else
		if (c.url or "") == "" then error("URL bos. Ayar'dan gir.") end
		local messages = {{role = "system", content = SYSTEM}}
		for _, h in ipairs(history) do
			table.insert(messages, {role = h.role, content = h.text})
		end
		url = c.url
		headers = {["Content-Type"] = "application/json", ["ngrok-skip-browser-warning"] = "true"}
		if (c.key or "") ~= "" then headers["Authorization"] = "Bearer " .. c.key end
		body = {model = c.model, messages = messages, stream = false}
	end

	local res = req({Url = url, Method = "POST", Headers = headers, Body = HttpService:JSONEncode(body)})
	local okj, data = pcall(HttpService.JSONDecode, HttpService, res.Body)
	if not okj then error("Gecersiz cevap: " .. tostring(res.Body):sub(1, 200)) end

	local text
	if p.type == "gemini" then
		text = data.candidates and data.candidates[1] and data.candidates[1].content.parts[1].text
	else
		text = data.choices and data.choices[1] and data.choices[1].message.content
	end
	if not text then error(tostring(res.Body):sub(1, 300)) end
	table.insert(history, {role = "assistant", text = text})
	return text
end

local function send()
	if busy or input.Text == "" then return end
	busy = true
	local prompt = input.Text
	input.Text = ""
	setSettingsOpen(false)
	addMsg("Sen", prompt, MUTED)
	local ok2, text = pcall(askAI, prompt)
	if not ok2 then
		addMsg("Hata", tostring(text), RED)
	else
		addMsg("AI", text)
		local code = text:match("```lua\n(.-)```") or text:match("```\n?(.-)```")
		if code then
			lastCode = code
			if autoRun then runCode(code) end
		end
	end
	busy = false
end

sendBtn.MouseButton1Click:Connect(send)
input.FocusLost:Connect(function(enter) if enter then send() end end)
runBtn.MouseButton1Click:Connect(function()
	if lastCode then runCode(lastCode) else addMsg("Sistem", "Henuz kod yok", MUTED) end
end)
autoBtn.MouseButton1Click:Connect(function()
	autoRun = not autoRun
	autoBtn.Text = autoRun and "Oto: ACIK" or "Oto: KAPALI"
end)

loadFields()
addMsg("Sistem", "WeyroxHub AI hazir. Ayar'dan saglayici ve API key sec.", ACCENT)
