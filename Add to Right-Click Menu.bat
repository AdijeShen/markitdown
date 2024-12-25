@echo off
setlocal EnableDelayedExpansion

:: 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo please check permission or run as administrator
    pause
    exit /b 1
)

:: 创建转换脚本
echo @echo off > "%SystemRoot%\pdf2md.bat"
echo markitdown "%%1" -o "%%~dpn1.md" >> "%SystemRoot%\pdf2md.bat"

:: 创建临时注册表文件
set "regfile=%temp%\pdf2md.reg"
echo Windows Registry Editor Version 5.00 > "%regfile%"
echo. >> "%regfile%"
echo [HKEY_CLASSES_ROOT\KWPS.PDF.9\shell\ConvertToMarkdown] >> "%regfile%"
echo @="Convert to Markdown" >> "%regfile%"
echo. >> "%regfile%"
echo [HKEY_CLASSES_ROOT\KWPS.PDF.9\shell\ConvertToMarkdown\command] >> "%regfile%"
echo @="pdf2md.bat \"%%1\"" >> "%regfile%"

:: 导入注册表
reg import "%regfile%"
if %errorLevel% equ 0 (
    echo install success
) else (
    echo install failed, please check permission or run as administrator
)

:: 清理临时文件
del "%regfile%"

pause
