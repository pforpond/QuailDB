REM quailDB manager
REM version 0.4
REM By Danielle Pond - For Xander Tate

REM 420 - no db file

setup:
ON ERROR GOTO errorhandler
$VERSIONINFO:CompanyName=Xander_Farms
$VERSIONINFO:ProductName=QuailDB
$VERSIONINFO:FileDescription=XanQuailDatabase
$VERSIONINFO:InternalName=QuailDB
$EXEICON:'data\icon.ico'
_ICON
LET devmode = 0
LET hardbuild$ = "0.4"
LET checkupdatelink$ = "https://dl.dropboxusercontent.com/s/kxkujrmdgrfhnem/checkupdate.ddf"
LET zipupdatelink$ = "https://dl.dropboxusercontent.com/s/8sej0p4axfsqwpp/unzip.exe"
LET winupdaterlink$ = "https://dl.dropboxusercontent.com/s/7c9a1o4m2j0swig/quaildbupdater.exe"
LET lnxupdaterlink$ = "https://dl.dropboxusercontent.com/s/8mth5t8a5jlsf1v/quaildbupdater"
LET looplimit = 100
LET arraytotal = 1000
_TITLE "Xander's Quail Database"
SCREEN _NEWIMAGE(800, 600, 32)
$RESIZE:STRETCH
$CONSOLE
IF devmode = 1 THEN
    _CONSOLE ON
ELSE
    _CONSOLE OFF
END IF
LET dbfont& = _LOADFONT("data/font.ttf", 30)
_FONT dbfont&
LET quaildb$ = "data/quaildb.ddf"
LET settingsfile$ = "data/settings.ddf"
REM check os
IF INSTR(_OS$, "[WINDOWS]") THEN LET ros$ = "win"
IF INSTR(_OS$, "[LINUX]") THEN LET ros$ = "lnx"
IF INSTR(_OS$, "[MACOSX]") THEN LET ros$ = "mac"
IF ros$ = "mac" THEN ERROR 430
IF ros$ <> "win" AND ros$ <> "lnx" THEN ERROR 430
REM checks photo folder
LET photofolder$ = "data/photos/"
IF _DIREXISTS(photofolder$) THEN
	REM nothing
ELSE
	REM creates folder
	IF ros$ = "win" THEN SHELL _HIDE "mkdir data\photos"
	IF ros$ = "lnx" THEN SHELL _HIDE "mkdir data/photos"
END IF
REM checks parameters
LET parameter$ = COMMAND$
LET findnoupdate% = INSTR(findnoupdate% + 1, UCASE$(parameter$), "-NOUPDATE")
LET findfix% = INSTR(findfix% + 1, UCASE$(parameter$), "-FIX")
IF findnoupdate% THEN LET noupdate = 1
IF findfix% THEN LET fixinstall = 1
IF fixinstall = 1 AND noupdate = 1 THEN ERROR 421
GOSUB removedebris
GOSUB updatechecker
GOSUB dimmer
GOSUB loadsettings
GOSUB checkdb
GOSUB loaddb
GOSUB backupdb
GOTO mainmenu

checkdb:
REM checks if database exists, makes new if not
CLS
PRINT "CHECKING DATABASE..."
IF _FILEEXISTS(quaildb$) THEN
	REM nothing!
ELSE
	REM creates new database file
	BEEP
	PRINT "...NO DATABASE FOUND!"
	PRINT "press any key to make a new database"
	DO
	LOOP WHILE INKEY$ = ""
    OPEN quaildb$ FOR OUTPUT AS #1
    CLOSE #1
END IF
RETURN

removedebris:
REM removes update debris
CLS
PRINT "REMOVING DEBRIS..."
IF ros$ = "lnx" THEN
    SHELL _HIDE "rm -R updatebackup"
    SHELL _HIDE "rm checkupdate.ddf"
    SHELL _HIDE "rm quaildbupdater"
    SHELL _HIDE "rm quaildbupdater.exe"
    SHELL _HIDE "rm windownloader.bat"
    SHELL _HIDE "rm unzip.exe"
    SHELL _HIDE "rm quaildbupdate.zip"
    SHELL _HIDE "rm *.tmp"
END IF
IF ros$ = "win" THEN
    SHELL _HIDE "rmdir /Q /S updatebackup"
    SHELL _HIDE "del checkupdate.ddf"
    SHELL _HIDE "del quaildbupdater"
    SHELL _HIDE "del quaildbupdater.exe"
    SHELL _HIDE "del windownloader.bat"
    SHELL _HIDE "del unzip.exe"
    SHELL _HIDE "del quaildbupdate.zip"
    SHELL _HIDE "del *.tmp"
END IF
RETURN

updatechecker:
REM checks online for any version updates
IF devmode = 1 THEN RETURN: REM return for if developer mode is on
IF noupdate = 1 THEN RETURN: REM return for is no update is on
CLS
PRINT "CHECKING FOR UPDATES..."
PRINT
REM downloads check update file
IF ros$ = "lnx" THEN SHELL _HIDE "curl -o checkupdate.ddf " + checkupdatelink$
IF ros$ = "win" THEN
    SHELL _HIDE "copy data\windownloader.bat windownloader.bat"
    SHELL _HIDE "windownloader.bat " + checkupdatelink$ + " checkupdate.ddf"
END IF
REM checks to see if file downloaded
IF _FILEEXISTS("checkupdate.ddf") THEN
    REM nothing
ELSE
    REM file failed to download!
    PRINT "...CANNOT CONNECT TO SERVER!"
    _DELAY 1
    RETURN
END IF
OPEN "checkupdate.ddf" FOR INPUT AS #1
INPUT #1, updatebuild$
CLOSE #1
IF fixinstall = 1 THEN LET hardbuild$ = "ilovexander"
IF updatebuild$ <> hardbuild$ THEN
    REM nothing
ELSE
    REM you are on the latest version
    PRINT "...YOU HAVE THE LATEST VERSION!"
    _DELAY 1
    IF ros$ = "lnx" THEN SHELL _HIDE "rm checkupdate.ddf"
    IF ros$ = "win" THEN SHELL _HIDE "del checkupdate.ddf"
    RETURN
END IF
REM download updater and zip tool
PRINT "...AN UPDATE IS AVAILABLE!"
PRINT
PRINT "- DOWNLOADING UPDATER..."
IF ros$ = "lnx" THEN
    REM linux update
    SHELL _HIDE "curl -o quaildbupdater " + lnxupdaterlink$
    REM checks to see if download completed
    IF _FILEEXISTS("quaildbupdater") THEN
        REM nothing
    ELSE
        PRINT "...UPDATE FAILED! FAILED TO DOWNLOAD UPDATER!"
        PRINT "Press enter to continue"
        INPUT a
        SHELL _HIDE "rm checkupdate.ddf"
        RETURN
    END IF
    SHELL _HIDE "chmod +x quaildbupdater"
END IF
IF ros$ = "win" THEN
    REM windows update
    SHELL _HIDE "windownloader.bat " + winupdaterlink$ + " quaildbupdater.exe"
    SHELL _HIDE "windownloader.bat " + zipupdatelink$ + " unzip.exe"
    IF _FILEEXISTS("quaildbupdater.exe") THEN
        REM nothing
    ELSE
        PRINT "...UPDATE FAILED! FAILED TO DOWNLOAD UPDATER!"
        PRINT "Press enter to continue"
        INPUT a
        SHELL _HIDE "del checkupdate.ddf"
        SHELL _HIDE "del windownloader.bat"
        RETURN
    END IF
    IF _FILEEXISTS("unzip.exe") THEN
        REM nothing
    ELSE
        PRINT "...UPDATE FAILED! FAILED TO DOWNLOAD UPDATER!"
        PRINT "Press enter to continue"
        INPUT a
        SHELL _HIDE "del checkupdate.ddf"
        SHELL _HIDE "del windownloader.bat"
        SHELL _HIDE "del quaildbupdater.exe"
        RETURN
    END IF
END IF
REM updater is ready, time to run it!
PRINT "...DONE!"
PRINT "- LAUNCHING UPDATER..."
_DELAY 3
IF ros$ = "lnx" THEN SHELL _DONTWAIT "./quaildbupdater"
IF ros$ = "win" THEN SHELL _DONTWAIT "quaildbupdater.exe"
SYSTEM

dimmer:
REM dimmer
DIM quailid(arraytotal) AS INTEGER
DIM quailname(arraytotal) AS STRING
DIM quailstatus(arraytotal) AS INTEGER
DIM quaildateofbirth(arraytotal) AS STRING
DIM quaildateofdeath(arraytotal) AS STRING
DIM quailsex(arraytotal) AS INTEGER
DIM quailcolour(arraytotal) AS INTEGER
DIM quailhoopid(arraytotal) AS INTEGER
DIM quailnotes(arraytotal) AS STRING
DIM quailweight(arraytotal) AS INTEGER
DIM listkeydata(arraytotal) AS STRING
DIM collum1data(arraytotal) AS STRING
DIM collum2data(arraytotal) AS STRING
DIM collum3data(arraytotal) AS STRING
DIM listiddata(arraytotal) AS INTEGER
DIM importphoto(arraytotal) AS STRING
DIM photoext(arraytotal) AS STRING
RETURN

loaddb:
REM loads database into memory
CLS
LET x = 0
PRINT "LOADING DATABASE..."
OPEN quaildb$ FOR INPUT AS #1
DO
    LET x = x + 1
    INPUT #1, quailid(x), quailname$(x), quailstatus(x), quaildateofbirth$(x), quaildateofdeath$(x), quailweight(x), quailsex(x), quailcolour(x), quailhoopid(x), quailnotes$(x)
LOOP UNTIL EOF(1)
CLOSE #1
RETURN

