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
            "fontStyle": "Gohu Nerd Font"
        },
        "PB" : {
            "primaryColor": '#F48DB9',
            "secondaryColor": '#D8579E',
            "tertiaryColor": '#E9B653',
            "quaternaryColor": '#DC635A',
            "backgroundColor": '#FED7D5',
            "defaultTextColor": '#7A4D69',
            "textBorderColor": '#7A4D69',
            "fontStyle": "Gohu Nerd Font"
        }
    }

}
