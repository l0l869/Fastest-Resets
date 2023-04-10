Class Timer
{
    __New(x, y, anchorPosition := "TopLeft", refreshRate := 20, fontSize := 30, Font := "")
    {
        this.timerX := x
        this.timerY := y
        this.anchorPosition := anchorPosition
        this.refreshRate := refreshRate
        this.Font := Font
        this.fontSize := fontSize
        this.timeDisplayed := "0:00.000"

        global textTimer
        Gui, Timer:Show, % "x0 " . " y0" . " w" . A_ScreenWidth . " h" . A_ScreenHeight
        Gui, Timer:Font, % "s" . this.fontSize . " cFFFFFF " . " q4", % this.Font
        Gui, Timer:Add, Text, x0 y0 w%A_ScreenWidth% vtextTimer, 0:00.000
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

        this.tickFunction := this.tick.Bind(this)
        tickFunction := this.tickFunction
        SetTimer, % tickFunction, % this.refreshRate
    }

    stop()
    {
        if !this.tickFunction
            return 1
        tickFunction := this.tickFunction
        SetTimer, % tickFunction, -0

        this.tickFunction:=""
    }

    tick()
    {
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


        return this.timeDisplayed := minutes . ":" . seconds . "." . SubStr(milliseconds, 1, 3), this.anchorTo()
    }

    anchorTo()
    {
        textSize := this.getTextSize()
        switch (this.anchorPosition)
        {
            case "TopLeft":
                anchorX := winX+this.timerX
                anchorY := winY+this.timerY
            case "TopRight": 
                anchorX := winX2-textSize.W-this.timerX
                anchorY := winY+this.timerY
            case "BottomLeft":
                anchorX := winX+this.timerX
                anchorY := WinY2-textSize.H-this.timerY
            case "BottomRight":
                anchorX := winX2-textSize.W-this.timerX
                anchorY := winY2-textSize.H-this.timerY
        }

        GuiControl, Timer:Move, textTimer, % "x" . anchorX " y" . anchorY
    }

    getTextSize(){
        ; GuiControlGet textSize, Timer:Pos, textTimer
        Gui, textSizeGUI:Font, % "s"this.fontSize, % this.Font
        Gui, textSizeGUI:Add, Text,, % this.timeDisplayed
        GuiControlGet textSize, textSizeGUI:Pos, Static1
        Gui, textSizeGUI:Destroy

        return {W: textSizeW, H:textSizeH}
    }
}

SetTimer, renew, 0 ; temporary

renew:
WinGetPos, winX, winY, winWidth, winHeight, Minecraft
global winX += 8
global winY += 30
global winWidth -= 16
global winHeight -= 38
global winX2 := winX+winWidth
global winY2 := winY+winHeight

if (MCproc.read(MCproc.baseAddress + 0x036A4B00, "Char", 0x28, 0x198, 0x10, 0x150, 0x798) == 2)
    Timer1.stop()
return