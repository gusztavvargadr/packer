#load "src/core/cake/core.cake"

var target = Argument("target", "default");
var configuration = Argument("configuration", string.Empty);
var recursive = Argument("recursive", false);
var version = "2112";

var buildDirectory = Argument("build-directory", "./build");
PackerTemplate.BuildDirectory = buildDirectory;

var ws2022s = PackerTemplates_CreateWindows(
  "ws2022s",
  "windows-server-2022-standard-desktop",
  $"2102.0.{version}",
  aliases: new [] { "windows-server" },
  vmware: true
);
var ws2019s = PackerTemplates_CreateWindows(
  "ws2019s",
  "windows-server-2019-standard-desktop",
  $"1809.0.{version}",
  aliases: new [] { "windows-server" },
  vmware: true
);
var ws2016s = PackerTemplates_CreateWindows(
  "ws2016s",
  "windows-server-2016-standard-desktop",
  $"1607.0.{version}",
  aliases: new [] { "windows-server" }
);
var wsips = PackerTemplates_CreateWindows(
  "wsips",
  "windows-server-standard-desktop-insider-preview",
  $"2102.0.{version}"
);

var ws2022sc = PackerTemplates_CreateWindows(
  "ws2022sc",
  "windows-server-2022-standard-core",
  $"2102.0.{version}",
  aliases: new [] { "windows-server-core" },
  vmware: true
);
var ws2019sc = PackerTemplates_CreateWindows(
  "ws2019sc",
  "windows-server-2019-standard-core",
  $"1809.0.{version}",
  aliases: new [] { "windows-server-core" },
  vmware: true
);
var ws2016sc = PackerTemplates_CreateWindows(
  "ws2016sc",
  "windows-server-2016-standard-core",
  $"1607.0.{version}",
  aliases: new [] { "windows-server-core" }
);
var wsipsc = PackerTemplates_CreateWindows(
  "wsipsc",
  "windows-server-standard-core-insider-preview",
  $"2102.0.{version}"
);

var w112102e = PackerTemplates_CreateWindows(
  "w112102e",
  "windows-11-enterprise",
  $"2102.0.{version}",
  aliases: new [] { "windows-11" },
  vmware: true
);
var w11ipe = PackerTemplates_CreateWindows(
  "w11ipe",
  "windows-11-enterprise-insider-preview",
  $"2102.0.{version}"
);

var w102102e = PackerTemplates_CreateWindows(
  "w102102e",
  "windows-10-enterprise",
  $"2102.0.{version}",
  aliases: new [] { "windows-10" },
  vmware: true
);
var w102101e = PackerTemplates_CreateWindows(
  "w102101e",
  "windows-10-enterprise",
  $"2101.0.{version}",
  aliases: new [] { "windows-10" }
);
var w102102eltsc = PackerTemplates_CreateWindows(
  "w102102eltsc",
  "windows-10-enterprise-ltsc",
  $"2102.0.{version}"
);
var w101809eltsc = PackerTemplates_CreateWindows(
  "w101809eltsc",
  "windows-10-enterprise-ltsc",
  $"1809.0.{version}"
);
var w10ipe = PackerTemplates_CreateWindows(
  "w10ipe",
  "windows-10-enterprise-insider-preview",
  $"2102.0.{version}"
);

var u1804s = PackerTemplates_CreateLinux(
  "u1804s",
  "ubuntu-server-1804-lts",
  $"1804.0.{version}",
  aliases: new [] { "ubuntu-server" }
);
var u1604s = PackerTemplates_CreateLinux(
  "u1604s",
  "ubuntu-server-1604-lts",
  $"1604.0.{version}",
  aliases: new [] { "ubuntu-server" }
);

var u1804d = PackerTemplates_CreateLinux(
  "u1804d",
  "ubuntu-desktop-1804-lts-xfce",
  $"1804.0.{version}",
  u1804s,
  aliases: new [] { "ubuntu-desktop" }
);
var u1604d = PackerTemplates_CreateLinux(
  "u1604d",
  "ubuntu-desktop-1604-lts-xfce",
  $"1604.0.{version}",
  u1604s,
  aliases: new [] { "ubuntu-desktop" }
);

