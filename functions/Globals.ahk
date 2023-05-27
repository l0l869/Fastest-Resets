;===Script===
global SCRIPT_VERSION := 20230528
global latestVersions
global iniFile := A_ScriptDir . "\configs\configs.ini"
global MCdir := LocalAppData . "\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang"

;===Process===
global MCproc
global MCversion
global xCoord
global offsetsCoords
global lastRestart
global isResetting
global winX
global winY
global winX2
global winY2
global winWidth
global winHeight

;===Timer===
global timerActivated
global timerOffset
global timerAnchor
global timerFont
global timerSize
global timerColour
global timerDecimalPlaces
global timerRefreshRate
global timerAutoSplit

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

;===Setup===
global mouseX, mouseY
global atMouseColour
global currentButton
global Buttons := []
global BUTTON_NAMES := ["Heart","SaveAndQuit","CreateNew","CreateNewWorld","Normal","Easy","Coordinates","Simulation","Seed","Create"]

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
;----hotkeysWin
;global buttonSaveKeybinds
;global hotkeyboxNewRestartMc
;global hotkeyboxNewResetKey
;global hotkeyboxStopResetKey
;global hotkeyboxStartTimer
;global hotkeyboxStopTimer
;global textReset
;global textRestartMC
;global textStopReset
;global textStartTimer
;global textStopTimer
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
global lastWarn := 0

        ;Timer
global checkboxTimer

        ;Stats
global textWorlds
global textAttempts
global textMCVersion


;===Env===
EnvGet, A_LocalAppData, LocalAppData