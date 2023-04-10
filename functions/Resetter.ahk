#Include functions/ClassMem.ahk
#Include functions/Timer copy.ahk
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
        MCproc := "" ; close handle of old mc
        MCproc := new _ClassMemory("ahk_exe Minecraft.Windows.exe", "PROCESS_VM_READ")

        WinGetPos, winX, winY, winWidth, winHeight, Minecraft
        winX += 8
        winY += 30
        winWidth -= 16
        winHeight -= 38
        winX2 := winX+winWidth
        winY2 := winY+winHeight

        if !Timer1
            Timer1 := new Timer(25,25,"TopRight",0,35,"MOJANGLES")
        Else
            Timer1.reset()

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

    Send, {Esc}
    waitUntil(Func("findPixel"),,,0xF54242,winX2-20,winY2-20,40,40) ; Quit
    Sleep, 25
    MouseClick,, winX+2, winY+winHeight*.025,,0

    waitUntil(Func("findPixel"),,,0xF57B42,winX2-20,winY2-20,40,40) ; CreateNew
    MouseClick,, winX+2, winY+winHeight*.025,,0
    Sleep, %keyDelay%

    waitUntil(Func("findPixel"),,,0xF5D742,winX2-20,winY2-20,40,40) ; CreateNewWorld
    MouseClick,, winX+2, winY+winHeight*.025,,0
    Sleep, %keyDelay%

    waitUntil(Func("findPixel"),,,0x4E42F5,winX2-20,winY2-20,40,40)
    MouseClick,, winX+2, winY+winHeight*.025,,0                     ; Easy
    Sleep, %keyDelay%

    MouseClick,, winX+2, winY+winHeight*.075,,0                     ; Coords
    Sleep, %keyDelay%

    MouseClick,, winX+2, winY+winHeight*.125,,0                     ; SimDis
    Sleep, %keyDelay%

    if setSeed
    {
        MouseClick,, winX+2, winY+winHeight*.175,,0                 ; Seed
        Sleep, 1
        IniRead, selectedSeed, %iniFile%, Settings, selectedSeed
        Send, %selectedSeed%
        Sleep, %keyDelay%
    }

    MouseClick,, winX+2, winY+winHeight*.225,,0                     ; Create
    MouseMove, winX+winWidth/2, winY+winHeight/2

    waitUntil(Func("findPixel"),15000,,0x9234EB,winX2-20,winY2-20,40,40)
    xCoord := getValue("Float", offsetsCoords*).value
    Log("Run #" . runAttempts . ": " . xCoord)
    
    if ((xCoord < minCoords Or xCoord > maxCoords) && autoReset)
        return inGameReset()

    if (Timer1 && waitUntil(Func("changedValue"),,, xCoord, "Float", offsetsCoords*))   ;hijaks thread bad
        Timer1.start()
}

findImage(image,x,y,dx,dy)
{
    ImageSearch, outX, outY, x, y, x+dx, y+dy, assets/%image%.png
    return {status: !ErrorLevel, X: outX, Y: outY}
}

findPixel(colour,x,y,dx,dy)
{
    PixelSearch, outX, outY, x, y, x+dx, y+dy, colour, 3, RGB Fast
    return {status: !ErrorLevel, X: outX, Y: outY}
}

getValue(dataType, baseOffset, offsets*)
{
    value := MCproc.read(MCproc.baseAddress + baseOffset, dataType, offsets*)
    if (value < 100000 && 0 < value)
        return {status: 1, value: value} 
}

changedValue(Tvalue, dataType, baseOffset, offsets*)
{
    value := MCproc.read(MCproc.baseAddress + baseOffset, dataType, offsets*)
    if ((value != Tvalue || (GetKeyState("W") || GetKeyState("S"))) && (value < 100000 && 0 < value))
        return {status: 1, value: value}
}

waitUntil(Function, waitTime := 15000, checkDelay := 1, Args*)    ; byRef Args* does not work sad
{
    waitTime += A_TickCount
    Loop, {
        if A_TickCount >= %waitTime%
        {
            MsgBox, Timed Out!
            runAttempts := updateAttempts(-1)
            Exit
        }
        returnValue := %Function%(Args*)    ; wow this is bad
        if returnValue.status
            return returnValue
        Sleep, %checkDelay%
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