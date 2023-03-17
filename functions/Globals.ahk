;===Script===
global SCRIPT_VERSION := 20230317
global PACK_VERSION := 114
global latestVersions
global iniFile := A_ScriptDir . "\configs\configs.ini"
global MCdir := LocalAppData . "\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang"

;===Process===
global MCproc
global MCversion
global xCoord
global offsetsCoords
global lastRestart
global winX
global winY
global winX2
global winY2
global winWidth
global winHeight

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
global textMCVersion


;===Env===
EnvGet, A_LocalAppData, LocalAppData