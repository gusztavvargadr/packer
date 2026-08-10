var target = Argument("target", "default");

Task("init")
  .Does(() => {
    RunVersionCommand(IsRunningOnWindows() ? "tar" : "bsdtar");
    RunVersionCommand("pigz");
  });

Task("test")
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
