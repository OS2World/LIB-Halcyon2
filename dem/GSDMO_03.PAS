program GSDMO_03;
{------------------------------------------------------------------------------
                          DBase File Formated Lister

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       This program demonstrates how dBase files may be listed using
       different field type formats.

       If the GSDMO_01.DBF file does not exist, the program will display a
       a message that the file was not found and to run GSDMO_01 to make
       the file.

       The program opens a dBase file and proceeds to list selected fields
       from each record.

       The NumberGet, DateGet, and StringGet commands are shown in the
       example.  This is intended to contrast them with the basic FieldGet
       command used to get the field image directly from disk.

       The NumberGet Procedure returns the actual numeric value in the field.
       This should be used on Number fields only as it returns a real value.

       The DateGet Function is used to retrieve a longint Julian Date from
       the date field.  See GSOB_DTE.PAS for an explanation of Julian Dates.
       Several other date handling routines are shown, such as SetDate(),
       SetCenturyOn, and DTOC()

       The StringGet Function returns the trimmed string.

       DTOC is used to display a 'viewable' date from the longint Julian
       Date value retrieved by DateGet.

       New procedures/functions introduced are:

                 DateGet
                 DTOC
                 NumberGet
                 SetCenturyOn
                 SetDateStyle
                 StringGet

-------------------------------------------------------------------------------}

uses
   USE32,
   GSOB_Var,
   GSOBShel,
   {$IFDEF WINDOWS}
      WinCRT,
      WinDOS;
   {$ELSE}
      CRT,
      DOS;
   {$ENDIF}

var
   rnum    : FloatNum;
   dnum    : longint;
begin
   ClrScr;
   if not FileExist('GSDMO_01.DBF') then
   begin
      writeln('File GSDMO_01.DBF not found.  Run GSDMO_01 to create.');
      halt;
   end;
                       {The 'Real' example starts here}

   SetDateStyle(USA);           {Sets the Date type to mm-dd-yy}
   SetCenturyOn;                {Gives full century on date display (YYYY)}
                                {default is false for YY only.}
   Select(1);
   Use('GSDMO_01');
   GoTop;
   while not dEOF do
   begin
      rnum := NumberGet('PAYMENT');  {use real number for math later}
      dnum := DateGet('BIRTHDATE');  {use for date conversion later}

      writeln(StringGet('LASTNAME'),', ',
                                     {Get field without trailing spaces}
              StringGet('FIRSTNAME'),'  ',
              DTOC(dnum),' [',
              StringGet('PAYMENT'),']',
              rnum/12:8:2);          {Compute and list PAYMENT / 12}
      Skip(1);
   end;
   CloseDataBases;
   write('Press any Key to continue:');
   repeat until KeyPressed;
end.
