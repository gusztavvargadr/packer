#load "src/core/cake/core.cake"

var target = Argument("target", "default");
var configuration = Argument("configuration", string.Empty);
var version = "2109";

var buildDirectory = Argument("build-directory", "./build");
PackerTemplate.BuildDirectory = buildDirectory;

var ws2022s = PackerTemplates_CreateWindows(
  "ws2022s",
  "windows-server-2022-standard-desktop",
  $"2102.0.{version}"
);

var ws2022sc = PackerTemplates_CreateWindows(
  "ws2022sc",
  "windows-server-2022-standard-core",
  $"2102.0.{version}"
);

var ws2019s = PackerTemplates_CreateWindows(
  "ws2019s",
  "windows-server-2019-standard-desktop",
  $"1809.0.{version}"
);

var ws2019sc = PackerTemplates_CreateWindows(
  "ws2019sc",
  "windows-server-2019-standard-corse",
  $"1809.0.{version}"
);

var ws2016s = PackerTemplates_CreateWindows(
  "ws2016s",
  "windows-server-2016-standard-desktop",
  $"1607.0.{version}"
);

var ws2016sc = PackerTemplates_CreateWindows(
  "ws2016sc",
  "windows-server-2016-standard-core",
  $"1607.0.{version}"
);

var ws2022s_alias = PackerTemplates_CreateWindows(
  "ws2022s-alias",
  "windows-server",
  $"2102.0.{version}",
  ws2022s
);
var ws2019s_alias = PackerTemplates_CreateWindows(
  "ws2019s-alias",
  "windows-server",
  $"1809.0.{version}",
  ws2019s
);
var ws2016s_alias = PackerTemplates_CreateWindows(
  "ws2016s-alias",
  "windows-server",
  $"1607.0.{version}",
  ws2016s
);

var wsips = PackerTemplates_CreateWindows(
  "wsips",
  "windows-server-2022-standard-desktop-insider",
  $"2102.0.{version}"
);

var wsipsc = PackerTemplates_CreateWindows(
  "wsipsc",
  "windows-server-20220standard-core-insider",
  $"2102.0.{version}"
);

var w101809eltsc = PackerTemplates_CreateWindows(
  "w101809eltsc",
  "windows-10-enterprise-ltsc",
  $"1809.0.{version}"
);
var w102009e = PackerTemplates_CreateWindows(
  "w102009e",
  "windows-10-enterprise",
  $"2009.0.{version}"
);
var w102101e = PackerTemplates_CreateWindows(
  "w102101e",
  "windows-10-enterprise",
  $"2101.0.{version}"
);
var w10ipe = PackerTemplates_CreateWindows(
  "w10ipe",
  "windows-10-enterprise-insider",
  $"2101.0.{version}"
);
var w11ipe = PackerTemplates_CreateWindows(
  "w11ipe",
  "windows-11-enterprise-insider-preview",
  $"2102.0.{version}"
);

var u1804s = PackerTemplates_CreateLinux(
  "u1804s",
  "ubuntu-server-1804-lts",
  $"1804.0.{version}"
);

var u1604s = PackerTemplates_CreateLinux(
  "u1604s",
  "ubuntu-server-1604-lts",
  $"1604.0.{version}"
);

var u1804s_alias = PackerTemplates_CreateLinux(
  "u1804s-alias",
  "ubuntu-server",
  $"1804.0.{version}",
  u1804s
);
var u1604s_alias = PackerTemplates_CreateLinux(
  "u1604s-alias",
  "ubuntu-server",
  $"1604.0.{version}",
  u1604s
);

var u1804d = PackerTemplates_CreateLinux(
  "u1804d",
  "ubuntu-desktop-1804-lts-xfce",
  $"1804.0.{version}"
);

var u1604d = PackerTemplates_CreateLinux(
  "u1604d",
  "ubuntu-desktop-1604-lts-xfce",
  $"1604.0.{version}"
);

