

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Luna = {}
Luna.__index = Luna

local Tab = {}
Tab.__index = Tab

-- Make frame draggable
local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Luna:CreateWindow(config)
    local Window = {}
    Window.Tabs = {}
    Window.SaveConfig = config.SaveConfig or false
    Window.ConfigFolder = config.ConfigFolder or "LunaConfig"
    Window.ConfigData = {}
    Window.Elements = {}
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "LunaHubGUI"
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 520, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
    mainFrame.AnchorPoint = Vector2.new(0, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    mainFrame.Parent = gui
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Color3.fromRGB(0, 255, 255)
    mainStroke.Thickness = 2
    
    MakeDraggable(mainFrame)
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 350, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = (config.Title or "Luna Hub") .. " | " .. (config.Subtitle or "")
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local gradient = Instance.new("UIGradient", title)
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,255,255))
    }
    
    task.spawn(function()
        while title.Parent do
            for i = 0, 360 do
                if not title.Parent then break end
                gradient.Rotation = i
                task.wait(0.02)
            end
        end
    end)
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    minimizeBtn.Text = "-"
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 20
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeBtn.Parent = titleBar
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    
    local logo = nil
    if config.Logo then
        logo = Instance.new("ImageButton")
        logo.Name = "LunaLogo"
        logo.Parent = gui
        logo.Size = UDim2.new(0, 50, 0, 50)
        logo.Position = UDim2.new(1, -80, 0.2, 0)
        logo.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        logo.BorderSizePixel = 0
        logo.Visible = false
        logo.Active = true
        logo.Image = config.Logo
        logo.ScaleType = Enum.ScaleType.Fit
        Instance.new("UICorner", logo).CornerRadius = UDim.new(0.2, 0)
        
        local logoStroke = Instance.new("UIStroke", logo)
        logoStroke.Color = Color3.fromRGB(0, 255, 255)
        logoStroke.Thickness = 3
        
        MakeDraggable(logo)
        
        logo.MouseButton1Click:Connect(function()
            logo.Visible = false
            mainFrame.Visible = true
        end)
    end
    
    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        if logo then
            logo.Visible = true
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)
    
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(0, 130, 1, -50)
    tabContainer.Position = UDim2.new(0, 5, 0, 45)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)
    
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -145, 1, -50)
    contentContainer.Position = UDim2.new(0, 140, 0, 45)
    contentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame
    Instance.new("UICorner", contentContainer).CornerRadius = UDim.new(0, 10)
    
    Window.gui = gui
    Window.mainFrame = mainFrame
    Window.logo = logo
    Window.tabContainer = tabContainer
    Window.contentContainer = contentContainer

    function Window:SaveConfigFile()
        if not self.SaveConfig then return end
        local success, err = pcall(function()
            if not isfolder(self.ConfigFolder) then
                makefolder(self.ConfigFolder)
            end
            writefile(self.ConfigFolder .. "/config.json", HttpService:JSONEncode(self.ConfigData))
        end)
        if not success then
            warn("Failed to save config:", err)
        end
    end
    
    function Window:LoadConfigFile()
        if not self.SaveConfig then return end
        local success, result = pcall(function()
            if isfile(self.ConfigFolder .. "/config.json") then
                return HttpService:JSONDecode(readfile(self.ConfigFolder .. "/config.json"))
            end
        end)
        if success and result then
            self.ConfigData = result
            for key, value in pairs(result) do
                if self.Elements[key] then
                    self.Elements[key]:Set(value, true)
                end
            end
            return result
        end
        return nil
    end
    
    function Window:Destroy()
        if self.SaveConfig then
            self:SaveConfigFile()
        end
        gui:Destroy()
    end

    function Window:CreateTab(name, icon)
        local NewTab = setmetatable({}, Tab)
        NewTab.Name = name
        NewTab.Elements = {}
        
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, 0, 0, 45)
        tabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        tabBtn.Text = ""
        tabBtn.BorderSizePixel = 0
        tabBtn.Parent = tabContainer
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)
        
        local iconImage = Instance.new("ImageLabel")
        iconImage.Size = UDim2.new(0, 20, 0, 20)
        iconImage.Position = UDim2.new(0, 10, 0.5, 0)
        iconImage.AnchorPoint = Vector2.new(0, 0.5)
        iconImage.BackgroundTransparency = 1
        iconImage.Image = icon or ""
        iconImage.ImageColor3 = Color3.fromRGB(200, 200, 200)
        iconImage.Parent = tabBtn
        
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, -40, 1, 0)
        tabLabel.Position = UDim2.new(0, 35, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = name
        tabLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabLabel.TextSize = 14
        tabLabel.Font = Enum.Font.GothamBold
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabBtn
        
        local tabStroke = Instance.new("UIStroke", tabBtn)
        tabStroke.Color = Color3.fromRGB(50, 50, 50)
        tabStroke.Thickness = 1
        
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, -10, 1, -10)
        scrollFrame.Position = UDim2.new(0, 5, 0, 5)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.ScrollBarThickness = 4
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.Visible = false
        scrollFrame.Parent = contentContainer
        
        local contentLayout = Instance.new("UIListLayout", scrollFrame)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 6)
        contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        task.spawn(function()
            while scrollFrame.Parent do
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
                task.wait(0.1)
            end
        end)
        
        NewTab.scrollFrame = scrollFrame
        NewTab.tabBtn = tabBtn
        NewTab.iconImage = iconImage
        NewTab.tabLabel = tabLabel
        NewTab.tabStroke = tabStroke
       
        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.scrollFrame.Visible = false
                TweenService:Create(t.tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
                TweenService:Create(t.tabStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 50)}):Play()
                t.iconImage.ImageColor3 = Color3.fromRGB(200, 200, 200)
                t.tabLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            
            scrollFrame.Visible = true
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 150, 200)}):Play()
            TweenService:Create(tabStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 255, 255)}):Play()
            iconImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
            tabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
        
        table.insert(Window.Tabs, NewTab)
        
        if #Window.Tabs == 1 then
            tabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
            tabStroke.Color = Color3.fromRGB(0, 255, 255)
            iconImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
            tabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            scrollFrame.Visible = true
        end
        
        return NewTab
    end
    
    if Window.SaveConfig then
        task.wait(0.3)
        Window:LoadConfigFile()
    end
    
    return Window
