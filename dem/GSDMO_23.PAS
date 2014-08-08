program GSDMO_23;
{------------------------------------------------------------------------------
                               DBase Filters

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       This program demonstrates how the programmer may set filters to
       determine what records to read from the file.

       The program will assign the routine FilterName as a filter for
       GSDMO_23.DBF by using SetFilterThru(FilterName).  This routine
       will return true if the record's LASTNAME field begins with a
       letter lower than 'M'.

       After listing all names that are alphabetically less than M, the
       filter is turned 'off' by resetting it to its default routine by
       SetFilterThru(DefFilterCk).  The file is then listed to show all
       records.

       Note that SetFilterThru should not be called until a file has been
       assigned to the selected file area through Use.  If no file has
       been assigned, Error 1008, Object is not initialized in file area,
       will halt the program.

       New procedures/functions introduced are:

                 SetFilterThru

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

{-----------------------------------------------------------------------------}
{$F+}                   {Filter Routine}
Function FilterName: boolean;
var
   b : boolean;
   n : string;
begin
   n := FieldGet('LASTNAME');
   b := n < 'M';
   FilterName := b;
end;
{$F-}                   {End Far Calls}
{-----------------------------------------------------------------------------}

var ch : char;

begin
   ClrScr;

   if not FileExist('GSDMO_23.DBF') then
   begin
      writeln('Creating GSDMO_23.DBF');
      MakeTestData(3,'GSDMO_23', 20, false);      {Make a dBase III file}
      writeln('GSDMO_23.DBF Created');
   end;

   Select(1);
   Use('GSDMO_23');
   SetFilterThru(FilterName);
   GoTop;
   while not dEOF do
   begin
      writeln(FieldGet('LASTNAME'),' ',
              FieldGet('FIRSTNAME'),'  ',
              RecNo);
      Skip(1);
   end;

   writeln;
   writeln('Now to turn off filtering.  Press any key');
   ch := ReadKey;

   SetFilterThru(DefFilterCk);
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



