#load "./components.cake"
#load "./providers.cake"

#addin "Cake.Json"
#addin "Cake.FileHelpers"

var configuration = Argument("Configuration", string.Empty);

Task("Configurations_Info")
  .Does(() => {
    Configurations_ForEach(Configuration_Info);
  });

Task("Configurations_Clean")
  .Does(() => {
    Configurations_ForEach(Configuration_Clean);
  });

Task("Configurations_Restore")
  .Does(() => {
    Configurations_ForEach(Configuration_Restore);
  });

Task("Configurations_Build")
  .IsDependentOn("Configurations_Restore")
  .Does(() => {
    Configurations_ForEach(Configuration_Build);
  });

Task("Configurations_Test")
  .IsDependentOn("Configurations_Build")
  .Does(() => {
    Configurations_ForEach(Configuration_Test);
  });

Task("Configurations_Package")
  .IsDependentOn("Configurations_Test")
  .Does(() => {
    Configurations_ForEach(Configuration_Package);
  });

Task("Configurations_Default")
  .IsDependentOn("Info");

var configurations = new List<Configuration>() {
  Configuration_Create("w10e.virtualbox", new [] { ".", "virtualbox", "chef", "vagrant" }),

  Configuration_Create("w10e-sql14d.virtualbox", new [] { ".", "virtualbox", "chef", "vagrant" }),

  Configuration_Create("w10e-sql14d-iis.virtualbox", new [] { ".", "virtualbox", "chef", "vagrant" }),
  Configuration_Create("w10e-sql14d-iis-vs15c.virtualbox", new [] { ".", "virtualbox", "chef", "vagrant" }),
  Configuration_Create("w10e-sql14d-iis-vs10p.virtualbox", new [] { ".", "virtualbox", "chef", "vagrant" }),
  Configuration_Create("w10e-sql14d-iis-vs10p-vs15p.virtualbox", new [] { ".", "virtualbox", "chef", "vagrant" }),
  
  Configuration_Create("w16s.virtualbox", new [] { ".", "virtualbox", "chef", "vagrant" }),
  Configuration_Create("w16s.amazon", new [] { ".", "amazon", "chef", "amazon-shell-shutdown" }),
  
  Configuration_Create("w16s-iis.virtualbox", new [] { ".", "virtualbox", "chef", "vagrant" }),
  Configuration_Create("w16s-iis.amazon", new [] { ".", "amazon", "chef", "amazon-shell-shutdown" }),

  Configuration_Create("w16s-sql14d.virtualbox", new [] { ".", "virtualbox", "chef", "vagrant" }),
  Configuration_Create("w16s-sql14d.amazon", new [] { ".", "amazon", "chef", "amazon-shell-shutdown" }),
  
  Configuration_Create("w16s-vs15c.virtualbox", new [] { ".", "virtualbox", "chef", "vagrant" }),
  Configuration_Create("w16s-vs15p.virtualbox", new [] { ".", "virtualbox", "chef", "vagrant" })
};

Configuration Configurations_GetByName(string name) {
  return configurations.FirstOrDefault(item => item.Name == name);
}

IEnumerable<Configuration> Configurations_GetMatching(string name) {
  return configurations.Where(item => item.IsMatching(name)).ToList();
}

void Configurations_ForEach(Action<Configuration> action) {
  foreach (var item in Configurations_GetMatching(configuration)) {
    action(item);
  }
}

class Configuration {
  public string Name { get; set; }
  public IEnumerable<Component> Components { get; set; }
  public Provider Provider { get; set; }
  public Func<Configuration> ParentResolver { get; set; }
  public IEnumerable<string> PackerComponents { get; set; }

  public bool IsMatching(string name) {
    return string.IsNullOrEmpty(name) || Name.Contains(name);
  }

  public Configuration GetParent() {
    return ParentResolver();
  }

  public string GetLogMessage(string message) {
    return Name + ": " + message;
  }

  public string GetBuildDirectory() {
    return "./build/" + Name;
  }

  public string GetTargetDirectory(string task) {
    return "./artifacts/" + Name + "/" + task;
  }

  public string GetTargetFilePattern(string task) {
    return GetTargetDirectory(task) + "/*." + Provider.NativeExtension;
  }

  public string GetBaseName() {
    return string.Join("-", Components.Select(item => item.Name));
  }

  public string GetDescription() {
    return string.Join(", ", Components.Select(item => item.Description));
  }

  public string GetBuilder(string task) {
    if (task == "package" || GetParent() != null) {
      return Provider.NativeBuilder;
    }

    return Provider.AlternativeBuilder;
  }
}

Configuration Configuration_Create(string name, IEnumerable<string> packerComponents) {
  var componentNames = name.Split('.')[0].Split('-');
  var components = componentNames.Select(Components_GetByName).ToList();

  var providerName = name.Split('.')[1];
  var provider = Providers_GetByName(providerName);

  Func<Configuration> parentResolver = () => null;
  if (componentNames.Length > 1) {
    var parentName = string.Join("-", componentNames.Reverse().Skip(1).Reverse()) + "." + providerName;
    parentResolver = () => Configurations_GetByName(parentName);
  }

  return new Configuration { Name = name, Components = components, Provider = provider, ParentResolver = parentResolver, PackerComponents = packerComponents };
}

void Configuration_Info(Configuration configuration) {
  Configuration_LogMessage(configuration, "Info");
}

void Configuration_Clean(Configuration configuration) {
  Configuration_LogMessage(configuration, "Clean");

  Configuration_CleanDirectory(configuration.GetBuildDirectory());
  Configuration_CleanDirectory(configuration.GetTargetDirectory("build"));
  Configuration_CleanDirectory(configuration.GetTargetDirectory("package"));
}

