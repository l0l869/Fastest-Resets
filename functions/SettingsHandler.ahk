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

    IniRead, timerActivated, %iniFile%, Timer, timerActivated
    If timerActivated = true
        GuiControl,, checkboxTimer, 1
    Gosub checkboxTimer
    loadTimerConfigs()

    worldCount := ComObjCreate("Shell.Application").NameSpace(MCdir . "\minecraftWorlds").Items.Count
        GuiControl,, textWorlds, #Worlds: %worldCount%

    updateAttempts(0)
    if !latestVersions
        checkUpdates()
    configureCompatibility()
}

loadTimerConfigs()
{
    IniRead, timerOffset, %iniFile%, Timer, Offset
        timerOffset := StrSplit(timerOffset, ",")
    IniRead, timerAnchor, %iniFile%, Timer, Anchor
    IniRead, timerSize, %iniFile%, Timer, Size
    IniRead, timerColour, %iniFile%, Timer, Colour
    IniRead, timerDecimalPlaces, %iniFile%, Timer, decimalPlaces
}

getMCVersion()
{
    IfWinNotExist, Minecraft
        return -1
    
    MCproc := new _ClassMemory("ahk_exe Minecraft.Windows.exe", "PROCESS_VM_READ")
    FileGetVersion, MCversion, % MCproc.GetModuleFileNameEx()
        GuiControl,, textMCVersion, MCVersion: %MCversion%

    return MCversion
}

Log(entry){
    FileAppend, %entry%`n, configs\logs.txt
}

configureCompatibility()   ;compatibility checks
{
    WinWait, Minecraft

    ;GuiControl, Enable, checkboxAutoReset if i want to call this func at every reset
    switch getMCVersion()
    {
        case "1.16.10.2": offsetsCoords := [0x036A3C18, 0xA8, 0x10, 0x190, 0x28, 0x0, 0x2C]
        case "1.16.1.2" : offsetsCoords := [0x0369D0A8, 0xA8, 0x10, 0x954]
        case "1.16.0.58": offsetsCoords := [0x038464D8, 0x190, 0x20, 0x0, 0x2C]
        case "1.16.0.57": offsetsCoords := [0x03846490, 0x190, 0x20, 0x0, 0x2C]
        case "1.16.0.51": offsetsCoords := [0x035C6298, 0x190, 0x20, 0x0, 0x2C]
        case "1.14.60.5": offsetsCoords := [0x0307D3A0, 0x30, 0xF0, 0x110]
        case "1.2.13.54": offsetsCoords := [0x01FA1888, 0x0, 0x10, 0x10, 0x20, 0x0, 0x2C]
        Default: 
            GuiControl,, textMCVersion, MCVersion: %MCversion%`nAutoReset not supported.
            GuiControl, Disable, checkboxAutoReset
            GuiControl,, checkboxAutoReset, 0
            Gosub, checkboxAutoReset
    }
    
    Loop, Read, %MCdir%\minecraftpe\global_resource_packs.json     ; packActive? PACK_VERSION
    {
        if packActive
        {
            RegExMatch(A_LoopReadLine, "[0-9]+, [0-9]+, [0-9]+", PACK_VERSION)
            PACK_VERSION := StrSplit(StrReplace(PACK_VERSION, A_Space, ""), ",")
            PACK_VERSION := PACK_VERSION[1]*100+PACK_VERSION[2]*10+PACK_VERSION[3]
            break
        }
        if InStr(A_LoopReadLine,"8eb36656-a7fe-4342-93e4-e443db3e8d3b")
            packActive := true
    }

    if !packActive
        MsgBox,, Warning, Fastest Resets Pack isn't activated.
}

checkUpdates()
{
    req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    req.Open("GET", "https://pastebin.com/raw/dbABGVM4", true) ; latest version
    req.Send()
    req.WaitForResponse()
    latestVersions := StrSplit(req.ResponseText, ",")

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
    scriptMainDir := RegExReplace(A_ScriptDir, "\\\w+$", "")
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