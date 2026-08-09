var target = Argument("target", "default");

Task("test")
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
