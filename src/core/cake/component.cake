class Component {
  public string Name { get; set; }

  public bool IsMatching(string name) {
    return string.IsNullOrEmpty(name) || Name.Contains(name);
  }
}

Component Component_Create(string name) {
  return new Component { Name = name };
}