var u1804d_alias = PackerTemplates_CreateLinux(
  "u1804d-alias",
  "ubuntu-desktop",
  $"1804.0.{version}",
  u1804d
);
var u1604d_alias = PackerTemplates_CreateLinux(
  "u1604d-alias",
  "ubuntu-desktop",
  $"1604.0.{version}",
  u1604d
);

var ws2019s_de = PackerTemplates_CreateWindows(
  "ws2019s-de",
  "docker-windows-enterprise-windows-server",
  $"2010.1809.{version}",
  ws2019s
);
var ws2019sc_de = PackerTemplates_CreateWindows(
  "ws2019sc-de",
  "docker-windows-enterprise-windows-server-core",
  $"2010.1809.{version}",
  ws2019sc
);

var u1804s_dc = PackerTemplates_CreateLinux(
  "u1804s-dc",
  "docker-community-ubuntu-server",
  $"2010.1804.{version}",
  u1804s
);
var u1604s_dc = PackerTemplates_CreateLinux(
  "u1604s-dc",
  "docker-community-ubuntu-server",
  $"2010.1604.{version}",
  u1604s
);

var u1804d_dc = PackerTemplates_CreateLinux(
  "u1804d-dc",
  "docker-community-ubuntu-desktop",
  $"2010.1804.{version}",
  u1804d
);
var u1604d_dc = PackerTemplates_CreateLinux(
  "u1604d-dc",
  "docker-community-ubuntu-desktop",
  $"2010.1604.{version}",
  u1604d
);

var u1804s_dc_alias = PackerTemplates_CreateLinux(
  "u1804s-dc-alias",
  "docker-linux",
  $"2010.0.{version}",
  u1804s_dc
);

var dc_w10 = PackerTemplates_CreateWindows(
  "w102101e-dc",
  "docker-linux-community-windows-10",
  $"2010.2101.{version}",
  w102101e
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

var vs17c_w10 = PackerTemplates_CreateWindows(
  "w102101e-dc-vs17c",
  "visual-studio-community-windows-10",
  $"2017.2101.{version}",
  dc_w10
);
var vs19c_w10 = PackerTemplates_CreateWindows(
  "w102101e-dc-vs19c",
  "visual-studio-community-windows-10",
  $"2019.2101.{version}",
  dc_w10
);
var vs17p_w10 = PackerTemplates_CreateWindows(
  "w102101e-dc-vs17p",
  "visual-studio-professional-windows-10",
  $"2017.2101.{version}",
  dc_w10
);
var vs19p_w10 = PackerTemplates_CreateWindows(
  "w102101e-dc-vs19p",
  "visual-studio-professional-windows-10",
  $"2019.2101.{version}",
  dc_w10
);

var w102009 = PackerTemplates_CreateWindows(
  "w102009",
  "windows-10",
  $"2009.0.{version}",
  w102009e
);
var w102101 = PackerTemplates_CreateWindows(
  "w102101",
  "windows-10",
  $"2101.0.{version}",
  w102101e
);

var wsd = PackerTemplates_CreateWindows(
  "wsd",
  "docker-windows",
  $"2010.0.{version}",
  ws2019s_de
);

var wsiis = PackerTemplates_CreateWindows(
  "wsiis",
  "iis",
  $"10.0.{version}",
  ws2019s_iis
);

var wssql17 = PackerTemplates_CreateWindows(
  "wssql17",
  "sql-server",
  $"2017.0.{version}",
  ws2019s_sql17d
);
var wssql19 = PackerTemplates_CreateWindows(
  "wssql19",
  "sql-server",
  $"2019.0.{version}",
  ws2019s_sql19d
);

var w10vs17 = PackerTemplates_CreateWindows(
  "w10vs17",
  "visual-studio",
  $"2017.0.{version}",
  vs17c_w10
);
var w10vs19 = PackerTemplates_CreateWindows(
  "w10vs19",
  "visual-studio",
  $"2019.0.{version}",
  vs19c_w10
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

Task("clean")
  .IsDependentOn("version")
  .Does(() => {
    PackerTemplates_ForEach(configuration, PackerTemplate_Clean);
  });

RunTarget(target);
