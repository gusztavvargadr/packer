#load ../../lib/cake/build.cake

name = Argument("name", "windows2012r2se");
description = Argument("description", "Windows Server 2012 R2 Standard Evaluation");

components = new List<string> { "windows2012r2se" };
parent = string.Empty;

RunTarget(target);
