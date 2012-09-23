
$a = Get-ChildItem .\tmp\test\*.zip | Sort-Object LastWriteTime

$i = 0
foreach ($o in $a)
{
	if ($i -eq 3)
	{
		Remove-Item $o
	}
	else
	{
		++$i
	}
}