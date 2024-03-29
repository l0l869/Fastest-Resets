Class Timer
{
    __New()
    {
        this.timeDisplayed := "0:00.000"
        loadTimerConfigs()

        global textTimer
        Gui, Timer:Show, % "x0 " . " y0" . " w" . A_ScreenWidth . " h" . A_ScreenHeight
        Gui, Timer:Font, % "s" . timerSize . " c" . timerColour . " q4", % timerFont
        Gui, Timer:Add, Text, x0 y0 w%A_ScreenWidth% vtextTimer, % this.timeDisplayed
        Gui, Timer:+AlwaysOnTop -Border -Caption +LastFound +ToolWindow
        Gui, Timer:Color, 000001
        WinSet, TransColor, 000001
        Gui, Timer:Show, x0 y0

        this.reset()
    }

    __Delete()
    {
        Gui, Timer:Destroy
    }

    reset()
    {
        if this.tickFunction
            this.stop()
        Sleep, 1
        this.startTick := 0
        this.elapsedTick := 0
        Gui, Timer:Default
        GuiControl,, textTimer, % this.FormatTime(0)
    }

    start()
    {
        this.startTick := A_TickCount

        if this.tickFunction
            return
        this.tickFunction := this.tick.Bind(this)
        tickFunction := this.tickFunction
        SetTimer, % tickFunction, % timerRefreshRate
    }

    stop()
    {
        if !this.tickFunction
            return 1
        tickFunction := this.tickFunction
        SetTimer, % tickFunction, Off

        this.tickFunction:=""
    }

    tick()
    {
        if timerAutoSplit
            this.checkAutoSplit()
        this.elapsedTick := A_TickCount-this.startTick
        GuiControl, Timer:, textTimer, % this.FormatTime(this.elapsedTick)
    }

    FormatTime(ms)
    {
        milliseconds := Mod(ms,1000)
        seconds := Mod(ms//1000,60)
        minutes := ms//60000

        if milliseconds < 10
            milliseconds := "00" . milliseconds
        else if milliseconds < 100
            milliseconds := "0" . milliseconds
        
        if seconds < 10
            seconds := "0" . seconds


        return this.timeDisplayed := minutes . ":" . seconds . "." . SubStr(milliseconds, 1, timerDecimalPlaces), this.anchorTo()
    }

    anchorTo()
    {
        getWinDimensions("Minecraft")

        textSize := this.getTextSize()
        switch (timerAnchor)
        {
            case "TopLeft":
                anchorX := winX+timerOffset[1]
                anchorY := winY+timerOffset[2]
            case "TopRight": 
                anchorX := winX2-textSize.W-timerOffset[1]
                anchorY := winY+timerOffset[2]
            case "BottomLeft":
                anchorX := winX+timerOffset[1]
                anchorY := WinY2-textSize.H-timerOffset[2]
            case "BottomRight":
                anchorX := winX2-textSize.W-timerOffset[1]
                anchorY := winY2-textSize.H-timerOffset[2]
        }

        GuiControl, Timer:Move, textTimer, % "x" . anchorX " y" . anchorY
    }

    checkAutoSplit()
    {
        ;##################### Old Method ######################
        ; baseOffset := ""
        ; if (offsetsCoords[1] == 0x036A3C18)
        ;     baseOffset := 0x036AB670 ;1.16.10

        ; if (offsetsCoords[1] == 0x0369D0A8)
        ;     baseOffset := 0x036A4B00 ;1.16.1

        ; if (baseOffset && MCproc.read(MCproc.baseAddress + baseOffset, "Char", 0x28, 0x198, 0x10, 0x150, 0x798) == 2)
        ;     this.stop()

        PixelGetColor, colourCode, winX2-1, winY2-1 ,RGB
        if (colourCode == 0x241200)
            this.stop()
    }

    getTextSize(){
        ; GuiControlGet textSize, Timer:Pos, textTimer
        Gui, textSizeGUI:Font, % "s"timerSize, % timerFont
        Gui, textSizeGUI:Add, Text,, % this.timeDisplayed
        GuiControlGet textSize, textSizeGUI:Pos, Static1
        Gui, textSizeGUI:Destroy

        return {W: textSizeW, H:textSizeH}
    }
}

getWinDimensions(Window)
{
    WinGet, style, Style, %Window%
    isFullscreen := !(style & 0x20800000)
    if isFullscreen
    {
        winX := 0
        winY := 0
        winWidth := A_ScreenWidth
        winHeight := A_ScreenHeight
        winX2 := winX+winWidth
        winY2 := winY+winHeight
        return
    }

    WinGetPos, winX, winY, winWidth, winHeight, %Window%
    winScaling := A_ScreenDPI/96
    winX += 8*winScaling
    winY += 38*winScaling
    winWidth -= 16*winScaling
    winHeight -= 38*winScaling
    winX2 := winX+winWidth
    winY2 := winY+winHeight
}