#load "src/core/cake/core.cake"

var target = Argument("target", "default");
var configuration = Argument("configuration", string.Empty);
var recursive = Argument("recursive", false);

packerTemplates = new List<PackerTemplate>();

var w10e = PackerTemplates_Create("w10e");
var w10e_dc = PackerTemplates_Create("w10e-dc", parent: w10e.First());

packerTemplates = packerTemplates.
  Concat(w10e).
  Concat(w10e_dc).
  ToList();

var w16s = PackerTemplates_Create("w16s", amazon: true);
var w16s_dc = PackerTemplates_Create("w16s-dc", amazon: true, parent: w16s.First());
var w16s_iis = PackerTemplates_Create("w16s-iis", amazon: true, parent: w16s.First());
var w16s_sql14x = PackerTemplates_Create("w16s-sql14x", amazon: true, parent: w16s.First());
var w16s_sql14d = PackerTemplates_Create("w16s-sql14d", amazon: true, parent: w16s.First());
var w16s_vs10p = PackerTemplates_Create("w16s-vs10p", parent: w16s.First());
var w16s_vs15c = PackerTemplates_Create("w16s-vs15c", parent: w16s.First());
var w16s_vs15p = PackerTemplates_Create("w16s-vs15p", parent: w16s.First());
var w16s_vs17c = PackerTemplates_Create("w16s-vs17c", parent: w16s.First());
var w16s_vs17p = PackerTemplates_Create("w16s-vs17p", parent: w16s.First());

packerTemplates = packerTemplates.
  Concat(w16s).
  Concat(w16s_dc).
  Concat(w16s_iis).
  Concat(w16s_sql14x).
  Concat(w16s_sql14d).
  Concat(w16s_vs10p).
  Concat(w16s_vs15c).
  Concat(w16s_vs15p).
  Concat(w16s_vs17c).
  Concat(w16s_vs17p).
  ToList();

packerTemplate = configuration;
packerRecursive = recursive;

IEnumerable<PackerTemplate> PackerTemplates_Create(string type, bool amazon = false, PackerTemplate parent = null) {
  var items = new List<PackerTemplate>();

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
  items.Add(virtualBoxBase);
  items.Add(virtualBoxSysprep);

  var hyperVSysprep = PackerTemplate_Create(
    type,
    "hyperv-sysprep",
    new [] { PackerBuilder_Create("hyperv-iso") },
    new [] { PackerProvisioner_Create("chef"), PackerProvisioner_Create("sysprep") },
    new [] { PackerPostProcessor_Create("vagrant-hyperv") },
    null
  );
  items.Add(hyperVSysprep);

  if (amazon) {
    var amazonSysprep = PackerTemplate_Create(
      type,
      "amazon-sysprep",
      new [] { PackerBuilder_Create("amazon-ebs") },
      new [] { PackerProvisioner_Create("chef"), PackerProvisioner_Create("amazon-shutdown") },
      new [] { PackerPostProcessor_Create("vagrant-amazon") },
      null
    );
    items.Add(amazonSysprep);
  }

  return items;
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