var ws2022s_de = PackerTemplates_CreateWindows(
  "ws2022s-de",
  "docker-enterprise-windows-server-desktop",
  $"2010.2102.{version}",
  ws2022s,
  aliases: new [] { "docker-windows" }
);
var ws2019s_de = PackerTemplates_CreateWindows(
  "ws2019s-de",
  "docker-enterprise-windows-server-desktop",
  $"2010.1809.{version}",
  ws2019s,
  aliases: new [] { "docker-windows" }
);

var ws2022sc_de = PackerTemplates_CreateWindows(
  "ws2022sc-de",
  "docker-enterprise-windows-server-core",
  $"2010.2102.{version}",
  ws2022sc
);
var ws2019sc_de = PackerTemplates_CreateWindows(
  "ws2019sc-de",
  "docker-enterprise-windows-server-core",
  $"2010.1809.{version}",
  ws2019sc
);

var dc_w11 = PackerTemplates_CreateWindows(
  "w112102e-dc",
  "docker-desktop-windows-11",
  $"2010.2102.{version}",
  w112102e
);

var dc_w10 = PackerTemplates_CreateWindows(
  "w102102e-dc",
  "docker-desktop-windows-10",
  $"2010.2102.{version}",
  w102102e
);

var u1804s_dc = PackerTemplates_CreateLinux(
  "u1804s-dc",
  "docker-community-ubuntu-server",
  $"2010.1804.{version}",
  u1804s,
  aliases: new [] { "docker-linux" }
);
var u1604s_dc = PackerTemplates_CreateLinux(
  "u1604s-dc",
  "docker-community-ubuntu-server",
  $"2010.1604.{version}",
  u1604s,
  aliases: new [] { "docker-linux" }
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

var ws2022s_iis = PackerTemplates_CreateWindows(
  "ws2022s-iis",
  "iis-windows-server-desktop",
  $"10.2102.{version}",
  ws2022s,
  aliases: new [] { "iis" }
);
var ws2019s_iis = PackerTemplates_CreateWindows(
  "ws2019s-iis",
  "iis-windows-server-desktop",
  $"10.1809.{version}",
  ws2019s,
  aliases: new [] { "iis" }
);

var ws2022sc_iis = PackerTemplates_CreateWindows(
  "ws2022sc-iis",
  "iis-windows-server-core",
  $"10.2102.{version}",
  ws2022sc
);
var ws2019sc_iis = PackerTemplates_CreateWindows(
  "ws2019sc-iis",
  "iis-windows-server-core",
  $"10.1809.{version}",
  ws2019sc
);

var ws2022s_sql19d = PackerTemplates_CreateWindows(
  "ws2022s-sql19d",
  "sql-server-developer-windows-server-desktop",
  $"2019.2102.{version}",
  ws2022s,
  aliases: new [] { "sql-server" }
);
var ws2022s_sql17d = PackerTemplates_CreateWindows(
  "ws2022s-sql17d",
  "sql-server-developer-windows-server-desktop",
  $"2017.2102.{version}",
  ws2022s,
  aliases: new [] { "sql-server" }
);

var vs19c_w11 = PackerTemplates_CreateWindows(
  "w112102e-dc-vs19c",
  "visual-studio-2019-community-windows-11",
  $"2019.2102.{version}",
  dc_w11
);
var vs17c_w11 = PackerTemplates_CreateWindows(
  "w112102e-dc-vs17c",
  "visual-studio-2017-community-windows-11",
  $"2017.2102.{version}",
  dc_w11
);

var vs19c_w10 = PackerTemplates_CreateWindows(
  "w102102e-dc-vs19c",
  "visual-studio-community-windows-10",
  $"2019.2102.{version}",
  dc_w10,
  aliases: new [] { "visual-studio" }
);
var vs17c_w10 = PackerTemplates_CreateWindows(
  "w102102e-dc-vs17c",
  "visual-studio-community-windows-10",
  $"2017.2102.{version}",
  dc_w10,
  aliases: new [] { "visual-studio" }
);

var vs19p_w10 = PackerTemplates_CreateWindows(
  "w102102e-dc-vs19p",
  "visual-studio-professional-windows-10",
  $"2019.2102.{version}",
  dc_w10
);
var vs17p_w10 = PackerTemplates_CreateWindows(
  "w102102e-dc-vs17p",
  "visual-studio-professional-windows-10",
  $"2017.2102.{version}",
  dc_w10
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
