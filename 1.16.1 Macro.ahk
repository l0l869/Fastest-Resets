﻿SetWorkingDir %A_ScriptDir%
#SingleInstance, Force
#Include SettingsHandler.ahk

Global AddSeedButton, SeedEdit, SeedList, SeedCheck, SetupButton, MaxCoordsEdit, MinCoordsEdit, AutoCheck, ResetThresholdEdit, AutoRestartCheck, ResetHotkey, RestartMCHotkey, DelayEdit, worldsText, attemptsText
Global keyDelay, setSeed, selectedSeed, autoReset, maxCoords, minCoords, autoRestart, resetThreshold

Gui, MainWin:Default
Gui, -MaximizeBox
Gui, Show, w420 h200, Fastest Resets
Gui, Color, EEEEEE
Gui, Font, s8, Arial

Gui, add, Hotkey, x10 y20 vResetHotkey +Disabled
Gui, add, Hotkey, x10 y60 vRestartMCHotkey +Disabled
Gui, add, Text, x10 y5, Reset Key
Gui, add, Text, x10 y45, Restart MC Key
Gui, add, Button, x10 y90 w120 h20 gEditHotkeys, Edit Hotkeys

Gui, add, Button, x145 y10 w120 h20 gAddSeed vAddSeedButton, Add Seed
Gui, add, Edit, x145 y35 vSeedEdit +Number -Multi
Gui, add, DropdownList, x145 y65 vSeedList gSeedChange
Gui, add, Checkbox, x145 y95 vSeedCheck gSeedCheck, Set Seed

Gui, add, Edit, x320 y10 w90 vMaxCoordsEdit gMaxCoordsEdit +Number -Multi
Gui, add, Edit, x320 y35 w90 vMinCoordsEdit gMinCoordsEdit +Number -Multi
Gui, add, Text, x290 y15, xMax
Gui, add, Text, x290 y40, xMin
Gui, add, Checkbox, vAutoCheck gAutoCheck, Auto Reset

Gui, add, Edit, x210 y145 w25 gResetThresholdEdit vResetThresholdEdit +Number -Multi
Gui, add, Checkbox, x185 y170 vAutoRestartCheck gAutoRestartCheck, Auto Restart

Gui, add, Text, x145 y150, Delay
Gui, add, Edit, x145 y166 w30 Center vDelayEdit gDelayEdit +Number -Multi

Gui, add, Button, x10 y125 w120 h20 gInstallResetPack, Install Resource Pack 
Gui, add, Button, x10 y150 w120 h40 vSetupButton gSetup, Set-up

Gui, add, Button, x300 y165 h20 gOpenMCDir, MC Directory

Gui, Font, s10, Arial
Gui, add, Text, vworldsText w100 x300 y125, #Worlds: -
Gui, add, Text, vattemptsText w100 x300 y145, #Attempts: -

loadConfigs()

#Include Resetter.ahk

; buttons

InstallResetPack:
    if FileExist(mcDir . "\resource_packs\FastestRes")  ; automatic update pack soon
    {
        MsgBox, Fastest Resets Pack already imported.
    }
    Else
    {
        Run, Assets\MC-Resources\FastestResets.mcpack
    }
return

OpenMCDir: 
    run, %mcDir%
return

EditHotkeys:
    Gui, hotkeysWin:Show, w150 h145, Edit Hotkeys
    Gui, hotkeysWin:add, Hotkey, x10 y20 w130 vrKey
    Gui, hotkeysWin:add, Hotkey, x10 y65 w130 vrmcKey
    Gui, hotkeysWin:add, Text, x10 y5,Reset Key
    Gui, hotkeysWin:add, Text, x10 y50,Restart MC Key
    Gui, hotkeysWin:add, Button, x10 y100 w130 h30 gSaveHotkeys,Save

    IniRead, key, %iniFile%, Hotkeys, Reset
        GuiControl,hotkeysWin:, rKey, %key%

    IniRead, key, %iniFile%, Hotkeys, RestartMinecraft
        GuiControl,hotkeysWin:, rmcKey, %key%
