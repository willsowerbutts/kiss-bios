echo off

set USBdrv=E
dir *.zip > %tmp%\foo
sort < %tmp%\foo
if "%1"=="" goto err2
if exist %1.zip goto err1
pkzip -P %1.zip copying. notice. make*.*
pkzip -Pa %1.zip *.hex *.b* *.a* *.s* *.c* *.h* *.doc *.txt *.out
REM  pkzip -Pa %1.zip ..\lib\libc.a ..\lib\libgcc.a
echo .
copy %1.zip D:\M68K_BAK
echo .
echo Please mount flash drive in USB port
pause
REM chkdsk %USBdrv%:
REM dir %1.zip
REM pause
xcopy %1.zip %USBdrv%:\Kiss /v
dir %USBdrv%:\Kiss
goto end
:err1
echo %1.zip ALREADY EXISTS
goto end
:err2
echo .
echo Usage:  SAVE  filename
:end
