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
var w10ipe = PackerTemplates_CreateWindows(
  "w10ipe",
  "windows-10-insider-preview-enterprise",
  $"{version}.0.0"
);
var w10e = w101909e;

var u1604s = PackerTemplates_CreateLinux(
  "u1604s",
  "ubuntu-1604-server",
  $"{version}.0.0"
);
var u16s = u1604s;

var u1604d = PackerTemplates_CreateLinux(
  "u1604d",
  "ubuntu-1604-desktop",
  $"{version}.0.0"
);
var u16d = u1604d;

var w10e_dc = PackerTemplates_CreateWindows(
  "w10e-dc",
  "docker-windows",
  $"1903.0.{version}-community-windows-10-1909-enterprise",
  w10e
);
var ws2019s_dc = PackerTemplates_CreateWindows(
  "ws2019s-dc",
  "docker-windows",
  $"1903.0.{version}-community-windows-server-1809-standard",
  ws2019s
);
var ws2016s_de = PackerTemplates_CreateWindows(
  "ws2016s-de",
  "docker-windows",
  $"1903.0.{version}-enterprise-windows-server-1607-standard",
  ws2016s
);
var ws2016sc_de = PackerTemplates_CreateWindows(
  "ws2016sc-de",
  "docker-windows",
  $"1903.0.{version}-enterprise-windows-server-1607-standard-core",
  ws2016sc
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

var u16s_dc = PackerTemplates_CreateLinux(
  "u16s-dc",
  "docker-linux",
  $"1903.0.{version}-community-ubuntu-server-1604-lts",
  u16s
);
var u16d_dc = PackerTemplates_CreateLinux(
  "u16d-dc",
  "docker-linux",
  $"1903.0.{version}-community-ubuntu-desktop-1604-lts",
  u16d
);

var ws2016s_iis = PackerTemplates_CreateWindows(
  "ws2016s-iis",
  "iis",
  $"10.0.{version}-windows-server-1607-standard",
  ws2016s
);
var ws2016sc_iis = PackerTemplates_CreateWindows(
  "ws2016sc-iis",
  "iis",
  $"10.0.{version}-windows-server-1607-standard-core",
  ws2016sc
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

var w10e_dc_vs17c = PackerTemplates_CreateWindows(
  "w10e-dc-vs17c",
  "visual-studio",
  $"2017.0.{version}-community-windows-10-1909-enterprise",
  w10e_dc
);
var w10e_dc_vs17p = PackerTemplates_CreateWindows(
  "w10e-dc-vs17p",
  "visual-studio",
  $"2017.0.{version}-professional-windows-10-1909-enterprise",
  w10e_dc
);
var w10e_dc_vs19c = PackerTemplates_CreateWindows(
  "w10e-dc-vs19c",
  "visual-studio",
  $"2019.0.{version}-community-windows-10-1909-enterprise",
  w10e_dc
);
var w10e_dc_vs19p = PackerTemplates_CreateWindows(
  "w10e-dc-vs19p",
  "visual-studio",
  $"2019.0.{version}-professional-windows-10-1909-enterprise",
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
