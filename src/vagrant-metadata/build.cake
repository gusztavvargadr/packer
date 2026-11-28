var target = Argument("target", "default");

Task("test")
  .Description("Test Vagrant metadata merging and conditional publication against a fake store.")
  .Does(() => {
    var arguments = new ProcessArgumentBuilder();
    arguments.AppendQuoted("vagrant_metadata_test.rb");

    var result = StartProcess("ruby", new ProcessSettings {
      Arguments = arguments,
      WorkingDirectory = Directory(".")
    });

    if (result != 0) {
      throw new Exception($"Vagrant metadata tests failed with code {result}.");
    }
  });

Task("default")
  .Description("Run the Vagrant metadata tests.")
  .IsDependentOn("test");

RunTarget(target);
