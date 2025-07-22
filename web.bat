@echo off

echo Xoa thu muc docs cu neu co...
rmdir /s /q docs

echo Tien hanh build web voi Flutter...
@REM flutter build web
IF ERRORLEVEL 1 (
    echo Build that bai. Dung script.
    exit /b 1
)

echo Di chuyen build\web sang docs...
move build\web docs

echo Hoan tat. Web nam trong thu muc docs\
