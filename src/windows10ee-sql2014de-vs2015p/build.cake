#load ../../lib/cake/build.cake

name = Argument("name", "windows10ee-sql2014de-vs2015p");
description = Argument("description", "Windows 10 Enterprise Evaluation with SQL Server 2014 Developer and Visual Studio 2015 Professional");

components = new List<string> { "windows10ee", "sql2014de", "vs2015p" };
parent = "windows10ee-sql2014de";

RunTarget(target);