end

function Tab:CreateSection(text)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(0.95, 0, 0, 30)
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Parent = self.scrollFrame
    
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Size = UDim2.new(1, 0, 1, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = "── " .. text .. " ──"
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextSize = 14
    sectionLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    sectionLabel.Parent = sectionFrame
    
    return sectionFrame
end

function Tab:CreateToggle(config)
    local Toggle = {}
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0.95, 0, 0, 38)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = self.scrollFrame
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", toggleFrame)
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Thickness = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Toggle"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 50, 0, 24)
    switchBg.Position = UDim2.new(1, -60, 0.5, 0)
    switchBg.AnchorPoint = Vector2.new(0, 0.5)
    switchBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    switchBg.BorderSizePixel = 0
    switchBg.Parent = toggleFrame
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

    local switchBtn = Instance.new("TextButton")
    switchBtn.Size = UDim2.new(0, 20, 0, 20)
    switchBtn.Position = UDim2.new(0, 2, 0.5, 0)
    switchBtn.AnchorPoint = Vector2.new(0, 0.5)
    switchBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    switchBtn.Text = ""
    switchBtn.BorderSizePixel = 0
    switchBtn.Parent = switchBg
    Instance.new("UICorner", switchBtn).CornerRadius = UDim.new(1, 0)

    local isOn = config.Default or false
    
    function Toggle:Set(value, skipCallback)
        isOn = value
        if isOn then
            TweenService:Create(switchBtn, TweenInfo.new(0.2), {Position = UDim2.new(1, -22, 0.5, 0)}):Play()
            TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 0)}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 255, 0)}):Play()
        else
            TweenService:Create(switchBtn, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, 0)}):Play()
            TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 50)}):Play()
        end
        
        if not skipCallback and config.Callback then
            config.Callback(isOn)
        end
    end

    switchBtn.MouseButton1Click:Connect(function()
        Toggle:Set(not isOn)
    end)

    Toggle:Set(isOn, true)
    table.insert(self.Elements, Toggle)
    return Toggle
end

function Tab:CreateButton(config)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(0.95, 0, 0, 38)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Parent = self.scrollFrame
    Instance.new("UICorner", buttonFrame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", buttonFrame)
    stroke.Color = Color3.fromRGB(0, 200, 255)
    stroke.Thickness = 2

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = config.Name or "Button"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = buttonFrame

    button.MouseButton1Click:Connect(function()
        TweenService:Create(buttonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 150, 200)}):Play()
        task.wait(0.1)
        TweenService:Create(buttonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
        
        if config.Callback then
            config.Callback()
        end
    end)

    return buttonFrame
