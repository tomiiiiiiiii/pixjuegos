if exist c:\pixjuegos.build.properties copy c:\pixjuegos.build.properties build.properties /y
cmd /c if exist c:\pixjuegos.keystore ant release install
cmd /c if not exist c:\pixjuegos.keystore ant debug install
cd bin
mkdir ..\..\..\temp 2> NUL
copy /y *release.apk ..\..\..\temp
start ..\..\..\temp &
taskkill /im adb.exe /f
pause