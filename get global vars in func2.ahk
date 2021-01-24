#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
SetBatchLines, -1
#KeyHistory 0
ListLines Off
SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match.

sourcePath:="sample-input-files\renderCurrentDir2.ahk"
SplitPath, sourcePath, OutFileName
filePath:=A_Temp "\" OutFileName
FileDelete, %filePath%
if (errorlevel) {
    clipboard:=sourcePath
    p("couldnt delete " sourcePath)
}
appendStart:="#NoEnv `; Recommended for performance and compatibility with future AutoHotkey releases.`n#SingleInstance, force`nSendMode Input  `; Recommended for new scripts due to its superior speed and reliability.`nSetWorkingDir %A_ScriptDir%  `; Ensures a consistent starting directory.`nSetBatchLines, -1`n#KeyHistory 0`nListLines Off`n`nListVars`n`n"
appendEnd:="`n`nf3::Exitapp`n"
FileRead, sourceFunc, %sourcePath%

emptyVariadicFunctions:="`n"

for funcName in listFunctionsInString(sourceFunc) {
    emptyVariadicFunctions.=funcName "(params*) {`n}`n"
}

FileAppend, % appendStart sourceFunc appendEnd emptyVariadicFunctions, %filePath%

runErrorTitle:=OutFileName " ahk_class #32770 ahk_exe AutoHotkeyU64.exe"
listvarsTitle:=filePath " - AutoHotkey ahk_class AutoHotkey ahk_exe AutoHotkeyU64.exe"

Run, "C:\Program Files\AutoHotkey\AutoHotkeyU64.exe" "%filePath%"
winwaitactive, % listvarsTitle
ControlGetText, globalVarsText, Edit1, % listvarsTitle

arr:=StrSplit(globalVarsText, "`n", "`r")
arr.remove(3)
arr.remove(3)
arrOfVarNames:=[]
for k, v in arr {
        arrOfVarNames.push(getUntil(v, "["))
}
dynamicVars:=listDynamicVars(sourceFunc, arrOfVarNames)

if dynamicVars.Count() {
    arrOfVarNames.push("Dynamic Vars:")
    arrOfVarNames.push("--------------------------------------------------")
    for dynamicVar in dynamicVars {
        arrOfVarNames.push(dynamicVar)
    }

}

d(arrOfVarNames)

ExitApp

getUntil(string, Needle) {
    pos:=InStr(string, Needle)
    return SubStr(String, 1 , pos - 1)
}

startWith(string, subString) {
    length:=StrLen(subString)
    if (SubStr(string, 1, length)=subString)
        return length + 1
    else
        return false
}

createGroup(groupName, titleArr) {
    global
    for k, v in titleArr {

        GroupAdd, %groupName%, %v%
    }
}

; Error:  Call to nonexistent function.
; 
; Specifically: URItoPath(EcurrentDir%whichSide%)
; 
; Line#
; 005: SetBatchLines,-1
; 007: ListLines,Off
; 010: {
; 011: ListVars
; 013: Gui,main:Default
; 015: if (SubStr(EcurrentDir%whichSide%,1,5)="file:")  
; 015: {
; --->	016: ansiPath := URItoPath(EcurrentDir%whichSide%)
; 017: decodeStrAs(ansiPath, "UTF-8")  
; 019: }
; 021: EcurrentDir%whichSide% := LTrim(EcurrentDir%whichSide%,"file:///")
; 022: EcurrentDir%whichSide% := StrReplace(EcurrentDir%whichSide%, "%20", " ")
; 024: lastChar := SubStr(EcurrentDir%whichSide%, 0)
; 025: if (lastChar="\")  
; 026: EcurrentDir%whichSide% := SubStr(EcurrentDir%whichSide%, 1, StrLen(EcurrentDir%whichSide%)-1)
; 
; The program will exit.

listFunctionsInString(fileContent) {
    ;ignore strings
    fileContent:=RegExReplace(fileContent, """.*?""")

    funcNames:={}

    pos := 1
    strLength:=0
    firstFunc:=""
    while(pos := RegExMatch(fileContent, "([0-9a-zA-Z0-9_#@$]+)\(.*?\)", funcMatch, pos + strLength)) {
        strLength:=StrLen(funcMatch)
        if funcMatch1 is not digit 
        {
            if (firstFunc and funcMatch1!=firstFunc) {
                funcNames[funcMatch1]:=true
            } else {
                firstFunc:=funcMatch1
            }
        }
    }
    return funcNames
}

listDynamicVars(fileContent, indexVars) {
    ;ignore strings
    fileContent:=RegExReplace(fileContent, """.*?""")
    dynamicVars:={}

    for k, indexVar in indexVars {

        pos := 1
        strLength:=0
        while(pos := RegExMatch(fileContent, "[0-9a-zA-Z0-9_#@$]+%" indexVar "%", dynamicVarMatch, pos + strLength)) {
            ; p(funcMatch)
            strLength:=StrLen(dynamicVarMatch)
            dynamicVars[dynamicVarMatch]:=true
        }
    }
    return dynamicVars
}

f3::Exitapp