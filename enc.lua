#!/usr/bin/env lua

local monocypher = require("monocypher")

local function getopt(argv, optstring, nonoptions)
    local optind = 1
    local optpos = 2
    nonoptions = nonoptions or {}
    return function()
        while true do
            local arg = argv[optind]
            if arg == nil then
                return nil
            elseif arg == "--" then
                for i = optind + 1, #argv do
                    table.insert(nonoptions, argv[i])
                end
                return nil
            elseif arg:sub(1, 1) == '-' then
                local opt = arg:sub(optpos, optpos)
                local start, stop = optstring:find(opt .. ":?")
                if not start then
                    optind = optind + 1
                    optpos = 2
                    return '?', opt
                elseif stop > start and #arg > optpos then
                    local optarg = arg:sub(optpos + 1)
                    optind = optind + 1
                    optpos = 2
                    return opt, optarg
                elseif stop > start then
                    local optarg = argv[optind + 1]
                    optind = optind + 2
                    optpos = 2
                    if optarg == nil then
                        return ':', opt
                    end
                    return opt, optarg
                else
                    optpos = optpos + 1
                    if optpos > #arg then
                        optind = optind + 1
                        optpos = 2
                    end
                    return opt, nil
                end
            else
                optind = optind + 1
                table.insert(nonoptions, arg)
            end
        end
    end
end

local function die(err)
    io.stderr:write("enc: " .. err .. '\n')
    os.exit(1, true)
end

local decrypt = false
local tty = io.open("/dev/tty", "r+") or die("can't access TTY")
local output = io.stdout
local input = io.stdin

for opt, optarg in getopt(arg, "dhvi:o:") do
    if opt == 'd' then
        decrypt = true
    elseif opt == 'h' then
        print("Usage: enc [-dhv] [-i <input>] [-o <output>]")
        os.exit(0, true)
    elseif opt == 'v' then
        print(monocypher._VERSION)
        os.exit(0, true)
    elseif opt == 'i' then
        input = io.open(optarg, "rb") or
            die(string.format("can't read from '%s'", optarg))
    elseif opt == 'o' then
        output = io.open(optarg, "wb") or
            die(string.format("can't write to '%s'", optarg))
    elseif opt == '?' then
        die(string.format("unknown option '-%s'", optarg))
    elseif opt == ':' then
        die(string.format("missing argument for option '-%s'", optarg))
    end
end

tty:write("Password: ")
if decrypt then
    local key = monocypher.argon2(tty:read(), input:read(16))
    local plaintext = monocypher.decrypt(input:read("*a"), key)
    output:write(plaintext)
else
    local key, salt = monocypher.argon2(tty:read())
    local ciphertext = monocypher.encrypt(input:read("*a"), key)
    output:write(salt)
    output:write(ciphertext)
end