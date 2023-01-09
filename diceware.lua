#!/usr/bin/env lua

-- Usage: diceware [count] [wordlist]

local random = assert(io.open("/dev/urandom", "rb"))
local wordlist = assert(io.open(arg[2] or "eff_large_wordlist.txt")):read("*a")
local count = tonumber(arg[1]) or 10 -- entropy = log2(wordlist_size) * count

local function roll(times)
    local result = ''
    while #result < times do
        local num = 0
        while num <= 4 do -- 2^8 % 6
            num = random:read(1):byte()
        end
        result = result .. tostring(num % 6 + 1)
    end
    return result
end

local times = #assert((wordlist:match("^%d+")), "Invalid wordlist")
local passphrase = wordlist:match(roll(times) .. "%s*(%w+)")
for _=2, count do
    passphrase = passphrase .. ' ' .. wordlist:match(roll(times) .. "%s*(%w+)")
end
print(passphrase)
