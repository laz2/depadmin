
$studentRoot = "d:\"
$teacherRoot = "e:\"

# Количество групп по 1-5 курсам
$groupsForCourses = 4, 4, 3, 4, 3

$groupDirs = @()

# $curs есть 0 для первого курса
Function Get-CourseGroupPrefix([int]$curs)
{
	$f = ((Get-Date).Year % 10) - $curs
	
	if ($f -lt 0)
	{
		$f = 10 + $f
	}
	
	return "" + $f + "2170"
}

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

Function Clear-Acl($acl)
{
	$rule = Create-FsRule "Allow" "Все" "FullControl" "ObjectInherit,ContainerInherit" "None"
	$acl.RemoveAccessRuleAll($rule)

	$rule = Create-FsRule "Allow" "Users" "FullControl" "ObjectInherit,ContainerInherit" "None"
	$acl.RemoveAccessRuleAll($rule)

	$rule = Create-FsRule "Allow" "students" "FullControl" "ObjectInherit,ContainerInherit" "None"
	$acl.RemoveAccessRuleAll($rule)

	$rule = Create-FsRule "Allow" "iit\Teachers" "FullControl" "ObjectInherit,ContainerInherit" "None"
	$acl.RemoveAccessRuleAll($rule)
}

Function Set-StudentRootAcl($root)
{
	$acl = Get-Acl $root

	Clear-Acl $acl

	Add-FsRule $acl "Allow" "students" "Read,ReadAndExecute,ListDirectory" "ObjectInherit,ContainerInherit" "None"
	Add-FsRule $acl "Allow" "iit\Teachers" "Read,ReadAndExecute,ListDirectory" "ObjectInherit,ContainerInherit" "None"

	Add-FsRule $acl "Allow" "SYSTEM" "FullControl" "ObjectInherit,ContainerInherit" "None"
	Add-FsRule $acl "Allow" "Administrators" "FullControl" "ObjectInherit,ContainerInherit" "None"

	Set-Acl $root $acl
}

Function Set-StudentsGroupDirAcl($dir)
{
	$acl = Get-Acl $dir

	Add-FsRule $acl "Allow" "iit\Teachers" "Modify" "ObjectInherit,ContainerInherit" "None"
	Add-FsRule $acl "Allow" "students"     "Modify" "ObjectInherit,ContainerInherit" "None"

	Add-FsRule $acl "Deny" "iit\Teachers" "Delete" "None" "None"
	Add-FsRule $acl "Deny" "students"     "Delete" "None" "None"

	Set-Acl $dir $acl
}

Function Set-TeacherRootAcl($path)
{
	$acl = Get-Acl $path

	Clear-Acl $acl

	Add-FsRule $acl "Allow" "SYSTEM"         "FullControl" "ObjectInherit,ContainerInherit" "None"
	Add-FsRule $acl "Allow" "Administrators" "FullControl" "ObjectInherit,ContainerInherit" "None"
	Add-FsRule $acl "Allow" "iit\Teachers"   "Modify"      "ObjectInherit,ContainerInherit" "None"

	Set-Acl $path $acl
}

# Установим права доступа для студенческого диска
Set-StudentRootAcl $studentRoot

# Очистим студенческий диск
Write-Host "Clean students root '$studentRoot' ..."
Remove-Item -Recurse -Force -Path "$studentRoot\*" -ErrorAction SilentlyContinue
Copy-Item "Прочитай и запомни, дорогой Студент.txt" $studentRoot

# Создадим директории для групп и для каждой установим права доступа
for ($curs = 0; $curs -lt 5; ++$curs)
{
	$prefix = Get-CourseGroupPrefix $curs

	$count = $groupsForCourses[$curs]
	while ($count -gt 0)
	{
		$path = Join-Path $studentRoot ($prefix + $count)

		Write-Host "Create and init group directory '$path'."

		$item = New-Item -Type Directory -Path $path -Force
		Set-StudentsGroupDirAcl $item
		--$count;
	}
}

Write-Host "Create and init downloads directory."
$downloadsDir = New-Item -Type Directory -Path "d:\downloads" -Force
Set-StudentsGroupDirAcl "d:\downloads"

# Установим права для преподавательского диска
if (Test-Path $teacherRoot)
{
	Set-TeacherRootAcl $teacherRoot
}
else
{
	Write-Warning "Cann't configure teacher root '$teacherRoot', because it doesn't exist."
}
