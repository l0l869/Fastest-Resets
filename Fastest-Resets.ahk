#Include %A_ScriptDir%
#SingleInstance, Force
#NoTrayIcon
#WinActivateForce
SetBatchLines -1
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 3
SendMode, Input
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

#Include functions/Globals.ahk
#Include functions/SettingsHandler.ahk

Menu Tray, Icon, %A_ScriptDir%\assets\_Icon.ico
Gui, MainWin:Default
Gui, -MaximizeBox
Gui, Show , w325 h385, Fastest Resets
Gui, Color, EEEEEE
Gui, Font , s10, Arial

Gui, add, GroupBox, y5 w150 h150, Hotkeys
Gui, add, Text    , y25 x25, Reset Key
Gui, add, Text    , y70 x25, Restart MC Key
Gui, add, Hotkey  , y40 x25 w120 vhotkeyboxResetKey +Disabled
Gui, add, Hotkey  , y85 x25 w120 vhotkeyboxRestartMc +Disabled
Gui, add, Button  , w120 h20 gEditHotkeys, Edit Hotkeys

Gui, add, GroupBox, y160 x10 w150 h120, Set Seed
Gui, add, Edit    , y180 x25 w120 veditboxSeed gAddSeed +Number -Multi
Gui, add, Button  , y205 x25 w120 h20 vbuttonAddSeed, Add Seed
Gui, add, DDL     , y230 x25 w120 vdropdownlistSeed gdropdownlistSeed
Gui, add, Checkbox, y260 x25 vcheckboxSetSeed gcheckboxSetSeed, Set Seed

Gui, add, GroupBox, x10 w150 h90, Auto Reset
Gui, add, Text    , y310 x35, xMax
Gui, add, Text    , y335 x35, xMin
Gui, add, Edit    , y305 x80 w45 veditboxMaxCoords geditboxMaxCoords +Number -Multi Center
Gui, add, Edit    , y330 x80 w45 veditboxMinCoords geditboxMinCoords +Number -Multi Center
Gui, add, Checkbox, y355 x40 vcheckboxAutoReset gcheckboxAutoReset, Auto Reset

Gui, add, GroupBox, y5 x165 w150 h75, Extra
Gui, add, Edit    , y25 x175 w25 veditboxResetThreshold geditboxResetThreshold +Number -Multi Center
Gui, add, Checkbox, y30 x205 vcheckboxAutoRestart gcheckboxAutoRestart, Auto Restart
Gui, add, Text    , y55 x210, Key Delay
Gui, add, Edit    , y50 x175 w25 veditboxKeyDelay geditboxKeyDelay +Number -Multi Center

Gui, add, Button  , y85 x165 w150 h25 gInstallPack, Install Resource Pack 

Gui, add, Button  , y115 x165 w150 h25 gOpenMCDir, MC Directory

Gui, Font, s13
Gui, add, Text    , y145 x165 w150 vtextWorlds, #Worlds: -
Gui, add, Text    , y170 x165 w150 vtextAttempts, #Attempts: -
Gui, Font, s10
Gui, add, Text    , y195 x165 w150 h30 vtextMCVersion, MC Version: Not Opened

loadConfigs()

#Include functions/Resetter.ahk

; buttons

InstallPack:
    if FileExist(MCdir . "\resource_packs\FR-Pack")
    {
        MsgBox, Fastest Resets Pack already imported.
    }
    Else
    {
        FileOpen(MCdir . "\minecraftpe\global_resource_packs.json", "w").Write("[`n   {`n      ""pack_id"" : ""8eb36656-a7fe-4342-93e4-e443db3e8d3b"",`n      ""version"" : [ 1, 1, 2 ]`n   }`n]").Close()
        FileCreateDir, %MCdir%\resource_packs\FR-Pack
        FileCopyDir, %A_ScriptDir%\assets\FR-Pack, %MCdir%\resource_packs\FR-Pack, 1
        Gosub, restartMC
    }
return

OpenMCDir: 
    run, %MCdir%
return

EditHotkeys:
    Gui, hotkeysWin:Show, w150 h145, Edit Hotkeys
    Gui, hotkeysWin:add, Hotkey, x10 y20 w130 vhotkeyboxNewResetKey
    Gui, hotkeysWin:add, Hotkey, x10 y65 w130 vhotkeyboxNewRestartMc
    Gui, hotkeysWin:add, Text, x10 y5,Reset Key
    Gui, hotkeysWin:add, Text, x10 y50,Restart MC Key
    Gui, hotkeysWin:add, Button, x10 y100 w130 h30 gSaveHotkeys,Save

    IniRead, iniKey, %iniFile%, Hotkeys, Reset
        GuiControl,hotkeysWin:, hotkeyboxNewResetKey, %iniKey%

    IniRead, iniKey, %iniFile%, Hotkeys, RestartMinecraft
        GuiControl,hotkeysWin:, hotkeyboxNewRestartMc, %iniKey%
return

SaveHotkeys:
    Gui, hotkeysWin:Submit
    Gui, hotkeysWin:Destroy

    IniWrite, %hotkeyboxNewResetKey%, %iniFile%, Hotkeys, Reset
    IniWrite, %hotkeyboxNewRestartMc%, %iniFile%, Hotkeys, RestartMinecraft

    if A_IsCompiled
        Run, Fastest-Resets.exe
    Else
        Run, Fastest-Resets.ahk
return

AddSeed:
    GuiControlGet inputtedSeed,, editboxSeed
    FileRead, seedList, configs\seeds.txt

    if !inputtedSeed
    {
        MsgBox, Invalid input!
    }

    if InStr(seedList, inputtedSeed)    ; this is bad, for instance: "12" is in "551255"
        MsgBox, %inputtedSeed% is already in seed list!
    Else
    {
        FileAppend, |%inputtedSeed%, configs\seeds.txt
        GuiControl,, dropdownlistSeed, %inputtedSeed% ; weird
        GuiControl,, editboxSeed
    }
return

; edits, checkboxes

editboxKeyDelay:
    GuiControlGet, valueKeyDelay,, editboxKeyDelay
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

MainWinGuiEscape:
MainWinGuiClose:
    ExitApp