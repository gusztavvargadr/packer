var target = Argument("target", "default");

var rootDirectory = Argument("rootDirectory", "../..");
var name = Argument("name", string.Empty);
var description = Argument("description", string.Empty);
var output = Argument("output", "virtualbox");

var components = new List<string>();
var parent = string.Empty;

Func<string> buildDirectory = () => rootDirectory + "/build/" + name + "/" + output;
Func<string> artifactsDirectory = () => rootDirectory + "/artifacts/" + name + "/" + output;

Task("default")
  .IsDependentOn("packer-build");

Task("clean")
  .IsDependentOn("clean-build")
  .IsDependentOn("clean-artifacts");

Task("clean-build")
  .Does(() => {
    CleanDirectories(buildDirectory());
  });

Task("clean-artifacts")
  .Does(() => {
    CleanDirectories(artifactsDirectory());
  });

Task("create-build")
  .Does(() => {
    CreateDirectory(buildDirectory());

    foreach (var component in components) {
      foreach (var directory in GetDirectories(rootDirectory + "/lib/packer/*")) {
        var directoryName = directory.GetDirectoryName();
        if (!component.Contains(directoryName)) {
          continue;
        }

        CopyFiles(rootDirectory + "/lib/packer/" + directoryName + "/" + output + "/**/*", buildDirectory(), true);
      }
    }
  });

Task("berks-package")
  .IsDependentOn("create-build")
  .Does(() => {
    if (GetFiles(buildDirectory() + "/Berksfile").Any()) {
      CreateDirectory(buildDirectory() + "/floppy_files");
      Berks("package floppy_files/cookbooks.tar.gz");
    }
  });

Task("packer-validate")
  .IsDependentOn("berks-package")
  .Does(() => {
    Packer("validate");    
  });

Task("packer-build")
  .WithCriteria(() => !GetFiles(artifactsDirectory() + "/*").Any())
  .IsDependentOn("packer-validate")
  .Does(() => {
    Packer("build");
  });

void Berks(string arguments) {
  int result = StartProcess("C:/opscode/chefdk/bin/berks.bat", new ProcessSettings {
    Arguments = arguments,
    WorkingDirectory = buildDirectory()
  });
  if (result != 0) {
    throw new Exception("Process exited with code " + result + ".");
  }
}

void Packer(string command) {
    var packerVarFiles = GetFiles(buildDirectory() + "/variables*.json").Select(item => item.ToString()).ToList();

    var sourcePath = output == "virtualbox"
      ? !string.IsNullOrEmpty(parent)
        ? GetFiles(rootDirectory + "/artifacts/" + parent + "/virtualbox/*.ovf").Single().ToString()
        : string.Empty
      : GetFiles(rootDirectory + "/artifacts/" + name + "/virtualbox/*.ovf").Single().ToString();
    var outputDirectory = MakeAbsolute(Directory(buildDirectory())).GetRelativePath(MakeAbsolute(Directory(artifactsDirectory()))).ToString();
    var packerVars = new Dictionary<string, string> {
      { "name", name },
      { "description", description },
      { "source_path", sourcePath },
      { "output_directory", outputDirectory }
    };

    Packer(command, "template.json", packerVarFiles, packerVars);
}

void Packer(string command, string template, List<string> varFiles, Dictionary<string, string> vars) {
  var options =
    string.Join(" ", varFiles.Select(item => "-var-file=\"" + item + "\"")) +
    " " +
    string.Join(" ", vars.Select(item => "-var \"" + item.Key + "=" + item.Value + "\""));
  int result = StartProcess("packer", new ProcessSettings {
    Arguments = command + " " + options + " " + template,
    WorkingDirectory = buildDirectory()
  });
  if (result != 0) {
    throw new Exception("Process exited with code " + result + ".");
  }
}