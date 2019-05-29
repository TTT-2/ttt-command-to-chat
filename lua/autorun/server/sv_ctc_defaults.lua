if SERVER then

    CTC_DEFAULT = {
        settings = {
            prefix = "!",
            run_first = "chat"
        },
        variables = {
            strings = {
                servername = "TTT with Friends"
            },
            colors = {
                default = {151, 211, 255, 255},
                highlight = {73, 170, 73, 255},
                white = {255, 255, 255, 255},
                url = {10, 85, 140, 255}
            }
        },
        text = {
            Deutsch = {
                ttt_ctc_help_line_1 = "Besuche %url%https://github.com/TimGoll/ttt-command-to-chat %default%um mehr Informationen über dieses Addon zu bekommen.",
                ttt_ctc_help_line_2 = "%highlight%Auflistung aller Befehle:",
                ttt_ctc_info_data_print = "Du bist $p$ und es ist $t$ Uhr, du spielst auf: {servername}!"
            },
            English = {
                ttt_ctc_help_line_1 = "Visit %url%https://github.com/TimGoll/ttt-command-to-chat %default%for more information about this addon.",
                ttt_ctc_help_line_2 = "%highlight%List of all available commands:",
                ttt_ctc_info_data_print = "You are %white%$p$%default% and it is %white%$t$%default% (on the %white%$d$%default%), you're playing on {servername}!"
            }
        },
        commands = {
            help = {
                chat = {
                    "ttt_ctc_help_line_1",
                    "ttt_ctc_help_line_2"
                },
                console = {
                    "ctc_help"
                }
            },
            info = {
                chat = {
                    "ttt_ctc_info_data_print"
                }
            },
            multicommand = {
                localized = false,
                chat = {
                    "Running multiple commands!"
                },
                console = {
                    "xmenu",
                    "shopeditor"
                }
            }
        }
    }

end