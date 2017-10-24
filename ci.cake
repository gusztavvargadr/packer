#load "src/core/cake/core.cake"

var target = Argument("target", "default");
var configuration = Argument("configuration", string.Empty);
var recursive = Argument("recursive", false);

packerTemplates = new List<PackerTemplate>();

var w10e = PackerTemplates_Create("w10e");
var w10e_dc = PackerTemplates_Create("w10e-dc", parents: w10e);
var w10e_dotnet = PackerTemplates_Create("w10e-dotnet", parents: w10e);
var w10e_vs17c = PackerTemplates_Create("w10e-vs17c", parents: w10e_dotnet);

packerTemplates = packerTemplates.
  Concat(w10e).
  Concat(w10e_dc).
  Concat(w10e_dotnet).
  Concat(w10e_vs17c).
  ToList();

var w16s = PackerTemplates_Create("w16s", amazon: true);
var w16s_dc = PackerTemplates_Create("w16s-dc", parents: w16s);
var w16s_dotnet = PackerTemplates_Create("w16s-dotnet", parents: w16s);
var w16s_vs17c = PackerTemplates_Create("w16s-vs17c", parents: w16s_dotnet);
var w16s_iis = PackerTemplates_Create("w16s-iis", parents: w16s_dotnet);
var w16s_sql17d = PackerTemplates_Create("w16s-sql17d", parents: w16s_dotnet);

packerTemplates = packerTemplates.
  Concat(w16s).
  Concat(w16s_dc).
  Concat(w16s_dotnet).
  Concat(w16s_vs17c).
  Concat(w16s_iis).
  Concat(w16s_sql17d).
  ToList();

packerTemplate = configuration;
packerRecursive = recursive;

IEnumerable<PackerTemplate> PackerTemplates_Create(string type, bool amazon = false, IEnumerable<PackerTemplate> parents = null) {
  var items = new List<PackerTemplate>();

  var virtualBoxCore = PackerTemplate_Create(
    type,
    "virtualbox-core",
    new [] { PackerBuilder_Create(parents == null ? "virtualbox-iso" : "virtualbox-ovf") },
    new [] { PackerProvisioner_Create("chef") },
    new [] { PackerPostProcessor_Create("vagrant-virtualbox") },
    parents != null ? parents.First(item => item.IsMatching("virtualbox-core")) : null
  );
  var virtualBoxSysprep = PackerTemplate_Create(
    type,
    "virtualbox-sysprep",
    new [] { PackerBuilder_Create("virtualbox-ovf") },
    new [] { PackerProvisioner_Create("sysprep") },
    new [] { PackerPostProcessor_Create("vagrant-virtualbox") },
    virtualBoxCore
  );
  items.Add(virtualBoxCore);
  items.Add(virtualBoxSysprep);

  var hyperVCore = PackerTemplate_Create(
    type,
    "hyperv-core",
    new [] { PackerBuilder_Create(parents == null ? "hyperv-iso" : "hyperv-vmcx") },
    new [] { PackerProvisioner_Create("chef") },
    new [] { PackerPostProcessor_Create("vagrant-hyperv") },
    parents != null ? parents.First(item => item.IsMatching("hyperv-core")) : null
  );
  var hyperVSysprep = PackerTemplate_Create(
    type,
    "hyperv-sysprep",
    new [] { PackerBuilder_Create("hyperv-vmcx") },
    new [] { PackerProvisioner_Create("sysprep") },
    new [] { PackerPostProcessor_Create("vagrant-hyperv") },
    hyperVCore
  );
  items.Add(hyperVCore);
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