end

function Tab:CreateSlider(config)
    local Slider = {}
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.95, 0, 0, 52)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = self.scrollFrame
    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", sliderFrame)
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Thickness = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Slider"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.25, 0, 0, 18)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 6)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(config.Default or config.Min)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 12
    valueLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.9, 0, 0, 6)
    sliderBg.Position = UDim2.new(0.05, 0, 1, -14)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = sliderFrame
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(0, 14, 0, 14)
    sliderBtn.Position = UDim2.new(0, 0, 0.5, 0)
    sliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderBtn.Text = ""
    sliderBtn.BorderSizePixel = 0
    sliderBtn.Parent = sliderBg
    Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(1, 0)

    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local dragging = false
    
    local function updateSlider(inputPos)
        local relativePos = math.clamp((inputPos - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * relativePos)
        
        sliderBtn.Position = UDim2.new(relativePos, 0, 0.5, 0)
        sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
        valueLabel.Text = tostring(value)
        
        if config.Callback then
            config.Callback(value)
        end
    end
    
    function Slider:Set(value, skipCallback)
        local relativePos = (value - min) / (max - min)
        sliderBtn.Position = UDim2.new(relativePos, 0, 0.5, 0)
        sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
        valueLabel.Text = tostring(value)
        
        if not skipCallback and config.Callback then
            config.Callback(value)
        end
    end
    
    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    sliderBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end)

    Slider:Set(default, true)
    table.insert(self.Elements, Slider)
    return Slider
end

function Tab:CreateDropdown(config)
    local Dropdown = {}
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.95, 0, 0, 38)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.BorderSizePixel = 0
    container.Parent = self.scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", container)
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Thickness = 1
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 1, -10)
    button.Position = UDim2.new(0, 10, 0, 5)
    button.BackgroundTransparency = 1
    button.Text = (config.Name or "Dropdown") .. ": " .. (config.Default or config.Options[1])
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.TextSize = 12
    button.Font = Enum.Font.Gotham
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Parent = container
    
    local currentIndex = 1
    local options = config.Options or {"Option 1", "Option 2"}
    
    for i, opt in ipairs(options) do
        if opt == config.Default then
            currentIndex = i
            break
        end
    end
    
    function Dropdown:Set(value, skipCallback)
        for i, opt in ipairs(options) do
            if opt == value then
                currentIndex = i
                button.Text = (config.Name or "Dropdown") .. ": " .. value
                
                if not skipCallback and config.Callback then
                    config.Callback(value)
                end
                break
            end
        end
    end
    
    button.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        local selectedValue = options[currentIndex]
        button.Text = (config.Name or "Dropdown") .. ": " .. selectedValue
        
        if config.Callback then
            config.Callback(selectedValue)
        end
    end)
    
    table.insert(self.Elements, Dropdown)
    return Dropdown
end

