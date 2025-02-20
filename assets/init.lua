local n, m = 40, 80
local g = 66000

function display(b)
    if not b then
        print("display: there is no 'b' argument")
        os.exit(1)
    end
    for i = 0, n - 1 do
        for j = 0, m - 1 do
            if b[i][j] ~= 0 then io.write("*") else io.write(" ") end
        end
        io.write("\n")
    end
end

local b = {}
local iter = 0

local function reset()
    for i = 0, n - 1 do
        b[i] = {}
        for j = 0, m - 1 do
            b[i][j] = 0
        end
    end

    -- initialization
    b[19][41] = 1
    b[20][40] = 1
    b[21][40] = 1
    b[22][40] = 1
    b[22][41] = 1
    b[22][42] = 1
    b[22][43] = 1
    b[19][44] = 1
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
                b[up  ][left ] +
                b[up  ][j    ] +
                b[up  ][right] +
                b[i   ][right] +
                b[down][right] +
                b[down][j    ] +
                b[down][left ] +
                b[i   ][left ]

                if count == 2 then nextb[i][j] = b[i][j]
                elseif count == 3 then nextb[i][j] = 1
                else nextb[i][j] = 0
                end
            end

        end
        b, nextb = nextb, b
        coroutine.yeild()

    end
end

C = coroutine.create(coro)

function update()
    local status1, status2 = coroutine.resume(C)

    local cellw, cellh = 64, 64
    for i = 0, nm1 do
        for j = 0, mm1 do
            local color

            if b[i][j] ~= 0 then
                color = RED
            else
                color = BLUE
            end

            DrawRectangle(cellw * j, cellh * i, 100, 100, color)
        end
    end

    for i = 0, nm1 do
        for j = 0, mm1 do
            DrawRectangleLines(cellw * j, cellh * i, 100, 100, BLACK)
        end
    end

    if IsKeyPressed(KEY_R) then
        C = coroutine.create(coro)
        reset()
    end

    local msg = "iteration " .. iter
    local x, y = 30, 500
    DrawText(msg, x, y, 140, GREEN)

    local msg = "status1 " .. tostring(status1) .. " status2 " .. tostring(status2)
    y = y + 140
    DrawText(msg, x, y, 140, GREEN)

end

