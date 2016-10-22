var target = Argument("target", "default");

Task("clean")
  .Does(() => {
    DeleteFile("chef/Berksfile.lock");
    CleanDirectories("chef/.berkshelf");
    CleanDirectories("output*");
    DeleteFiles("*.box");
  });

Task("berks-package")
  .Does(() => {
    StartProcess("C:/opscode/chefdk/bin/berks.bat", new ProcessSettings {
      Arguments = "package .berkshelf/cookbooks.tar.gz",
      WorkingDirectory = "chef"
    });
  });

Task("packer-validate")
  .IsDependentOn("berks-package")
  .Does(() => {
    StartProcess("packer", "validate template.json");
  });

Task("packer-build")
  .IsDependentOn("clean")
  .IsDependentOn("packer-validate")
  .Does(() => {
    StartProcess("packer", "build template.json");
  });
