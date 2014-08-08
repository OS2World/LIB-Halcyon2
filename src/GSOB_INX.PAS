unit GSOB_INX;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                                 Index Handler

           GSOB_INX (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved 

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       This unit handles the objects for all indexed lists.

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

{$O+} {Vp/2 simply ignore this!}

interface

uses
   Use32,
   GSOB_Var,
   GSOB_Dsk,                          {File handler routines}
   GSOB_Str,                          {String handler routines,}
   {$IFDEF WINDOWS}
      Objects;
   {$ELSE}
      GSOB_Obj;
   {$ENDIF}

const

   ixAscending      = true;
   ixDescending     = false;

   IndexPageSize = 16384;
   MaxTagValue   = MaxLongint;
   NilTagValue   = -1;
   NoTagValue    = -2;

type

   ixFileStatus = (ixInvalid, ixNotUpdated, ixUpdated);

   ixKeyString  = string;

   GSP_IndxEtry = ^GSR_IndxEtry;
   GSR_IndxEtry = Record
      Tag         : Longint;
      KeyStr      : String;
   end;

   GSP_IndxFile = ^GSO_IndxFile;
   GSO_IndxFile = Object(GSO_DiskFile)
      IndxBufr    : PByteArray;
      Next_Blk    : Longint;
      constructor Init;
      destructor  Done; virtual;
      procedure   ReleasePage(page: longint); virtual;
      function    GetPageNo: longint; virtual;
   end;

   GSP_IndxColl = ^GSO_IndxColl;
   GSO_IndxColl = Object(TCollection)
      ixSortType  : SortStatus;
      EntrySize   : Integer;
      KeyLength   : Integer;
      KeysOnPage  : Integer;
      ixBufrSize  : Word;
      ixBufrKeys  : Integer;
      WorkPage    : Integer;
      LastGoTo    : longint;
      KeyCount    : longint;
      BOF_Key     : boolean;
      EOF_Key     : boolean;
      constructor Init(KLength : Integer; sorttype : SortStatus);
      constructor InitNode(CLink : GSP_IndxColl);
      procedure   EndRetrieve; virtual;
      procedure   InsertKey(recno: longint; s: string); virtual;
      function    MakeNewPage : pointer; virtual;
      function    PickKey(knum : longint) : GSP_IndxEtry; virtual;
      function    RetrieveKey : GSP_IndxEtry; virtual;
      procedure   StoreIndex(p : GSP_IndxColl; recnode : boolean); virtual;
   end;

   GSP_IndxPage = ^GSO_IndxPage;
   GSO_IndxPage = Object(TSortedCollection)
      CollLink    : GSP_IndxColl;   {Link to collection owner}
      Etry_No     : Integer;        {Last entry accessed}
      Etry_Up     : Integer;
      IsActive    : boolean;        {True if page is in memory, false if filed}
      Last_Key    : GSP_IndxEtry;   {Last Key in page. Valid only when filed}
      Page_No     : longint;        {Disk block holding filed page}
      IndxRBuf    : PByteArray;
      RBufEtry    : Integer;
      RBufPosn    : Integer;
      RBufStep    : Integer;
      RBufSize    : Word;
      RKeyLgth    : Integer;
      constructor Init(CLink : pointer);
      destructor  Done; virtual;
      procedure   AtInsert(Index: Integer; Item : pointer); virtual;
      procedure   CheckLimit; virtual;
      function    Compare(Key1, Key2 : pointer) : Integer; virtual;
      procedure   FreeAllElements; virtual;
      procedure   Insert(Item : pointer); virtual;
      procedure   PageLoad; virtual;
      procedure   PageStore; virtual;
      procedure   Retrieve; virtual;
      procedure   SetBuffer(BSize, BKeys, BLgth:Integer); virtual;
   end;

var
   ExactIndexMatch : boolean;
   CollPool : GSP_IndxFile;
   KeepEntry : GSR_IndxEtry;

{------------------------------------------------------------------------------
                               IMPLEMENTATION SECTION
------------------------------------------------------------------------------}

implementation

const

   ValueHigh   = 1;    {Token value passed for key comparison high}
   ValueLow    = -1;   {Token value passed for key comparison low}
   ValueEqual  = 0;    {Token value passed for key comparison equal}

   Null_Key = 0;    {file not accessed yet}
   Next_Key = -1;   {Token value passed to read next record}
   Prev_Key = -2;   {Token value passed to read previous record}
   Top_Key  = -3;   {Token value passed to read first record}
   Bttm_Key = -4;   {Token value passed to read final record}
   Same_Key = -5;   {Token value passed to re-read the record}
   EOF_Key  = -6;   {Token value returned if access beyond EOF/TOF}

   EtryAdjust = 5;  {Added to Key Length to account for GSR_IndxEtry size}

var
   ExitSave : pointer;
   Etry_Ptr : GSP_IndxEtry;
   Page_Ptr : GSP_IndxPage;

{------------------------------------------------------------------------------
                               GSO_IndxFile
------------------------------------------------------------------------------}

constructor GSO_IndxFile.Init;
var
   fn : string[12];
begin
   fn := Unique_Field + '.CPx';
   GSO_DiskFile.Init(fn,dfReadWrite);
   GetMem(IndxBufr,IndexPageSize);
   if IndxBufr = nil then exit;
   GSO_DiskFile.Rewrite(1);
   Next_Blk := 0;
end;

destructor GSO_IndxFile.Done;
begin
   if IndxBufr <> nil then FreeMem(IndxBufr,IndexPageSize);
   Close;
   Erase;
   GSO_DiskFile.Done;
   CollPool := nil;
end;

function GSO_IndxFile.GetPageNo: longint;
begin
   GetPageNo := Next_Blk;
   if FileSize = Next_Blk then inc(Next_Blk,IndexPageSize)
   else
   begin
      Read(Next_Blk,IndxBufr^,4);
      move(IndxBufr^,Next_Blk,4);
   end;
end;

procedure GSO_IndxFile.ReleasePage(page: longint);
begin
   if page <> -1 then
   begin
      move(Next_Blk,IndxBufr^,4);
      Next_Blk := page;
      Write(Next_Blk,IndxBufr^,4);
   end;
end;

{------------------------------------------------------------------------------
                               GSO_IndxColl
------------------------------------------------------------------------------}

constructor GSO_IndxColl.Init(KLength : Integer; sorttype : SortStatus);
var
   p  : pointer;
   fn : string[12];
begin
   TCollection.Init(64,32);
   ixSortType := sorttype;
   KeyLength := KLength;
   EntrySize := KeyLength+EtryAdjust;  {Key length+length byte+SizeOf(longint)}
   KeysOnPage :=  (IndexPageSize div EntrySize) - 1;
   p := MakeNewPage;
   Insert(p);
   WorkPage := 0;
   ixBufrSize := 0;
   ixBufrKeys := 0;
   LastGoTo := Null_Key;
   KeyCount := 0;
   BOF_Key := false;
   EOF_Key := false;
end;

constructor GSO_IndxColl.InitNode(CLink : GSP_IndxColl);
begin
   Init(CLink^.KeyLength,CLink^.ixSortType);
end;

Procedure GSO_IndxColl.EndRetrieve;
var
   i : Integer;
   w : GSP_IndxPage;
begin
   if ixBufrSize = 0 then exit;
   for i := 0 to Count-1 do
   begin
      w := Items^[i];
      if w^.IndxRBuf <> nil then FreeMem(w^.IndxRBuf, w^.RBufSize);
      w^.IndxRBuf := nil;
   end;
   ixBufrSize := 0;
end;

procedure GSO_IndxColl.InsertKey(recno: longint; s: string);
var
   p : GSP_IndxEtry;
   w : GSP_IndxPage;
begin
   GetMem(p, EntrySize);
   move(s, p^.KeyStr, KeyLength+1);
   p^.Tag := recno;
   w := Items^[WorkPage];
   if ixSortType = NoSort then
      w^.AtInsert(w^.Count, p)
   else
      w^.Insert(p);
   inc(KeyCount);
end;

function GSO_IndxColl.MakeNewPage : pointer;
begin
   MakeNewPage := New(GSP_IndxPage, Init(@Self));
end;


function GSO_IndxColl.PickKey(knum : longint) : GSP_IndxEtry;
var
   e : Integer;
   i : Integer;
   p : GSP_IndxEtry;
   w : GSP_IndxPage;
begin
   BOF_Key := false;
   EOF_Key := false;
   if GSP_IndxPage(Items^[WorkPage])^.Count = 0 then
   begin
      PickKey := nil;
      exit;                          {No keys in the file}
   end;
   if (LastGoTo = Null_Key) then
   begin                             {This is the first read}
      case knum of
         Next_Key  : knum := Top_Key;
         Prev_Key  : knum := Bttm_Key;
      end;
   end;
   case knum of
      Top_Key   : LastGoTo := 1;
      Bttm_Key  : LastGoTo := KeyCount;
      Next_Key  : inc(LastGoTo);
      Prev_Key  : dec(LastGoTo);
      else LastGoTo := knum;
   end;
   if LastGoTo < 1 then BOF_Key := true
      else if LastGoTo > KeyCount then EOF_Key := true;
   if BOF_Key or EOF_Key then PickKey := nil
   else
   begin
      e := (LastGoTo-1) div KeysOnPage;
      i := (LastGoTo-1) mod KeysOnPage;
      w := Items^[e];
      if e <> WorkPage then
      begin
         GSP_IndxPage(Items^[WorkPage])^.PageStore;
         w^.PageLoad;
         WorkPage := e;
      end;
      p := GSP_IndxEtry(w^.Items^[i]);
      move(p^, KeepEntry, EntrySize);
      PickKey := @KeepEntry;
   end;
end;


function GSO_IndxColl.RetrieveKey : GSP_IndxEtry;
var
   e : Integer;
   f : Integer;
   i : longint;
   m : longint;
   p : GSP_IndxEtry;
   q : GSP_IndxEtry;
   w : GSP_IndxPage;
begin
   if GSP_IndxPage(Items^[WorkPage])^.Count = 0 then
   begin
      RetrieveKey := nil;
      exit;
   end;
   if ixBufrSize = 0 then
   begin
      m := MemAvail;
      m := m - (IndexPageSize*2);
      m := m div Count;
      i := IndexPageSize div 8;
      while (i > m) and (i > 128) do i := i div 2;
      if i = 128 then Error(tpHeapOverFlow, inxRetrieveKeyError);
      ixBufrSize := i;
      ixBufrKeys := ixBufrSize div EntrySize;
      if Count > 1 then
      begin
         for f := 0 to Count-1 do
         begin
            w := Items^[f];
            if not w^.IsActive then
               w^.SetBuffer(i,ixBufrKeys, EntrySize);
         end;
      end;
   end;
   e := -1;
   i := 0;
   while (i < Count) do
   begin
      w := Items^[i];
      if w^.Etry_Up < w^.Etry_No then
      begin
         if w^.IsActive then q := w^.At(w^.Etry_Up)
            else  q := w^.Last_Key;
         if e = -1 then
         begin
            e := i;
            p := q;
         end
         else
         begin
            if w^.Compare(p, q) > 0 then
            begin
               e := i;
               p := q;
            end;
         end;
      end;
      inc(i);
   end;
   if e = -1 then
   begin
      RetrieveKey := nil;
      exit;
   end;
   move(p^, KeepEntry, EntrySize);
   RetrieveKey := @KeepEntry;
   w := Items^[e];
   w^.Retrieve;
end;

Procedure GSO_IndxColl.StoreIndex(p : GSP_IndxColl; recnode : boolean);
begin
end;

{------------------------------------------------------------------------------
                               GSO_IndxPage
------------------------------------------------------------------------------}

constructor GSO_IndxPage.Init(CLink : pointer);
begin
   TSortedCollection.Init(GSP_IndxColl(CLink)^.KeysOnPage+1,64);
   IndxRBuf := nil;
   IsActive := true;
   Page_No := -1;
   Last_Key := nil;
   Etry_No := -1;
   Etry_Up := 0;
   CollLink := CLink;
end;

destructor GSO_IndxPage.Done;
begin
   if Page_No >= 0 then CollPool^.ReleasePage(Page_No);
   FreeAllElements;
   if IndxRBuf <> nil then FreeMem(IndxRBuf, RBufSize);
   if Last_Key <> nil then FreeMem(Last_Key,CollLink^.EntrySize);
   TSortedCollection.Done;
end;

procedure GSO_IndxPage.AtInsert(Index: Integer; Item : Pointer);
begin
   TCollection.AtInsert(Index,Item);
   Etry_No := Count;
   CheckLimit;
end;

procedure GSO_IndxPage.CheckLimit;
var
   p : GSP_IndxPage;
begin
   if Count <= CollLink^.KeysOnPage then exit;
   p := CollLink^.MakeNewPage;
   CollLink^.AtInsert(CollLink^.WorkPage+1,p);
   inc(CollLink^.WorkPage);
   PageStore;
end;

function GSO_IndxPage.Compare(Key1, Key2 : pointer) : Integer;
var
   k1  : GSP_IndxEtry absolute Key1;
   k2  : GSP_IndxEtry absolute Key2;
   flg : Integer;
begin
   if (Key1 = nil) or (Key2 = nil) then
   begin
      if (Key1 = nil) and (Key2 = nil) then flg := ValueEqual
         else if Key1 = nil then flg := ValueLow
            else flg := ValueHigh;
   end
   else
   begin
      if k1^.KeyStr <  k2^.KeyStr then flg := ValueLow
         else if k1^.KeyStr >  k2^.KeyStr then flg := ValueHigh
            else flg := ValueEqual;
   end;
   if (flg = ValueEqual) and (k2^.Tag <> NoTagValue) then
   begin
      if k1^.Tag = k2^.Tag then flg := ValueEqual
         else if k1^.Tag > k2^.Tag then flg := ValueHigh
            else flg := ValueLow;
   end;
   if CollLink^.ixSortType = SortDown then
      if flg = ValueLow then flg := ValueHigh
         else if flg = ValueHigh then flg := ValueLow;
   Compare := flg;
end;

procedure GSO_IndxPage.FreeAllElements;
var
   i : Integer;
begin
   for i := 0 to Count-1 do
      FreeMem(Items^[i],length(GSP_IndxEtry(Items^[i])^.KeyStr)+EtryAdjust);
   Count := 0;
end;

procedure GSO_IndxPage.Insert(Item : Pointer);
var
   I : Integer;
   B : boolean;
begin
   B := Search(KeyOf(Item),I);
   AtInsert(I, Item);
end;

procedure GSO_IndxPage.PageLoad;
var
   entsize : Integer;
   i       : Integer;
   p       : GSP_IndxEtry;
   q       : GSP_IndxEtry;
begin
   entsize := CollLink^.EntrySize;
   IsActive := true;
   if Page_No < 0 then exit;
   CollPool^.Read(Page_No, CollPool^.IndxBufr^, IndexPageSize);
   for i := 0 to Etry_No - 1 do
   begin
      p := @CollPool^.IndxBufr^[i*entsize];
      GetMem(q, entsize);
      move(p^, q^, entsize);
      AtInsert(Count, q);
   end;
end;

procedure GSO_IndxPage.PageStore;
var
   entsize : Integer;
   i       : Integer;
begin
   if CollPool = nil then CollPool := New(GSP_IndxFile, Init);
   entsize := CollLink^.EntrySize;
   if Page_No < 0 then Page_No := CollPool^.GetPageNo;
   IsActive := false;
   Etry_No := Count;
   if Last_Key = nil then GetMem(Last_Key, entsize);
   Move(Items^[0]^, Last_Key^, entsize);
   for i := 0 to Count-1 do
      move(Items^[i]^, CollPool^.IndxBufr^[i*entsize], entsize);
   CollPool^.Write(Page_No, CollPool^.IndxBufr^, IndexPageSize);
   FreeAllElements;
   SetLimit(0);
end;

procedure GSO_IndxPage.Retrieve;
var
   i : longint;
   v : Integer;
   z : Integer;
begin
   inc(Etry_Up);
   if IsActive then exit;
   inc(RBufPosn);
   if RBufPosn >= RBufEtry then
   begin
      RBufPosn := 0;
      v := Etry_No - Etry_Up;
      if v > RBufEtry then v := RBufEtry;
      i := (Page_No) + (Etry_Up * RKeyLgth);
      CollPool^.Read(i,IndxRBuf^, v * RKeyLgth);
   end;
   move(IndxRBuf^[RBufPosn * RKeyLgth], Last_Key^, RKeyLgth);
end;

Procedure GSO_IndxPage.SetBuffer(BSize, BKeys, BLgth:Integer);
begin
   RBufSize := BSize;
   RBufEtry := BKeys;
   RBufPosn := 0;
   RBufStep := 0;
   RKeyLgth := BLgth;
   GetMem(IndxRBuf, RBufSize);
   CollPool^.Read(Page_No,IndxRBuf^, RBufSize);
end;

{------------------------------------------------------------------------------
                           Setup and Exit Routines
------------------------------------------------------------------------------}

{$F+}
procedure ExitHandler;
begin
   if CollPool <> nil then Dispose(CollPool, Done);
   ExitProc := ExitSave;
end;
{$F-}

begin
   ExitSave := ExitProc;
   ExitProc := @ExitHandler;
   ExactIndexMatch := false;
   CollPool := nil;
end.
{----------------------------------------------------------------------------}
                                      END
