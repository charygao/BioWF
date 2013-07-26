Welcome to .NET Bio 1.1
Copyright (c) 2011-2013, The Outercurve Foundation. 

For the latest information, source code and updates please visit: http://bio.codeplex.com

The Samples folder contains examples in both C# and VB.NET. You can delete the specific 
source files which do not apply to your project. They will not hurt anything but NuGet does
not have an ability to restrict content within a package based on language so both are present. 

If you are using the full .NET Framework (not the client profile), there will be 
WebService support added to your project through the Bio.WebServiceHandlers.dll assembly.  
There are examples of using this in the BioUtilities.Blast.vb/cs files but they are currently 
commented out as there is no way to include content based on the target framework with NuGet 
currently.  You will need to uncomment those functions if you'd like to use them and you will 
also need a reference to the System.Web assembly if you don't have one already.



