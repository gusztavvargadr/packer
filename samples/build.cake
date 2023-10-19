var target = Argument("target", "default");
var configuration = Argument("configuration", string.Empty);
var recursive = Argument("recursive", false);
var version = "2310v2";

Task("info")
  .Does(() => {
    Information($"Test for {version}.");
  });

Task("default")
  .IsDependentOn("info");

RunTarget(target);
