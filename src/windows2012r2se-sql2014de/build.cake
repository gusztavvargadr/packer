#load ../../lib/cake/build.cake

packerVarFiles = new List<string> { "../../lib/packer/windows/variables.json", "../../lib/packer/windows2012r2/variables.json", "variables.json" };
var ovf = GetFiles("../../src/windows2012r2se/build/virtualbox/*.ovf").Single().ToString();
packerVars = new Dictionary<string, string> { { "source_path", ovf } };

Task("default")
  .IsDependentOn("packer-build");

RunTarget(target);
