#WinActivateForce
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetTitleMatchMode, 3
SendMode, Input
; SetKeyDelay, 20              can be used instead of global sleep delay
; SetMouseDelay, 20
; SetDefaultMouseSpeed, 0

global iniFile := A_ScriptDir . "\Configs.ini"

loadConfigs(){
    FileRead, tmplist, Seeds.txt
    IniRead, sSeed, %iniFile%, Settings, seedSelected
    tmplist := StrReplace(tmplist, sSeed, "") ;remove dupe seed
        GuiControl,, SeedList, %tmplist%|%sSeed%||

    IniRead, stateSeed, %iniFile%, Settings, setSeed
    If stateSeed = true
        GuiControl,, SeedCheck, 1
    Gosub SeedCheck
    
    IniRead, stateAutoReset, %iniFile%, Settings, autoReset
    If stateAutoReset = true
        GuiControl,, AutoCheck, 1
    Gosub AutoCheck

    IniRead, maxC, %iniFile%, Settings, maxCoords
        GuiControl,, MaxCoordsEdit, %maxC%
        
    IniRead, minC, %iniFile%, Settings, minCoords
        GuiControl,, MinCoordsEdit, %minC%
        
        
    IniRead, key, %iniFile%, Hotkeys, Reset
        GuiControl,, ResetHotkey, %key%
        Hotkey, %key%, resetInGame
        
    IniRead, key, %iniFile%, Hotkeys, RestartMinecraft
        GuiControl,, RestartMCHotkey, %key%
        Hotkey, %key%, restartMC

    IniRead, iniDelay, %iniFile%, Settings, globalDelay
        GuiControl,, DelayEdit, %iniDelay%
        delay := iniDelay
}

setUp()
{
    ; Test if minecraft is open
    if WinExist("Minecraft")
        WinActivate
    else 
    {    
        MsgBox, Minecraft is not open!
        Return
    }

    ; checks if PNGs exists
    imgFiles := ["CreateNewWorld.png", "CreateNew.png", "Easy.png", "Quit.png", "SimDis.png", "Coords.png", "Create.png", "Seed.png"]
    For i, file in imgFiles
    {
        if !FileExist(A_ScriptDir . "\assets\" . file)
        {
            MsgBox, Couldn't find file: %file% in assets folder
            return
        }
    }
    
    ; button checks
    Sleep, 1000
    Loop, {
        if A_Index > 20 ; tries 20 times for 100ms each: 2s
        {    
            MsgBox, Couldn't find CreateNew.png! Aborting...
            return
        }
            
        ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, assets/CreateNew.png
        if ErrorLevel = 0
        {
            IniWrite, %X% %Y%, %iniFile%, Macro, CreateNew
            Click, %X% %Y%
            Break
        }
        Sleep, 100
    }
    Sleep, 500

    Loop, {
        if A_Index > 20 ; tries 20 times for 100ms each: 2s
        {    
            MsgBox, Couldn't find CreateNewWorld.png! Aborting...
            return
        }
            
        ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, assets/CreateNewWorld.png
        if ErrorLevel = 0
        {
            IniWrite, %X% %Y%, %iniFile%, Macro, CreateNewWorld
            Click, %X% %Y%
            Break
        }
        Sleep, 100
    }
    Sleep, 1000

    Loop, {
        if A_Index > 20 ; tries 20 times for 100ms each
        {    
            MsgBox, Couldn't find Easy.png! Aborting...
            return
        }
            
        ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, assets/Easy.png
        if ErrorLevel = 0
        {
            IniWrite, %X% %Y%, %iniFile%, Macro, Easy
            Click, %X% %Y%
            Break
        }
        Sleep, 100
    }
    Sleep, 500

    Loop, {
        if A_Index > 20 ; tries 20 times for 100ms each
        {    
            MsgBox, Couldn't find Coords.png! Aborting...
            return
        }
            
        ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, assets/Coords.png
        if ErrorLevel = 0
        {
            IniWrite, %X% %Y%, %iniFile%, Macro, Coords
            Click, %X% %Y%
            Break
        }
        Sleep, 100
    }
    Sleep, 500

    Loop, {
        if A_Index > 20 ; tries 20 times for 100ms each
        {    
            MsgBox, Couldn't find SimDis.png! Aborting...
            return
        }
            
        ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, assets/SimDis.png
        if ErrorLevel = 0
        {
            IniWrite, %X% %Y%, %iniFile%, Macro, SimDis
            Click, %X% %Y%
            Break
        }
        Sleep, 100
    }
    Sleep, 500

    Loop, {
        if A_Index > 20 ; tries 20 times for 100ms each: 2s
        {    
            MsgBox, Couldn't find Seed.png! Aborting...
            return
        }
            
        ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, assets/Seed.png
        if ErrorLevel = 0
        {
            IniWrite, %X% %Y%, %iniFile%, Macro, Seed
            Click, %X% %Y%
            Break
        }
        Sleep, 100
    }
    Sleep, 500

    Loop, {
        if A_Index > 20 ; tries 20 times for 100ms each
        {    
            MsgBox, Couldn't find Create.png! Aborting...
            return
        }
            
        ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, assets/Create.png
        if ErrorLevel = 0
        {
            IniWrite, %X% %Y%, %iniFile%, Macro, Create
            Click, %X% %Y%
            Break
        }
        Sleep, 100
    }
}