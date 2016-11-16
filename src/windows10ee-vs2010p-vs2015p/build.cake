#load ../../lib/cake/build.cake

packerVarFiles = new List<string> { "../../lib/packer/windows/variables.json", "../../lib/packer/windows10/variables.json", "variables.json" };
var ovf = GetFiles("../../src/windows10ee-vs2010p/build/virtualbox/*.ovf").Single().ToString();
packerVars = new Dictionary<string, string> { { "source_path", ovf } };

Task("default")
  .IsDependentOn("packer-build");

RunTarget(target);
