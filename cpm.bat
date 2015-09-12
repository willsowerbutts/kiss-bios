REM
echo  Create a new ROM binary with CP/M-68
REM
set TARGET=kiss01
set KROM=.\rom
REM
make %TARGET%.bin
copy/b %TARGET%.bin+%KROM%\rom80.bin cpm68sm.bin
copy/b %TARGET%.bin+%KROM%\rom400.bin cpm68.bin