void Configuration_Restore(Configuration configuration) {
  Configuration_LogMessage(configuration, "Restore");
  
  if (DirectoryExists(configuration.GetBuildDirectory())) {
    return;
  }

  CreateDirectory(configuration.GetBuildDirectory());

  Configuration_MergeJson(configuration, "template.json");
  Configuration_MergeJson(configuration, "variables.json");

  Configuration_MergeDirectories(configuration, "host");
  Configuration_MergeDirectories(configuration, "floppy");
  Configuration_MergeDirectories(configuration, "disk");
  Configuration_MergeDirectories(configuration, "scripts");

  Configuration_Berkshelf(configuration, "package ../disk/cookbooks.tar.gz");
}

void Configuration_Build(Configuration configuration) {
  Configuration_LogMessage(configuration, "Build");

  var targetFile = Configuration_GetTargetFile(configuration, "build");
  if (targetFile != null) {
    return;
  }

  Packer(configuration, "build", "validate");
  Packer(configuration, "build", "build");
}

void Configuration_Test(Configuration configuration) {
  Configuration_LogMessage(configuration, "Test");
}

void Configuration_Package(Configuration configuration) {
  Configuration_LogMessage(configuration, "Package");

  var targetFile = Configuration_GetTargetFile(configuration, "package");
  if (targetFile != null) {
    return;
  }

  Packer(configuration, "package", "validate");
  Packer(configuration, "package", "build");
}

void Configuration_LogMessage(Configuration configuration, string message) {
  Information(configuration.GetLogMessage(message));
}

void Configuration_CleanDirectory(string path) {
  if (!DirectoryExists(path)) {
    return;
  }

  CleanDirectory(path);
  DeleteDirectory(path, true);
}

void Configuration_MergeJson(Configuration configuration, string fileName) {
  var merged = new JObject();
  foreach (var component in configuration.Components) {
    foreach (var sourceDirectory in GetDirectories("./src/*")) {
      var sourceDirectoryName = sourceDirectory.GetDirectoryName(); 
      if (!component.IsMatching(sourceDirectoryName)) {
        continue;
      }

      foreach (var packerComponent in configuration.PackerComponents) {
        foreach (var file in GetFiles(sourceDirectory + "/" + packerComponent + "/" + fileName)) {
          merged.Merge(ParseJsonFromFile(file));
        }
      }
    }
  }
  FileWriteText(configuration.GetBuildDirectory() + "/" + fileName, merged.ToString());
}

void Configuration_MergeDirectories(Configuration configuration, string directoryName) {
  var targetDirectory = configuration.GetBuildDirectory() + "/" + directoryName;
  EnsureDirectoryExists(targetDirectory);
  
  foreach (var component in configuration.Components) {
    foreach (var sourceDirectory in GetDirectories("./src/*")) {
      var sourceDirectoryName = sourceDirectory.GetDirectoryName(); 
      if (!component.IsMatching(sourceDirectoryName)) {
        continue;
      }

      foreach (var packerComponent in configuration.PackerComponents) {
        CopyFiles(sourceDirectory + "/" + packerComponent + "/" + directoryName + "/**/*", targetDirectory, true);
      }
    }
  }
}

FilePath Configuration_GetTargetFile(Configuration configuration, string task) {
  return GetFiles(configuration.GetTargetFilePattern(task)).FirstOrDefault();
}

FilePath Configuration_GetSourceFile(Configuration configuration, string task) {
  if (task == "package") {
    return GetFiles(configuration.GetTargetFilePattern("build")).FirstOrDefault();
  }

  if (configuration.GetParent() == null) {
    return null;
  }

  return GetFiles(configuration.GetParent().GetTargetFilePattern("build")).FirstOrDefault();  
}

void Configuration_Berkshelf(Configuration configuration, string arguments) {
  var result = StartProcess("C:/opscode/chefdk/bin/berks.bat", new ProcessSettings {
    Arguments = arguments,
    WorkingDirectory = configuration.GetBuildDirectory() + "/host"
  });
  if (result != 0) {
    throw new Exception("Process exited with code " + result + ".");
  }
}

void Packer(Configuration configuration, string task, string command) {
  var packerVarFiles = new [] { "variables.json" };

  var name = configuration.GetBaseName();
  var description = configuration.GetDescription();
  var sourceFile = Configuration_GetSourceFile(configuration, task);
  var outputDirectory = Directory(configuration.GetTargetDirectory(task));

  var packerVars = new Dictionary<string, string> {
    { "name", name },
    { "description", description },
    { "task", task },
    { "source_path", sourceFile != null ? MakeAbsolute(sourceFile).ToString() : "" },
    { "output_directory", MakeAbsolute(outputDirectory).ToString() }
  };

  Packer(configuration, command, "template.json", configuration.GetBuilder(task), packerVarFiles, packerVars);
}

void Packer(Configuration configuration, string command, string template, string builder, IEnumerable<string> varFiles, Dictionary<string, string> vars) {
  var options =
    "-only=\"" + builder + "\"" +
    " " + string.Join(" ", varFiles.Select(item => "-var-file=\"" + item + "\"")) +
    " " + string.Join(" ", vars.Select(item => "-var \"" + item.Key + "=" + item.Value + "\""));
  var result = StartProcess("packer", new ProcessSettings {
    Arguments = command + " " + options + " " + template,
    WorkingDirectory = configuration.GetBuildDirectory()
  });
  if (result != 0) {
    throw new Exception("Process exited with code " + result + ".");
  }
}
