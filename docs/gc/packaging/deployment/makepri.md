---
author: M-Stahl
title: Make package resource index (makepri.exe)
description: Creates, dumps, and performs utility functions on package resource index (PRI) files.
kindex:
- Make package resource index (makepri.exe)
- makepri.exe
ms.author: scotmi
ms.topic: conceptual
edited: 10/30/2019
security: public
---

# Make package resource index (MakePRI.exe)
   
  
MakePRI.exe is a command-line tool used for creating and dumping package resource index (PRI) files and for performing utility functions on them. 
   
  
MakePRI provides the following subcommands and functions.  
 
<table> 
<tr> <th>

Command</th> <th>

Description</th> </tr>
 
<tr> <td><a href="#makepri_createconfig">makepri createconfig</a></td> <td>Creates a PRI configuration file for use with other commands </td> </tr>
 
<tr> <td> <a href="#makepri_new">makepri new</a> </td> <td>Creates a new PRI file from scratch </td> </tr>
 
<tr> <td> <a href="#makepri_versioned">makepri versioned</a> </td> <td>Creates a PRI file that's based on a previous version </td> </tr>
 
<tr> <td> <a href="#makepri_resourcepack">makepri resourcepack</a> </td> <td>Creates a PRI file that contains additional resource variants for a base PRI </td> </tr>
 
<tr> <td> <a href="#makepri_dump">makepri dump</a> </td> <td>Dumps the contents of a PRI file </td> </tr>
 </table>

 

 

 
<a id="makepri_createconfig"></a>

   

## makepri createconfig  
   
  
MakePRI.exe createconfig creates a PRI configuration file at the [config file destination], with default qualifiers specified by the [default qualifiers].   
 
<table>
<tr><td><code>makepri createconfig </code><i>/cf &lt;filepath></i> <i>/dq &lt;qualifiers></i><code> [/o]</code>



</td></tr>
</table>



 
<table>
<tr><th>

Option</th><th>

Description</th></tr>

<tr><td><i>/cf &lt;filepath></i></td><td> Configuration file's output location. Example: <pre>
/cf C:\MyApp\priconfig.xml</pre>
  </td></tr>

<tr><td><i>/dq &lt;qualifiers></i></td><td> Default qualifier set in the configuration file. Some qualifiers are required, such as the language. Example: <pre>
/dq en-US</pre>
 
<table>

Multiple qualifiers are separated by underscores. Example: <pre>
lang-en-US_scale-100_contrast-high</pre>

</table>

  </td></tr>

<tr><td>/o</td><td> Overwrites an existing output file of the same name, without prompting.  </td></tr>
</table>

   
  
[Return to the top of this topic.](makepri.md)  
 

 

 

  
<a id="makepri_new"></a>

   

## makepri new  
   
  
MakePRI.exe new creates a PRI file at [outputfile] by indexing all files in [projectroot] and its subdirectories, as directed by [configxml]. The index will be assigned [indexname] to reference resources in the application.   
 
<table>
<tr><td><code>makepri new </code><i>/pr &lt;folderpath></i> <i>/cf &lt;filepath></i><code> [/of &lt;filepath>] [/mn &lt;filepath>] [/in &lt;string>] [/vma &lt;integer>] [/il &lt;filepath>] [/am] [/o] [/v]</code>



</td></tr>
</table>



 
<table>
<tr><th>

Option</th><th>

Description</th></tr>

<tr><td><i>/pr &lt;folderpath></i></td><td> Root location of project files. Example: <pre>
/pr C:\MyApp\src\</pre>
  </td></tr>

<tr><td><i>/cf &lt;filepath></i></td><td> Configuration file's location. Use the <a href="#makepri_createconfig">makepri createconfig</a> command to generate this file. Example: <pre>
/cf C:\MyApp\priconfig.xml</pre>
  </td></tr>

<tr><td>/of &lt;filepath></td><td> Output location of the PRI file. The default is [projectroot]\resources.pri. Example: <pre>
/of C:\MyApp\src\resources.pri</pre>
  </td></tr>

<tr><td>/mn &lt;filepath></td><td> Location of the application's or component's manifest. This parameter is ignored if [indexname] is specified. The default is [projectroot]\AppXManifest.xml.  </td></tr>

<tr><td>/in &lt;string></td><td> Name of the generated index of resources. For example, usually matches the AppX package's name and the class library's simple name. Can be supplied via the [manifest] parameter.  </td></tr>

<tr><td>/vma &lt;integer></td><td> Major version number for index. The default is 1.  </td></tr>

<tr><td>/il &lt;filepath></td><td> XML log of indexed resources. No log file is generated by default.  </td></tr>

<tr><td>/am</td><td> Causes MakePRI.exe to set the auto-merge flag within the PRI file. The default isn't set. 
<table>

We don't recommend this flag for normal use with AppX packages.
</table>

  </td></tr>

<tr><td>/o</td><td> Overwrites an existing output file of the same name, without prompting.  </td></tr>

<tr><td>/v</td><td> Causes verbose messages to be displayed on the console.  </td></tr>
</table>

   
  
 [Return to the top of this topic.](makepri.md)   
 

 

 

  
<a id="makepri_versioned"></a>

   

## makepri versioned  
   
  
MakePRI.exe versioned creates a versioned PRI file at [outputfile] by indexing all files in [projectroot] and its subdirectories according to [indexfile] and as directed by [configxml].   
 
