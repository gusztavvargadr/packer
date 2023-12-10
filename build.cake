var target = Argument("target", "default");

var sample = Argument<string>("sample");
var image = Argument<string>("image");
var provider = Argument<string>("provider");
var build = Argument<string>("build");

var platform = (sample.Contains("ubuntu") || sample.Contains("linux")) ? "ubuntu" : "windows";

var sampleDirectory = Directory($"samples/{sample}");
var platformDirectory = Directory($"../../src/{platform}");

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

Task("default")
  .IsDependentOn("test");

RunTarget(target);

void PackerInit() {
  var arguments = new ProcessArgumentBuilder();

  arguments.Append("init");
  arguments.Append(platformDirectory);

  Packer(arguments.Render());
}

void PackerBuild(string stage) {
  var arguments = new ProcessArgumentBuilder();

  arguments.Append("build");
  arguments.Append($"-var-file=\"images.pkrvars.hcl\"");
  arguments.Append($"-var image=\"{image}\"");
  arguments.Append($"-var provider=\"{provider}\"");
  arguments.Append($"-var build=\"{build}\"");
  arguments.Append($"-only \"{build}-{stage}.*\"");
  arguments.Append("-force");
  arguments.Append(platformDirectory);

  Packer(arguments.Render());
}

void Packer(string arguments) {
  var result = StartProcess("packer", new ProcessSettings {
    Arguments = arguments,
    WorkingDirectory = sampleDirectory
  });
  
  if (result != 0) {
    throw new Exception($"Packer failed with code {result} .");
  }
}
