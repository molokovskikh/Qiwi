[Reflection.Assembly]::LoadFile("C:\Program Files (x86)\Common Files\Microsoft Shared\MSEnv\PublicAssemblies\envdte.dll");
$dte=[Activator]::CreateInstance([Type]::GetTypeFromProgID("VisualStudio.DTE.11.0"));  
$solution= $dte.Solution;
$solution.Create("c:\temp", "test");



$project=$solution.AddFromFile("C:\Users\Сергей\documents\visual studio 2012\Projects\MvcApplication1\MvcApplication1\MvcApplication1.csproj");

$remfile=$project.Properties|where { ($_.Name -eq "Project Folder" -or $_.Name -eq "ProjectFolder" -or $_.Name -eq "FullPath" -or $_.Name -eq "LocalPath") -and $_.Value -NE $NULL }|Select-Object Value -first 1|ForEach-Object { $_.Value};
if($remfile)
{
	write-output $remfile;
}

$globalAsax = $project.ProjectItems |  ForEach-Object { $_.ProjectItems } | where { $_.Name -eq "Global.asax.cs" }
if($globalAsax) {
$cf=$globalAsax.FileCodeModel.CodeElements | where { $_.Kind -eq 5} |  ForEach-Object { $_.Children} | where { $_.Kind -eq 1 -and ($_.Bases|ForEach-Object { $_.FullName}) -contains "System.Web.HttpApplication"} |  ForEach-Object { $_.Children } | where { $_.Kind -eq 2 -and $_.Name -eq "Application_Start"}
if($cf)
{ 
  # write-output $cf.Name;
   [string] $code = "QiwiShop.Qiwi.Start()";
   $sp= $cf.GetStartPoint(16).CreateEditPoint();
   $ep= $cf.GetEndPoint(16).CreateEditPoint();
   [string] $test=$sp.GetText($ep);
   if(!$test.Contains($code))
   {
     write-output $test;
     $ep.Insert("`r`n"+[string]::Empty.PadRight($sp.LineCharOffset,' ')+$code+";`r`n");
     $globalAsax.Save();
   }
   else
   {	  
	  $sp.ReplaceText($ep,[System.Text.RegularExpressions.Regex]::Replace($test, $code.Replace("(", "\(").Replace(")", "\)") + "\s*;", ""), 8);
	  $globalAsax.Save();	  
   }
} 
}

$solution.Close();
$dte.Quit();