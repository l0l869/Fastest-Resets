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
        Minecraft := "" ; close handle of old mc
        Minecraft := new _ClassMemory("ahk_exe Minecraft.Windows.exe", "PROCESS_VM_READ")
        DynPtrBaseAddr := Minecraft.baseAddress + 0x0369D0A8 ;ptr to player's x coords

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
    findButton("Quit")
    Sleep, 1500

    IniRead, iniBtn, %iniFile%, Macro, CreateNew
    boundsBtn := StrSplit(iniBtn, A_Space)
    findButton("CreateNew", boundsBtn[1], boundsBtn[2], 500, 500)
    Sleep, %keyDelay%

    IniRead, iniBtn, %iniFile%, Macro, CreateNewWorld
    boundsBtn := StrSplit(iniBtn, A_Space)
    findButton("CreateNewWorld", boundsBtn[1], boundsBtn[2], 750, 500)
    Sleep, %keyDelay%

    IniRead, iniBtn, %iniFile%, Macro, Easy
    boundsBtn := StrSplit(iniBtn, A_Space)
    findButton("Easy", boundsBtn[1], boundsBtn[2], 400, 400)
    Sleep, %keyDelay%

    IniRead, iniBtn, %iniFile%, Macro, Coords
    Click, %iniBtn%                     ;Coords
    Sleep, %keyDelay%

    IniRead, iniBtn, %iniFile%, Macro, SimDis
    Click, %iniBtn%                     ;SimDis
    Sleep, %keyDelay%

    if setSeed
    {
        IniRead, iniBtn, %iniFile%, Macro, Seed
        Click, %iniBtn%                 ;Seed
        Sleep, 1
        IniRead, selectedSeed, %iniFile%, Settings, selectedSeed
        Send, %selectedSeed%
        Sleep, %keyDelay%
    }

    IniRead, iniBtn, %iniFile%, Macro, Create
    Click, %iniBtn%                     ;Create
    MouseMove, %prevX%, %prevY%

    if autoReset
    {
        IniRead, iniBtn, %iniFile%, Macro, Heart
        boundsBtn := StrSplit(iniBtn, A_Space)

        IniRead, worldGenTimeSleep, %iniFile%, Macro, WorldGenTime
        Sleep, worldGenTimeSleep - 1000 ; -1000: incase world loads faster than expected
        
        findButton("Heart", boundsBtn[1], boundsBtn[2], 2, 2, 1000, -1, false)

        xCoord := Minecraft.read(DynPtrBaseAddr, "Float", 0xA8, 0x10, 0x954)
            if (xCoord < minCoords Or xCoord > maxCoords)
                inGameReset()
            else
                SoundBeep, 1000
    }
}

findButton(btn, bx := 0, by := 0, dx := 1920, dy := 1080, attempts := 200, findDelay := 1, doClick := true)
{
    Loop, {
        if A_Index > %attempts%
        {
            MsgBox, Couldn't find %btn%, try doing setup to calibrate
            updateAttempts(-1)
            Exit
        }
        ImageSearch, X, Y, bx, by, bx+dx, by+dy, assets/%btn%.png
        if ErrorLevel = 0
        {
            if doClick
                Click, %X% %Y%
            return 1
        }
        Sleep, %findDelay%
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
    
    GuiControl,, attemptsText, #Attempts: %attempts% ; doesnt update if win isnt active
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