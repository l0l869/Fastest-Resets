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

StartTimer:
    if Timer1
        Timer1.start()
Return

StopTimer:
    if Timer1
        Timer1.stop()
return

inGameReset()
{
    runAttempts := updateAttempts()
    if autoRestart
        shouldRestart(runAttempts)


    ; working concept for now

    IniRead, BTN_SaveAndQuit   , %iniFile%, Buttons, SaveAndQuit
    IniRead, BTN_CreateNew     , %iniFile%, Buttons, CreateNew
    IniRead, BTN_CreateNewWorld, %iniFile%, Buttons, CreateNewWorld
    IniRead, BTN_Normal        , %iniFile%, Buttons, Normal
    IniRead, BTN_Easy          , %iniFile%, Buttons, Easy
    IniRead, BTN_Seed          , %iniFile%, Buttons, Seed
    IniRead, BTN_Simulation    , %iniFile%, Buttons, Simulation
    IniRead, BTN_Create        , %iniFile%, Buttons, Create

    BTN_SaveAndQuit    := StrSplit(BTN_SaveAndQuit, ",")
    BTN_CreateNew      := StrSplit(BTN_CreateNew, ",")
    BTN_CreateNewWorld := StrSplit(BTN_CreateNewWorld, ",")
    BTN_Normal         := StrSplit(BTN_Normal, ",")
    BTN_Easy           := StrSplit(BTN_Easy, ",")
    BTN_Seed           := StrSplit(BTN_Seed, ",")
    BTN_Simulation     := StrSplit(BTN_Simulation, ",")
    BTN_Create         := StrSplit(BTN_Create, ",")

    Buttons := [BTN_SaveAndQuit,BTN_CreateNew,BTN_CreateNewWorld,BTN_Normal,BTN_Easy,BTN_Seed,BTN_Simulation,BTN_Create]

    While (isResetting)
    {
        For k, BTN in Buttons
        {
            PixelGetColor, isColourBTN, BTN[1], BTN[2], RGB
            if (isColourBTN == BTN[3])
            {
                Click % BTN[1] BTN[2]
                Sleep, %keyDelay%
            }
        }

        ; MouseMove, winX+winWidth/2, winY+winHeight/2
        ; Sleep, 500

        ; xCoord := getValue("Float", offsetsCoords*)
        ; Log("Run #" . runAttempts . " - X: " . xCoord . ", xMin: " . minCoords . ", xMax: " . maxCoords . ", Offset: " . offsetsCoords[1] . ", bAddress: " . MCproc.baseAddress)
        
        ; if (autoReset && (xCoord < minCoords || xCoord > maxCoords))
        ;     return inGameReset()

        ; if Timer1
        ; {
        ;     isResetting := 2
        ;     threadWaitForMovement := Func("waitForMovement")
        ;     setTimer, % threadWaitForMovement, -0 ; new thread
        ; }

        ; if (autoReset && FileExist("assets/alert.wav"))
        ;     SoundPlay, assets/alert.wav

        ; break

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