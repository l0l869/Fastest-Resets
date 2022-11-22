; this code is bad but it'll do for now

global Minecraft
global DynPtrBaseAddr := 0
global xCoord := 0
return

resetInGame:
    IfWinNotExist, Minecraft
    {
        MsgBox,4,, Minecraft is not open, Do you want to Launch?
        IfMsgBox, Yes
            RestartMinecraft()
        return
    }
    IniRead, selectedSeed, %iniFile%, Settings, seedSelected
    Minecraft := "" ; close handle of old mc
    Minecraft := new _ClassMemory("ahk_exe Minecraft.Windows.exe", "", hProcessCopy)
    DynPtrBaseAddr := Minecraft.baseAddress + 0x0369D0A8 ;ptr to xcoords

    inGameReset()
return

restartMC:
    RestartMinecraft()
Return

inGameReset()
{
    MouseGetPos, prevX, prevY
    Send, {Esc}
    Sleep, 20
    Loop, {
        ImageSearch, X, Y, 100, 100, A_ScreenWidth, A_ScreenHeight, assets/Quit.png
        if ErrorLevel = 0
        {
            Click, %X% %Y%
            break
        }
        Sleep, 1

        if A_Index > 200
        {
            MsgBox, Couldn't find button
            return
        }
    }
    Sleep, 1500

    IniRead, cn, %iniFile%, Macro, CreateNew
    btn := StrSplit(cn, A_Space)
    Loop, {
        ImageSearch, X, Y, btn[1], btn[2], btn[1]+750, btn[2]+400, assets/CreateNew.png
        if ErrorLevel = 0
        {
            Click, %X% %Y%
            break
        }
        Sleep, 1

        if A_Index > 200
        {
            MsgBox, Couldn't find button
            return
        }
    }
    Sleep, %delay%

    IniRead, cn, %iniFile%, Macro, CreateNewWorld
    btn := StrSplit(cn, A_Space)
    Loop, {
        ImageSearch, X, Y, btn[1], btn[2], btn[1]+750, btn[2]+400, assets/CreateNewWorld.png
        if ErrorLevel = 0
        {
            Click, %X% %Y%
            break
        }
        Sleep, 1

        if A_Index > 200
        {
            MsgBox, Couldn't find button
            return
        }
    }
    Sleep, %delay%

    IniRead, cn, %iniFile%, Macro, Easy
    btn := StrSplit(cn, A_Space)
    Loop, {
        ImageSearch, X, Y, btn[1], btn[2], btn[1]+750, btn[2]+400, assets/Easy.png
        if ErrorLevel = 0
        {
            Click, %X% %Y%        ;Easy
            break
        }
        Sleep, 1

        if A_Index > 200
        {
            MsgBox, Couldn't find button
            return
        }
    }
    Sleep, %delay%

    IniRead, cn, %iniFile%, Macro, Coords
    Click, %cn%                     ;Coords

    Sleep, %delay%

    IniRead, cn, %iniFile%, Macro, SimDis
    Click, %cn%                     ;SimDis

    Sleep, %delay%

    if setSeed
    {
        IniRead, cn, %iniFile%, Macro, Seed
        Click, %cn%                 ;Seed
        Sleep, 1
        Send, %selectedSeed%
        Sleep, %delay%
    }

    IniRead, cn, %iniFile%, Macro, Create
    Click, %cn%                     ;Create
    MouseMove, %prevX%, %prevY%

    if autoReset
    {
        Sleep, 1500
        Loop, {
            ImageSearch, X, Y, 500, 500, 1920, 1080 , assets/Heart.png
            if ErrorLevel = 0
                break
            Sleep, 1

            if A_Index > 1000
            {
                MsgBox, Couldn't detect in world
               return
            }
        }
        xCoord := Minecraft.read(DynPtrBaseAddr, "Float", 0xA8, 0x10, 0x954)
        if (xCoord < minCoords Or xCoord > maxCoords)
            inGameReset()
        else
            SoundBeep, 1000
    }
}

startUp()
{
    IfWinNotExist, Minecraft
    {
        Run, shell:AppsFolder\Microsoft.MinecraftUWP_8wekyb3d8bbwe!App
    }
    Sleep, 2000
    ; Minecraft := "" ; close handle of old mc
    ; Minecraft := new _ClassMemory("ahk_exe Minecraft.Windows.exe", "", hProcessCopy)
    ; DynPtrBaseAddr := Minecraft.baseAddress + 0x0369D0A8
    WinMaximize, "Minecraft"
}

RestartMinecraft()
{
    WinClose, Minecraft
    Run, shell:AppsFolder\Microsoft.MinecraftUWP_8wekyb3d8bbwe!App
    startUp()
}