
%~1 @mshta vbscript:CreateObject^("Shell.Application"^).ShellExecute^("cmd.exe","/q /d /k call ""%~s0"" ::","","runas",1^)^(window.close^)& exit /b 0

chcp 65001 >nul
title Young Deamon Process

:: 预设值 
set Client=%ProgramFiles(x86)%\dial_client\Auth_Supplicant.exe
set UseCard="以太网"
set DisCard="AC9260";"蓝牙网络连接 2"
set Stop=

for %%i in ("%Client%") do set "ClientName=%%~nxi"

set times=0

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
	rasdial | find /i "My PPPOE Link" >nul && (
		<nul set /p "=%UseCard% 已连接。 "
	)
	rasdial | find /i "My PPPOE Link" >nul || (
		echo;
		call :Connect
	)
) || (
	<nul set /p "=%UseCard% 网线已断开。 "
	rasdial "my pppoe link" /disconnect >nul
)
timeout /t 1 /nobreak >nul
goto :Head

:Connect
set /a times+=1

echo;%UseCard% 网线已接入，正在尝试链接（第 %times% 次）。 

for %%i in ("%ClientName%";%Stop%) do taskkill /f /im "%%~i" /t >nul 2>nul
for %%i in (%DisCard%) do netsh interface set interface "%%~i" disabled >nul

start "" "%Client%"

for /l %%i in (1,1,15) do (
	timeout /t 1 /nobreak >nul
	rasdial | find /i "My PPPOE Link" >nul && goto :Connect-ringout
	if "%%i"=="15" echo;%UseCard% 连接超时，请检查客户端状态。 
)
:Connect-ringout

taskkill /f /im "%ClientName%" /t >nul 2>nul
for %%i in (%DisCard%) do netsh interface set interface "%%~i" enabled >nul

goto :EOF

