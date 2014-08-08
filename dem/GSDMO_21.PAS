program GSDMO_21;
{------------------------------------------------------------------------------
                        DBase File and Structure Copying

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       This program demonstrates how dBase files and file structures may
       be copied using Griffin Solutions units.

       The program creates (if necessary) and opens a dBase file and its
       memo. It then copies the files to new file named GSDMO21A.DBF and
       GSDMO21A.DBT.  Records will only be copied if they are valid (i.e.,
       deleted records are ignored if SetDeletedOn, and SetFilterThru must
       validate the record as well).  You can match the two files and see
       that record 7 in GSDMO_21.DBF was not copied, because its deletion
       flag was set before copying.

       Next, the file structure only is copied to GSDMO21B.DBF and DBT.
       This is useful when the file structure must be preserved for future
       use.

       New procedures/functions introduced are:

                 CopyTo
                 CopyStructure

-------------------------------------------------------------------------------}

uses
   USE32,
   GSOB_Var,
   GSOB_Gen,
   GSOBShel,
   {$IFDEF WINDOWS}
      WinCRT;
   {$ELSE}
      CRT;
   {$ENDIF}

begin
   ClrScr;

   if not FileExist('GSDMO_21.DBF') then

   begin
      writeln('Creating GSDMO_21.DBF');
      MakeTestData(4,'GSDMO_21', 20, true);      {Make a dBase IV file}
      writeln('GSDMO_21.DBF Created');
   end;

   SetDeletedOn;
   Select(1);
   Use('GSDMO_21');
   go(7);
   DeleteRec;                      {This record should not copy}
   CopyTo('GSDMO21A');
   CopyStructure('GSDMO21B');
   select(2);
   Use('GSDMO21A');
   GoTop;
   while not dEOF do
   begin
      writeln(FieldGet('LASTNAME'),' ',
              FieldGet('FIRSTNAME'),'  ',
              RecNo);
      Skip(1);
   end;
   CloseDataBases;
end.



