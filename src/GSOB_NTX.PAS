unit GSOB_Ntx;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                            Clipper Index Handler

           GSOB_NTX (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved 

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       This unit handles the objects for all Clipper index (.NTX)
       operations.  This unit may be implemented by adding a
       conditional define to the complier options, see VDB_FLAG.INC
       for more!

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} {Os/2 & Dos Compiler flags!}

{$O+}

interface

uses
   USE32,
   GSOB_Var,
   GSOB_Dte,
   GSOB_Str,                          {String handler routines}
   GSOB_Inx,
   GSOB_Dsk,                          {File handler routines}
   GSOB_DBF,
   {$IFDEF WINDOWS}
      Objects;
   {$ELSE}
      GSOB_Obj;
   {$ENDIF}

const

   NdxBlokSize = 1024;


type

   GSP_InxHeader  = ^GSR_InxHeader;
   GSR_InxHeader  = Record
      Vers1,
      Vers2       : SmallInt;
      Root        : Longint;
      Unknwn1     : Longint;
      Entry_Sz    : SmallInt;
      Key_Lgth    : SmallInt;
      Key_Dcml    : SmallInt;
      Max_Keys    : SmallInt;
      Min_Keys    : SmallInt;
      Key_Form    : array [0..1001] of char;
   end;

   GSP_InxDataBlk  = ^GSR_InxDataBlk;
   GSR_InxDataBlk  = Record
      case SmallInt of
         0 : (Data_Ary    : array [0..NdxBlokSize] of byte);
         1 : (Indx_Ary    : array [0..NdxBlokSize div 2] of SmallWord);
         2 : (Entry_Ct    : SmallInt{Integer});
   end;

   GSP_InxElement = ^GSR_InxElement;
   GSR_InxElement = Record
      Block_Ax  : Longint;
      Recrd_Ax  : Longint;
      Char_Fld  : array [1..255] of char;
   end;

   GSP_IndexFile   = ^GSO_IndexFile;
   GSP_InxNode     = ^GSO_InxNode;

   GSP_InxTable = ^GSO_InxTable;
   GSO_InxTable = Object(TCollection)
      ixLink      : GSP_IndexFile;
      ActivePage  : GSP_InxNode;
      Elements    : array[0..NdxBlokSize div 12] of GSP_InxElement;
      OkToClear   : boolean;
      constructor Init(ILink : GSP_IndexFile);
      destructor  Done; virtual;
      function    AccessPage(pn : longint) : pointer;
      procedure   AdjustNodePntrs(pn : longint);
      function    FetchBttm : pointer;
      function    FetchCurr : pointer;
      function    FetchNext : pointer;
      function    FetchPrev : pointer;
      function    FetchTop  : pointer;
      procedure   NodeEntryDelete(en : Integer);
      procedure   NodeEntryInsert(en : Integer; wkey: string; wb, wr: longint);
      function    NodeGet(pn : longint) : pointer;
      procedure   NodePntrReplace(en : Integer; wkey: string; wb,wr: longint);
      function    NodePut(pn : longint) : pointer;
      procedure   ResetBuffers;
   end;

   GSO_InxNode = Object(TObject)
      tbLink      : GSP_InxTable;   {Link to collection owner}
      IndxBufr    : GSP_InxDataBlk;
      NodeLink    : Longint;
      Page_No     : Longint;   {Disk block holding node info}
      Etry_No     : Integer;   {Last entry used in node}
      Count       : Integer;   {Number of keys in this node }
      NonLeaf     : Boolean;   {True for non-leaf nodes}
      Changed     : boolean;
      constructor Init(CLink : GSP_InxTable; pn : longint);
      destructor  Done; virtual;
      procedure   Deliver;
      procedure   Retrieve;
   end;

   GSO_IndexFile   = object(GSO_DiskFile)
      ixColl       : GSP_IndxColl;
      ixKey_St     : ixKeyString;     {Holds last key value found}
      ixKey_Num    : longint;         {Holds last physical record number}
      IxKey_Form   : string[255];     {Holds the key formula in type string}
      ixKey_Siz    : Integer;
      ixKey_Typ    : char;
      ixBOF        : boolean;
      ixEOF        : boolean;
      ixFollowKey  : boolean;         {Flag to follow key for next read when}
                                      {the key is modified.  If false, the }
                                      {next record from the old key position }
                                      {is read.  If true, the next record from}
                                      {the new key position is read.  Default}
                                      {is false}
      tbLink       : GSP_InxTable;
      Ndx_Hdr      : GSR_InxHeader;
      Key_Lgth     : Integer;
      Max_Keys     : Integer;
      Entry_Sz     : Integer;
      CurrNode     : GSP_InxNode;
      CurrElmt     : GSP_InxElement;  {Pointer to key entry information}
      CacheBuf     : PByteArray;
      CacheBlok    : Word;

      Constructor Init(IName : string);
      Constructor NewInit(filname,formla: string; lth,dcl: Integer; typ: char);
      Destructor  Done; virtual;
      Procedure   IndxClear; virtual;
      Procedure   IndxStore(p : GSP_IndxColl; recnode : boolean); virtual;
      Function    KeyFind(st : String) : longint; virtual;
      Procedure   KeyList(st : string); virtual;
      Function    KeyLocRec(rec : longint) : boolean; virtual;
      Function    KeyRead(a : LongInt) : longint; virtual;
      Procedure   KeySort(kl : Integer; sa : SortStatus); virtual;
      Procedure   KeyUpdate(rec: longint; st: string; Apnd: boolean); virtual;
      Function    Ndx_AdjVal(st : string): string;
      Procedure   Ndx_Close;
      Procedure   Ndx_Flush;
      Procedure   Ndx_GetHdr;
      Function    Ndx_NextBlock : longint;
      Procedure   Ndx_PutHdr;
      Function    Ndx_Root : Longint;
      Procedure   WriteStatus(RNum : longint); virtual;
   end;

