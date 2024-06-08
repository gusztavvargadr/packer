var configuration = Argument("configuration", string.Empty);
var target = Argument("target", "default");

var author = Argument("author", "gusztavvargadr");
var version = Argument("version", "2405");

var configurationParts = configuration.Split('/', StringSplitOptions.RemoveEmptyEntries);
var sample = configurationParts.ElementAtOrDefault(0) ?? Argument<string>("sample");
var image = configurationParts.ElementAtOrDefault(1) ?? Argument<string>("image");
var provider = configurationParts.ElementAtOrDefault(2) ?? Argument<string>("provider");
var build = configurationParts.ElementAtOrDefault(3) ?? Argument<string>("build");

var platform = (sample.Contains("ubuntu") || sample.Contains("linux")) ? "ubuntu" : "windows";

var sampleDirectory = Directory($"samples/{sample}");
var platformDirectory = Directory($"../../src/{platform}");
var artifactsDirectory = Directory($"artifacts");

Task("init")
  .Does(() => {
    PackerInit();
  });

Task("restore")
  .IsDependentOn("init")
  .Does(() => {
    PackerBuild("restore");
  });

Task("build")
  .IsDependentOn("restore")
  .Does(() => {
    PackerBuild("build");
  });

Task("test")
  .IsDependentOn("build")
  .Does(() => {
    PackerBuild("test");
  });

Task("publish")
  .IsDependentOn("test")
  .Does(() => {
    PackerBuild("publish");
  });

Task("clean")
  .Does(() => {
    CleanDirectory(artifactsDirectory);
  });

Task("default")
  .IsDependentOn("test");

RunTarget(target);

void PackerInit() {
  var arguments = new ProcessArgumentBuilder();

  arguments.Append("init");
  arguments.Append(platformDirectory);

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
