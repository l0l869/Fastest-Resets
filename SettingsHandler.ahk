#WinActivateForce
SetTitleMatchMode, 3
SendMode, Input

global iniFile := A_ScriptDir . "\Configs.ini"
EnvGet, A_LocalAppData, LocalAppData
global mcDir := LocalAppData . "\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang"

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

    nw := ComObjCreate("Shell.Application").NameSpace(mcDir . "\minecraftWorlds").Items.Count
        GuiControl,, worldsText, #Worlds: %nw%
}

chkButton(btn)
{
    Loop, {
        if A_Index > 30 ; tries 30 times for 100ms each: 3s
        {    
            MsgBox, Couldn't find %btn%! Aborting...
            return 0
        }
            
        ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, assets/%btn%
        if ErrorLevel = 0
        {
            nbtn := RTrim(btn, ".png")
            IniWrite, %X% %Y%, %iniFile%, Macro, %nbtn%
            Click, %X% %Y%
            return 1
        }
        Sleep, 100
    }
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
    imgFiles := ["CreateNew.png", "CreateNewWorld.png", "Easy.png", "Coords.png", "SimDis.png", "Seed.png", "Create.png", "Heart.png","Quit.png"]
    For i, file in imgFiles
    {
        if !FileExist(A_ScriptDir . "\assets\" . file)
        {
            MsgBox, Couldn't find file: %file% in assets folder
            return
        }
    }
    
    ; button checks
    btnFiles := ["CreateNew.png", "CreateNewWorld.png", "Easy.png", "Coords.png", "SimDis.png", "Seed.png", "Create.png"]
    For i, btn in btnFiles
    {
        if !chkButton(btn)
        {
            MsgBox, Couldn't find %btn%! Aborting...
            return
        }    
    }

    MsgBox, Success!
}