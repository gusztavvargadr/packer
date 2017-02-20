#load "./lib/cake/configurations.cake"

// todo: rename to ci?
// todo: targets: version, test, docs, publish
// todo: w16, containers
// todo: ami, hyperv, vmware
// todo: sysprep on desktop
// todo: all bat to cmd
// todo: review issues on GitHub (both Vagrant and Packer)
// todo: review and refactor included scripts and other resources
// todo: update iso sources
// todo: yaml load
// todo: check which configs to continue
// tood: build parent if missing
// todo: build / package remove from template (configure from script)
// todo: all vars to save to json (make build folder work standalone)

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
