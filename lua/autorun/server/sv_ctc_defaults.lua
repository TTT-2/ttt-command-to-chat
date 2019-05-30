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
                ctc_default = {151, 211, 255, 255},
                ctc_highlight = {215, 240, 240, 255},

                ctc_heading = {85, 150, 100, 255},
                ctc_white = {255, 255, 255, 255},
                ctc_url = {10, 85, 140, 255}
            }
        },
        text = {
            Deutsch = {
                ttt_ctc_help_line_1 = "Besuche %ctc_url%https://github.com/TimGoll/ttt-command-to-chat %ctc_default%um mehr Informationen über dieses Addon zu bekommen.",
                ttt_ctc_help_line_2 = "%ctc_heading%Auflistung aller Befehle:",
                ttt_ctc_info_data_print = "Du bist %ctc_white%$p$%ctc_default% und es ist %ctc_white%$t$ Uhr%ctc_default% (am %ctc_white%$d$%ctc_default%), du spielst auf: {servername}!",
                ttt_ctc_info_desc = "Gibt ein paar generelle Informationen raus."
            },
            English = {
                ttt_ctc_help_line_1 = "Visit %ctc_url%https://github.com/TimGoll/ttt-command-to-chat %ctc_default%for more information about this addon.",
                ttt_ctc_help_line_2 = "%ctc_heading%List of all available commands:",
                ttt_ctc_info_data_print = "You are %ctc_white%$p$%ctc_default% and it is %ctc_white%$t$%ctc_default% (on the %ctc_white%$d$%ctc_default%), you're playing on {servername}!",
                ttt_ctc_info_desc = "Prints general information."
            }
        },
        commands = {
            help = {
                desc = {
                    localized = false,
                    text = "Lists all commands"
                },
                chat = {
                    "ttt_ctc_help_line_1",
                    "ttt_ctc_help_line_2"
                },
                console = {
                    "ctc_defaults_list_all"
                }
            },
            info = {
                desc = {
                    text = "ttt_ctc_info_desc"
                },
                chat = {
                    "ttt_ctc_info_data_print"
                }
            },
            multicommand = {
                desc = {
                    localized = false,
                    text = "Runs multiple commands at once"
                },
                localized = false,
                chat = {
                    "Running multiple commands!"
                },
                console = {
                    "xgui",
                    "shopeditor"
                }
            }
        }
    }

end