implementation


const

   Same_Record = -5;   {Token value passed to read the same record}

var Ndx_Data : GSR_InxDataBlk;

   Work_Key : string;               {Holds key passed in Find and KeyUpdate}
   RPag     : Longint;              {Work variable to hold current index block}
   RNum     : Longint;              {Work variable for record number}
   IsAscend : Boolean;              {Flag for ascending/descending status.}
                                    {Set based on Next/Previous Record read}

{------------------------------------------------------------------------------
                               GSO_InxTable
------------------------------------------------------------------------------}

constructor GSO_InxTable.Init(ILink : GSP_IndexFile);
var
   p  : pointer;
   i  : Integer;
begin
   TCollection.Init(32,16);
   for i := 0 to ILink^.Max_Keys do
      Elements[i] := Addr(Ndx_Data.Data_Ary[Ndx_Data.Indx_Ary[i+1]]);
   ixLink := ILink;
   OkToClear := true;
end;

destructor GSO_InxTable.Done;
var
   i : Integer;
begin
   TCollection.Done;
end;

function GSO_InxTable.AccessPage(pn : longint) : pointer;
var
   p  : GSP_InxNode;
   px : longint;
   i  : Integer;
   ok : boolean;
begin
   ok := false;
   i := 0;
   while (i < Count) and not ok do
   begin
      if GSP_InxNode(Items^[i])^.Page_No = pn then
      begin
         ok := true;
         p := Items^[i];
         AtDelete(i);
         Insert(p);
      end;
      inc(i);
   end;
   if not ok then
   begin
      if Count > 7 then Free(Items^[0]);
      p := New(GSP_InxNode, Init(@Self, pn));
      Insert(p);
   end;
   ActivePage := p;
   AccessPage := p;
end;

procedure GSO_InxTable.AdjustNodePntrs(pn : longint);
var
   p : GSP_InxNode;
   q : GSP_InxNode;
   e  : GSP_InxElement;
   i : Integer;
   v : Integer;
   x : longint;
begin
   p := AccessPage(pn);
   if not p^.NonLeaf then exit;
   for i := 0 to p^.Count-1 do
   begin
      e := Elements[i];
      x := e^.Block_Ax;
      for v := 0 to Count -1 do
      begin
         q := Items^[v];
         if q^.Page_No = x then q^.NodeLink := pn;
      end;
   end;
end;

function GSO_InxTable.FetchBttm : pointer;
var
   n  : longint;
   p  : GSP_InxNode;
   e  : GSP_InxElement;
begin
   p := NodeGet(ixLink^.Ndx_Root);
   if p^.Count > 0 then e := Elements[p^.Count-1] else e := nil;
   while p^.NonLeaf and (p^.Count > 0) do
   begin
      n := p^.Page_No;
      p^.Etry_No := p^.Count;
      if p^.Count > 0 then dec(p^.Etry_No);
      p := NodeGet(e^.Block_Ax);
      p^.NodeLink := n;
      if p^.Count > 0 then e := Elements[p^.Count-1] else e := nil;
   end;
   p^.Etry_No := p^.Count;
   if p^.Count > 0 then dec(p^.Etry_No);
   FetchBttm := e;
end;

function GSO_InxTable.FetchCurr : pointer;
begin
   FetchCurr := Elements[ActivePage^.Etry_No];
end;

function GSO_InxTable.FetchNext : pointer;
var
   p  : GSP_InxNode;
   h  : GSP_InxNode;
   e  : GSP_InxElement;
   n  : longint;
   t  : boolean;
begin
   p := ActivePage;
   p^.Retrieve;
   h := p;
   t := p^.NonLeaf;
   inc(p^.Etry_No);
   while (p^.Etry_No >= p^.Count) and (p^.NodeLink <> -1) do
   begin
      Delete(p);
      AtInsert(0,p);
      p := NodeGet(p^.NodeLink);
      if t or (p^.Etry_No = p^.Count-1) then inc(p^.Etry_No);
   end;
   if (p^.Etry_No >= p^.Count) and (p^.Page_No = ixLink^.Ndx_Root) then
      begin
         FetchNext := nil;
         dec(p^.Etry_No);
      end
         else if not t then
               FetchNext := Elements[p^.Etry_No]
            else
            begin
               e := Elements[p^.Etry_No];
               while p^.NonLeaf do
               begin
                  n := p^.Page_No;
                  p := NodeGet(e^.Block_Ax);
                  p^.NodeLink := n;
                  p^.Etry_No := 0;
                  if p^. Count > 0 then e := Elements[0] else e := nil;
               end;
               FetchNext := e;
            end;
end;

function GSO_InxTable.FetchPrev : pointer;
var
   p  : GSP_InxNode;
   h  : GSP_InxNode;
   e  : GSP_InxElement;
   n  : longint;
   t  : boolean;
begin
   p := ActivePage;
   p^.Retrieve;
   h := p;
   t := p^.NonLeaf;
   if not t then dec(p^.Etry_No);
   while (p^.Etry_No < 0) and (p^.NodeLink <> -1) do
   begin
      Delete(p);
      AtInsert(0,p);
      p := NodeGet(p^.NodeLink);
      dec(p^.Etry_No);
   end;
   if (p^.Etry_No < 0) and (p^.Page_No = ixLink^.Ndx_Root) then
   begin
      FetchPrev := nil;
      inc(p^.Etry_No);
      while p^.NonLeaf do
      begin
         e := Elements[p^.Etry_No];
         p := NodeGet(e^.Block_Ax);
         inc(p^.Etry_No);
      end;
   end
      else if not t then FetchPrev := Elements[p^.Etry_No]
         else
         begin
            e := Elements[p^.Etry_No];
            while p^.NonLeaf and (p^.Count > 0) do
            begin
               n := p^.Page_No;
               p := NodeGet(e^.Block_Ax);
               p^.NodeLink := n;
               p^.Etry_No := p^.Count-1;
               if p^. Count > 0 then e := Elements[p^.Count-1] else e := nil;
            end;
            FetchPrev := e;
         end;
