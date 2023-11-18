var target = Argument("target", "default");

var platform = Argument<string>("platform");
var sample = Argument<string>("sample");
var image = Argument<string>("image");
var provider = Argument<string>("provider");
var build = Argument<string>("build");

var version = "2311";

var rootDirectory = Directory(".");
var platformDirectory = Directory($"../../src/{platform}");
var sampleDirectory = Directory(sample);

Task("init")
  .Does(() => {
    PackerInit();
  });

Task("restore")
  .IsDependentOn("init")
  .Does(() => {
    PackerValidate("restore");
    PackerBuild("restore");
  });

Task("build")
  .IsDependentOn("restore")
  .Does(() => {
    PackerValidate("image");
    PackerBuild("image");
  });

Task("default")
  .IsDependentOn("build");

RunTarget(target);

void PackerInit() {
  var arguments = new ProcessArgumentBuilder();

  arguments.Append("init");
  arguments.Append(platformDirectory);

  Packer(arguments.Render());
}

void PackerValidate(string stage) {
  var arguments = new ProcessArgumentBuilder();

  arguments.Append("validate");
  arguments.Append($"-var-file=\"images.pkrvars.hcl\"");
  arguments.Append($"-var image=\"{image}\"");
  arguments.Append($"-var provider=\"{provider}\"");
  arguments.Append($"-var build=\"{build}\"");
  arguments.Append($"-only \"{build}-{stage}.*\"");
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
  Information($"Invoking 'packer {arguments}'.");

  var result = StartProcess("packer", new ProcessSettings {
    Arguments = arguments,
    WorkingDirectory = sampleDirectory
  });
  
  if (result != 0) {
    throw new Exception($"Process exited with code {result} .");
  }
}