loadsettings:
REM loads settings into memory
CLS
PRINT "LOADING SETTINGS..."
IF _FILEEXISTS(settingsfile$) THEN
	REM nothing
ELSE
	GOSUB newsettings
END IF
OPEN settingsfile$ FOR INPUT AS #2
INPUT #2, titlecolour$, importphotosloc$
CLOSE #2
RETURN

newsettings:
REM makes a new settings file
PRINT "NO SETTINGS FILE FOUND! RESETTING TO DEFAULT!"
OPEN settingsfile$ FOR OUTPUT AS #2
WRITE #2, "&HFFFCFCFC", "/home/"
CLOSE #2
RETURN

backupdb:
REM backs up database
CLS
PRINT "BACKING UP DATABASE..."
GOSUB calculateindex
IF fullid = 0 THEN RETURN
REM checks dir exists
IF _DIREXISTS("data/backups") THEN
    REM nothing
ELSE
    REM create new directory
    IF ros$ = "lnx" THEN SHELL _HIDE "mkdir data/backups"
    IF ros$ = "win" THEN SHELL _HIDE "mkdir data\backups"
END IF
REM backs up
OPEN "data/backups/quaildb-" + DATE$ + ".ddf" FOR OUTPUT AS #1
LET x = 0
DO
    LET x = x + 1
    WRITE #1, quailid(x), quailname$(x), quailstatus(x), quaildateofbirth$(x), quaildateofdeath$(x), quailweight(x), quailsex(x), quailcolour(x), quailhoopid(x), quailnotes$(x)
LOOP UNTIL x = fullid
CLOSE #1
RETURN

errorhandler:
IF devmode = 1 THEN
    _DEST _CONSOLE
    PRINT "error - "; ERR; " line - "; _ERRORLINE
    _DEST 0
END IF
IF ERR = 420 THEN BEEP: PRINT "ERROR! Database file missing!": PRINT "Contact Danni!": END
IF ERR = 421 THEN BEEP: PRINT "ERROR! Conflicting launch commands!": END
IF ERR = 430 THEN BEEP: PRINT "ERROR! Unsupported OS!": END
RESUME NEXT

mainmenu:
CLS
PRINT "XANDER'S QUAIL DATABASE!"
PRINT "version " + hardbuild$
PRINT
PRINT "What would you like to do?"
PRINT "1 - New Quail"
PRINT "2 - Search by Hoop ID"
PRINT "3 - Search by Name"
PRINT "4 - List"
PRINT "5 - Catalog"
PRINT "6 - Settings"
PRINT "7 - Quit"
PRINT
INPUT a
IF a = 1 THEN GOSUB newquailentry: LET a = 0
IF a = 2 THEN GOSUB hoopidsearch: LET a = 0
IF a = 3 THEN GOSUB namesearch: LET a = 0
IF a = 4 THEN GOSUB listentries: LET a = 0
IF a = 5 THEN GOSUB catalogentries: LET a = 0
IF a = 6 THEN GOSUB settingsmenu: LET a = 0
IF a = 7 THEN PRINT "GOODBYE!": _DELAY 0.5: SYSTEM
GOTO mainmenu

settingsmenu:
REM settings menu 
CLS
PRINT "SETTINGS MENU!"
PRINT
PRINT "What would you like to do?"
PRINT "1 - Back to Main Menu"
PRINT "2 - Change Title Colour"
PRINT "3 - Change Photo Import Folder"
PRINT "4 - Erase Databse"
PRINT
INPUT a
IF a = 1 THEN LET a = 0: RETURN
IF a = 2 THEN PRINT "NOT READY YET!": _DELAY 1
IF a = 3 THEN GOSUB changephotosetting
IF a = 4 THEN GOSUB erasedb
GOTO settingsmenu

changephotosetting:
REM writes a change to the settings regarding photo imports
LET importfolderexists = 0
IF _DIREXISTS(importphotosloc$) THEN LET importfolderexists = 1
CLS
PRINT "PHOTO IMPORT FOLDER!"
PRINT
PRINT "The current folder is set at: " + importphotosloc$
IF importfolderexists = 0 THEN
	PRINT "The folder does not exist!"
ELSE
	PRINT "The folder exists!"
END IF
PRINT
PRINT "Where are your quail photos located?"
PRINT "(press enter to keep current settings!)"
INPUT tempimportphotosloc$
PRINT
REM returns
IF tempimportphotosloc$ = "" THEN RETURN
IF tempimportphotosloc$ = importphotosloc$ THEN RETURN
IF _DIREXISTS(tempimportphotosloc$) THEN
	REM new folder exists! save changes!
	LET importphotosloc$ = tempimportphotosloc$
	REM adds slash to path if needed
	IF ros$ = "lnx" THEN IF RIGHT$(importphotosloc$, 1) <> "/" THEN LET importphotosloc$ = importphotosloc$ + "/"
	IF ros$ = "win" THEN IF RIGHT$(importphotosloc$, 1) <> "\" THEN LET importphotosloc$ = importphotosloc$ + "\"
	OPEN settingsfile$ FOR OUTPUT AS #2
	WRITE #2, titlecolour$, importphotosloc$
	CLOSE #2
	PRINT "New photo location saved!"
	_DELAY 1
	RETURN
ELSE
	REM new folder does not exist! ask again!
	PRINT "Location does not exist!"
	_DELAY 1
	GOTO changephotosetting
END IF
RETURN

erasedb:
REM erases database
CLS
PRINT "ERASE DATABASE!"
PRINT
PRINT "Are you sure? Confirming will delete your entire database!"
PRINT "1 - Yes"
PRINT "2 - No"
PRINT
INPUT a
IF a <> 1 AND a <> 2 THEN GOTO erasedb
IF a = 2 THEN LET a = 0: RETURN
CLS
PRINT "ERASE DATABASE!"
PRINT
COLOR &HFFFC5454
PRINT "==!!FINAL WARNING!!=="
COLOR &HFFFCFCFC
PRINT "Proceeding will ERASE your DATABASE!"
PRINT "To proceed you must type in all caps"
PRINT
COLOR &HFF54FC54
PRINT "DELETE MY DATABASE NOW"
COLOR &HFFFCFCFC
PRINT
INPUT a$
IF a$ <> "DELETE MY DATABASE NOW" THEN LET a = 0: RETURN
LET itime = INT(TIMER)
LET temp = 0
CLS
DO
	LET soupkitchen = _KEYHIT
	LET ctime = INT(TIMER) - itime
	LET t = 60 - ctime
	LET tt = 30 - ctime
	IF temp = 0 AND tt = 0 THEN CLS: LET temp = 1
	COLOR &HFFFCFCFC
	LOCATE 1, 1: PRINT "ERASE DATABASE!"
	PRINT
	COLOR &HFFFC5454
	LOCATE 2, 1: PRINT "DATABASE WILL BE OVERWRITTEN IN " + LTRIM$(STR$(t)) + " SECONDS!"
	PRINT
	IF tt > 0 THEN 
		IF soupkitchen = 88 OR soupkitchen = 120 THEN LET a = 0: COLOR &HFFFCFCFC: LET temp = 0: RETURN
		COLOR &HFF54FC54
		LOCATE 3, 1: PRINT "OPTION TO OVERRIDE ERASE EXPIRES IN " LTRIM$(STR$(tt)) + " SECONDS!"
		LOCATE 4, 1: PRINT "PRESS X TO OVERRIDE ERASE!"
	ELSE
		LOCATE 3, 1: PRINT "OPTION TO OVERRIDE ERASE HAS EXPIRED!"
	END IF
	_LIMIT 100
LOOP UNTIL t = 0
CLS
COLOR &HFFFCFCFC
PRINT "ERASING DATABASE..."
IF ros$ = "win" THEN SHELL _HIDE "del " + quaildb$
IF ros$ = "lnx" THEN SHELL _HIDE "rm " + quaildb$
PRINT "...ERASE COMPLETE!"
PRINT
PRINT "You must now close this window and relaunch!"
DO
	_LIMIT looplimit
LOOP

