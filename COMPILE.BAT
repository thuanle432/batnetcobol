@echo off
if not "%1" == "" goto START

echo *========================================================================================*

echo *  コンパイル用BATファイル（メイン）

echo *  P1：COBOLソースファイル名（拡張子「.CBL」は含まず）

echo *  P2：SJISコンパイル時 = 「-S」、UCS2コンパイル時 = 「-U」、

echo *  P3：業務コード   現在=「-KH」（国保資格賦課）のみ対応

echo *  P4：メインプログラムコンパイル時 = 「-EXE」、サブプログラムコンパイル時 = 「-DLL」

echo *========================================================================================*

goto END



:START

setlocal



set PGM=%1

shift

set SJIS-UCS2=%1

shift

set GYOMU=%1

shift

set MAIN-SUB=%1

shift



if "%SJIS-UCS2%" == "-S" goto SJIS_COMPILE

if "%SJIS-UCS2%" == "-U" goto UCS2_COMPILE



:SJIS_COMPILE

call COMPILE%SJIS-UCS2%.BAT %PGM% %GYOMU% %MAIN-SUB%

call COMPILE%SJIS-UCS2%_DBG.BAT %PGM% %GYOMU% %MAIN-SUB%

goto END



:UCS2_COMPILE

call COMPILE%SJIS-UCS2%.BAT %PGM% %GYOMU% %MAIN-SUB%

call COMPILE%SJIS-UCS2%_DBG.BAT %PGM% %GYOMU% %MAIN-SUB%

goto END




:END



endlocal

rem *===================================================================*