end;

function GSO_InxTable.FetchTop : pointer;
var
   p  : GSP_InxNode;
   e  : GSP_InxElement;
   n  : longint;
begin
   p := NodeGet(ixLink^.Ndx_Root);
   if p^.Count > 0 then e := Elements[0] else e := nil;
   while p^.NonLeaf and (p^.Count > 0) do
   begin
      n := p^.Page_No;
      p^.Etry_No := 0;
      p := NodeGet(e^.Block_Ax);
      p^.NodeLink := n;
      if p^.Count <= 0 then e := nil;
   end;
   p^.Etry_No := 0;
   FetchTop := e;
end;

procedure GSO_InxTable.NodeEntryDelete(en : Integer);
var
   p  : GSP_InxNode;
begin
   p := ActivePage;
   Move(Elements[en+1]^,Elements[en]^,ixLink^.Entry_Sz*(p^.Count-en));
   dec(Ndx_Data.Entry_Ct);
   p^.Deliver;
end;

procedure GSO_InxTable.NodeEntryInsert
                                (en : Integer; wkey: string; wb,wr: longint);
var
   p  : GSP_InxNode;
   e  : GSP_InxElement;
begin
   p := ActivePage;
   e := Elements[en];
   Move(Elements[en]^,Elements[en+1]^,ixLink^.Entry_Sz*(p^.Count-en));
   move(wkey[1],e^.Char_Fld,ixLink^.Key_Lgth);
   e^.Block_Ax := wb;
   e^.Recrd_Ax := wr;
   inc(Ndx_Data.Entry_Ct);
   p^.Deliver;
end;

function GSO_InxTable.NodeGet(pn : longint) : pointer;
var
   p  : GSP_InxNode;
begin
   p := AccessPage(pn);
   p^.Retrieve;
   NodeGet := p;
end;

procedure GSO_InxTable.NodePntrReplace
                                (en : Integer; wkey: string; wb,wr: longint);
var
   p  : GSP_InxNode;
   q  : GSP_InxNode;
   e  : GSP_InxElement;
begin
   p := ActivePage;
   q := p;
   p := NodeGet(p^.NodeLink);
   while (p^.Etry_No >= p^.Count-1) and (p^.NodeLink <> -1) do
      p := NodeGet(p^.NodeLink);
   if p^.NodeLink <> -1 then
   begin
      e := Elements[p^.Etry_No];
      FillChar(e^.Char_Fld, ixLink^.Key_Lgth, ' ');
      move(wkey[1],e^.Char_Fld,length(wkey));
      e^.Block_Ax := wb;
      e^.Recrd_Ax := wr;
      p^.Deliver;
   end;
   ActivePage := q;
   ActivePage^.Retrieve;
end;

function GSO_InxTable.NodePut(pn : longint) : pointer;
var
   p  : GSP_InxNode;
begin
   p := AccessPage(pn);
   p^.Deliver;
   NodePut := p;
end;

procedure GSO_InxTable.ResetBuffers;
begin
   if OkToClear then FreeAll;
end;

{------------------------------------------------------------------------------
                               GSO_InxNode
------------------------------------------------------------------------------}

constructor GSO_InxNode.Init(CLink : GSP_InxTable; pn : longint);
var
   i : Integer;
   r : Word;
begin
   IndxBufr := nil;
   Page_No := pn;
   Etry_No := -1;
   Count := 0;
   NonLeaf := true;
   tbLink := CLink;
   NodeLink := -1;
   Changed := false;
end;

destructor GSO_InxNode.Done;
var
   r : Word;
begin
   if IndxBufr <> nil then dispose(IndxBufr);
   TObject.Done;
end;

procedure GSO_InxNode.Deliver;
var
   v : longint;
begin
   Count := Ndx_Data.Entry_Ct;
   move(Ndx_Data.Data_Ary[(Count *  tbLink^.ixLink^.Entry_Sz)],v,4);
   NonLeaf := v <> 0;
   if NonLeaf then Count := Count + 1;
   if IndxBufr = nil then New(IndxBufr);
   move(Ndx_Data,IndxBufr^,NdxBlokSize);
   tbLink^.ixLink^.Write(Page_No,IndxBufr^,NdxBlokSize);
end;

procedure GSO_InxNode.Retrieve;
var v : longint;
begin
   if IndxBufr = nil then
   begin
      New(IndxBufr);
      tbLink^.ixLink^.Read(Page_No,IndxBufr^,NdxBlokSize);
   end;
   move(IndxBufr^,Ndx_Data,NdxBlokSize);
   Count := Ndx_Data.Entry_Ct;
   move(Ndx_Data.Data_Ary[Ndx_Data.Indx_Ary[1]],v,4);
   NonLeaf := v <> 0;
   if nonLeaf then Count := Count + 1;
end;

{-----------------------------------------------------------------------------
                                 GSO_IndexFile
------------------------------------------------------------------------------}

constructor GSO_IndexFile.Init(IName : string);
var
   i : Integer;