loadandsortlist:
REM loads list into memory then sorts it into order
REM copy list to memory
FOR xx = 1 TO fullid
	REM internal id
	LET listiddata(xx) = quailid(xx)
	REM key data
	IF listkey$ = "internalid" THEN LET listkeydata$(xx) = LTRIM$(STR$(quailid(xx)))
	IF listkey$ = "name" THEN LET listkeydata$(xx) = quailname$(xx)
	IF listkey$ = "status" THEN 
		IF quailstatus(xx) = 1 THEN LET listkeydata$(xx) = "Unknown"
		IF quailstatus(xx) = 2 THEN LET listkeydata$(xx) = "Chick"
		IF quailstatus(xx) = 3 THEN LET listkeydata$(xx) = "Active"
		IF quailstatus(xx) = 4 THEN LET listkeydata$(xx) = "Retired"
		IF quailstatus(xx) = 5 THEN LET listkeydata$(xx) = "Dead"
		IF quailstatus(xx) = 6 THEN LET listkeydata$(xx) = "Sold"
	END IF
	IF listkey$ = "sex" THEN
		IF quailsex(xx) = 1 THEN LET listkeydata$(xx) = "Unknown"
		IF quailsex(xx) = 2 THEN LET listkeydata$(xx) = "Male"
		IF quailsex(xx) = 3 THEN LET listkeydata$(xx) = "Female"
	END IF
	IF listkey$ = "dateofbirth" THEN LET listkeydata$(xx) = quaildateofbirth$(xx)
	IF listkey$ = "dateofdeath" THEN LET listkeydata$(xx) = quaildateofdeath$(xx)
	IF listkey$ = "colour" THEN
		IF quailcolour(xx) = 1 THEN LET listkeydata$(xx) = "Unknown"
		IF quailcolour(xx) = 2 THEN LET listkeydata$(xx) = "Silver"
		IF quailcolour(xx) = 3 THEN LET listkeydata$(xx) = "Moonridge Blue"
		IF quailcolour(xx) = 4 THEN LET listkeydata$(xx) = "Wild Type"
		IF quailcolour(xx) = 5 THEN LET listkeydata$(xx) = "Pharaoh"
		IF quailcolour(xx) = 6 THEN LET listkeydata$(xx) = "Fawn"
		IF quailcolour(xx) = 7 THEN LET listkeydata$(xx) = "Snowflake"
		IF quailcolour(xx) = 8 THEN LET listkeydata$(xx) = "Chocolate"
		IF quailcolour(xx) = 9 THEN LET listkeydata$(xx) = "White"
		IF quailcolour(xx) = 10 THEN LET listkeydata$(xx) = "Broken White"
		IF quailcolour(xx) = 11 THEN LET listkeydata$(xx) = "Mixed"
	END IF
	IF listkey$ = "hoopid" THEN LET listkeydata$(xx) = LTRIM$(STR$(quailhoopid(xx)))
	IF listkey$ = "weight" THEN LET listkeydata$(xx) = LTRIM$(STR$(quailweight(xx))) + "G"
	REM collum 1
	IF collum1$ = "internalid" THEN LET collum1data$(xx) = LTRIM$(STR$(quailid(xx)))
	IF collum1$ = "name" THEN LET collum1data$(xx) = quailname$(xx)
	IF collum1$ = "status" THEN 
		IF quailstatus(xx) = 1 THEN LET collum1data$(xx) = "Unknown"
		IF quailstatus(xx) = 2 THEN LET collum1data$(xx) = "Chick"
		IF quailstatus(xx) = 3 THEN LET collum1data$(xx) = "Active"
		IF quailstatus(xx) = 4 THEN LET collum1data$(xx) = "Retired"
		IF quailstatus(xx) = 5 THEN LET collum1data$(xx) = "Dead"
		IF quailstatus(xx) = 6 THEN LET collum1data$(xx) = "Sold"
	END IF
	IF collum1$ = "sex" THEN
		IF quailsex(xx) = 1 THEN LET collum1data$(xx) = "Unknown"
		IF quailsex(xx) = 2 THEN LET collum1data$(xx) = "Male"
		IF quailsex(xx) = 3 THEN LET collum1data$(xx) = "Female"
	END IF
	IF collum1$ = "dateofbirth" THEN LET collum1data$(xx) = quaildateofbirth$(xx)
	IF collum1$ = "dateofdeath" THEN LET collum1data$(xx) = quaildateofdeath$(xx)
	IF collum1$ = "colour" THEN
		IF quailcolour(xx) = 1 THEN LET collum1data$(xx) = "Unknown"
		IF quailcolour(xx) = 2 THEN LET collum1data$(xx) = "Silver"
		IF quailcolour(xx) = 3 THEN LET collum1data$(xx) = "Moonridge Blue"
		IF quailcolour(xx) = 4 THEN LET collum1data$(xx) = "Wild Type"
		IF quailcolour(xx) = 5 THEN LET collum1data$(xx) = "Pharaoh"
		IF quailcolour(xx) = 6 THEN LET collum1data$(xx) = "Fawn"
		IF quailcolour(xx) = 7 THEN LET collum1data$(xx) = "Snowflake"
		IF quailcolour(xx) = 8 THEN LET collum1data$(xx) = "Chocolate"
		IF quailcolour(xx) = 9 THEN LET collum1data$(xx) = "White"
		IF quailcolour(xx) = 10 THEN LET collum1data$(xx) = "Broken White"
		IF quailcolour(xx) = 11 THEN LET collum1data$(xx) = "Mixed"
	END IF
	IF collum1$ = "hoopid" THEN LET collum1data$(xx) = LTRIM$(STR$(quailhoopid(xx)))
	IF collum1$ = "weight" THEN LET collum1data$(xx) = LTRIM$(STR$(quailweight(xx))) + "G"
	REM collum 2
	IF collum2$ = "internalid" THEN LET collum2data$(xx) = LTRIM$(STR$(quailid(xx)))
	IF collum2$ = "name" THEN LET collum2data$(xx) = quailname$(xx)
	IF collum2$ = "status" THEN 
		IF quailstatus(xx) = 1 THEN LET collum2data$(xx) = "Unknown"
		IF quailstatus(xx) = 2 THEN LET collum2data$(xx) = "Chick"
		IF quailstatus(xx) = 3 THEN LET collum2data$(xx) = "Active"
		IF quailstatus(xx) = 4 THEN LET collum2data$(xx) = "Retired"
		IF quailstatus(xx) = 5 THEN LET collum2data$(xx) = "Dead"
		IF quailstatus(xx) = 6 THEN LET collum2data$(xx) = "Sold"
	END IF
	IF collum2$ = "sex" THEN
		IF quailsex(xx) = 1 THEN LET collum2data$(xx) = "Unknown"
		IF quailsex(xx) = 2 THEN LET collum2data$(xx) = "Male"
		IF quailsex(xx) = 3 THEN LET collum2data$(xx) = "Female"
	END IF
	IF collum2$ = "dateofbirth" THEN LET collum2data$(xx) = quaildateofbirth$(xx)
	IF collum2$ = "dateofdeath" THEN LET collum2data$(xx) = quaildateofdeath$(xx)
	IF collum2$ = "colour" THEN
		IF quailcolour(xx) = 1 THEN LET collum2data$(xx) = "Unknown"
		IF quailcolour(xx) = 2 THEN LET collum2data$(xx) = "Silver"
		IF quailcolour(xx) = 3 THEN LET collum2data$(xx) = "Moonridge Blue"
		IF quailcolour(xx) = 4 THEN LET collum2data$(xx) = "Wild Type"
		IF quailcolour(xx) = 5 THEN LET collum2data$(xx) = "Pharaoh"
		IF quailcolour(xx) = 6 THEN LET collum2data$(xx) = "Fawn"
		IF quailcolour(xx) = 7 THEN LET collum2data$(xx) = "Snowflake"
		IF quailcolour(xx) = 8 THEN LET collum2data$(xx) = "Chocolate"
		IF quailcolour(xx) = 9 THEN LET collum2data$(xx) = "White"
		IF quailcolour(xx) = 10 THEN LET collum2data$(xx) = "Broken White"
		IF quailcolour(xx) = 11 THEN LET collum2data$(xx) = "Mixed"
	END IF
	IF collum2$ = "hoopid" THEN LET collum2data$(xx) = LTRIM$(STR$(quailhoopid(xx)))
	IF collum2$ = "weight" THEN LET collum2data$(xx) = LTRIM$(STR$(quailweight(xx))) + "G"
	REM collum 3
	IF collum3$ = "internalid" THEN LET collum3data$(xx) = LTRIM$(STR$(quailid(xx)))
	IF collum3$ = "name" THEN LET collum3data$(xx) = quailname$(xx)
	IF collum3$ = "status" THEN 
		IF quailstatus(xx) = 1 THEN LET collum3data$(xx) = "Unknown"
		IF quailstatus(xx) = 2 THEN LET collum3data$(xx) = "Chick"
		IF quailstatus(xx) = 3 THEN LET collum3data$(xx) = "Active"
		IF quailstatus(xx) = 4 THEN LET collum3data$(xx) = "Retired"
		IF quailstatus(xx) = 5 THEN LET collum3data$(xx) = "Dead"
		IF quailstatus(xx) = 6 THEN LET collum3data$(xx) = "Sold"
	END IF
	IF collum3$ = "sex" THEN
		IF quailsex(xx) = 1 THEN LET collum3data$(xx) = "Unknown"
		IF quailsex(xx) = 2 THEN LET collum3data$(xx) = "Male"
		IF quailsex(xx) = 3 THEN LET collum3data$(xx) = "Female"
	END IF
	IF collum3$ = "dateofbirth" THEN LET collum3data$(xx) = quaildateofbirth$(xx)
	IF collum3$ = "dateofdeath" THEN LET collum3data$(xx) = quaildateofdeath$(xx)
	IF collum3$ = "colour" THEN
		IF quailcolour(xx) = 1 THEN LET collum3data$(xx) = "Unknown"
		IF quailcolour(xx) = 2 THEN LET collum3data$(xx) = "Silver"
		IF quailcolour(xx) = 3 THEN LET collum3data$(xx) = "Moonridge Blue"
		IF quailcolour(xx) = 4 THEN LET collum3data$(xx) = "Wild Type"
		IF quailcolour(xx) = 5 THEN LET collum3data$(xx) = "Pharaoh"
		IF quailcolour(xx) = 6 THEN LET collum3data$(xx) = "Fawn"
		IF quailcolour(xx) = 7 THEN LET collum3data$(xx) = "Snowflake"
		IF quailcolour(xx) = 8 THEN LET collum3data$(xx) = "Chocolate"
		IF quailcolour(xx) = 9 THEN LET collum3data$(xx) = "White"
		IF quailcolour(xx) = 10 THEN LET collum3data$(xx) = "Broken White"
		IF quailcolour(xx) = 11 THEN LET collum3data$(xx) = "Mixed"
	END IF
	IF collum3$ = "hoopid" THEN LET collum3data$(xx) = LTRIM$(STR$(quailhoopid(xx)))
	IF collum3$ = "weight" THEN LET collum3data$(xx) = LTRIM$(STR$(quailweight(xx))) + "G"
