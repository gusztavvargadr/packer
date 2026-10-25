var configuration = Argument("configuration", string.Empty);
var target = Argument("target", "default");
var reportHostAndProvider = Argument("reportHostAndProvider", false);

var author = Argument("author", "gusztavvargadr");
var version = Argument("version", "2607.1.0");

var configurationParts = configuration.Split('/', StringSplitOptions.RemoveEmptyEntries);
var sample = configurationParts.ElementAtOrDefault(0) ?? Argument<string>("sample");
var image = configurationParts.ElementAtOrDefault(1) ?? Argument<string>("image");
var provider = configurationParts.ElementAtOrDefault(2) ?? Argument<string>("provider");
var build = configurationParts.ElementAtOrDefault(3) ?? Argument<string>("build");

var platform = (sample.Contains("ubuntu") || sample.Contains("linux")) ? "ubuntu" : "windows";

var sampleDirectory = Directory($"samples/{sample}");
var platformDirectory = Directory($"../../src/{platform}");
var artifactsDirectory = Directory($"artifacts");
var configurationImageDirectory = Directory($"artifacts/{sample}/{image}/{provider}/{build}/image");

Task("init")
  .Description("Validate archive tools and initialize the selected OS's Packer plugins.")
  .Does(() => {
    RunVersionCommand(IsRunningOnWindows() || IsRunningOnMacOs() ? "tar" : "bsdtar", "--version");
    RunVersionCommand("pigz", "--version");
    PackerInit();
  });

Task("restore-configuration")
  .Description("Run the selected Packer restore stage to prepare build dependencies.")
  .Does(() => {
    PackerBuild("restore");
  });

Task("restore-box")
  .Description("Repackage downloaded Vagrant image contents when present.")
  .WithCriteria(() => build == "vagrant" && DirectoryExists(configurationImageDirectory))
  .Does(() => {
    PackerBuild("restore-box");
  });

Task("restore")
  .Description("Prepare build dependencies and restore a downloaded Vagrant box when present.")
  .IsDependentOn("restore-configuration")
  .IsDependentOn("restore-box");

Task("build")
  .Description("Build the selected native image or package its native result as a Vagrant box.")
  .Does(() => {
    PackerBuild("build");
  });

Task("test")
  .Description("Run the selected Packer test stage; Vagrant boots the local box, while native is empty.")
  .Does(() => {
    PackerBuild("test");
  });

Task("publish")
  .Description("Publish Vagrant payloads to R2 and metadata to HCP; the native stage is empty.")
  .Does(() => {
    PackerBuild("publish");
  });

Task("download")
  .Description("Download and boot the published Vagrant box through its Packer download stage.")
  .Does(() => {
    PackerBuild("download");
  });

Task("clean")
  .Description("Remove all generated files under artifacts for every configuration.")
  .Does(() => {
    CleanDirectory(artifactsDirectory);
  });

Task("default")
  .Description("Initialize, restore, build, and test the selected configuration.")
  .IsDependentOn("init")
  .IsDependentOn("restore")
  .IsDependentOn("build")
  .IsDependentOn("test");

RunTarget(target);

void PackerInit() {
  ReportHostAndProvider();

  var arguments = new ProcessArgumentBuilder();

  arguments.Append("init");
  arguments.Append(platformDirectory);

  Packer(arguments);

  PackerPluginList();
}

void ReportHostAndProvider() {
  if (!reportHostAndProvider) {
    return;
  }

  if (!IsRunningOnMacOs()) {
    throw new Exception("Host and provider reporting requires macOS.");
  }

  RunVersionCommand("sw_vers");
  RunVersionCommand("uname", "-m");

  if (provider == "vmware") {
    var vmwareVmx = "/Applications/VMware Fusion.app/Contents/Library/vmware-vmx";
    RunVersionCommand(vmwareVmx, "-v");

    var vagrantVmwareUtility = "/opt/vagrant-vmware-desktop/bin/vagrant-vmware-utility";
    RunVersionCommand(vagrantVmwareUtility, "-version");
    return;
  }

  if (provider == "virtualbox") {
    RunVersionCommand("VBoxManage", "--version");
    return;
  }

  throw new Exception($"Host and provider reporting does not support {provider}.");
}

void PackerPluginList() {
  var arguments = new ProcessArgumentBuilder();

  arguments.Append("plugins installed");

  Packer(arguments);
}

void PackerBuild(string stage) {
  var arguments = new ProcessArgumentBuilder();

  arguments.Append("build");
  arguments.Append($"-var author=\"{author}\"");
  arguments.Append($"-var version=\"{version}\"");
  arguments.Append($"-var-file=\"images.pkrvars.hcl\"");
  arguments.Append($"-var image=\"{image}\"");
  arguments.Append($"-var provider=\"{provider}\"");
  arguments.Append($"-var build=\"{build}\"");
  arguments.Append($"-only \"{build}-{stage}.*\"");
  arguments.Append("-force");
  arguments.Append("-timestamp-ui");
  arguments.Append(platformDirectory);

  Packer(arguments);
}

void Packer(ProcessArgumentBuilder arguments) {
  var result = StartProcess("packer", new ProcessSettings {
    Arguments = arguments,
    WorkingDirectory = sampleDirectory
  });
  
  if (result != 0) {
    throw new Exception($"Packer failed with code {result} .");
  }
}

void RunVersionCommand(string executable, string argument = "") {
  var arguments = new ProcessArgumentBuilder();
  if (!string.IsNullOrEmpty(argument)) {
    arguments.Append(argument);
  }

  var result = StartProcess(executable, new ProcessSettings {
    Arguments = arguments
  });

  if (result != 0) {
    throw new Exception($"{executable} failed with code {result} .");
  }
}
