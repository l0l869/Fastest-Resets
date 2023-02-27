;===Process===
global mcProc
global DynPtrBaseAddr
global xCoord
global lastRestart


;===Script===
global SCRIPT_VERSION := 20230108
global PACK_VERSION := 1.1
global iniFile := A_ScriptDir . "\configs\configs.ini"
global mcDir := LocalAppData . "\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang"


;===Config===
global setSeed
global autoReset
global autoRestart
global selectedSeed
global maxCoords
global minCoords
global resetThreshold
global keyDelay
global keybindRestartMc
global keybindReset


;===Stats===
global runAttempts
global worldCount


;===UI===
        ;Seed
;global buttonAddSeed
global editboxSeed
global dropdownlistSeed
global checkboxSetSeed

        ;Setup
;global buttonInstallPack
;global buttonOpenMcDir

        ;Hotkeys
;global buttonEditHotkeys
global hotkeyboxRestartMc
global hotkeyboxResetKey
;global textResetKey
;global textRestartMcKey
;----hotkeysWin
;global buttonSaveKeybinds
global hotkeyboxNewRestartMc
global hotkeyboxNewResetKey
;global textResetKey
;global textRestartMcKey
;----
        ;Autoreset
global editboxMaxCoords
global editboxMinCoords
global checkboxAutoReset

        ;Autorestart
global editboxResetThreshold
global checkboxAutoRestart

        ;Keydelay
global editboxKeyDelay
;global textDelay

        ;Stats
global textWorlds
global textAttempts


;===Env===
EnvGet, A_LocalAppData, LocalAppData