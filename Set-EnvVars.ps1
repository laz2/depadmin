
$envKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"

$envbind = @(
	@('TOOLS_DIR',    'c:\tools'),
	@('JAVA_HOME',    '%PROGRAMFILES%\Java\jdk1.6.0_29'),
	@('SC_CORE_HOME', '%TOOLS_DIR%\sc-core'),
	@('PATH', @(
		'%PROGRAMFILES%\NVIDIA Corporation\PhysX\Common'
		'%TOOLS_DIR%\apache-ant\bin',
		'%TOOLS_DIR%\Python26',
		'%TOOLS_DIR%\Python26\Scripts',
		'%TOOLS_DIR%\Python26\Tools\Scripts',
		'%TOOLS_DIR%\Python26\Lib\site-packages\PyQt4',
		'%TOOLS_DIR%\gtkmm\bin',
		'C:\WINDOWS\system32',
		'C:\WINDOWS',
		'C:\WINDOWS\System32\Wbem',
		'%PROGRAMFILES%\doxygen\bin',
		'%PROGRAMFILES%\Microsoft SQL Server\90\Tools\binn\',
		'C:\WINDOWS\system32\WindowsPowerShell\v1.0',
		'%PROGRAMFILES%\CMake\bin',
		'%PROGRAMFILES%\MATLAB\R2011b\runtime\win32',
		'%PROGRAMFILES%\MATLAB\R2011b\bin',
		'%SC_CORE_HOME%\bin',
		'%TOOLS_DIR%\QtSDK\mingw\bin'
	))
)

ForEach ($bind in $envbind)
{
	$name = $bind[0]
	$newMachineValue = $bind[1]

	if ($newMachineValue -is [array])
	{
		$result = ""
		
		ForEach ($comp in $newMachineValue)
		{
			$result += $comp
			$result += ';'
		}

		$newMachineValue = $result.Substring(0, $result.Length - 1)
	}

	$curMachineValue = [environment]::GetEnvironmentVariable($name, "Machine")
	Write-Host "Variable $name:"
	Write-Host "`tCur: $curMachineValue"
	Write-Host "`tNew: $newMachineValue"

	Remove-ItemProperty $envKeyPath -Name $name
	New-ItemProperty $envKeyPath -Name $name -Value $newMachineValue -PropertyType ExpandString | Out-Null
}