NEXT xx
REM sort list
DO
	LET sorting = 0
	FOR sort1 = 1 TO fullid - 1
		IF listorder$ = "ascending" THEN 
			IF UCASE$(listkeydata$(sort1)) > UCASE$(listkeydata$(sort1 + 1)) THEN 
				SWAP listkeydata$(sort1), listkeydata$(sort1 + 1)
				SWAP collum1data$(sort1), collum1data$(sort1 + 1)
				SWAP collum2data$(sort1), collum2data$(sort1 + 1)
				SWAP collum3data$(sort1), collum3data$(sort1 + 1)
				SWAP listiddata(sort1), listiddata(sort1 + 1)
				LET sorting = 1
			END IF
		END IF
		IF listorder$ = "descending" THEN 
			IF UCASE$(listkeydata$(sort1)) < UCASE$(listkeydata$(sort1 + 1)) THEN 
				SWAP listkeydata$(sort1 + 1), listkeydata$(sort1)
				SWAP collum1data$(sort1 + 1), collum1data$(sort1)
				SWAP collum2data$(sort1 + 1), collum2data$(sort1)
				SWAP collum3data$(sort1 + 1), collum3data$(sort1)
				SWAP listiddata(sort1 + 1), listiddata(sort1)
				LET sorting = 1
			END IF
		END IF
	NEXT sort1
LOOP UNTIL sorting = 0
RETURN

listentries:
REM list mode
GOSUB editlist
IF cancellist = 1 THEN RETURN
LET listentry = 1
LET idcounter = 0
CLS
PRINT "Loading list..."
GOSUB calculateindex
IF fullid = 0 THEN PRINT "...Your database is empty!": _DELAY 1: RETURN
GOSUB loadandsortlist
_KEYCLEAR
REM list time!
listloop:
CLS
PRINT "QUAIL LIST MODE!"
PRINT "Sorted by " + listkey$ + " in " + listorder$ + " order"
PRINT "Currently showing " + collum1$ + " | " + collum2$ + " | " + collum3$
PRINT "Use arrow keys + enter. E = Edit List."
PRINT
REM displays list
FOR list1 = listentry TO listentry + 12
	IF list1 = listentry THEN 
		COLOR &HFF54FC54
	ELSE
		COLOR &HFFFCFCFC
	END IF
	IF listiddata(list1) > 0 THEN PRINT collum1data$(list1), " | ", collum2data$(list1), " | ", collum3data$(list1)
NEXT list1
REM list controls
DO
	LET keys = _KEYHIT
	IF keys = 18432 THEN
		REM up
		LET listentry = listentry - 1
		IF listentry =< 0 THEN LET listentry = 1
		GOTO listloop
	END IF
	IF keys = 20480 THEN
		REM down
		LET listentry = listentry + 1
		IF listentry > fullid THEN LET listentry = fullid
		GOTO listloop
	END IF
	IF keys = 69 OR keys = 101 THEN
		REM edit list
		LET listentry = 1
		GOSUB editlist
		GOSUB loadandsortlist
		_KEYCLEAR
		GOTO listloop
	END IF
	IF keys = 13 THEN
		REM view entry in catalog view
		LET idcounter = listiddata(listentry)
		_KEYCLEAR
		GOSUB listcatalogviewer
		GOTO listloop
	END IF
	IF keys = 27 THEN RETURN
LOOP

listcatalogviewer:
REM catalog viewer for the list mode
CLS
DO
    _LIMIT looplimit
    LET keys = _KEYHIT
    LOCATE 1, 1: PRINT "QUAIL LIST CATALOG VIEWER!"
    LOCATE 2, 1: PRINT "ESC = end. P = Photo. E = Edit."
    GOSUB displaysearch
    IF keys = 69 OR keys = 101 THEN GOSUB editquailentry: _KEYCLEAR
    IF keys = 80 OR keys = 112 THEN GOSUB viewphotosetup: _KEYCLEAR
LOOP UNTIL keys = 27
RETURN

editlist:
REM edits entries and order in list view
LET question = 1
LET cancellist = 0
LET collum1$ = ""
LET collum2$ = ""
LET collum3$ = ""
LET listorder$ = ""
LET listkey$ = ""
DO
	CLS
	PRINT "EDIT LIST!" 
	IF collum1$ <> "" THEN PRINT "COLLUM 1: " + collum1$
	IF collum2$ <> "" THEN PRINT "COLLUM 2: " + collum2$
	IF collum3$ <> "" THEN PRINT "COLLUM 3: " + collum3$
	IF listkey$ <> "" THEN PRINT "LIST KEY: " + listkey$
	IF listorder$ <> "" THEN PRINT "LIST ORDER: " + listorder$
	PRINT
	LET nextquestion = 0
	IF question = 1 THEN 
		REM collum 1
		PRINT "What would you like to be in collum 1?"
		PRINT "1 - Hoop ID"
		PRINT "2 - Name"
		PRINT "3 - Status"
		PRINT "4 - Sex"
		PRINT "5 - Date of Birth"
		PRINT "6 - Date of Death"
		PRINT "7 - Weight"
		PRINT "8 - Internal ID"
		PRINT "999 - Cancel"
		INPUT a
		IF a = 1 THEN LET collum1$ = "hoopid": LET nextquestion = 1
		IF a = 2 THEN LET collum1$ = "name": LET nextquestion = 1
		IF a = 3 THEN LET collum1$ = "status": LET nextquestion = 1
		IF a = 4 THEN LET collum1$ = "sex": LET nextquestion = 1
		IF a = 5 THEN LET collum1$ = "dateofbirth": LET nextquestion = 1
		IF a = 6 THEN LET collum1$ = "dateofdeath": LET nextquestion = 1
		IF a = 7 THEN LET collum1$ = "weight": LET nextquestion = 1
		IF a = 8 THEN LET collum1$ = "internalid": LET nextquestion = 1
		IF a = 999 THEN LET cancellist = 1
	END IF
	IF question = 2 THEN 
		REM collum 2
		PRINT "What would you like to be in collum 2?"
		PRINT "1 - Hoop ID"
		PRINT "2 - Name"
		PRINT "3 - Status"
		PRINT "4 - Sex"
		PRINT "5 - Date of Birth"
		PRINT "6 - Date of Death"
		PRINT "7 - Weight"
		PRINT "8 - Internal ID"
		PRINT "999 - Cancel"
		INPUT a
		IF a = 1 THEN LET collum2$ = "hoopid": LET nextquestion = 1
		IF a = 2 THEN LET collum2$ = "name": LET nextquestion = 1
		IF a = 3 THEN LET collum2$ = "status": LET nextquestion = 1
		IF a = 4 THEN LET collum2$ = "sex": LET nextquestion = 1
		IF a = 5 THEN LET collum2$ = "dateofbirth": LET nextquestion = 1
		IF a = 6 THEN LET collum2$ = "dateofdeath": LET nextquestion = 1
		IF a = 7 THEN LET collum2$ = "weight": LET nextquestion = 1
		IF a = 8 THEN LET collum2$ = "internalid": LET nextquestion = 1
		IF a = 999 THEN LET cancellist = 1
	END IF
	IF question = 3 THEN 
		REM collum 3
		PRINT "What would you like to be in collum 3?"
		PRINT "1 - Hoop ID"
		PRINT "2 - Name"
		PRINT "3 - Status"
		PRINT "4 - Sex"
		PRINT "5 - Date of Birth"
		PRINT "6 - Date of Death"
		PRINT "7 - Weight"
		PRINT "8 - Internal ID"
		PRINT "999 - Cancel"
		INPUT a
		IF a = 1 THEN LET collum3$ = "hoopid": LET nextquestion = 1
		IF a = 2 THEN LET collum3$ = "name": LET nextquestion = 1
		IF a = 3 THEN LET collum3$ = "status": LET nextquestion = 1
		IF a = 4 THEN LET collum3$ = "sex": LET nextquestion = 1
		IF a = 5 THEN LET collum3$ = "dateofbirth": LET nextquestion = 1
		IF a = 6 THEN LET collum3$ = "dateofdeath": LET nextquestion = 1
		IF a = 7 THEN LET collum3$ = "weight": LET nextquestion = 1
		IF a = 8 THEN LET collum3$ = "internalid": LET nextquestion = 1
		IF a = 999 THEN LET cancellist = 0
	END IF
	IF question = 4 THEN
		REM key list 
		PRINT "What should the list key on?"
		IF collum1$ = "internalid" THEN PRINT "1 - Internal ID"
		IF collum1$ = "name" THEN PRINT "1 - Name"
		IF collum1$ = "status" THEN PRINT "1 - Status"
		IF collum1$ = "sex" THEN PRINT "1 - Sex"
		IF collum1$ = "dateofbirth" THEN PRINT "1 - Date of Birth"
		IF collum1$ = "dateofdeath" THEN PRINT "1 - Date of Death"
		IF collum1$ = "weight" THEN PRINT "1 - Weight"
		IF collum1$ = "hoopid" THEN PRINT "1 - Hoop ID"
		IF collum2$ = "internalid" THEN PRINT "2 - Internal ID"
		IF collum2$ = "name" THEN PRINT "2 - Name"
		IF collum2$ = "status" THEN PRINT "2 - Status"
		IF collum2$ = "sex" THEN PRINT "2 - Sex"
		IF collum2$ = "dateofbirth" THEN PRINT "2 - Date of Birth"
		IF collum2$ = "dateofdeath" THEN PRINT "2 - Date of Death"
		IF collum2$ = "weight" THEN PRINT "2 - Weight"
		IF collum2$ = "hoopid" THEN PRINT "2 - Hoop ID"	
		IF collum3$ = "internalid" THEN PRINT "3 - Internal ID"
		IF collum3$ = "name" THEN PRINT "3 - Name"
		IF collum3$ = "status" THEN PRINT "3 - Status"
		IF collum3$ = "sex" THEN PRINT "3 - Sex"
		IF collum3$ = "dateofbirth" THEN PRINT "3 - Date of Birth"
		IF collum3$ = "dateofdeath" THEN PRINT "3 - Date of Death"
		IF collum3$ = "weight" THEN PRINT "3 - Weight"
		IF collum3$ = "hoopid" THEN PRINT "3 - Hoop ID"
		PRINT "999 - Cancel"
		INPUT a
		IF a = 1 THEN LET listkey$ = collum1$: LET nextquestion = 1
		IF a = 2 THEN LET listkey$ = collum2$: LET nextquestion = 1
		IF a = 3 THEN LET listkey$ = collum3$: LET nextquestion = 1
		IF a = 999 THEN LET cancellist = 1
	END IF
	IF question = 5 THEN
		REM list order
		PRINT "What order?"
		PRINT "1 - Ascending"
		PRINT "2 - Descending"
		PRINT "999 - Cancel"
		INPUT a
		IF a = 1 THEN LET listorder$ = "ascending": LET nextquestion = 1
		IF a = 2 THEN LET listorder$ = "descending": LET nextquestion = 1
		IF a = 999 THEN LET cancellist = 1
	END IF
	IF nextquestion = 1 THEN LET question = question + 1
