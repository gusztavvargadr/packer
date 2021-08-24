#load "./component.cake"
#load "./builder.cake"
#load "./provisioner.cake"
#load "./postprocessor.cake"

class PackerTemplate {
  public static string BuildDirectory { get; set; }

  public string Name { get; set; }
  public string Type { get; set; }
  public string FullName { get { return Name + "-" + Type; } }
  public IEnumerable<Component> Components { get; set; }
  public IEnumerable<PackerBuilder> Builders { get; set; }
  public IEnumerable<PackerProvisioner> Provisioners { get; set; }
  public IEnumerable<PackerPostProcessor> PostProcessors { get; set; }
  public PackerTemplate Parent { get; set; }
  public string GroupName { get; set; }
  public string GroupVersion { get; set; }

  public bool IsMatching(string name) {
    return string.IsNullOrEmpty(name) || FullName.Contains(name);
  }

  public string GetLogMessage(string message) {
    return FullName + ": " + message;
  }

  public string GetBuildDirectory() {
    return BuildDirectory + "/" + Name + "/" + Type;
  }
}

PackerTemplate PackerTemplate_Create(
  string name,
  string type,
  IEnumerable<PackerBuilder> builders,
  IEnumerable<PackerProvisioner> provisioners,
  IEnumerable<PackerPostProcessor> postprocessors,
  PackerTemplate parent,
  string groupName = null,
  string groupVersion = null
) {
  var components = name.Split('-').Select(component => Component_Create(component)).ToList();

  return new PackerTemplate {
    Name = name,
    Type = type,
    Components = components,
    Builders = builders,
    Provisioners = provisioners,
    PostProcessors = postprocessors,
    Parent = parent,
    GroupName = groupName,
    GroupVersion = groupVersion
  };
}

void PackerTemplate_Info(PackerTemplate template) {
  PackerTemplate_Log(template, "Info");
}

void PackerTemplate_Version(PackerTemplate template) {
  PackerTemplate_Log(template, "Version");
}

void PackerTemplate_Restore(PackerTemplate template) {
  PackerTemplate_Log(template, "Restore");

  if (FileExists(template.GetBuildDirectory() + "/template.json")) {
    return;
  }

  CleanDirectory(template.GetBuildDirectory());

  if (template.Parent != null) {
    PackerTemplate_Restore(template.Parent);
    PackerTemplate_Build(template.Parent);
  }

  PackerTemplate_MergeDirectories(template);
  PackerTemplate_MergeJson(template);

  PackerTemplate_Packer(template, "validate template.json");
}

void PackerTemplate_Build(PackerTemplate template) {
  PackerTemplate_Log(template, "Build");

  if (FileExists(template.GetBuildDirectory() + "/output/build/manifest.json")) {
    return;
  }

  if (FileExists(template.GetBuildDirectory() + "/output/package/vagrant.box")) {
    return;
  }

  PackerTemplate_Packer(template, "build template.json");
}

void PackerTemplate_Test(PackerTemplate template) {
  PackerTemplate_Log(template, "Test");

  if (!template.Type.Contains("vagrant")) {
    return;
  }

  var provider = template.Type.Split('-')[0];
  var vmName = $"{template.Name}-build";
  var boxName = $"gusztavvargadr/{template.Name}-build";
  var boxAddress = $"file://{template.GetBuildDirectory()}/output/package/vagrant.box";

  try {
    PackerTemplate_Vagrant(template, $"box add {boxAddress} --name {boxName}");
    PackerTemplate_Vagrant(template, $"up {vmName} --provider {provider}", vmName, boxName);
  } finally {
    PackerTemplate_Vagrant(template, $"destroy {vmName} --force", vmName, boxName);
    PackerTemplate_Vagrant(template, $"box remove {boxName} --provider {provider}");
  }
}

void PackerTemplate_Package(PackerTemplate template) {
  PackerTemplate_Log(template, "Package");
}

