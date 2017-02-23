#load "./lib/cake/configurations.cake"

var target = Argument("Target", "Default");

Task("Info")
  .IsDependentOn("Configurations_Info");

Task("Clean")
  .IsDependentOn("Configurations_Clean");

Task("Restore")
  .IsDependentOn("Configurations_Restore");

Task("Build")
  .IsDependentOn("Configurations_Build");

Task("Test")
  .IsDependentOn("Configurations_Test");

Task("Package")
  .IsDependentOn("Configurations_Package");

Task("Default")
  .IsDependentOn("Info");

RunTarget(target);
