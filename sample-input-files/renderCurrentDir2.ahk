renderCurrentDir()
{
    global
    local ansiPath, bothSameDir, dirToStopWatching,i,k,v,y,drive
    ; global EcurrentDir1, EcurrentDir2, whichSide, currentDirSearch, stopSizes
    Gui, main:Default

    if (SubStr(EcurrentDir%whichSide%,1,5)="file:") {
        ansiPath:=URItoPath(EcurrentDir%whichSide%)
        EcurrentDir%whichSide%:=decodeStrAs(ansiPath, "UTF-8")
    }

    EcurrentDir%whichSide%:=LTrim(EcurrentDir%whichSide%,"file:///")
    EcurrentDir%whichSide%:=StrReplace(EcurrentDir%whichSide%, "%20", " ")
    ; d(EcurrentDir%whichSide%)
    lastChar:=SubStr(EcurrentDir%whichSide%, 0)
    if (lastChar="\")
        EcurrentDir%whichSide%:=SubStr(EcurrentDir%whichSide%, 1, StrLen(EcurrentDir%whichSide%)-1)
    EcurrentDir%whichSide%:=Rtrim(EcurrentDir%whichSide%," ")
    EcurrentDir%whichSide%:=StrReplace(EcurrentDir%whichSide%, "/" , "\")
    Gui, ListView, vlistView%whichSide%

    currentDirSearch:=""
    if (InStr(fileExist(EcurrentDir%whichSide%), "D"))
    {
        stopSizes:=false

        if (lastDir%whichSide%!=EcurrentDir%whichSide% ) {
            bothSameDir:=bothSameDir(whichSide)
            if (lastDir%whichSide%!="" and EcurrentDir%otherSide%!=lastDir%whichSide%) {
                for k, v in watching%whichSide% {
                    if (v=lastDir%whichSide%) {
                        watching%whichSide%.Remove(k)
                        dirToStopWatching:=v
                        break
                    }
                }
                stopWatchFolder(whichSide,dirToStopWatching) 
            }

            if (!bothSameDir) {
                watching%whichSide%.Push(EcurrentDir%whichSide%)
                startWatchFolder(whichSide,EcurrentDir%whichSide%)
            }

            if (lastDir%whichSide%!="" and !cannotDirHistory%whichSide%) {
                dirHistory%whichSide%.Push(lastDir%whichSide%)
            }
        }
        if cannotDirHistory%whichSide% {
            cannotDirHistory%whichSide%:=false
        }
        lastDir%whichSide%:=EcurrentDir%whichSide%
        focused=flistView

        filePaths:=[] 
        rowBak:=[]
        ; dates:=[]
        sortableDates:=[]
        sizes:=[]
        sortableSizes:=[]
        ; dateColors:=[]
        filesWithNoExt:=[]
        if (lastIconNumber)
            rememberIconNumber:=lastIconNumber

        unsorted%whichSide%:=[]
        sortedByDate%whichSide%:=[]
        sortedBySize%whichSide%:=[]
        canSortBySize%whichSide%:=false
        stuffByName%whichSide%:={}
        sortedDates:=[]
        sortedSizes%whichSide%:=[]
        Loop, Files, % EcurrentDir%whichSide% "\*", DF
        {
            stuffByName%whichSide%[A_LoopFileName]:={date:A_LoopFileTimeModified,attri:A_LoopFileAttrib,size:A_LoopFileSize}

            sortedDates.Push({date:A_LoopFileTimeModified,name:A_LoopFileName})
        }

        sortedDates:=sortArrByKey(sortedDates,"date")
        ; sortedDates:=sortArrByKey(sortedDates,"date",true)

        for k, v in sortedDates {
            sortedByDate%whichSide%.Push(v["name"])
        }

        firstSizes%whichSide%:=true
        whichsort%whichSide%:="newOld"
        oldNew%whichSide%:=false 

        renderFunctionsToSort(sortedByDate%whichSide%)

        Gui, ListView, folderlistView2_%whichSide%
        LV_Delete()
        parent1DirDirs%whichSide%:=[]
        SplitPath, EcurrentDir%whichSide%, , parent1Dir%whichSide%
        SplitPath, parent1Dir%whichSide%, Out2DirName%whichSide% , parent2Dir%whichSide%,,,OutDrive2%whichSide%
        SplitPath, parent2Dir%whichSide%, Out3DirName%whichSide%, parent3Dir%whichSide%,,,OutDrive3%whichSide%
        Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"

        if (parent1Dir%whichSide%!=EcurrentDir%whichSide%) {
            if (!Out2DirName%whichSide%)
                Out2DirName%whichSide%:=OutDrive2%whichSide%
            LV_ModifyCol(1,"NoSort", Out2DirName%whichSide%)
            Loop, Files, % parent1Dir%whichSide% "\*", D
            {
                if (A_LoopFileLongPath!=EcurrentDir%whichSide%) {
                    LV_Add(, A_LoopFileName)
                    parent1DirDirs%whichSide%.Push(A_LoopFileLongPath)
                } else {
                    toSelect:=(A_Index=1) ? 1 : A_Index-1
                }
            }
            Gui, ListView, folderlistView2_%whichSide% ;just in case
            LV_Modify(toSelect, "+Select +Focus Vis") ; select
        } else
        {
            LV_ModifyCol(1,"NoSort", "")
        } 
        Gui, ListView, folderlistView1_%whichSide%
        LV_Delete()
        parent2DirDirs%whichSide%:=[] 
        if (parent2Dir%whichSide%!=parent1Dir%whichSide%) {
            if (!Out3DirName%whichSide%)
                Out3DirName%whichSide%:=OutDrive3%whichSide%
            LV_ModifyCol(1,"NoSort", Out3DirName%whichSide%)
            Loop, Files, % parent2Dir%whichSide% "\*", D
            {
                if (A_LoopFileLongPath!=parent1Dir%whichSide%) {
                    LV_Add(, A_LoopFileName)
                    parent2DirDirs%whichSide%.Push(A_LoopFileLongPath)
                } else {
                    toSelect:=(A_Index=1) ? 1 : A_Index-1
                }
            }
            Gui, ListView, folderlistView1_%whichSide% ;just in case
            LV_Modify(toSelect, "+Select +Focus Vis") ; select
        }
        else
        {
            LV_ModifyCol(1,"NoSort", "")
        } 

        DriveGet, OutputVar, List
        drives:=StrSplit(OutputVar,"")
        length:=drives.Length()

        for i, drive in drives {
            y:=40*(i-1)
            DriveGet, totalSpace, Capacity, %drive%:
            DriveSpaceFree, freeSpace, %drive%:

                text:=drive ":\ " Round(100-100*freeSpace/totalSpace, 2) "%`n" autoMegaByteFormat(freeSpace) "/" autoMegaByteFormat(totalSpace)
                if (i>numberOfDrives) {
                    gui, add, button,h40 y%y% w%favoritesListViewWidth% vDrive%i% x0 Left ggChangeDrive, % text
                }
                else {
                    GuiControl, Show, Drive%i%
                    GuiControl, Text, Drive%i%, % text
                }
            }

            loop % numberOfDrives {
                if (A_Index>length) {
                    GuiControl, Hide, Drive%A_Index%
                }
            }

            if (length>numberOfDrives)
                numberOfDrives:=length
        } else {
            SplitPath, EcurrentDir%whichSide%, OutFileName%whichSide%, OutDir%whichSide%
            if (InStr(fileExist(OutDir%whichSide%), "D")) {
                toFocus:=OutFileName%whichSide%
                EcurrentDir%whichSide%:=OutDir%whichSide%

                renderCurrentDir()

            } else {
                ; p(fileExist(currentDir))
                EcurrentDir%whichSide%:=lastDir%whichSide%
                GuiControl, Text,vcurrentDirEdit%whichSide%, % EcurrentDir%whichSide%

                if (focused!="changePath") {
                    renderCurrentDir()
                }
                ; lastDir:=currentDir
            } 

        }
        Gui, ListView, vlistView%whichSide%
    }