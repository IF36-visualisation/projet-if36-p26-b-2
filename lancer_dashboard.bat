@echo off
chcp 65001 >nul
title B2-Spirit - Dashboard du trafic aerien
echo ============================================
echo   B2-Spirit : lancement du dashboard...
echo ============================================
echo.

REM --- Recherche automatique de Rscript.exe ---
set "RSCRIPT="
for /d %%D in ("C:\Program Files\R\R-*") do set "RSCRIPT=%%D\bin\Rscript.exe"
if not exist "%RSCRIPT%" for /d %%D in ("C:\Program Files (x86)\R\R-*") do set "RSCRIPT=%%D\bin\Rscript.exe"

if not exist "%RSCRIPT%" (
  echo [ERREUR] Rscript.exe introuvable.
  echo Installez R depuis https://cran.r-project.org puis relancez.
  echo.
  pause
  exit /b 1
)

REM --- Se placer a la racine du projet (dossier de ce .bat) ---
cd /d "%~dp0"

echo R detecte : %RSCRIPT%
echo Le dashboard va s'ouvrir dans votre navigateur. Gardez cette fenetre ouverte.
echo (Fermez cette fenetre pour arreter l'application.)
echo.

"%RSCRIPT%" -e "shiny::runApp('shiny', launch.browser = TRUE)"

pause
