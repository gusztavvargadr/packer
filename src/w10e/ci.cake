#load "../core/cake/core.cake"

var target = Argument("target", "default");
var configuration = Argument("configuration", string.Empty);

packerImage = PackerImage_Create(
  "w10e",
  "../..",
  new [] {
    PackerTemplate_Create(
      "virtualbox-ovf",
      new [] { PackerBuilder_Create("virtualbox-iso") },
      new [] { PackerProvisioner_Create("chef") },
      new PackerPostProcessor[] {},
      string.Empty,
      string.Empty
    ),
    PackerTemplate_Create(
      "virtualbox-vagrant",
      new [] { PackerBuilder_Create("virtualbox-ovf") },
      new [] { PackerProvisioner_Create("sysprep") },
      new [] { PackerPostProcessor_Create("vagrant") },
      "w10e",
      "virtualbox-ovf"
    ),
    PackerTemplate_Create(
      "hyperv-vagrant",
      new [] { PackerBuilder_Create("hyperv-iso") },
      new [] { PackerProvisioner_Create("chef"), PackerProvisioner_Create("sysprep") },
      new [] { PackerPostProcessor_Create("vagrant") },
      string.Empty,
      string.Empty
    )
  }
);
packerTemplate = configuration;

Task("default")
  .IsDependentOn("info");

Task("info")
  .IsDependentOn("packer-info");

Task("clean")
  .IsDependentOn("packer-clean");

Task("version")
  .IsDependentOn("packer-version");

Task("restore")
  .IsDependentOn("packer-restore");

Task("build")
  .IsDependentOn("packer-build");

Task("test")
  .IsDependentOn("packer-test");

Task("package")
  .IsDependentOn("packer-package");

Task("publish")
  .IsDependentOn("packer-publish");

RunTarget(target);
