#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
SetBatchLines, -1
#KeyHistory 0
ListLines Off

filePath:="sample-input-files\renderCurrentDir3.ahk"
FileRead, fileContent, %filePath%
funcNames:=listFunctionsInString(fileContent)
d(funcNames)

listFunctionsInString(fileContent) {
    fileContent:=RegExReplace(fileContent, """.*?""")

    funcNames:={}

    pos := 1
    strLength:=0
    while(pos := RegExMatch(fileContent, "([0-9a-zA-Z0-9_#@$]+)\(.*?\)", funcMatch, pos + strLength)) {
        strLength:=StrLen(funcMatch)
        if funcMatch1 is not digit 
        {
            funcNames[funcMatch1]:=true
        }
    }
    return funcNames
}


ExitApp

f3::Exitapp