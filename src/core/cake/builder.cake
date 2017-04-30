class PackerBuilder {
  public string Name { get; set; }

  public bool IsMatching(string name) {
    return Name.Contains(name);
  }
}

PackerBuilder PackerBuilder_Create(
  string name
) {
  return new PackerBuilder {
    Name = name
  };
}
