var components = new List<Component>() {
  Component_Create("w10e", "Windows 10 Enterprise"),
  Component_Create("w12r2s", "Windows Server 2012 R2 Standard"),
  Component_Create("w16s", "Windows Server 2016 Standard"),
  Component_Create("vs15c", "Visual Studio 2015 Community"),
  Component_Create("iis", "IIS")
};

Component Components_GetByName(string name) {
  return components.FirstOrDefault(item => item.Name == name);
}

class Component {
  public string Name { get; set; }
  public string Description { get; set; }

  public bool IsMatching(string name) {
    return string.IsNullOrEmpty(name) || Name.Contains(name);
  }
}

Component Component_Create(string name, string description) {
  return new Component { Name = name, Description = description };
}
