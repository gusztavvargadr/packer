#load "src/core/cake/core.cake"

var target = Argument("target", "default");
var configuration = Argument("configuration", string.Empty);
var recursive = Argument("recursive", false);

packerTemplates = new List<PackerTemplate>();

var w10e = PackerTemplates_CreateWindows("w10e");
var w10e_dc = PackerTemplates_CreateWindows("w10e-dc", parents: w10e);
var w10e_dc_vs17c = PackerTemplates_CreateWindows("w10e-dc-vs17c", parents: w10e_dc);
var w10e_dc_vs17p = PackerTemplates_CreateWindows("w10e-dc-vs17p", parents: w10e_dc);

packerTemplates = packerTemplates.
  Concat(w10e).
  Concat(w10e_dc).
  Concat(w10e_dc_vs17c).
  Concat(w10e_dc_vs17p).
  ToList();

var w16s = PackerTemplates_CreateWindows("w16s", amazon: true);
var w16s_dc = PackerTemplates_CreateWindows("w16s-dc", parents: w16s);
var w16s_dc_vs17c = PackerTemplates_CreateWindows("w16s-dc-vs17c", parents: w16s_dc);
var w16s_dc_vs17p = PackerTemplates_CreateWindows("w16s-dc-vs17p", parents: w16s_dc);
var w16s_iis = PackerTemplates_CreateWindows("w16s-iis", parents: w16s);
var w16s_sql14d = PackerTemplates_CreateWindows("w16s-sql14d", parents: w16s);
var w16s_sql17d = PackerTemplates_CreateWindows("w16s-sql17d", parents: w16s);

packerTemplates = packerTemplates.
  Concat(w16s).
  Concat(w16s_dc).
  Concat(w16s_dc_vs17c).
  Concat(w16s_dc_vs17p).
  Concat(w16s_iis).
  Concat(w16s_sql14d).
  Concat(w16s_sql17d).
  ToList();

var w16sc = PackerTemplates_CreateWindows("w16sc");
var w16sc_de = PackerTemplates_CreateWindows("w16sc-de", parents: w16sc);

packerTemplates = packerTemplates.
  Concat(w16sc).
  Concat(w16sc_de).
  ToList();

var w1809de = PackerTemplates_CreateWindows("w1809de");
// var w1809de_dc = PackerTemplates_CreateWindows("w1809de-dc", parents: w1809de);
// var w1809de_dc_vs17c = PackerTemplates_CreateWindows("w1809de-dc-vs17c", parents: w1809de_dc);
// var w1809de_dc_vs17p = PackerTemplates_CreateWindows("w1809de-dc-vs17p", parents: w1809de_dc);

packerTemplates = packerTemplates.
  Concat(w1809de).
  // Concat(w1809de_dc).
  // Concat(w1809de_dc_vs17c).
  // Concat(w1809de_dc_vs17p).
  ToList();

var w1809ss = PackerTemplates_CreateWindows("w1809ss");
// var w1809ss_dc = PackerTemplates_CreateWindows("w1809ss-dc", parents: w1809ss);
// var w1809ss_dc_vs17c = PackerTemplates_CreateWindows("w1809ss-dc-vs17c", parents: w1809ss_dc);
// var w1809ss_dc_vs17p = PackerTemplates_CreateWindows("w1809ss-dc-vs17p", parents: w1809ss_dc);

packerTemplates = packerTemplates.
  Concat(w1809ss).
  // Concat(w1809ss_dc).
  // Concat(w1809ss_dc_vs17c).
  // Concat(w1809ss_dc_vs17p).
  ToList();

var w1809ssc = PackerTemplates_CreateWindows("w1809ssc");
var w1809ssc_de = PackerTemplates_CreateWindows("w1809ssc-de", parents: w1809ssc);

packerTemplates = packerTemplates.
  Concat(w1809ssc).
  Concat(w1809ssc_de).
  ToList();

var u16s = PackerTemplates_CreateLinux("u16s");
var u16s_dc = PackerTemplates_CreateLinux("u16s-dc", parents: u16s);

packerTemplates = packerTemplates.
  Concat(u16s).
  Concat(u16s_dc).
  ToList();

var u16d = PackerTemplates_CreateLinux("u16d");
var u16d_dc = PackerTemplates_CreateLinux("u16d-dc", parents: u16d);

packerTemplates = packerTemplates.
  Concat(u16d).
  Concat(u16d_dc).
  ToList();

packerTemplate = configuration;
packerRecursive = recursive;

IEnumerable<PackerTemplate> PackerTemplates_CreateWindows(string type, bool amazon = false, IEnumerable<PackerTemplate> parents = null) {
  var items = new List<PackerTemplate>();

  var virtualBoxCore = PackerTemplate_Create(
    type,
    "virtualbox-core",
    new [] { PackerBuilder_Create(parents == null ? "virtualbox-iso" : "virtualbox-ovf") },
    new [] { PackerProvisioner_Create("chef") },
    new PackerPostProcessor[] {},
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
    new PackerPostProcessor[] {},
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

IEnumerable<PackerTemplate> PackerTemplates_CreateLinux(string type, bool amazon = false, IEnumerable<PackerTemplate> parents = null) {
  var items = new List<PackerTemplate>();

  var virtualBoxCore = PackerTemplate_Create(
    type,
    "virtualbox-core",
    new [] { PackerBuilder_Create(parents == null ? "virtualbox-iso" : "virtualbox-ovf") },
    new [] { PackerProvisioner_Create("shell") },
    new PackerPostProcessor[] {},
    parents != null ? parents.First(item => item.IsMatching("virtualbox-core")) : null
  );
  var virtualBoxSysprep = PackerTemplate_Create(
    type,
    "virtualbox-sysprep",
    new [] { PackerBuilder_Create("virtualbox-ovf") },
    new PackerProvisioner[] {},
    new [] { PackerPostProcessor_Create("vagrant-virtualbox") },
    virtualBoxCore
  );
  items.Add(virtualBoxCore);
  items.Add(virtualBoxSysprep);

  var hyperVCore = PackerTemplate_Create(
    type,
    "hyperv-core",
    new [] { PackerBuilder_Create(parents == null ? "hyperv-iso" : "hyperv-vmcx") },
    new [] { PackerProvisioner_Create("shell") },
    new PackerPostProcessor[] {},
    parents != null ? parents.First(item => item.IsMatching("hyperv-core")) : null
  );
  var hyperVSysprep = PackerTemplate_Create(
    type,
    "hyperv-sysprep",
    new [] { PackerBuilder_Create("hyperv-vmcx") },
    new PackerProvisioner[] {},
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
      new [] { PackerProvisioner_Create("shell") },
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
