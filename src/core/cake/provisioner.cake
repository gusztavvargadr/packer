class PackerProvisioner {
  public string Name { get; set; }

  public bool IsMatching(string name) {
    return Name.Contains(name);
  }
}

PackerProvisioner PackerProvisioner_Create(
  string name
) {
  return new PackerProvisioner {
    Name = name
  };
}
