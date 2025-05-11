#!/bin/bash
# ICON: rainbowchordboard

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR=/$directory/MUOS/application/RainbowChordBoard
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [[ "${DEVICE_NAME^^}" == *'RG35XX'*'SP'* ]] || [[ "${DEVICE_NAME^^}" == *'RG28XX'* ]]; then
    GPTOKEYB_CONFIG="./rainbowchordboard-nosticks.gptk"  
else
    GPTOKEYB_CONFIG="./rainbowchordboard.gptk"
fi

cd $GAMEDIR

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "love" -c "$GPTOKEYB_CONFIG" &
./love rainbowchordboard

$ESUDO kill -9 $(pidof gptokeyb)


