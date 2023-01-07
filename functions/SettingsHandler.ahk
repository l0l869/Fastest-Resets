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
        GuiControl,, hotkeyboxResetKey, %iniKey%
        Hotkey, %iniKey%, resetInGame
        
    IniRead, iniKey, %iniFile%, Hotkeys, RestartMinecraft
        GuiControl,, hotkeyboxRestartMc, %iniKey%
        Hotkey, %iniKey%, restartMC

    IniRead, iniKeyDelay, %iniFile%, Settings, keyDelay
        GuiControl,, editboxKeyDelay, %iniKeyDelay%
        keyDelay := iniKeyDelay

    worldCount := ComObjCreate("Shell.Application").NameSpace(mcDir . "\minecraftWorlds").Items.Count
        GuiControl,, textWorlds, #Worlds: %worldCount%

    updateAttempts(0)
}