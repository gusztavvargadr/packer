#load "src/core/cake/core.cake"

var target = Argument("target", "default");
var configuration = Argument("configuration", string.Empty);
var version = "2005";

var buildDirectory = Argument("build-directory", EnvironmentVariable("PACKER_BUILD_DIR") ?? "./build");
PackerTemplate.BuildDirectory = buildDirectory;

Environment.SetEnvironmentVariable("PACKER_SOURCE_DIR", MakeAbsolute(Directory(".")).ToString());

var ws2016s = PackerTemplates_CreateWindows(
  "ws2016s",
  "windows-server-2016-standard",
  $"{version}.0.0"
);
var ws2016sc = PackerTemplates_CreateWindows(
  "ws2016sc",
  "windows-server-2016-standard-core",
  $"{version}.0.0"
);
var ws2019s = PackerTemplates_CreateWindows(
  "ws2019s",
  "windows-server-2019-standard",
  $"{version}.0.0"
);
var ws2019sc = PackerTemplates_CreateWindows(
  "ws2019sc",
  "windows-server-2019-standard-core",
  $"{version}.0.0"
);
var wsipsc = PackerTemplates_CreateWindows(
  "wsipsc",
  "windows-server-insider-preview-standard-core",
  $"{version}.0.0"
);

var w101809eltsc = PackerTemplates_CreateWindows(
  "w101809eltsc",
  "windows-10-1809-enterprise-ltsc",
  $"{version}.0.0"
);
var w101909e = PackerTemplates_CreateWindows(
  "w101909e",
  "windows-10-1909-enterprise",
  $"{version}.0.0"
);
var w102004e = PackerTemplates_CreateWindows(
  "w102004e",
  "windows-10-2004-enterprise",
  $"{version}.0.0"
);
var w10ipe = PackerTemplates_CreateWindows(
  "w10ipe",
  "windows-10-insider-preview-enterprise",
  $"{version}.0.0"
);

var u1604s = PackerTemplates_CreateLinux(
  "u1604s",
  "ubuntu-server-1604",
  $"{version}.0.0"
);

var u1604d = PackerTemplates_CreateLinux(
  "u1604d",
  "ubuntu-desktop-1604",
  $"{version}.0.0"
);

var ws2019s_de = PackerTemplates_CreateWindows(
  "ws2019s-de",
  "docker-1903-enterprise-windows-server",
  $"{version}.0.0",
  ws2019s
);
var ws2019sc_de = PackerTemplates_CreateWindows(
  "ws2019sc-de",
  "docker-1903-enterprise-windows-server-core",
  $"{version}.0.0",
  ws2019sc
);

var w102004e_dc = PackerTemplates_CreateWindows(
  "w102004e-dc",
  "docker-1903-community-windows-10",
  $"{version}.0.0",
  w102004e
);
var u1604s_dc = PackerTemplates_CreateLinux(
  "u1604s-dc",
  "docker-1903-community-ubuntu-server",
  $"{version}.0.0",
  u1604s
);
var u1604d_dc = PackerTemplates_CreateLinux(
  "u1604d-dc",
  "docker-1903-community-ubuntu-desktop",
  $"{version}.0.0",
  u1604d
);

var ws2019s_iis = PackerTemplates_CreateWindows(
  "ws2019s-iis",
  "iis",
  $"10.0.{version}-windows-server-1809-standard",
  ws2019s
);
var ws2019sc_iis = PackerTemplates_CreateWindows(
  "ws2019sc-iis",
  "iis",
  $"10.0.{version}-windows-server-1809-standard-core",
  ws2019sc
);

var ws2019s_sql17d = PackerTemplates_CreateWindows(
  "ws2019s-sql17d",
  "sql-server",
  $"2017.0.{version}-developer-windows-server-1809-standard",
  ws2019s
);
var ws2019s_sql19d = PackerTemplates_CreateWindows(
  "ws2019s-sql19d",
  "sql-server",
  $"2019.0.{version}-developer-windows-server-1809-standard",
  ws2019s
);

var w102004e_dc_vs17c = PackerTemplates_CreateWindows(
  "w102004e-dc-vs17c",
  "visual-studio-2017-community-windows-10",
  $"{version}.0.0",
  w102004e_dc
);
var w102004e_dc_vs17p = PackerTemplates_CreateWindows(
  "w102004e-dc-vs17p",
  "visual-studio-2017-professional-windows-10",
  $"{version}.0.0",
  w102004e_dc
);
var w102004e_dc_vs19c = PackerTemplates_CreateWindows(
  "w102004e-dc-vs19c",
  "visual-studio-2019-community-windows-10",
  $"{version}.0.0",
  w102004e_dc
);
var w102004e_dc_vs19p = PackerTemplates_CreateWindows(
  "w102004e-dc-vs19p",
  "visual-studio-2019-professional-windows-10",
  $"{version}.0.0",
  w102004e_dc
);

Task("default")
  .IsDependentOn("info");

Task("info")
  .Does(() => {
    PackerTemplates_ForEach(configuration, PackerTemplate_Info);
  });

Task("clean")
  .Does(() => {
    PackerTemplates_ForEach(configuration, PackerTemplate_Clean);
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

Task("package")
  .Does(() => {
    PackerTemplates_ForEach(configuration, PackerTemplate_Package);
  });

Task("publish")
  .IsDependentOn("package")
  .Does(() => {
    PackerTemplates_ForEach(configuration, PackerTemplate_Publish);
  });

Task("download")
  .Does(() => {
    PackerTemplates_ForEach(configuration, PackerTemplate_Download);
  });

RunTarget(target);
