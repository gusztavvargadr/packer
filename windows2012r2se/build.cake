#load ../build.cake

Task("default")
  .IsDependentOn("packer-build");

RunTarget(target);
