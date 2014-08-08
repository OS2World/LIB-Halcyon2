Program GSDMO_15;
{------------------------------------------------------------------------------
                          DBase File and Memo Builder

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       This program creates a dBase file 'GSDMO_15.DBF with memo file
       'GSDMO_15.DBT'.  It shows how memo fields are built.

       New procedures/functions introduced are:

                 DTOS
                 MemoClear
                 MemoInsLine
                 MemoPut

-------------------------------------------------------------------------------}

uses
   USE32,
   GSOB_DBF,
   GSOBShel,
   {$IFDEF WINDOWS}
      WinCRT,
      WinDOS;
   {$ELSE}
      CRT,
      DOS;
   {$ENDIF}


var
   fli : text;
   s   : string;
   icnt: integer;
   t   : string;

   gfLineName  : string[12];
   gfBirthDate : string[8];
   gfRandomNum : string[12];


Procedure MakeTheFile(fname : string);
var
   f   : GSP_DB4Build;        {Create a dBase 3 format by using GSP_DB3Build}
begin
           {Create new dBase file}

   New(f, Init(fname));
   f^.InsertField('LINENAME','C',30,0);
   f^.InsertField('BIRTHDATE','D',8,0);
   f^.InsertField('RANDOMNUM','N',12,5);
   f^.InsertField('COMMENTS','M',10,0);
   dispose(f, Done);
end;


Function RandString(l,h : integer) : string;
var
   v : integer;
   g : string;
begin
   v := random((h-l)+1);
   v := v + l;
   str(v,g);
   RandString := g;
end;


procedure BuildRecordData;
var
   k1  : word;
   s1  : string[5];
begin
               {data for LINENAME}
   str(icnt, gfLineName);
   gfLineName := 'Line ' + gfLineName;
               {data for BIRTHDATE}
   k1 := random(25);
   gfBirthDate := DTOS(Date - k1);
               {data for RANDOMNUM}
   k1 := random(2);
   if k1 = 0 then gfRandomNum := '-' else gfRandomNum := '';
   s1 := RandString(0,30000);
   while length(s1) < 5 do s1 := s1+'0';
   gfRandomNum := gfRandomNum + RandString(0,30000) + '.' + s1;
   while length(gfRandomNum) < 12 do gfRandomNum := ' ' + gfRandomNum;
               {data for COMMENTS}
   MemoClear;                          {Erase the current memo buffer}
   readln(fli, s);                     {Read a line of text}
   MemoInsLine(0,s);                   {Insert text s at end of the memo}
end;


{--- Main Program ---}

begin
           {Create new dBase file}

   Writeln('Creating the file..');
   MakeTheFile('GSDMO_15');
   Writeln('Finished');

           {Add records to the file}

   Select(1);
   Use('GSDMO_15');
   randomize;
   assign(fli,'wisdom.fil');
   reset(fli);
   Writeln('Appending records to the file..');
   for icnt := 1 to 20 do
   begin
      BuildRecordData;
      ClearRecord;
      FieldPut('LINENAME',gfLineName);
      FieldPut('BIRTHDATE',gfBirthDate);
      FieldPut('RANDOMNUM',gfRandomNum);
      Writeln(gfLineName,'  ',gfBirthDate,'  ',gfRandomNum);
      MemoPut('COMMENTS');             {Store the memo record}
      DBAppend;
   end;

           {Dispose of objects (also closes the files}

   Writeln('Finished');
   CloseDataBases;
   close(fli);
end.
