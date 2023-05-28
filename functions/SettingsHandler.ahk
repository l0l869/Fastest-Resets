loadConfigs(){
    FileRead, seedList, configs\seeds.txt
    IniRead, selectedSeed, %iniFile%, Settings, selectedSeed
    seedList := StrReplace(seedList, selectedSeed, "") ; remove selected seed from dropdown list
        GuiControl,, dropdownlistSeed, %seedList%|%selectedSeed%||

    IniRead, setSeed, %iniFile%, Settings, setSeed
    If setSeed = true
        GuiControl,, checkboxSetSeed, 1
    Gosub checkboxSetSeed
    
    IniRead, autoReset, %iniFile%, Settings, autoReset
    If autoReset = true
        GuiControl,, checkboxAutoReset, 1
    Gosub checkboxAutoReset

    IniRead, iniMaxCoords, %iniFile%, Settings, maxCoords
        GuiControl,, editboxMaxCoords, %iniMaxCoords%
        
    IniRead, iniMinCoords, %iniFile%, Settings, minCoords
        GuiControl,, editboxMinCoords, %iniMinCoords%
        
    IniRead, autoRestart, %iniFile%, Settings, autoRestart
    If autoRestart = true
        GuiControl,, checkboxAutoRestart, 1
    Gosub checkboxAutoRestart

    IniRead, iniResetThreshold, %iniFile%, Settings, resetThreshold
        GuiControl,, editboxResetThreshold, %iniResetThreshold%

    IniRead, iniKey, %iniFile%, Hotkeys, Reset
        Hotkey, %iniKey%, ResetInGame
        
    IniRead, iniKey, %iniFile%, Hotkeys, RestartMinecraft
        Hotkey, %iniKey%, RestartMC

    IniRead, iniKey, %iniFile%, Hotkeys, StopReset
        if(iniKey != "ERROR")
            Hotkey, %iniKey%, StopReset
        Else {
            IniWrite, ^Tab, %iniFile%, Hotkeys, StopReset
            IniWrite, Mojangles, %iniFile%, Timer, font
            IniWrite, 0, %iniFile%, Timer, refreshRate
            Hotkey, ^Tab, StopReset
        }

    IniRead, iniKey, %iniFile%, Hotkeys, StartTimer
        if(iniKey && iniKey != "ERROR")
            Hotkey, %iniKey%, StartTimer

    IniRead, iniKey, %iniFile%, Hotkeys, StopTimer
        if(iniKey && iniKey != "ERROR")
            Hotkey, %iniKey%, StopTimer

    IniRead, iniKeyDelay, %iniFile%, Settings, keyDelay
        GuiControl,, editboxKeyDelay, %iniKeyDelay%
        keyDelay := iniKeyDelay

    IniRead, timerActivated, %iniFile%, Timer, timerActivated
    If timerActivated = true
        GuiControl,, checkboxTimer, 1
    Gosub checkboxTimer

    worldCount := ComObjCreate("Shell.Application").NameSpace(MCdir . "\minecraftWorlds").Items.Count
        GuiControl, MainWin:, textWorlds, #Worlds: %worldCount%

    updateAttempts(0)

    ; if !latestVersions
    ;     checkUpdates()

    configureCompatibility()

    loadButtons()
}

adjustMinecraftSettings()
{
    hasUpdated := 0
    txtOptions := MCdir . "\minecraftpe\options.txt"

    if(!FileExist(txtOptions))
        return -1

    Loop, read, %txtOptions%
    {
        if InStr(A_LoopReadLine, "screen_animations:")
            hasUpdated |= SubStr(A_LoopReadLine, 19, 1) == "0" ? 0 : writeAtLine(txtOptions, A_Index, "screen_animations:0")

        if InStr(A_LoopReadLine, "gfx_safe_zone_x:")
            hasUpdated |= SubStr(A_LoopReadLine, 17, 1) == "1" ? 0 : writeAtLine(txtOptions, A_Index, "gfx_safe_zone_x:1")

        if InStr(A_LoopReadLine, "gfx_safe_zone_y:")
            hasUpdated |= SubStr(A_LoopReadLine, 17, 1) == "1" ? 0 : writeAtLine(txtOptions, A_Index, "gfx_safe_zone_y:1")
    }
    
    if hasUpdated
    {
        MsgBox,4, Warning, Restart to apply appropriate Minecraft settings?
        IfMsgBox, Yes
            Gosub, restartMC
    }
}

loadTimerConfigs()
{
    IniRead, timerOffset, %iniFile%, Timer, offset
        timerOffset := StrSplit(timerOffset, ",")
    IniRead, timerAnchor, %iniFile%, Timer, anchor
    IniRead, timerFont, %iniFile%, Timer, font
    IniRead, timerSize, %iniFile%, Timer, size
    IniRead, timerColour, %iniFile%, Timer, colour
    IniRead, timerDecimalPlaces, %iniFile%, Timer, decimalPlaces
    IniRead, timerRefreshRate, %iniFile%, Timer, refreshRate
    IniRead, timerAutoSplit, %iniFile%, Timer, autoSplit
}

