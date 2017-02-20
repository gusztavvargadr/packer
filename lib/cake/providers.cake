var providers = new List<Provider>() {
  Provider_Create("amazon", "", "amazon-ebs", "amazon-ebs" ),
  Provider_Create("virtualbox", "ovf", "virtualbox-ovf", "virtualbox-iso" )
};

Provider Providers_GetByName(string name) {
  return providers.FirstOrDefault(item => item.Name == name);
}

class Provider {
  public string Name { get; set; }
  public string NativeExtension { get; set; }
  public string NativeBuilder { get; set; }
  public string AlternativeBuilder { get; set; }
}

Provider Provider_Create(string name, string nativeExtension, string nativeBuilder, string alternativeBuilder) {
  return new Provider { Name = name, NativeExtension = nativeExtension, NativeBuilder = nativeBuilder, AlternativeBuilder = alternativeBuilder };
}
