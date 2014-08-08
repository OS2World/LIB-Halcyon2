program GSDMO_07;
{------------------------------------------------------------------------------
                            DBase Memo File Lister

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       This program demonstrates how dBase memo records may be listed
       using Griffin Solutions units.

       The program opens a dBase file GSDMO_07.DBF and proceeds to list
       selected fields from each record along with its memo record.  If
       the file does not exist it will be created in dBase IV format.

       New procedures/functions introduced are:

                 MemoGet
                 MemoGetLine
                 MemoLines
                 MemoWidth

-------------------------------------------------------------------------------}

uses
   USE32,
   GSOB_Gen,
   GSOBShel,
   {$IFDEF WINDOWS}
      WinCRT,
      WinDOS;
   {$ELSE}
      CRT,
      DOS;
   {$ENDIF}

var
   CkFile  : file;
   c       : char;
   Shar    : boolean;

                     {Procedure to display the memo field}

procedure ShowTheMemo;
var
   i, ml   : integer;
begin
   MemoGet('COMMENTS');         {Load the COMMENTS memo into memory}
   ml := MemoLines;             {Get the nummber of memo lines}
   if ml <> 0 then
      for i := 1 to ml do       {Get and write each memo line}
         writeln(MemoGetLine(i))
      else writeln('[ EMPTY ]');
   writeln;
end;


                               {Main program}
begin
   ClrScr;

             {Ensure a dBase file with a memo exists.}
             {A dBase III file with memo can be made }
             {if the first argument of MakeTestData  }
             {is changed from 4 to 3.  Refer to the  }
             {GSOB_GEN.PAS listing.                  }

   if not FileExist('GSDMO_07.DBF') then
   begin
      writeln('Creating GSDMO_07.DBF');
      MakeTestData(4,'GSDMO_07', 20, true); {Make a dBase IV file with a memofile linked}
      writeln('GSDMO_07.DBF Created');
      ClrScr;
   end;

   SetCenturyOn;
   Select(1);
   Use('GSDMO_07');
   MemoWidth(75);        {sets width of the memo line.  Default is 70}
   GoTop;
   while not dEOF do
   begin
      ClrScr;
      writeln(FieldGet('LASTNAME'),', ',
              FieldGet('FIRSTNAME'));
      ShowTheMemo;
      write('Press any key....');
      c := ReadKey;
      writeln;
      Skip(1);
   end;
   CloseDataBases;
end.

