﻿#Include %A_ScriptDir%
#SingleInstance, Force
#NoTrayIcon
#WinActivateForce
SetBatchLines -1
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 3
SendMode, Input
SetMouseDelay, -1
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

#Include functions/Globals.ahk
#Include functions/SettingsHandler.ahk

Menu Tray, Icon, %A_ScriptDir%\assets\_Icon.ico
Gui, MainWin:Default
Gui, -MaximizeBox
Gui, Show , w325 h285, Fastest Resets
Gui, Color, EEEEEE
Gui, Font , s10, Arial

Gui, add, GroupBox, y5 w150 h50, Hotkeys
Gui, add, Button  , y25 x25 w120 h20 gEditHotkeys, Edit Hotkeys

Gui, add, GroupBox, y60 x10 w150 h120, Set Seed
Gui, add, Edit    , y80 x25 w120 veditboxSeed +Number -Multi
Gui, add, Button  , y105 x25 w120 h20 vbuttonAddSeed gAddSeed, Add Seed
Gui, add, DDL     , y130 x25 w120 vdropdownlistSeed gdropdownlistSeed
Gui, add, Checkbox, y160 x25 vcheckboxSetSeed gcheckboxSetSeed, Set Seed

Gui, add, GroupBox, x10 w150 h90, Auto Reset
Gui, add, Text    , y210 x35, xMax
Gui, add, Text    , y235 x35, xMin
Gui, add, Edit    , y205 x80 w45 veditboxMaxCoords geditboxMaxCoords +Number -Multi Center
Gui, add, Edit    , y230 x80 w45 veditboxMinCoords geditboxMinCoords +Number -Multi Center
Gui, add, Checkbox, y255 x40 vcheckboxAutoReset gcheckboxAutoReset, Auto Reset

Gui, add, GroupBox, y5 x165 w150 h100, Extra
Gui, add, Edit    , y25 x175 w25 veditboxResetThreshold geditboxResetThreshold +Number -Multi Center
Gui, add, Checkbox, y30 x205 vcheckboxAutoRestart gcheckboxAutoRestart, Auto Restart
Gui, add, Text    , y55 x210, Key Delay
Gui, add, Edit    , y50 x175 w25 veditboxKeyDelay geditboxKeyDelay +Number -Multi Center
Gui, add, Button  , y75 x175 w25 h25 gTimerSettings, ⚙️
Gui, add, Checkbox, y80 x205 vcheckboxTimer gcheckboxTimer, Timer

Gui, add, Button  , y110 x165 w150 h25 gSetup, Setup

Gui, add, Button  , y140 x165 w150 h25 gOpenMCDir, MC Directory

Gui, Font, s13
Gui, add, Text    , y170 x165 w150 vtextWorlds, #Worlds: -
Gui, add, Text    , y195 x165 w150 vtextAttempts, #Attempts: -
Gui, Font, s10
Gui, add, Text    , y220 x165 w150 h30 vtextMCVersion, MC Version: Not Opened

loadConfigs()

#Include functions/Resetter.ahk

; buttons

Setup:
    SetupButtons()
return

OpenMCDir:
    run, %MCdir%
return

EditHotkeys:
    Gui, hotkeysWin:Show, w170 h285
    Gui, hotkeysWin:add, Hotkey, x10 y20 w150 vhotkeyboxNewResetKey
    Gui, hotkeysWin:add, Hotkey, x10 y65 w150 vhotkeyboxNewRestartMc
    Gui, hotkeysWin:add, Hotkey, x10 y110 w150 vhotkeyboxStopResetKey
    Gui, hotkeysWin:add, Hotkey, x10 y155 w150 vhotkeyboxStartTimer
    Gui, hotkeysWin:add, Hotkey, x10 y200 w150 vhotkeyboxStopTimer
    Gui, hotkeysWin:add, Text  , x10 y5,Reset
    Gui, hotkeysWin:add, Text  , x10 y50,Restart MC
    Gui, hotkeysWin:add, Text  , x10 y95,Stop Reset
    Gui, hotkeysWin:add, Text  , x10 y140,Start Timer
    Gui, hotkeysWin:add, Text  , x10 y185,Stop Timer
    Gui, hotkeysWin:add, Button, x10 y240 w150 h30 gSaveHotkeys,Save

    IniRead, iniKey, %iniFile%, Hotkeys, Reset
        GuiControl, hotkeysWin:, hotkeyboxNewResetKey, %iniKey%

    IniRead, iniKey, %iniFile%, Hotkeys, RestartMinecraft
        GuiControl, hotkeysWin:, hotkeyboxNewRestartMc, %iniKey%

    IniRead, iniKey, %iniFile%, Hotkeys, StopReset
        GuiControl, hotkeysWin:, hotkeyboxStopResetKey, %iniKey%

    IniRead, iniKey, %iniFile%, Hotkeys, StartTimer
        GuiControl, hotkeysWin:, hotkeyboxStartTimer, %iniKey%

    IniRead, iniKey, %iniFile%, Hotkeys, StopTimer
        GuiControl, hotkeysWin:, hotkeyboxStopTimer, %iniKey%
