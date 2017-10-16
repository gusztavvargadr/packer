#load "./component.cake"
#load "./builder.cake"
#load "./provisioner.cake"
#load "./postprocessor.cake"

#addin "Cake.FileHelpers&version=1.0.4"
#addin "Cake.Json&version=1.0.2.13"

class PackerTemplate {
  public string Type { get; set; }
  public string Name { get; set; }
  public string FullName { get { return Type + "-" + Name; } }
  public IEnumerable<Component> Components { get; set; }
  public IEnumerable<PackerBuilder> Builders { get; set; }
  public IEnumerable<PackerProvisioner> Provisioners { get; set; }
  public IEnumerable<PackerPostProcessor> PostProcessors { get; set; }
  public PackerTemplate Parent { get; set; }

  public bool IsMatching(string name) {
    return string.IsNullOrEmpty(name) || FullName.Contains(name);
  }

  public string GetLogMessage(string message) {
    return FullName + ": " + message;
  }

  public string GetBuildDirectory() {
    return "build/" + Type + "/" + Name;
  }
}

PackerTemplate PackerTemplate_Create(
  string type,
  string name,
  IEnumerable<PackerBuilder> builders,
  IEnumerable<PackerProvisioner> provisioners,
  IEnumerable<PackerPostProcessor> postprocessors,
  PackerTemplate parent
) {
  var components = type.Split('-').Select(component => Component_Create(component)).ToList();

  return new PackerTemplate {
    Type = type,
    Name = name,
    Components = components,
    Builders = builders,
    Provisioners = provisioners,
    PostProcessors = postprocessors,
    Parent = parent
  };
}

void PackerTemplate_Info(PackerTemplate template) {
  PackerTemplate_Log(template, "Info");
}

void PackerTemplate_Clean(PackerTemplate template) {
  PackerTemplate_Log(template, "Clean");

  CleanDirectory(template.GetBuildDirectory());
  DeleteDirectory(template.GetBuildDirectory());
}

void PackerTemplate_Version(PackerTemplate template) {
  PackerTemplate_Log(template, "Version");
}

void PackerTemplate_Restore(PackerTemplate template) {
  PackerTemplate_Log(template, "Restore");

  if (DirectoryExists(template.GetBuildDirectory())) {
    return;
  }

  PackerTemplate_MergeDirectories(template);
  PackerTemplate_MergeJson(template);
}

void PackerTemplate_Build(PackerTemplate template) {
  PackerTemplate_Version(template);
  PackerTemplate_Restore(template);

  PackerTemplate_Log(template, "Build");

  if (FileExists(template.GetBuildDirectory() + "/manifest.json")) {
    return;
  }

  PackerTemplate_Packer(template, "build template.json");
}

void PackerTemplate_Rebuild(PackerTemplate template) {
  PackerTemplate_Clean(template);
  PackerTemplate_Build(template);

  PackerTemplate_Log(template, "Rebuild");
}

void PackerTemplate_Test(PackerTemplate template) {
  PackerTemplate_Build(template);

  PackerTemplate_Log(template, "Test");
}

void PackerTemplate_Package(PackerTemplate template) {
  PackerTemplate_Test(template);

  PackerTemplate_Log(template, "Package");
}

void PackerTemplate_Publish(PackerTemplate template) {
  PackerTemplate_Package(template);

  PackerTemplate_Log(template, "Publish");
}

void PackerTemplate_MergeDirectories(PackerTemplate template) {
  PackerTemplate_Log(template, "Merge Directories");

  foreach (var component in template.Components) {
    foreach (var sourceDirectory in GetDirectories("src/*")) {
      var sourceDirectoryName = sourceDirectory.GetDirectoryName();
      if (!component.IsMatching(sourceDirectoryName)) {
        continue;
      }

      foreach (var builder in template.Builders) {
        foreach (var builderDirectory in GetDirectories(sourceDirectory + "/packer/builders/*")) {
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
        foreach (var provisionerDirectory in GetDirectories(sourceDirectory + "/packer/provisioners/*")) {
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
        foreach (var postProcessorDirectory in GetDirectories(sourceDirectory + "/packer/postprocessors/*")) {
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
}

void PackerTemplate_MergeJson(PackerTemplate template) {
  var jsonFileName = "template.json";
  var jsonFile = template.GetBuildDirectory() + "/" + jsonFileName;

  PackerTemplate_Log(template, "Merge Json " + jsonFile);

  var json = new JObject();

  var jsonTemplateVariables = new JObject();
  jsonTemplateVariables["name"] = template.FullName;
  var buildDirectory = MakeAbsolute(Directory(template.GetBuildDirectory()));
  var parent = template.Parent;
  if (parent != null) {
    var parentBuildDirectory = MakeAbsolute(Directory(parent.GetBuildDirectory()));
    var manifestFile = parentBuildDirectory + "/manifest.json";
    if (FileExists(manifestFile)) {
      var manifest = ParseJsonFromFile(manifestFile);
      if (template.Builders.Any(item => item.IsMatching("virtualbox"))) {
        var parentBuildOutputFile = File(parentBuildDirectory + "/" + manifest["builds"][0]["files"][1]["name"].ToString());
        jsonTemplateVariables["virtualbox_source_path"] = buildDirectory.GetRelativePath(parentBuildOutputFile).ToString();
      }
      if (template.Builders.Any(item => item.IsMatching("hyperv"))) {
        var parentBuildOutputDirectory = parentBuildDirectory + "/output";
        jsonTemplateVariables["hyperv_clone_from_vmxc_path"] = parentBuildOutputDirectory;
      }
    }
  }
  var descriptions = new List<string>();
  var runList = new List<string>();
  
  foreach (var component in template.Components) {
    if (parent == null || !parent.Components.Any(item => item.Name == component.Name)) {
      runList.Add(component.Name);
    }

    foreach (var sourceDirectory in GetDirectories("src/*")) {
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
        foreach (var builderDirectory in GetDirectories(sourceDirectory + "/packer/builders/*")) {
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
        foreach (var provisionerDirectory in GetDirectories(sourceDirectory + "/packer/provisioners/*")) {
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
        foreach (var postProcessorDirectory in GetDirectories(sourceDirectory + "/packer/postprocessors/*")) {
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

  runList.AddRange(template.Builders.Select(item => item.Name));

  jsonTemplateVariables["description"] = string.Join(", ", descriptions);

  jsonTemplateVariables["chef_run_list_prepare"] = string.Join(",", runList.Select(item => "recipe[gusztavvargadr_packer_" + item.Replace("-", "_") + "::prepare]"));
  jsonTemplateVariables["chef_run_list_install"] = string.Join(",", runList.Select(item => "recipe[gusztavvargadr_packer_" + item.Replace("-", "_") + "::install]"));
  jsonTemplateVariables["chef_run_list_patch"] = string.Join(",", runList.Select(item => "recipe[gusztavvargadr_packer_" + item.Replace("-", "_") + "::patch]"));
  jsonTemplateVariables["chef_run_list_cleanup"] = string.Join(",", runList.Select(item => "recipe[gusztavvargadr_packer_" + item.Replace("-", "_") + "::cleanup]"));
  
  var jsonTemplate = new JObject();
  jsonTemplate["variables"] = jsonTemplateVariables;
  json.Merge(jsonTemplate);

  FileWriteText(jsonFile, json.ToString());
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

void PackerTemplate_Log(PackerTemplate template, string message) {
  Information(template.GetLogMessage(message));
}
