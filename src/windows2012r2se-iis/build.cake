#load ../../lib/cake/build.cake

name = Argument("name", "windows2012r2se-iis");
description = Argument("description", "Windows Server 2012 R2 Standard Evaluation with IIS");

components = new List<string> { "windows2012r2se", "iis" };
parent = "windows2012r2se";

RunTarget(target);
