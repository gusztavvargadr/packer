#load "./builder.cake"
#load "./provisioner.cake"
#load "./postprocessor.cake"

#addin "Cake.FileHelpers"
#addin "Cake.Json"

class PackerTemplate {
  public PackerImage Image { get; set; }
  public string Name { get; set; }
  public IEnumerable<PackerBuilder> Builders { get; set; }
  public IEnumerable<PackerProvisioner> Provisioners { get; set; }
  public IEnumerable<PackerPostProcessor> PostProcessors { get; set; }

  public string ParentImageName { get; set; }
  public string ParentTemplateName { get; set; }

  public bool IsMatching(string name) {
    return string.IsNullOrEmpty(name) || Name.Contains(name);
  }

  public string GetLogMessage(string message) {
    return Name + ": " + message;
  }

  public string GetBuildDirectory() {
    return Image.GetBuildDirectory() + "/" + Name;
  }

  public string GetInputDirectory() {
    return Image.RootDirectory + "/build/" + ParentImageName + "/" + ParentTemplateName + "/output";
  }

  public string GetOutputDirectory() {
    return GetBuildDirectory() + "/output";
  }
}

PackerTemplate PackerTemplate_Create(
  string name,
  IEnumerable<PackerBuilder> builders,
  IEnumerable<PackerProvisioner> provisioners,
  IEnumerable<PackerPostProcessor> postprocessors,
  string parentImageName,
  string parentTemplateName
) {
  return new PackerTemplate {
    Name = name,
    Builders = builders,
    Provisioners = provisioners,
    PostProcessors = postprocessors,
    ParentImageName = parentImageName,
    ParentTemplateName = parentTemplateName
  };
}

void PackerTemplate_Info(PackerTemplate template) {
  PackerTemplate_Log(template, "Info");
}

void PackerTemplate_Clean(PackerTemplate template) {
  PackerTemplate_Log(template, "Clean");

  var buildDirectory = template.GetBuildDirectory();
  CleanDirectory(buildDirectory);
}

void PackerTemplate_Version(PackerTemplate template) {
  PackerTemplate_Log(template, "Version");
}

void PackerTemplate_Restore(PackerTemplate template) {
  PackerTemplate_Log(template, "Restore");

  var buildDirectory = template.GetBuildDirectory();
  EnsureDirectoryExists(buildDirectory);

  PackerTemplate_MergeDirectories(template);
  PackerTemplate_Berkshelf(template, "package cookbooks.tar.gz");
  PackerTemplate_MergeJson(template);

  PackerTemplate_Packer(template, "validate template.json");  
}

void PackerTemplate_Build(PackerTemplate template) {
  PackerTemplate_Log(template, "Build");

  var outputDirectory = template.GetOutputDirectory();
  if (DirectoryExists(outputDirectory)) {
    return;
  }

  PackerTemplate_Packer(template, "build template.json");
}

void PackerTemplate_MergeDirectories(PackerTemplate template) {
  PackerTemplate_Log(template, "Merge Directories");

  foreach (var component in template.Image.Components) {
    foreach (var sourceDirectory in GetDirectories("../core/packer/*")) {
      var sourceDirectoryName = sourceDirectory.GetDirectoryName();
      if (!component.IsMatching(sourceDirectoryName)) {
        continue;
      }

      foreach (var builder in template.Builders) {
        foreach (var builderDirectory in GetDirectories(sourceDirectory + "/builders/*")) {
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
        foreach (var provisionerDirectory in GetDirectories(sourceDirectory + "/provisioners/*")) {
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
        foreach (var postProcessorDirectory in GetDirectories(sourceDirectory + "/postprocessors/*")) {
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

void PackerTemplate_Berkshelf(PackerTemplate template, string arguments) {
  PackerTemplate_Log(template, "Berkshelf " + arguments);

  var berksDirectory = template.GetBuildDirectory() + "/provisioners/chef";
  if (!FileExists(berksDirectory + "/Berksfile")) {
    return;
  }

  var result = StartProcess("C:/opscode/chefdk/bin/berks.bat", new ProcessSettings {
    Arguments = arguments,
    WorkingDirectory = berksDirectory
  });
  if (result != 0) {
    throw new Exception("Process exited with code " + result + ".");
  }
}

void PackerTemplate_MergeJson(PackerTemplate template) {
  var jsonFileName = "template.json";
  var jsonFile = template.GetBuildDirectory() + "/" + jsonFileName;

  PackerTemplate_Log(template, "Merge Json " + jsonFile);

  var json = new JObject();
  foreach (var component in template.Image.Components) {
    foreach (var sourceDirectory in GetDirectories("../core/packer/*")) {
      var sourceDirectoryName = sourceDirectory.GetDirectoryName();
      if (!component.IsMatching(sourceDirectoryName)) {
        continue;
      }

      foreach (var file in GetFiles(sourceDirectory + "/" + jsonFileName)) {
        json.Merge(ParseJsonFromFile(file));
      }

      var jsonTemplateVariables = new JObject();
      jsonTemplateVariables["name"] = template.Image.Name;
      jsonTemplateVariables["description"] = template.Image.Description;
      jsonTemplateVariables["version"] = "0.0.0";
      jsonTemplateVariables["input_directory"] = MakeAbsolute(Directory(template.GetBuildDirectory())).GetRelativePath(MakeAbsolute(Directory(template.GetInputDirectory()))).ToString();
      jsonTemplateVariables["output_directory"] = MakeAbsolute(Directory(template.GetBuildDirectory())).GetRelativePath(MakeAbsolute(Directory(template.GetOutputDirectory()))).ToString();
      
      var runList = new List<string>();
      runList.AddRange(template.Builders.Select(item => item.Name));
      runList.Add(template.Image.Components.Last().Name);
      jsonTemplateVariables["chef_run_list"] = string.Join(",", runList.Select(item => "role[gusztavvargadr_packer_" + item.Replace("-", "_") + "]"));
      
      var jsonTemplate = new JObject();
      jsonTemplate["variables"] = jsonTemplateVariables;
      json.Merge(jsonTemplate);

      foreach (var builder in template.Builders) {
        foreach (var builderDirectory in GetDirectories(sourceDirectory + "/builders/*")) {
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
        foreach (var provisionerDirectory in GetDirectories(sourceDirectory + "/provisioners/*")) {
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
        foreach (var postProcessorDirectory in GetDirectories(sourceDirectory + "/postprocessors/*")) {
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
