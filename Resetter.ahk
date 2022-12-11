#Include ClassMem.ahk

SetTitleMatchMode, 3
global Minecraft
global DynPtrBaseAddr := 0
global xCoord := 0
global lastRestart
Exit

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
        IniRead, selectedSeed, %iniFile%, Settings, selectedSeed
        Minecraft := "" ; close handle of old mc
        Minecraft := new _ClassMemory("ahk_exe Minecraft.Windows.exe", "PROCESS_VM_READ")
        DynPtrBaseAddr := Minecraft.baseAddress + 0x0369D0A8 ;ptr to xcoords

        inGameReset()
    }
return

restartMC:
    WinClose, Minecraft
    Run, shell:AppsFolder\Microsoft.MinecraftUWP_8wekyb3d8bbwe!App
    lastRestart := updateAttempts(0)
Return

inGameReset()
{
    attemptsCount := updateAttempts()
    if autoRestart
        shouldRestart(attemptsCount)

    MouseGetPos, prevX, prevY
    Send, {Esc}
    if !findButton("Quit")
        return
    Sleep, 1500

    IniRead, cn, %iniFile%, Macro, CreateNew
    boundsBtn := StrSplit(cn, A_Space)
    if !findButton("CreateNew", boundsBtn[1], boundsBtn[2], 500, 500)
        return
    Sleep, %keyDelay%

    IniRead, cn, %iniFile%, Macro, CreateNewWorld
    boundsBtn := StrSplit(cn, A_Space)
    if !findButton("CreateNewWorld", boundsBtn[1], boundsBtn[2], 750, 500)
        return
    Sleep, %keyDelay%

    IniRead, cn, %iniFile%, Macro, Easy
    boundsBtn := StrSplit(cn, A_Space)
    if !findButton("Easy", boundsBtn[1], boundsBtn[2], 400, 400)
        return
    Sleep, %keyDelay%

    IniRead, cn, %iniFile%, Macro, Coords
    Click, %cn%                     ;Coords
    Sleep, %keyDelay%

    IniRead, cn, %iniFile%, Macro, SimDis
    Click, %cn%                     ;SimDis
    Sleep, %keyDelay%

    if setSeed
    {
        IniRead, cn, %iniFile%, Macro, Seed
        Click, %cn%                 ;Seed
        Sleep, 1
        Send, %selectedSeed%
        Sleep, %keyDelay%
    }

    IniRead, cn, %iniFile%, Macro, Create
    Click, %cn%                     ;Create
    MouseMove, %prevX%, %prevY%

    if autoReset
    {
        IniRead, cn, %iniFile%, Macro, Heart
        boundsBtn := StrSplit(cn, A_Space)

        IniRead, worldGenTimeSleep, %iniFile%, Macro, WorldGenTime
        Sleep, worldGenTimeSleep - 1000
        
        Loop, {
            ImageSearch, X, Y, boundsBtn[1], boundsBtn[2], boundsBtn[1]+2, boundsBtn[2]+2, assets/Heart.png
            if ErrorLevel = 0
                break

            if A_Index > 1000 ; about 5s
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

findButton(btn, bx := 0, by := 0, dx := 1920, dy := 1080)
{
    Loop, {
        ImageSearch, X, Y, bx, by, bx+dx, by+dy, assets/%btn%.png
        if ErrorLevel = 0
        {
            Click, %X% %Y%
            return 1
        }
        if A_Index > 200
        {
            MsgBox, Couldn't find %btn%, try doing setup to calibrate
            updateAttempts(-1)
            return 0
        }
        Sleep, 1
    }
}

updateAttempts(amount := 1)
{
    txt := FileOpen("configs/attempts.txt", "r") ; open/reads txt
    attempts := txt.Read() + amount
    if amount != 0
    {
        txt := FileOpen("configs/attempts.txt", "w") ; overwrites txt
        txt.Write(attempts)
    }
    txt.Close()
    
    GuiControl,, attemptsText, #Attempts: %attempts%
    return attempts
}

shouldRestart(resetCounter)
{
    if !lastRestart
    {
        lastRestart := resetCounter
        return false
    }

    if (resetCounter >= lastRestart + resetThreshold)
    {
        updateAttempts(-1)
        Gosub, RestartMC ;lastRestart redefines 
        Exit
     }
}