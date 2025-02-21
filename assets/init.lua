local n, m = 40, 80
local g = 66000
local started = false

local field, generation
local iter = 0

local function make_field()
    local tmp = {}
    for i = 0, n - 1 do
        tmp[i] = {}
        for j = 0, m - 1 do
            tmp[i][j] = 0
        end
    end
    return tmp
end

local function reset()
    field = make_field()
    generation = make_field()

    -- initialization
    field[19][41] = 1
    field[20][40] = 1
    field[21][40] = 1
    field[22][40] = 1
    field[22][41] = 1
    field[22][42] = 1
    field[22][43] = 1
    field[19][44] = 1
end

reset()

local nm1, mm1 = n - 1, m - 1
-- end of initialization

--main()

local function coro()
    local nextb = {}
    for i = 0, n - 1 do
        nextb[i] = {}
    end

    -- Счетчик повторений
    for k = 1, g do
        iter = k

        for i = 0, nm1 do
            local up, down
            if i ~= 0 then up = i - 1 else up = nm1 end
            if i ~= nm1 then down = i + 1 else down = 0 end

            for j = 0, mm1 do
                local left, right
                if j ~= 0 then left = j - 1 else left = mm1 end
                if j ~= mm1 then right = j + 1 else right = 0 end

                local count =

                field[up  ][left ] +
                field[up  ][j    ] +
                field[up  ][right] +
                field[i   ][right] +
                field[down][right] +
                field[down][j    ] +
                field[down][left ] +
                field[i   ][left ]

                if count == 2 then 
                    nextb[i][j] = field[i][j]
                    generation[i][j] = generation[i][j] + 1
                elseif count == 3 then 
                    nextb[i][j] = 1
                    generation[i][j] = 0
                else 
                    nextb[i][j] = 0
                    generation[i][j] = 0
                end

                if generation[i][j] > 255 then
                    generation[i][j] = 255
                end
            end

        end
        field, nextb = nextb, field
        coroutine.yield()

    end
end

C = coroutine.create(coro)
local cellw, cellh = 64, 64
local ceil = math.ceil
local random = math.random

local function text_stream()

    local j = 0
    local fnt_size = 300
    local color = { 0, 0, 0 }
    local x = 0
    local colord = 1
    while true do
        local c = Color(ceil(color[1]), ceil(color[2]), ceil(color[3]))

        --local c = RED
        DrawText("HELLO YEPdev", x, j, fnt_size, c)
        --DrawText("HELLO YEPdev", 100, j, fnt_size, RED)

        --[[
        color[1] = color[1] + random() * 0.5
        color[2] = color[2] + random() * 0.5
        color[3] = color[3] + random() * 0.5
        --]]
        
        color[1] = color[1] + colord
        color[2] = color[2] + colord
        color[3] = color[3] + colord


        for k = 1, 3 do
            if (color[k] >= 255) then
                colord = -colord
            end
        end

        j = j + 10

        if j > GetScreenHeight() then
            j = -fnt_size
        end

        x = x + random(10)

        if x > GetScreenWidth() then
            x = 0
        end

        coroutine.yield()
    end

end

local c_text_stream = coroutine.create(text_stream)

local function draw()
    for i = 0, nm1 do
        for j = 0, mm1 do
            local color

            if field[i][j] ~= 0 then
                color = RED
                color.a = generation[i][j]
            else
                color = BLUE
            end

            DrawRectangle(cellw * j, cellh * i, cellw, cellh, color)
        end
    end

    for i = 0, nm1 do
        for j = 0, mm1 do
            DrawRectangleLines(cellw * j, cellh * i, cellw, cellh, BLACK)
        end
    end

    local msg = "iteration " .. iter
    local x, y = 30, 500
    DrawText(msg, x, y, 140, GREEN)

    local msg = "status1 " .. tostring(status1) .. " status2 " .. tostring(status2)
    y = y + 140
    DrawText(msg, x, y, 140, GREEN)

    --coroutine.resume(c_text_stream)

end

local floor = math.floor

function update()
    if started then
        local status1, status2 = coroutine.resume(C)
    else
        local mp = GetMousePosition()

        local _x = floor(mp.x / cellw)
        local _y = floor(mp.y / cellh)

        if IsMouseButtonDown(0) then
            field[_y][_x] = 1
        elseif IsMouseButtonDown(1) then
            field[_y][_x] = 0
        end

    end
    draw()

    if IsKeyPressed(KEY_R) then
        C = coroutine.create(coro)
        reset()
    elseif IsKeyPressed(KEY_SPACE) then
        started = not started
    end

end

