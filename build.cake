// todo: targets: clean, (restore), version, build, test, package, publish

var target = Argument("target", "Default");
var name = Argument("name", string.Empty);

var components = new List<Component>() {
  {
    new Component {
      Name = "w10e",
      Description = "Windows 10 Enterprise",
    }
  },
  {
    new Component {
      Name = "w12r2s",
      Description = "Windows Server 2012 R2 Standard"
    }
  }
};

var configurations = new List<Configuration>() {
  {
    new Configuration {
      Name = "w10e.virtualbox",
      Components = new [] { "w10e" },
      Builders = new [] { "virtualbox-iso" }
    }
  },
  {
    new Configuration {
      Name = "w12r2s.virtualbox",
      Components = new [] { "w12r2s" },
      Builders = new [] { "virtualbox-iso" }
    }
  }
};

Func<List<Configuration>> getSelectedConfigurations = () => {
  var items = new List<Configuration>();

  foreach (var item in configurations) {
    if (!item.Matches(name)) {
      continue;
    }

    items.Add(item);
  }

  return items;
};

class Component {
  public string Name { get; set; }
  public string Description { get; set; }

  public bool Matches(string name) {
    return Name.Contains(name);
  }
}

class Configuration {
  public string Name { get; set; }
  public IEnumerable<string> Components { get; set; }
  public IEnumerable<string> Builders { get; set; }

  public bool Matches(string name) {
    return string.IsNullOrEmpty(name) || Name.Contains(name);
  }

  public string GetActionLog(string action) {
    return Name + ": " + action;
  }

  public string GetBuildDirectory() {
    return "./build/" + Name;
  }

  public string GetArtifactsDirectory() {
    return "./artifacts/" + Name;
  }

  public string GetDescription(IEnumerable<Component> components) {
    return string.Join(", ", GetComponents(components).Select(item => item.Name));
  }

  public IEnumerable<Component> GetComponents(IEnumerable<Component> components) {
    return components.Where(item => Components.Contains(item.Name));
  }
}
 
Task("Default")
  .IsDependentOn("List");

Task("List")
  .Does(() => {
    ForEachSelectedConfiguration(List);
  });

Task("Clean")
  .Does(() => {
    ForEachSelectedConfiguration(Clean);
  });

Task("Build")
  .Does(() => {
    ForEachSelectedConfiguration(Build);
  });

RunTarget(target);

void ForEachSelectedConfiguration(Action<Configuration> action) {
  foreach (var item in getSelectedConfigurations()) {
    action(item);
  }
}

void List(Configuration configuration) {
  Information(configuration.GetActionLog("List"));
}

void Clean(Configuration configuration) {
  Information(configuration.GetActionLog("Clean"));

  if (DirectoryExists(configuration.GetBuildDirectory())) {
    CleanDirectory(configuration.GetBuildDirectory());
    DeleteDirectory(configuration.GetBuildDirectory(), true);
  }

  if (DirectoryExists(configuration.GetArtifactsDirectory())) {
    CleanDirectory(configuration.GetArtifactsDirectory());    
    DeleteDirectory(configuration.GetArtifactsDirectory(), true);
  }
}

void Build(Configuration configuration) {
  Information(configuration.GetActionLog("Build"));

  EnsureDirectoryExists(configuration.GetBuildDirectory());
  foreach (var component in configuration.GetComponents(components)) {
    foreach (var sourceDirectory in GetDirectories("./src/*")) {
      var sourceDirectoryName = sourceDirectory.GetDirectoryName(); 
      if (!component.Matches(sourceDirectoryName)) {
        continue;
      }

      CopyFiles("./src/" + sourceDirectoryName + "/**/*", configuration.GetBuildDirectory(), true);
    }
  }

  Berks(configuration, "package cookbooks.tar.gz");

  Packer(configuration, "validate");

  // Packer(configuration, "build");  
}

void Berks(Configuration configuration, string arguments) {
  Information(configuration.GetActionLog("Berks " + arguments));

  int result = StartProcess("C:/opscode/chefdk/bin/berks.bat", new ProcessSettings {
    Arguments = arguments,
    WorkingDirectory = configuration.GetBuildDirectory() + "/chef"
  });
  if (result != 0) {
    throw new Exception("Process exited with code " + result + ".");
  }
}

void Packer(Configuration configuration, string command) {
  Information(configuration.GetActionLog("Packer " + command));
  
  var packerVarFiles = GetFiles(configuration.GetBuildDirectory() + "/**/variables*.json").Select(item => item.ToString()).ToList();

  var description = configuration.GetDescription(components);
  // var sourcePath = output == "virtualbox"
  //   ? !string.IsNullOrEmpty(parent)
  //     ? GetFiles(rootDirectory + "/artifacts/" + parent + "/virtualbox/*.ovf").Single().ToString()
  //     : string.Empty
  //   : GetFiles(rootDirectory + "/artifacts/" + name + "/virtualbox/*.ovf").Single().ToString();
  var outputDirectory = MakeAbsolute(Directory(configuration.GetBuildDirectory())).GetRelativePath(MakeAbsolute(Directory(configuration.GetArtifactsDirectory()))).ToString();

  var packerVars = new Dictionary<string, string> {
    { "description", description },
    // { "source_path", sourcePath },
    { "output_directory", outputDirectory }
  };

  Packer(configuration, command, "template.json", packerVarFiles, packerVars);
}

void Packer(Configuration configuration, string command, string template, List<string> varFiles, Dictionary<string, string> vars) {
  var options =
    "-only=" + string.Join(",", configuration.Builders) +
    " " + string.Join(" ", varFiles.Select(item => "-var-file=\"" + item + "\"")) +
    " " + string.Join(" ", vars.Select(item => "-var \"" + item.Key + "=" + item.Value + "\""));
  int result = StartProcess("packer", new ProcessSettings {
    Arguments = command + " " + options + " " + template,
    WorkingDirectory = configuration.GetBuildDirectory()
  });
  if (result != 0) {
    throw new Exception("Process exited with code " + result + ".");
  }
}