function Tab:CreateMultiDropdown(config)
    local MultiDropdown = {}
    local selectedItems = {}
    
    if config.Default then
        for _, item in ipairs(config.Default) do
            selectedItems[item] = true
        end
    end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.95, 0, 0, 38)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.BorderSizePixel = 0
    container.Parent = self.scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", container)
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Thickness = 1
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 1, -10)
    button.Position = UDim2.new(0, 10, 0, 5)
    button.BackgroundTransparency = 1
    button.Text = (config.Name or "Multi Select") .. ": ..."
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.TextSize = 12
    button.Font = Enum.Font.Gotham
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Parent = container
    
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Size = UDim2.new(1, 0, 0, 0)
    dropdownContainer.Position = UDim2.new(0, 0, 1, 5)
    dropdownContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    dropdownContainer.BorderSizePixel = 0
    dropdownContainer.Visible = false
    dropdownContainer.Parent = container
    dropdownContainer.ZIndex = 10
    Instance.new("UICorner", dropdownContainer).CornerRadius = UDim.new(0, 8)
    
    local dropdownStroke = Instance.new("UIStroke", dropdownContainer)
    dropdownStroke.Color = Color3.fromRGB(0, 255, 255)
    dropdownStroke.Thickness = 2
    
    local optionLayout = Instance.new("UIListLayout", dropdownContainer)
    optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionLayout.Padding = UDim.new(0, 2)
    
    local function updateDisplay()
        local selected = {}
        for item, isSelected in pairs(selectedItems) do
            if isSelected then
                table.insert(selected, item)
            end
        end
        
        if #selected == 0 then
            button.Text = (config.Name or "Multi Select") .. ": None"
        else
            button.Text = (config.Name or "Multi Select") .. ": " .. table.concat(selected, ", ")
        end
        
        if config.Callback then
            config.Callback(selected)
        end
    end
    
    for _, option in ipairs(config.Options or {}) do
        local optionFrame = Instance.new("Frame")
        optionFrame.Size = UDim2.new(1, -10, 0, 28)
        optionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        optionFrame.BorderSizePixel = 0
        optionFrame.Parent = dropdownContainer
        Instance.new("UICorner", optionFrame).CornerRadius = UDim.new(0, 6)
        
        local optionLabel = Instance.new("TextLabel")
        optionLabel.Size = UDim2.new(0.8, 0, 1, 0)
        optionLabel.Position = UDim2.new(0, 10, 0, 0)
        optionLabel.BackgroundTransparency = 1
        optionLabel.Text = option
        optionLabel.Font = Enum.Font.Gotham
        optionLabel.TextSize = 11
        optionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        optionLabel.TextXAlignment = Enum.TextXAlignment.Left
        optionLabel.Parent = optionFrame
        
        local checkmark = Instance.new("TextLabel")
        checkmark.Size = UDim2.new(0, 20, 0, 20)
        checkmark.Position = UDim2.new(1, -25, 0.5, 0)
        checkmark.AnchorPoint = Vector2.new(0.5, 0.5)
        checkmark.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        checkmark.Text = selectedItems[option] and "✓" or ""
        checkmark.Font = Enum.Font.GothamBold
        checkmark.TextSize = 14
        checkmark.TextColor3 = Color3.fromRGB(0, 255, 0)
        checkmark.BorderSizePixel = 0
        checkmark.Parent = optionFrame
        Instance.new("UICorner", checkmark).CornerRadius = UDim.new(0, 4)
        
        if selectedItems[option] then
            checkmark.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        end
        
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(1, 0, 1, 0)
        optionBtn.BackgroundTransparency = 1
        optionBtn.Text = ""
        optionBtn.Parent = optionFrame
        
        optionBtn.MouseButton1Click:Connect(function()
            selectedItems[option] = not selectedItems[option]
            
            if selectedItems[option] then
                checkmark.Text = "✓"
                checkmark.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            else
                checkmark.Text = ""
                checkmark.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
            
            updateDisplay()
        end)
    end
    
    button.MouseButton1Click:Connect(function()
        dropdownContainer.Visible = not dropdownContainer.Visible
        
        if dropdownContainer.Visible then
            local optionCount = #(config.Options or {})
            dropdownContainer.Size = UDim2.new(1, 0, 0, (optionCount * 30) + 10)
            container.Size = UDim2.new(0.95, 0, 0, 38 + (optionCount * 30) + 15)
        else
            container.Size = UDim2.new(0.95, 0, 0, 38)
        end
    end)
    
    function MultiDropdown:Set(items, skipCallback)
        selectedItems = {}
        for _, item in ipairs(items) do
            selectedItems[item] = true
        end
        
        for _, child in ipairs(dropdownContainer:GetChildren()) do
            if child:IsA("Frame") then
                local checkmark = child:FindFirstChild("TextLabel")
                local label = child:FindFirstChildOfClass("TextLabel")
                if checkmark and label then
                    local optionText = label.Text
                    if selectedItems[optionText] then
                        checkmark.Text = "✓"
                        checkmark.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                    else
                        checkmark.Text = ""
                        checkmark.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    end
                end
            end
        end
        
        if not skipCallback then
            updateDisplay()
        end
    end
    
    updateDisplay()
    table.insert(self.Elements, MultiDropdown)
    return MultiDropdown
end

