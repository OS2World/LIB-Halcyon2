program GSDMO_01;
{------------------------------------------------------------------------------
                              DBase File Creator

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

        This program creates a test file for the next several programs.


       The GSDMO_01.DBF file will be created by using the MakeTestData
       procedure in GSOB_GEN.PAS.

-------------------------------------------------------------------------------}

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

uses
   USE32,
   GSOB_Gen,
   {$IFDEF WINDOWS}
      WinCRT,
      WinDOS;
   {$ELSE}
      CRT,
      DOS;
   {$ENDIF}

begin
   ClrScr;

{-----------------------------------------------------------------------------}
{  This call will create a .DBF file containing 20 records without memos.                   }
{  See the GSOB_GEN.PAS file to see how it works.                              }
{-----------------------------------------------------------------------------}

   writeln('Creating GSDMO_01.DBF');
   MakeTestData(4, 'GSDMO_01', 20, false);
   {For porting test only}
   {$IfDef TEST}
   {MakeTestData(3, 'GSDM3_01', 20, false); {DB3}
   {MakeTestData(4, 'GSDM4_01', 20, false); {DB4}
   {MakeTestData(4, 'GSDM0_01', 2000, false); {DB4}
   {$EndIF}
   writeln('GSDMO_01.DBF Created');

   {For Long Names test only}
   {writeln('Creating LONG_GSDMO_01.DBFIV');
   MakeTestData(4, 'LONG_GSDMO_01.DBFIV', 2000, false); {DB4}
   {writeln('LONG_GSDMO_01.DBFIV Created');}


end.
