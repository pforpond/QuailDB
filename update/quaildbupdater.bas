REM quaildb updater
REM danielle pond
REM small updater for quaildb

REM screen and font
_TITLE "Xander's Quail Database Updater"
SCREEN _NEWIMAGE(800, 600, 32)
$RESIZE:STRETCH
$CONSOLE
LET dbfont& = _LOADFONT("data/font.ttf", 30)
_FONT dbfont&
REM check os
IF INSTR(_OS$, "[WINDOWS]") THEN LET ros$ = "win"
IF INSTR(_OS$, "[LINUX]") THEN LET ros$ = "lnx"
LET quaildbupdate$ = "https://dl.dropboxusercontent.com/s/m8g8ar8oqa4d74h/quaildbupdate.zip"
PRINT "CHECKING FOR UPDATES..."
PRINT
PRINT "...AN UPDATE IS AVAILABLE!"
PRINT
PRINT "- DOWNLOADING UPDATER..."
PRINT "...DONE!"
PRINT "- LAUNCHING UPDATER..."
PRINT "...DONE!"
PRINT "- BACKING UP PREVIOUS VERSION..."
REM backs up
IF ros$ = "lnx" THEN
	SHELL _HIDE "mkdir updatebackup"
	SHELL _HIDE "cp quaildb_linux updatebackup/"
	SHELL _HIDE "cp quaildb_win.exe updatebackup/"
END IF
IF ros$ = "win" THEN
	SHELL _HIDE "mkdir updatebackup"
	SHELL _HIDE "copy quaildb_linux updatebackup\"
	SHELL _HIDE "copy quaildb_win.exe updatebackup\"
END IF
REM checks backups
IF _FILEEXISTS("updatebackup\quaildb_linux") THEN
	REM nothing
ELSE
	PRINT "...UPDATE FAILED! FAILED TO BACKUP PREVIOUS VERSIONS!"
	PRINT "press enter to continue"
	INPUT a
	IF ros$ = "lnx" THEN SHELL _DONTWAIT "./quaildb_linux -noupdate": SYSTEM
	IF ros$ = "win" THEN SHELL _DONTWAIT "quaildb_win.exe -noupdate": SYSTEM
	END
END IF
PRINT "...DONE!"
REM deletes old versions
PRINT "- REMOVING PREVIOUS VERSIONS..."
IF ros$ = "lnx" THEN SHELL _HIDE "rm quaildb_linux": SHELL _HIDE "rm quaildb_win.exe"
IF ros$ = "win" THEN SHELL _HIDE "del quaildb_linux": SHELL _HIDE "del quaildb_win.exe"
PRINT "...DONE!"
REM downloads new versions
PRINT "- DOWNLOADING NEW VERSION..."
IF ros$ = "lnx" THEN SHELL _HIDE "curl -o quaildbupdate.zip " + quaildbupdate$
IF ros$ = "win" THEN SHELL _HIDE "windownloader.bat " + quaildbupdate$ + " quaildbupdate.zip"
REM checks download
IF _FILEEXISTS("quaildbupdate.zip") THEN
	REM nothing
ELSE
	REM no update file found!
	PRINT "...UPDATE FAILED! FAILED TO DOWNLOAD NEW VERSION!"
	PRINT "press enter to continue"
	INPUT a
	IF ros$ = "lnx" THEN
		SHELL _HIDE "cp updatebackup\quaildb_linux"
		SHELL _HIDE "cp updatebackup\quaildb_win.exe"
		SHELL _DONTWAIT "./quaildb_linux -noupdate"
		SYSTEM
	END IF
	IF ros$ = "win" THEN
		SHELL _HIDE "copy updatebackup/quaildb_linux"
		SHELL _HIDE "copy updatebackup/quaildb_win.exe"
		SHELL _DONTWAIT "quaildb_win.exe -noupdate"
		SYSTEM
	END IF
	END
END IF
PRINT "...DONE!"
REM extracts zip and copies icon
PRINT "- INSTALLING UPDATE..."
IF ros$ = "lnx" THEN 
	SHELL _HIDE "unzip -o quaildbupdate.zip"
	SHELL _HIDE "mv -f icon.ico data/icon.ico"
	SHELL _HIDE "mv -f font.ttf data/font.ttf"
END IF
IF ros$ = "win" THEN 
	SHELL _HIDE "unzip -o quaildbupdate.zip"
	SHELL _HIDE "copy icon.ico data\icon.ico /y"
	SHELL _HIDE "copy font.ttf data\font.ttf /y"
	SHELL _HIDE "del icon.ico"
	SHELL _HIDE "del font.ttf"
END IF
REM checks if extract is good
IF _FILEEXISTS("quaildb_linux") THEN
	REM nothing
ELSE
	PRINT "...UPDATE FAILED! FAILED TO INSTALL UPDATE!"
	PRINT "press any key to continue"
	INPUT a
		IF ros$ = "lnx" THEN
		SHELL _HIDE "cp updatebackup\quaildb_linux"
		SHELL _HIDE "cp updatebackup\quaildb_win.exe"
		SHELL _DONTWAIT "./quaildb_linux -noupdate"
		SYSTEM
	END IF
	IF ros$ = "win" THEN
		SHELL _HIDE "copy updatebackup/quaildb_linux"
		SHELL _HIDE "copy updatebackup/quaildb_win.exe"
		SHELL _DONTWAIT "quaildb_win.exe -noupdate"
		SYSTEM
	END IF
	END
END IF
IF _FILEEXISTS("quaildb_win.exe") THEN
	REM nothing
ELSE
	PRINT "...UPDATE FAILED! FAILED TO INSTALL UPDATE!"
	PRINT "press any key to continue"
	INPUT a
		IF ros$ = "lnx" THEN
		SHELL _HIDE "cp updatebackup\quaildb_linux"
		SHELL _HIDE "cp updatebackup\quaildb_win.exe"
		SHELL _DONTWAIT "./quaildb_linux -noupdate"
		SYSTEM
	END IF
	IF ros$ = "win" THEN
		SHELL _HIDE "copy updatebackup/quaildb_linux"
		SHELL _HIDE "copy updatebackup/quaildb_win.exe"
		SHELL _DONTWAIT "quaildb_win.exe -noupdate"
		SYSTEM
	END IF
	END
END IF
PRINT "...DONE!"
REM update is complete! return to main app!
PRINT
PRINT "UPDATE COMPLETE!"
PRINT "DATABASE WILL RE-LAUNCH SOON..."
_DELAY 5
IF ros$ = "lnx" THEN SHELL _HIDE "chmod +x quaildb_linux": SHELL _DONTWAIT "./quaildb_linux -noupdate": SYSTEM
IF ros$ = "win" THEN SHELL _DONTWAIT "quaildb_win.exe -noupdate": SYSTEM







