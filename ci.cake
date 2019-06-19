#load "src/core/cake/core.cake"

var target = Argument("target", "default");
var configuration = Argument("configuration", string.Empty);
var recursive = Argument("recursive", false);

//  windows-10
var w10e = PackerTemplates_CreateWindows("w10e");

// windows-server
var ws2019s = PackerTemplates_CreateWindows("ws2019s");
var ws2019sc = PackerTemplates_CreateWindows("ws2019sc");

// ubuntu-desktop
var u16d = PackerTemplates_CreateLinux("u16d");

// ubuntu-server
var u16s = PackerTemplates_CreateLinux("u16s");

// docker windows
var ws2019sc_de = PackerTemplates_CreateWindows("ws2019sc-de", parents: ws2019sc);

// docker-linux
var u16s_dc = PackerTemplates_CreateLinux("u16s-dc", parents: u16s);

// iis
var ws2019s_iis = PackerTemplates_CreateWindows("ws2019s-iis", parents: ws2019s);

// sql-server
var ws2019s_sql17d = PackerTemplates_CreateWindows("ws2019s-sql17d", parents: ws2019s);

// visual-studio
var w10e_dc = PackerTemplates_CreateWindows("w10e-dc", parents: w10e);
var w10e_dc_vs17c = PackerTemplates_CreateWindows("w10e-dc-vs17c", parents: w10e_dc);
var w10e_dc_vs17p = PackerTemplates_CreateWindows("w10e-dc-vs17p", parents: w10e_dc);
var w10e_dc_vs19c = PackerTemplates_CreateWindows("w10e-dc-vs19c", parents: w10e_dc);
var w10e_dc_vs19p = PackerTemplates_CreateWindows("w10e-dc-vs19p", parents: w10e_dc);

var ws2019s_dc = PackerTemplates_CreateWindows("ws2019s-dc", parents: ws2019s);
var ws2019s_dc_vs17c = PackerTemplates_CreateWindows("ws2019s-dc-vs17c", parents: ws2019s_dc);
var ws2019s_dc_vs17p = PackerTemplates_CreateWindows("ws2019s-dc-vs17p", parents: ws2019s_dc);
var ws2019s_dc_vs19c = PackerTemplates_CreateWindows("ws2019s-dc-vs19c", parents: ws2019s_dc);
var ws2019s_dc_vs19p = PackerTemplates_CreateWindows("ws2019s-dc-vs19p", parents: ws2019s_dc);

packerTemplate = configuration;
packerRecursive = recursive;

IEnumerable<PackerTemplate> PackerTemplates_CreateWindows(string name, IEnumerable<PackerTemplate> parents = null) {
  var items = new List<PackerTemplate>();

  var virtualBoxCore = PackerTemplate_Create(
    name,
    "virtualbox-core",
    new [] { PackerBuilder_Create(parents == null ? "virtualbox-iso" : "virtualbox-ovf") },
    new [] { PackerProvisioner_Create("chef") },
    new [] { PackerPostProcessor_Create("manifest") },
    parents != null ? parents.First(item => item.IsMatching("virtualbox-core")) : null
  );
  var virtualBoxSysprep = PackerTemplate_Create(
    name,
    "virtualbox-sysprep",
    new [] { PackerBuilder_Create("virtualbox-ovf") },
    new [] { PackerProvisioner_Create("sysprep") },
    new [] { PackerPostProcessor_Create("vagrant-virtualbox") },
    virtualBoxCore
  );
  items.Add(virtualBoxCore);
  items.Add(virtualBoxSysprep);

  var hyperVCore = PackerTemplate_Create(
    name,
    "hyperv-core",
    new [] { PackerBuilder_Create(parents == null ? "hyperv-iso" : "hyperv-vmcx") },
    new [] { PackerProvisioner_Create("chef") },
    new [] { PackerPostProcessor_Create("manifest") },
    parents != null ? parents.First(item => item.IsMatching("hyperv-core")) : null
  );
  var hyperVSysprep = PackerTemplate_Create(
    name,
    "hyperv-sysprep",
    new [] { PackerBuilder_Create("hyperv-vmcx") },
    new [] { PackerProvisioner_Create("sysprep") },
    new [] { PackerPostProcessor_Create("vagrant-hyperv") },
    hyperVCore
  );
  items.Add(hyperVCore);
  items.Add(hyperVSysprep);

  packerTemplates.AddRange(items);

  return items;
}

