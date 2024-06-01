/*
Ollama - Open WebUI Script

Copyright(C) 2024 Special-Niewbie Softwares

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation version 3.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/
#Persistent
global ProgressGui, ProgressBar, AIListDialogOpen := false

OllamaExePath := "C:\Users\" . A_UserName . "\AppData\Local\Programs\Ollama\ollama app.exe"
OllamaProcessName := "ollama app.exe"
DockerExePath := "C:\Program Files\Docker\Docker\Docker Desktop.exe"
DockerProcessName := "Docker Desktop.exe"
TempBatchFile := A_Temp . "\temp_update_models.ps1"

Menu, Tray, NoStandard

; Menu System Tray
Menu, Tray, Add, Update all Ollama Models, UpdateModels
Menu, Tray, Add, Check New Models Online, CheckModels
Menu, Tray, Add, AI Installed List, ShowAIList
Menu, Tray, Add, , Separator
Menu, Tray, Add, Reload Script, ReloadScript
Menu, Tray, Add, , Separator
Menu, Tray, Add, Script site for Updates / Donate, OpenScriptSite
Menu, Tray, Add, Show Version, ShowVersionInfo
Menu, Tray, Add, , Separator
Menu, Tray, Add, Exit, ExitApp

; Function to create and update the progress bar
ShowProgress(percentage, text := "") {
    global ProgressGui, ProgressBar
    if !IsObject(ProgressGui) {
        Progress, B2 W600, % text
        ProgressGui := true
    }
    Progress, % percentage
}

; Function to hide the progress bar
HideProgress() {
    global ProgressGui
    if (ProgressGui) {
        Progress, Off
        ProgressGui := false
    }
}

; Function to check if a process exists
ProcessExist(ProcessName) {
    Process, Exist, %ProcessName%
    return ErrorLevel
}

; Function to run batch code
UpdateModels() {
    global TempBatchFile
    FileAppend, $models = (ollama list | Select-Object -Skip 1 | ForEach-Object { $_.Split()[0] })`nforeach ($model in $models) { ollama pull $model }`nPause, %TempBatchFile%
    RunWait, powershell.exe -NoExit -File "%TempBatchFile%"
    FileDelete, %TempBatchFile%
    MsgBox, All Models are updated!
}

CheckModels() {
    Run, https://ollama.com/library
}

; Check if Ollama is installed
if !FileExist(OllamaExePath) {
    MsgBox, 0x40030, Ollama Not Installed, Ollama is not installed on your system. Please install Ollama first before proceeding to open the Open WebUI.
    ExitApp
}

; Check if Ollama is already running
if !ProcessExist(OllamaProcessName) {
    ; Starting the progress bar
    ShowProgress(0, "Checking Ollama AI server..")
    
    Sleep, 500
    ShowProgress(50, "Ollama AI server is not running...")
    
    Sleep, 500

    ; Try starting Ollama app.exe
    Run, %ComSpec% /c ""%OllamaExePath%"", , Hide

    ; Wait for some time to check if the application is launched
    Sleep, 5000

    ; Check if the application has started
    if !ProcessExist(OllamaProcessName) {
        MsgBox, 0x40030, Ollama Launch Failed, Ollama app failed to start. Please check the installation and try again.
        ExitApp
    }

    ShowProgress(50, "Starting Ollama AI server..")
    Sleep, 500
    ShowProgress(65, "Booting AI...")
    Sleep, 500
    ShowProgress(75, "Booting AI....")
    Sleep, 500
    ShowProgress(90, "AI almost ready for Open WebUI.....")
    Sleep, 150
    ShowProgress(100, "Startup completed!")
    
    ; Check if Docker Desktop is installed
    if !FileExist(DockerExePath) {
        MsgBox, 0x40030, Docker Not Installed, Docker Desktop is not installed on your system. Please install Docker Desktop first before proceeding to open the Open WebUI.
        ExitApp
    }

    ; Check if Docker Desktop is already running
    if !ProcessExist(DockerProcessName) {
        Run, % DockerExePath

        Sleep, 500
        ShowProgress(50, "Starting Docker AI server..")
        Sleep, 5000
        ShowProgress(65, "Booting AI...")
        Sleep, 5000
        ShowProgress(75, "Booting AI....")
        Sleep, 5000
        ShowProgress(90, "AI almost ready for Open WebUI.....")
        Sleep, 1500
        ShowProgress(100, "Startup completed!")
        
        Run, http://localhost:3000/

        Sleep, 500
        HideProgress()
    } else {
        ShowProgress(50, "Checking Docker AI server..")
        
        Sleep, 500
        ShowProgress(75, "Docker AI is already running, booting Open WebUI...")
        Sleep, 500
        ShowProgress(100, "Startup completed!")

        Run, http://localhost:3000/

        Sleep, 500
        HideProgress()
    }
} else {
    ShowProgress(0, "Checking Ollama AI server...")
    Sleep, 500
	
    ShowProgress(50, "Ollama AI is already running, checking Docker AI server...")
    Sleep, 500

    ; Check if Docker Desktop is installed
    if !FileExist(DockerExePath) {
        MsgBox, 0x40030, Docker Not Installed, Docker Desktop is not installed on your system. Please install Docker Desktop first before proceeding to open the Open WebUI.
        ExitApp
    }

    ; Check if Docker Desktop is already running
    if !ProcessExist(DockerProcessName) {
        Run, % DockerExePath

        Sleep, 500
        ShowProgress(50, "Starting Docker AI server..")
        Sleep, 5000
        ShowProgress(65, "Booting AI...")
        Sleep, 5000
        ShowProgress(75, "Booting AI....")
        Sleep, 5000
        ShowProgress(90, "AI almost ready for Open WebUI.....")
        Sleep, 1500
        ShowProgress(100, "Startup completed!")
        
        Run, http://localhost:3000/

        Sleep, 500
        HideProgress()
    } else {
        ShowProgress(50, "Checking Docker AI server...")
        
        Sleep, 500
        ShowProgress(80, "Docker AI is already running, booting Open WebUI...")
        Sleep, 500
        ShowProgress(100, "Startup completed!")

        Run, http://localhost:3000/

        Sleep, 500
        HideProgress()
    }
}

; Handles the "Windows+a" key combination
#a::
    Run, http://localhost:3000/
    
return

ShowToolTip() {
    ToolTip, Window Minimized
    SetTimer, RemoveToolTip, 1500
    CloseButtonTooltipActive := true
}

RemoveToolTip() {
    ToolTip
    CloseButtonTooltipActive := false
}

#If WinActive("Installed AI List") And CloseUnderMouse()
LButton::WinMinimize
#If
CloseUnderMouse()
{
	CoordMode, Mouse, Window
	MouseGetPos, x, y
	WinGetPos,,, w,, A
	If (w - x <= 46) And (y <= 30) {
		If (!CloseButtonTooltipActive) {
            ShowToolTip()
        }
		return True
	}
	Return False
}

Return

ShowAIList:
	
	WebUIcommands := "serve    -   Start ollama`n" 
    . "create  -   Create a model from a Modelfile`n" 
    . "show    -   Show information for a model`n" 
    . "run        -   Run a model`n" 
    . "pull        -   Pull a model from a registry`n" 
    . "push     -   Push a model to a registry`n" 
    . "list         -   List models`n" 
    . "ps         -   List running models`n" 
    . "cp         -   Copy a model`n" 
    . "rm         -   Remove a model`n" 
    . "help      -   Help about any command`n`n"
	. "Just insert the command above to get the results, no need to write `ollama `:"
	
	; Check if the dialog is already open
    if AIListDialogOpen
        return

    ; Set the List Dialog Open variable to true
    AIListDialogOpen := true

    ; Creating the dialog box
	
    Gui, AIListDialog:Add, Text, x5 y5 w300 h20, Available Commands:`n
	Gui, AIListDialog:Add, Text, x20 y20 w400 h180, %WebUIcommands%
    Gui, AIListDialog:Add, Edit, x20 y210 w275 h20 vCommandText
    Gui, AIListDialog:Add, Button, x312 y207 w60 h25 gRunCommand, Enter >
    Gui, AIListDialog:Add, Text, x5 y245 w300 h20, Result:
    Gui, AIListDialog:Add, ListBox, x5 y265 w410 h200 vAIListText, % StrReplace(RunAIListCommand("ollama list"), "`n", "|")
    Gui, AIListDialog:Add, Button, x172.5 y535 w75 h30 Default gCloseAIList, Close
    Gui, AIListDialog:Show, w420 h580, Installed AI List

Return

CloseAIList:
    ; Close the dialog window
    Gui, AIListDialog:Destroy

    ; Kill the CMD process in the background
    if (cmdPID) {
        Process, Close, %cmdPID%  ; Uses the cmd PID variable stored in RunE List Command
        cmdPID := ""
    }
    
    ; Resets the List Dialog Open variable to false
    AIListDialogOpen := false
return

RunAIListCommand(command) {
    ; Run the ollama list command and capture the output
    commandOutput := ""
    RunWait, %comspec% /c %command%,, Hide, pid
    Process, WaitClose, %pid%
    file := A_Temp . "\ollama_list_output.txt"
    FileDelete, %file%
    RunWait, %comspec% /c %command% > %file%,, Hide
    FileRead, commandOutput, %file%
    FileDelete, %file%

    ; Remove the first line from the output
    StringSplit, lines, commandOutput, `n
    outputWithoutFirstLine := ""
    Loop, % lines0 {
        if (A_Index != 1) {
            outputWithoutFirstLine .= lines%A_Index% "`n"
        }
    }
    return outputWithoutFirstLine
}
	
RunCommand:
    ; Get text from writing bar
    GuiControlGet, Command, , CommandText

    ; Add "ollama " to the command
    command := "ollama " . Command

    ; Run the command
    AIList := RunAIListCommand(command)

    ; Update the text with the result
    GuiControl,, AIListText, %AIList%
Return

ReloadScript:
    Reload
return

OpenScriptSite() {
    Run, https://github.com/Special-Niewbie/Ollama-Open-WebUI-Script
}

; Function to show version information
ShowVersionInfo:
    MsgBox, 64, Version Info, Script Version: 1.0.0 `nAuthor: Special-Niewbie Softwares `nCopyright(C) 2024 Special-Niewbie Softwares
return

ExitApp:
ExitApp
