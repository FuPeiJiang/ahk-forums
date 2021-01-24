#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
SetBatchLines, -1
#KeyHistory 0
ListLines Off

filePath:="sample-input-files\renderCurrentDir3.ahk"
FileRead, fileContent, %filePath%

funcNames:=listDynamicVars(fileContent)
p(funcNames)

listDynamicVars(fileContent) {
    fileContent:=RegExReplace(fileContent, """.*?""")
    dynamicVars:={}

    fileContent:=removeComments(fileContent)

    unlocked:=false
    pos := 1
    strLength:=0
    ;var can contain [a-zA-Z0-9_#@$]
    ; either var or %var%
    while(pos := RegExMatch(fileContent, "%[a-zA-Z0-9_#@$]+?%|[a-zA-Z0-9_#@$]+", dynamicVarMatch, pos)) {

        ; if (dynamicVarMatch="EcurrentDir")
        ; unlocked:=true
        ; if (unlocked) {
        if (pos=pastPos) {
            passed:=true
            ImHoldingThis.Push(dynamicVarMatch)
        } else {
            if (passed) {
                strDynamicVar:=validDynamicVar(ImHoldingThis) ;this returns the array to string if all valid!
                dynamicVars[strDynamicVar]:=true
            }
            ImHoldingThis:=[dynamicVarMatch]
            passed:=false
        }
        ; }

        strLength:=StrLen(dynamicVarMatch)
        pos+=strLength
        pastPos:=pos
        pastMatch:=dynamicVarMatch

    }
    return dynamicVars
}

validDynamicVar(ImHoldingThis) {
    ; only letters without %% cannot come though, since it would be length 1, only length >1 can come here
    ; everything here has %%, but it cannot be ONLY %%, we need at least a letter one. : that's why notBlank
    for k, v in ImHoldingThis {
        if (SubStr(v, 1, 1)="%") {
            var:=SubStr(v, 2, -1)
        } else {
            var:=v
            ; Error:  This dynamic variable is blank. If this variable was not intended to be dynamic, remove the % symbols from it.
            notBlank:=true
        }
        ; a var name cannot be ONLY digits
        if var is digit
            return
        strDynamicVar.=v
    }
    if (notBlank)
        return strDynamicVar
}

return

removeComments(content) {
    content:=RegExReplace(content, "sm)\/\*.*?^\s*\*\/")
    content:=RegExReplace(content, "m`n)\s+;.*$")
    return content
}

f3::Exitapp