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
    WinGetPos, X, Y, Width, Height, Minecraft
    runAttempts := updateAttempts()
    if autoRestart
        shouldRestart(runAttempts)

    Send, {Esc}
    waitImage("") ; Quit
    MouseClick,, X+10, Y+30+(Height-30)*.05,,0
    Sleep, 1500

    waitImage("") ; CreateNew
    MouseClick,, X+10, Y+30+(Height-30)*.05,,0
    Sleep, %keyDelay%

    waitImage("") ; CreateNewWorld
    MouseClick,, X+10, Y+30+(Height-30)*.05,,0
    Sleep, %keyDelay%

    waitImage("") ; Easy
    MouseClick,, X+10, Y+30+(Height-30)*.05,,0
    Sleep, %keyDelay%

    MouseClick,, X+10, Y+30+(Height-30)*.1,,0                     ;Coords
    Sleep, %keyDelay%

    MouseClick,, X+10, Y+30+(Height-30)*15,,0                     ;SimDis
    Sleep, %keyDelay%

    if setSeed
    {
        MouseClick,, X+10, Y+30+(Height-30)*.2,,0                 ;Seed
        Sleep, 1
        IniRead, selectedSeed, %iniFile%, Settings, selectedSeed
        Send, %selectedSeed%
        Sleep, %keyDelay%
    }

    MouseClick,, X+10, Y+30+(Height-30)*.25,,0                     ;Create
    MouseMove, X+Width/2, Y+Height/2

    if autoReset
    {        
        waitImage("") ; Heart

        xCoord := mcProc.read(mcProc.baseAddress + 0x0369D0A8, "Float", 0xA8, 0x10, 0x954)
            if (xCoord < minCoords Or xCoord > maxCoords)
                inGameReset()
            else
                SoundBeep, 1000
    }
}

waitImage(image, dx := 1920, dy := 1080, attempts := 200, findDelay := 1)
{
    Loop, {
        if A_Index > %attempts%
        {
            MsgBox, Couldn't find %image%
            runAttempts := updateAttempts(-1)
            Exit
        }
        ImageSearch, X, Y, 0, 0, dx, dy, assets/%image%.png
        if ErrorLevel = 0
            return 1
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