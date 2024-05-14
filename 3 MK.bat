@echo off
set COMPILEDIR=%CD%
set color=1e
color %color%

:START
cls
set CLANGUAGE=English
set LANG=english
set LTARGET=english

echo.
echo  Checking language directories...
if not exist ..\..\zone\%LTARGET% mkdir ..\..\zone\%LTARGET%
if not exist ..\..\zone_source\%LTARGET% xcopy ..\..\zone_source\english ..\..\zone_source\%LTARGET% /SYI > NUL
echo  Promatch will be created in %CLANGUAGE%!
echo.


echo  Building mod.ff:
echo    Deleting old mod.ff file...
del mod.ff

echo    Copying localized strings...
xcopy %LANG% ..\..\raw\%LTARGET% /SYI > NUL

echo    Copying game resources...
echo xcopy images ..\..\raw\images /SYI > NUL
xcopy mp ..\..\raw\mp /SYI > NUL
xcopy fx ..\..\raw\fx /SYI > NUL
xcopy maps ..\..\raw\maps /SYI > NUL
xcopy images ..\..\raw\images /SYI > NUL
xcopy sound ..\..\raw\sound /SYI > NUL
xcopy soundaliases ..\..\raw\soundaliases /SYI > NUL
xcopy materials ..\..\raw\materials /SYI > NUL
xcopy material_properties ..\..\raw\material_properties /SYI > NUL
xcopy xanim ..\..\raw\xanim /SYI > NUL
xcopy xmodel ..\..\raw\xmodel /SYI > NUL
xcopy xmodelparts ..\..\raw\xmodelparts /SYI > NUL
xcopy xmodelsurfs ..\..\raw\xmodelsurfs /SYI > NUL
xcopy mp ..\..\raw\mp /SYI > NUL
xcopy rulesets ..\..\raw\rulesets /SYI > NUL
xcopy promatch ..\..\raw\promatch /SYI > NUL
xcopy ui_mp ..\..\raw\ui_mp /SYI > NUL
xcopy vision ..\..\raw\vision /SYI > NUL
copy /Y mod.csv ..\..\zone_source > NUL
copy /Y mod_ignore.csv ..\..\zone_source\english\assetlist > NUL
cd ..\..\bin > NUL

echo    Compiling mod...
linker_pc.exe -language english -compress -cleanup mod 
cd %COMPILEDIR% > NUL
copy ..\..\zone\english\mod.ff > NUL
echo  New mod.ff file successfully built!
del z_promatch2.iwd
7za a -r -tzip z_promatch2.iwd rulesets\promatch\promatch.gsc > NUL
7za a -r -tzip z_promatch2.iwd rulesets\promatch\rulesets.gsc > NUL
7za a -r -tzip z_promatch2.iwd rulesets\custom.gsc > NUL
7za a -r -tzip z_promatch2.iwd rulesets\*.cfg > NUL
7za a -r -tzip z_promatch2.iwd weapons\mp\*_mp > NUL
7za a -r -tzip z_promatch2.iwd mod.arena > NUL
7za a -r -tzip z_promatch2.iwd promatch\*.gsc > NUL
7za a -r -tzip z_promatch2.iwd maps\mp\gametypes\*.gsc > NUL
7za a -r -tzip z_promatch2.iwd maps\mp\*.gsc > NUL


copy /y mod.ff "H:\COD4\Mods\promatch207"
copy /y mod.ff "H:\COD4SERVER\Mods\promatch207"
copy /y z_promatch1.iwd "H:\COD4\Mods\promatch207"
copy /y z_promatch1.iwd "H:\COD4SERVER\Mods\promatch207"
copy /y z_promatch2.iwd "H:\COD4\Mods\promatch207"
copy /y z_promatch2.iwd "H:\COD4SERVER\Mods\promatch207"
copy /y z_promatch3.iwd "H:\COD4\Mods\promatch207"
copy /y z_promatch3.iwd "H:\COD4SERVER\Mods\promatch207"
exit