require("vis")

vis.events.subscribe(vis.events.INIT, function ()
    vis:command("set tabwidth 4")
    vis:command("set autoindent")
    vis:command("set expandtab")
    vis:command("set theme default-16")
end)

vis.events.subscribe(vis.events.WIN_OPEN, function ()
    vis:command("set number")
    vis:command("set colorcolumn 80")
end)

require("plugins/vis-plug").init({
    { "lutobler/vis-commentary" },
    { "https://repo.or.cz/vis-goto-file.git" },
    { "https://gitlab.com/mcepl/vis-jump" },
    { "https://gitlab.com/mcepl/vis-open_rej", ref="872ac619" },
    { "https://gitlab.com/muhq/vis-spellcheck" },
    { "erf/vis-title" }
}, true)
