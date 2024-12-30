@echo off
if not "%1" == "" goto START
echo *===================================================================*
echo *  コンパイル用BATファイル
echo *===================================================================*
goto END

:START
setlocal

rem *-------------------------------------------------------------------*
rem *-- Setting Compile Options.
rem *-------------------------------------------------------------------*
set PGM=%1
shift
set GYOMU=%1
shift

set DLOAD=DLOAD
rem ***** set COB_LIBSUFFIX=CPY,CBL
set COB_LIBSUFFIX=CPY
set COMPSLCT=-S
set ENVBAT_FILE=COMPENV%GYOMU%.BAT

:LOOP
if "%1" == "" goto SET_OPTION
if "%1" == "-EXE" set MAIN=-M
if "%1" == "-DLL" set MAIN=
if "%1" == "-CHK" set CHK=-Dk
if "%1" == "-OPT" set OPT=-O
if "%1" == "-DBG" set DBG=-Dt -dd%BIN0%
if "%1" == "-PCOB" set PCOB=F5DDFCB4.LIB
if "%1" == "-NODLOAD" set DLOAD=
shift
goto LOOP

:SET_OPTION

set MAIN2=%MAIN%
if "%MAIN2%" == "" set MAIN2=-D

echo □□□ 環境設定処理中 □□□

rem *-------------------------------------------------------------------*
rem * ↓業務を追加する場合は、このバッチファイルも修正してください↓
rem *-------------------------------------------------------------------*
call COMPENV%GYOMU%.BAT %MAIN2% -U
if "%COMPENV_RTN%" == "NG" goto ERROR

echo □□□ TEMPフォルダ作成中 □□□
set TEMP=%TEMP0%\%PGM%
rd /s /q %TEMP%
md %TEMP%

set MSG=,MESSAGE
set NOALPHAL=NOALPHAL

set SYSOUT=%LST0%\%PGM%_debug.lst
copy nul %SYSOUT% > nul

echo TEMPフォルダ = %TEMP%
echo コンパイルリスト = %SYSOUT%

set OPT1=-m%SMD0% -f.\ffd -P%PGM%_debug.lst -dp%LST0% %CHK% -do%BIN0% %MAIN% %OPT% %DBG%
set OPT2=-WC,"%NOALPHAL%,CONF(68),COPY,%DLOAD%,NUMBER,COUNT,CHECK(ALL),SOURCE,SRF(FIX,FIX),SSIN(SSIN),SSOUT(SSOUT),RCS(UCS2),LIST,XREF%MSG%"
set SUFFIX=CBL
@rem set LIBS=F3BICIMP.LIB LIBC.LIB KERNEL32.LIB USER32.LIB
set LIBS=%LIBSPATH%\F3BICIMP.LIB LIBC.LIB %PCOB%

set @CBR_JUSTINTIME_DEBUG=NO
set @MessOutFile=%TEMP%\COBS_POPUPMSG.txt

copy %SRCU%\%PGM%.%SUFFIX% %TEMP%\%PGM%.%SUFFIX%
echo %SRCU%\%PGM%.%SUFFIX% %TEMP%\%PGM%.%SUFFIX%
rem *-------------------------------------------------------------------*
rem *-- PID のﾁｪｯｸ
:PGIDCHK
echo □□□ プログラムIDチェック中 □□□
if errorlevel 1 goto ERROR

echo PGIDCHK PG=%PGM%.%SUFFIX%
set PGM0=PGIDCHK
set SSOUT=%TEMP%\%PGM0%.txt
set SYSIN="%PGM%"
set INSRC=%TEMP%\%PGM%.%SUFFIX%
set @MGPRM=%SYSIN%

G:\BATCH\BIN\共通\%PGM0%
set ProgramStatus=%errorlevel%
echo ProgramStatus=%ProgramStatus%

copy %SYSOUT%+%SSOUT% %SYSOUT%
del  %SSOUT%
if not %ProgramStatus%==0 echo ********************************************************************
if not %ProgramStatus%==0 echo 指定されたPIDと、ｿｰｽのPROGRAM-IDが一致していません！ 確認願います
if not %ProgramStatus%==0 echo ********************************************************************
if not %ProgramStatus%==0 goto ERROR

:PGIDCHK_END

rem *-------------------------------------------------------------------*
rem *-- COBOL32 Compile
rem *-------------------------------------------------------------------*
:COBOL32
echo □□□ コンパイル中 □□□
echo COBOL97 V61 PGM=%PGM%.%SUFFIX%
cobol32 %OPT1% %OPT2% %SRCU%\%PGM%.%SUFFIX%
if errorlevel 1 goto ERROR
:COBOL32_END

rem *-------------------------------------------------------------------*
rem *-- LINK 用デバッグオプションの設定など
if not "%DBG%" == "" set DBG=/DEBUG /DEBUGTYPE:COFF
if not "%MAIN%" == "" goto LINK-M

rem *-------------------------------------------------------------------*
:LIB
echo □□□ DEFファイル作成中 □□□
rem *-- ﾓｼﾞｭｰﾙ定義ﾌｧｲﾙの自動作成
echo DEFCRT %PGM%.def
set PGM0=DEFCRT
set SSOUT=%TEMP%\%PGM0%.txt
set SYSIN="%PGM%"
set OTDEF=%TEMP%\%PGM%.def
set @MGPRM=%SYSIN%

rem H:\pcbatch\KAIHATU_SITE\WEB_COMPILE_110_NEW\%PGM0%
G:\BATCH\BIN\共通\%PGM0%
set ProgramStatus=%errorlevel%
echo ProgramStatus=%ProgramStatus%