return

SaveHotkeys:
    Gui, hotkeysWin:Submit
    Gui, hotkeysWin:Destroy

    IniWrite, %hotkeyboxNewResetKey%, %iniFile%, Hotkeys, Reset
    IniWrite, %hotkeyboxNewRestartMc%, %iniFile%, Hotkeys, RestartMinecraft
    IniWrite, %hotkeyboxStopResetKey%, %iniFile%, Hotkeys, StopReset
    IniWrite, %hotkeyboxStartTimer%, %iniFile%, Hotkeys, StartTimer
    IniWrite, %hotkeyboxStopTimer%, %iniFile%, Hotkeys, StopTimer

    if A_IsCompiled
        Run, Fastest-Resets.exe
    Else
        Run, Fastest-Resets.ahk
return

AddSeed:
    GuiControlGet inputtedSeed,, editboxSeed
    FileRead, seedList, configs\seeds.txt
    seedList := StrSplit(seedList, "|")

    if !inputtedSeed
        MsgBox, Invalid input!

    seedInList := false
    For k, v in seedList
        if (inputtedSeed==v)
            seedInList := true
        
    if !seedInList
    {
        FileAppend, |%inputtedSeed%, configs\seeds.txt
        GuiControl,, dropdownlistSeed, %inputtedSeed%
        GuiControl,, editboxSeed
    } else {
        MsgBox, %inputtedSeed% is already in seed list!
    }
return

TimerSettings:
    Gui, timerSettings:Show, w250 h235, Timer
    Gui, timerSettings:Font, s10 Arial

    Gui, timerSettings:add, GroupBox, y5 w70 h75, Offset
    Gui, timerSettings:add, Text    , y25 x25, X
    Gui, timerSettings:add, Edit    , y22 x40 w30 veditboxX +Number -Multi Center
    Gui, timerSettings:add, Text    , y50 x25, Y
    Gui, timerSettings:add, Edit    , y47 x40 w30 veditboxY +Number -Multi Center

    Gui, timerSettings:add, GroupBox, y5 x90 w150 h75, Anchor
    Gui, timerSettings:add, DDL     , y35 x110 w110 h75 vdropdownlistAnchor, TopLeft|TopRight|BottomLeft|BottomRight

    Gui, timerSettings:add, GroupBox, y80 x12 w150 h100, Font
    Gui, timerSettings:add, Text    , y100 x25, Size
    Gui, timerSettings:add, Edit    , y120 x25 w30 veditboxSize +Number -Multi Center
    Gui, timerSettings:add, Text    , y100 x75, Colour (Hex)
    Gui, timerSettings:add, Edit    , y120 x75 w70 veditboxColour -Multi Center Limit6
    Gui, timerSettings:add, Edit    , y150 x25 w120 veditboxFont -Multi Center

    Gui, timerSettings:add, GroupBox, y80 x170 w70 h50, Precision
    Gui, timerSettings:add, DDL     , y100 x188 w35 h75 vdropdownlistDecimalPlaces, 1|2|3

    Gui, timerSettings:add, GroupBox, y130 x170 w70 h50, AutoSplit
    Gui, timerSettings:add, Checkbox, y150 x198 vcheckboxAutoSplit

    Gui, timerSettings:add, Button  , y185 x12 w230 h40 gTimerSave, Save

    IniRead, iniOffset, %iniFile%, Timer, offset
        Offsets := StrSplit(iniOffset, ",")
        GuiControl, timerSettings:, editboxX, % Offsets[1]
        GuiControl, timerSettings:, editboxY, % Offsets[2]

    IniRead, iniAnchor, %iniFile%, Timer, anchor
        GuiControl, timerSettings:, dropdownlistAnchor, % "|" . iniAnchor . "||TopLeft|TopRight|BottomLeft|BottomRight"

    IniRead, iniFont, %iniFile%, Timer, font
        GuiControl, timerSettings:, editboxFont, %iniFont%

    IniRead, iniSize, %iniFile%, Timer, size
        GuiControl, timerSettings:, editboxSize, %iniSize%

    IniRead, iniColour, %iniFile%, Timer, colour
        GuiControl, timerSettings:, editboxColour, %iniColour%

    IniRead, iniDecimalPlaces, %iniFile%, Timer, decimalPlaces
        GuiControl, timerSettings:, dropdownlistDecimalPlaces, % "|" . iniDecimalPlaces . "||1|2|3"

    IniRead, iniAutoSplit, %iniFile%, Timer, autoSplit
        GuiControl, timerSettings:, checkboxAutoSplit, % iniAutoSplit
return

