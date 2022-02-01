## MELTs.m / writemelts.m / writemelts.xml

For more information visit: 

http://melts.ofm-research.org/index.html
https://gitlab.com/ENKI-portal/xMELTS => Requires to register (if by any interest you want to compile xMELTs on your own please see end of this document)

The matlab program MELTs.m is a LAUNCHER of the thermodynamic minimisation program MELTS. 

Using MELTs.m provides the opportunity to compute a large set of composition directly from a spreadsheet. Example of input spreadsheet can be found in Cumulate.csv. 
Running MELTs.m with the Cumulate.csv file will create a Cumulates_batch, Cumulates_frac and Cumulates_Spec folders, which give an example of the 3 type of calculation I implemented (e.g., fractionation, equilibrium and frac/equilibrium switch depending on melt fraction). You can see the output formats and how everything is put in order depending on the water content and crystallinity.
The Cumulate.csv with a fO2 buffer FMQ +1 that you have here is an example of a non-failing MELTs calculation. Failing calclulations occurs when MELTS fail to converge to a reasonable Gibbs minmization and fall in an endless loop. The reasons are unknown and from the many tests I made, it varies according to the fO2 or water content.
When that happens, you have to hit ctrl+C in the command window of matlab to kill the simulation. I am currently working with Juliana Troch to circumvent the endless loop (although not correcting the problem).  

note: In Input spreadsheet, the fO2 must be chosen among the following: "none","nno","fmq","coh","iw","hm"

Other Variables such as Temperature, Pressure calculation mode and type must be filled directly in MELTs.m file. 

MELTs.m launch Melts-batch that works as follows: 

	## Reference: xMELTs README.md file 
		#### Standalone MELTS - batch execution, read-write XML files ####
		1. Ensure that the PORT3 library is installed.  
		2. In a terminal window, migrate to the repository directory, and type this command:

		    ```
		    make Melts-batch
		    ```
		A new file appears in the directory named `Melts-batch`.   This is an executable image that you can run by typing this command:  

		```
		./Melts-batch
		```
		The command generates the following output detailing usage:  

		```
		Usage:
		  Melts-batch input.melts
		  Melts-batch input.xml
		  Melts-batch inputDir outputDir [inputProcessedDir]
			      Directories are stipulated relative to current directory
			      with no trailing delimiter.
		```
		 The three usage scenarios are as follows:  
		- First usage takes a standard MELTS input file as input on the command line and processes it using MELTS version 1.0.2, placing output files in the current directory.  
		- Second usage processes a MELTS input file formatted using the standard MELTS input XML schema (contained in schema definition file [MELTSinput.xsd](https://gitlab.com/ENKI-portal/xMELTS/blob/master/MELTSinput.xsd)) and processes it using the MELTS/pMELTS
		 version specified in that file, placing output files in the current directory.
		- Third usage places the executable in listening mode.  The program waits for a file to be placed in the specified `inputDir`, processes that file, and places output into the `outputDir`, moving the input file in the `inputProcessedDir` if one is specified.  			This usage is appropriate if some other program (like Excel) is used to generate input files and waits until output is produced for subsequent processes.  Input files must conform to the XML schema noted in the second usage, and output files are generated 		according to XML output schema specified in [MELTSoutput.xsd](https://gitlab.com/ENKI-portal/xMELTS/blob/master/MELTSoutput.xsd) and [MELTSstatus.xsd](https://gitlab.com/ENKI-portal/xMELTS/blob/master/MELTSstatus.xsd). Detailed documentation files on all of 			the XML schema may be found in [the Wiki](https://gitlab.com/ENKI-portal/xMELTS/wikis/home).  These schema are also utilized in client-server communication involving the MELTS web services (see below).  A typical command for this usage scenario may look like 			this:

		    ```
		    ./Melts-batch ./inputXML ./outputXML ./processedXML
		    ```
		    where the various directories must exist prior to starting the batch process.


xMELTs compilation: 

- Make sure you send a request to get access to the project port3 in the gitlab otherwise you download xMELTs without the port3 library. 

https://gitlab.com/ENKI-portal/port3

On Linux based system: 

- Make sure you have the following library installed: 
	- gfortran
	- Xorg openbox
	- clang
	- libxml2-dev
	- zlib1g-dev


