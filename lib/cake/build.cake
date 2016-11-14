var target = Argument("target", "default");

Task("clean")
  .Does(() => {
    DeleteFiles("Berksfile.lock");
    CleanDirectories("build");
  });

Task("berks-package")
  .Does(() => {
    CreateDirectory("build/chef");
    StartProcess("C:/opscode/chefdk/bin/berks.bat", new ProcessSettings {
      Arguments = "package build/chef/cookbooks.tar.gz",
      WorkingDirectory = "."
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
