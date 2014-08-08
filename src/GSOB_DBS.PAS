unit GSOB_DBS;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                        dBase III/IV DataBase Handler

           GSOB_DBS (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved 

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       This unit contains the objects to manipulate the data, index,
       and memo files that constitute a database.

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

{$IfNDef Os2} {$V-} {$EndIF}

interface
uses
   Use32,
   GSOB_Var,
   GSOB_Dte,
   GSOB_MMo,
   GSOB_DBF,
   GSOB_Dsk,
   GSOB_Inx,
   GSOB_Str,
   {$IFDEF CLIPPER}
      GSOB_Ntx,
   {$ELSE}
      GSOB_Ndx,
   {$ENDIF}
   {$IFDEF WINDOWS}
      Objects;
   {$ELSE}
      GSOB_Obj;
   {$ENDIF}

const
   IndexesAvail    = 64;
   DBFCacheSize    : Word = 32768;

type

   GSP_FormRec = ^GSR_FormRec;
   GSR_FormRec = record
      FType : Char;
      FDcml : byte;
      FSize : SmallInt{Integer};
      FPosn : array[0..32] of SmallInt{Integer};
      FAlias: string[10];
   end;

   GSP_dBHandler = ^GSO_dBHandler;

   GSP_dBIndex     = ^GSO_dBIndex;
   GSO_dBIndex     = object(GSO_IndexFile)
      DBFObj       : GSP_dBHandler;
      PassCount    : Integer;
      FormRec      : GSR_FormRec;
      Constructor  Init(dbfilobj : GSP_dBHandler; IName : string);
      Constructor  NewInit(dbfilobj : GSP_dBHandler; filname, formla : string; lth, dcl : Integer; typ : char);
      Procedure    IndexUpdate(rnum: longint; fml: GSR_FormRec; apnd: boolean);
      Procedure    WriteStatus(RNum : longint); virtual;
   end;

   GSO_dBHandler = object(GSO_dBaseFld)
      IndexHandle : Integer;
      IndexMaster : GSP_dBIndex;
      IndexStack  : array[1..IndexesAvail] of GSP_dBIndex;
      MemoFile    : GSP_dBMemo;
      CacheFirst  : Longint;
      CacheLast   : Longint;
      CachePtr    : PByteArray;
      CacheRecs   : Integer;
      CacheSize   : LongInt;
      CacheRead   : boolean;
      Found       : boolean;

      constructor Init(FName : string);
      destructor  Done; virtual;
      procedure   Append; virtual;
      procedure   Close; virtual;
      procedure   CopyFile(filname: string);
      procedure   CopyFromIndex(ixColl: GSP_IndxColl; filname: string);
      procedure   CopyMemoRecord(df : GSP_dBHandler);
      procedure   CopyStructure(filname : string);
      Function    Find(st : string) : boolean; virtual;
      Function    FindNear(st : string) : boolean; virtual;
      Procedure   Formula(st : string; var fmrec: GSR_FormRec); virtual;
      Function    FormXtract(fmrec : GSR_FormRec) : string; virtual;
      procedure   GetRec(RecNum : LongInt); virtual;
      Procedure   Index(IName : string);
      Function    IndexOrder(AIndexHandle : Integer) : boolean;
      function    IndexInsert(ix : GSP_dBIndex) : Integer;
      function    IndexMore(IName : string) : Integer;
      Function    IndexTo(filname, formla : string) : Integer;
      Procedure   LoadToIndex(ixColl: GSP_IndxColl; zfld: string);
      Procedure   MemoClear;
      function    MemoGetLine(linenum : Integer) : string;
      Procedure   MemoInsLine(linenum : Integer; st : string); virtual;
      procedure   MemoGet(st : string);
      procedure   MemoGetN(n : Integer);
      Procedure   MemoWidth(l : Integer);
      function    MemoLines : Integer;
      procedure   MemoPut(st : string);
      procedure   MemoPutN(n : Integer);
      procedure   Open; virtual;
      Procedure   Pack;
      Procedure   ReIndex;
      procedure   PutRec(RecNum : LongInt); virtual;
      Procedure   Read(blk : longint; var dat; len : Word); virtual;
      procedure   SetDBFCache(tf: boolean); virtual;
      procedure   Skip(RecCnt : LongInt); virtual;
      procedure   SortFile(filname, zfld: string; isascend : SortStatus);
      Procedure   StatusUpdate(stat1,stat2,stat3 : longint); virtual;
      function    TestFilter : boolean; virtual;
      Procedure   Write(blk : longint; var dat; len : Word); virtual;
      Procedure   Zap;
      Procedure   ZapIndexes;
   end;

   GSP_dbTable = ^GSO_dbTable;
   GSO_dBTable = Object(GSO_IndxColl)
      dbas        : GSP_dBHandler;     {Object to refer to}
      Sel_Item    : longint;            {Last entry selected}
      Scn_Key     : string;             {Holds select key formula}
      fmRec       : GSR_FormRec;
      fmType      : char;
      tbEntry     : GSP_IndxEtry;
      tbSorted    : boolean;

      Constructor Init(var Fil : GSO_dBHandler; zfld : string;
                       sortseq : SortStatus);
      procedure   Build_dBTabl; virtual;
      function    FilterKey : string; virtual;
      function    FindKey_dBTabl(pcnd : string) : boolean; virtual;
      function    FindRec_dBTabl(pcnd : string) : boolean; virtual;
      function    GetKey_dBTabl(keynum: longint): boolean; virtual;
      function    GetRec_dBTabl(keynum: longint): boolean; virtual;
   end;

implementation

var
   FieldPtr : GSP_DBFField;
   IxOrder  : Integer;
constructor GSO_dBHandler.Init(FName : string);
var
   i : Integer;
begin
   GSO_dBaseFld.Init(FName);
   if WithMemo then
      case FileVers of
         DB3WithMemo : MemoFile := New(GSP_dBMemo3, Init(FName,FileVers));
         DB4WithMemo : MemoFile := New(GSP_dBMemo4, Init(FName,FileVers));
      end
   else MemoFile := nil;
   IndexHandle := -1;
   IndexMaster := nil;
   for i := 1 to IndexesAvail do IndexStack[i] := nil;
   CacheRead := false;
   CachePtr := nil;
   Found := false;
end;

destructor GSO_dBHandler.Done;
var
   i : Integer;
begin
   GSO_dBHandler.Close;
   if WithMemo then
   begin
      Dispose(MemoFile, Done);
      WithMemo := false;
   end;
   GSO_dBaseFld.Done;
end;

{------------------------------------------------------------------------------
                              Record Processing
------------------------------------------------------------------------------}

procedure GSO_dBHandler.Append;
var
   i    : Integer;
   ftyp : char;
begin
   GSO_dBaseFld.Append;
   if (IndexHandle > 0) then
   begin
      for i := 1 to IndexesAvail do
      begin
         if IndexStack[i] <> nil then
         begin
            IndexStack[i]^.IndexUpdate(RecNumber,IndexStack[i]^.FormRec,true);
         end;
      end;
   end;
end;                        {Append}

procedure GSO_dBHandler.Close;
var
   i : Integer;
   ix : GSP_dBIndex;
begin
   if WithMemo then MemoFile^.Close;
   for i := 1 to IndexesAvail do
      if IndexStack[i] <> nil then
      begin
         Dispose(IndexStack[i], Done);
         IndexStack[i] := nil;
      end;
   IndexMaster := nil;               {Set index active flag to false}
   IndexHandle := -1;
   if CachePtr <> nil then FreeMem(CachePtr, CacheSize);
   CachePtr := nil;
   CacheSize := 0;
   GSO_dBaseFld.Close;
end;

Function GSO_dBHandler.Find(st : string) : boolean;
var
   RNum   : longint;
begin
   if (IndexMaster <> nil) then
   begin
      RNum := IndexMaster^.KeyFind(st);
      if RNum > 0 then                {RNum = 0 if no match, otherwise}
                                      {it holds the valid record number}
      begin
         GetRec(RNum);                {If match found, read the record}
         Found := True;               {Set Match Found flag true}
      end else
      begin                           {If no matching index key, then}
         Found := False;              {Set Match Found Flag False}
         GetRec(Bttm_Record);
         File_EOF := True;
      end;
   end else                           {If there is no index file, then}
      Found := False;                 {Set Match Found Flag False}
   Find := Found;
end;                  {Find}

Function GSO_dBHandler.FindNear(st : string) : boolean;
var
   RNum   : longint;
begin
   if (IndexMaster <> nil) then
   begin
      RNum := IndexMaster^.KeyFind(st);
      if RNum > 0 then                {RNum = 0 if no match, otherwise}
                                      {it holds the valid record number}
      begin
         GetRec(RNum);                {If match found, read the record}
         Found := True;               {Set Match Found flag true}
      end else
      begin                           {If no matching index key, then}
         Found := False;              {Set Match Found Flag False}
         if IndexMaster^.ixEOF then
         begin
            GetRec(Bttm_Record);
            File_EOF := True;
         end
         else
         begin
            RNum := IndexMaster^.KeyRead(-5);    {Read current index pos}
            GetRec(RNum);                        {read the record}
         end;
      end;
   end else                           {If there is no index file, then}
      Found := False;                 {Set Match Found Flag False}
   FindNear := Found;
end;                  {Find}


procedure GSO_dBHandler.GetRec(RecNum : LongInt);
var
   rnum  : longint;
   cread : boolean;
   okread: boolean;
begin
   cread := CacheRead;
   okread := false;
   File_EOF := false;
   File_TOF := false;
   rnum := RecNum;
   case RecNum of
      Top_Record  : RecNum := Next_Record;
      Bttm_Record : RecNum := Prev_Record;
   end;
   repeat
      if (IndexMaster <> nil) and (RecNum < 0) then
      begin
         CacheRead := false;
         rnum := IndexMaster^.KeyRead(rnum);
         File_EOF := IndexMaster^.ixEOF;
         File_TOF := IndexMaster^.ixBOF;
      end;
      if (not File_EOF) and (not File_TOF) then   {done if EOF reached}
      begin
         GSO_dBaseDBF.GetRec(rnum);
         if RecNum > 0 then okread := true     {done if physical record access}
            else okread := TestFilter;
         rnum := RecNum;
      end;
   until okread or File_EOF or File_TOF;
   CacheRead := cread;
end;

procedure GSO_dBHandler.Open;
begin
   GSO_dBaseFld.Open;
   if WithMemo then MemoFile^.Open;
end;

procedure GSO_dBHandler.PutRec(RecNum : LongInt);
var
   i    : Integer;
   ftyp : char;
begin
   GSO_dBaseFld.PutRec(RecNum);
   if (IndexHandle > 0) then
   begin
      for i := 1 to IndexesAvail do
      begin
         if IndexStack[i] <> nil then
         begin
            IndexStack[i]^.IndexUpdate(RecNumber,IndexStack[i]^.FormRec,false);
         end;
      end;
   end;
end;                        {PutRec}

Procedure GSO_DBHandler.Read(blk : longint; var dat; len : Word);
begin
   if (not CacheRead) or (blk < HeadLen) then
      GSO_DiskFile.Read(blk,dat,len)
   else
   begin
      if (CacheFirst = -1) or
         (blk < CacheFirst) or
         (blk > CacheLast) then
      begin
         GSO_DiskFile.Read(blk,CachePtr^,CacheSize);
         CacheFirst := blk;
         CacheLast := (blk + (dfGoodRec-RecLen));
      end;
      if blk > CacheLast then dfGoodRec := 0
      else
      begin
         dfGoodRec := RecLen;
         Move(CachePtr^[blk - CacheFirst],dat,RecLen);
      end;
   end;
end;

Procedure GSO_DBHandler.SetDBFCache(tf: boolean);
begin
   if tf and CacheRead then exit;
   CacheRead := tf;
   if not tf then
   begin
      if CachePtr <> nil then FreeMem(CachePtr, CacheSize);
      CachePtr := nil;
      CacheSize := 0;
   end
   else
   begin
      CacheSize := MaxAvail;
      if CacheSize > DBFCacheSize then
         CacheSize := DBFCacheSize
      else CacheSize := CacheSize - 16384;
      CacheSize := CacheSize - (CacheSize mod RecLen);
      if CacheSize < RecLen then CacheSize := RecLen;
      GetMem(CachePtr, CacheSize);
      CacheFirst := -1;
      CacheRecs := CacheSize div RecLen;
   end;
end;

PROCEDURE GSO_dBHandler.Skip(RecCnt : LongInt);
VAR
   i  : Integer;
   rs : Word;
   rn : longint;
   de : longint;
   dr : longint;
   rl : longint;
   rc : longint;
begin;
   If RecCnt <> 0 then
   begin
      if RecCnt < 0 then de := Top_Record else de := Bttm_Record;
      rl := RecNumber;
      rn := abs(RecCnt);
      if RecCnt > 0 then dr := Next_Record else dr := Prev_Record;
      if (IndexMaster <> nil) then
      begin
         i := 1;
         repeat
            rc := IndexMaster^.KeyRead(dr);
            if rc > 0 then
            begin
               rl := rc;
               File_EOF := IndexMaster^.ixEOF;
               File_TOF := IndexMaster^.ixBOF;
            end
            else
            begin
               rl := IndexMaster^.KeyRead(de);
               GetRec(rl);                        {restore top/bottom record}
               File_EOF := RecCnt > 0;            {set EOF flag}
               File_TOF := RecCnt < 0;
            end;
            inc(i);
         until (i > rn) or (File_EOF) or (File_TOF);
      end
      else
      begin
         rl := Recnumber + RecCnt;
         File_EOF := (rl > NumRecs);
         File_TOF := (rl < 1);
         if rl < 1 then rl := 1;
         if rl > NumRecs then rl := NumRecs;
      end;
      if File_EOF or File_TOF then
      begin
         if File_EOF then
         begin
            GetRec(rl);
            File_EOF := true;
         end
         else
         begin
            GetRec(rl);
            File_TOF := true;
         end;
      end
      else
      begin
         GetRec(rl);
         if not TestFilter then
         repeat
            GetRec(dr);
         until TestFilter or File_EOF or File_TOF;
      end;
   end;
end;


function GSO_dBHandler.TestFilter: boolean;
begin
   TestFilter := not(DelFlag and (not UseDelRecord));
end;

Procedure GSO_DBHandler.Write(blk : longint; var dat; len : Word);
begin
   GSO_DiskFile.Write(blk,dat,len);
   if (CacheRead) then CacheFirst := -1;
end;


{------------------------------------------------------------------------------
                              Formula Processing
------------------------------------------------------------------------------}


Procedure GSO_dBHandler.Formula(st : string; var fmrec : GSR_FormRec);
var
   FldVal,
   FldWrk : string;
   FldPos : Integer;
   FldCnt : Integer;

   Procedure EvalField(fldst : string);
   var
      fldp  : GSP_DBFField;
      strf  : boolean;
      prnd  : Integer;
   begin
      fldst := TrimL(TrimR(fldst));
      if fldst = '' then exit;
      fldst := AllCaps(fldst);
      prnd := 0;
      strf := false;
      if pos('STR(',fldst) = 1 then prnd := 4
         else
            if pos('DTOC(',fldst) = 1 then prnd := 5
            else
               if pos('DTOS(',fldst) = 1 then prnd := 5;
      if prnd > 0 then
      begin
         strf := true;
         system.Delete(fldst,1,prnd);
         prnd := pos(')',fldst);
         if prnd > 0 then fldst[0] := chr(prnd-1);
      end;
      fldp := AnalyzeField(fldst);
      if fldp <> nil then
      begin
         if not strf and (fldp^.FieldType <> 'C') and (FldCnt = 0) then
         begin
            fmrec.FType := fldp^.FieldType;
            fmrec.FDcml := fldp^.FieldDec;
         end;
         fmrec.FSize := fmrec.FSize + fldp^.FieldLen;
         fmrec.FPosn[FldCnt] := fldp^.FieldNum;
      end
      else
         Error(gsBadFormula, dbsFormulaError);
   end;

begin
   for FldCnt := 0 to 32 do fmrec.FPosn[FldCnt] := 0;
   fmrec.FType := 'C';
   fmrec.FDcml := 0;
   fmrec.FSize := 0;
   FldCnt := 0;
   FldVal := '';                      {Initialize the return string value}
   FldWrk := st;                      {Move the input string to a work field}
   while (FldWrk <> '') and
         (FldCnt < 32) and
         (fmrec.FType = 'C') do       {Repeat while there is still}
                                      {something in the work field.}
   begin
      FldPos := pos('+', FldWrk);     {Search for a '+' delimiter}
      if FldPos = 0 then FldPos := length(FldWrk)+1;
                                      {If no '+' then simulate for this pass}
                                      {by setting position to one beyond the}
                                      {end of the target field string.}
      EvalField(SubStr(FldWrk,1,FldPos-1));
                                      {Go find the field using the substring}
                                      {from the string's beginning to one }
                                      {position before the '+' character.}
      system.delete(FldWrk,1,FldPos); {Delete the string up through the '+'};
      FldWrk := TrimL(FldWrk);        {Remove leading spaces}
      inc(FldCnt);
   end;
end;

Function  GSO_dBHandler.FormXtract(fmrec : GSR_FormRec) : string;
var
   s : string;
   i : Integer;
begin
   s := '';
   i := 0;
   while fmrec.FPosn[i] <> 0 do
   begin
      s := s + FieldGetN(fmRec.FPosn[i]);
      inc(i);
   end;
   FormXtract := s;
end;


{------------------------------------------------------------------------------
                              Index Processing
------------------------------------------------------------------------------}

Procedure GSO_dBHandler.Index(IName : String);
var
   i,j : Integer;                     {Local working variable  }
   st  : String[64];                  {Local working variable}
   ix  : GSP_dBIndex;
begin
   for i := 1 to IndexesAvail do
      if IndexStack[i] <> nil then
      begin
         Dispose(IndexStack[i], Done);
         IndexStack[i] := nil;
      end;
   IndexMaster := nil;               {Set index active flag to false}
   IName := StripChar(' ',IName);
   while (IName <> '') do
   begin
      j := pos(',',IName);
      if j = 0  then j := ord(IName[0]) + 1;
      st := copy(IName,1,j-1);
      System.Delete(IName,1,j);
      if st <> '' then
      begin
         ix := New(GSP_dBIndex, Init(@Self,st));
         i := IndexInsert(ix);
      end;
   end;
end;

Function GSO_dBHandler.IndexInsert(ix : GSP_dBIndex) : Integer;
var
   i   : Integer;                     {Local working variable  }
begin
   i := 1;
   while (IndexStack[i] <> nil) and (i <= IndexesAvail) do inc(i);
   if i <= IndexesAvail then
   begin
      IndexStack[i] := ix;
      IndexInsert := i;
      if IndexMaster = nil then
      begin
         IndexMaster := ix;
         IndexHandle := i;
      end;
   end else IndexInsert := -1;
end;

Function GSO_dBHandler.IndexOrder(AIndexHandle : Integer) : boolean;
var
   s  : string;
   b  : longint;
   i  : byte;
   ix : GSP_dBIndex;
begin
   IndexOrder := true;
   case AIndexHandle of
      0               : begin
                           IndexMaster := nil;
                           IndexHandle := 0;
                        end;
      1..IndexesAvail : begin
                           IndexMaster := IndexStack[AIndexHandle];
                           IndexHandle := AIndexHandle;
                           if IndexMaster <> nil then

                              if RecNumber = 0 then GetRec(Top_Record)
                              else

                              begin
                                 s := FormXtract(IndexMaster^.FormRec);
                                 b := IndexMaster^.KeyFind(s);
                                 while (b <> RecNumber) and (b <> 0) do
                                    b := IndexMaster^.KeyRead(Next_Record);
                              end;
                        end;
      else              IndexOrder := false;
   end;
end;

Function GSO_dBHandler.IndexMore(IName : String) : Integer;
var
   ix : GSP_dBIndex;
begin
   ix := nil;
   IName := StripChar(' ',IName);
   if IName <> '' then ix := New(GSP_dBIndex, Init(@Self,IName));
   if ix <> nil then IndexMore := IndexInsert(ix)
      else IndexMore := -1;
end;

Function GSO_dBHandler.IndexTo(filname, formla : string) : Integer;
var
   i,
   j,
   fl : Integer;                      {Local working variable}
   ftyp : char;
   fval : longint;
   fkey : string;
   s    : string;
   ix   : GSP_dBIndex;
   excl : boolean;
   delf : boolean;
   fmrec : GSR_FormRec;
{
             旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
             �  Main routine.  This takes and analyzes the      �
             �  argument to build an index file.  It does the   �
             �  following:                                      �
             �  1.  Reset current index files.                  �
             �  2.  Get the total new formula field length.     �
             �  3.  Create an index file.                       �
             �  4.  Build the index by reading all dbase        �
             �      records and updating the index file.        �
             읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
}

begin
   StatusUpdate(StatusStart,StatusIndexTo,NumRecs);
   ix := IndexMaster;
   if formla <> '' then
   begin
      s := AllCaps(TrimR(filname));
      i := length(s);
      j := i;
      while (i > 0) and not (s[i] in ['\',':']) do dec(i);
      FmRec.FAlias := copy(s,i+1,(j-i));
      Formula(formla,fmrec);         {Get field length/type of the formula}
      if fmrec.FSize = 0 then exit;           {Exit if formula is no good}
      Open;
      ix := nil;
      filname := StripChar(' ',filname);
      excl := GS_Exclusive;
      GS_SetExclusive(dbOn);
      if filname <> '' then
         ix := New(GSP_dBIndex, NewInit(@Self, filname, formla, fmrec.FSize, fmrec.FDcml, fmrec.FType));
      if ix = nil then
         begin
            IndexTo := -1;
            exit;
         end;
      IndexMaster := nil;
      ix^.KeySort(fmrec.FSize,SortUp);              {Ascending Sort}
      SetDBFCache(dbOn);
      delf := UseDelRecord;
      UseDelRecord := true;
      GetRec(Top_Record);             {Read all dBase file records}
      while not File_EOF do
      begin
         fkey := FormXtract(fmrec);
         ix^.ixColl^.InsertKey(RecNumber,fkey);
         StatusUpdate(StatusIndexTo,RecNumber,0);
         GetRec(Next_Record);
      end;
      UseDelRecord := delf;
      SetDBFCache(dbOff);
      StatusUpdate(StatusStop,0,0);
      StatusUpdate(StatusStart,StatusIndexWr,NumRecs);
      ix^.IndxStore(ix^.ixColl,true);
      GetRec(Top_Record);             {Reset to top record}
      Dispose(ix, Done);
      GS_SetExclusive(excl);
      ix := New(GSP_dBIndex, Init(@Self,filname));
      if ix <> nil then
      begin
         IndexTo := IndexInsert(ix);
         IndexMaster := ix;
      end;
   end
      else IndexTo := -1;
   StatusUpdate(StatusStop,0,0);
end;

Procedure GSO_dBHandler.ReIndex;
var
   rxIndexHandle : Integer;
   rxIndexMaster : GSP_dBIndex;
   rxIndexStack  : array[1..IndexesAvail] of GSP_dBIndex;
   fm  : string[255];
   nam : string[80];
   i   : Integer;
   k   : Integer;
   h   : Integer;
begin
   rxIndexHandle := IndexHandle;
   rxIndexMaster := IndexMaster;

   for i := 1 to IndexesAvail do
   begin
      rxIndexStack[i]  := IndexStack[i];
      IndexStack[i] := nil;
   end;
   IndexMaster := nil;               {Set index active flag to false}
   IndexHandle := -1;

   for i := 1 to IndexesAvail do
   begin
      if rxIndexStack[i] <> nil then
      begin
         fm := rxIndexStack[i]^.ixKey_Form;
         nam := rxIndexStack[i]^.dfFileName;
         k := pos('.',nam);
         if k <> 0 then system.delete(nam,k,4);
         Dispose(rxIndexStack[i], Done);
         k := IndexTo(nam,fm);
         if i = rxIndexHandle then h := i;
      end;
   end;

   if h > 0 then
   begin
      IndexMaster := IndexStack[h];
      IndexHandle := h;
   end;
end;


{------------------------------------------------------------------------------
                               Memo Routines
------------------------------------------------------------------------------}

procedure GSO_dBHandler.MemoClear;
begin
   MemoFile^.MemoClear;
end;

procedure GSO_dBHandler.MemoGet(st : string);
var
   v : longint;
   s : string;
begin
   FieldPtr := AnalyzeField(st);
   if (FieldPtr <> nil) and (FieldPtr^.FieldType = 'M') then
   begin
      move(FieldPtr^.FieldAddress^,s[1], FieldPtr^.FieldLen);
      s[0] := chr(FieldPtr^.FieldLen);
      v := ValWholeNum(s);
      MemoFile^.MemoGet(v);
   end
   else Error(gsBadFieldType, dbsMemoGetError)
end;

procedure GSO_dBHandler.MemoGetN(n : Integer);
var
   v : longint;
   s : string;
begin
   FieldPtr := @Fields^[n];
   if (FieldPtr <> nil) and (FieldPtr^.FieldType = 'M') then
   begin
      move(FieldPtr^.FieldAddress^, s[1], FieldPtr^.FieldLen);
      s[0] := chr(FieldPtr^.FieldLen);
      v := ValWholeNum(s);
      MemoFile^.MemoGet(v);
   end
   else Error(gsBadFieldType, dbsMemoGetNError)
end;

function GSO_dBHandler.MemoGetLine(linenum : Integer) : string;
begin
   MemoGetLine := MemoFile^.MemoGetLine(linenum-1);
end;

Procedure GSO_dBHandler.MemoInsLine(linenum : Integer; st : string);
begin
   MemoFile^.MemoInsLine(linenum-1,st);
end;

function GSO_dBHandler.MemoLines : Integer;
begin
   MemoLines := MemoFile^.MemoLines;
end;

procedure GSO_dBHandler.MemoPut(st : string);
begin
   FieldPtr := AnalyzeField(st);
   MemoPutN(-713);         {Use MemoPutN to do work.}
                           {-713 tells MemoPutN that FieldPtr is valid}
end;

procedure GSO_dBHandler.MemoPutN(n : Integer);
var
   v1, v2 : longint;
   rsl    : Word;
   i      : Integer;
   s      : string;
begin
   if n <> -713 then FieldPtr := @Fields^[n];  {-713 if called from MemoPut}
   if (FieldPtr <> nil) and (FieldPtr^.FieldType = 'M') then
   begin
      move(FieldPtr^.FieldAddress^, s[1], FieldPtr^.FieldLen);
      s[0] := chr(FieldPtr^.FieldLen);
      v1 := ValWholeNum(s);
      i := 0;
      v2 := MemoFile^.MemoPut(v1);
      if v1 <> v2 then
      begin
         s := StrWholeNum(v2,10);
         move(s[1],FieldPtr^.FieldAddress^,FieldPtr^.FieldLen);
      end;
   end
   else Error(gsBadFieldType, dbsMemoPutNError)
end;

Procedure GSO_dBHandler.MemoWidth(l : Integer);
begin
   MemoFile^.Edit_Lgth := l;
end;

{------------------------------------------------------------------------------
                  File Modifying Routine (Sort, Copy, Pack, Zap)
------------------------------------------------------------------------------}

Procedure GSO_dBHandler.CopyFile(filname : string);
var
   ix     : pointer;
   FCopy  : GSP_dBHandler;
   NuFile : GSP_DBFBuild;
   rr     : GSP_IndxEtry;
   keyct  : Integer;
   crd  : boolean;

BEGIN
   repeat until LokFile;
   StatusUpdate(StatusStart,StatusCopy,RecsInFile);
   ix := IndexMaster;
   IndexMaster := nil;
   crd := CacheRead;
   SetDBFCache(dbOn);
   keyct := 0;
   CopyStructure(filname);
   FCopy := New(GSP_dBHandler, Init(filname));
   FCopy^.Open;
   GetRec(Top_Record);
   while not File_EOF do           {Read .DBF sequentially}
   begin
      move(CurRecord^,FCopy^.CurRecord^,RecLen+1);
      if WithMemo then CopyMemoRecord(FCopy);
      FCopy^.Append;
      StatusUpdate(StatusCopy,RecNumber,0);
      GetRec(Next_Record);
   end;
   Dispose(FCopy, Done);
   StatusUpdate(StatusStop,0,0);
   SetDBFCache(crd);
   IndexMaster := ix;
   LokOff;
END;                        { CopyFile }

procedure GSO_dBHandler.CopyMemoRecord(df : GSP_dbHandler);
var
   fp : Integer;
   mbuf : array[0..GS_dBase_MaxMemoRec+1] of byte;
   mcnt : Word;
   rl   : FloatNum;
   tcnt : longint;
   vcnt : longint;
   i    : Integer;
   blk  : longint;
begin
   FillChar(mbuf,GS_dBase_MaxMemoRec,#0);
   for fp := 1 to NumFields do
   begin
      if Fields^[fp].FieldType = 'M' then
      begin
         blk := Trunc(NumberGetN(fp));
         if (blk <> 0) then
         begin
            mcnt := MemoFile^.MemoBlocks(blk);
            i := 0;
            df^.MemoFile^.Read(0, mbuf, 1);
            move(mbuf,tcnt,4);               {Get next block}
            vcnt := tcnt+mcnt;
            move(vcnt,mbuf,4);
            df^.MemoFile^.Write(0,mbuf,1);   {update next block}
            rl := tcnt;
            df^.NumberPutN(fp,rl);
            repeat
               MemoFile^.Read(blk+i,mbuf,1);
               df^.MemoFile^.Write(tcnt+i,mbuf,1);
               inc(i);
            until i = mcnt;
         end;
      end;
   end;
end;

procedure GSO_dBHandler.CopyStructure(filname : string);
var
   NuFile : GSP_DBFBuild;
   fp     : Integer;
BEGIN
   if FileVers = DB4WithMemo then
      NuFile := New(GSP_DB4Build, Init(filname))
   else
      NuFile := New(GSP_DB3Build, Init(filname));
   for fp := 1 to NumFields do
      NuFile^.InsertField(FieldName(fp),Fields^[fp].FieldType,
                          Fields^[fp].FieldLen,Fields^[fp].FieldDec);
   dispose(NuFile, Done);
END;

Procedure GSO_dBHandler.Pack;
var
   rxIndexHandle : Integer;
   rxIndexMaster : GSP_dBIndex;
   fp            : Integer;
   i, j          : longint;
begin      {Pack}
   if dfFileShrd then Error(dosAccessDenied, dbsPackError);
   rxIndexHandle := IndexHandle;
   rxIndexMaster := IndexMaster;
   IndexMaster := nil;               {Set index active flag to false}
   IndexHandle := -1;
   StatusUpdate(StatusStart,StatusPack,NumRecs);
   j := 0;
   for i := 1 to NumRecs do           {Read .DBF sequentially}
   begin
      Read(HeadLen+((i-1) * RecLen), CurRecord^, RecLen);
      RecNumber := i;
      DelFlag := CurRecord^[0] = GS_dBase_DltChr;
      if not DelFlag then             {Write to work file if not deleted}
      begin
         inc(j);                      {Increment record count for packed file }
         PutRec(j);
      end
      else
         if WithMemo then
         begin
            for fp := 1 to NumFields do
            begin
               if Fields^[fp].FieldType = 'M' then
               begin
                  MemoFile^.Memo_Loc := Trunc(NumberGetN(fp));
                  if (MemoFile^.Memo_Loc <> 0) then
                     MemoFile^.MemoBlockRelease(MemoFile^.Memo_Loc);
               end;
            end;
         end;
      StatusUpdate(StatusPack,i,0);
   end;
   if i > j then                      {If records were deleted then...}
   begin
      NumRecs := j;                   {Store new record count in objectname}
      Write(HeadLen+(j*RecLen), EOFMark, 1);
                                      {Write End of File byte at file end}
      Truncate(HeadLen+(j*RecLen)+1);
                                      {Set new file size for dBase file};
   end;
   StatusUpdate(StatusStop,0,0);
   IndexHandle := rxIndexHandle;
   IndexMaster := rxIndexMaster;
   ReIndex;
END;                        { Pack }

                     {-------------------------------}

{-----------------------------------------------------------------------------
                               File Sorting Routines
-----------------------------------------------------------------------------}


Procedure GSO_dBHandler.LoadToIndex(ixColl: GSP_IndxColl; zfld: string);
var
   crd  : boolean;
   ix   : pointer;
   fkey : GSR_FormRec;
   ftyp : char;
begin
   StatusUpdate(StatusStart,StatusSort,RecsInFile);
   ix := IndexMaster;
   IndexMaster := nil;
   crd := CacheRead;
   SetDBFCache(dbOn);
   GetRec(Top_Record);             {Read all dBase file records}
   while not File_EOF do
   begin
      Formula(zfld, fkey);
      ixColl^.InsertKey(RecNumber, FormXtract(fkey));
      StatusUpdate(StatusSort,RecNumber,0);
      GetRec(Next_Record);
   end;
   SetDBFCache(crd);
   IndexMaster := ix;
   GetRec(Top_Record);             {Reset to top record}
   StatusUpdate(StatusStop,0,0);
end;

procedure GSO_dBHandler.CopyFromIndex(ixColl: GSP_IndxColl; filname: string);
var
   FCopy  : GSP_dBHandler;
   NuFile : GSP_DBFBuild;
   rr     : GSP_IndxEtry;
   keyct  : Integer;
   crd  : boolean;

BEGIN
   StatusUpdate(StatusStart,StatusCopy,ixColl^.KeyCount);
   crd := CacheRead;
   SetDBFCache(dbOff);
   keyct := 0;
   CopyStructure(filname);
   FCopy := New(GSP_dBHandler, Init(filname));
   FCopy^.Open;
   rr := ixColl^.RetrieveKey;
   while rr <> nil do
   begin
      GetRec(rr^.Tag);
      move(CurRecord^,FCopy^.CurRecord^,RecLen);
      if WithMemo then CopyMemoRecord(FCopy);
      FCopy^.Append;
      inc(keyct);
      StatusUpdate(StatusCopy,keyct,0);
      rr := ixColl^.RetrieveKey;
   end;
   SetDBFCache(crd);
   FCopy^.Close;
   Dispose(FCopy, Done);
   StatusUpdate(StatusStop,0,0);
end;

Procedure GSO_dBHandler.SortFile(filname, zfld: string; isascend : SortStatus);
var
   fl    : Integer;                      {Local working variable}
   fkey  : GSR_FormRec;
   ftyp  : char;
   ixColl: GSP_IndxColl;

begin

   if GS_FileIsOpen(filname+DBExtension) then
   begin
      Error(gsFileAlreadyOpen, dbsSortFile);
      exit;
   end;

   if zfld <> '' then
   begin
      Formula(zfld, fkey);  {use to get length}
      fl := fkey.FSize;
      if fl = 0 then
      begin
         Error(gsBadFormula, dbsSortFile);
         exit;                        {Exit if formula is no good}
      end;
      ixColl := New(GSP_IndxColl, Init(fl, isascend));
      LoadToIndex(ixColl, zfld);
      CopyFromIndex(ixColl, filname);
      Dispose(ixColl, Done);
   end;
end;

                     {-------------------------------}

Procedure GSO_dBHandler.Zap;
var
   mbuf : array[0..GS_dBase_MaxMemoRec] of byte;
   i, j : longint;                    {Local variables   }
begin              {Zap}
   if dfFileShrd then Error(dosAccessDenied,dbsZapError);
   ZapIndexes;
   if WithMemo then
   begin
      MemoFile^.Read(0,mbuf,1);
      mbuf[0] := 1;
      MemoFile^.Write(0,mbuf,1);
      MemoFile^.Truncate(1);
   end;
   NumRecs := 0;                   {Store new record count in objectname}
   RecNumber := 0;
   Write(HeadLen, EOFMark, 1);
   Truncate(HeadLen);
   dStatus := Updated;
   Close;
   Open;
END;                        { Zap }

Procedure GSO_dBHandler.StatusUpdate(stat1,stat2,stat3 : longint);
begin
end;

Procedure GSO_dBHandler.ZapIndexes;
var
   i : Integer;
begin
   for i := 1 to IndexesAvail do
      if IndexStack[i] <> nil then IndexStack[i]^.IndxClear;
end;

{------------------------------------------------------------------------------
                               GSO_dBIndex
------------------------------------------------------------------------------}

Constructor GSO_dBIndex.Init(dbfilobj : GSP_dBHandler; IName : string);
var
   s : string;
   i,j : Integer;
begin
   GSO_IndexFile.Init(IName);
   DBFObj := dbfilobj;
   s := AllCaps(TrimR(IName));
   i := length(s);
   j := i;
   while (i > 0) and not (s[i] in ['\',':']) do dec(i);
   FormRec.FAlias := copy(s,i+1,(j-i));
   DBFObj^.Formula(IxKey_Form, FormRec);
   IxKey_Typ := FormRec.FType;
   PassCount := 0;
end;


Constructor GSO_dBIndex.NewInit(dbfilobj : GSP_dBHandler; filname,
                                formla: string; lth, dcl: Integer; typ: char);
var
   s : string;
   i,j : Integer;
begin
   GSO_IndexFile.NewInit(filname, formla, lth, dcl, typ);
   DBFObj := dbfilobj;
   s := AllCaps(TrimR(filname));
   i := length(s);
   j := i;
   while (i > 0) and not (s[i] in ['\',':']) do dec(i);
   FormRec.FAlias := copy(s,i+1,(j-i));
   PassCount := 0;
end;

Procedure GSO_dBIndex.IndexUpdate(rnum: longint; fml: GSR_FormRec;
                                  apnd: boolean);
begin
   KeyUpdate(rnum, DBFObj^.FormXtract(fml), apnd);
end;

Procedure GSO_dBIndex.WriteStatus(RNum : longint);
begin
   if RNum = 1 then inc(PassCount);
   DBFObj^.StatusUpdate(StatusIndexWr,RNum,PassCount);
end;

{-----------------------------------------------------------------------------
                               GSO_dBTable
-----------------------------------------------------------------------------}

Constructor GSO_dBTable.Init(var Fil: GSO_dBHandler; zfld: string;
                                 sortseq: SortStatus);
begin
   zfld := AllCaps(zfld);
   Fil.Formula(zfld, fmRec);
   fmType := fmRec.FType;
   GSO_IndxColl.Init(fmRec.FSize,sortseq);
   dBas := @Fil;
   Sel_Item := 1;
   tbSorted := sortseq <> NoSort;
   Scn_Key := zfld;
end;

procedure GSO_dBTable.Build_dBTabl;
var
   t : string;
   crd : boolean;
   ia : pointer;
   i  : Integer;
   z  : GSP_IndxColl;
begin
   with dBas^ do
   begin
      ia := IndexMaster;
      IndexMaster := nil;
      crd := CacheRead;
      SetDBFCache(dbOn);
      GetRec(Top_Record);             {Read all dBase file records}
      while not File_EOF do
      begin
         t := FilterKey;
         InsertKey(RecNumber,t);
         GetRec(Next_Record);
      end;
      SetDBFCache(crd);
      IndexMaster := ia;
      GetRec(Top_Record);             {Reset to top record}
      if tbSorted and (Count > 1) then
      begin
         z := new(GSP_IndxColl, InitNode(@Self));
         i := 1;
         tbEntry := RetrieveKey;
         while tbEntry <> nil do
         begin
            z^.InsertKey(tbEntry^.Tag,tbEntry^.KeyStr);
            inc(i);
            tbEntry := RetrieveKey;
         end;
         FreeAll;
         for i := 0 to z^.Count-1 do Insert(z^.Items^[i]);
         z^.Count := 0;
         Dispose(z, Done);
      end;
   end;
end;

function GSO_dBTable.FilterKey: string;
begin
   FilterKey := dbas^.FormXtract(fmRec);
end;

function GSO_dBTable.FindKey_dBTabl(pcnd : string) : boolean;
var
   Search: Boolean;
   L, H,
   I, C  : Integer;
begin
   Search := False;
   L := 1;
   H := KeyCount;
   while L <= H do
   begin
      I := (L + H) shr 1;
      tbEntry := PickKey(I);
      if tbEntry^.KeyStr < pcnd  then L := I + 1 else
      begin
         H := I - 1;
         if pcnd = tbEntry^.KeyStr then Search := True;
      end;
   end;
   tbEntry := PickKey(L);
   FindKey_dBTabl := Search;
end;

function GSO_dBTable.FindRec_dBTabl(pcnd : string) : boolean;
begin
   if FindKey_dBTabl(pcnd) then
   begin
       FindRec_dBTabl := true;
       dBas^.GetRec(tbEntry^.Tag);
   end
      else FindRec_dBTabl := false;
end;

function GSO_dBTable.GetKey_dBTabl(keynum: longint): boolean;
begin
   tbEntry := PickKey(keynum);
   GetKey_dBTabl := tbEntry <> nil;
end;

function GSO_dBTable.GetRec_dBTabl(keynum: longint) : boolean;
begin
   if GetKey_dBTabl(keynum) then
   begin
       GetRec_dBTabl := true;
       dBas^.GetRec(tbEntry^.Tag);
   end
      else GetRec_dBTabl := false;
end;



end.
{-----------------------------------------------------------------------------}
                                    END
