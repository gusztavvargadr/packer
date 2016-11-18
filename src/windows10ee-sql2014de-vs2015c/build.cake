#load ../../lib/cake/build.cake

name = Argument("name", "windows10ee-sql2014de-vs2015c");
description = Argument("description", "Windows 10 Enterprise Evaluation with SQL Server 2014 Developer and Visual Studio 2015 Community");

components = new List<string> { "windows10ee", "sql2014de", "vs2015c" };
parent = "windows10ee-sql2014de";

RunTarget(target);
