#load ../../lib/cake/build.cake

name = Argument("name", "windows10ee");
description = Argument("description", "Windows 10 Enterprise Evaluation");

components = new List<string> { "windows10ee" };
parent = string.Empty;

RunTarget(target);
