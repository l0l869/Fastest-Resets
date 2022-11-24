; this code is bad but it'll do for now

#Include ClassMem.ahk

SetTitleMatchMode, 3
global Minecraft
global DynPtrBaseAddr := 0
global xCoord := 0
return

resetInGame:
    IfWinNotExist, Minecraft
    {
        MsgBox,4,, Minecraft is not open, do you want to launch?
        IfMsgBox, Yes
            Gosub, RestartMC
        return
    }
    IfWinActive, Minecraft
    {
        IniRead, selectedSeed, %iniFile%, Settings, seedSelected
        Minecraft := "" ; close handle of old mc
        Minecraft := new _ClassMemory("ahk_exe Minecraft.Windows.exe", "PROCESS_VM_READ")
        DynPtrBaseAddr := Minecraft.baseAddress + 0x0369D0A8 ;ptr to xcoords

        inGameReset()
    }
return

restartMC:
    WinClose, Minecraft
    Run, shell:AppsFolder\Microsoft.MinecraftUWP_8wekyb3d8bbwe!App
Return

findButton(btn, bx := 0, by := 0, dx := 1920, dy := 1080)
{
    Loop, {
        ImageSearch, X, Y, bx, by, bx+dx, by+dy, assets/%btn%.png
        if ErrorLevel = 0
        {
            Click, %X% %Y%
            return 1
        }
        Sleep, 1

        if A_Index > 200
        {
            MsgBox, Couldn't find %btn%, try doing setup to calibrate
            return 0
        }
    }
}

inGameReset()
{
    MouseGetPos, prevX, prevY
    Send, {Esc}
    if !findButton("Quit")
        return
    Sleep, 1500

    IniRead, cn, %iniFile%, Macro, CreateNew
    boundsBtn := StrSplit(cn, A_Space)
    if !findButton("CreateNew", boundsBtn[1], boundsBtn[2], 500, 500)
        return
    Sleep, %delay%

    IniRead, cn, %iniFile%, Macro, CreateNewWorld
    boundsBtn := StrSplit(cn, A_Space)
    if !findButton("CreateNewWorld", boundsBtn[1], boundsBtn[2], 750, 500)
        return
    Sleep, %delay%

    IniRead, cn, %iniFile%, Macro, Easy
    boundsBtn := StrSplit(cn, A_Space)
    if !findButton("Easy", boundsBtn[1], boundsBtn[2], 400, 400)
        return
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
        IniRead, cn, %iniFile%, Macro, Heart
        boundsBtn := StrSplit(cn, A_Space)

        Sleep, 1500
        Loop, {
            ImageSearch, X, Y, boundsBtn[1], boundsBtn[2], A_ScreenWidth, A_ScreenWidth , assets/Heart.png
            if ErrorLevel = 0
                break
                
            if A_Index = 100 ; redefines heart bounds if current doesnt meet
            {
                boundsBtn := [0,0]
            }

            if A_Index > 200
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

        IniWrite, %X% %Y%, %iniFile%, Macro, Heart
    }
}