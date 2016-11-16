#load ../../lib/cake/build.cake

packerVarFiles = new List<string> { "../../lib/packer/windows/variables.json", "../../lib/packer/windows10/variables.json", "variables.json" };

Task("default")
  .IsDependentOn("packer-build");

RunTarget(target);
