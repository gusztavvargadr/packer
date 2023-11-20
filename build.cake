#load "src/core/cake/core.cake"

var target = Argument("target", "default");
var configuration = Argument("configuration", string.Empty);
var recursive = Argument("recursive", false);
var version = "2310";

var buildDirectory = Argument("build-directory", "./artifacts");
PackerTemplate.BuildDirectory = buildDirectory;

var w1122h2e_vs22c = PackerTemplates_CreateWindows(
  "w1122h2e-vs22c",
  "visual-studio-2022-community-windows-11",
  $"2022.2202.{version}",
  w1122h2e,
  aliases: new [] { "visual-studio" }
);
var w1022h2e_vs22c = PackerTemplates_CreateWindows(
  "w1022h2e-vs22c",
  "visual-studio-2022-community-windows-10",
  $"2022.2202.{version}",
  w1022h2e
);
var w1122h2e_vs19c = PackerTemplates_CreateWindows(
  "w1122h2e-vs19c",
  "visual-studio-2019-community-windows-11",
  $"2019.2202.{version}",
  w1122h2e
);
var w1022h2e_vs19c = PackerTemplates_CreateWindows(
  "w1022h2e-vs19c",
  "visual-studio-2019-community-windows-10",
  $"2019.2202.{version}",
  w1022h2e
);

Task("default")
  .IsDependentOn("info");

Task("info")
  .Does(() => {
    PackerTemplates_ForEach(configuration, PackerTemplate_Info);
  });

Task("version")
  .Does(() => {
    PackerTemplates_ForEach(configuration, PackerTemplate_Version);
  });

Task("restore")
  .IsDependentOn("version")
  .Does(() => {
    PackerTemplates_ForEach(configuration, PackerTemplate_Restore);
  });

Task("build")
  .IsDependentOn("restore")
  .Does(() => {
    PackerTemplates_ForEach(configuration, PackerTemplate_Build);
  });

Task("rebuild")
  .IsDependentOn("clean")
  .IsDependentOn("build")
  .Does(() => {
  });

Task("test")
  .IsDependentOn("build")
  .Does(() => {
    PackerTemplates_ForEach(configuration, PackerTemplate_Test);
  });

Task("publish")
  .Does(() => {
    PackerTemplates_ForEach(configuration, PackerTemplate_Publish);
  });

Task("download")
  .Does(() => {
    PackerTemplates_ForEach(configuration, PackerTemplate_Download);
  });

Task("clean")
  .IsDependentOn("version")
  .Does(() => {
    PackerTemplates_ForEach(configuration, PackerTemplate_Clean);
  });

RunTarget(target);
