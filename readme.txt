

                                 HALCYON/2

                               Version 3.50r2

                 VIRTUAL REALITY GROUP fixes & Os/2 porting	

                           dBase III, IV access


       ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
       These Turbo Pascal routines handle processing for dBase III/IV
       files, including memo (.DBT), index (.NDX), and data (.DBF) files.
       Use is made of object oriented programming to simplify the user
       interface.  Examples of the user interface is demonstrated in the
       sample programs.

       This release is valid for reading and writing of data, index, and
       memo files.  Routines will compile under TP 5.5, TP 6.0, TP 7.0,
       Turbo Pascal for Windows, Virtual Pascal for Os/2 and LsxPower.

       ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
       Halcyon original code is owned by Griffin Solutions
       dBase is a trademark of Ashton-Tate.
       Turbo Pascal is a trademark of Borland International, Inc.
       Virtual Pascal is a trademark of U.K. FPrint
       LsxPower is a trademark of Laserstars Technologies, Inc.
      ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 ±± 0. INDEX ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    1. Legal Stuff
    2. What it does ?
    3. What i've Fixed and Not
    4. Source new functions
    5. What i've added
    6. What i've to do
    7. Thanks & Greetings
    8. Contacting The Author


ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 ±± 1. Legal Stuff ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 Virtual Reality Group doesn't reserve rights for this porting!
 
 Original Halcyon source is copyright 1993 by Griffin Solutions - All 
 rights reserved.

 You may distribute this software to everyone,  upload it to bbses, internet
 ftp sites etc. etc., but you can not sell it.

 Halcyon/2 is FREEWARE, that is if you like this software and use it, you
 haven't to pay anything! Please consider to mention The Toy of Virtual Group 
 in your docs ... ;-)

 Original Halcyon/2 source code, known as HALCYON, is copyrighted to
 Griffin Solutions. It was distributed as Shareware!

 THIS PORTING IS DISTRIBUTED WITH PERMISSION OF GRIFFIN SOLUTIONS

 GRIFFIN SOLUTIONS DOESN'T SUPPORT THIS PORTING; IF YOU NEED MORE INFO
 ABOUT ACTUAL HALCYON LIBRARY TRY CONNETING TO: http://www.hom.net/~grifsolu
 
 IF YOU WANT TO USE ORIGINAL HALCYON CODE YOU ARE UNDER SHAREWARE 
 RESTRICTIONS, YOU MUST GET ORIGINAL SOURCE CODE. 

 REMEMBER: HALCYON/2 IS NOT THE SAME AS HALCYON.

 ANOTHER LITTLE THING: I'VE DONE THIS PORTING FOR MY OWN USE, I'M NO MORE
 INTERESTED IN DBF ENGINES, IF YOU NEED SUPPORT ASK IT TO MY BUT ONLY FOR
 TECHNICAL PROBLEMS ABOUT THIS PORTING, NOT ABOUT DBF!!!!

 I provide you this software on an "as is" basis which means that I give
 you no warranty at all, and that I can not be held responsible for damage
 caused to your software or hardware by Halcyon/2.
 If you decide to use Halcyon/2 on your PC, you do it at your own risk.

 All trademarks reported in this document are copyright by their respective
 owners.


ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 ±± 2. What it does ? ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 Halcyon/2 is a series of Pascal routines for management of dBase III 
 and IV files. 

 The routines are designed to do the following:

  - Provide a simple user interface to read and write dBase III and IV
    files in a network environment.

  - Allow creation, use and updating of multiple dBase .NDX index files in
    reading and updating the dBase III and IV data (DBF) files. The .MDX 
    index files are not supported!

  - Allow creation, use and updating of multiple Clipper .NTX index files
    in reading and updating the dBase III data (DBF) files.

  - Allow reading and updating of .DBT memo file entries.

  - Allow creation of new dBase III or IV files. These routines will work
    with either dBase III and IV memo file structures. However, these formats
    are not interchangeable.

  - Provide expanded routines to display, edit, and update dBase files.
    (Not fully developed under Os/2)

  - Provide a file handler interface that provides a simple disk management
    capability including file sharing for LANs.

  - Allow operation under all versions of Object Oriented Turbo Pascal,
    including Turbo Pascal for Windows, Virtual Pascal and so on.

  - Apply Object Oriented Programming to create easily usable modules.

  - New Halcyon/2 feature is the incredible VRGDBENG.DLL support. Now you
    could simply use Halcyon/2 as a DLL! Interface code is provided
    for Os/2, Dos (DPMI) and Uindous!


ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 ±± 3. What i've Fixed and Not ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 Well i've ported all libraries to Os/2. The Objects support i've used is 
 the same offered by Halcyon (GSOB_OBJ), but i've unlimited all arrays, 
 it's an Os/2 rulez! ;)

 The GSOB_DSK disk library now make an extensive use of DosApi... for 
 handling files, extend pipes and so on.

 I've not ported the Editor, Viewer and Browser sample demos just because 
 i'm not interested on; TV support is not developed for Os/2. I 
 hate Turbo Vision (it's like a big and slow elephant), if you need it you 
 could write it by your own!  ;^) (all unsupported files are stored in the 
 \dem\unsupp.zip and \dem\teg.zip).

 I've received the last Halcyon version with unmangled sources (ver. 3.59)
 I've tried to make it usable mixing it with Halcyon/2 but there's no way
 to do that ... only one is to make all the work i've done with 3.59 instead
 of 3.05; i'm not interested on this, sorry!

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 ±± 4. Source new functions ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 dbOn & dbOff - (old name On & Off) i've renamed constats for reach a complete
		Delphi compatibility

 dbAppend     - (old name Append) renamed function for obvious reasons!


ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 ±± 5. What i've added ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 . I've added full long names support (Os/2 version). Consider that, due to
 original DBF structure, if you need to use MEMO files (.DBT) you must use
 standard DOS names (8 char) for compatibility with other DB programs that 
 use the same file. Note that the extension has no limit, the MEMO file is
 automatically renamed as a .DBT! The same for .IDX or .NDX files, so to 
 avoid strange runtime errors i've added this GS error constant:
   dbfLongNameMemo = 1230 {Error in GSO_DBFBuild.WriteDBT}
 It will be raised when a mismatched filename is used!

 . I've added this 'Procedure SetDBExt(vDBExt:String)' in the GSOBSHEL.
 It's only a dirty trick to change DBF extensions if it's needed ;^) 

 . I've added the \src\use32.pas sourcecode for compatibility reasons with 
 Dos version. Refer to Vp/2 documentations to learn something about what 
 it does! ;-)

 . I've added also a .DLL support; see it in \dll directory. 

 . Modified GS_Flush routine to work with LsxPower (a Matt Yours' suggestion)
   
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 ±± 6. What i've to do ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

 GSOB_DSK    - GS_ExtendHandles doesn't work under LsxPower because 
               DosSetMaxFH API is not supported :-(
 
 DLL SUPPORT - support works fine under Dos and Uindous but under Os/2 and 
               LsxPower it doesn't.  I don't know why, it's about
               a week i'm trying to fix it... i'm thinkink there's a bug 
               somewhere but not in my code ;-)

               I hope someone at FPrint could help me fix it shortly!


 This version of Halcyon/2 has not a real manual, you could find a copy of
 that i've found in Halcyon original library!


 If Griffin Solutions and Os/2 people are interested we could try to make
 a real porting of last Halcyon libraries... but this is probably only a 
 dream! ;-)

	
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 ±± 7. Thanks & Greetings ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 My greetings go to all my friends, fidonet users on Hobbiville, Vega,
 Bradipoland and Gotham City BBSes; to all OS/2 users around the world, to
 Vp/2 developing team.

 Many thanks to (random order):
  - Matt Yourst (developer of LsxPower Dos extender for Vp/2) for his 
    availability and for good support to LSXPower!
  - Richard Griffin for his good library and for the possibility to make this
    porting available to public domain
  - Vitaly Mityanov of Vp/2 Team for support to DLL version (I'M STILL 
    WAITING FOR INFOS! ;)
  - Gustavo Muslera for sending me ver. 3.59; sorry but 3.59 is quite
    unstable and not so similar to 3.05 ... i'm not so sure i'll mix my 
    Halcyon/2 with 3.59, at all! ;-(

  The betatesters (in alphabetical order):
  - Djj         - hey guy, you're insane! ;) 
  - SuperGiamma - (aka Gian Maria Romanato) for cheating his read.me O:-)
  - The Toy     - (aka Me) Who could do this better? ;-)


ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 ±± 8. Contacting The Author ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 If you want to tell me about a bug you found in Halcyon/2 or about other
 fixes you can reach me at:

     Internet  :  toy.vrgroup@iol.it
     Fidonet   :  2:333/329.12
     Snail Mail:  Antonio Manara Rossini
                  Facciolati street n. 139
                  35127 Padova 
                  Italy   

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