function Tab:CreateTextBox(config)
    local TextBox = {}
    local textFrame = Instance.new("Frame")
    textFrame.Size = UDim2.new(0.95, 0, 0, 38)
    textFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    textFrame.BorderSizePixel = 0
    textFrame.Parent = self.scrollFrame
    Instance.new("UICorner", textFrame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", textFrame)
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Thickness = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.35, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "TextBox"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = textFrame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.55, 0, 0, 28)
    textBox.Position = UDim2.new(0.4, 0, 0.5, 0)
    textBox.AnchorPoint = Vector2.new(0, 0.5)
    textBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    textBox.Text = ""
    textBox.PlaceholderText = config.PlaceholderText or "Enter text..."
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 11
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    textBox.BorderSizePixel = 0
    textBox.Parent = textFrame
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 6)

    textBox.FocusLost:Connect(function(enterPressed)
        if config.Callback then
            config.Callback(textBox.Text)
        end
        
        if config.RemoveTextAfterFocusLost then
            textBox.Text = ""
        end
    end)
    
    function TextBox:Set(text)
        textBox.Text = text
    end

    table.insert(self.Elements, TextBox)
    return TextBox
end

function Tab:CreateFolder(name)
    local Folder = {}
    Folder.Elements = {}
    
    local folderContainer = Instance.new("Frame")
    folderContainer.Size = UDim2.new(0.95, 0, 0, 40)
    folderContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    folderContainer.BorderSizePixel = 0
    folderContainer.Parent = self.scrollFrame
    Instance.new("UICorner", folderContainer).CornerRadius = UDim.new(0, 8)
    
    local folderStroke = Instance.new("UIStroke", folderContainer)
    folderStroke.Color = Color3.fromRGB(100, 100, 100)
    folderStroke.Thickness = 1
    
    local folderHeader = Instance.new("TextButton")
    folderHeader.Size = UDim2.new(1, 0, 0, 40)
    folderHeader.BackgroundTransparency = 1
    folderHeader.Text = ""
    folderHeader.Parent = folderContainer
    
    local folderLabel = Instance.new("TextLabel")
    folderLabel.Size = UDim2.new(0.9, 0, 1, 0)
    folderLabel.Position = UDim2.new(0, 35, 0, 0)
    folderLabel.BackgroundTransparency = 1
    folderLabel.Text = name
    folderLabel.Font = Enum.Font.GothamBold
    folderLabel.TextSize = 13
    folderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    folderLabel.TextXAlignment = Enum.TextXAlignment.Left
    folderLabel.Parent = folderHeader
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.Position = UDim2.new(0, 10, 0.5, 0)
    arrow.AnchorPoint = Vector2.new(0, 0.5)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▶"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 12
    arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    arrow.Parent = folderHeader
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -10, 0, 0)
    contentFrame.Position = UDim2.new(0, 5, 0, 45)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Visible = false
    contentFrame.Parent = folderContainer
    
    local contentLayout = Instance.new("UIListLayout", contentFrame)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 6)
    
    local isOpen = false
    
    folderHeader.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        contentFrame.Visible = isOpen
        
        if isOpen then
            arrow.Text = "▼"
            TweenService:Create(folderContainer, TweenInfo.new(0.2), {
                Size = UDim2.new(0.95, 0, 0, 45 + contentLayout.AbsoluteContentSize.Y + 10)
            }):Play()
        else
            arrow.Text = "▶"
            TweenService:Create(folderContainer, TweenInfo.new(0.2), {
                Size = UDim2.new(0.95, 0, 0, 40)
            }):Play()
        end
    end)
    
    task.spawn(function()
        while contentFrame.Parent do
            if isOpen then
                contentFrame.Size = UDim2.new(1, -10, 0, contentLayout.AbsoluteContentSize.Y)
                folderContainer.Size = UDim2.new(0.95, 0, 0, 45 + contentLayout.AbsoluteContentSize.Y + 10)
            end
            task.wait(0.1)
        end
    end)
    
    Folder.scrollFrame = contentFrame
    
    function Folder:CreateSection(text)
        return Tab.CreateSection(self, text)
    end
    
    function Folder:CreateToggle(config)
        return Tab.CreateToggle(self, config)
    end
    
    function Folder:CreateButton(config)
        return Tab.CreateButton(self, config)
    end
    
    function Folder:CreateSlider(config)
        return Tab.CreateSlider(self, config)
    end
    
    function Folder:CreateDropdown(config)
        return Tab.CreateDropdown(self, config)
    end
    
    function Folder:CreateMultiDropdown(config)
        return Tab.CreateMultiDropdown(self, config)
    end
    
    function Folder:CreateTextBox(config)
        return Tab.CreateTextBox(self, config)
    end
    
    return Folder
end

return Luna


