#WinActivateForce
SetTitleMatchMode, 3
SendMode, Input

global iniFile := A_ScriptDir . "\configs\configs.ini"
EnvGet, A_LocalAppData, LocalAppData
global mcDir := LocalAppData . "\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang"

loadConfigs(){
    FileRead, seedList, configs\seeds.txt
    IniRead, selectedSeed, %iniFile%, Settings, selectedSeed
    seedList := StrReplace(seedList, selectedSeed, "") ; remove selected seed from dropdown list
        GuiControl,, SeedDropDownList, %seedList%|%selectedSeed%||

    IniRead, stateSeed, %iniFile%, Settings, setSeed
    If stateSeed = true
        GuiControl,, SeedCheck, 1
    Gosub SeedCheck
    
    IniRead, stateAutoReset, %iniFile%, Settings, autoReset
    If stateAutoReset = true
        GuiControl,, AutoCheck, 1
    Gosub AutoCheck

    IniRead, iniMaxCoords, %iniFile%, Settings, maxCoords
        GuiControl,, MaxCoordsEdit, %iniMaxCoords%
        
    IniRead, iniMinCoords, %iniFile%, Settings, minCoords
        GuiControl,, MinCoordsEdit, %iniMinCoords%
        
    IniRead, stateAutoRestart, %iniFile%, Settings, autoRestart
    If stateAutoRestart = true
        GuiControl,, AutoRestartCheck, 1
    Gosub AutoRestartCheck

    IniRead, iniResetThreshold, %iniFile%, Settings, resetThreshold
        GuiControl,, ResetThresholdEdit, %iniResetThreshold%

    IniRead, iniKey, %iniFile%, Hotkeys, Reset
        GuiControl,, ResetHotkey, %iniKey%
        Hotkey, %iniKey%, resetInGame
        
    IniRead, iniKey, %iniFile%, Hotkeys, RestartMinecraft
        GuiControl,, RestartMCHotkey, %iniKey%
        Hotkey, %iniKey%, restartMC

    IniRead, iniKeyDelay, %iniFile%, Settings, keyDelay
        GuiControl,, DelayEdit, %iniKeyDelay%
        keyDelay := iniKeyDelay

    worldCount := ComObjCreate("Shell.Application").NameSpace(mcDir . "\minecraftWorlds").Items.Count
        GuiControl,, worldsText, #Worlds: %worldCount%

    updateAttempts(0)
}

checkButton(btn, attempts := 30, checkDelay := 100, doClick := true)
{
    Loop, {
        if A_Index > %attempts% ; default: tries 30 times for 100ms each: 3s
            return 0
            
        ImageSearch, X, Y, 0, 0, A_ScreenWidth, A_ScreenHeight, assets/%btn%
        if ErrorLevel = 0
        {
            IniWrite, %X% %Y%, %iniFile%, Macro, % RTrim(btn, ".png")
            if doClick
                Click, %X% %Y%
            return 1
        }
        Sleep, %checkDelay%
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
    imgFiles := ["CreateNew.png", "CreateNewWorld.png", "Easy.png", "Coords.png", "SimDis.png", "Seed.png", "Create.png", "Heart.png", "Quit.png"]
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
        if !checkButton(btn)
        {
            MsgBox, Couldn't find %btn%! Aborting...
            return
        }    
    }

    ; exiting world test
    Sleep, 2000
    worldGenStart := A_TickCount - 2000
    if !checkButton("Heart.png", 650, 1, false)
    {
        MsgBox, Couldn't detect in world! Aborting...
        return
    }
    worldGenTime := A_TickCount - worldGenStart
    IniWrite, %worldGenTime%, %iniFile%, Macro, worldGenTime

    Send, {Esc}
    if !checkButton("Quit.png")
    {
        MsgBox, Couldn't find "Quit.png"! Aborting...
        return
    }
    Sleep, 50 ; sometimes quit btn doesnt actually activate

    MsgBox, Success!
}