copy %SYSOUT%+%SSOUT% %SYSOUT%
del  %SSOUT%
if not %ProgramStatus%==0 echo ********************************************************************
if not %ProgramStatus%==0 echo ﾓｼﾞｭｰﾙ定義ﾌｧｲﾙ=%TEMP%\%PGM%.def の自動作成に失敗しました
if not %ProgramStatus%==0 echo ********************************************************************
if not %ProgramStatus%==0 goto ERROR

rem *-- LIB (DLLのみ)
echo □□□ オブジェクト作成中 □□□
echo LIB  PGM=%PGM%.LIB
lib /DEF:%TEMP%\%PGM%.def /MACHINE:IX86 /OUT:%BIN0%\%PGM%.LIB %BIN0%\%PGM%.obj
if errorlevel 1 goto ERROR

rem *-------------------------------------------------------------------*
rem *-- LINK (DLL用)
:LINK
echo □□□ DLLのリンケージ中 □□□
echo LINK  PGM=%PGM%.DLL
link %BIN0%\%PGM%.obj %BIN0%\%PGM%.exp %LIBS% %DBG% /DLL /OUT:%BIN0%\%PGM%_DEBUG.DLL
if errorlevel 1 goto ERROR
goto PRE_COMPILE
rem goto NORMAL

rem *-------------------------------------------------------------------*
rem *-- LINK (EXE用)
:LINK-M
echo □□□ EXEのリンケージ中 □□□
echo LINK  PGM=%PGM%.EXE
link %BIN0%\%PGM%.obj %LIBS% %DBG% /OUT:%BIN0%\%PGM%_DEBUG.EXE
if errorlevel 1 goto ERROR

:PRE_COMPILE
copy %SRCU%\%PGM%.%SUFFIX% %TEMP%\%PGM%.%SUFFIX%
if errorlevel 1 goto ERROR
rem *-------------------------------------------------------------------*
rem *-- 【ﾌﾟﾛｸﾞﾗﾑｿｰｽ ﾁｪｯｸ その２】
echo □□□ プログラムソースチェック中 □□□
set PGM0=PRE_COMPILE.vbs
cscript.exe G:\BATCH\BIN\共通\%PGM0%  %TEMP%\%PGM%.%SUFFIX%

rem *-------------------------------------------------------------------*
rem *-- 【ﾌﾟﾛｸﾞﾗﾑｿｰｽﾁｪｯｸ】IF文のネスト範囲をチェックする
:NESTCHK
echo □□□ ネストのチェック中 □□□
echo NESTCHK PG=%PGM%.%SUFFIX%
set PGM0=NESTCHK
set SSOUT=%TEMP%\%PGM0%.txt
set INSRC=%TEMP%\%PGM%.%SUFFIX%
set OTSRC=%LST0%\%PGM%_NESTCHK.%SUFFIX%

G:\BATCH\BIN\共通\%PGM0%
set ProgramStatus=%errorlevel%
echo ProgramStatus=%ProgramStatus%

copy %SYSOUT%+%SSOUT% %SYSOUT%
del  %SSOUT%
if not %ProgramStatus%==0 echo ********************************************************************
if not %ProgramStatus%==0 echo IF文のネスト範囲に確認を要する箇所があります！ 確認願います
if not %ProgramStatus%==0 echo ********************************************************************
if not %ProgramStatus%==0 goto WARNING

del  %OTSRC%

:PROGRAM_NG_CHECK_END

rem *-------------------------------------------------------------------*
:NORMAL
echo COBOL97 V61 - COMPILE and LINK Normal End; Program=%PGM%.%SUFFIX%
echo *
echo *************************
echo * %PGM%   NORMAL END *    ＼(⌒▽⌒)／
echo *************************
rem *** echo * %PGM%  のコンパイル用ワークファイル( %TEMP% )は削除しました。
rem *** rd /s /q %TEMP%
echo * %PGM%.objは削除しました。
del %BIN0%\%PGM%.obj
if not "%MAIN%" == ""  goto END
echo * %PGM%.lib、%PGM%.expは削除しました。
del %BIN0%\%PGM%.lib
del %BIN0%\%PGM%.exp
goto END

rem *-------------------------------------------------------------------*
:WARNING
echo COBOL97 V61 - COMPILE and LINK Normal End; Program=%PGM%.%SUFFIX%
echo *
echo @@@@@@@@@@@@@@@@@@@@@@@@@
echo @ %PGM%  !!WARNING!! @    (ﾉﾟ⊿ﾟ)ﾉ ｶｸﾆﾝｼﾃﾈ!
echo @@@@@@@@@@@@@@@@@@@@@@@@@
rem *** echo * %PGM%  のコンパイル用ワークファイル( %TEMP% )は削除しました。
rem *** rd /s /q %TEMP%
echo * %PGM%.objは削除しました。
del %BIN0%\%PGM%.obj
if not "%MAIN%" == ""  goto END
echo * %PGM%.lib、%PGM%.expは削除しました。
del %BIN0%\%PGM%.lib
del %BIN0%\%PGM%.exp
goto END

rem *-------------------------------------------------------------------*
:ERROR
echo ### COMPILE and LINK ERROR; Program=%PGM%.%SUFFIX% ###
echo *
echo #########################
echo # %PGM% ABNORMAL END #    ＼(゜ロ＼)(／ロ゜)／ｵﾛｵﾛ
echo #########################

:END

endlocal
rem *===================================================================*