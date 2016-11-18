#load ../../lib/cake/build.cake

name = Argument("name", "windows10ee-vs2015c");
description = Argument("description", "Windows 10 Enterprise Evaluation with Visual Studio 2015 Community");

components = new List<string> { "windows10ee", "vs2015c" };
parent = "windows10ee";

RunTarget(target);
