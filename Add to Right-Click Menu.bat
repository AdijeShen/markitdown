@echo off
setlocal EnableDelayedExpansion

:: 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please check permission or run as administrator
    pause
    exit /b 1
)

:: 定义要处理的文件后缀
set "extensions=pdf doc docx txt ppt pptx xls xlsx"
echo Will process following extensions: %extensions%
echo.

:: 初始化计数器
set "success_count=0"
set "fail_count=0"

:: 创建转换脚本
echo @echo off > "%SystemRoot%\pdf2md.bat"
echo markitdown "%%1" -o "%%~dpn1.md" >> "%SystemRoot%\pdf2md.bat"

:: 创建临时注册表文件
set "regfile=%temp%\pdf2md.reg"
echo Windows Registry Editor Version 5.00 > "%regfile%"
echo. >> "%regfile%"

:: 处理每个后缀
for %%e in (%extensions%) do (
    echo Processing .%%e files...
    
    :: 获取文件类型的默认程序ID
    for /f "tokens=3" %%i in ('reg query "HKEY_CLASSES_ROOT\.%%e" /ve 2^>nul') do set "classid=%%i"
    
    if not defined classid (
        echo Failed to get program ID for .%%e files
        set /a "fail_count+=1"
    ) else (
        echo Found program ID: !classid!
        
        :: 添加注册表项
        echo [HKEY_CLASSES_ROOT\!classid!\shell\ConvertToMarkdown] >> "%regfile%"
        echo @="Convert to Markdown" >> "%regfile%"
        echo. >> "%regfile%"
        echo [HKEY_CLASSES_ROOT\!classid!\shell\ConvertToMarkdown\command] >> "%regfile%"
        echo @="pdf2md.bat \"%%1\"" >> "%regfile%"
        echo. >> "%regfile%"
        
        set /a "success_count+=1"
        echo Successfully added settings for .%%e files
    )
    
    echo.
    set "classid="
)

:: 导入注册表
reg import "%regfile%"
if %errorLevel% equ 0 (
    echo Registry import successful
) else (
    echo Registry import failed, please check permission
    set "success_count=0"
    set /a "fail_count+=1"
)

:: 显示总结
echo.
echo Processing complete
echo Successful: %success_count%
echo Failed: %fail_count%

:: 清理临时文件
del "%regfile%"

pause
