# Microsoft Developer Studio Project File - Name="asmsx" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=asmsx - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "asmsx.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "asmsx.mak" CFG="asmsx - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "asmsx - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "asmsx - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "asmsx - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386

!ELSEIF  "$(CFG)" == "asmsx - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "asmsx - Win32 Release"
# Name "asmsx - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=asmsx.c
# End Source File
# Begin Source File

SOURCE=error.c
# End Source File
# Begin Source File

SOURCE=.\lex.parser1.c
# End Source File
# Begin Source File

SOURCE=.\lex.parser2.c
# End Source File
# Begin Source File

SOURCE=.\lex.parser3.c
# End Source File
# Begin Source File

SOURCE=.\lex.scan.c
# End Source File
# Begin Source File

SOURCE=parser1.l

!IF  "$(CFG)" == "asmsx - Win32 Release"

!ELSEIF  "$(CFG)" == "asmsx - Win32 Debug"

# Begin Custom Build
InputPath=parser1.l

"lex.parser1.c" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	"C:\Program Files\Git\bin\flex.exe" -i  -Pparser1 -olex.parser1.c $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=parser2.l

!IF  "$(CFG)" == "asmsx - Win32 Release"

!ELSEIF  "$(CFG)" == "asmsx - Win32 Debug"

# Begin Custom Build
InputPath=parser2.l

"lex.parser2.c" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	"C:\Program Files\Git\bin\flex.exe" -i  -Pparser2 -olex.parser2.c $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=parser3.l

!IF  "$(CFG)" == "asmsx - Win32 Release"

!ELSEIF  "$(CFG)" == "asmsx - Win32 Debug"

# Begin Custom Build
InputPath=parser3.l

"lex.parser3.c" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	"C:\Program Files\Git\bin\flex.exe" -i  -Pparser3 -olex.parser3.c $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=scan.l

!IF  "$(CFG)" == "asmsx - Win32 Release"

!ELSEIF  "$(CFG)" == "asmsx - Win32 Debug"

# Begin Custom Build
InputPath=scan.l

"lex.scan.c" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	"C:\Program Files\Git\bin\flex.exe" -i -olex.scan.c $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=warnmsg.c
# End Source File
# Begin Source File

SOURCE=wav.c
# End Source File
# Begin Source File

SOURCE=.\z80gen.tab.c
# End Source File
# Begin Source File

SOURCE=z80gen.y

!IF  "$(CFG)" == "asmsx - Win32 Release"

!ELSEIF  "$(CFG)" == "asmsx - Win32 Debug"

# Begin Custom Build
InputPath=z80gen.y

"z80gen.tab.c" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	"C:\Program Files\Git\bin\bison.exe" -d -v -oz80gen.tab.c $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=asmsx.h
# End Source File
# Begin Source File

SOURCE=error.h
# End Source File
# Begin Source File

SOURCE=parser1.h
# End Source File
# Begin Source File

SOURCE=parser2.h
# End Source File
# Begin Source File

SOURCE=parser3.h
# End Source File
# Begin Source File

SOURCE=warnmsg.h
# End Source File
# Begin Source File

SOURCE=wav.h
# End Source File
# Begin Source File

SOURCE=.\z80gen.tab.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
