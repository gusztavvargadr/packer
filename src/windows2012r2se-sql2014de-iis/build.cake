#load ../../lib/cake/build.cake

name = Argument("name", "windows2012r2se-sql2014de-iis");
description = Argument("description", "Windows Server 2012 R2 Standard Evaluation with SQL Server 2014 Developer and IIS");

components = new List<string> { "windows2012r2se", "sql2014de", "iis" };
parent = "windows2012r2se-sql2014de";

RunTarget(target);
