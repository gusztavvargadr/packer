#load "./template.cake"

IEnumerable<PackerTemplate> packerTemplates = new PackerTemplate[] {};
var packerTemplate = string.Empty;
var packerRecursive = false;

void PackerTemplates_ForEach(string template, Action<PackerTemplate> action, bool recursive) {
  foreach (var t in packerTemplates.Where(item => item.IsMatching(template))) {
    if (recursive && t.Parent != null) {
      PackerTemplates_ForEach(t.Parent.FullName, action, true);
    }
    action(t);
  }
}

Task("packer-info")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Info, packerRecursive);
  });

Task("packer-clean")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Clean, packerRecursive);
  });

Task("packer-version")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Version, packerRecursive);
  });

Task("packer-restore")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Restore, packerRecursive);
  });

Task("packer-build")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Build, packerRecursive);
  });

Task("packer-rebuild")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Rebuild, packerRecursive);
  });

Task("packer-test")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Test, packerRecursive);
  });

Task("packer-package")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Package, packerRecursive);
  });

Task("packer-publish")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Publish, packerRecursive);
  });
