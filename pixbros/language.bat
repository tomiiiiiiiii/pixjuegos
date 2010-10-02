@rem recupera lenguaje de windows
@reg query HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Nls\Language /v Default | findstr Default > %TEMP%\lang.txt