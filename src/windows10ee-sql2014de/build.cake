#load ../../lib/cake/build.cake

name = Argument("name", "windows10ee-sql2014de");
description = Argument("description", "Windows 10 Enterprise Evaluation with SQL Server 2014 Developer");

components = new List<string> { "windows10ee", "sql2014de" };
parent = "windows10ee";

RunTarget(target);