LOOP UNTIL question = 6 OR cancellist = 1
RETURN

calculateindex:
REM caulculates number of entries in database
REM calculate full index
LET fullid = 0
DO
    LET fullid = fullid + 1
LOOP UNTIL fullid <> quailid(fullid) AND quailid(fullid) = 0
LET fullid = fullid - 1
RETURN

changename:
REM changes quail name
PRINT "What is the Name?"
IF newentry = 0 THEN PRINT "Current value: " + quailname$(idcounter)
PRINT
INPUT quailname$(idcounter)
LET nextquestion = 1
RETURN

changestatus:
REM changes quail status
PRINT "What is the quail status?"
IF newentry = 0 THEN 
	IF quailstatus(idcounter) = 1 THEN PRINT "Current value: Unknown"
	IF quailstatus(idcounter) = 2 THEN PRINT "Current value: Chick"
	IF quailstatus(idcounter) = 3 THEN PRINT "Current value: Active"
	IF quailstatus(idcounter) = 4 THEN PRINT "Current value: Retired"
	IF quailstatus(idcounter) = 5 THEN PRINT "Current value: Dead"
	IF quailstatus(idcounter) = 6 THEN PRINT "Current value: Sold"
END IF
PRINT
PRINT "1 - Unknown"
PRINT "2 - Chick"
PRINT "3 - Active"
PRINT "4 - Retired"
PRINT "5 - Dead"
PRINT "6 - Sold"
INPUT quailstatus(idcounter)
IF newentry = 1 THEN IF quailstatus(idcounter) = 999 OR quailstatus(idcounter) = 911 THEN RETURN
IF quailstatus(idcounter) > 0 AND quailstatus(idcounter) < 7 THEN LET nextquestion = 1
RETURN

changedateofbirth:
REM changes quail date of birth
PRINT "What is the date of birth? (DD/MM/YYYY)"
IF newentry = 0 THEN PRINT "Current value: " + quaildateofbirth$(idcounter)
PRINT
INPUT quaildateofbirth$(idcounter)
IF newentry = 1 THEN IF quaildateofbirth$(idcounter) = "/Q" OR quaildateofbirth$(idcounter) = "/B" THEN RETURN
IF quaildateofbirth$(idcounter) = "" THEN
    REM Quail requires date of birth
    PRINT "Quail requires a valid date of birth!"
    _DELAY 1
ELSE
    LET birthday = VAL(LEFT$(quaildateofbirth$(idcounter), 2))
    LET birthmonth = VAL(MID$(quaildateofbirth$(idcounter), 4, 2))
    LET birthyear = VAL(RIGHT$(quaildateofbirth$(idcounter), 4))
    LET datecheck = 0
    IF birthday > 0 AND birthday < 32 THEN LET datecheck = datecheck + 1
    IF birthmonth > 0 AND birthmonth < 13 THEN LET datecheck = datecheck + 1
    IF birthyear > 1000 THEN LET datecheck = datecheck + 1
    IF datecheck = 3 THEN
        LET nextquestion = 1
    ELSE
        PRINT "Quail requires a valid date of birth!"
        _DELAY 1
    END IF
END IF
RETURN

changedateofdeath:
REM changes quail date of death
PRINT "What is the date of death? (DD/MM/YYYY)"
IF newentry = 0 THEN PRINT "Current value: " + quaildateofdeath$(idcounter)
PRINT
IF quailstatus(idcounter) = 5 THEN
    INPUT quaildateofdeath$(idcounter)
    IF newentry = 1 THEN IF quaildateofdeath$(idcounter) = "/B" OR quaildateofdeath$(idcounter) = "/Q" THEN RETURN
    IF quaildateofdeath$(idcounter) = "" THEN
        REM invalid value
        PRINT "Quail is dead! Date required!"
        _DELAY 1
        GOTO changedateofdeath
    ELSE
        REM checks date
        LET deathday = VAL(LEFT$(quaildateofdeath$(idcounter), 2))
        LET deathmonth = VAL(MID$(quaildateofdeath$(idcounter), 4, 2))
        LET deathyear = VAL(RIGHT$(quaildateofdeath$(idcounter), 4))
        REM checks if date is valid
        LET datecheck = 0
        IF deathday > 0 AND deathday < 32 THEN LET datecheck = datecheck + 1
        IF deathmonth > 0 AND deathmonth < 13 THEN LET datecheck = datecheck + 1
        IF deathyear > 1000 THEN LET datecheck = datecheck + 1
        IF datecheck = 3 THEN
            REM nothing
        ELSE
            PRINT "Quail requires a valid date of death!"
            _DELAY 1
            GOTO changedateofdeath
        END IF
        REM checks death year is after birth year
        IF deathyear < birthyear THEN
            REM invalid date! early year!
            PRINT "Quail must die after birth!"
            _DELAY 1
            GOTO changedateofdeath
        ELSE
            IF deathyear = birthyear THEN
                IF deathmonth < birthmonth THEN
                    REM invalid date! early month!
                    PRINT "Quail must die after birth!"
                    _DELAY 1
                    GOTO changedateofdeath
                ELSE
                    IF deathmonth = birthmonth THEN
                        IF deathday < birthday THEN
                            REM invalid date! early day!
                            PRINT "Quail must die after birth!"
                            _DELAY 1
                            GOTO changedateofdeath
                        ELSE
                            REM valid date
                            LET nextquestion = 1
                        END IF
                    ELSE
                        REM valid date
                        LET nextquestion = 1
                    END IF
                    REM valid date
                    LET nextquestion = 1
                END IF
            ELSE
                REM valid date!
                LET nextquestion = 1
            END IF
        END IF
    END IF
ELSE
    REM no date needed!
    LET nextquestion = 1
END IF
RETURN

changeweight:
REM changes quail weight
PRINT "What is the weight of the quail in grams?"
IF newentry = 0 THEN PRINT "Current value:" + STR$(quailweight(idcounter))
INPUT quailweight(idcounter)
PRINT
LET nextquestion = 1
RETURN

changesex:
REM changes sex of quail
PRINT "What is the quails sex?"
IF newentry = 0 THEN
	IF quailsex(idcounter) = 1 THEN PRINT "Current value: Unknown"
	IF quailsex(idcounter) = 2 THEN PRINT "Current value: Male"
	IF quailsex(idcounter) = 3 THEN PRINT "Current value: Female"
END IF
PRINT
PRINT "1 - Unknown"
PRINT "2 - Male"
PRINT "3 - Female"
INPUT quailsex(idcounter)
IF newentry = 1 THEN IF quailsex(idcounter) = 999 OR quailsex(idcounter) = 911 THEN RETURN
IF quailsex(idcounter) > 0 AND quailsex(idcounter) < 4 THEN LET nextquestion = 1
RETURN

changecolour:
REM changes colour of quail
PRINT "What is the colour of the quail?"
IF newentry = 0 THEN 
	IF quailcolour(idcounter) = 1 THEN PRINT "Current value: Unknown"
	IF quailcolour(idcounter) = 2 THEN PRINT "Current value: Silver"
	IF quailcolour(idcounter) = 3 THEN PRINT "Current value: Moonridge Blue"
	IF quailcolour(idcounter) = 4 THEN PRINT "Current value: Wild Type"
	IF quailcolour(idcounter) = 5 THEN PRINT "Current value: Pharaoh"
	IF quailcolour(idcounter) = 6 THEN PRINT "Current value: Fawn"
	IF quailcolour(idcounter) = 7 THEN PRINT "Current value: Snowflake"
	IF quailcolour(idcounter) = 8 THEN PRINT "Current value: Chocolate"
	IF quailcolour(idcounter) = 9 THEN PRINT "Current value: White"
	IF quailcolour(idcounter) = 10 THEN PRINT "Current value: Broken White"
	IF quailcolour(idcounter) = 11 THEN PRINT "Current value: Mixed"
END IF
PRINT
PRINT "1 - Unknown"
PRINT "2 - Silver"
PRINT "3 - Moonridge Blue"
PRINT "4 - Wild Type"
PRINT "5 - Pharaoh"
PRINT "6 - Fawn"
PRINT "7 - Snowflake"
PRINT "8 - Chocolate"
PRINT "9 - White"
PRINT "10 - Broken White"
PRINT "11 - Mixed"
INPUT quailcolour(idcounter)
IF newentry = 1 THEN IF quailcolour(idcounter) = 999 OR quailcolour(idcounter) = 911 THEN RETURN
IF quailcolour(idcounter) > 0 AND quailcolour(idcounter) < 12 THEN LET nextquestion = 1
RETURN

