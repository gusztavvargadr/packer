#load "./template.cake"

var version = "1906";
var packerTemplates = new List<PackerTemplate>();

var w10e = PackerTemplates_CreateWindows(
  "w10e",
  "windows-10",
  string.Format("1903.0.{0}-enterprise", version)
);

var ws2019s = PackerTemplates_CreateWindows(
  "ws2019s",
  "windows-server",
  string.Format("1809.0.{0}-standard", version)
);
var ws2019sc = PackerTemplates_CreateWindows(
  "ws2019sc",
  "windows-server",
  string.Format("1809.0.{0}-standard-core", version)
);

var u16d = PackerTemplates_CreateLinux(
  "u16d",
  "ubuntu-desktop",
  string.Format("1604.0.{0}-lts", version)
);

var u16s = PackerTemplates_CreateLinux(
  "u16s",
  "ubuntu-server",
  string.Format("1604.0.{0}-lts", version)
);

var w10e_dc = PackerTemplates_CreateWindows(
  "w10e-dc",
  "docker-windows",
  string.Format("1809.0.{0}-community-windows-10-1903-enterprise", version),
  w10e
);
var ws2019s_dc = PackerTemplates_CreateWindows(
  "ws2019s-dc",
  "docker-windows",
  string.Format("1809.0.{0}-community-windows-server-1809-standard", version),
  ws2019s
);
var ws2019s_de = PackerTemplates_CreateWindows(
  "ws2019s-de",
  "docker-windows",
  string.Format("1809.0.{0}-enterprise-windows-server-1809-standard", version),
  ws2019s
);
var ws2019sc_de = PackerTemplates_CreateWindows(
  "ws2019sc-de",
  "docker-windows",
  string.Format("1809.0.{0}-enterprise-windows-server-1809-standard-core", version),
  ws2019sc
);

var u16d_dc = PackerTemplates_CreateLinux(
  "u16d-dc",
  "docker-linux",
  string.Format("1809.0.{0}-community-ubuntu-desktop-1604-lts", version),
  u16d
);
var u16s_dc = PackerTemplates_CreateLinux(
  "u16s-dc",
  "docker-linux",
  string.Format("1809.0.{0}-community-ubuntu-server-1604-lts", version),
  u16s
);

// iis
var ws2019s_iis = PackerTemplates_CreateWindows("ws2019s-iis", parents: ws2019s);
var ws2019sc_iis = PackerTemplates_CreateWindows("ws2019sc-iis", parents: ws2019sc);

// sql-server
var ws2019s_sql17d = PackerTemplates_CreateWindows("ws2019s-sql17d", parents: ws2019s);

// visual-studio
var w10e_dc_vs17c = PackerTemplates_CreateWindows("w10e-dc-vs17c", parents: w10e_dc);
var w10e_dc_vs17p = PackerTemplates_CreateWindows("w10e-dc-vs17p", parents: w10e_dc);
var w10e_dc_vs19c = PackerTemplates_CreateWindows("w10e-dc-vs19c", parents: w10e_dc);
var w10e_dc_vs19p = PackerTemplates_CreateWindows("w10e-dc-vs19p", parents: w10e_dc);

var ws2019s_dc_vs17c = PackerTemplates_CreateWindows("ws2019s-dc-vs17c", parents: ws2019s_dc);
var ws2019s_dc_vs17p = PackerTemplates_CreateWindows("ws2019s-dc-vs17p", parents: ws2019s_dc);
var ws2019s_dc_vs19c = PackerTemplates_CreateWindows("ws2019s-dc-vs19c", parents: ws2019s_dc);
var ws2019s_dc_vs19p = PackerTemplates_CreateWindows("ws2019s-dc-vs19p", parents: ws2019s_dc);

IEnumerable<PackerTemplate> PackerTemplates_CreateWindows(string name, string groupName = null, string groupVersion = null, IEnumerable<PackerTemplate> parents = null) {
  var items = new List<PackerTemplate>();

  if (parents == null) {
    var virtualBoxInit = PackerTemplate_Create(
      name,
      "virtualbox-init",
      new [] { PackerBuilder_Create("virtualbox-iso") },
      new [] { PackerProvisioner_Create("sysprep"), PackerProvisioner_Create("vagrant") },
      new [] { PackerPostProcessor_Create("vagrant-virtualbox") },
      null
    );
    items.Add(virtualBoxInit);
  }
  var virtualBoxCore = PackerTemplate_Create(
    name,
    "virtualbox-core",
    new [] { PackerBuilder_Create(parents == null ? "virtualbox-iso" : "virtualbox-ovf") },
    new [] { PackerProvisioner_Create("sysprep"), PackerProvisioner_Create("chef") },
    new [] { PackerPostProcessor_Create("manifest") },
    parents != null ? parents.First(item => item.IsMatching("virtualbox-core")) : null
  );
  var virtualBoxVagrant = PackerTemplate_Create(
    name,
    "virtualbox-vagrant",
    new [] { PackerBuilder_Create("virtualbox-ovf") },
    new [] { PackerProvisioner_Create("sysprep"), PackerProvisioner_Create("vagrant") },
    new [] { PackerPostProcessor_Create("vagrant-virtualbox") },
    virtualBoxCore,
    groupName,
    groupVersion
  );
  items.Add(virtualBoxCore);
  items.Add(virtualBoxVagrant);

  if (parents == null) {
    var hyperVInit = PackerTemplate_Create(
      name,
      "hyperv-init",
      new [] { PackerBuilder_Create("hyperv-iso") },
      new [] { PackerProvisioner_Create("sysprep"), PackerProvisioner_Create("vagrant") },
      new [] { PackerPostProcessor_Create("vagrant-hyperv") },
      null
    );
    items.Add(hyperVInit);
  }
  var hyperVCore = PackerTemplate_Create(
    name,
    "hyperv-core",
    new [] { PackerBuilder_Create(parents == null ? "hyperv-iso" : "hyperv-vmcx") },
    new [] { PackerProvisioner_Create("sysprep"), PackerProvisioner_Create("chef") },
    new [] { PackerPostProcessor_Create("manifest") },
    parents != null ? parents.First(item => item.IsMatching("hyperv-core")) : null
  );
  var hyperVVagrant = PackerTemplate_Create(
    name,
    "hyperv-vagrant",
    new [] { PackerBuilder_Create("hyperv-vmcx") },
    new [] { PackerProvisioner_Create("sysprep"), PackerProvisioner_Create("vagrant") },
    new [] { PackerPostProcessor_Create("vagrant-hyperv") },
    hyperVCore,
    groupName,
    groupVersion
  );
  items.Add(hyperVCore);
  items.Add(hyperVVagrant);

  packerTemplates.AddRange(items);

  return items;
}

