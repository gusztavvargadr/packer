var target = Argument("target", "default");

var packerTemplate = Argument("packer-template", "template.json");
var packerVarFiles = new List<string>();
var packerVars = new Dictionary<string, string>();

Task("clean")
  .Does(() => {
    DeleteFiles("Berksfile.lock");
    CleanDirectories("build");
  });

Task("berks-package")
  .Does(() => {
    CreateDirectory("build/chef");
    Berks("package build/chef/cookbooks.tar.gz");
  });

Task("packer-validate")
  .IsDependentOn("berks-package")
  .Does(() => {
    Packer("validate", packerTemplate, packerVars, packerVarFiles);
  });

Task("packer-build")
  .IsDependentOn("packer-validate")
  .Does(() => {
    Packer("build", packerTemplate, packerVars, packerVarFiles);
  });

void Berks(string arguments) {
  int result = StartProcess("C:/opscode/chefdk/bin/berks.bat", new ProcessSettings {
    Arguments = arguments,
    WorkingDirectory = "."
  });
  if (result != 0) {
    throw new Exception("Process exited with code " + result + ".");
  }
}

void Packer(string command, string template, Dictionary<string, string> vars, List<string> varFiles) {
  var options =
    string.Join(" ", varFiles.Select(item => "-var-file=\"" + item + "\"")) +
    " " +
    string.Join(" ", vars.Select(item => "-var \"" + item.Key + "=" + item.Value + "\""));
  int result = StartProcess("packer", new ProcessSettings {
    Arguments = command + " " + options + " " + template,
    WorkingDirectory = "."
  });
  if (result != 0) {
    throw new Exception("Process exited with code " + result + ".");
  }
}