changehoopid:
REM changes a quails hoop id
PRINT "What is the Hoop ID?"
IF newentry = 0 THEN PRINT "Current value:" + STR$(quailhoopid(idcounter))
PRINT
INPUT quailhoopid(idcounter)
LET nextquestion = 1
RETURN

changenotes:
REM changes any quail notes
PRINT "Any notes?"
IF newentry = 0 THEN PRINT "Current value: " + quailnotes$(idcounter)
PRINT
INPUT quailnotes$(idcounter)
LET nextquestion = 1
RETURN

newquailentry:
LET idcounter = 0
LET newentry = 1
DO
    LET idcounter = idcounter + 1
LOOP UNTIL idcounter <> quailid(idcounter) AND quailid(idcounter) = 0
LET question = 1
DO
    LET nextquestion = 0
    CLS
    PRINT "NEW QUAIL DATA ENTRY!"
    PRINT
    IF question = 1 THEN 
		GOSUB changename
		IF quailname$(idcounter) = "/Q" THEN GOSUB wipecurrententry: RETURN
		IF quailname$(idcounter) = "/B" THEN LET nextquestion = 0: LET question = 1
	END IF
    IF question = 2 THEN 
		GOSUB changestatus
		IF quailstatus(idcounter) = 999 THEN GOSUB wipecurrententry: RETURN
		IF quailstatus(idcounter) = 911 THEN LET nextquestion = 0: LET question = 1 
	END IF
    IF question = 3 THEN 
		GOSUB changedateofbirth
		IF quaildateofbirth$(idcounter) = "/Q" THEN GOSUB wipecurrententry: RETURN
		IF quaildateofbirth$(idcounter) = "/B" THEN LET nextquestion = 0: LET question = 2
	END IF
    IF question = 4 THEN 
		GOSUB changedateofdeath
		IF quaildateofdeath$(idcounter) = "/Q" THEN GOSUB wipecurrententry: RETURN
		IF quaildateofdeath$(idcounter) = "/B" THEN LET nextquestion = 0: LET question = 3
	END IF
    IF question = 5 THEN 
		GOSUB changeweight
		IF quailweight(idcounter) = 999 THEN GOSUB wipecurrententry: RETURN
		IF quailweight(idcounter) = 911 THEN LET nextquestion = 0: LET question = 4
	END IF
    IF question = 6 THEN 
		GOSUB changesex
		IF quailsex(idcounter) = 999 THEN GOSUB wipecurrententry: RETURN
		IF quailsex(idcounter) = 911 THEN LET nextquestion = 0: LET question = 5
	END IF
    IF question = 7 THEN 
		GOSUB changecolour
		IF quailcolour(idcounter) = 999 THEN GOSUB wipecurrententry: RETURN
		IF quailcolour(idcounter) = 911 THEN LET nextquestion = 0: LET question = 6
	END IF
    IF question = 8 THEN 
		GOSUB changehoopid
		IF quailhoopid(idcounter) = 999 THEN GOSUB wipecurrententry: RETURN
		IF quailhoopid(idcounter) = 911 THEN LET nextquestion = 0: LET question = 7
	END IF
    IF question = 9 THEN 
		GOSUB changenotes
		IF quailnotes$(idcounter) = "/Q" THEN GOSUB wipecurrententry: RETURN
		IF quailnotes$(idcounter) = "/B" THEN LET nextquestion = 0: LET question = 8
	END IF
    IF nextquestion = 1 THEN LET question = question + 1
LOOP UNTIL question = 10
newreviewloop:
CLS
PRINT "PLEASE REVIEW THE NEW QUAIL!"
PRINT
PRINT "Name: " + quailname$(idcounter)
IF quailstatus(idcounter) = 1 THEN PRINT "Status: Unknown"
IF quailstatus(idcounter) = 2 THEN PRINT "Status: Chick"
IF quailstatus(idcounter) = 3 THEN PRINT "Status: Active"
IF quailstatus(idcounter) = 4 THEN PRINT "Status: Retired"
IF quailstatus(idcounter) = 5 THEN PRINT "Status: Dead"
IF quailstatus(idcounter) = 6 THEN PRINT "Status: Sold"
PRINT "Date of Birth: " + quaildateofbirth$(idcounter)
IF quaildateofdeath$(idcounter) = "" THEN
    PRINT "Date of Death: N/A"
ELSE
    PRINT "Date of Death: " + quaildateofdeath$(idcounter)
END IF
PRINT "Weight: " + LTRIM$(STR$(quailweight(idcounter))) + "g"
IF quailsex(idcounter) = 1 THEN PRINT "Sex: Unknown"
IF quailsex(idcounter) = 2 THEN PRINT "Sex: Male"
IF quailsex(idcounter) = 3 THEN PRINT "Sex: Female"
IF quailcolour(idcounter) = 1 THEN PRINT "Colour: Unknown"
IF quailcolour(idcounter) = 2 THEN PRINT "Colour: Silver"
IF quailcolour(idcounter) = 3 THEN PRINT "Colour: Moonridge Blue"
IF quailcolour(idcounter) = 4 THEN PRINT "Colour: Wild Type"
IF quailcolour(idcounter) = 5 THEN PRINT "Colour: Pharaoh"
IF quailcolour(idcounter) = 6 THEN PRINT "Colour: Fawn"
IF quailcolour(idcounter) = 7 THEN PRINT "Colour: Snowflake"
IF quailcolour(idcounter) = 8 THEN PRINT "Colour: Chocolate"
IF quailcolour(idcounter) = 9 THEN PRINT "Colour: White"
IF quailcolour(idcounter) = 10 THEN PRINT "Colour: Broken White"
IF quailcolour(idcounter) = 11 THEN PRINT "Colour: Mixed"
PRINT "Hoop ID:" + LTRIM$(STR$(quailhoopid(idcounter)))
PRINT "Notes: " + quailnotes$(idcounter)
PRINT
PRINT "Does this look correct? 1 = Yes. 2 = No."
INPUT a
IF a = 2 THEN
    REM wipe values, return to main menu
    GOSUB wipecurrententry
    GOTO mainmenu
END IF
IF a <> 1 THEN GOTO newreviewloop
LET quailid(idcounter) = idcounter
GOSUB savequailentry
LET newentry = 0
RETURN

wipecurrententry:
REM wipes out current entry values
LET quailname$(idcounter) = ""
LET quailstatus(idcounter) = 0
LET quaildateofbirth$(idcounter) = ""
LET quaildateofdeath$(idcounter) = ""
LET quailsex(idcounter) = 0
LET quailcolour(idcounter) = 0
LET quailhoopid(idcounter) = 0
LET quailnotes$(idcounter) = ""
RETURN

savequailentry:
REM saves database
PRINT
PRINT "SAVING ENTRY..."
GOSUB calculateindex
OPEN quaildb$ FOR OUTPUT AS #1
LET x = 0
DO
	LET x = x + 1
	WRITE #1, quailid(x), quailname$(x), quailstatus(x), quaildateofbirth$(x), quaildateofdeath$(x), quailweight(x), quailsex(x), quailcolour(x), quailhoopid(x), quailnotes$(x)
LOOP UNTIL x = fullid
_DELAY 0.5
CLOSE #1
PRINT "...SAVED!"
PRINT
PRINT "PRESS ENTER TO RETURN"
INPUT a
RETURN

editquailentry:
REM edits a quail entry in the database
CLS
PRINT "QUAIL DATA EDITOR!"
PRINT
PRINT "Select the data you would like to edit!"
PRINT "1 - Name"
PRINT "2 - Status"
PRINT "3 - Date of Birth"
PRINT "4 - Date of Death"
PRINT "5 - Weight"
PRINT "6 - Sex"
PRINT "7 - Colour"
PRINT "8 - Hoop ID"
PRINT "9 - Notes"
PRINT "10 - Photo"
PRINT "11 - Done! Save changes!"
PRINT
IF editloop = 0 THEN INPUT z
IF z > 0 AND z < 10 THEN
    CLS
    PRINT "QUAIL DATA EDITOR!"
    PRINT
    LET editrequested = 1
END IF
IF z = 1 THEN GOSUB changename
IF z = 2 THEN GOSUB changestatus
IF z = 3 THEN GOSUB changedateofbirth
IF z = 4 THEN GOSUB changedateofdeath
IF z = 5 THEN GOSUB changeweight
IF z = 6 THEN GOSUB changesex
IF z = 7 THEN GOSUB changecolour
IF z = 8 THEN GOSUB changehoopid
IF z = 9 THEN GOSUB changenotes
IF editrequested = 1 THEN
	IF nextquestion = 0 THEN LET editloop = 1
	IF nextquestion = 1 THEN LET editloop = 0: LET editrequested = 0
END IF
IF z = 10 THEN GOSUB quailphotoimport
IF z = 11 THEN GOSUB savequailentry: LET editloop = 0: LET nextquestion = 0: LET editrequested = 0: RETURN
GOTO editquailentry

quailphotoimport:
REM imports a photo of a quail for the database
CLS
REM removes import folder list if it already exists
IF _FILEEXISTS("photolist1.tmp") THEN
	IF ros$ = "lnx" THEN SHELL _HIDE "rm *.tmp"
	IF ros$ = "win" THEN SHELL _HIDE "del *.tmp"
END IF
REM checks import folder exists
IF _DIREXISTS(importphotosloc$) THEN
	REM nothing
ELSE
	REM import folder does not exist!
	PRINT "PHOTO IMPORT FOLDER DOES NOT EXIST!"
	PRINT
	PRINT "Go to settings to set a valid folder!"
	PRINT "Press enter to return!"
	INPUT a
	RETURN
