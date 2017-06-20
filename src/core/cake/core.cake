#load "./template.cake"

IEnumerable<PackerTemplate> packerTemplates = new PackerTemplate[] {};
var packerTemplate = string.Empty;

void PackerTemplates_ForEach(string template, Action<PackerTemplate> action) {
  foreach (var t in packerTemplates.Where(item => item.IsMatching(template))) {
    action(t);
  }
}

Task("packer-info")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Info);
  });

Task("packer-clean")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Clean);
  });

Task("packer-version")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Version);
  });

Task("packer-restore")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Restore);
  });

Task("packer-build")
  .IsDependentOn("packer-version")
  .IsDependentOn("packer-restore")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Build);
  });

Task("packer-rebuild")
  .IsDependentOn("packer-clean")
  .IsDependentOn("packer-build")
  .Does(() => {
  });

Task("packer-test")
  .IsDependentOn("packer-build")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Test);
  });

Task("packer-package")
  .IsDependentOn("packer-test")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Package);
  });

Task("packer-publish")
  .IsDependentOn("packer-package")
  .Does(() => {
    PackerTemplates_ForEach(packerTemplate, PackerTemplate_Publish);
  });