IEnumerable<PackerTemplate> PackerTemplates_CreateLinux(string name, string groupName = null, string groupVersion = null, IEnumerable<PackerTemplate> parents = null, bool amazon = true, bool azure = true) {
  var items = new List<PackerTemplate>();

  if (parents == null) {
    var virtualBoxInit = PackerTemplate_Create(
      name,
      "virtualbox-init",
      new [] { PackerBuilder_Create("virtualbox-iso") },
      new [] { PackerProvisioner_Create("shell-install"), PackerProvisioner_Create("shell-vagrant") },
      new [] { PackerPostProcessor_Create("vagrant-virtualbox") },
      null
    );
    items.Add(virtualBoxInit);
  }
  var virtualBoxCore = PackerTemplate_Create(
    name,
    "virtualbox-core",
    new [] { PackerBuilder_Create(parents == null ? "virtualbox-iso" : "virtualbox-ovf") },
    new [] { PackerProvisioner_Create("shell-prepare"), PackerProvisioner_Create("shell-configure"), PackerProvisioner_Create("shell-install"), PackerProvisioner_Create("shell-cleanup") },
    new [] { PackerPostProcessor_Create("manifest") },
    parents != null ? parents.First(item => item.IsMatching("virtualbox-core")) : null
  );
  var virtualBoxVagrant = PackerTemplate_Create(
    name,
    "virtualbox-vagrant",
    new [] { PackerBuilder_Create("virtualbox-ovf") },
    new [] { PackerProvisioner_Create("shell-vagrant") },
    new [] { PackerPostProcessor_Create("vagrant-virtualbox") },
    virtualBoxCore,
    groupName,
    groupVersion
  );
  items.Add(virtualBoxCore);
  items.Add(virtualBoxVagrant);

  if (parents == null) {
    var hyperVInit = PackerTemplate_Create(
      name,
      "hyperv-init",
      new [] { PackerBuilder_Create("hyperv-iso") },
      new [] { PackerProvisioner_Create("shell-vagrant") },
      new [] { PackerPostProcessor_Create("vagrant-hyperv") },
      null
    );
    items.Add(hyperVInit);
  }
  var hyperVCore = PackerTemplate_Create(
    name,
    "hyperv-core",
    new [] { PackerBuilder_Create(parents == null ? "hyperv-iso" : "hyperv-vmcx") },
    new [] { PackerProvisioner_Create("shell-prepare"), PackerProvisioner_Create("shell-configure"), PackerProvisioner_Create("shell-install"), PackerProvisioner_Create("shell-cleanup") },
    new [] { PackerPostProcessor_Create("manifest") },
    parents != null ? parents.First(item => item.IsMatching("hyperv-core")) : null
  );
  var hyperVVagrant = PackerTemplate_Create(
    name,
    "hyperv-vagrant",
    new [] { PackerBuilder_Create("hyperv-vmcx") },
    new [] { PackerProvisioner_Create("shell-vagrant") },
    new [] { PackerPostProcessor_Create("vagrant-hyperv") },
    hyperVCore,
    groupName,
    groupVersion
  );
  items.Add(hyperVCore);
  items.Add(hyperVVagrant);

  if (amazon) {
    var amazonCore = PackerTemplate_Create(
      name,
      "amazon",
      new [] { PackerBuilder_Create("amazon") },
      new [] { PackerProvisioner_Create("shell-prepare"), PackerProvisioner_Create("shell-configure"), PackerProvisioner_Create("shell-install"), PackerProvisioner_Create("shell-cleanup") },
      new [] { PackerPostProcessor_Create("manifest") },
      // new [] { PackerPostProcessor_Create("vagrant-amazon") },
      parents != null ? parents.First(item => item.IsMatching("amazon")) : null
    );
    items.Add(amazonCore);
  }

  if (azure) {
    var azureCore = PackerTemplate_Create(
      name,
      "azure",
      new [] { PackerBuilder_Create(parents == null ? "azure-marketplace" : "azure-custom") },
      new [] { PackerProvisioner_Create("shell-prepare"), PackerProvisioner_Create("shell-configure"), PackerProvisioner_Create("shell-install"), PackerProvisioner_Create("shell-cleanup") },
      new [] { PackerPostProcessor_Create("manifest") },
      parents != null ? parents.First(item => item.IsMatching("azure")) : null
    );

    items.Add(azureCore);
  }

  packerTemplates.AddRange(items);

  return items;
}

void PackerTemplates_ForEach(string template, Action<PackerTemplate> action) {
  foreach (var t in packerTemplates.Where(item => item.IsMatching(template))) {
    action(t);
  }
}
