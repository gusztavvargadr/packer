#load ../../lib/cake/build.cake

name = Argument("name", "windows10ee-vs2010p");
description = Argument("description", "Windows 10 Enterprise Evaluation with Visual Studio 2010 Professional");

components = new List<string> { "windows10ee", "vs2010p" };
parent = "windows10ee";

RunTarget(target);
