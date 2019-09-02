#load "src/core/cake/core.cake"

var target = Argument("target", "default");
var configuration = Argument("configuration", string.Empty);
var version = "1908";

var buildDirectory = Argument("build-directory", EnvironmentVariable("PACKER_BUILD_DIR") ?? "./build");
PackerTemplate.BuildDirectory = buildDirectory;

Environment.SetEnvironmentVariable("PACKER_SOURCE_DIR", MakeAbsolute(Directory(".")).ToString());

var w10e = PackerTemplates_CreateWindows(
  "w10e",
  "windows-10",
  $"1903.0.{version}-enterprise"
);

var ws2019s = PackerTemplates_CreateWindows(
  "ws2019s",
  "windows-server",
  $"1809.0.{version}-standard"
);
var ws2019sc = PackerTemplates_CreateWindows(
  "ws2019sc",
  "windows-server",
  $"1809.0.{version}-standard-core"
);

var u16d = PackerTemplates_CreateLinux(
  "u16d",
  "ubuntu-desktop",
  $"1604.0.{version}-lts"
);

var u16s = PackerTemplates_CreateLinux(
  "u16s",
  "ubuntu-server",
  $"1604.0.{version}-lts"
);

var w10e_dc = PackerTemplates_CreateWindows(
  "w10e-dc",
  "docker-windows",
  $"1809.0.{version}-community-windows-10-1903-enterprise",
  w10e
);
var ws2019s_dc = PackerTemplates_CreateWindows(
  "ws2019s-dc",
  "docker-windows",
  $"1809.0.{version}-community-windows-server-1809-standard",
  ws2019s
);
var ws2019s_de = PackerTemplates_CreateWindows(
  "ws2019s-de",
  "docker-windows",
  $"1903.0.{version}-enterprise-windows-server-1809-standard",
  ws2019s
);
var ws2019sc_de = PackerTemplates_CreateWindows(
  "ws2019sc-de",
  "docker-windows",
  $"1903.0.{version}-enterprise-windows-server-1809-standard-core",
  ws2019sc
);

var u16d_dc = PackerTemplates_CreateLinux(
  "u16d-dc",
  "docker-linux",
  $"1903.0.{version}-community-ubuntu-desktop-1604-lts",
  u16d
);
var u16s_dc = PackerTemplates_CreateLinux(
  "u16s-dc",
  "docker-linux",
  $"1903.0.{version}-community-ubuntu-server-1604-lts",
  u16s
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

var w10e_dc_vs17c = PackerTemplates_CreateWindows(
  "w10e-dc-vs17c",
  "visual-studio",
  $"2017.0.{version}-community-windows-10-1903-enterprise",
  w10e_dc
);
var w10e_dc_vs17p = PackerTemplates_CreateWindows(
  "w10e-dc-vs17p",
  "visual-studio",
  $"2017.0.{version}-professional-windows-10-1903-enterprise",
  w10e_dc
);
var w10e_dc_vs19c = PackerTemplates_CreateWindows(
  "w10e-dc-vs19c",
  "visual-studio",
  $"2019.0.{version}-community-windows-10-1903-enterprise",
  w10e_dc
);
var w10e_dc_vs19p = PackerTemplates_CreateWindows(
  "w10e-dc-vs19p",
  "visual-studio",
  $"2019.0.{version}-professional-windows-10-1903-enterprise",
  w10e_dc
);
var ws2019s_dc_vs17c = PackerTemplates_CreateWindows(
  "ws2019s-dc-vs17c",
  "visual-studio",
  $"2017.0.{version}-community-windows-server-1809-standard",
  ws2019s_dc
);
var ws2019s_dc_vs17p = PackerTemplates_CreateWindows(
  "ws2019s-dc-vs17p",
  "visual-studio",
  $"2017.0.{version}-professional-windows-server-1809-standard",
  ws2019s_dc
);
var ws2019s_dc_vs19c = PackerTemplates_CreateWindows(
  "ws2019s-dc-vs19c",
  "visual-studio",
  $"2019.0.{version}-community-windows-server-1809-standard",
  ws2019s_dc
);
var ws2019s_dc_vs19p = PackerTemplates_CreateWindows(
  "ws2019s-dc-vs19p",
  "visual-studio",
  $"2019.0.{version}-professional-windows-server-1809-standard",
  ws2019s_dc
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
