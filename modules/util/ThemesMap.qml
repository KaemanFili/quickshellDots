import QtQuick
//this doesn't get used anymore, but its a good reference so I can see the colors I'm using.
QtObject {
    id: themes
    property var map: {
        
        "BMO" : {
            "primaryColor": '#86d8ab',
            "secondaryColor": '#d0da4b',
            "tertiaryColor": '#992c24',
            "quaternaryColor": '#0c6b09',
            "backgroundColor": '#43856c',
            "defaultTextColor": '#2828a5',
            "textBorderColor": '#201d1d',
            "fontStyle": "Gohu Nerd Font",
            "wallpaperPath": "wallpapers/retro-BMO.jpg"
        },
        "PB" : {
            "primaryColor": '#F48DB9',
            "secondaryColor": '#D8579E',
            "tertiaryColor": '#E9B653',
            "quaternaryColor": '#DC635A',
            "backgroundColor": '#FED7D5',
            "defaultTextColor": '#7A4D69',
            "textBorderColor": '#7A4D69',
            "fontStyle": "Gohu Nerd Font",
            "wallpaperPath": "wallpapers/PB.jpg"
        },
        "IK" : {
            "primaryColor": '#75DFF0',
            "secondaryColor": '#0000E8',
            "tertiaryColor": '#FFD33B',
            "quaternaryColor": '#C51F4A',
            "backgroundColor": '#3CA8D7',
            "defaultTextColor": '#092A5B',
            "textBorderColor": '#051D43',
            "fontStyle": "Gohu Nerd Font",
            "wallpaperPath": "wallpapers/IK.png"
        }
    }

}
