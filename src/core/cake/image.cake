#load "./components.cake"
#load "./template.cake"

class PackerImage {
  public string Name { get; set; }
  public string Description { get; set; }
  public string RootDirectory { get; set; }
  public IEnumerable<Component> Components { get; set; }
  public IEnumerable<PackerTemplate> Templates { get; set; }

  public string GetBuildDirectory() {
    return RootDirectory + "/build/" + Name;
  }
}

PackerImage PackerImage_Create(
  string name,
  string rootDirectory,
  IEnumerable<PackerTemplate> templates
) {
  var components = name.Split('-').Select(Components_GetByName).ToList();
  
  var image = new PackerImage {
    Name = name,
    Description = string.Join(", ", components.Select(item => item.Description)),
    RootDirectory = rootDirectory,
    Components = name.Split('-').Select(Components_GetByName).ToList(),
    Templates = templates.ToList()
  };
  foreach (var item in image.Templates) {
    item.Image = image;
  }
  return image;
}

void PackerImage_Info(PackerImage image, string template) {
  PackerImage_ForEachTemplate(image, template, PackerTemplate_Info);
}

void PackerImage_Clean(PackerImage image, string template) {
  PackerImage_ForEachTemplate(image, template, PackerTemplate_Clean);
}

void PackerImage_Version(PackerImage image, string template) {
  PackerImage_ForEachTemplate(image, template, PackerTemplate_Version);
}

void PackerImage_Restore(PackerImage image, string template) {
  PackerImage_ForEachTemplate(image, template, PackerTemplate_Restore);
}

void PackerImage_Build(PackerImage image, string template) {
  PackerImage_ForEachTemplate(image, template, PackerTemplate_Build);
}

void PackerImage_Test(PackerImage image, string template) {
}

void PackerImage_Package(PackerImage image, string template) {
}

void PackerImage_Publish(PackerImage image, string template) {
}

void PackerImage_ForEachTemplate(PackerImage image, string template, Action<PackerTemplate> action) {
  foreach (var t in image.Templates.Where(item => item.IsMatching(template))) {
    action(t);
  }
}