<table>
<tr><td><code>makepri versioned </code><i>/pr &lt;folderpath></i> <i>/cf &lt;filepath></i><code> [/of &lt;filepath>] [/if &lt;filepath>] [/il &lt;filepath>] [/am] [/o] [/v]</code>



</td></tr>
</table>



 
<table>
<tr><th>

Option</th><th>

Description</th></tr>

<tr><td><i>/pr &lt;folderpath></i></td><td> Root location of project files. Example: <pre>
/pr C:\MyApp\src\</pre>
  </td></tr>

<tr><td><i>/cf &lt;filepath></i></td><td> Configuration file's output location. Example: <pre>
/cf C:\MyApp\priconfig.xml</pre>
  </td></tr>

<tr><td>/of &lt;filepath></td><td> Output location of the PRI file. The default is [projectroot]\resources.pri. Example: <pre>
/of C:\MyApp\src\resources.pri</pre>
  </td></tr>

<tr><td>/if &lt;filepath></td><td> Location of the base PRI file. The default is [projectroot]\resources.pri. Example: <pre>
/if C:\MyApp\1.2\resources.pri</pre>
  </td></tr>

<tr><td>/il &lt;filepath></td><td> XML log of indexed resources. No log file is generated by default.  </td></tr>

<tr><td>/am</td><td> Causes MakePRI.exe to set the auto-merge flag within the PRI file. By default, it's set to the same value as that of the base PRI file. 
<table>

We don't recommend this flag for normal use with AppX packages.
</table>

  </td></tr>

<tr><td>/o</td><td> Overwrites an existing output file of the same name, without prompting.  </td></tr>

<tr><td>/v</td><td> Causes verbose messages to be displayed on the console.  </td></tr>
</table>

   
  
 [Return to the top of this topic.](makepri.md)   
 

 

 

  
<a id="makepri_resourcepack"></a>

   

## makepri resourcepack  
   
  
MakePRI.exe resourcepack creates a PRI file at [outputfile] by indexing all files in [projectroot] and its subdirectories, as directed by [configxml]. ResourcePack PRI files contain only additional variants of resources already specified in [indexfile].   
 
<table>
<tr><td><code>makepri resourcepack </code><i>/pr &lt;folderpath></i> <i>/cf &lt;filepath></i><code> [/of &lt;filepath>] [/if &lt;filepath>] [/il &lt;filepath>] [/am] [/o] [/v]</code>



</td></tr>
</table>



 
<table>
<tr><th>

Option</th><th>

Description</th></tr>

<tr><td><i>/pr &lt;folderpath></i></td><td> Root location of project files. Example: <pre>
/pr C:\MyApp\src\</pre>
  </td></tr>

<tr><td><i>/cf &lt;filepath></i></td><td> Configuration file's output location. Example: <pre>
/cf C:\MyApp\priconfig.xml</pre>
  </td></tr>

<tr><td>/of &lt;filepath></td><td> Output location of the PRI file. The default is [projectroot]\resources.pri. Example: <pre>
/of C:\MyApp\src\resources.pri</pre>
  </td></tr>

<tr><td>/if &lt;filepath></td><td> Location of the base PRI file. The default is [projectroot]\resources.pri. Example: <pre>
/if C:\MyApp\1.2\resources.pri</pre>
  </td></tr>

<tr><td>/il &lt;filepath></td><td> XML log of indexed resources. No log file is generated by default.  </td></tr>

<tr><td>/am</td><td> Causes MakePRI.exe to set the auto-merge flag within the PRI file. By default, it's set to the same value as that of the base PRI file. 
<table>

We don't recommend this flag for normal use with AppX packages.
</table>

  </td></tr>

<tr><td>/o</td><td> Overwrites an existing output file of the same name, without prompting.  </td></tr>

<tr><td>/v</td><td> Causes verbose messages to be displayed on the console.  </td></tr>
</table>

   
  
 [Return to the top of this topic.](makepri.md)   
 

 

 

  
<a id="makepri_dump"></a>

   

## makepri dump  
   
  
MakePRI.exe dump outputs a dumped xml file at [outputfile] containing a list of all resources in [indexfile].   
 
<table>
<tr><td><code>makepri dump [/of &lt;filepath>] [/if &lt;filepath>] [/dt &lt;string>] [/o] [/v]</code>



</td></tr>
</table>



 
<table>
<tr><th>

Option</th><th>

Description</th></tr>

<tr><td>/of &lt;filepath></td><td> Output location of the PRI file. The default is [projectroot]\resources.pri. Example: <pre>
/of C:\MyApp\src\resources.pri</pre>
  </td></tr>

<tr><td>/if &lt;filepath></td><td> Location of the base PRI file. The default is [projectroot]\resources.pri. Example: <pre>
/if C:\MyApp\1.2\resources.pri</pre>
  </td></tr>

<tr><td>/dt &lt;string></td><td> Format of the dumped file: "Basic" (default) or "Detailed".  </td></tr>

<tr><td>/o</td><td> Overwrites an existing output file of the same name, without prompting.  </td></tr>

<tr><td>/v</td><td> Causes verbose messages to be displayed on the console.  </td></tr>
</table>

   
  
 [Return to the top of this topic.](makepri.md)   
 

 

 

  
<a id="ID4EONAC"></a>

   

## See also  
 [Make package (makepkg.exe)](makepkg.md)