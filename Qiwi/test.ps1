$dte=[Activator]::CreateInstance([Type]::GetTypeFromProgID("VisualStudio.DTE.11.0"));
$solution= $dte.Solution;
$solution.Create("c:\temp", "test");

$project=$solution.AddFromFile("c:\Users\mlh\Documents\Visual Studio 2012\Projects\QiwiShop\MvcQiwi\MvcQiwi.csproj");
$globalAsax = $project.ProjectItems |  ForEach-Object { $_.ProjectItems } | where { $_.Name -eq "Global.asax.cs" }
if($globalAsax) {
$cf=$globalAsax.FileCodeModel.CodeElements | where { $_.Kind -eq 5} |  ForEach-Object { $_.Children} | where { $_.Kind -eq 1 -and ($_.Bases|ForEach-Object { $_.FullName}) -contains "System.Web.HttpApplication"} |  ForEach-Object { $_.Children } | where { $_.Kind -eq 2 -and $_.Name -eq "Application_Start"}
if($cf)
{ 
   write-output $cf.Name;
   $code = "QiwiShop.Qiwi.Init()";
   $sp= $cf.GetStartPoint(16).CreateEditPoint();
   $ep= $cf.GetEndPoint(16).CreateEditPoint();
   $test=$sp.GetText($ep);
   if(!$test.Contains($code))
   {
   write-output $test;
     $ep.Insert("`r`n"+[string]::Empty.PadRight($sp.LineCharOffset,' ')+$code+";`r`n"); 
     $globalAsax.Save();
   }
} 
}
$solution.Close();
$dte.Quit();