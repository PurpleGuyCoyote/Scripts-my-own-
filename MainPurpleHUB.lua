if game.PlaceId == 77972039892729 then
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Создаем UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MineController"
ScreenGui.Parent = PlayerGui

-- Основной фрейм (перетаскиваемый)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 50)
MainFrame.Position = UDim2.new(0.5, -100, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Текст заголовка
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "Mine Controller"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Кнопка для перекраски мин
local RevealButton = Instance.new("TextButton")
RevealButton.Name = "RevealButton"
RevealButton.Size = UDim2.new(1, -10, 0, 20)
RevealButton.Position = UDim2.new(0, 5, 0, 30)
RevealButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
RevealButton.Text = "Reveal Mines"
RevealButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RevealButton.TextSize = 14
RevealButton.Font = Enum.Font.Gotham
RevealButton.Parent = MainFrame

-- Таблицы для хранения оригинальных свойств
local originalProperties = {}

-- Функция для сохранения оригинальных свойств
local function saveOriginalProperties(model)
    if not originalProperties[model] then
        originalProperties[model] = {}
    end
    
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            originalProperties[model][part] = {
                Color = part.Color,
                Material = part.Material,
                BrickColor = part.BrickColor,
                Transparency = part.Transparency
            }
            
            -- Сохраняем SurfaceAppearance если есть
            local surfaceAppearance = part:FindFirstChildOfClass("SurfaceAppearance")
            if surfaceAppearance then
                originalProperties[model][part].SurfaceAppearance = {
                    ColorMap = surfaceAppearance.ColorMap,
                    TexturePack = surfaceAppearance.TexturePack
                }
            end
            
            -- Сохраняем Texture если есть (для более старых моделей)
            local texture = part:FindFirstChildOfClass("Texture")
            if texture then
                originalProperties[model][part].Texture = texture.Texture
            end
        end
    end
end

-- Функция для восстановления оригинальных свойств
local function restoreOriginalProperties(model)
    if originalProperties[model] then
        for part, properties in pairs(originalProperties[model]) do
            if part and part.Parent then
                pcall(function()
                    if properties.Color then
                        part.Color = properties.Color
                    end
                    if properties.Material then
                        part.Material = properties.Material
                    end
                    if properties.BrickColor then
                        part.BrickColor = properties.BrickColor
                    end
                    if properties.Transparency then
                        part.Transparency = properties.Transparency
                    end
                    
                    -- Восстанавливаем SurfaceAppearance
                    if properties.SurfaceAppearance then
                        local surfaceAppearance = part:FindFirstChildOfClass("SurfaceAppearance")
                        if surfaceAppearance then
                            surfaceAppearance.ColorMap = properties.SurfaceAppearance.ColorMap
                            surfaceAppearance.TexturePack = properties.SurfaceAppearance.TexturePack
                        end
                    end
                    
                    -- Восстанавливаем Texture
                    if properties.Texture then
                        local texture = part:FindFirstChildOfClass("Texture")
                        if texture then
                            texture.Texture = properties.Texture
                        end
                    end
                end)
            end
        end
    end
end

-- Функция для проверки, содержит ли модель объект Mine
local function hasMine(model)
    local mine = model:FindFirstChild("Mine")
    if mine then
        return true
    end
    
    -- Также проверяем в потомках
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant.Name == "Mine" then
            return true
        end
    end
    
    return false
end

-- Функция для изменения цвета и текстуры всех BasePart в модели
local function colorModelParts(model, isMineModel)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            if isMineModel then
                -- Яркий красный для мин
                part.Color = Color3.fromRGB(255, 50, 50)  -- Красный
                part.Material = Enum.Material.Plastic
                
                -- Удаляем текстуры для чистого цвета
                local surfaceAppearance = part:FindFirstChildOfClass("SurfaceAppearance")
                if surfaceAppearance then
                    surfaceAppearance:Destroy()
                end
                
                local texture = part:FindFirstChildOfClass("Texture")
                if texture then
                    texture:Destroy()
                end
                
                -- Делаем немного прозрачным для эффекта
                part.Transparency = 0.2
            else
                -- Яркий зеленый для безопасных плиток
                part.Color = Color3.fromRGB(50, 255, 50)  -- Зеленый
                part.Material = Enum.Material.Plastic
                
                -- Удаляем текстуры для чистого цвета
                local surfaceAppearance = part:FindFirstChildOfClass("SurfaceAppearance")
                if surfaceAppearance then
                    surfaceAppearance:Destroy()
                end
                
                local texture = part:FindFirstChildOfClass("Texture")
                if texture then
                    texture:Destroy()
                end
                
                -- Делаем немного прозрачным для эффекта
                part.Transparency = 0.2
            end
        end
    end
end

-- Основная функция для раскрытия мин
local function revealMines()
    -- Сначала восстанавливаем все оригинальные свойства
    for model, _ in pairs(originalProperties) do
        if model and model.Parent then
            restoreOriginalProperties(model)
        end
    end
    
    -- Очищаем таблицу
    originalProperties = {}
    
    -- Находим папку Tiles
    local tilesFolder = workspace:FindFirstChild("Tiles")
    if not tilesFolder then
        warn("Папка 'Tiles' не найдена в workspace!")
        return
    end
    
    -- Перебираем все модели в папке Tiles
    for _, model in ipairs(tilesFolder:GetChildren()) do
        if model:IsA("Model") then
            -- Сохраняем оригинальные свойства
            saveOriginalProperties(model)
            
            -- Проверяем, есть ли в модели Mine
            local isMineModel = hasMine(model)
            
            -- Меняем цвет и текстуру
            colorModelParts(model, isMineModel)
            
            print(("Модель '%s': %s"):format(model.Name, isMineModel and "МИНА!" or "безопасна"))
        end
    end
    
    print("Раскрытие мин завершено!")
end

-- Функция для восстановления исходного вида
local function revertMines()
    for model, _ in pairs(originalProperties) do
        if model and model.Parent then
            restoreOriginalProperties(model)
        end
    end
    
    originalProperties = {}
    print("Все модели восстановлены к исходному виду!")
end

-- Обработчик нажатия кнопки
local isRevealed = false
RevealButton.MouseButton1Click:Connect(function()
    if not isRevealed then
        revealMines()
        RevealButton.Text = "Revert Mines"
        RevealButton.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
        isRevealed = true
    else
        revertMines()
        RevealButton.Text = "Reveal Mines"
        RevealButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        isRevealed = false
    end
end)

-- Добавляем визуальный эффект при наведении на кнопку
RevealButton.MouseEnter:Connect(function()
    if isRevealed then
        RevealButton.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    else
        RevealButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end
end)

RevealButton.MouseLeave:Connect(function()
    if isRevealed then
        RevealButton.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
    else
        RevealButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

print("Mine Controller загружен! Используйте интерфейс для управления.")

else print("This game is not supported!")
end
