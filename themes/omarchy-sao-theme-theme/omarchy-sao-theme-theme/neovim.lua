return {
    {
        "bjarneo/aether.nvim",
        branch = "v2",
        name = "aether",
        priority = 1000,
        opts = {
            transparent = false,
            colors = {
                -- Background colors
                bg = "#000000",
                bg_dark = "#000000",
                bg_highlight = "#3c4189",

                -- Foreground colors
                -- fg: Object properties, builtin types, builtin variables, member access, default text
                fg = "#e6e6e6",
                -- fg_dark: Inactive elements, statusline, secondary text
                fg_dark = "#bee3eb",
                -- comment: Line highlight, gutter elements, disabled states
                comment = "#3c4189",

                -- Accent colors
                -- red: Errors, diagnostics, tags, deletions, breakpoints
                red = "#1d28d8",
                -- orange: Constants, numbers, current line number, git modifications
                orange = "#5f69f1",
                -- yellow: Types, classes, constructors, warnings, numbers, booleans
                yellow = "#6dc4e9",
                -- green: Comments, strings, success states, git additions
                green = "#43c2f4",
                -- cyan: Parameters, regex, preprocessor, hints, properties
                cyan = "#7ea9c3",
                -- blue: Functions, keywords, directories, links, info diagnostics
                blue = "#3f4ce4",
                -- purple: Storage keywords, special keywords, identifiers, namespaces
                purple = "#405cf2",
                -- magenta: Function declarations, exception handling, tags
                magenta = "#91a1fd",
            },
        },
        config = function(_, opts)
            require("aether").setup(opts)
            vim.cmd.colorscheme("aether")

            -- Enable hot reload
            require("aether.hotreload").setup()
        end,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "aether",
        },
    },
}
