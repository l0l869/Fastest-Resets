#Include functions/ClassMem.ahk
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
        mcProc := "" ; close handle of old mc
        mcProc := new _ClassMemory("ahk_exe Minecraft.Windows.exe", "PROCESS_VM_READ")
        DynPtrBaseAddr := mcProc.baseAddress + 0x0369D0A8 ;ptr to player's x coords

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
    runAttempts := updateAttempts()
    if autoRestart
        shouldRestart(runAttempts)

    MouseGetPos, prevX, prevY
    Send, {Esc}
    findButton("Quit", 400, 400)
    Sleep, 1500

    findButton("CreateNew", 500, 500)
    Sleep, %keyDelay%

    findButton("CreateNewWorld", 750, 500)
    Sleep, %keyDelay%

    findButton("Easy", 400, 400)
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
        IniRead, worldGenTimeSleep, %iniFile%, Macro, WorldGenTime
        Sleep, worldGenTimeSleep - 1000 ; -1000: incase world loads faster than expected
        
        findButton("Heart", 2, 2, 1000, -1, false)

        xCoord := mcProc.read(DynPtrBaseAddr, "Float", 0xA8, 0x10, 0x954)
            if (xCoord < minCoords Or xCoord > maxCoords)
                inGameReset()
            else
                SoundBeep, 1000
    }
}

findButton(btn, dx := 1920, dy := 1080, attempts := 200, findDelay := 1, doClick := true)
{
    IniRead, iniBtn, %iniFile%, Macro, %btn%
    boundsBtn := StrSplit(iniBtn, A_Space)

    Loop, {
        if A_Index > %attempts%
        {
            MsgBox, Couldn't find %btn%, try doing setup to calibrate
            runAttempts := updateAttempts(-1)
            Exit
        }
        ImageSearch, X, Y, boundsBtn[1], boundsBtn[2], boundsBtn[1]+dx, boundsBtn[2]+dy, assets/%btn%.png
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
    
    GuiControl,, textAttempts, #Attempts: %attempts% ; doesnt update if win isnt active
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