IEnumerable<PackerTemplate> PackerTemplates_CreateLinux(string name, bool amazon = true, bool azure = true, IEnumerable<PackerTemplate> parents = null) {
  var items = new List<PackerTemplate>();

  var virtualBoxCore = PackerTemplate_Create(
    name,
    "virtualbox-core",
    new [] { PackerBuilder_Create(parents == null ? "virtualbox-iso" : "virtualbox-ovf") },
    new [] { PackerProvisioner_Create("shell-prepare"), PackerProvisioner_Create("shell-configure"), PackerProvisioner_Create("shell-install"), PackerProvisioner_Create("shell-cleanup") },
    new [] { PackerPostProcessor_Create("manifest") },
    parents != null ? parents.First(item => item.IsMatching("virtualbox-core")) : null
  );
  var virtualBoxSysprep = PackerTemplate_Create(
    name,
    "virtualbox-sysprep",
    new [] { PackerBuilder_Create("virtualbox-ovf") },
    new [] { PackerProvisioner_Create("shell-vagrant") },
    new [] { PackerPostProcessor_Create("vagrant-virtualbox") },
    virtualBoxCore
  );
  items.Add(virtualBoxCore);
  items.Add(virtualBoxSysprep);

  var hyperVCore = PackerTemplate_Create(
    name,
    "hyperv-core",
    new [] { PackerBuilder_Create(parents == null ? "hyperv-iso" : "hyperv-vmcx") },
    new [] { PackerProvisioner_Create("shell-prepare"), PackerProvisioner_Create("shell-configure"), PackerProvisioner_Create("shell-install"), PackerProvisioner_Create("shell-cleanup") },
    new [] { PackerPostProcessor_Create("manifest") },
    parents != null ? parents.First(item => item.IsMatching("hyperv-core")) : null
  );
  var hyperVSysprep = PackerTemplate_Create(
    name,
    "hyperv-sysprep",
    new [] { PackerBuilder_Create("hyperv-vmcx") },
    new [] { PackerProvisioner_Create("shell-vagrant") },
    new [] { PackerPostProcessor_Create("vagrant-hyperv") },
    hyperVCore
  );
  items.Add(hyperVCore);
  items.Add(hyperVSysprep);

  if (amazon) {
    var amazonSysprep = PackerTemplate_Create(
      name,
      "amazon",
      new [] { PackerBuilder_Create("amazon") },
      new [] { PackerProvisioner_Create("shell-prepare"), PackerProvisioner_Create("shell-configure"), PackerProvisioner_Create("shell-install"), PackerProvisioner_Create("shell-cleanup") },
      new [] { PackerPostProcessor_Create("manifest") },
      // new [] { PackerPostProcessor_Create("vagrant-amazon") },
      parents != null ? parents.First(item => item.IsMatching("amazon")) : null
    );
    items.Add(amazonSysprep);
  }

  if (azure) {
    var azureSysprep = PackerTemplate_Create(
      name,
      "azure",
      new [] { PackerBuilder_Create(parents == null ? "azure-marketplace" : "azure-custom") },
      new [] { PackerProvisioner_Create("shell-prepare"), PackerProvisioner_Create("shell-configure"), PackerProvisioner_Create("shell-install"), PackerProvisioner_Create("shell-cleanup") },
      new [] { PackerPostProcessor_Create("manifest") },
      parents != null ? parents.First(item => item.IsMatching("azure")) : null
    );

    items.Add(azureSysprep);
  }

  packerTemplates.AddRange(items);

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
