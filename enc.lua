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

local function die(message)
    io.stderr:write(message and "enc: " .. message .. ".\n" or
                    "Usage: enc [-dhv] [-i <input>] [-o <output>]\n")
    os.exit(1, true)
end

local decrypt = false

for opt, optarg in getopt(arg, "dhi:o:v") do
    if opt == 'd' then
        decrypt = true
    elseif opt == 'h' then
        die()
    elseif opt == 'i' then
        io.input(optarg)
    elseif opt == 'o' then
        io.output(optarg)
    elseif opt == 'v' then
        io.stderr:write(monocypher._VERSION .. '\n')
        os.exit(0, true)
    elseif opt == '?' then
        die(string.format("unknown option '-%s'", optarg))
    elseif opt == ':' then
        die(string.format("missing argument for option '-%s'", optarg))
    end
end

io.stderr:write("Password: ")
if decrypt then
    local key = monocypher.argon2(io.stdin:read(), io.input():read(16))
    local plaintext = monocypher.decrypt(io.input():read("*a"), key)
    io.output():write(plaintext)
else
    local key, salt = monocypher.argon2(io.stdin:read())
    io.output():write(salt)
    local ciphertext = monocypher.encrypt(io.input():read("*a"), key)
    io.output():write(ciphertext)
end
