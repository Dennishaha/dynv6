
%~1 @mshta vbscript:CreateObject^("Shell.Application"^).ShellExecute^("cmd.exe","/q /d /k call ""%~s0"" ::","","runas",1^)^(window.close^)& exit /b 0

chcp 65001 >nul
title Young Deamon Process

:: 预设值 
set Client=%ProgramFiles(x86)%\dial_client\Auth_Supplicant.exe
set UseCard="以太网 5"
set DisCard="AC9260";"蓝牙网络连接 2"
set Stop=

for %%i in ("%ClientPath%") do set "ClientName=%%~nxi"

:: 运行检查 
if not exist "%Client%" 1>&2 echo;客户端 "%Client%" 缺失。 
netsh interface show interface %UseCard% | find "An interface with this name is not registered with the router." >nul && (
	1>&2 echo;网卡 %UseCard% 缺失。 
)

echo;
echo;登录客户端路径 %Client% 
echo;网络连接使用的网卡 %UseCard% 
echo;连接时禁用的网卡 %DisCard% 
echo;连接时禁用的进程 %Stop% 
echo;
echo;Young 网络守护进程已启动。 
echo;

:Head

netsh interface show interface %UseCard% | find "   Connect state:        Connected" >nul && (
	timeout /t 1 /nobreak >nul
	goto :Head
)

1>&2 echo;%UseCard% 未连接，正尝试链接。 

rasdial "my pppoe link" /disconnect
for %%i in ("%ClientName%";%Stop%) do taskkill /f /im "%%~i" /t 2>nul

for %%i in (%DisCard%) do netsh interface set interface "%%~i" disabled
start "" "%Client%"

timeout /t 6 /nobreak >nul

taskkill /f /im "%ClientName%" /t
for %%i in (%DisCard%) do netsh interface set interface "%%~i" enabled

goto :Head

