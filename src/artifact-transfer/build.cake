var target = Argument("target", "default");

Task("init")
  .Description("Validate the platform libarchive tar and pigz versions.")
  .Does(() => {
    RunVersionCommand(IsRunningOnWindows() || IsRunningOnMacOs() ? "tar" : "bsdtar");
    RunVersionCommand("pigz");
  });

Task("test")
  .Description("Validate archive tools and test Vagrant box preparation, restoration, and checksums.")
  .IsDependentOn("init")
  .Does(() => {
    var arguments = new ProcessArgumentBuilder();
    arguments.AppendQuoted("vagrant_box_test.rb");

    var result = StartProcess("ruby", new ProcessSettings {
      Arguments = arguments,
      WorkingDirectory = Directory(".")
    });

    if (result != 0) {
      throw new Exception($"Artifact transfer tests failed with code {result}.");
    }
  });

Task("default")
  .Description("Run the artifact-transfer validation and Vagrant box tests.")
  .IsDependentOn("test");

RunTarget(target);

void RunVersionCommand(string executable) {
  var arguments = new ProcessArgumentBuilder();
  arguments.Append("--version");

  var result = StartProcess(executable, new ProcessSettings {
    Arguments = arguments
  });

  if (result != 0) {
    throw new Exception($"{executable} version validation failed with code {result}.");
  }
}
