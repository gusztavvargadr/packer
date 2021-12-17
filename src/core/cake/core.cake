#load "./template.cake"

#addin "nuget:?package=Cake.FileHelpers&version=4.0.1"
#addin "nuget:?package=Cake.Json&version=6.0.1"
#addin "nuget:?package=Newtonsoft.Json&version=12.0.2"

var packerTemplates = new List<PackerTemplate>();

IEnumerable<PackerTemplate> PackerTemplates_CreateWindows(string name, string groupName = null, string groupVersion = null, IEnumerable<PackerTemplate> parents = null, IEnumerable<string> aliases = null) {
  var items = new List<PackerTemplate>();

  var virtualBoxCore = PackerTemplate_Create(
    name,
    "virtualbox-core",
    new [] { PackerBuilder_Create(parents == null ? "virtualbox-iso" : "virtualbox-ovf") },
    new [] { PackerProvisioner_Create("chef") },
    new [] { PackerPostProcessor_Create("manifest") },
    parents != null ? parents.First(item => item.IsMatching("virtualbox-core")) : null
  );
  var virtualBoxVagrant = PackerTemplate_Create(
    name,
    "virtualbox-vagrant",
    new [] { PackerBuilder_Create("virtualbox-ovf") },
    new [] { PackerProvisioner_Create("vagrant") },
    new [] { PackerPostProcessor_Create("vagrant-virtualbox") },
    virtualBoxCore,
    groupName,
    groupVersion,
    aliases
  );
  items.Add(virtualBoxCore);
  items.Add(virtualBoxVagrant);

  var hyperVCore = PackerTemplate_Create(
    name,
    "hyperv-core",
    new [] { PackerBuilder_Create(parents == null ? "hyperv-iso" : "hyperv-vmcx") },
    new [] { PackerProvisioner_Create("chef") },
    new [] { PackerPostProcessor_Create("manifest") },
    parents != null ? parents.First(item => item.IsMatching("hyperv-core")) : null
  );
  var hyperVVagrant = PackerTemplate_Create(
    name,
    "hyperv-vagrant",
    new [] { PackerBuilder_Create("hyperv-vmcx") },
    new [] { PackerProvisioner_Create("vagrant") },
    new [] { PackerPostProcessor_Create("vagrant-hyperv") },
    hyperVCore,
    groupName,
    groupVersion,
    aliases
  );
  items.Add(hyperVCore);
  items.Add(hyperVVagrant);

  packerTemplates.AddRange(items);

  return items;
}

IEnumerable<PackerTemplate> PackerTemplates_CreateLinux(string name, string groupName = null, string groupVersion = null, IEnumerable<PackerTemplate> parents = null, IEnumerable<string> aliases = null, bool amazon = false, bool azure = false) {
  var items = new List<PackerTemplate>();

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
    groupVersion,
    aliases
  );
  items.Add(virtualBoxCore);
  items.Add(virtualBoxVagrant);

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
    groupVersion,
    aliases
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
