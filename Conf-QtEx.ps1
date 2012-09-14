
# 
# $h = @{}
# Get-Childitem $env:TOOLS_DIR\QtSDK\Examples\4.7\* -Recurse | ForEach { if (-not $_.PSIsContainer) { $h[$_.Extension] = $_.Extension } }

$examplesRoot = Get-Item $env:TOOLS_DIR\QtSDK\Examples\4.7\

$fileExtensions = @(
	"*.desktop", "*.vsh", "*.qhp", "*.txt", "*.gitattributes", "*.xsl", "*.xpm", "*.rc", "*.svg", "*.qhcp", "*.gccxml",
	"*.js", "*.htm", "*.xsd", "*.c", "*.ttf", "*.jpg", "*.pov", "*.inf", "*.qhc", "*.qm", "*.ics", "*.wml", "*.dat", "*.ui",
	"*.doc", "*.php", "*.qch", "*.qss", "*.qrc", "*.resx", "*.glsl", "*.css", "*.pro", "*.vb", "*.sci", "*.xbel",
	"*.ini", "*.vcproj", "*.qml", "*.fsh", "*.xq", "*.qmlproject", "*.png", "*.cpp", "*.wav", "*.cht", "*.sln",
	"*.csproj", "*.cs", "*.html", "*.pri", "*.xml", "*.service", "*.ts", "*.vcf", "*.mng", "*.h", "*.vbproj"
)

Function Create-FsRule([string]$type, [string]$account, [string]$access, [string]$inheritance, [string]$propagation)
{
	$_account     = [System.Security.Principal.NTAccount]$account
	$_access      = [System.Security.AccessControl.FileSystemRights]$access
	$_inheritance = [System.Security.AccessControl.InheritanceFlags]$inheritance
	$_propagation = [System.Security.AccessControl.PropagationFlags]$propagation
	$_type        = [System.Security.AccessControl.AccessControlType]$type

	$rule = New-Object System.Security.AccessControl.FileSystemAccessRule( `
		$_account, $_access, $_inheritance, $_propagation, $_type)

	return $rule
}

Function Add-FsRule($acl, [string]$type, [string]$account, [string]$access, [string]$inheritanceFlags, [string]$propagationFlags)
{
	$rule = Create-FsRule $type $account $access $inheritanceFlags $propagationFlags
	$acl.addAccessRule($rule)
}

ForEach ($file in (Get-Childitem $env:TOOLS_DIR\QtSDK\Examples\4.7\* -Recurse -Include $fileExtensions))
{
	Write-Host $file.Name
}
