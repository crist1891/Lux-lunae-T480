-- ─────────────────────────────────────────────────────────────
--  LUX LUNAE — Fiat Lux!        Hyprland 0.55+ (Lua config)
--  Syntax follows the official example config + wiki.hypr.land
-- ─────────────────────────────────────────────────────────────
-- palette: black #050403 · gold #988f46 · light gold #bfb771
--          dim #635d38 · ash #29241e · red #b5313a · moon #e9e6c8

local lux      = os.getenv("HOME") .. "/.config/lux"

-- Are we inside a virtual machine? (reads DMI info; real hardware like a ThinkPad says LENOVO)
local function in_vm()
    local ok, res = pcall(function()
        for _, f in ipairs({ "sys_vendor", "product_name" }) do
            local h = io.open("/sys/class/dmi/id/" .. f, "r")
            if h then
                local v = h:read("*l") or ""
                h:close()
                if v:match("QEMU") or v:match("KVM") or v:match("VirtualBox") or v:match("innotek")
                    or v:match("VMware") or v:match("Parallels") or v:match("Xen") then
                    return true
                end
            end
        end
        return false
    end)
    return ok and res == true
end
local vm = in_vm()

-- Real hardware: scale 1.2 (a 1920x1080 panel becomes 1600x900 of workspace). VM: 1.
-- Change the number below to taste; `hyprctl monitors` lists the output name if you want to pin one screen.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = vm and 1 or 1.2,
})

-- ── environment ──
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("XDG_MENU_PREFIX", "arch-")      -- lets Dolphin find the app list ("Open with ...")
if vm then hl.env("WLR_NO_HARDWARE_CURSORS", "1") end   -- VM only; real GPUs keep the hardware cursor

-- ── autostart (the shell, qs, is also the notification daemon — no mako) ──
hl.on("hyprland.start", function()
    hl.exec_cmd(lux .. "/wallcycle.sh init")
    hl.exec_cmd("qs")                                   -- Quickshell: side panel + top bar
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-- ── look and feel ──
hl.config({
    general = {
        gaps_in        = 5,
        gaps_out       = 12,
        border_size    = 2,
        col = {
            active_border   = { colors = { "rgba(988f46ff)", "rgba(bfb771ff)" }, angle = 45 },
            inactive_border = "rgba(29241eff)",
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 0,        -- sharp corners, like the shield badge
        active_opacity   = 1.0,
        inactive_opacity = 0.93,
        shadow = { enabled = false },
        blur   = { enabled = false, size = 6, passes = 3 },   -- Super+Shift+B toggles
    },

    animations = { enabled = true },

    dwindle = { preserve_split = true },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        background_color         = 0xff050403,
    },

    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        touchpad     = { natural_scroll = true },
    },
})

-- animations
hl.curve("moon", { type = "bezier", points = { {0.2, 0.0}, {0.0, 1.0} } })
hl.animation({ leaf = "windows",    enabled = true, speed = 4, bezier = "moon", style = "slide" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "moon" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "moon", style = "fade" })
hl.animation({ leaf = "border",     enabled = true, speed = 6, bezier = "moon" })

-- kitty asked to be maximized/fullscreened on open and covered the other windows;
-- ignore maximize requests from every client
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- ── keybinds (end_4's set, adapted) ──
require("keybinds")