END IF
REM folder exists! loads folder contents into memory!
REM writes folder contents to file!
IF ros$ = "lnx" THEN 
	SHELL _HIDE "ls " + importphotosloc$ + "*.png > photolist1.tmp"
	SHELL _HIDE "ls " + importphotosloc$ + "*.jpg > photolist2.tmp"
	SHELL _HIDE "ls " + importphotosloc$ + "*.jpeg > photolist3.tmp"
	SHELL _HIDE "ls " + importphotosloc$ + "*.PNG > photolist4.tmp"
	SHELL _HIDE "ls " + importphotosloc$ + "*.JPG > photolist5.tmp"
	SHELL _HIDE "ls " + importphotosloc$ + "*.JPEG > photolist6.tmp"
END IF
IF ros$ = "win" THEN
	SHELL _HIDE "dir /b " + importphotosloc$ + "*.png > photolist1.tmp"
	SHELL _HIDE "dir /b " + importphotosloc$ + "*.jpg > photolist2.tmp"
	SHELL _HIDE "dir /b " + importphotosloc$ + "*.jpeg > photolist3.tmp"
END IF
REM loads file into memory!
IF ros$ = "lnx" THEN LET filenumbertotal = 6
IF ros$ = "win" THEN LET filenumbertotal = 3
LET totalfiles = 1
DO
	LET filenumber = filenumber + 1
	OPEN "photolist" + LTRIM$(STR$(filenumber)) + ".tmp" FOR INPUT AS #2
	DO
		INPUT #2, importphoto$(totalfiles)
		LET photoext$(totalfiles) = RIGHT$(importphoto$(totalfiles), 3)
		IF ros$ = "lnx" THEN
			IF photoext$(totalfiles) = "peg" THEN LET photoext$(totalfiles) = "jpeg"
			IF photoext$(totalfiles) = "PEG" THEN LET photoext$(totalfiles) = "JPEG"
		END IF
		IF ros$ = "win" THEN IF photoext$(totalfiles) = "peg" THEN LET photoext$(totalfiles) = "jpeg"
		IF importphoto$(totalfiles) <> "" THEN LET totalfiles = totalfiles + 1
	LOOP UNTIL EOF(2)
	CLOSE #2
LOOP UNTIL filenumber >= filenumbertotal
REM return for if the folder is empty
IF importphoto$(1) = "" AND totalfiles = 1 THEN
	PRINT "PHOTO IMPORT FOLDER IS EMPTY!"
	PRINT "Add some photos and try again!"
	PRINT "png, jpg and jpeg files supported!"
	PRINT
	PRINT "Press enter to return!"
	INPUT a
	RETURN
END IF
REM list time!
LET listentry2 = 1
_KEYCLEAR
listloop2:
CLS
PRINT "SELECT A PHOTO FOR " + quailname$(idcounter)
PRINT "Use arrow keys + enter. ESC = Cancel."
PRINT
REM displays list
FOR list2 = listentry2 TO listentry2 + 12
	IF list2 = listentry2 THEN 
		COLOR &HFF54FC54
	ELSE
		COLOR &HFFFCFCFC
	END IF
	PRINT importphoto$(list2)
NEXT list2
REM list controls
DO
	LET keys = _KEYHIT
	IF keys = 18432 THEN
		REM up
		LET listentry2 = listentry2 - 1
		IF listentry2 =< 0 THEN LET listentry2 = 1
		GOTO listloop2
	END IF
	IF keys = 20480 THEN
		REM down
		LET listentry2 = listentry2 + 1
		IF listentry2 > totalfiles THEN LET listentry2 = totalfiles
		GOTO listloop2
	END IF
	IF keys = 13 THEN
		REM view entry in catalog view
		IF ros$ = "lnx" THEN LET viewphoto$ = importphoto$(listentry2)
		IF ros$ = "win" THEN LET viewphoto$ = importphotosloc$ + importphoto$(listentry2)
		_KEYCLEAR
		GOSUB viewquailphoto
		_KEYCLEAR
		photoloop:
		PRINT "WAS THAT A PHOTO OF " + quailname(idcounter) + "?"
		PRINT "1 - Yes"
		PRINT "2 - No"
		INPUT u
		IF u <> 1 AND u <> 2 THEN GOTO photoloop
		PRINT: PRINT "IMPORTING PHOTO..."
		_KEYCLEAR
		IF u = 1 THEN
			REM update photo!
			IF ros$ = "lnx" THEN
				SHELL _HIDE "rm " + photofolder$ + LTRIM$(STR$(idcounter)) + ".jpg"
				SHELL _HIDE "rm " + photofolder$ + LTRIM$(STR$(idcounter)) + ".png"
				SHELL _HIDE "rm " + photofolder$ + LTRIM$(STR$(idcounter)) + ".jpeg"
				SHELL _HIDE "rm " + photofolder$ + LTRIM$(STR$(idcounter)) + ".JPG"
				SHELL _HIDE "rm " + photofolder$ + LTRIM$(STR$(idcounter)) + ".PNG"
				SHELL _HIDE "rm " + photofolder$ + LTRIM$(STR$(idcounter)) + ".JPEG"
				SHELL _HIDE "cp " + importphoto$(listentry2) + " " + photofolder$ + LTRIM$(STR$(idcounter)) + "." + photoext$(listentry2)
			END IF
			IF ros$ = "win" THEN
				SHELL _HIDE "del " + photofolder$ + LTRIM$(STR$(idcounter)) + ".jpg"
				SHELL _HIDE "del " + photofolder$ + LTRIM$(STR$(idcounter)) + ".png"
				SHELL _HIDE "del " + photofolder$ + LTRIM$(STR$(idcounter)) + ".jpeg"
				SHELL _HIDE "copy " + importphotosloc$ + importphoto(listentry2) + " " + photofolder$ + LTRIM$(STR$(idcounter)) + "." + photoext$(listentry2)
			END IF 
		END IF
		IF _FILEEXISTS(photofolder$ + LTRIM$(STR$(idcounter)) + "." + photoext$(idcounter)) THEN
			PRINT "...IMPORT COMPLETE!"
		ELSE
			PRINT "...IMPORT FAILED! :("
		END IF
		PRINT
		PRINT "Press enter to return!"
		INPUT u
		IF ros$ = "lnx" THEN SHELL _HIDE "rm *.tmp"
		IF ros$ = "win" THEN SHELL _HIDE "del *.tmp"
		REM clears file array
		FOR byefiles = 1 TO totalfiles
			LET importphoto$(byefiles) = ""
			LET photoext$(byefiles) = ""
		NEXT byefiles
		LET filenumber = 0
		RETURN
	END IF
	IF keys = 27 THEN 
		REM leave photo menu
		REM deletes files
		IF ros$ = "lnx" THEN SHELL _HIDE "rm *.tmp"
		IF ros$ = "win" THEN SHELL _HIDE "del *.tmp"
		REM clears file array
		FOR byefiles = 1 TO totalfiles
			LET importphoto$(byefiles) = ""
			LET photoext$(byefiles) = ""
		NEXT byefiles
		LET filenumber = 0
		RETURN
	END IF
LOOP
RETURN

viewquailphoto:
REM views a quail photo
LET nophoto = 0
IF _FILEEXISTS(viewphoto$) THEN
	REM nothing
ELSE
	LET nophoto = 1
	RETURN
END IF
LET quailphoto = _LOADIMAGE(viewphoto$)
SCREEN quailphoto
_PUTIMAGE (1, 1), quailphoto
DO
LOOP WHILE INKEY$ = ""
SCREEN _NEWIMAGE(800, 600, 32)
_FONT dbfont&
CLS
RETURN

hoopidsearch:
REM searches database by quail hoop id
CLS
PRINT "QUAIL HOOP ID SEARCH!"
PRINT
PRINT "Type in the hoop id you would like to search:"
INPUT searchterm
LET searchterm$ = LTRIM$(STR$(searchterm))
PRINT
PRINT "Searching..."
GOSUB calculateindex
IF fullid = 0 THEN PRINT "...Your database is empty!": _DELAY 1: RETURN
LET idcounter = 0
LET resultcounter = 0
DO
    _LIMIT looplimit
    LET idcounter = idcounter + 1
    LET findhoop% = INSTR(findhoop% + 1, LTRIM$(STR$(quailhoopid(idcounter))), searchterm$)
    IF findhoop% THEN
        REM result found! display them!
        CLS
        LOCATE 1, 1: PRINT "SEARCH RESULTS!"
        GOSUB displaysearch
        PRINT
        PRINT "ENTER = continue. P = photo. E = edit."
        INPUT a$
        IF UCASE$(a$) = "E" THEN GOSUB editquailentry: GOTO resultloop
        IF UCASE$(a$) = "P" THEN GOSUB viewphotosetup: GOTO resultloop
        LET resultcounter = resultcounter + 1
        CLS
        PRINT "Searching..."
    END IF
LOOP UNTIL idcounter <> quailid(idcounter) AND quailid(idcounter) = 0
IF resultcounter = 0 THEN
    PRINT "...Search complete! No results found!"
ELSE
    IF resultcounter = 1 THEN
        PRINT "...Search complete! 1 result!"
    ELSE
        PRINT "...Search complete! " + LTRIM$(STR$(resultcounter)) + " results!"
    END IF
END IF
PRINT
PRINT "Press enter to return to mainmenu"
INPUT a
RETURN

