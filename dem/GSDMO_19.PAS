program GSDMO_19;
{------------------------------------------------------------------------------
                             DBase File Sorting

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       This program demonstrates how dBase files may be sorted using
       Griffin Solutions units.

       The program creates (if necessary) and opens a dBase file and its
       memo. It then sorts the file to GSDMO19S.DBF and GSDMO19S.DBT.
       The sort fields are LASTNAME and FIRSTNAME.

       Records will only be sorted if they are valid (i.e., deleted records
       are ignored if SetDeletedOn, and SetFilterThru must validate the
       record as well).

       New procedures/functions introduced are:

                 SortTo

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

var
   fx : file;

begin
   ClrScr;

   if not FileExist('GSDMO_19.DBF') then
   begin
      writeln('Creating GSDMO_19.DBF');
      MakeTestData(3,'GSDMO_19', 20, true);   {Make a dBase III file w/memo}
      writeln('GSDMO_19.DBF Created');
   end;

   Select(1);
   Use('GSDMO_19');
   Writeln('Sorting to file GSDMO19S.DBF..');
   SortTo('GSDMO19S','LASTNAME+FIRSTNAME',SortUp);
   Writeln('Listing from Sorted file GSDMO19S.DBF..');
   Select(2);                     {Use record area 2 for new file}
   Use('GSDMO19S');               {Assign the sorted dBase III file GSDMO19S}
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