getMCVersion()
{
    Process, Exist, Minecraft.Windows.exe
        if !ErrorLevel
            return -1
    
    MCproc := new _ClassMemory("ahk_exe Minecraft.Windows.exe", "PROCESS_VM_READ")
    FileGetVersion, MCversion, % MCproc.GetModuleFileNameEx()
        GuiControl, MainWin:, textMCVersion, MCVersion: %MCversion%

    return MCversion
}

configureCompatibility()
{
    Process, Wait, Minecraft.Windows.exe

    ;GuiControl, Enable, checkboxAutoReset if i want to call this func at every reset
    switch getMCVersion()
    {
        case "1.16.10.2": offsetsCoords := [0x036A3C18, 0xA8, 0x10, 0x954]
        case "1.16.1.2" : offsetsCoords := [0x0369D0A8, 0xA8, 0x10, 0x954]
        case "1.16.0.58": offsetsCoords := [0x038464D8, 0x190, 0x20, 0x0, 0x2C]
        case "1.16.0.57": offsetsCoords := [0x03846490, 0x190, 0x20, 0x0, 0x2C]
        case "1.16.0.51": offsetsCoords := [0x035C6298, 0x190, 0x20, 0x0, 0x2C]
        case "1.14.60.5": offsetsCoords := [0x0307D3A0, 0x30, 0xF0, 0x110]
        case "1.2.13.54": offsetsCoords := [0x01FA1888, 0x0, 0x10, 0x10, 0x20, 0x0, 0x2C]
        Default: 
            GuiControl, MainWin:,        textMCVersion, MCVersion: %MCversion%`nAutoReset not supported.
            GuiControl, MainWin:Disable, checkboxAutoReset
            GuiControl, MainWin:,        checkboxAutoReset, 0
            Gosub, checkboxAutoReset
    }

    adjustMinecraftSettings()
}

checkUpdates()
{
    if(!DllCall("Wininet.dll\InternetGetConnectedState", "Str", 0x40,"Int",0))
        return 0

    req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    req.Open("GET", "https://pastebin.com/raw/dbABGVM4", true) ; latest version
    req.Send()
    req.WaitForResponse()
    latestVersions := StrSplit(req.ResponseText, ",")

    ; Definitely wont need this anymore
    ;
    ; idk if i should have this
    ; if (PACK_VERSION < latestVersions[2])
    ;     MsgBox,, Update,% "New Pack Update!`n" . PACK_VERSION . " => " . latestVersions[2]

    if (SCRIPT_VERSION < latestVersions[1])
        MsgBox 4, Update,% "New Update Available!`n" . SCRIPT_VERSION . " => " . latestVersions[1] . "`n`nDo you want to update?",,

    IfMsgBox, Yes
        downloadLatest(latestVersions)

    return latestVersions
}

downloadLatest(latestVersions)
{
    scriptMainDir := RegExReplace(A_ScriptDir, "\\[^\\]*$", "")
    tempFolder := A_ScriptDir . "\temp"
    RegExMatch(latestVersions[3], "Fastest\.Resets\.v[0-9]+\.[0-9]+\.zip", newVersionZipName)
    FileCreateDir, %tempFolder%
    UrlDownloadToFile % latestVersions[3], %tempFolder%\%newVersionZipName%
    if(ErrorLevel || !FileExist(tempFolder . "\" . newVersionZipName))
    {
        FileRemoveDir, %tempFolder%, 1
        MsgBox, Update Failed!
        return -1
    }
    sh := ComObjCreate("Shell.Application")
    sh.Namespace( tempFolder ).CopyHere( sh.Namespace( tempFolder . "\" . newVersionZipName ).items, 4|16 )
    FileDelete, %tempFolder%\%newVersionZipName%
    newVersionFolderName := StrReplace(RTrim(newVersionZipName, ".zip"), ".", A_Space,, 2)

    FileCopy, configs\configs.ini, %tempFolder%\%newVersionFolderName%\configs, 1
    FileCopy, configs\attempts.txt, %tempFolder%\%newVersionFolderName%\configs, 1
    FileCopy, configs\seeds.txt, %tempFolder%\%newVersionFolderName%\configs, 1
    FileCopy, configs\logs.txt, %tempFolder%\%newVersionFolderName%\configs, 1
    FileMoveDir, %tempFolder%\%newVersionFolderName%, %scriptMainDir%, 1
    FileRemoveDir, %A_ScriptDir%, 1

    MsgBox, Update Complete!
    Run, %scriptMainDir%\%newVersionFolderName%\Fastest-Resets.ahk
    ExitApp, 1
}

writeAtLine(txtPath, atLine, string)
{
    txtFile := FileOpen(txtPath, "rw")

    dataFile := StrSplit(txtFile.Read(), "`n")
    if (dataFile[atLine])
    {
        dataFile[atLine] := string
        for k, v in dataFile
            if (v != "`n")
                dataReturn .= v . "`n"
        
        txtFile.Seek(0)
        txtFile.Write(dataReturn)
    }

    txtFile.Close()
    return 1
}

Log(entry){
    FileAppend, %entry%`n, configs\logs.txt
}

loadButtons()
{
    Buttons := []
    For k, btn in BUTTON_NAMES
    {
        IniRead, btnvar, %iniFile%, Buttons, %btn%
        Buttons.push(StrSplit(btnvar,","))
    }
}

;
;   idk what this is im bored lol
;

SetupButtons()
{
    if currentButton
        return

    MsgBox % "Tab: Assign Button`n" "Shift + Esc: Finish Setup"

    s := Func("finishSetup")
    Hotkey, +Esc, % s
    Hotkey, +Esc, On
    s := Func("setButton")
    Hotkey, Tab, % s
    Hotkey, Tab, On

    Run, shell:AppsFolder\Microsoft.MinecraftUWP_8wekyb3d8bbwe!App
    currentButton := 1

    global textMouseToolTip, textMouseColourTip, textButtonList
    Gui, Setup:Show, % "x0 " . " y0" . " w" . A_ScreenWidth . " h" . A_ScreenHeight
    Gui, Setup:Font, % "s" 25 " c" "FFFFFF" " q4", Mojangles
    Gui, Setup:Add , Text, x0 y0 w350 h150 vtextMouseToolTip
    Gui, Setup:Add , Text, x0 y0 w200 h100 vtextMouseColourTip
    Gui, Setup:Add , Text, x0 y0 w550 h230 vtextButtonList
    Gui, Setup:         +AlwaysOnTop -Border -Caption +LastFound +ToolWindow
    Gui, Setup:Color  , 000001
    WinSet, TransColor, 000001
    Gui, Setup:Show   , x0 y0

    global isShown := true
    SetTimer, updateSetupWindow, 8
    Gosub, updateTextButtonList

    updateSetupWindow:
        if (!WinActive("Minecraft") && isShown){
            Gui, Setup:Hide
            isShown := false
        } else if (WinActive("Minecraft") && !isShown){
            Gui, Setup:Maximize
            isShown := true
        }

        Gosub, updateTextMouseTip
    return

    updateTextMouseTip:
        MouseGetPos, mouseX, mouseY
        getWinDimensions("Minecraft")
        PixelGetColor, atMouseRawColour, mouseX, mouseY, RGB
        Switch atMouseRawColour ;hover colour to unhover colour
        {
            case 0x218306: atMouseColour := 0xC6C6C6
            case 0x43A01C: atMouseColour := 0xC6C6C6
            case 0x177400: atMouseColour := 0x979797
            case 0x025F00: atMouseColour := 0x404040
            case 0x037300: atMouseColour := 0x7F7F7F
            case 0xFFFFFF: atMouseColour := 0x4C4C4C
            case 0x4E8836: atMouseColour := 0x808080
            Default: atMouseColour := atMouseRawColour
        }

        GuiControl, Setup:Move, textMouseToolTip  , % "x" mouseX "y" mouseY
        GuiControl, Setup:Move, textMouseColourTip, % "x" mouseX+135 "y" mouseY+75
        Gui       , Setup:Font, % "s" 25 " q4" " c" atMouseColour, Mojangles
        GuiControl, Setup:Font, textMouseColourTip
        GuiControl, Setup:    , textMouseToolTip, % "X:" Floor(mouseX-winX) " Y:" Floor(mouseY-winY) "`nButton: " BUTTON_NAMES[currentButton] "`nColour: "
        GuiControl, Setup:    , textMouseColourTip, % atMouseColour

        if(mouseX < 600 && mouseY < 300)
            GuiControl, Setup:Move, textButtonList, % "y" A_ScreenHeight-230
        Else
            GuiControl, Setup:Move, textButtonList, % "y" 0

        if(mouseX < 200 && mouseY > 235 && mouseY < 275)
        {
            GuiControl, Setup:Move, textMouseToolTip  , % "x" 0 "y" A_ScreenHeight
            GuiControl, Setup:Move, textMouseColourTip, % "x" 0 "y" A_ScreenHeight
        }
    return

    updateTextButtonList:
        loadButtons()
        string := ""
        For k, btn in BUTTON_NAMES
        {
            amount := 15-StrLen(btn)
            filler := ""
            Loop, %amount%
                filler .= " "
            string .= btn "" filler ": X:" Buttons[k][1] " Y:" Buttons[k][2] " Colour: " Buttons[k][3] "`n"
        }
        Gui       , Setup:Font, % "s" 15 " c" "FFFFFF" " q4", Consolas
        GuiControl, Setup:Font, textButtonList
        GuiControl, Setup:    , textButtonList, % string
    return
}

setButton()
{
    IniWrite, % mouseX "," mouseY "," atMouseColour, %iniFile%, Buttons, % BUTTON_NAMES[currentButton]
    currentButton += 1
    Click
    if(currentButton > BUTTON_NAMES.length())
        finishSetup()
}

finishSetup()
{
    Gui, Setup:Destroy
    currentButton := ""
    Hotkey, +Esc, Off
    Hotkey, Tab, Off
    loadButtons()
}