namesearch:
REM searches database by quail name
CLS
PRINT "QUAIL NAME SEARCH!"
PRINT
PRINT "Type in the name you would like to search:"
INPUT searchterm$
PRINT
PRINT "Searching..."
GOSUB calculateindex
IF fullid = 0 THEN PRINT "...Your database is empty!": _DELAY 1: RETURN
LET idcounter = 0
LET resultcounter = 0
DO
    _LIMIT looplimit
    LET idcounter = idcounter + 1
    LET findname% = INSTR(findname% + 1, LCASE$(quailname$(idcounter)), LCASE$(searchterm$))
    IF findname% THEN
		resultloop:
        REM result found! display them!
        CLS
        LOCATE 1, 1: PRINT "SEARCH RESULTS!"
        GOSUB displaysearch
        PRINT
        PRINT "ENTER = continue. P = photo. E = edit."
        INPUT a$
        IF UCASE$(a$) = "E" THEN GOSUB editquailentry: GOTO resultloop
        IF UCASE$(a$) = "P" THEN GOSUB viewphotosetup: GOTO resultloop
        LET resultcounter = resultcounter + 1
        CLS
        PRINT "Searching..."
    END IF
LOOP UNTIL idcounter <> quailid(idcounter) AND quailid(idcounter) = 0
IF resultcounter = 0 THEN
    PRINT "...Search complete! No results found!"
ELSE
    IF resultcounter = 1 THEN
        PRINT "...Search complete! 1 result!"
    ELSE
        PRINT "...Search complete! " + LTRIM$(STR$(resultcounter)) + " results!"
    END IF
END IF
PRINT
PRINT "Press enter to return to mainmenu"
INPUT a
RETURN

calculatequailage:
REM calculate quail age
LET birthday = VAL(LEFT$(quaildateofbirth$(idcounter), 2))
LET birthmonth = VAL(MID$(quaildateofbirth$(idcounter), 4, 2))
LET birthyear = VAL(RIGHT$(quaildateofbirth$(idcounter), 4))
IF quaildateofdeath$(idcounter) <> "" THEN
    REM extract death day
    LET deathday = VAL(LEFT$(quaildateofdeath$(idcounter), 2))
    LET deathmonth = VAL(MID$(quaildateofdeath$(idcounter), 4, 2))
    LET deathyear = VAL(RIGHT$(quaildateofdeath$(idcounter), 4))
ELSE
    REM use current date
    LET deathmonth = VAL(LEFT$(DATE$, 2))
    LET deathday = VAL(MID$(DATE$, 4, 2))
    LET deathyear = VAL(RIGHT$(DATE$, 4))
END IF
REM calculates age in years months and days
LET ageyear = deathyear - birthyear
LET agemonth = deathmonth - birthmonth
LET ageday = deathday - birthday
REM handles invalid values
IF ageday < 0 THEN
    LET temp = ageday
    LET temp = ABS(temp)
    LET ageday = birthday + temp
    LET agemonth = agemonth - 1
    LET temp = 0
END IF
IF agemonth < 0 THEN
    LET temp = agemonth
    LET temp = ABS(temp)
    LET agemonth = birthmonth + temp
    LET ageyear = ageyear - 1
    LET temp = 0
END IF
RETURN

displaysearch:
GOSUB calculatequailage: REM works out quail age
REM calculate quail weight spec
IF quailweight(idcounter) < 225 THEN LET quailweightspec$ = "RUNT"
IF quailweight(idcounter) >= 225 THEN LET quailweightspec$ = "NORMAL"
IF quailweight(idcounter) > 300 THEN LET quailweightspec$ = "JUMBO"
IF quailweight(idcounter) > 350 THEN LET quailweightspec$ = "GIANT"
IF quailweight(idcounter) > 400 THEN LET quailweightspec$ = "COLLOSAL"
REM display results of search
COLOR &HFFFCFCFC
LOCATE 4, 1: PRINT "Internal ID: " + LTRIM$(STR$(quailid(idcounter))) + "/" + LTRIM$(STR$(fullid))
LOCATE 5, 1: PRINT "Name: " + quailname$(idcounter)
LOCATE 6, 1
IF quailstatus(idcounter) = 1 THEN COLOR &HFFA8A8A8: PRINT "Status: Unknown"
IF quailstatus(idcounter) = 2 THEN COLOR &HFFFCFC54: PRINT "Status: Chick"
IF quailstatus(idcounter) = 3 THEN COLOR &HFF54FC54: PRINT "Status: Active"
IF quailstatus(idcounter) = 4 THEN COLOR &HFFFC54FC: PRINT "Status: Retired"
IF quailstatus(idcounter) = 5 THEN COLOR &HFFFC5454: PRINT "Status: Dead"
IF quailstatus(idcounter) = 6 THEN COLOR &HFF545454: PRINT "Status: Sold"
COLOR &HFFFCFCFC
LOCATE 7, 1: PRINT "Age: " + LTRIM$(STR$(ageyear)) + " years " + LTRIM$(STR$(agemonth)) + " months and " + LTRIM$(STR$(ageday)) + " days"
LOCATE 8, 1: PRINT "Date of Birth: " + quaildateofbirth$(idcounter)
LOCATE 9, 1
IF quaildateofdeath$(idcounter) = "" THEN
    PRINT "Date of Death: N/A"
ELSE
    PRINT "Date of Death: " + quaildateofdeath$(idcounter)
END IF
LOCATE 10, 1: PRINT "Weight: " + LTRIM$(STR$(quailweight(idcounter))) + "g"
LOCATE 11, 1: PRINT "Weight Spec: " + quailweightspec$
LOCATE 12, 1
IF quailsex(idcounter) = 1 THEN COLOR &HFFA8A8A8: PRINT "Sex: Unknown"
IF quailsex(idcounter) = 2 THEN COLOR &HFF5454FC: PRINT "Sex: Male"
IF quailsex(idcounter) = 3 THEN COLOR &HFFFC54FC: PRINT "Sex: Female"
LOCATE 13, 1
IF quailcolour(idcounter) = 1 THEN COLOR &HFFFCFCFC: PRINT "Colour: Unknown"
IF quailcolour(idcounter) = 2 THEN COLOR &HFFA8A8A8: PRINT "Colour: Silver"
IF quailcolour(idcounter) = 3 THEN COLOR &HFF5454FC: PRINT "Colour: Moonridge Blue"
IF quailcolour(idcounter) = 4 THEN COLOR &HFFA80000: PRINT "Colour: Wild Type"
IF quailcolour(idcounter) = 5 THEN COLOR &HFFFCFC54: PRINT "Colour: Pharaoh"
IF quailcolour(idcounter) = 6 THEN COLOR &HFFA85400: PRINT "Colour: Fawn"
IF quailcolour(idcounter) = 7 THEN COLOR &HFFFCFCFC: PRINT "Colour: Snowflake"
IF quailcolour(idcounter) = 8 THEN COLOR &HFFA85400: PRINT "Colour: Chocolate"
IF quailcolour(idcounter) = 9 THEN COLOR &HFFFCFCFC: PRINT "Colour: White"
IF quailcolour(idcounter) = 10 THEN COLOR &HFFA8A8A8: PRINT "Colour: Broken White"
IF quailcolour(idcounter) = 11 THEN COLOR &HFFFCFCFC: PRINT "Colour: Mixed"
COLOR &HFFFCFCFC
LOCATE 14, 1: PRINT "Hoop ID:" + LTRIM$(STR$(quailhoopid(idcounter)))
LOCATE 15, 1: PRINT "Notes: " + quailnotes$(idcounter)
RETURN

catalogentries:
GOSUB calculateindex
IF fullid = 0 THEN PRINT "...Your database is empty!": _DELAY 1: RETURN
LET idcounter = 1
_KEYCLEAR
CLS
DO
    _LIMIT looplimit
    LET keys = _KEYHIT
    LOCATE 1, 1: PRINT "QUAIL CATALOG VIEWER!"
    LOCATE 2, 1: PRINT "ARROW KEYS = move. E = edit. P = photo. ESC = end."
    GOSUB displaysearch
    IF keys = 19712 THEN IF quailid(idcounter + 1) <> 0 THEN LET idcounter = idcounter + 1: CLS: _KEYCLEAR
    IF keys = 19200 THEN IF quailid(idcounter - 1) <> 0 THEN LET idcounter = idcounter - 1: CLS: _KEYCLEAR
    IF keys = 69 OR keys = 101 THEN GOTO editquailentry
    IF keys = 80 OR keys = 112 THEN GOSUB viewphotosetup
LOOP UNTIL keys = 27
RETURN


viewphotosetup:
REM sets up viewing a photo 
CLS
PRINT "LOADING PHOTO..."
IF ros$ = "lnx" THEN LET catalogphotototal = 6
IF ros$ = "win" THEN LET catalogphotototal = 3
LET catalogphotoloop = 0
DO
	_KEYCLEAR
	LET catalogphotoloop = catalogphotoloop + 1
	IF catalogphotoloop = 1 THEN LET viewphoto$ = photofolder$ + LTRIM$(STR$(idcounter)) + ".jpg"
	IF catalogphotoloop = 2 THEN LET viewphoto$ = photofolder$ + LTRIM$(STR$(idcounter)) + ".jpeg"
	IF catalogphotoloop = 3 THEN LET viewphoto$ = photofolder$ + LTRIM$(STR$(idcounter)) + ".png"
	IF catalogphotoloop = 4 THEN LET viewphoto$ = photofolder$ + LTRIM$(STR$(idcounter)) + ".JPG"
	IF catalogphotoloop = 5 THEN LET viewphoto$ = photofolder$ + LTRIM$(STR$(idcounter)) + ".JPEG"
	IF catalogphotoloop = 6 THEN LET viewphoto$ = photofolder$ + LTRIM$(STR$(idcounter)) + ".PNG"
	GOSUB viewquailphoto
LOOP UNTIL nophoto <> 1 OR catalogphotoloop => catalogphotototal
IF nophoto = 1 THEN
	PRINT "...NO PHOTO FOUND!"
	PRINT
	PRINT "PRESS ENTER TO RETURN!"
	INPUT u
END IF
CLS
RETURN
    
    
    
    
    

