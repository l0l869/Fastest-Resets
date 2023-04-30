#Include functions/ClassMem.ahk
#Include functions/Timer.ahk
Exit

ResetInGame:
    if !WinActive("Minecraft")
    {
        ; awkward substitute fix for #ifwinactive 
        IniRead, iniKey, %iniFile%, Hotkeys, Reset
        Hotkey, %iniKey%, ResetInGame, Off
        Send, %iniKey%
        Hotkey, %iniKey%, ResetInGame, On
        return
    }

    isResetting := 1

    MCproc := "" ; close handle of old mc
    MCproc := new _ClassMemory("ahk_exe Minecraft.Windows.exe", "PROCESS_VM_READ")

    if Timer1
        Timer1.reset()

    if !timerActivated
        Timer1 := ""

    if (!Timer1 && timerActivated)
        global Timer1 := new Timer()

    getWinDimensions("Minecraft")

    inGameReset()
return

RestartMC:
    WinClose, Minecraft
    Run, shell:AppsFolder\Microsoft.MinecraftUWP_8wekyb3d8bbwe!App
    lastRestart := updateAttempts(0)
Return

StopReset:
    isResetting := 0
return

inGameReset()
{
    runAttempts := updateAttempts()
    if autoRestart
        shouldRestart(runAttempts)

    While (isResetting)
    {
        PixelGetColor, colourCode, winX2-1, winY2-1 ,RGB
        Switch colourCode
        {
            default:
                if (A_Index == 1)
                {
                    Send, {Esc}
                    Sleep, 75
                }

            case 0xF54242:
                MouseClick,, winX+3, winY+winHeight*.025,,0
                Sleep, %keyDelay%

            case 0xF57B42:
                MouseClick,, winX+3, winY+winHeight*.025,,0
                Sleep, %keyDelay%

            case 0xF5D742:
                MouseClick,, winX+3, winY+winHeight*.025,,0
                Sleep, %keyDelay%

            case 0x4E42F5:
                MouseClick,, winX+3, winY+winHeight*.025,,0
                Sleep, %keyDelay%
                MouseClick,, winX+3, winY+winHeight*.075,,0
                Sleep, %keyDelay%
                MouseClick,, winX+3, winY+winHeight*.125,,0
                Sleep, %keyDelay%

                if setSeed
                {
                    MouseClick,, winX+3, winY+winHeight*.175,,0
                    Sleep, 1
                    IniRead, selectedSeed, %iniFile%, Settings, selectedSeed
                    Send, %selectedSeed%
                    Sleep, %keyDelay%
                }

                MouseClick,, winX+3, winY+winHeight*.225,,0
                MouseMove, winX+winWidth/2, winY+winHeight/2
                Sleep, 500

            case 0x9234EB:
                if(A_Index == 1)
                {
                    Send, {Esc}
                    Sleep, 150
                    Continue
                }

                xCoord := getValue("Float", offsetsCoords*)
                Log("Run #" . runAttempts . " - X: " . xCoord . ", xMin: " . minCoords . ", xMax: " . maxCoords . ", Offset: " . offsetsCoords[1] . ", bAddress: " . MCproc.baseAddress)
                
                if (autoReset && (xCoord < minCoords || xCoord > maxCoords))
                    return inGameReset()

                if Timer1
                {
                    isResetting := 2
                    threadWaitForMovement := Func("waitForMovement")
                    setTimer, % threadWaitForMovement, -0 ; new thread
                }

                if (autoReset && FileExist("assets/alert.wav"))
                    SoundPlay, assets/alert.wav

                break
        }

        if !WinActive("Minecraft")
            break
    }

    if !Timer1
        isResetting := 0
}

waitForMovement()
{
    While(isResetting == 2)
    {
        newCoord := getValue("Float", offsetsCoords*)
        hasInputted := (GetKeyState("W") || GetKeyState("A") || GetKeyState("S") || GetKeyState("D") || GetKeyState("Space"))
        if (xCoord != newCoord || hasInputted)
        {
            Timer1.start()
            return isResetting := 0
        }
    }
}

getValue(dataType, baseOffset, offsets*)
{
    While (!value)
	{
    	value := MCproc.read(MCproc.baseAddress + baseOffset, dataType, offsets*)
    	if (value < 100000 && 0 < value)
        	return value

        if (A_Index > 3000)
            break
	}
    Log("Value: " . value . ", PID: " . MCproc.PID . ", " . MCproc.currentProgram . ", bAddress: " . MCproc.baseAddress . " + " . baseOffset)
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
    
    GuiControl, MainWin:, textAttempts, #Attempts: %attempts% 
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