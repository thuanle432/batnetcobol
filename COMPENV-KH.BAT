rem *===================================================================*
rem *  COBOL97 COMPILE and LINK
rem *  ＰＣバッチ開発　プログラムコンパイルバッチ用環境変数設定
rem *  for 国保資格賦課
rem *===================================================================*
set MAINSUB=SUB
if "%1" == "-M" set MAINSUB=PGM

rem *▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
rem *  LIBSPATHにNetCOBOLのインストールパスを設定してください。
set LIBSPATH="C:\Program Files (x86)\NetCOBOL"
rem *▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
rem *▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
rem *  KERNEL32_LIB_PATHにkernel32.Libが格納されているパスを設定してください。
set KERNEL32_LIB_PATH="C:\Program Files (x86)\Windows Kits\10\Lib\10.0.17763.0\um\x86"
rem *▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

rem *-------------------------------------------------------------------*
rem * 翻訳時に参照するコピー句フォルダの設定（全業務共通）
rem *-------------------------------------------------------------------*
if "%2" == "-S"  set CPY1=G:\BATCH\CBL\共通\CPY\CPYSJIS
if "%2" == "-S"  goto START_MSG1
if "%2" == "-U"  set CPY1=G:\BATCH\CBL\共通\CPY\CPYUCS2
if "%2" == "-U"  goto START_MSG1

goto ERROR1

:START_MSG1

set CPY0=G:\BATCH\CBL\国保資格賦課\CPY
set CPY2=G:\BATCH\CBL\共通\CPY
set CPY3=

echo CPY0=%CPY0%
if not exist %CPY0% goto ERROR2
echo CPY1=%CPY1%
if not exist %CPY1% goto ERROR2
echo CPY2=%CPY2%
if not exist %CPY2% goto ERROR2

set COB_COBCOPY=%CPY0%;%CPY1%;%CPY2%

if "%CPY3%" == ""  goto CPY3_SKIP
echo CPY3=%CPY3%
if not exist %CPY3% goto ERROR2
set COB_COBCOPY=%CPY0%;%CPY1%;%CPY2%;%CPY3%
:CPY3_SKIP

echo COB_COBCOPY=%COB_COBCOPY%

rem *-------------------------------------------------------------------*
rem * 
rem *-------------------------------------------------------------------*
echo *** SJIS 固定形式 メインプログラムｺﾝﾊﾟｲﾙ ***
set SRC0=G:\BATCH\CBL\国保資格賦課\%MAINSUB%\SJIS
set SRCU=G:\BATCH\CBL\国保資格賦課\%MAINSUB%\UNI
set SRCB=G:\BATCH\CBL\国保資格賦課\%MAINSUB%\BOTH
set BIN0=G:\BATCH\BIN\国保資格賦課
set TEMP0=G:\BATCH\TEMP\国保資格賦課
set SMD0=G:\BATCH\FORM\国保資格賦課
set LST0=G:\BATCH\CBL\国保資格賦課\%MAINSUB%\COMPILELIST

echo SRC0=%SRC0%
rem *** 止血 *** if not exist %SRC0% goto ERROR2
echo SRCU=%SRCU%
rem *** 止血 *** if not exist %SRCU% goto ERROR2
echo SRCB=%SRCB%
rem *** 止血 *** if not exist %SRCB% goto ERROR2
echo BIN0=%BIN0%
rem *** 止血 *** if not exist %BIN0% goto ERROR2
echo TEMP0=%TEMP0%
rem *** 止血 *** if not exist %TEMP0% goto ERROR2
echo SMD0=%SMD0%
rem *** 止血 *** if not exist %SMD0% goto ERROR2
echo LST0=%LST0%
rem *** 止血 *** if not exist %LST0% goto ERROR2

goto END

rem *-------------------------------------------------------------------*
rem * 業務コードに誤りがあった場合
rem *-------------------------------------------------------------------*
:ERROR0
set COMPENV_RTN=NG
echo ### 業務コードに誤り=%3 ###
echo Ctrl+C を押して処理を中断してください！
rem *** PAUSE

goto END

rem *-------------------------------------------------------------------*
rem * コンパイル種別に誤りがあった場合
rem *-------------------------------------------------------------------*
:ERROR1
set COMPENV_RTN=NG
echo ### コンパイル種別に誤り=COB%2 ###
echo Ctrl+C を押して処理を中断してください！
rem *** PAUSE

goto END

rem *-------------------------------------------------------------------*
rem * 指定されたフォルダが存在しなかった場合
rem *-------------------------------------------------------------------*
:ERROR2
set COMPENV_RTN=NG
echo ### フォルダが存在しません！ ###
echo Ctrl+C を押して処理を中断してください！
rem *** PAUSE

rem *-------------------------------------------------------------------*
rem * 終わり
rem *-------------------------------------------------------------------*
:END
