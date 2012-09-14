
$xxmklink = ".\xxmklink.exe"
$permanentPatterns = @( "Программы", "Programs" )

function CreateLink($path, $target, $linkArgs, $workingPath)
{
	$linkArgs = '"' + $linkArgs + '"'
	Write-Host "$xxmklink /q $path $target $linkArgs $workingPath"
	& $xxmklink /q $path $target $linkArgs $workingPath
}

function ProcessFolderNode($parentPath, $folder)
{
	# Определить путь к папке
	if ($folder.HasAttribute("path"))
	{
		$path = $folder.path
	}
	else
	{
		if ($folder.HasAttribute("name"))
		{
			$path = Join-Path -Path $parentPath -ChildPath $folder.name
		}
		else
		{
			Write-Error "Folder tag doesn't has attributes 'path' or 'name'."
			exit
		}
	}
	
	# Создать папку, если ее не существует
	if (!(Test-Path $path))
	{
		New-Item -ItemType Directory $path | Out-Null
	}
	
	# Обработать все элементы из конфигурационного файла, которые должны быть в папке
	foreach ($child in $folder.GetEnumerator())
	{
		if ($child.LocalName -eq "link")
		{
			$linkPath = Join-Path -Path $path -ChildPath $child.name
			$targetPath = $child.target

			$workingFolder = $child.Item("workingFolder")
			if ($workingFolder)
			{
				$workingFolder = $workingFolder."#text"
			}
			else
			{
				$workingFolder = Split-Path $targetPath
			}

			$linkArgs = $child.Item("args")
			if ($linkArgs)
			{
				$linkArgs = $linkArgs."#text"
			}

			CreateLink $linkPath $targetPath $linkArgs $workingFolder
		}
		elseif ($child.LocalName -eq "folder")
		{
			ProcessFolderNode $path $child
		}
		else
		{
			Write-Error "Unknown node with name '$child.LocalName'."
			exit
		}
	}
}

$data = [xml](Get-Content ".\links.xml")
foreach ($folder in $data.root.folder)
{
	$path = $folder.path

	if ($folder.clean -eq "true")
	{
		Remove-Item "$path\*" -Exclude $permanentPatterns -Force -Recurse
	}

	ProcessFolderNode "." $folder
}
