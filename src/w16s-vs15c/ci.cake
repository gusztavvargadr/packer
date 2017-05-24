#load "../core/cake/core.cake"

var target = Argument("target", "default");
var configuration = Argument("configuration", string.Empty);

packerImage = PackerImage_Create(
  "w16s-vs15c",
  "../..",
  new [] {
    PackerTemplate_Create(
      "virtualbox-ovf",
      new [] { PackerBuilder_Create("virtualbox-ovf") },
      new [] { PackerProvisioner_Create("chef") },
      new PackerPostProcessor[] {},
      "w16s",
      "virtualbox-ovf"
    ),
    PackerTemplate_Create(
      "virtualbox-vagrant",
      new [] { PackerBuilder_Create("virtualbox-ovf") },
      new [] { PackerProvisioner_Create("sysprep") },
      new [] { PackerPostProcessor_Create("vagrant-virtualbox") },
      "w16s-vs15c",
      "virtualbox-ovf"
    ),
    PackerTemplate_Create(
      "hyperv-vagrant",
      new [] { PackerBuilder_Create("hyperv-iso") },
      new [] { PackerProvisioner_Create("chef"), PackerProvisioner_Create("sysprep") },
      new [] { PackerPostProcessor_Create("vagrant-hyperv") },
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
