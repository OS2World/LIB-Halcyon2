Unit GSOB_Gen;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                               DBase File Builder

           GSOB_GEN (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved 

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

       This unit creates a test dBase file and adds records to an
       existing test file.

       The unit uses two external files to generate data.  The first is
       TESTDATA.FIL, which contains names and addresses the routines use
       to randomly generate data.  The second file is WISDOM.FIL, which
       contains one-liners used to randomly create memo fields.  Each of
       these files may be modified to fit the user's requirements.

       File structure is:

              LASTNAME    C   30    0
              FIRSTNAME   C   30    0
              STREET      C   30    0
              OFFICE      C   30    0
              CITY        C   30    0
              STATE       C   2     0
              ZIP         C   10    0
              TELEPHONE   C   20    0
              BIRTHDATE   D    8    0
              PAYMENT     N    9    2
              PAIDFLAG    L    1    0
              RANDOMNUM   N   12    5
              UNIQUEID    C    8    0
              COMMENTS    M   10    0   (Only included if Memo Field requested)

       The MakeTestData unit is called as follows for database creation:

          MakeTestData(typFile, namFile, numRecs, MemoAlso);

          where:
                  typFile  = 3 for db3 or 4 for db4
                  namFile  = file name without the file extension
                  numRecs  = number of records to insert
                  MemoAlso = boolean true to create a memo file and records,
                             false to omit a memo field.

       The AddTestData unit is called as follows for additional records:

          AddTestData(namObjt, numRecs);

          where:
                  namObjt  = Pointer to the GS_dBFld_Objt object for the file
                  numRecs  = number of records to add
  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

{$O+}

interface

uses
   Use32,
   GSOB_Var,
   GSOB_Dte,
   GSOB_Str,
   GSOB_DBF,
   GSOB_DBS,
   {$IFDEF WINDOWS}
      WinCRT,
      WinDOS,
      Objects;
   {$ELSE}
      CRT,
      DOS,
      GSOB_Obj;
   {$ENDIF}


procedure MakeTestData(dbfType : Integer; namFile : string; numRecs : Integer; MemoAlso : boolean);
procedure AddTestData(namObjt : GSP_dBHandler; numRecs : Integer);

implementation
const

   CollectionsEmpty : boolean = true;

   yearweight : array [0..6] of Word = (7665,14600,14600,23725,32850,40150,40150);
   memoweight : array [0..7] of Word = (0,500,500,1000,1500,1000,500,500);

var
   fli : text;
   flp : text;
   s   : string;
   i,
   j,
   k   : Integer;
   x   : Integer;

   gfMemoArray : array[0..50] of Word;
   gfMemoLines : Integer;
   gfMemoBytes : longint;
   gfMemoAvg   : Integer;
   gfLastName  : string[30];
   gfFirstName : string[30];
   gfStreet    : string[80];
   gfOffice    : string;
   gfState     : string[2];
   gfZip       : string[5];
   gfCity      : string[30];
   gfTelePhone : string[20];
   gfBirthDate : string[8];
   gfPayment   : string[9];
   gfPaidFlag  : string[1];
   gfRandomNum : string[12];
   gfUniqueID  : string[8];
   SZC         : string;

   MoColl,
   LNColl,
   FNColl,
   StColl,
   OfColl,
   SZColl : TCollection;

   fx : GSP_DBFBuild;
   t : string;

   dbx : GSP_dBHandler;
   useMemo : boolean;



{  Use this when a consistent series of records needs to be created to
   test a program.  Otherwise, comment it out. }

Procedure Randomize;
begin
   RandSeed := 1234;
end;



procedure MakeCollections;
begin
   FileMode := 66;
   assign(fli,'testdata.fil');
   reset(fli);
   LNColl.Init(32,32);
   FNColl.Init(32,32);
   StColl.Init(32,32);
   OfColl.Init(32,32);
   SZColl.Init(32,32);
   x := 0;
   readln(fli,s);
   while not EOF(fli) do
   begin
      s := TrimR(s);
      if s[1] = '%' then
      begin
         if s = '%LASTNAME' then x := 1;
         if s = '%FIRSTNAME' then x := 2;
         if s = '%STREET' then x := 3;
         if s = '%OFFICE' then x := 4;
         if s = '%STATEZIPCITY' then x := 5;
      end
      else
      case x of
         1 : LNColl.Insert(NewStr(s));
         2 : FNColl.Insert(NewStr(s));
         3 : StColl.Insert(NewStr(s));
         4 : OfColl.Insert(NewStr(s));
         5 : SZColl.Insert(NewStr(s));
      end;
      readln(fli,s);
   end;
   close(fli);
   if not useMemo then exit;
   gfMemoBytes := 0;
   assign(fli,'wisdom.fil');
   reset(fli);
   MoColl.Init(2000,500);
   readln(fli,s);
   while not EOF(fli) do
   begin
      s := TrimR(s);
      gfMemoBytes := gfMemoBytes + ord(s[0]);
      MoColl.Insert(NewStr(s));
      readln(fli,s);
   end;
   close(fli);
   gfMemoAvg := gfMemoBytes div MoColl.Count;
end;

Function RandString(l,h : Integer) : string;
var
   v : Integer;
   g : string;
begin
   v := random((h-l)+1);
   v := v + l;
   str(v,g);
   RandString := g;
end;

procedure BuildRecordData;
var
   z   : string;
   i1,
   j1,
   j2,
   k1  : Word;
   i2  : longint;
   tf  : boolean;
   s1  : string[5];
begin
   j := random(LNColl.Count);
   gfLastName := PString(LNColl.At(j))^;
   j := random(FNColl.Count);
   gfFirstName := PString(FNColl.At(j))^ + ' ' + chr(Random(26)+65) + '.';
   j := random(StColl.Count);
   gfStreet := RandString(10,9999) + ' ' + PString(StColl.At(j))^;
   j := random(OfColl.Count*3);
   if j < OfColl.Count then
      gfOffice := PString(OfColl.At(j))^ + ' ' + RandString(1,99)
   else gfOffice := '';
   j := random(SZColl.Count);
   s := PString(SZColl.At(j))^;
   gfState := copy(s,1,2);
   gfZip := copy(s,3,5);
   gfCity := copy(s,8,30);
   gfTelePhone := RandString(100,600) + ' ' + RandString(100,999) + '-' +
                  RandString(1000,9999);
   i1 := yearweight[random(7)];
   i2 := random(i1)+1;
   gfBirthDate := GS_Date_dBStor(GS_Date_Curr - i2);
   i1 := random(20000) + 1;
   str(i1:6,gfPayment);
   gfPayment := gfPayment + '.' + RandString(10,99);
   i1 := random(2);
   if i1 = 0 then gfPaidFlag := 'F' else gfPaidFlag := 'T';

   i1 := random(2);
   if i1 = 0 then gfRandomNum := '-' else gfRandomNum := '';
   s1 := RandString(0,30000);
   while length(s1) < 5 do s1 := s1+'0';
   gfRandomNum := gfRandomNum + RandString(0,30000) + '.' + s1;
   while length(gfRandomNum) < 12 do gfRandomNum := ' ' + gfRandomNum;
   gfUniqueID := Unique_Field;
   if not useMemo then exit;
   dbx^.MemoFile^.MemoClear;
   j2 := random(8);
   j2 := memoweight[j2];
   if j2 = 0 then exit;
   s := '--- ' + gfLastName + ', ' + gfFirstName + ' Memo Record';
   dbx^.MemoInsLine(0,s);
   gfMemoLines := random(j2 div gfMemoAvg);
   i1 := 0;
   while i1 <= gfMemoLines do
   begin
      j1 := random(MoColl.Count);
      tf := true;
      if i1 > 0 then
         for k1 := 0 to i1 do if j1 = gfMemoArray[k1] then tf := false;
      if tf then
      begin
         s := PString(MOColl.At(j1))^;
         dbx^.MemoInsLine(0,s);
         gfMemoArray[i1] := j1;
         inc(i1);
      end;
   end;
end;

procedure MakeTestData(dbfType : Integer; namFile : string; numRecs : Integer; MemoAlso : boolean);
begin
   useMemo := MemoAlso;
   if CollectionsEmpty then MakeCollections;
   CollectionsEmpty := false;

           {Create new dBase file}
   if dbfType = 3 then
      fx := New(GSP_db3Build, Init(namFile))
   else
      fx := New(GSP_db4Build, Init(namFile));
   fx^.InsertField('LASTNAME','C',30,0);
   fx^.InsertField('FIRSTNAME','C',30,0);
   fx^.InsertField('STREET','C',30,0);
   fx^.InsertField('OFFICE','C',30,0);
   fx^.InsertField('CITY','C',30,0);
   fx^.InsertField('STATE','C',2,0);
   fx^.InsertField('ZIP','C',10,0);
   fx^.InsertField('TELEPHONE','C',20,0);
   fx^.InsertField('BIRTHDATE','D',8,0);
   fx^.InsertField('PAYMENT','N',9,2);
   fx^.InsertField('PAIDFLAG','L',1,0);
   fx^.InsertField('RANDOMNUM','N',12,5);
   fx^.InsertField('UNIQUEID','C',8,0);
   if useMemo then fx^.InsertField('COMMENTS','M',10,0);
   Dispose(fx, Done);

           {Add records to the file}


   New(dbx, Init(namFile));
   dbx^.Open;
   randomize;
   dbx^.StatusUpdate(StatusStart,GenFStatus,numRecs);
   for i := 1 to numRecs do
   begin
      {$IfDef TEST}
       GotoXY(1,2); WriteLn('Record num.: ',i);
      {$EndIf}
      dbx^.StatusUpdate(GenFStatus,i,0);
      BuildRecordData;
      dbx^.Blank;
      dbx^.FieldPut('LASTNAME',gfLastName);
      dbx^.FieldPut('FIRSTNAME',gfFirstName);
      dbx^.FieldPut('STREET',gfStreet);
      dbx^.FieldPut('OFFICE',gfOffice);
      dbx^.FieldPut('CITY',gfCity);
      dbx^.FieldPut('STATE',gfState);
      dbx^.FieldPut('ZIP',gfZip);
      dbx^.FieldPut('TELEPHONE',gfTelephone);
      dbx^.FieldPut('BIRTHDATE',gfBirthDate);
      dbx^.FieldPut('PAYMENT',gfPayment);
      dbx^.FieldPut('PAIDFLAG',gfPaidFlag);
      dbx^.FieldPut('RANDOMNUM',gfRandomNum);
      dbx^.FieldPut('UNIQUEID',gfUniqueID);
      if useMemo then
         dbx^.MemoPut('COMMENTS');
      dbx^.Append;
   end;
   dbx^.StatusUpdate(StatusStop,0,0);
   Dispose(dbx, Done);
end;

procedure AddTestData(namObjt : GSP_dBHandler; numRecs : Integer);
begin
   dbx := namObjt;
   if CollectionsEmpty then MakeCollections;
   CollectionsEmpty := false;
   useMemo := namObjt^.WithMemo;
   randomize;
   dbx^.StatusUpdate(StatusStart,GenFStatus,numRecs);
   for i := 1 to numRecs do
   begin
      dbx^.StatusUpdate(GenFStatus,i,0);
      BuildRecordData;
      dbx^.Blank;
      dbx^.FieldPut('LASTNAME',gfLastName);
      dbx^.FieldPut('FIRSTNAME',gfFirstName);
      dbx^.FieldPut('STREET',gfStreet);
      dbx^.FieldPut('OFFICE',gfOffice);
      dbx^.FieldPut('CITY',gfCity);
      dbx^.FieldPut('STATE',gfState);
      dbx^.FieldPut('ZIP',gfZip);
      dbx^.FieldPut('TELEPHONE',gfTelephone);
      dbx^.FieldPut('BIRTHDATE',gfBirthDate);
      dbx^.FieldPut('PAYMENT',gfPayment);
      dbx^.FieldPut('PAIDFLAG',gfPaidFlag);
      dbx^.FieldPut('RANDOMNUM',gfRandomNum);
      dbx^.FieldPut('UNIQUEID',gfUniqueID);
      if useMemo then
         dbx^.MemoPut('COMMENTS');
      dbx^.Append;
   end;
   dbx^.StatusUpdate(StatusStop,0,0);
end;

end.
