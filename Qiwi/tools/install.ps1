# Runs every time a package is installed in a project

param($installPath, $toolsPath, $package, $project)

# $installPath is the path to the folder where the package is installed.
# $toolsPath is the path to the tools directory in the folder where the package is installed.
# $package is a reference to the package object.
# $project is a reference to the project the package was installed to.

$src=$installPath+"\content\App_Start";
$dst=$project.Properties|where { ($_.Name -eq "Project Folder" -or $_.Name -eq "ProjectFolder" -or $_.Name -eq "FullPath" -or $_.Name -eq "LocalPath") -and $_.Value -NE $NULL }|Select-Object Value -first 1|ForEach-Object { $_.Value};
#$dst=($project.Properties|where { $_.Name -eq "ProjectFolder"}|ForEach-Object { $_.Value});
Copy-Item $src -destination $dst -recurse

$globalAsax = $project.ProjectItems |  ForEach-Object { $_.ProjectItems } | where { $_.Name -eq "Global.asax.cs" }
if($globalAsax) {
$cf=$globalAsax.FileCodeModel.CodeElements | where { $_.Kind -eq 5} |  ForEach-Object { $_.Children} | where { $_.Kind -eq 1 -and ($_.Bases|ForEach-Object { $_.FullName}) -contains "System.Web.HttpApplication"} |  ForEach-Object { $_.Children } | where { $_.Kind -eq 2 -and $_.Name -eq "Application_Start"}
if($cf)
{    
   $code = "QiwiShop.Qiwi.Start()";
   $sp= $cf.GetStartPoint(16).CreateEditPoint();
   $ep= $cf.GetEndPoint(16).CreateEditPoint();
   $test=$sp.GetText($ep);
   if(!$test.Contains($code))
   {    
     $ep.Insert("`r`n"+[string]::Empty.PadRight($sp.LineCharOffset,' ')+$code+";`r`n");
     $globalAsax.Save();
   }  
} 
}
else
{
	$globalAsax = $project.ProjectItems |  ForEach-Object { $_.ProjectItems } | where { $_.Name -eq "Global.asax.vb" }
	if($globalAsax) {
		$cf=$globalAsax.FileCodeModel.CodeElements | where { $_.Kind -eq 5} |  ForEach-Object { $_.Children} | where { $_.Kind -eq 1 -and ($_.Bases|ForEach-Object { $_.FullName}) -contains "System.Web.HttpApplication"} |  ForEach-Object { $_.Children } | where { $_.Kind -eq 2 -and $_.Name -eq "Application_Start"}
		if($cf)
		{    
			$code = "QiwiShop.Qiwi.Start()";
			$sp= $cf.GetStartPoint(16).CreateEditPoint();
			$ep= $cf.GetEndPoint(16).CreateEditPoint();
			$test=$sp.GetText($ep);
			if(!$test.Contains($code))
			{    
				$ep.Insert("`r`n"+[string]::Empty.PadRight($sp.LineCharOffset,' ')+$code+";`r`n");
				$globalAsax.Save();
			}  
		} 
					}
}
