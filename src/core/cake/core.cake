#load "./image.cake"

PackerImage packerImage = new PackerImage();
var packerTemplate = string.Empty;

Task("packer-info")
  .Does(() => {
    PackerImage_Info(packerImage, packerTemplate);
  });

Task("packer-clean")
  .Does(() => {
    PackerImage_Clean(packerImage, packerTemplate);
  });

Task("packer-version")
  .Does(() => {
    PackerImage_Version(packerImage, packerTemplate);
  });

Task("packer-restore")
  .Does(() => {
    PackerImage_Restore(packerImage, packerTemplate);
  });

Task("packer-build")
  .IsDependentOn("packer-version")
  .IsDependentOn("packer-restore")
  .Does(() => {
    PackerImage_Build(packerImage, packerTemplate);
  });

Task("packer-test")
  .IsDependentOn("packer-build")
  .Does(() => {
    PackerImage_Test(packerImage, packerTemplate);
  });

Task("packer-package")
  .IsDependentOn("packer-test")
  .Does(() => {
    PackerImage_Package(packerImage, packerTemplate);
  });

Task("packer-publish")
  .IsDependentOn("packer-package")
  .Does(() => {
    PackerImage_Publish(packerImage, packerTemplate);
  });
