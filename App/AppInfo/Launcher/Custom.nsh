ChangeUI all "${NSISDIR}\Contrib\UIs\modern.exe"

${SegmentFile}

	Var ApacheService_Exist
	Var MySQLService_Exist
	Var MaperDLL_Exist

${SegmentPre}

	Banner::show /set 76 "Моля, изчакайте, IcarTest Portable" "подготвя файловете..."

	ExpandEnvStrings $1 "%PAL:AppDir%\IcarTest_xampp"
	ExpandEnvStrings $2 "%PAL:AppDir:ForwardSlash%/IcarTest_xampp"
	ExpandEnvStrings $3 "C:/IcarTest_xampp"
	ExpandEnvStrings $4 "C:\IcarTest_xampp"

	CopyFiles /SILENT "$1\mysql\bin\my.cnf" "$1\mysql\bin\my.cnf.bak"
	CopyFiles /SILENT "$1\apache\bin\php.ini" "$1\apache\bin\php.ini.bak"
	CopyFiles /SILENT "$1\apache\conf\httpd.conf" "$1\apache\conf\httpd.conf.bak"
	CopyFiles /SILENT "$1\apache\conf\extra\httpd-ssl.conf" "$1\apache\conf\extra\httpd-ssl.conf.bak"
	CopyFiles /SILENT "$1\apache\conf\extra\httpd-xampp.conf" "$1\apache\conf\extra\httpd-xampp.conf.bak"

	${ReplaceInFile} "$1\mysql\bin\my.cnf" $3 $2
	${ReplaceInFile} "$1\apache\bin\php.ini" $4 $1
	${ReplaceInFile} "$1\apache\conf\httpd.conf" $3 $2
	${ReplaceInFile} "$1\apache\conf\extra\httpd-ssl.conf" $3 $2
	${ReplaceInFile} "$1\apache\conf\extra\httpd-xampp.conf" $3 $2

	Sleep 500
	Banner::destroy

!macroend

${SegmentPrePrimary}

	${registry::KeyExists} "HKLM\SYSTEM\CurrentControlSet\services\Apache2.2" $R0
	${If} $R0 = 0
		StrCpy $ApacheService_Exist true
	${Else}
		Banner::show /set 76 "Моля, изчакайте," "стартира се Apache2.2 услугата..."
		nsExec::Exec '$AppDirectory\IcarTest_xampp\apache\bin\apache -k install'
		nsExec::Exec 'net start Apache2.2'
		Banner::destroy
	${EndIf}

	${registry::KeyExists} "HKLM\SYSTEM\CurrentControlSet\services\mysql" $R0
	${If} $R0 = 0
		StrCpy $MySQLService_Exist true
	${Else}
		Banner::show /set 76 "Моля, изчакайте," "стартира се MySQL услугата..."
		nsExec::Exec '$AppDirectory\IcarTest_xampp\mysql\bin\mysqld --install mysql --defaults-file="$AppDirectory\IcarTest_xampp\mysql\bin\my.cnf"'
		nsExec::Exec 'net start MySQL'
		Banner::destroy
	${EndIf}

	${registry::KeyExists} "HKLM\Software\Classes\AppID\Maper.DLL" $R0
	${If} $R0 = 0
		StrCpy $MaperDLL_Exist true
	${Else}
		Banner::show /set 76 "Моля, изчакайте," "регистрира се Maper.dll..."
		nsExec::Exec 'regsvr32 /s "$AppDirectory\IcarTest_xampp\IcarTest\Maper.dll"'
		Banner::destroy
	${EndIf}

!macroend

${SegmentPostPrimary}

	${IfNot} $ApacheService_Exist == true
		${registry::KeyExists} "HKLM\SYSTEM\CurrentControlSet\services\Apache2.2" $R0
		${If} $R0 = 0
			Banner::show /set 76 "Моля, изчакайте," "спира се Apache2.2 услугата..."
			nsExec::Exec 'net stop Apache2.2'
			nsExec::Exec '$AppDirectory\IcarTest_xampp\apache\bin\apache -k uninstall'
			Banner::destroy
		${EndIf}
	${EndIf}

	${IfNot} $MySQLService_Exist == true
		${registry::KeyExists} "HKLM\SYSTEM\CurrentControlSet\services\mysql" $R0
		${If} $R0 = 0
			Banner::show /set 76 "Моля, изчакайте," "спира се MySQL услугата..."
			nsExec::Exec 'net stop MySQL'
			nsExec::Exec '$AppDirectory\IcarTest_xampp\mysql\bin\mysqld --remove mysql'
			Banner::destroy
		${EndIf}
	${EndIf}

	${IfNot} $MaperDLL_Exist == true
		${registry::KeyExists} "HKLM\Software\Classes\AppID\Maper.DLL" $R0
		${If} $R0 = 0
			Banner::show /set 76 "Моля, изчакайте," "отменя се Maper.dll..."
			nsExec::Exec 'regsvr32 /s /u "$AppDirectory\IcarTest_xampp\IcarTest\Maper.dll"'
			Banner::destroy
		${EndIf}
	${EndIf}

	Banner::show /set 76 "Моля, изчакайте, IcarTest Portable" "възстановява файловете..."

	ExpandEnvStrings $1 "%PAL:AppDir%\IcarTest_xampp"

	Delete "$1\mysql\bin\my.cnf"
	Delete "$1\apache\bin\php.ini"
	Delete "$1\apache\conf\httpd.conf"
	Delete "$1\apache\conf\extra\httpd-ssl.conf"
	Delete "$1\apache\conf\extra\httpd-xampp.conf"

	Rename "$1\mysql\bin\my.cnf.bak" "$1\mysql\bin\my.cnf"
	Rename "$1\apache\bin\php.ini.bak" "$1\apache\bin\php.ini"
	Rename "$1\apache\conf\httpd.conf.bak" "$1\apache\conf\httpd.conf"
	Rename "$1\apache\conf\extra\httpd-ssl.conf.bak" "$1\apache\conf\extra\httpd-ssl.conf"
	Rename "$1\apache\conf\extra\httpd-xampp.conf.bak" "$1\apache\conf\extra\httpd-xampp.conf"
	
	Sleep 1000
	Banner::destroy

!macroend