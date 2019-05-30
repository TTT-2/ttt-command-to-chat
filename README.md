# TTT - Command to Chat

A small addon that makes it easy for server owners to configure chat commands. Each defined command registers a chat command and a console command. Once executed, chat messages can be printed to the player chat or further commands can be automatically executed. Additionally multiple languages, variables, placeholders and colors are supported.

## Setup

After installation of the addon, the GM server has to run once. A new folder will ve created in `garrysmmod/data` called `ctc`. Inside this folder is a file called `commands.txt`. This text file is a json structure which can be edited in order to create new custom commands.

## Basic Settings

The settings part looks like this. The `prefix` defines the symbol (or multiple symbols) that have to be in front of a chat command in order to be detected. It is `!` by default. `run_first` defines if chatprints (`chat`) or console commands (`console`) should be executed first.

```json
"settings": {
    "prefix": "!",
    "run_first": "chat"
}
```

## Basic Command

The most basic command is a simple text print like this without any variables, placeholders or colors. In this example no localization was used.

```json
"commands": {
    "example": {
        "localized": false,
        "chat": [
            "Awesome text line one!",
            "And there's a second line here"
        ]
    }
}
```

Once you enter `!example` in the chat, two lines are printed. Additionally a command called `ctc_example` gets registered, which can be executed in the console. This can be used to call a chatcommand from multiple other chat commands (see later), bind it to a key using `bind` or (in case you are using TTT2) use [Easy Custom Bindings](https://steamcommunity.com/sharedfiles/filedetails/?id=1673119444) in combination with the TTT2 binding system.

## Adding Color

In this example the first line should be colored. Therefore a colortag has to be added. A colortag always starts and ends with `%`. In this case `%ctc_awesome%`.

```json
"commands": {
    "example": {
        "localized": false,
        "chat": [
            "%ctc_awesome%Awesome text line one!",
            "And there's a second line here"
        ]
    }
}
```

In order to use this color, it has to be defined first. This happens in the `variables.colors` area and looks like this:

```json
"variables": {
    "colors": {
        "ctc_awesome": [
            85,
            150,
            100,
            255
        ]
    }
}
```

`ctc_awesome` is the color name followed by an array of the color values (r,g,b,a). There is no specific naming scheme for variables. But you have to make sure, that it is unique and no string that occurs in your regular text.

There are two default colors `ctc_default` and `ctc_highlight` that can be overwritten. However these two colors don't have to be overwritte to be used.

## Adding Variables and Placeholders

In the next step, variables and placeholders are added. Variables are strings that can be substituted into the text, placeholders are predefined variables, that set specific values such as playername, time, ...

```json
"variables": {
    "strings": {
        "cooldudes": "friends"
    }
}
```

After such a string variable is defined, it can be used inside multiple commands. To use a variable in a command, it has to be surrounded by brackets (`{var_name}`).

```json
"commands": {
    "example": {
        "localized": false,
        "chat": [
            "%ctc_awesome%Awesome text line one!",
            "And there's a second line here",
            "You are %ctc_white%$p$%ctc_default% and you're playing with {cooldudes}!"
        ]
    }
}
```

In the third line of this chat message tweo colors, a placeholer `$p$` and a variable `cooldudes` is used. Right now there are three placeholders available: `$p$` (playername), `$s$` (servername/hostname), `$t$` (current time) and `$d$` (current date).

## Description

Additionally a `desc` tag is added to each command. It can be localized. This tag is used by the `ctc_defaults_list_all` command that prints all available commands to the chat. You can omitt this tag if you do not want to use a description. A command with a description looks like this:

```json
"commands": {
    "example": {
        "localized": false,
        "desc": {
            "text": "A neat example command.",
            "localized": false
        },
        "chat": [
            //...
        ]
    }
}
```

You can only use localization in this case. Variables, placeholders and colors are not allowed. However the commandname uses `ctc_highlight` and the command description uses `ctc_default` as colors. You can overwrite these colors if you want to use something different here.

## Localization

Most of the time you want to use localized strings. You have to set `localized` to `true` (or remove it all together) in order to use localization. Additionally a language object has to be defined. The previous defined example would look like this:

```json
"commands": {
    "example": {
        "localized": false,
        "desc": {
            "text": "ttt_ctc_example_desc"
        },
        "chat": [
            "ttt_ctc_example_line_1",
            "ttt_ctc_example_line_2",
            "ttt_ctc_example_line_3"
        ]
    }
},
"text": {
    "English": {
        "ttt_ctc_example_desc": "A neat example command.",
        "ttt_ctc_example_line_1": "%ctc_awesome%Awesome text line one!",
        "ttt_ctc_example_line_2": "And there's a second line here",
        "ttt_ctc_example_line_3": "You are %ctc_white%$p$%ctc_default% and you're playing with {cooldudes}!"
    },
    "Deutsch": {
        "ttt_ctc_example_desc": "Ein toller Beispielbefehl.",
        "ttt_ctc_example_line_1": "%ctc_awesome%Wunderbare Textzeile eins!",
        "ttt_ctc_example_line_2": "Und hier ist eine zweite Zeile",
        "ttt_ctc_example_line_3": "Du bist %ctc_white%$p$%ctc_default% und du spielst mit {cooldudes}!"
    }
}
```

## Console Commands

Additionally to chatprints, commands can be executed. This can be used to bind multiple console commands to a chatprint. The following example opens the TTT2 shopeditor and the ULX window:

```json
"commands": {
    "multicommand": {
        "desc": {
            "localized": false,
            "text": "Opens ULX and shopeditor"
        },
        "console": [
            "xgui",
            "shopeditor"
        ]
    }
}
```

Of course this can be combined with chat prints.

CTC provides one special command which is `ctc_defaults_list_all`. It is useful if you want to implement a chat command that prints all available chat commands, because it prints all commands in combination with the description. A help command without localizations would look like this:

```json
"commands": {
    "help": {
        "localized": false,
        "desc": {
            "localized": false,
            "text": "Lists all commands"
        },
        "chat": [
            "Here's a list of all available commands:"
        ],
        "console": [
            "ctc_defaults_list_all"
        ]
    }
}
```

**Hint:** It is important to note that this only works if you have the setting `run_first` set to `chat`. If you use `console`, the commandlist will be printed first.

Additionally commands can be used to call other chatcommands. If you have a serverinfo line defined in a chatcommand called `info` and you want to print it everytime a chatcommand is issued, just add `ctc_info` to the `console` list.

A neat sideeffect is that you are able to bind multiple console commands to one key by grouping them to a chatcommand (see the first example of this chapter). Now you can bind the new groupcommand to a key using `bind` or (in case you are using TTT2) use [Easy Custom Bindings](https://steamcommunity.com/sharedfiles/filedetails/?id=1673119444) in combination with the TTT2 binding system.

For a full example, check out the default generated command file in `garrysmod/data/ctc/commands.txt`.