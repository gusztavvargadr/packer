#load "src/core/cake/core.cake"

var target = Argument("target", "default");
var configuration = Argument("configuration", string.Empty);
var version = "2006";

var buildDirectory = Argument("build-directory", EnvironmentVariable("PACKER_BUILD_DIR") ?? "./build");
PackerTemplate.BuildDirectory = buildDirectory;

Environment.SetEnvironmentVariable("PACKER_SOURCE_DIR", MakeAbsolute(Directory(".")).ToString());

var ws2016s = PackerTemplates_CreateWindows(
  "ws2016s",
  "windows-server-standard",
  $"1607.0.{version}"
);
var ws2016sc = PackerTemplates_CreateWindows(
  "ws2016sc",
  "windows-server-standard-core",
  $"1607.0.{version}"
);
var ws2019s = PackerTemplates_CreateWindows(
  "ws2019s",
  "windows-server-standard",
  $"1809.0.{version}"
);
var ws2019sc = PackerTemplates_CreateWindows(
  "ws2019sc",
  "windows-server-standard-core",
  $"1809.0.{version}"
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
  "windows-10-enterprise",
  $"1909.0.{version}"
);
var w102004e = PackerTemplates_CreateWindows(
  "w102004e",
  "windows-10-enterprise",
  $"2004.0.{version}"
);
var w10ipe = PackerTemplates_CreateWindows(
  "w10ipe",
  "windows-10-insider-preview-enterprise",
  $"{version}.0.0"
);

var u1604s = PackerTemplates_CreateLinux(
  "u1604s",
  "ubuntu-server",
  $"1604.0.{version}"
);

var u1604d = PackerTemplates_CreateLinux(
  "u1604d",
  "ubuntu-desktop",
  $"1604.0.{version}"
);

var ws2019s_de = PackerTemplates_CreateWindows(
  "ws2019s-de",
  "docker-windows-enterprise-windows-server",
  $"1903.1809.{version}",
  ws2019s
);
var ws2019sc_de = PackerTemplates_CreateWindows(
  "ws2019sc-de",
  "docker-windows-enterprise-windows-server-core",
  $"1903.1809.{version}",
  ws2019sc
);

var w102004e_dc = PackerTemplates_CreateWindows(
  "w102004e-dc",
  "docker-linux-community-windows-10",
  $"1903.2004.{version}",
  w102004e
);
var u1604s_dc = PackerTemplates_CreateLinux(
  "u1604s-dc",
  "docker-linux-community-ubuntu-server",
  $"1903.1604.{version}",
  u1604s
);
var u1604d_dc = PackerTemplates_CreateLinux(
  "u1604d-dc",
  "docker-linux-community-ubuntu-desktop",
  $"1903.1604.{version}",
  u1604d
);

var ws2019s_iis = PackerTemplates_CreateWindows(
  "ws2019s-iis",
  "iis-windows-server",
  $"10.1809.{version}",
  ws2019s
);
var ws2019sc_iis = PackerTemplates_CreateWindows(
  "ws2019sc-iis",
  "iis-windows-server-core",
  $"10.1809.{version}",
  ws2019sc
);

var ws2019s_sql17d = PackerTemplates_CreateWindows(
  "ws2019s-sql17d",
  "sql-server-developer-windows-server",
  $"2017.1809.{version}",
  ws2019s
);
var ws2019s_sql19d = PackerTemplates_CreateWindows(
  "ws2019s-sql19d",
  "sql-server-developer-windows-server",
  $"2019.1809.{version}",
  ws2019s
);

var w102004e_dc_vs17c = PackerTemplates_CreateWindows(
  "w102004e-dc-vs17c",
  "visual-studio-community-windows-10",
  $"2017.2004.{version}",
  w102004e_dc
);
var w102004e_dc_vs17p = PackerTemplates_CreateWindows(
  "w102004e-dc-vs17p",
  "visual-studio-professional-windows-10",
  $"2017.2004.{version}",
  w102004e_dc
);
var w102004e_dc_vs19c = PackerTemplates_CreateWindows(
  "w102004e-dc-vs19c",
  "visual-studio-community-windows-10",
  $"2019.2004.{version}",
  w102004e_dc
);
var w102004e_dc_vs19p = PackerTemplates_CreateWindows(
  "w102004e-dc-vs19p",
  "visual-studio-professional-windows-10",
  $"2019.2004.{version}",
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