TimerSave:
    Gui, timerSettings:Submit
    Gui, timerSettings:Destroy

    IniWrite, % editboxX . "," . editboxY, %iniFile%, Timer, offset
    IniWrite, % dropdownlistAnchor, %iniFile%, Timer, anchor
    IniWrite, % editboxFont, %iniFile%, Timer, font
    IniWrite, % editboxSize, %iniFile%, Timer, size
    IniWrite, % editboxColour, %iniFile%, Timer, colour
    IniWrite, % dropdownlistDecimalPlaces, %iniFile%, Timer, decimalPlaces
    IniWrite, % checkboxAutoSplit, %iniFile%, Timer, autoSplit

    if Timer1
    {
        Timer1.reset()
        Timer1 := ""
        Gui, Timer:Destroy ;idk why it doesnt dereference properly
        Timer1 := new Timer()
    }
return

; edits, checkboxes

editboxKeyDelay:
    GuiControlGet, valueKeyDelay,, editboxKeyDelay
        shouldWarn := 10000 < A_TickCount-lastWarn
        if (valueKeyDelay < 50 && shouldWarn)
        {
            lastWarn := A_TickCount
            MsgBox, A key delay lower than 50ms is unverifiable
        }
        IniWrite, %valueKeyDelay%, %iniFile%, Settings, keyDelay
        keyDelay := valueKeyDelay
return

editboxResetThreshold:
    GuiControlGet, iniResetThreshold,, editboxResetThreshold
        IniWrite, %iniResetThreshold%, %iniFile%, Settings, resetThreshold
        resetThreshold := iniResetThreshold
return

checkboxAutoRestart:
    GuiControlGet, autoRestart,, checkboxAutoRestart
    if autoRestart
    {
        IniWrite, true, %iniFile%, Settings, autoRestart
        autoRestart := true
        GuiControl, Enable, editboxResetThreshold
    }
    Else
    {
        IniWrite, false, %iniFile%, Settings, autoRestart
        autoRestart := false
        GuiControl, Disable, editboxResetThreshold
    }   
return

checkboxTimer:
    GuiControlGet, timerActivated,, checkboxTimer
    if timerActivated
    {
        IniWrite, true, %iniFile%, Timer, timerActivated
        timerActivated := true
        if !Timer1
            global Timer1 := new Timer()
    }
    Else
    {
        IniWrite, false, %iniFile%, Timer, timerActivated
        timerActivated := false
        if Timer1
        {
            Timer1.reset()
            Timer1 := ""
        }
    }  
return

editboxMaxCoords:
    GuiControlGet, valueMaxCoordsEdit,, editboxMaxCoords
        maxCoords := valueMaxCoordsEdit
        IniWrite, %valueMaxCoordsEdit%, %iniFile%, Settings, maxCoords
return

editboxMinCoords:
    GuiControlGet, valueMinCoordsEdit,, editboxMinCoords
        minCoords := valueMinCoordsEdit
        IniWrite, %valueMinCoordsEdit%, %iniFile%, Settings, minCoords
return


dropdownlistSeed:
    GuiControlGet, selectedSeed,, dropdownlistSeed
        IniWrite, %selectedSeed%, %iniFile%, Settings, selectedSeed
return


checkboxSetSeed:
    GuiControlGet, setSeed,, checkboxSetSeed
        if setSeed
        {
            setSeed := true
            GuiControl, Enable, editboxSeed
            GuiControl, Enable, dropdownlistSeed
            GuiControl, Enable, buttonAddSeed
            GuiControl,, checkboxAutoReset, 0
            Gosub checkboxAutoReset
            IniWrite, true, %iniFile%, Settings, setSeed
        }
        Else
        {
            setSeed := false
            GuiControl, Disable, editboxSeed
            GuiControl, Disable, dropdownlistSeed
            GuiControl, Disable, buttonAddSeed
            IniWrite, false, %iniFile%, Settings, setSeed
        }
return

checkboxAutoReset:
    GuiControlGet, autoReset,, checkboxAutoReset
        if autoReset
        {
            autoReset := true
            GuiControl, Enable, editboxMaxCoords
            GuiControl, Enable, editboxMinCoords
            GuiControl,, checkboxSetSeed, 0
            Gosub checkboxSetSeed
            IniWrite, true, %iniFile%, Settings, autoReset
        }
        Else
        {
            autoReset := false
            GuiControl, Disable, editboxMaxCoords
            GuiControl, Disable, editboxMinCoords
            IniWrite, false, %iniFile%, Settings, autoReset
        }
return

; gui close

hotkeysWinGuiClose:
MsgBox,4, Hotkeys, Save?
IfMsgBox, Yes
    gosub SaveHotkeys
IfMsgBox, No
    Gui, hotkeysWin:Destroy
return

timerSettingsGuiClose:
MsgBox,4, Timer Settings, Save?
IfMsgBox, Yes
    gosub TimerSave
IfMsgBox, No
    Gui, timerSettings:Destroy
return

MainWinGuiEscape:
MainWinGuiClose:
    ExitApp