begin
   GSO_DiskFile.Init(IName+'.NTX',dfReadWrite+dfSharedDenyNone);
   dfFileFlsh := WriteFlush;
   if dfFileExst then Reset(1)
      else
      begin
         Error(dosFileNotFound,ndxInitError);
         exit;
      end;
   Read(0,Ndx_Hdr,NdxBlokSize);
   Key_Lgth := Ndx_Hdr.Key_Lgth;
   Max_Keys := Ndx_Hdr.Max_Keys;
   Entry_Sz := Ndx_Hdr.Entry_Sz;
   move(Ndx_Hdr.Key_Form[0], ixKey_Form[1],241);
   ixKey_Form[0] := #241;
   ixKey_Form[0] := chr(pos(#0,ixKey_Form)-1);
   ixKey_Form := TrimR(ixKey_Form);
   ixKey_Form := TrimL(ixKey_Form);
   ixKey_Siz := Key_Lgth;
   ixBOF := false;
   ixEOF := false;
   ixKey_St := '';
   ixKey_Num := 0;
   ixFollowKey := false;
   Read(Ndx_Root,Ndx_Data,NdxBlokSize);
   tbLink := New(GSP_InxTable, Init(@Self));
end;

Constructor GSO_IndexFile.NewInit(filname,formla : string; lth,dcl: Integer;
                                  typ : char);
var
   i : Integer;
begin
   GSO_DiskFile.Init(filname+'.NTX',dfReadWrite);
   dfFileFlsh := WriteFlush;
   Rewrite(1);
   FillChar(Ndx_Hdr, SizeOf(Ndx_Hdr),#0);
   Ndx_Hdr.Root := NdxBlokSize;
   Ndx_Hdr.Vers1 := 6;
   Ndx_Hdr.Vers2 := 1;
   lth := lth+dcl;
   if dcl > 0 then inc(lth);  {account for decimal point}
   Ndx_Hdr.Key_Lgth := lth;
   Ndx_Hdr.Key_Dcml := dcl;
   i := lth+8;
   Ndx_Hdr.Max_Keys := ((NdxBlokSize-4) div (i+2)) - 1;
   if odd(Ndx_Hdr.Max_Keys) then dec(Ndx_Hdr.Max_Keys);
   Ndx_Hdr.Min_Keys := Ndx_Hdr.Max_Keys div 2;
   Ndx_Hdr.Entry_Sz := i;
   CnvStrToAsc(formla,Ndx_Hdr.Key_Form, length(formla)+1);
   Write(0,Ndx_Hdr,NdxBlokSize);
   Key_Lgth := lth;
   Max_Keys := Ndx_Hdr.Max_Keys;
   Entry_Sz := Ndx_Hdr.Entry_Sz;
   ixKey_Form := formla;
   ixKey_Form := TrimR(ixKey_Form);
   ixKey_Form := TrimL(ixKey_Form);
   ixKey_Siz := Key_Lgth;
   ixKey_Typ := typ;
   ixBOF := false;
   ixEOF := false;
   ixKey_St := '';
   ixKey_Num := 0;
   ixFollowKey := false;
   FillChar(Ndx_Data, SizeOf(Ndx_Data),#0);
   for i := 0 to Ndx_Hdr.Max_Keys do Ndx_Data.Indx_Ary[succ(i)] :=
                     ((Ndx_Hdr.Max_Keys + 2) * 2) + (Ndx_Hdr.Entry_Sz * i);
   Write(-1,Ndx_Data,NdxBlokSize);
   tbLink := New(GSP_InxTable, Init(@Self));
end;

Destructor GSO_IndexFile.Done;
var
   i : Integer;
begin
   Ndx_Close;
   GSO_DiskFile.Done;
end;

Procedure GSO_IndexFile.IndxClear;
var
   i : Integer;
begin
   Ndx_Flush;
   Ndx_GetHdr;
   Ndx_Hdr.Root := 1;
   Write(0,Ndx_Hdr,NdxBlokSize);
   ixBOF := false;
   ixEOF := false;
   ixKey_St := '';
   ixKey_Num := 0;
   FillChar(Ndx_Data, SizeOf(Ndx_Data),#0);
   Write(-1,Ndx_Data,NdxBlokSize);
   Truncate(-1);
end;

Procedure GSO_IndexFile.IndxStore(p: GSP_IndxColl; recnode: boolean);
var
   i         : Integer;
   rc        : Integer;
   rl        : Word;
   dt        : longint;
   ec        : longint;
   kc        : Integer;
   mh        : Integer;
   mk        : Integer;
   mm        : Integer;
   mr        : Integer;
   mv        : Integer;
   rf        : GSP_IndxEtry;
   rr        : GSP_IndxEtry;
   sc        : Integer;
   sv        : string[104];
   dl        : Integer;
   ixFiller  : array[0..NdxBlokSize+108] of byte;
   ixData    : GSR_InxDataBlk absolute ixFiller;
   ixPntr    : GSP_InxElement;
   ixBlok    : longint;
   NodeColl  : GSP_IndxColl;

   procedure CacheWrite;
   begin
      move(ixData,CacheBuf^[CacheBlok],NdxBlokSize);
      CacheBlok := CacheBlok+NdxBlokSize;
      if CacheBlok >= NdxBlokSize*16 then
      begin
         Write(-1,CacheBuf^,CacheBlok);
         CacheBlok := 0;
      end;
   end;

   procedure CollectNodes;
   begin
      ixData.Entry_Ct := rc-1;
      CacheWrite;
      if recnode then
      begin
         move(rr^.Tag,sv[Key_Lgth+1],4);  {Hang on to Record number}
         sv[0] := chr(Key_Lgth+4);
      end;
      NodeColl^.InsertKey(ixBlok, sv);
      rc := 0;
      inc(ixBlok,NdxBlokSize);
      mk := mv;
      if mm > 0 then
      begin
         inc(mk);
         dec(mm);
      end;
   end;

begin
   mk := Max_Keys;
   if recnode then mr := 1 else mr := 0;
   kc := p^.KeyCount;
   if kc <= mk then
   begin
      mk := kc+1;
      mv := mk;
      mm := 0;
   end
   else
   begin
      i := kc;
      mv := 0;
      repeat
         mh := mv;
         mv := i div mk;
         inc(mv);
         i := (kc - mv) + mr;
      until mh = mv;
      mm := i mod mv;
      mk := i div mv;
      inc(mk);               {to keep things balanced on leaf nodes}
      mv := mk;
      if mm > 0 then
      begin
         inc(mk);
         dec(mm);
      end;
   end;
   if recnode then
   begin
      ixBlok := NdxBlokSize;
      GetMem(CacheBuf,NdxBlokSize*16);
      Read(0,CacheBuf^,NdxBlokSize);    {Position to initial loc}
   end
   else
   begin
      ixBlok := Ndx_NextBlock;
   end;
   CacheBlok := 0;
   New(NodeColl, Init(Key_Lgth+4,NoSort));
   rr := p^.RetrieveKey;
   rc := 0;
   ec := 0;
   FillChar(ixData, SizeOf(ixData),#0);
   dl := (Max_Keys + 2) * 2;
   for i := 0 to Max_Keys do ixData.Indx_Ary[i+1] := (dl + (Entry_Sz * i));
   while rr <> nil do
   begin
      rf := rr;
      ixPntr :=  Addr(ixData.Data_Ary[ixData.Indx_Ary[rc+1]]);
      sv := rr^.KeyStr;
      if (ixKey_Typ = 'N') and recnode then
      begin
         sv := PadL(sv, Key_Lgth);
         for sc := 1 to length(sv) do
              if sv[sc] = ' ' then sv[sc] := '0';
      end;
      move(sv[1],IxPntr^.Char_Fld[1],Key_Lgth);
      if recnode then
      begin
         IxPntr^.Recrd_Ax := rr^.Tag;
         IxPntr^.Block_Ax := 0;
      end
      else
      begin
         move(rr^.KeyStr[Key_Lgth+1],IxPntr^.Recrd_Ax,4); {Load Record number}
         IxPntr^.Block_Ax := rr^.Tag;
      end;
      inc(rc);
      inc(ec);
      WriteStatus(ec);
      if rc >= mk then CollectNodes;
      rr := p^.RetrieveKey;
   end;
   if rc > 0 then
   begin
      rr := rf;
      if recnode then inc(rc);
      CollectNodes;
   end;
   p^.EndRetrieve;
   if CacheBlok > 0 then Write(-1,CacheBuf^,CacheBlok);
   if ec > Max_Keys then IndxStore(NodeColl, false);
   Dispose(NodeColl, Done);
   if recnode then
   begin
      FreeMem(CacheBuf,NdxBlokSize*16);
      Dispose(ixColl, Done);
      Ndx_Hdr.Root := Ndx_NextBlock-NdxBlokSize;
      Ndx_Flush;
   end;
end;


Function GSO_IndexFile.KeyFind(st : string) : LongInt;
var
   i         : Integer;               {Work variable}
   rl        : Integer;               {Result code for Val procedure}
   ct        : Integer;               {Variable to hold BlockRead byte count}
   IsEqual   : boolean;               {Flag to hunt for key match}
   PNode     : longint;
   Match_Cnd : Integer;
   LeafPag   : longint;
   LeafEtry  : Integer;


   procedure StoreMatchValue;
   begin
      move(CurrElmt^.Char_Fld,ixKey_St[1],Key_Lgth);
                                      {Move the key field to Ndx_Key_St.}
      ixKey_St[0] := Work_Key[0];   {Now insert the length into Ndx_Key_St}
   end;

   function DoMatchValue : Integer;
   begin
      Match_Cnd := StrCompare(ixKey_St, Work_Key);
      DoMatchValue := Match_Cnd;
   end;

   function SearchMatchValue(var Index: Integer): Boolean;
   var
      L,
      H,
      I,
      C: Integer;
   begin
      SearchMatchValue := False;
      L := 0;
      H := CurrNode^.Count - 1;
      while L <= H do
      begin
         I := (L + H) shr 1;
         CurrElmt := tbLink^.Elements[I];
         if (CurrNode^.NonLeaf) and (CurrNode^.Count-1 = I) then
            C := 1
         else
         begin
            StoreMatchValue;
            C := DoMatchValue;
         end;
         if C < 0 then L := I + 1 else
         begin
            H := I - 1;
            if C = 0 then SearchMatchValue := true;
         end;
      end;
      CurrElmt := tbLink^.Elements[L];
      StoreMatchValue;
      Index := L;
   end;

begin
{   tbLink^.ResetBuffers;}
   ixKey_Num := 0;                    {Initialize}
   ixKey_St := '';                    {Initialize}
   Work_Key := Ndx_AdjVal(st);        {Set key comparison value}
   RPag := Ndx_Root;                  {Get root node address}
   PNode := -1;
   ixEOF := true;
   LeafPag := -1;
   while RPag <> 0 do                 {While a non-leaf node, do this}
   begin
      CurrNode := tbLink^.NodeGet(RPag);
      CurrNode^.NodeLink := PNode;
      IsEqual := SearchMatchValue(i);
      if IsEqual then
      begin
         LeafPag := RPag;
         LeafEtry := i;
      end;
      CurrNode^.Etry_No := i;
      ixEOF := ixEOF and (i >= Ndx_Data.Entry_Ct);
      CurrElmt := tbLink^.Elements[i];
      PNode := RPag;
      RPag := CurrElmt^.Block_Ax;
   end;
   if IsEqual then
      ixKey_Num := CurrElmt^.Recrd_Ax
      else
         if LeafPag > 0 then
         begin
            CurrNode := tbLink^.NodeGet(LeafPag);
            CurrNode^.Etry_No := LeafEtry;
            CurrElmt := tbLink^.Elements[LeafEtry];
            ixKey_Num := CurrElmt^.Recrd_Ax
         end
         else
            ixKey_Num := 0;
   KeyFind := ixKey_Num;              {Return with the record number}
end;

Procedure GSO_IndexFile.KeyList(st : string);
var
   ofil      : text;
   RPag      : LongInt;
   i,j,k,v   : Integer;
   rl        : Integer;
   ct        : Integer;
   recnode,
   Less_Than : boolean;
   WorkNode  : GSP_InxNode;
   Next_Blk  : Longint;
begin
   Next_Blk := Ndx_NextBlock;
   System.assign(ofil, st);
   System.ReWrite(ofil);
   writeln(ofil,'--------------------------------------------------');
   writeln(ofil,'File Name = ',dfFileName);
   writeln(ofil,'Key Expression = ',ixKey_Form);
   writeln(ofil,'Key Length = ',Key_Lgth,
                '   Maximum Keys/Block = ',Max_Keys);
   writeln(ofil,'Root =',Ndx_Root:5);
   tbLink^.FreeAll;
   WorkNode := tbLink^.FetchTop;
   writeln(ofil,'Data records are at Level ',tbLink^.Count,
                ' in the hierarchy.');
   RPag := NdxBlokSize;
   while RPag <> Next_Blk do
   begin
      WorkNode := tbLink^.NodeGet(RPag);
      System.write(ofil,RPag:2,'  [',Ndx_Data.Entry_Ct:2,']');
      CurrElmt :=  tbLink^.Elements[0];
      recnode := not WorkNode^.nonLeaf;
      k := WorkNode^.Count;
      v := 1;
      i := 1;
      while (i <= k) do
      begin
         CurrElmt :=  tbLink^.Elements[i-1];
         with CurrElmt^ do
         begin
            System.write(ofil,'':v,Block_Ax:5);
            v := 9;
            if (i = k) and not recnode then System.write(ofil,'    0 - empty')
            else
               begin
                  System.write(ofil,Recrd_Ax:5,' ');
                  for j := 1 to Key_Lgth do
                        System.write(ofil,Char_Fld[j]);
               end;
         WRITELN(OFIL);
         end;
         inc(i);
      end;
      writeln(ofil);
      inc(RPag,NdxBlokSize);
      tbLink^.FreeAll;
   end;
   Ndx_Flush;
   System.Close(ofil);
end;


Function GSO_IndexFile.KeyLocRec (rec : longint) : boolean;
var
   lr : longint;
begin
   if rec = ixKey_Num then
   begin                              {Exit if already at the record}
      KeyLocRec := true;
      exit;
   end;
   tbLink^.ResetBuffers;
   lr := KeyRead(Top_Record);
   while (not ixEOF) and (lr <> rec) do lr := KeyRead(Next_Record);
   if (ixEOF) then KeyLocRec := false
      else KeyLocRec := true;
end;


FUNCTION  GSO_IndexFile.KeyRead(a : longint) : longint;
var
   elem : GSP_InxElement;
   h_str : ixKeyString;
   h_num : longint;
begin
   RNum := a;
   if ((a = Next_Record) or (a = Prev_Record)) and
      (ixKey_Num = 0) then RNum := Top_Record;
                                      {if first time through, use Top_Record}
                                      {command instead}
   if ((RNum = Next_Record) or (RNum = Prev_Record)) and (RNum = 0) then
   begin
      h_str := ixKey_St;
      h_num := ixKey_Num;
      ixKey_Num := KeyFind(h_str);
      if ixKey_Num <> 0 then
      begin
         while (ixKey_Num < h_num) and (ixKey_St = h_str) do
         begin
            elem := tbLink^.FetchNext;
            if elem <> nil then
            begin
               move(elem^.Char_Fld,ixKey_St[1],Key_Lgth);
               ixKey_St[0] := chr(Key_Lgth);
               ixKey_Num := elem^.Recrd_Ax;
            end
               else h_num := 0;
         end;
      end
      else
      begin
         if ixEOF then
         begin
            elem := tbLink^.FetchPrev;
            if elem <> nil then
            begin
               move(elem^.Char_Fld,ixKey_St[1],Key_Lgth);
               ixKey_St[0] := chr(Key_Lgth);
               ixKey_Num := elem^.Recrd_Ax;
            end;
            ixEOF := false;
         end;
      end;
      if ixKey_Num <> h_num then RNum := Same_Record;
   end;
   ixBOF := false;
   ixEOF := false;                   {End-of-File initially set false}
   case RNum of                       {Select KeyRead Action}

      Next_Record : begin
                       elem := tbLink^.FetchNext;
                       if elem = nil then ixEOF := true;
                    end;

      Prev_Record : begin
                       elem := tbLink^.FetchPrev;
                       if elem = nil then ixBOF := true;
                    end;

      Top_Record  : begin
                       elem := tbLink^.FetchTop;
                       if elem = nil then ixEOF := true;
                    end;


      Bttm_Record : begin
                       elem := tbLink^.FetchBttm;
                       if elem = nil then ixBOF := true;
                    end;

      Same_Record : elem := tbLink^.FetchCurr;

      else          elem := nil;      {if no valid action, return zero}
   end;
   CurrNode := tbLink^.ActivePage;
   if elem <> nil then
   begin
      RNum := elem^.Recrd_Ax;
      move(elem^.Char_Fld,ixKey_St[1],Key_Lgth);
      ixKey_St[0] := chr(Key_Lgth);
      ixKey_Num := RNum;
      CurrElmt := elem;
   end
   else
   begin
      RNum := 0;
      CurrElmt := tbLink^.Elements[CurrNode^.Count];
   end;
   KeyRead := RNum;                   {Return RNum}
end;

Procedure GSO_IndexFile.KeySort(kl : Integer; sa : SortStatus);
begin
   ixColl := New(GSP_IndxColl, Init(Key_Lgth, sa));
end;

Procedure GSO_IndexFile.KeyUpdate(rec : longint; st : string; Apnd : boolean);
var
   em_hold : boolean;                 {holds ExactMatch flag during this}
   old_key : ixKeyString;
   old_num : longint;
   shrrsl  : Word;

{
   This routine deletes the current entry by overlaying the remaining entries
   over the entry location, and then decrementing the entry count
}
   Procedure DeleteEntry;
   begin
      tbLink^.NodeEntryDelete(CurrNode^.Etry_No);
   end;

{  This routine inserts an entry by making room in the current data array
   and inserting the new entry.  The entry count is then incremented.
}
   Procedure InsertEntry(var wk : ixKeyString; wb,wr : longint);
   begin
      tbLink^.NodeEntryInsert(CurrNode^.Etry_No,wk,wb,wr);
   end;

{  This routine searches back through the nodes to replace the key value in
   the non-leaf node.
}
   procedure ReplacePointerEntry(var wk : ixKeyString; wb,wr : longint);
   begin
      tbLink^.NodePntrReplace(CurrNode^.Etry_No,wk,wb,wr);
      CurrNode := tbLink^.ActivePage;
   end;

{  This routine is used to delete all references to a record key.  It will
   delete the key from the leaf node, and then search the non-leaf node and
   replace the pointer if it was the last entry in the non-leaf node.
}
   Procedure KeyDelete;
   var
      InLeaf : boolean;
      TheBlk : longint;
      TheStr : ixKeyString;
      TheRec : longint;
      DumRec : longint;
   begin
      InLeaf := not CurrNode^.NonLeaf;
      TheBlk := CurrElmt^.Block_Ax;
      if not InLeaf then
      begin
         TheRec := KeyRead(Prev_Record);
         move(CurrElmt^.Char_Fld,TheStr[1],Key_Lgth);
         TheStr[0] := chr(Key_Lgth);
         DumRec := KeyRead(Next_Record);
         ReplacePointerEntry(TheStr,TheBlk,TheRec);
         TheRec := KeyRead(Prev_Record);
      end;
      DeleteEntry;                    {delete the key from this node.}
      if (CurrNode^.Count = 0) and (CurrNode^.NodeLink <> -1) then
      begin                           {if empty, delete nonleaf pointer}
         CurrNode := tbLink^.NodeGet(CurrNode^.NodeLink);
         KeyDelete;
         exit;
      end;
      if inLeaf and (CurrNode^.Etry_No >= CurrNode^.Count) and
        (CurrNode^.NodeLink <> -1) then
      begin
         CurrElmt := tblink^.Elements[tbLink^.Count-1];
         move(CurrElmt^.Char_Fld,ixKey_St[1],Key_Lgth);
         ixKey_St[0] := chr(length(Work_Key));
         ReplacePointerEntry(ixKey_St,CurrElmt^.Block_Ax,CurrElmt^.Recrd_Ax);
      end;
   end;

{  This routine will divide a block into two equal blocks and then store the
   index levels (n1 and n2), entry counts (e1 and e2), and block numbers
   (b1 and b2) for later node pointer updates.  The new key (from the middle
   of the block's entries) will be saved in s1.
}
   Procedure SplitBlock(var p1,p2 : GSP_InxNode; var e : GSP_InxElement);
   var
      b1   : longint;
      e1   : Integer;
      e2   : Integer;
      en   : Integer;
      wp   : longint;

   begin
      en := CurrNode^.Etry_No;
      wp := CurrNode^.Page_No;
      b1 := Ndx_NextBlock;                {Get the next available block.}
      e1 := (CurrNode^.Count) div 2;      {Number of entries in first half.}
      e2 := ((CurrNode^.Count) - e1);     {Number of entries in second half.}
      Ndx_Data.Entry_Ct := e1;
      dec(Ndx_Data.Entry_Ct);
      p1 := tbLink^.NodePut(b1);          {Save the block.}
      p1^.Etry_No := -1;
      p1^.NodeLink := CurrNode^.NodeLink;
      move(tbLink^.Elements[e1-1]^,e^,Entry_Sz);
      tbLink^.AdjustNodePntrs(b1);
      Ndx_Data.Entry_Ct := e2;
      if CurrNode^.NonLeaf then dec(Ndx_Data.Entry_Ct);
      move(tbLink^.Elements[e1]^,Ndx_Data.Data_Ary[Ndx_Data.Indx_Ary[1]],
           Entry_Sz*(e2+1));
                                          {Shift second half to beginning of}
                                          {the buffer array.}
      p2 := tbLink^.NodePut(wp);         {Save the block}
      p2^.Etry_No := -1;
      if en <= e1 then
      begin
         p1^.Etry_No := en;
         CurrNode := p1;
      end
      else
      begin
         p2^.Etry_No := en-e1;
         CurrNode := p2;
      end;
      Ndx_PutHdr;                  {Store from header info area}
      CurrNode := tbLink^.NodeGet(CurrNode^.Page_No);
      CurrElmt := tbLink^.Elements[CurrNode^.Etry_No];
   end;


{  This routine is used to create a new root node when the split block
   pointers will not fit in the current root node.
}
   Procedure MakeRootNode(wb,wr : longint);
   var i : Integer;
   begin
      Ndx_Hdr.Root := Ndx_NextBlock;  {Set root pointer to this block.}
      Ndx_PutHdr;                     {Write updated header block.}
      FillChar(Ndx_Data, SizeOf(Ndx_Data),#0);
      for i := 0 to Ndx_Hdr.Max_Keys do Ndx_Data.Indx_Ary[succ(i)] :=
                    ((Ndx_Hdr.Max_Keys + 2) * 2) + (Ndx_Hdr.Entry_Sz * i);
      CurrElmt := tbLink^.Elements[0];
      CurrElmt^.Block_Ax := wb;
      CurrElmt^.Recrd_Ax := wr;
      CurrNode := tbLink^.NodePut(Ndx_Root);
      CurrNode^.Etry_No := 0;
   end;

{  This routine will split the current node, create a new root node if needed,
   and then insert the newly created block in the proper sequence in the node.
}
   procedure ExpandIndex;
   var
      e    : GSP_InxElement;
      p1   : GSP_InxNode;
      p2   : GSP_InxNode;
      pl   : longint;
      s    : ixKeyString;
   begin
      GetMem(e,Entry_Sz);
      SplitBlock(p1,p2,e);
      pl := CurrNode^.Page_No;
      if CurrNode^.NodeLink = -1 then
      begin
         MakeRootNode(p2^.Page_No,0);
         p1^.NodeLink := Ndx_Root;
         p2^.NodeLink := p1^.NodeLink;
      end
         else CurrNode := tbLink^.NodeGet(CurrNode^.NodeLink);
      if Ndx_Data.Entry_Ct >= Max_Keys then ExpandIndex;
      CurrElmt := tbLink^.Elements[p1^.Count-1];
      move(e^.Char_Fld,s[1],Key_Lgth);
      s[0] := chr(Key_Lgth);         {Save the last key entry in the block.}
      InsertEntry(s,p1^.Page_No,e^.Recrd_Ax);
      CurrNode := tbLink^.NodeGet(pl);
      CurrElmt := tBlink^.Elements[CurrNode^.Etry_No];
      FreeMem(e,Entry_Sz);
   end;

{  Routine to find the record that is just after the record key.  This is
   necessary to ensure a new duplicate key is properly inserted after any
   existing matching keys.
}
   Procedure FindLastKey;
   var
      nu_key : longint;
   begin
      nu_key := KeyFind(st);          {Find a matching key.}
      if nu_key <> 0 then             {If there is a match, continue looking}
      begin
         while (ixKey_St = Work_Key) and (not ixEOF) do
            nu_key := KeyRead(Next_Record);
         if CurrNode^.NonLeaf then nu_key := KeyRead(Prev_Record);
      end;
   end;

{  This routine will insert the new key into the index.  It will search for
   matching keys and insert the new key after any existing matches.  It will
   then check to see if the node is filled, and split the block if necessary.
}
   Procedure KeyInsert;
   begin
      FindLastKey;
      tbLink^.OkToClear := false;
      if Ndx_Data.Entry_Ct >= Max_Keys then  {overflow condition?}
      begin
         ExpandIndex;
         FindLastKey;
      end;
      if ixEOF then
      begin
         while CurrNode^.NonLeaf do
         begin
            CurrNode^.Etry_No := CurrNode^.Count-1;
            CurrElmt := tbLink^.Elements[CurrNode^.Etry_No];
            CurrNode := tbLink^.NodeGet(CurrElmt^.Block_Ax);
         end;
         CurrNode^.Etry_No := CurrNode^.Count;
      end;
      ixKey_St := PadR(Work_Key,Key_Lgth);
      ixKey_Num := rec;
      InsertEntry(ixKey_St,0,rec);
      if (CurrNode^.Etry_No = CurrNode^.Count-1) and
         (CurrNode^.Page_No <> Ndx_Root) then          {last entry in node?}
         ReplacePointerEntry(ixKey_St,CurrNode^.Page_No,0);
      tbLink^.OkToClear := true;
      if not ixFollowKey then
      begin
         ixKey_St := old_key;
         ixKey_Num := old_num;
      end;
      tbLink^.ResetBuffers;
   end;

begin
   old_key := ixKey_St;
   old_num := ixKey_Num;
   Work_Key := Ndx_AdjVal(st);        {Set key comparison value}
   if dfFileShrd then shrrsl := LockRec(0,NdxBlokSize);
   if not Apnd then                   {Tests for Append vs Update}
   begin
      if KeyLocRec(rec) then
      begin
         if Work_Key = ixKey_St then
         begin
            if dfFileShrd then
               shrrsl := UnLock;
            exit;
         end;
         KeyDelete;
      end;
   end;
   em_hold := dbExactMatch;
   dbExactMatch := true;
   KeyInsert;
   if dfFileShrd then shrrsl := UnLock;
   dbExactMatch := em_hold;
end;



function GSO_IndexFile.Ndx_AdjVal(st : string): string;
var
   Work_Key : string;
   dt       : longint;
   rl       : Word;
begin
   if (ixKey_Typ = 'N') then
   begin
      Work_Key := PadL(st, Key_Lgth);
      for rl := 1 to length(Work_Key) do
              if Work_Key[rl] = ' ' then Work_Key[rl] := '0';
   end
   else Work_Key := st;
   Ndx_AdjVal := Work_Key;
end;

Procedure GSO_IndexFile.Ndx_Close;
begin
   Ndx_Flush;
   Dispose(tbLink, Done);
   Close;
end;

Procedure GSO_IndexFile.Ndx_Flush;
begin
   Ndx_PutHdr;
   tbLink^.FreeAll;
   ixKey_St := '';
   ixKey_Num := 0;
end;

Procedure GSO_IndexFile.Ndx_GetHdr;
begin
   Read(0,Ndx_Hdr,NdxBlokSize);
end;

Function GSO_IndexFile.Ndx_NextBlock : longint;
var
   rl : Word;
begin
   Ndx_NextBlock := FileSize;
end;

Procedure GSO_IndexFile.Ndx_PutHdr;
begin
   Write(0,Ndx_Hdr,NdxBlokSize);
end;

Function GSO_IndexFile.Ndx_Root : Longint;
begin
   if dfFileShrd then Ndx_GetHdr;
   Ndx_Root := Ndx_Hdr.Root;
end;

Procedure GSO_IndexFile.WriteStatus(RNum : longint);
begin
end;

end.
{-----------------------------------------------------------------------------}
                                      END


