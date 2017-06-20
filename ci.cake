#load "src/core/cake/core.cake"

var target = Argument("target", "default");
var configuration = Argument("configuration", string.Empty);

var w10e = PackerTemplates_Create("w10e");
var w16s = PackerTemplates_Create("w16s");
var w16s_iis = PackerTemplates_Create("w16s-iis", w16s.First());
var w16s_sql14d = PackerTemplates_Create("w16s-sql14d", w16s.First());
var w16s_vs17c = PackerTemplates_Create("w16s-vs17c", w16s.First());
var w16s_vs17p = PackerTemplates_Create("w16s-vs17p", w16s.First());

packerTemplates = new List<PackerTemplate>();
packerTemplates = packerTemplates.Concat(w10e).ToList();
packerTemplates = packerTemplates.Concat(w16s).Concat(w16s_iis).Concat(w16s_sql14d).Concat(w16s_vs17c).Concat(w16s_vs17p).ToList();
packerTemplate = configuration;

IEnumerable<PackerTemplate> PackerTemplates_Create(string type, PackerTemplate parent = null) {
  var virtualBoxBase = PackerTemplate_Create(
    type,
    "virtualbox-base",
    new [] { PackerBuilder_Create(parent == null ? "virtualbox-iso" : "virtualbox-ovf") },
    new [] { PackerProvisioner_Create("chef") },
    new PackerPostProcessor[] {},
    parent
  );
  var virtualBoxSysprep = PackerTemplate_Create(
    type,
    "virtualbox-sysprep",
    new [] { PackerBuilder_Create("virtualbox-ovf") },
    new [] { PackerProvisioner_Create("sysprep") },
    new [] { PackerPostProcessor_Create("vagrant-virtualbox") },
    virtualBoxBase
  );
  var hyperVSysprep = PackerTemplate_Create(
    type,
    "hyperv-sysprep",
    new [] { PackerBuilder_Create("hyperv-iso") },
    new [] { PackerProvisioner_Create("chef"), PackerProvisioner_Create("sysprep") },
    new [] { PackerPostProcessor_Create("vagrant-hyperv") },
    null
  );
  var amazonSysprep = PackerTemplate_Create(
    type,
    "amazon-sysprep",
    new [] { PackerBuilder_Create("amazon-ebs") },
    new [] { PackerProvisioner_Create("chef"), PackerProvisioner_Create("amazon-shutdown") },
    new PackerPostProcessor[] {},
    null
  );

  return new [] {
    virtualBoxBase,
    virtualBoxSysprep,
    hyperVSysprep,
    amazonSysprep
  };
}

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

Task("rebuild")
  .IsDependentOn("packer-rebuild");

Task("test")
  .IsDependentOn("packer-test");

Task("package")
  .IsDependentOn("packer-package");

Task("publish")
  .IsDependentOn("packer-publish");

RunTarget(target);
