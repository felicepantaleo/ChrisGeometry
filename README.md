# Chris Seez Geometry Dump (Imperial College)
May 2026



## Software
My HGCAL geometry toy is set up as a Mac app, and aims at
graphics. There is probably not much in it that is useful outside a
Mac graphics environment. Most of what might be useful I have
tried to put into the DocDB files. However I have placed a tar file
containing the code etc at:
https://cernbox.cern.ch/s/HoEClzT7IeNEgsQ
the content of which anyone is free to do what they like with. The
file and directory structure is as it gets organized by Xcode, which
looks a complete mess, but it means that the Hex.xcodeproj file can
be opened by someone with Xcode and modified, hacked,
developed, or whatever, and built as a Mac app.
Downloading the app
The already-built app can be downloaded to a MacBook etc,
although the procedure is a bit of a pain because of the malware
protection security (because I am not a paying "Known
Developer").
For MacOS 26 (Tahoe): in the  menu select System Settings, in the
System Settings select Privacy & Security. At the bottom of that
page there is Security. Set the "Allow applications from" to "App
Store & Known Developers".
Next download the zip file from
https://cernbox.cern.ch/s/f7mktYOas62nX9r
and unzip it (double click). This gives you Hex.app with its icon.
When you try to open it (i.e. use it) you will get a message warning
you that Apple is not able to verify that it is free from malware,
and so won't open it. Don't throw it in the bin, click the Done
button, and go back to Security in the System Settings where you
will be offered the possibility of opening it anyway.
You get warned again, and you have to give your machine's
password. After that it opens and you are OK: i.e. you don't have
to go through all this hooplah again if you open it again.


## Documents in DocDB
I have loaded in DocDB a number of sets of slides summarizing
information about the geometry obtained from the engineers and
hardware people, and about conventions adopted for the CMSSW
GEANT geometry. Often these are distilled and revised versions
of slides shown in our biweekly Friday Geometry meetings.
Below is a list of what is there.
- Silicon sensor layer layout flat-file: description and
latest version
https://cms-docdb.cern.ch/cgi-bin/DocDB/ShowDocument?docid=14750
Description of the contents of the silicon sensor layer layout flat-
file used (by Sunanda) to generate the XML file which is in turn
used to control the silicon sensor layer layout of the GEANT
description of the HGCAL in CMSSW. Latest (final?) version of
the flat file also included.
- Description of contents of the scintilator tile layer
layout flat-file, and latest version of file
https://cms-docdb.cern.ch/cgi-bin/DocDB/ShowDocument?docid=14751
Description of the contents of the scintilator tile layer layout flat-
file used to generate the XML file which is in turn used to
control the scintilator tile layer layout of the GEANT description
of the HGCAL in CMSSW. The latest version of the file is also
included.
- Layer layout pictures
https://cms-docdb.cern.ch/cgi-bin/DocDB/ShowDocument?docid=14753
Scale drawings of each of the 47 layers, including colour coding
to show wafer type, marking of cassette boundaries, numbering
of cassettes, indication of wafer orientation, and wafer (u, v)
index. Also including eta-circles at eta = 1.55, 1.6, 2.8 and 3.0.
- HGCAL Longitudinal Stackup in CMSSW GEANT
model
https://cms-docdb.cern.ch/cgi-bin/DocDB/ShowDocument?docid=14752
Numbers for GEANT description of longitudinal stackup,
together with material composition tables of key composite
materials. The material names used are those used in GEANT.
(e.g. HGC_Kapton_PDG is the material Polyimide,
commercially named Kapton, and HGC_Kapton is a composite
of Kapton, Copper, and Epoxy used in the silicon modules).
- Summary of silicon sensor cell areas
https://cms-docdb.cern.ch/cgi-bin/DocDB/ShowDocument?docid=14831
Summary of silicon sensor cell areas, for both full and partial
wafers.
- Nearest neighbour algorithm
https://cms-docdb.cern.ch/cgi-bin/DocDB/ShowDocument?docid=14955
Algorithm to find a list of the directly adjacent cells of any
specified Si cell, where the specification of the cell is in terms of
its CMSSW DetId.
- Mapping of CMSSW Si cell detIds to ECON-D
channel sequence numbers
https://cms-docdb.cern.ch/cgi-bin/DocDB/ShowDocument?docid=14816
Mapping of CMSSW Si cell DetIds to HGCROC channels and
readout sequence is described and tabulated.
- Trigger cell mapping of Si modules
https://cms-docdb.cern.ch/cgi-bin/DocDB/ShowDocument?docid=14954
Colour coded layout pictures showing mapping of cells to
trigger cells. Trigger cells are numbered by ROC:Trigger
Link:Trigger Cell, and silicon cells are numbered by hardware
number.
- Silicon wafer geometry
https://cms-docdb.cern.ch/cgi-bin/DocDB/ShowDocument?docid=14962
Slides aiming to provide complete documentation of the wafer
geometry; i.e. to contain all the information required to
determine everything about the geometric structure of any
wafer.
An appendix contains an algorithm to calculate cell (iu, iv)
DetId indices from an (x, y) point specified relative to the wafer
centre in the wafers Reference frame (i.e. CMSSW iplacement =
0), and thereby identify the cell.