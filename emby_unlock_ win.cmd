@echo off
mode con: cols=100 lines=40

setlocal enabledelayedexpansion

title Emby Unlocker ^| arg0WAK

color b
cls

echo ---------------------------------------------------------
echo ^|                                                       ^|
echo ^|          Emby Unlocker for Lifetime Premiere          ^|
echo ^|               https://github.com/arg0WAK              ^|
echo ^|                                                       ^|
echo ---------------------------------------------------------
echo.

for /F %%a in ('echo prompt $E ^| cmd') do set "esc=%%a"

set "Red=%esc%[31m"
set "Green=%esc%[32m"
set "Yellow=%esc%[33m"
set "Blue=%esc%[34m"
set "Magenta=%esc%[35m"
set "Cyan=%esc%[36m"
set "White=%esc%[37m"
set "Reset=%esc%[0m"

set INFO=%Cyan%[NFO]%Reset%
set SUCCESS=%Green%[DNE]%Reset%
set ERROR=%Red%[ERR]%Reset%
set WARNING=%Yellow%[NFO]%Reset%

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo %ERROR% You must run this script as ADMINISTRATOR.
    pause
    exit /b 1
) else (
    echo %SUCCESS% Administrator privilege check passed.
)

set HOST_FILE=%WINDIR%\System32\drivers\etc\hosts
set SITE=arg0.dev

for /f "tokens=2 delims=[]" %%a in ('ping -n 1 %SITE% ^| find "["') do (
    set IP_ARG0=%%a
)

set PROXY=!IP_ARG0! mb3admin.com

echo %WARNING% Adding entry to %HOST_FILE%...
timeout /t 2 /nobreak >nul

findstr /C:"!PROXY!" "%HOST_FILE%" >nul
if !errorlevel! neq 0 (
    echo !PROXY! >> "%HOST_FILE%"
    echo %SUCCESS% Line added: !PROXY!
) else (
    echo %INFO% Required entry already exists: !PROXY!
)

echo %INFO% Downloading certificate...
timeout /t 2 /nobreak >nul

set CERT_FILE=mb3admin.crt
set CERT_URL=https://arg0.dev/emby/%CERT_FILE%
set TEMP_CERT=%TEMP%\%CERT_FILE%

powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%CERT_URL%', '%TEMP_CERT%')"

if !errorlevel! neq 0 (
    echo %ERROR% Certificate could not be downloaded.
    pause
    exit /b 1
) else (
    echo %SUCCESS% Certificate downloaded.
)

echo %WARNING% Installing certificate to Root CA...
echo %INFO% Waiting last user privileges...
timeout /t 2 /nobreak >nul

certutil -addstore "Root" "%TEMP_CERT%" >nul 2>&1

if %errorlevel% neq 0 (
    powershell -command "Write-Host ([ComponentModel.Win32Exception]::new(%errorlevel%).Message)"
    echo %ERROR% Certificate could not be added.
    pause
    exit /b 1
) else (
    echo %SUCCESS% Certificate successfully added to system store.
)

echo %WARNING% Cleaning up temporary files...
timeout /t 2 /nobreak >nul
del "%TEMP_CERT%" >nul 2>&1

if exist "%TEMP_CERT%" (
    echo %ERROR% Temporary file could not be deleted.
) else (
    echo %SUCCESS% Temporary certificate file removed.
)

echo %WARNING% Restarting network services...
timeout /t 2 /nobreak >nul

ipconfig /flushdns >nul 2>&1

if %errorlevel% neq 0 (
    echo %ERROR% Failed to restart network services. Please check your system settings.
    pause
    exit /b 1
) else (
    echo %SUCCESS% Network services restarted successfully.
)

echo %WARNING% Testing network connectivity...

timeout /t 10 /nobreak >nul

set MB3ADMIN=mb3admin.com

for /f "tokens=2 delims=[]" %%a in ('ping -n 1 %MB3ADMIN% ^| find "["') do (
    set IP_MB3ADMIN=%%a
)

if "!IP_MB3ADMIN!" == "!IP_ARG0!" (
    echo %SUCCESS% Both domains match the same IP address: !IP_MB3ADMIN!
) else (
    echo %ERROR% The domains do not match the same IP address. Please flush your DNS cache manually.
    pause
    exit /b 1
)

echo %WARNING% Checking SSL to mb3admin.com...

timeout /t 2 /nobreak >nul

powershell -Command ^
"try { ^
  $req = [System.Net.HttpWebRequest]::Create('https://mb3admin.com'); ^
  $res = $req.GetResponse(); ^
  $res.Close(); ^
  $cert = $req.ServicePoint.Certificate; ^
  if (-not $cert) { exit 1 } ^
} catch { exit 1 }"

if %errorlevel% neq 0 (
    echo %ERROR% SSL connection failed. Please check your network settings.
    pause
    exit /b 1
) else (
    echo %SUCCESS% SSL connection to mb3admin.com is successful.
)

color a
cls
echo.
echo ---------------------------------------------------------------
echo ^|                                                             ^|
echo ^|            Emby Premiere is now fully unlocked.             ^|
echo ^|      You can use any license key and enjoy all features^^!    ^|
echo ^|                                                             ^|
echo ---------------------------------------------------------------
echo.

echo %WARNING% If you want to support my work, please consider starring my GitHub repository!
echo %INFO% telegram: @arg0WAK

timeout /t 3 /nobreak >nul
start https://github.com/arg0WAK

pause
exit /b 1