return {
    "lervag/vimtex",
    lazy = false,
    init = function()
        vim.g.vimtex_view_method = "evince"
    end,
    config = function()
        -- Explicitly define all mappings with descriptions

        -- Document compilation and viewing
        vim.keymap.set("n", "<leader>xi", "<plug>(vimtex-info)", { desc = "VimTeX info", silent = true })
        vim.keymap.set("n", "<leader>xI", "<plug>(vimtex-info-full)", { desc = "VimTeX info full", silent = true })
        vim.keymap.set("n", "<leader>xt", "<plug>(vimtex-toc-open)", { desc = "Open TOC", silent = true })
        vim.keymap.set("n", "<leader>xT", "<plug>(vimtex-toc-toggle)", { desc = "Toggle TOC", silent = true })
        vim.keymap.set("n", "<leader>xq", "<plug>(vimtex-log)", { desc = "Show log", silent = true })
        vim.keymap.set("n", "<leader>xv", "<plug>(vimtex-view)", { desc = "View PDF", silent = true })
        vim.keymap.set("n", "<leader>xr", "<plug>(vimtex-reverse-search)", { desc = "Reverse search", silent = true })
        vim.keymap.set("n", "<leader>xl", "<plug>(vimtex-compile)", { desc = "Compile document", silent = true })
        vim.keymap.set(
            "n",
            "<leader>xL",
            "<plug>(vimtex-compile-selected)",
            { desc = "Compile selected", silent = true }
        )
        vim.keymap.set(
            "x",
            "<leader>xL",
            "<plug>(vimtex-compile-selected)",
            { desc = "Compile selected", silent = true }
        )
        vim.keymap.set("n", "<leader>xk", "<plug>(vimtex-stop)", { desc = "Stop compilation", silent = true })
        vim.keymap.set("n", "<leader>xK", "<plug>(vimtex-stop-all)", { desc = "Stop all compilations", silent = true })
        vim.keymap.set("n", "<leader>xe", "<plug>(vimtex-errors)", { desc = "Show errors", silent = true })
        vim.keymap.set(
            "n",
            "<leader>xo",
            "<plug>(vimtex-compile-output)",
            { desc = "Show compilation output", silent = true }
        )
        vim.keymap.set("n", "<leader>xg", "<plug>(vimtex-status)", { desc = "Show compilation status", silent = true })
        vim.keymap.set(
            "n",
            "<leader>xG",
            "<plug>(vimtex-status-all)",
            { desc = "Show all compilation status", silent = true }
        )
        vim.keymap.set("n", "<leader>xc", "<plug>(vimtex-clean)", { desc = "Clean auxiliary files", silent = true })
        vim.keymap.set(
            "n",
            "<leader>xC",
            "<plug>(vimtex-clean-full)",
            { desc = "Clean auxiliary files (full)", silent = true }
        )
        vim.keymap.set("n", "<leader>xm", "<plug>(vimtex-imaps-list)", { desc = "Show imaps list", silent = true })
        vim.keymap.set("n", "<leader>xx", "<plug>(vimtex-reload)", { desc = "Reload VimTeX", silent = true })
        vim.keymap.set(
            "n",
            "<leader>xX",
            "<plug>(vimtex-reload-state)",
            { desc = "Reload VimTeX state", silent = true }
        )
        vim.keymap.set("n", "<leader>xs", "<plug>(vimtex-toggle-main)", { desc = "Toggle main file", silent = true })
        vim.keymap.set("n", "<leader>xa", "<plug>(vimtex-context-menu)", { desc = "Show context menu", silent = true })

        -- Deletion and change operators
        vim.keymap.set(
            "n",
            "dse",
            "<plug>(vimtex-env-delete)",
            { desc = "Delete surrounding environment", silent = true }
        )
        vim.keymap.set("n", "dsc", "<plug>(vimtex-cmd-delete)", { desc = "Delete surrounding command", silent = true })
        vim.keymap.set(
            "n",
            "ds$",
            "<plug>(vimtex-env-delete-math)",
            { desc = "Delete surrounding math", silent = true }
        )
        vim.keymap.set(
            "n",
            "dsd",
            "<plug>(vimtex-delim-delete)",
            { desc = "Delete surrounding delimiter", silent = true }
        )
        vim.keymap.set(
            "n",
            "cse",
            "<plug>(vimtex-env-change)",
            { desc = "Change surrounding environment", silent = true }
        )
        vim.keymap.set("n", "csc", "<plug>(vimtex-cmd-change)", { desc = "Change surrounding command", silent = true })
        vim.keymap.set(
            "n",
            "cs$",
            "<plug>(vimtex-env-change-math)",
            { desc = "Change surrounding math", silent = true }
        )
        vim.keymap.set(
            "n",
            "csd",
            "<plug>(vimtex-delim-change-math)",
            { desc = "Change surrounding delimiter", silent = true }
        )

        -- Toggle functions
        vim.keymap.set("n", "tsf", "<plug>(vimtex-cmd-toggle-frac)", { desc = "Toggle fraction", silent = true })
        vim.keymap.set("x", "tsf", "<plug>(vimtex-cmd-toggle-frac)", { desc = "Toggle fraction", silent = true })
        vim.keymap.set("n", "tsc", "<plug>(vimtex-cmd-toggle-star)", { desc = "Toggle star command", silent = true })
        vim.keymap.set(
            "n",
            "tss",
            "<plug>(vimtex-env-toggle-star)",
            { desc = "Toggle star environment", silent = true }
        )
        vim.keymap.set("n", "tse", "<plug>(vimtex-env-toggle)", { desc = "Toggle environment", silent = true })
        vim.keymap.set("n", "ts$", "<plug>(vimtex-env-toggle-math)", { desc = "Toggle math", silent = true })
        vim.keymap.set("n", "tsb", "<plug>(vimtex-env-toggle-break)", { desc = "Toggle break", silent = true })
        vim.keymap.set(
            "n",
            "tsd",
            "<plug>(vimtex-delim-toggle-modifier)",
            { desc = "Toggle delimiter modifier", silent = true }
        )
        vim.keymap.set(
            "x",
            "tsd",
            "<plug>(vimtex-delim-toggle-modifier)",
            { desc = "Toggle delimiter modifier", silent = true }
        )
        vim.keymap.set(
            "n",
            "tsD",
            "<plug>(vimtex-delim-toggle-modifier-reverse)",
            { desc = "Toggle delimiter modifier (reverse)", silent = true }
        )
        vim.keymap.set(
            "x",
            "tsD",
            "<plug>(vimtex-delim-toggle-modifier-reverse)",
            { desc = "Toggle delimiter modifier (reverse)", silent = true }
        )

        -- Surrounding operations
        vim.keymap.set(
            "n",
            "<F6>",
            "<plug>(vimtex-env-surround-line)",
            { desc = "Surround line with environment", silent = true }
        )
        vim.keymap.set(
            "x",
            "<F6>",
            "<plug>(vimtex-env-surround-visual)",
            { desc = "Surround selection with environment", silent = true }
        )
        vim.keymap.set("n", "<F7>", "<plug>(vimtex-cmd-create)", { desc = "Create command", silent = true })
        vim.keymap.set("x", "<F7>", "<plug>(vimtex-cmd-create)", { desc = "Create command", silent = true })
        vim.keymap.set("i", "<F7>", "<plug>(vimtex-cmd-create)", { desc = "Create command", silent = true })
        vim.keymap.set("i", "]]", "<plug>(vimtex-delim-close)", { desc = "Close delimiter", silent = true })
        vim.keymap.set(
            "n",
            "<F8>",
            "<plug>(vimtex-delim-add-modifiers)",
            { desc = "Add delimiter modifiers", silent = true }
        )

        -- Text objects
        vim.keymap.set("x", "ac", "<plug>(vimtex-ac)", { desc = "Around command", silent = true })
        vim.keymap.set("o", "ac", "<plug>(vimtex-ac)", { desc = "Around command", silent = true })
        vim.keymap.set("x", "ic", "<plug>(vimtex-ic)", { desc = "Inside command", silent = true })
        vim.keymap.set("o", "ic", "<plug>(vimtex-ic)", { desc = "Inside command", silent = true })
        vim.keymap.set("x", "ad", "<plug>(vimtex-ad)", { desc = "Around delimiter", silent = true })
        vim.keymap.set("o", "ad", "<plug>(vimtex-ad)", { desc = "Around delimiter", silent = true })
        vim.keymap.set("x", "id", "<plug>(vimtex-id)", { desc = "Inside delimiter", silent = true })
        vim.keymap.set("o", "id", "<plug>(vimtex-id)", { desc = "Inside delimiter", silent = true })
        vim.keymap.set("x", "ae", "<plug>(vimtex-ae)", { desc = "Around environment", silent = true })
        vim.keymap.set("o", "ae", "<plug>(vimtex-ae)", { desc = "Around environment", silent = true })
        vim.keymap.set("x", "ie", "<plug>(vimtex-ie)", { desc = "Inside environment", silent = true })
        vim.keymap.set("o", "ie", "<plug>(vimtex-ie)", { desc = "Inside environment", silent = true })
        vim.keymap.set("x", "a$", "<plug>(vimtex-a$)", { desc = "Around math", silent = true })
        vim.keymap.set("o", "a$", "<plug>(vimtex-a$)", { desc = "Around math", silent = true })
        vim.keymap.set("x", "i$", "<plug>(vimtex-i$)", { desc = "Inside math", silent = true })
        vim.keymap.set("o", "i$", "<plug>(vimtex-i$)", { desc = "Inside math", silent = true })
        vim.keymap.set("x", "aP", "<plug>(vimtex-aP)", { desc = "Around paragraph", silent = true })
        vim.keymap.set("o", "aP", "<plug>(vimtex-aP)", { desc = "Around paragraph", silent = true })
        vim.keymap.set("x", "iP", "<plug>(vimtex-iP)", { desc = "Inside paragraph", silent = true })
        vim.keymap.set("o", "iP", "<plug>(vimtex-iP)", { desc = "Inside paragraph", silent = true })
        vim.keymap.set("x", "am", "<plug>(vimtex-am)", { desc = "Around item", silent = true })
        vim.keymap.set("o", "am", "<plug>(vimtex-am)", { desc = "Around item", silent = true })
        vim.keymap.set("x", "im", "<plug>(vimtex-im)", { desc = "Inside item", silent = true })
        vim.keymap.set("o", "im", "<plug>(vimtex-im)", { desc = "Inside item", silent = true })

        -- Navigation
        vim.keymap.set("n", "%", "<plug>(vimtex-%)", { desc = "Match delimiter", silent = true })
        vim.keymap.set("x", "%", "<plug>(vimtex-%)", { desc = "Match delimiter", silent = true })
        vim.keymap.set("o", "%", "<plug>(vimtex-%)", { desc = "Match delimiter", silent = true })
        vim.keymap.set("n", "]]", "<plug>(vimtex-]])", { desc = "Next begin environment", silent = true })
        vim.keymap.set("x", "]]", "<plug>(vimtex-]])", { desc = "Next begin environment", silent = true })
        vim.keymap.set("o", "]]", "<plug>(vimtex-]])", { desc = "Next begin environment", silent = true })
        vim.keymap.set("n", "][", "<plug>(vimtex-][)", { desc = "Next end environment", silent = true })
        vim.keymap.set("x", "][", "<plug>(vimtex-][)", { desc = "Next end environment", silent = true })
        vim.keymap.set("o", "][", "<plug>(vimtex-][)", { desc = "Next end environment", silent = true })
        vim.keymap.set("n", "[]", "<plug>(vimtex-[])", { desc = "Previous end environment", silent = true })
        vim.keymap.set("x", "[]", "<plug>(vimtex-[])", { desc = "Previous end environment", silent = true })
        vim.keymap.set("o", "[]", "<plug>(vimtex-[])", { desc = "Previous end environment", silent = true })
        vim.keymap.set("n", "[[", "<plug>(vimtex-[[)", { desc = "Previous begin environment", silent = true })
        vim.keymap.set("x", "[[", "<plug>(vimtex-[[)", { desc = "Previous begin environment", silent = true })
        vim.keymap.set("o", "[[", "<plug>(vimtex-[[)", { desc = "Previous begin environment", silent = true })
        vim.keymap.set("n", "]m", "<plug>(vimtex-]m)", { desc = "Next math environment", silent = true })
        vim.keymap.set("x", "]m", "<plug>(vimtex-]m)", { desc = "Next math environment", silent = true })
        vim.keymap.set("o", "]m", "<plug>(vimtex-]m)", { desc = "Next math environment", silent = true })
        vim.keymap.set("n", "]M", "<plug>(vimtex-]M)", { desc = "Next closing math environment", silent = true })
        vim.keymap.set("x", "]M", "<plug>(vimtex-]M)", { desc = "Next closing math environment", silent = true })
        vim.keymap.set("o", "]M", "<plug>(vimtex-]M)", { desc = "Next closing math environment", silent = true })
        vim.keymap.set("n", "[m", "<plug>(vimtex-[m)", { desc = "Previous math environment", silent = true })
        vim.keymap.set("x", "[m", "<plug>(vimtex-[m)", { desc = "Previous math environment", silent = true })
        vim.keymap.set("o", "[m", "<plug>(vimtex-[m)", { desc = "Previous math environment", silent = true })
        vim.keymap.set("n", "[M", "<plug>(vimtex-[M)", { desc = "Previous closing math environment", silent = true })
        vim.keymap.set("x", "[M", "<plug>(vimtex-[M)", { desc = "Previous closing math environment", silent = true })
        vim.keymap.set("o", "[M", "<plug>(vimtex-[M)", { desc = "Previous closing math environment", silent = true })
        vim.keymap.set("n", "]n", "<plug>(vimtex-]n)", { desc = "Next math zone", silent = true })
        vim.keymap.set("x", "]n", "<plug>(vimtex-]n)", { desc = "Next math zone", silent = true })
        vim.keymap.set("o", "]n", "<plug>(vimtex-]n)", { desc = "Next math zone", silent = true })
        vim.keymap.set("n", "]N", "<plug>(vimtex-]N)", { desc = "Next closing math zone", silent = true })
        vim.keymap.set("x", "]N", "<plug>(vimtex-]N)", { desc = "Next closing math zone", silent = true })
        vim.keymap.set("o", "]N", "<plug>(vimtex-]N)", { desc = "Next closing math zone", silent = true })
        vim.keymap.set("n", "[n", "<plug>(vimtex-[n)", { desc = "Previous math zone", silent = true })
        vim.keymap.set("x", "[n", "<plug>(vimtex-[n)", { desc = "Previous math zone", silent = true })
        vim.keymap.set("o", "[n", "<plug>(vimtex-[n)", { desc = "Previous math zone", silent = true })
        vim.keymap.set("n", "[N", "<plug>(vimtex-[N)", { desc = "Previous closing math zone", silent = true })
        vim.keymap.set("x", "[N", "<plug>(vimtex-[N)", { desc = "Previous closing math zone", silent = true })
        vim.keymap.set("o", "[N", "<plug>(vimtex-[N)", { desc = "Previous closing math zone", silent = true })
        vim.keymap.set("n", "]r", "<plug>(vimtex-]r)", { desc = "Next frame/slide environment", silent = true })
        vim.keymap.set("x", "]r", "<plug>(vimtex-]r)", { desc = "Next frame/slide environment", silent = true })
        vim.keymap.set("o", "]r", "<plug>(vimtex-]r)", { desc = "Next frame/slide environment", silent = true })
        vim.keymap.set("n", "]R", "<plug>(vimtex-]R)", { desc = "Next closing frame/slide environment", silent = true })
        vim.keymap.set("x", "]R", "<plug>(vimtex-]R)", { desc = "Next closing frame/slide environment", silent = true })
        vim.keymap.set("o", "]R", "<plug>(vimtex-]R)", { desc = "Next closing frame/slide environment", silent = true })
        vim.keymap.set("n", "[r", "<plug>(vimtex-[r)", { desc = "Previous frame/slide environment", silent = true })
        vim.keymap.set("x", "[r", "<plug>(vimtex-[r)", { desc = "Previous frame/slide environment", silent = true })
        vim.keymap.set("o", "[r", "<plug>(vimtex-[r)", { desc = "Previous frame/slide environment", silent = true })
        vim.keymap.set(
            "n",
            "[R",
            "<plug>(vimtex-[R)",
            { desc = "Previous closing frame/slide environment", silent = true }
        )
        vim.keymap.set(
            "x",
            "[R",
            "<plug>(vimtex-[R)",
            { desc = "Previous closing frame/slide environment", silent = true }
        )
        vim.keymap.set(
            "o",
            "[R",
            "<plug>(vimtex-[R)",
            { desc = "Previous closing frame/slide environment", silent = true }
        )
        vim.keymap.set("n", "]/", "<plug>(vimtex-]/)", { desc = "Next comment", silent = true })
        vim.keymap.set("x", "]/", "<plug>(vimtex-]/)", { desc = "Next comment", silent = true })
        vim.keymap.set("o", "]/", "<plug>(vimtex-]/)", { desc = "Next comment", silent = true })
        vim.keymap.set("n", "]*", "<plug>(vimtex-]star)", { desc = "Next section", silent = true })
        vim.keymap.set("x", "]*", "<plug>(vimtex-]star)", { desc = "Next section", silent = true })
        vim.keymap.set("o", "]*", "<plug>(vimtex-]star)", { desc = "Next section", silent = true })
        vim.keymap.set("n", "[/", "<plug>(vimtex-[/)", { desc = "Previous comment", silent = true })
        vim.keymap.set("x", "[/", "<plug>(vimtex-[/)", { desc = "Previous comment", silent = true })
        vim.keymap.set("o", "[/", "<plug>(vimtex-[/)", { desc = "Previous comment", silent = true })
        vim.keymap.set("n", "[*", "<plug>(vimtex-[star)", { desc = "Previous section", silent = true })
        vim.keymap.set("x", "[*", "<plug>(vimtex-[star)", { desc = "Previous section", silent = true })
        vim.keymap.set("o", "[*", "<plug>(vimtex-[star)", { desc = "Previous section", silent = true })

        -- Documentation
        vim.keymap.set(
            "n",
            "K",
            "<plug>(vimtex-doc-package)",
            { desc = "Show documentation for package", silent = true }
        )
    end,
}
