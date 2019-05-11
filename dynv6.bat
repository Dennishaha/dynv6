
@echo off
setlocal EnableDelayedExpansion

:: 使用前可将脚本加载于 组策略-本地计算机策略-计算机配置-Windows设置-启动

set token=这里填入你的 Token
set hostname=这里填入你的 dynv6 域名
set daemon=5

:: 预设 
set "MsgBox=call :MsgBox"
set "Url=http://dynv6.com/api/update?hostname=%hostname%&ipv6=^!ipv6^!&token=%token%"

:: 检测 
bitsadmin /? >nul || (%MsgBox% "bitsadmin.exe is missing." & exit /b 1)
timeout /? >nul || (%MsgBox% "timeout.exe is missing." & exit /b 1)

:loop

:: 获取IPv6 
set "ipv6.old=%ipv6%"
for /f "tokens=1,* delims=:" %%a in ('ipconfig ^| findstr /i /r /c:"^   IPv6.*" 2^>nul') do (
	set "ipv6=%%b" & set "ipv6=!ipv6:~1!"
	goto :out1
)
:out1

:: 有变更时，上传 
if not "%ipv6%"=="%ipv6.old%" (
	>"%tmp%\dynv6.log" echo;
	bitsadmin /transfer %random% /download /dynamic "%Url%" "%tmp%\dynv6.log"
	findstr /i "unchanged updated" "%tmp%\dynv6.log" || (
		%MsgBox% "Some errors have occurred and you can check the log file for information.  %tmp%\dynv6.log"
	)

)

:: 刷新间隔 
timeout /t %daemon% /nobreak >nul
goto :loop


:MsgBox
mshta vbscript:execute^("msgbox(""%~1"",64,""dynv6"")(close)"^)
goto :EOF