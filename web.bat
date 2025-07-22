@echo off

echo Xoa thu muc docs cu neu co...
rmdir /s /q docs

@REM echo Tien hanh build web voi Flutter...
@REM flutter build web
@REM IF ERRORLEVEL 1 (
@REM     echo Build that bai. Dung script.
@REM     exit /b 1
@REM )

echo Di chuyen build\web sang docs...
move build\web docs
echo lichhoc.trantien.id.vn > docs\CNAME
echo Da tao ten mien.
echo Hoan tat. Web nam trong thu muc docs\