void PackerTemplate_Publish(PackerTemplate template) {
  PackerTemplate_Log(template, "Publish");

  if (!template.Type.Contains("vagrant")) {
    return;
  }

  var provider = template.Type.Split('-')[0];

  var boxChecksum = string.Empty;
  var checksumFile = $"{template.GetBuildDirectory()}/output/package/checksum.sha256";
  foreach (var checksumLine in FileReadLines(checksumFile)) {
    var checksumParts = checksumLine.Split('\t');
    if (checksumParts[1] == "vagrant.box") {
      boxChecksum = checksumParts[0];
      break;
    }
  }

  try {
    PackerTemplate_Vagrant(template, "cloud publish --force"
      + $" --checksum-type sha256"
      + $" --checksum {boxChecksum}"
      + $" gusztavvargadr/{template.GroupName}"
      + $" {template.GroupVersion}"
      + $" {provider}"
      + $" {template.GetBuildDirectory()}/output/package/vagrant.box"
    );
  } catch (Exception ex) {
    Information($"Error publishing: '{ex.Message}'.");
  }
}

void PackerTemplate_Download(PackerTemplate template) {
  PackerTemplate_Log(template, "Download");

  if (!template.Type.Contains("vagrant")) {
    return;
  }

  var provider = template.Type.Split('-')[0];
  var vmName = $"{template.Name}-publish";
  var boxName = $"gusztavvargadr/{template.GroupName}";
  var boxVersion = template.GroupVersion;

  var downloadWaitMinutes = new [] { 0, 1, 2, 5, 10 };
  var downloadSucceeded = false;

  foreach (var downloadWaitMinute in downloadWaitMinutes) {
    Information($"Waiting {downloadWaitMinute} minutes before retry.");
    System.Threading.Thread.Sleep(TimeSpan.FromMinutes(downloadWaitMinute));

    try {
      PackerTemplate_Vagrant(template, $"up {vmName} --provider {provider}", vmName, boxName, boxVersion);

      downloadSucceeded = true;
      break;
    } catch (Exception ex) {
      Information($"Error downloading: '{ex.Message}'.");
    } finally {
      try {
        PackerTemplate_Vagrant(template, $"destroy {vmName} --force", vmName, boxName, boxVersion);
        PackerTemplate_Vagrant(template, $"box remove {boxName} --provider {provider} --box-version {boxVersion}");
      } catch (Exception ex) {
        Information($"Error cleaning up: '{ex.Message}'.");
      }
    }
  }

  if (!downloadSucceeded) {
    throw new Exception("Error downloading.");
  }
}

void PackerTemplate_Clean(PackerTemplate template) {
  PackerTemplate_Log(template, "Clean");

  CleanDirectory(template.GetBuildDirectory());
  DeleteDirectory(template.GetBuildDirectory(), new DeleteDirectorySettings { Recursive = true, Force = true });
}

void PackerTemplate_Log(PackerTemplate template, string message) {
  Information(template.GetLogMessage(message));
}

