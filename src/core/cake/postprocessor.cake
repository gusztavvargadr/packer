class PackerPostProcessor {
  public string Name { get; set; }

  public bool IsMatching(string name) {
    return Name.Contains(name);
  }
}

PackerPostProcessor PackerPostProcessor_Create(
  string name
) {
  return new PackerPostProcessor {
    Name = name
  };
}
