#load ../../lib/cake/build.cake

name = Argument("name", "windows10ee-vs2010p-vs2015p");
description = Argument("description", "Windows 10 Enterprise Evaluation with Visual Studio 2010 Professional and Visual Studio 2015 Professional");

components = new List<string> { "windows10ee", "vs2010p", "vs2015p" };
parent = "windows10ee-vs2010p";

RunTarget(target);