void PackerTemplate_MergeDirectories(PackerTemplate template) {
  PackerTemplate_Log(template, "Merge Directories");

  foreach (var component in template.Components) {
    foreach (var sourceDirectory in PackerTemplate_GetDirectories("src/*")) {
      var sourceDirectoryName = sourceDirectory.GetDirectoryName();
      if (!component.IsMatching(sourceDirectoryName)) {
        continue;
      }

      foreach (var builder in template.Builders) {
        foreach (var builderDirectory in PackerTemplate_GetDirectories(sourceDirectory + "/packer/builders/*")) {
          var builderDirectoryName = builderDirectory.GetDirectoryName();
          if (!builder.IsMatching(builderDirectoryName)) {
            continue;
          }

          var targetDirecory = template.GetBuildDirectory() + "/builders/" + builder.Name;
          EnsureDirectoryExists(targetDirecory);
          CopyFiles(builderDirectory + "/**/*", targetDirecory, true);
        }
      }

      foreach (var provisioner in template.Provisioners) {
        foreach (var provisionerDirectory in PackerTemplate_GetDirectories(sourceDirectory + "/packer/provisioners/*")) {
          var provisionerDirectoryName = provisionerDirectory.GetDirectoryName();
          if (!provisioner.IsMatching(provisionerDirectoryName)) {
            continue;
          }

          var targetDirecory = template.GetBuildDirectory() + "/provisioners/" + provisioner.Name;
          EnsureDirectoryExists(targetDirecory);
          CopyFiles(provisionerDirectory + "/**/*", targetDirecory, true);
        }
      }

      foreach (var postProcessor in template.PostProcessors) {
        foreach (var postProcessorDirectory in PackerTemplate_GetDirectories(sourceDirectory + "/packer/postprocessors/*")) {
          var postProcessorDirectoryName = postProcessorDirectory.GetDirectoryName();
          if (!postProcessor.IsMatching(postProcessorDirectoryName)) {
            continue;
          }

          var targetDirecory = template.GetBuildDirectory() + "/postprocessors/" + postProcessor.Name;
          EnsureDirectoryExists(targetDirecory);
          CopyFiles(postProcessorDirectory + "/**/*", targetDirecory, true);
        }
      }
    }
  }

  DeleteFiles(template.GetBuildDirectory() + "/**/template.json");

  var buildDirectory = MakeAbsolute(Directory(template.GetBuildDirectory()));
  foreach (var policyFile in GetFiles(template.GetBuildDirectory() + "/**/Policyfile.rb")) {
      var policyPath = "./" + buildDirectory.GetRelativePath(policyFile);
      
      PackerTemplate_Chef(template, "install " + policyPath);
      PackerTemplate_Chef(template, "export " + File(policyPath).Path.GetDirectory() + "/Policyfile.lock.json " + File(policyPath).Path.GetDirectory() + "/upload");
  }
}