return

SaveHotkeys:
    Gui, hotkeysWin:Submit
    Gui, hotkeysWin:Destroy

    IniWrite, %rKey%, %iniFile%, Hotkeys, Reset
    IniWrite, %rmcKey%, %iniFile%, Hotkeys, RestartMinecraft

    if A_IsCompiled
        Run, 1.16.1 Macro.exe
    Else
        Run, 1.16.1 Macro.ahk
return

Setup:
    MsgBox, 4,, Have you taken screenshots?
    IfMsgBox Yes
    {
        MsgBox, 1,, Be ready on the screen that has the "Create New" button. Once hit OK dont interfere process. Note: The way Minecraft is displayed now is the way you'll play.
        IfMsgBox OK
            {
                setUp()
            }
    }
    IfMsgBox No 
    {
        Run, %A_ScriptDir%\assets
        Sleep, 1000
        MsgBox, Windows Key + Shift + S, to screenshot buttons with their corresponding file name like the examples provided
    }
return

AddSeed:
GuiControlGet inSeed,, SeedEdit

 IfNotInString, tmplist, %inSeed%
 {
    if inSeed != ""
    {   
        FileAppend, "|"%inSeed%, configs\Seeds.txt
        tmplist .= "|"inSeed
        GuiControl,,SeedList, %tmplist%
        GuiControl,,SeedEdit, 
    }
}
return

; edits, checkboxes

DelayEdit:
    GuiControlGet, inputDelay,, DelayEdit
        IniWrite, %inputDelay%, %iniFile%, Settings, keyDelay
        keyDelay := inputDelay
return

ResetThresholdEdit:
    GuiControlGet, iniResetThreshold,, ResetThresholdEdit
        IniWrite, %iniResetThreshold%, %iniFile%, Settings, resetThreshold
        resetThreshold := iniResetThreshold
return

AutoRestartCheck:
    GuiControlGet, state,, AutoRestartCheck
    if state = 1
    {
        IniWrite, true, %iniFile%, Settings, autoRestart
        autoRestart := true
        GuiControl, Enable, ResetThresholdEdit
    }
    Else
    {
        IniWrite, false, %iniFile%, Settings, autoRestart
        autoRestart := false
        GuiControl, Disable, ResetThresholdEdit
    }   
return

MaxCoordsEdit:
    GuiControlGet, maxCEdit,, MaxCoordsEdit
        maxCoords := maxCEdit
        IniWrite, %maxCEdit%, %iniFile%, Settings, maxCoords
return

MinCoordsEdit:
    GuiControlGet, minCEdit,, MinCoordsEdit
        minCoords := minCEdit
        IniWrite, %minCEdit%, %iniFile%, Settings, minCoords
return

SeedChange:
    GuiControlGet, sSeed,, SeedList
        IniWrite, %sSeed%, %iniFile%, Settings, selectedSeed
return


SeedCheck:
    GuiControlGet, state,, SeedCheck
        if state = 1
        {
            setSeed := true
            GuiControl, Enable, SeedEdit
            GuiControl, Enable, SeedList
            GuiControl, Enable, AddSeedButton
            GuiControl,, AutoCheck, 0
            Gosub AutoCheck
            IniWrite, true, %iniFile%, Settings, setSeed
        }
        Else
        {
            setSeed := false
            GuiControl, Disable, SeedEdit
            GuiControl, Disable, SeedList
            GuiControl, Disable, AddSeedButton
            IniWrite, false, %iniFile%, Settings, setSeed
        }
return

AutoCheck:
    GuiControlGet, state,, AutoCheck
        if state = 1
        {
            autoReset := true
            GuiControl, Enable, maxCoordsEdit
            GuiControl, Enable, minCoordsEdit
            GuiControl,, SeedCheck, 0
            Gosub SeedCheck
            IniWrite, true, %iniFile%, Settings, autoReset
        }
        Else
        {
            autoReset := false
            GuiControl, Disable, maxCoordsEdit
            GuiControl, Disable, minCoordsEdit
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