void PackerTemplate_MergeJson(PackerTemplate template) {
  var jsonFileName = "template.json";
  var jsonFile = template.GetBuildDirectory() + "/" + jsonFileName;

  PackerTemplate_Log(template, "Merge Json " + jsonFile);

  var json = new JObject();

  var jsonTemplateVariables = new JObject();
  jsonTemplateVariables["name"] = template.Name;
  var buildDirectory = MakeAbsolute(Directory(template.GetBuildDirectory()));
  var parent = template.Parent;
  if (parent != null) {
    var parentBuildDirectory = MakeAbsolute(Directory(parent.GetBuildDirectory()));
    var manifestFile = parentBuildDirectory + "/output/build/manifest.json";
    if (!FileExists(manifestFile)) {
      throw new Exception("Manifest missing at '" + manifestFile + "'.");
    }

    var manifest = ParseJsonFromFile(manifestFile);
    if (template.Builders.Any(item => item.IsMatching("virtualbox"))) {
      var parentBuildOutputFile = File(parentBuildDirectory + "/" + manifest["builds"][0]["files"][1]["name"].ToString());
      jsonTemplateVariables["virtualbox_source_path"] = buildDirectory.GetRelativePath(parentBuildOutputFile).ToString();
    }
    if (template.Builders.Any(item => item.IsMatching("hyperv"))) {
      var parentBuildOutputDirectory = parentBuildDirectory + "/output/build";
      jsonTemplateVariables["hyperv_clone_from_vmcx_path"] = parentBuildOutputDirectory;
    }
    if (template.Builders.Any(item => item.IsMatching("azure"))) {
      var artifactId = manifest["builds"][0]["artifact_id"].ToString();
      jsonTemplateVariables["azure_image_name"] = artifactId.Split('/').Last();
    }
  }
  var descriptions = new List<string>();
  var runList = new List<string>();
  
  foreach (var component in template.Components) {
    if (parent == null || !parent.Components.Any(item => item.Name == component.Name)) {
      runList.Add(component.Name);
    }

    foreach (var sourceDirectory in PackerTemplate_GetDirectories("src/*")) {
      var sourceDirectoryName = sourceDirectory.GetDirectoryName();
      if (!component.IsMatching(sourceDirectoryName)) {
        continue;
      }

      foreach (var file in GetFiles(sourceDirectory + "/packer/" + jsonFileName)) {
        json.Merge(ParseJsonFromFile(file));
      }
      var description = json["variables"]["description"].ToString();
      if (!string.IsNullOrEmpty(description)) {
        descriptions.Add(description);
      }

      foreach (var builder in template.Builders) {
        foreach (var builderDirectory in PackerTemplate_GetDirectories(sourceDirectory + "/packer/builders/*")) {
          var builderDirectoryName = builderDirectory.GetDirectoryName();
          if (!builder.IsMatching(builderDirectoryName)) {
            continue;
          }

          foreach (var file in GetFiles(builderDirectory + "/" + jsonFileName)) {
            json.Merge(ParseJsonFromFile(file));
          }
        }
      }

      foreach (var provisioner in template.Provisioners) {
        foreach (var provisionerDirectory in PackerTemplate_GetDirectories(sourceDirectory + "/packer/provisioners/*")) {
          var provisionerDirectoryName = provisionerDirectory.GetDirectoryName();
          if (!provisioner.IsMatching(provisionerDirectoryName)) {
            continue;
          }

          foreach (var file in GetFiles(provisionerDirectory + "/" + jsonFileName)) {
            json.Merge(ParseJsonFromFile(file));
          }
        }
      }

      foreach (var postProcessor in template.PostProcessors) {
        foreach (var postProcessorDirectory in PackerTemplate_GetDirectories(sourceDirectory + "/packer/postprocessors/*")) {
          var postProcessorDirectoryName = postProcessorDirectory.GetDirectoryName();
          if (!postProcessor.IsMatching(postProcessorDirectoryName)) {
            continue;
          }

          foreach (var file in GetFiles(postProcessorDirectory + "/" + jsonFileName)) {
            json.Merge(ParseJsonFromFile(file));
          }
        }
      }
    }
  }

  jsonTemplateVariables["version"] = version + ".0.0";
  jsonTemplateVariables["description"] = string.Join(", ", descriptions);

  var environentVariableKeyPrefix = "PACKER_VAR_";
  foreach (var environmentVariable in EnvironmentVariables()) {
    if (environmentVariable.Key.StartsWith(environentVariableKeyPrefix)) {
      jsonTemplateVariables[environmentVariable.Key.Substring(environentVariableKeyPrefix.Length)] = environmentVariable.Value;
    }
  }

  var jsonTemplate = new JObject();
  jsonTemplate["variables"] = jsonTemplateVariables;
  json.Merge(jsonTemplate);

  FileWriteText(jsonFile, json.ToString());
}

IEnumerable<DirectoryPath> PackerTemplate_GetDirectories(GlobPattern pattern) {
  return GetDirectories(pattern).OrderBy(item => item.GetDirectoryName());
}

void PackerTemplate_Packer(PackerTemplate template, string arguments) {
  PackerTemplate_Log(template, "Packer " + arguments);

  var result = StartProcess("packer", new ProcessSettings {
    Arguments = arguments,
    WorkingDirectory = template.GetBuildDirectory()
  });
  
  if (result != 0) {
    throw new Exception("Process exited with code " + result + ".");
  }
}

void PackerTemplate_Vagrant(PackerTemplate template, string arguments, string vmName = "", string boxName = "", string boxVersion = "") {
  PackerTemplate_Log(template, "Vagrant " + arguments);

  var result = StartProcess("vagrant", new ProcessSettings {
    Arguments = arguments,
    EnvironmentVariables = new Dictionary<string, string> { 
      { "VAGRANT_VM_NAME", vmName },
      { "VAGRANT_BOX_NAME", boxName },
      { "VAGRANT_BOX_VERSION", boxVersion },
    }
  });
  
  if (result != 0) {
    throw new Exception("Process exited with code " + result + ".");
  }
}

void PackerTemplate_Chef(PackerTemplate template, string arguments) {
  PackerTemplate_Log(template, "Chef " + arguments);

  var result = StartProcess("chef", new ProcessSettings {
    Arguments = arguments
  });
  
  if (result != 0) {
    throw new Exception("Process exited with code " + result + ".");
  }
}
