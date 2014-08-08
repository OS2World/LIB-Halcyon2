unit GSOB_Ndx;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                            dBase III Index Handler

           GSOB_NDX (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved 

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       This unit handles the objects for all dBase III index (.NDX)
       operations.

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

interface

uses
   Use32,
   GSOB_Var,
   GSOB_Dte,
   GSOB_Str,                          {String handler routines}
   GSOB_Inx,
   GSOB_Dsk,                          {File handler routines}
   GSOB_DBF,
   {$IFOPT N-}
      GSOB_Flp,                       {Used if 80x87 not selected}
   {$ENDIF}
   {$IFDEF WINDOWS}
      Objects;
   {$ELSE}
      GSOB_Obj;
   {$ENDIF}

const

   NdxBlokSize = 512;

type

   LastUpdateAction = (AtLeaf,NoChange,LastChanged,Empty,Expanded);

   GSP_InxHeader  = ^GSR_InxHeader;
   GSR_InxHeader  = Record
      Root        : Longint;
      Next_Blk    : Longint;
      Unknwn1     : Longint;
      Key_Lgth    : SmallInt;
      Max_Keys    : SmallInt;
      Data_Typ    : SmallInt;
      Entry_Sz    : SmallInt;
      Unknwn2     : Longint;
      Key_Form    : array [0..NdxBlokSize-25] of char;
   end;

   GSP_InxDataBlk  = ^GSR_InxDataBlk;
   GSR_InxDataBlk  = Record
      Entry_Ct     : SmallInt;
      Unknwn1      : SmallInt;
      Data_Ary     : array [0..NdxBlokSize+255] of byte; {Array of key entries}
                                                         {plus overflow area}
   end;

   GSP_InxElement = ^GSR_InxElement;
   GSR_InxElement = Record
      Block_Ax  : Longint;
      Recrd_Ax  : Longint;
      Char_Fld  : array [1..255] of char;
   end;

   GSP_IndexFile   = ^GSO_IndexFile;
   GSP_InxNode = ^GSO_InxNode;

   GSP_InxTable = ^GSO_InxTable;
   GSO_InxTable = Object(TCollection)
      ixLink      : GSP_IndexFile;
      Elements    : array[0..(NdxBlokSize div 12)+1] of GSP_InxElement;
      constructor Init(ILink : GSP_IndexFile);
      function    FetchBttm : pointer;
      function    FetchCurr : pointer;
      function    FetchNext : pointer;
      function    FetchPrev : pointer;
      function    FetchTop  : pointer;
      procedure   NodeEntryDelete(en : Integer);
      procedure   NodeEntryInsert(en : Integer; wkey: string; wb, wr: longint);
      function    NodeGet(pn : longint) : pointer;
      procedure   WriteAllNodes(actn: LastUpdateAction);
      procedure   ReleaseNode(p: GSP_InxNode);
      procedure   ReleaseAllNodes;
   end;

   GSO_InxNode = Object(TObject)
      tbLink      : GSP_InxTable;   {Link to collection owner}
      IndxBufr    : GSP_InxDataBlk;
      Page_No     : Longint;   {Disk block holding node info}
      Etry_No     : Integer;   {Last entry used in node}
      ItemCount   : Integer;   {Number of keys in this node }
      NonLeaf     : Boolean;   {True for non-leaf nodes}
      Changed     : boolean;
      ChgLastEtry : boolean;
      constructor Init(CLink : GSP_InxTable; pn : longint);
      destructor  Done; virtual;
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

var
   Ndx_Data : GSR_InxDataBlk;


implementation


const

   AccessTries  : Word = 1000;  {Attempts to access file before stop}
   Same_Record = -5;            {Token value passed to read the same record}

var
   SaveKey1 : GSR_InxElement;
   SaveKey2 : GSR_InxElement;

   Work_Key : string;               {Holds key passed in Find and KeyUpdate}
   RPag     : Longint;              {Work variable to hold current index block}
   RNum     : Longint;              {Work variable for record number}
   IsAscend : Boolean;              {Flag for ascending/descending status.}
                                    {Set based on Next/Previous Record read}


{$IFOPT N+}
{------------------------------------------------------------------------------
                    Conversion/Comparison of Number Fields
                    Used when The $N switch is set '+'
------------------------------------------------------------------------------}

type
   gsDouble = Double;

procedure MakeDouble(C_String: string;var dtype: Double;var rcode : Word);
begin
   val(C_String,dtype,rcode);
end;

function CmprDouble(var val1, val2) : Integer;
var
   v1       : Double absolute val1;
   v2       : Double absolute val2;
begin
   if v1 = v2 then CmprDouble := 0
      else if v1 < v2 then CmprDouble := -1
         else CmprDouble := 1;
end;

function CnvrtDouble(var dtype) : string;
var
   dbl_in : Double absolute dtype;
   st     : string;
begin
   str(dbl_in,st);
   CnvrtDouble := st;
end;
{$ENDIF}

{------------------------------------------------------------------------------
                               GSO_InxTable
------------------------------------------------------------------------------}

constructor GSO_InxTable.Init(ILink : GSP_IndexFile);
var
   i  : Integer;
begin
   TCollection.Init(32,16);
   for i := 0 to ILink^.Max_Keys+2 do
      Elements[i] := Addr(Ndx_Data.Data_Ary[(i *  ILink^.Entry_Sz)]);
   ixLink := ILink;
end;

function GSO_InxTable.FetchBttm : pointer;
var
   p  : GSP_InxNode;
   e  : GSP_InxElement;
begin
   ReleaseAllNodes;
   p := NodeGet(ixLink^.Ndx_Root);
   e := Elements[p^.ItemCount-1];
   while p^.NonLeaf and (p^.ItemCount > 0) do
   begin
      p^.Etry_No := p^.ItemCount;
      if p^.ItemCount > 0 then dec(p^.Etry_No);
      p := NodeGet(e^.Block_Ax);
      if p^.ItemCount > 0 then e := Elements[p^.ItemCount-1] else e := nil;
   end;
   p^.Etry_No := p^.ItemCount;
   if p^.ItemCount > 0 then dec(p^.Etry_No);
   FetchBttm := e;
end;

function GSO_InxTable.FetchCurr : pointer;
var
   p  : GSP_InxNode;
begin
   p := Items^[Count-1];
   p^.Retrieve;
   FetchCurr := Elements[p^.Etry_No];
end;

function GSO_InxTable.FetchNext : pointer;
var
   p  : GSP_InxNode;
   e  : GSP_InxElement;
begin
   if Count = 0 then
   begin
      FetchNext := nil;
      exit;
   end;
   p := Items^[Count-1];
   p^.Retrieve;
   inc(p^.Etry_No);
   if p^.Etry_No < p^.ItemCount then         {Get next in leaf node}
      FetchNext := Elements[p^.Etry_No]
   else
   begin                                 {Search NonLeaf Nodes}
      while (p^.Etry_No >= p^.ItemCount) and (Count <> 1) do
      begin
         ReleaseNode(p);
         p := Items^[Count-1];
         p^.Retrieve;
         inc(p^.Etry_No);
      end;

      if (p^.Etry_No >= p^.ItemCount) then
      begin                 {At EOF, restore back to last valid record}
         dec(p^.Etry_No);
         while p^.NonLeaf do
         begin
            e := Elements[p^.Etry_No];
            p := NodeGet(e^.Block_Ax);
            p^.Etry_No := p^.ItemCount-1;
         end;
         FetchNext := nil;
      end
      else                  {Get next available leaf node}
      begin
         e := Elements[p^.Etry_No];
         while p^.NonLeaf do
         begin
            p := NodeGet(e^.Block_Ax);
            p^.Etry_No := 0;
            if p^.ItemCount > 0 then e := Elements[0] else e := nil;
         end;
         FetchNext := e;
      end;
   end;
end;

function GSO_InxTable.FetchPrev : pointer;
var
   p  : GSP_InxNode;
   e  : GSP_InxElement;
begin
   if Count = 0 then
   begin
      FetchPrev := nil;
      exit;
   end;
   p := Items^[Count-1];
   p^.Retrieve;
   dec(p^.Etry_No);
   if p^.Etry_No >= 0 then         {Get next in leaf node}
      FetchPrev := Elements[p^.Etry_No]
   else
   begin                           {Search nonleafnodes}
      while (p^.Etry_No < 0) and (Count <> 1) do
      begin
         ReleaseNode(p);
         p := Items^[Count-1];
         p^.Retrieve;
         dec(p^.Etry_No);
      end;
      if (p^.Etry_No < 0) then
      begin
         inc(p^.Etry_No);
         while p^.NonLeaf do
         begin
            e := Elements[p^.Etry_No];
            p := NodeGet(e^.Block_Ax);
            p^.Etry_No := 0;
         end;
         FetchPrev := nil;
      end
      else
      begin
         e := Elements[p^.Etry_No];
         while p^.NonLeaf do
         begin
            p := NodeGet(e^.Block_Ax);
            p^.Etry_No := p^.ItemCount-1;
            if p^.ItemCount > 0 then e := Elements[p^.ItemCount-1]
               else e := nil;
         end;
         FetchPrev := e;
      end;
   end;
end;

function GSO_InxTable.FetchTop : pointer;
var
   p  : GSP_InxNode;
   e  : GSP_InxElement;
   n  : longint;
begin
   ReleaseAllNodes;
   p := NodeGet(ixLink^.Ndx_Root);
   e := Elements[0];
   while p^.NonLeaf and (p^.ItemCount > 0) do
   begin
      n := p^.Page_No;
      p^.Etry_No := 0;
      p := NodeGet(e^.Block_Ax);
      if p^.ItemCount <= 0 then e := nil;
   end;
   p^.Etry_No := 0;
   FetchTop := e;
end;

procedure GSO_InxTable.NodeEntryDelete(en : Integer);
var
   p  : GSP_InxNode;
begin
   p := Items^[Count-1];
   p^.Retrieve;
   Move(Elements[en+1]^,Elements[en]^,ixLink^.Entry_Sz*(p^.ItemCount-en));
   dec(Ndx_Data.Entry_Ct);
   move(Ndx_Data, p^.IndxBufr^,SizeOf(Ndx_Data));
   dec(p^.ItemCount);
   p^.ChgLastEtry := p^.ItemCount = en;
   if p^.ChgLastEtry then dec(p^.Etry_No);
   p^.Changed := true;
end;

procedure GSO_InxTable.NodeEntryInsert
                                (en : Integer; wkey: string; wb,wr: longint);
var
   p  : GSP_InxNode;
   e  : GSP_InxElement;
begin
   p := Items^[Count-1];
   p^.Retrieve;
   e := Elements[en];
   Move(Elements[en]^,Elements[en+1]^,ixLink^.Entry_Sz*(p^.ItemCount-en));
   move(wkey[1],e^.Char_Fld,ixLink^.Key_Lgth);
   e^.Block_Ax := wb;
   e^.Recrd_Ax := wr;
   inc(Ndx_Data.Entry_Ct);
   move(Ndx_Data, p^.IndxBufr^,SizeOf(Ndx_Data));
   p^.ChgLastEtry := p^.ItemCount = en;
   inc(p^.ItemCount);
   p^.Changed := true;
end;

function GSO_InxTable.NodeGet(pn : longint) : pointer;
var
   p  : GSP_InxNode;
      nlt : longint;
      nlb : longint;
begin
   p := New(GSP_InxNode, Init(@Self, pn));
   Insert(p);
   p^.Retrieve;
   NodeGet := p;
end;

procedure GSO_InxTable.WriteAllNodes(actn: LastUpdateAction);
var
   p  : GSP_InxNode;
   e  : GSP_InxElement;
   ar : LastUpdateAction;

   Procedure WriteNode(pn : longint);
   begin
      ixLink^.Write(pn*NdxBlokSize,Ndx_Data,NdxBlokSize);
   end;

   Procedure MakeRootNode;
   begin
      ixLink^.Ndx_Hdr.Root := ixLink^.Ndx_NextBlock;
                                          {Set root pointer to this block.}
      ixLink^.Ndx_PutHdr;                 {Write updated header block.}
      FillChar(Ndx_Data, SizeOf(Ndx_Data),#0);
      move(SaveKey1,Elements[0]^,ixLink^.Entry_Sz);
      move(SaveKey2,Elements[1]^,ixLink^.Entry_Sz);
      Ndx_Data.Entry_Ct := 1;
      WriteNode(ixLink^.Ndx_Hdr.Root);
   end;

   Procedure SplitBlock;
   var
      b1   : longint;
      e1   : Integer;
      e2   : Integer;

   begin
      b1 := ixLink^.Ndx_NextBlock;        {Get the next available block.}
      e1 := (p^.ItemCount) shr 1;         {Number of entries in first half.}
      e2 := (p^.ItemCount) - e1;          {Number of entries in second half.}
      Ndx_Data.Entry_Ct := e1;
      if p^.NonLeaf then dec(Ndx_Data.Entry_Ct);
      WriteNode(p^.Page_no);
      move(Elements[e1-1]^,SaveKey1,ixLink^.Entry_Sz);
      SaveKey1.Block_Ax := p^.Page_No;
      SaveKey1.Recrd_Ax := 0;
      Ndx_Data.Entry_Ct := e2;
      if p^.NonLeaf then dec(Ndx_Data.Entry_Ct);
      move(Elements[e1]^,Ndx_Data.Data_Ary[0],ixLink^.Entry_Sz*e2);
                                          {Shift second half to beginning of}
                                          {the buffer array.}
      WriteNode(b1);
      move(Elements[e2-1]^,SaveKey2,ixLink^.Entry_Sz);
      SaveKey2.Block_Ax := b1;
      SaveKey2.Recrd_Ax := 0;
      ixLink^.Ndx_PutHdr;                 {Store from header info area}
   end;

begin
   if Count = 0 then exit;
   p := Items^[Count-1];
   p^.Retrieve;

   if actn = Expanded then
   begin
      e := Elements[p^.Etry_No];
      move(SaveKey2,e^,8);
      move(Elements[p^.Etry_No]^,Elements[p^.Etry_No+1]^,
           ixLink^.Entry_Sz*(p^.ItemCount-p^.Etry_No));
      move(SaveKey1,e^,ixLink^.Entry_Sz);
      inc(Ndx_Data.Entry_Ct);
      p^.ChgLastEtry := p^.ItemCount = p^.Etry_No;
      inc(p^.ItemCount);
      p^.Changed := true;
   end;

   if actn = LastChanged then
   begin
      e := Elements[p^.Etry_No];
      move(SaveKey1,e^,ixLink^.Entry_Sz);
      p^.ChgLastEtry := p^.ItemCount-1 = p^.Etry_No;
      p^.Changed := true;
   end;


   if p^.ItemCount = 0 then ar := Empty
   else
   begin
      if Ndx_Data.Entry_Ct > ixLink^.Max_Keys then  {overflow condition?}
      begin
         SplitBlock;
         ar := Expanded;
      end
      else
      begin
         if p^.Changed then
            WriteNode(p^.Page_no);
        if p^.ChgLastEtry  then
         begin
            move(Elements[p^.Etry_No]^,SaveKey1,ixLink^.Entry_Sz);
            SaveKey1.Block_Ax := p^.Page_No;
            SaveKey1.Recrd_Ax := 0;
            ar := LastChanged;
         end
         else
            ar := NoChange;
      end;
      ReleaseNode(p);
      if Count > 0 then
         WriteAllNodes(ar)
      else
         if ar = Expanded then MakeRootNode;
    end;
end;

procedure GSO_InxTable.ReleaseNode(p: GSP_InxNode);
begin
   Delete(p);
   Dispose(p,Done);
end;

procedure GSO_InxTable.ReleaseAllNodes;
var
   p  : GSP_InxNode;
begin
   while Count > 0 do
   begin
      p := Items^[Count-1];
      ReleaseNode(p);
   end;
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
   ItemCount := 0;
   NonLeaf := true;
   tbLink := CLink;
   Changed := false;
   ChgLastEtry := false;
end;

destructor GSO_InxNode.Done;
begin
   if IndxBufr <> nil then dispose(IndxBufr);
   TObject.Done;
end;

procedure GSO_InxNode.Retrieve;
var
   v : longint;
begin
   if IndxBufr = nil then
   begin
      New(IndxBufr);
      tbLink^.ixLink^.Read(Page_No*NdxBlokSize,IndxBufr^,NdxBlokSize);
   end;
   move(IndxBufr^,Ndx_Data,SizeOf(Ndx_Data));
   ItemCount := Ndx_Data.Entry_Ct;
   move(Ndx_Data.Data_Ary[0],v,4);
   NonLeaf := v <> 0;
   if nonLeaf then inc(ItemCount);
end;

{-----------------------------------------------------------------------------
                                 GSO_IndexFile
------------------------------------------------------------------------------}

constructor GSO_IndexFile.Init(IName : string);
var
   i : Integer;
begin
   GSO_DiskFile.Init(IName+'.NDX',dfReadWrite+dfSharedDenyNone);
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
   tbLink := New(GSP_InxTable, Init(@Self));
end;

Constructor GSO_IndexFile.NewInit(filname, formla: string; lth, dcl: Integer;
                                  typ : char);
var
   i : Integer;
begin
   GSO_DiskFile.Init(filname+'.NDX',dfReadWrite);
   dfFileFlsh := WriteFlush;
   Rewrite(1);
   FillChar(Ndx_Hdr, SizeOf(Ndx_Hdr),#0);
   Ndx_Hdr.Root := 1;
   Ndx_Hdr.Next_Blk := 2;
   case typ of
      'D',
      'F',
      'N'  : begin
                Ndx_Hdr.Data_Typ := 1;
                lth := 8;
             end;
      else Ndx_Hdr.Data_Typ := 0;
   end;
   Ndx_Hdr.Key_Lgth := lth;
   i := lth+8;
   while (i mod 4) <> 0 do i := i + 1;
   Ndx_Hdr.Max_Keys := ((SizeOf(Ndx_Hdr)-8) div i);
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
   Ndx_Hdr.Next_Blk := 2;
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
   rc        : Integer;
   rl        : Word;
   dt        : longint;
   ec        : longint;
   mk        : Integer;
   rf        : GSP_IndxEtry;
   rr        : GSP_IndxEtry;
   sv        : string[100];
   ixFiller  : array[0..NdxBlokSize+255] of byte;
   ixData    : GSR_InxDataBlk absolute ixFiller;
   ixPntr    : GSP_InxElement;
   ixBlok    : longint;
   NodeColl  : GSP_IndxColl;
   DblNum    : gsDouble;

   procedure CacheWrite;
   begin
      move(ixData,CacheBuf^[CacheBlok],NdxBlokSize);
      CacheBlok := CacheBlok+NdxBlokSize;
      if CacheBlok >= NdxBlokSize*32 then
      begin
         Write(-1,CacheBuf^,CacheBlok);
         CacheBlok := 0;
      end;
   end;

   procedure CollectNodes;
   begin
      ixData.Entry_Ct := rc;
      if not recnode then dec(ixData.Entry_Ct);
      CacheWrite;
      FillChar(ixData, SizeOf(ixData),#0);
      NodeColl^.InsertKey(ixBlok, rr^.KeyStr);
      rc := 0;
      inc(ixBlok);
   end;

begin
   mk := Max_Keys;
   if recnode then
   begin
      ixBlok := 1;
      GetMem(CacheBuf,NdxBlokSize*32);
      Read(0,CacheBuf^,NdxBlokSize);    {Position to initial loc}
   end
   else
   begin
      inc(mk);
      ixBlok := Ndx_NextBlock;
   end;
   CacheBlok := 0;
   NodeColl := nil;
   New(NodeColl, InitNode(ixColl));
   rr := p^.RetrieveKey;
   rc := 0;
   ec := 0;
   FillChar(ixData, SizeOf(ixData),#0);
   while rr <> nil do
   begin
      rf := rr;
      ixPntr :=  Addr(ixData.Data_Ary[rc*Entry_Sz]);
      if ixKey_Typ = 'C' then
         move(rr^.KeyStr[1],IxPntr^.Char_Fld[1],Key_Lgth)
      else
      begin
         sv := rr^.KeyStr;
         if ixKey_Typ = 'D' then
         begin
            dt := GS_Date_Juln(sv);
            str(dt,sv);
         end;
         MakeDouble(sv,DblNum,rl);
         move(DblNum,IxPntr^.Char_Fld[1],Key_Lgth);
      end;
      if recnode then
      begin
         IxPntr^.Recrd_Ax := rr^.Tag;
         IxPntr^.Block_Ax := 0;
      end
      else
      begin
         IxPntr^.Recrd_Ax := 0;
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
      CollectNodes;
   end;
   p^.EndRetrieve;
   if CacheBlok > 0 then Write(-1,CacheBuf^,CacheBlok);
   if ec > Max_Keys then IndxStore(NodeColl, false);
   Dispose(NodeColl, Done);
   if recnode then
   begin
      FreeMem(CacheBuf,NdxBlokSize*32);
      Dispose(ixColl, Done);
      Ndx_Hdr.Root := Ndx_NextBlock-1;
      Ndx_PutHdr;
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

   procedure StoreMatchValue;
   begin
      move(CurrElmt^.Char_Fld,ixKey_St[1],Key_Lgth);
                                      {Move the key field to Ndx_Key_St.}
      ixKey_St[0] := Work_Key[0];   {Now insert the length into Ndx_Key_St}
   end;

   function DoMatchValue : Integer;
   begin
      if ixKey_Typ = 'C' then    {Character key field}
         Match_Cnd := StrCompare(ixKey_St, Work_Key)
      else                            {Numeric key field}
         Match_Cnd := CmprDouble(ixKey_St[1], Work_Key[1]);
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
      H := CurrNode^.ItemCount - 1;
      if (CurrNode^.NonLeaf) then dec(H);
      while L <= H do
      begin
         I := (L + H) shr 1;
         CurrElmt := tbLink^.Elements[I];
         StoreMatchValue;
         C := DoMatchValue;
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
   tbLink^.ReleaseAllNodes;
   ixKey_Num := 0;                    {Initialize}
   ixKey_St := '';                    {Initialize}
   Work_Key := Ndx_AdjVal(st);        {Set key comparison value}
   RPag := Ndx_Root;                  {Get root node address}
   PNode := -1;
   ixEOF := true;
   while RPag <> 0 do                 {While a non-leaf node, do this}
   begin
      CurrNode := tbLink^.NodeGet(RPag);
      IsEqual := SearchMatchValue(i);
      CurrNode^.Etry_No := i;
      ixEOF := ixEOF and (i >= Ndx_Data.Entry_Ct);
      CurrElmt := tbLink^.Elements[i];
      PNode := RPag;
      RPag := CurrElmt^.Block_Ax;
   end;
   if IsEqual then
      ixKey_Num := CurrElmt^.Recrd_Ax else ixKey_Num := 0;
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
   writeln(ofil,'Root =',Ndx_Root:5,'   Next Block Available:',Next_Blk:5);
   WorkNode := tbLink^.FetchTop;
   writeln(ofil,'Data records are at Level ',tbLink^.Count,
                ' in the hierarchy.');
   RPag := 1;
   while RPag <> Next_Blk do
   begin
      WorkNode := tbLink^.NodeGet(RPag);
      System.write(ofil,RPag:2,'  [',Ndx_Data.Entry_Ct:2,']');
      CurrElmt :=  tbLink^.Elements[0];
      recnode := not WorkNode^.nonLeaf;
      k := WorkNode^.ItemCount;
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
                  if ixKey_Typ <> 'C' then
                     System.write(ofil,CnvrtDouble(Char_Fld))
                  else
                     for j := 1 to Key_Lgth do
                        System.write(ofil,Char_Fld[j]);
               end;
         WRITELN(OFIL);
         end;
         inc(i);
      end;
      writeln(ofil);
      inc(RPag);
   end;
   Ndx_Flush;
   System.Close(ofil);
end;


Function GSO_IndexFile.KeyLocRec (rec : longint) : boolean;
var
   lr : longint;
begin
   if (rec = ixKey_Num) and (tbLink^.Count > 0) then
   begin                              {Exit if already at the record}
      KeyLocRec := true;
      exit;
   end;
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
   if ((RNum = Next_Record) or (RNum = Prev_Record)) and
      (tbLink^.Count = 0) then
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
   CurrNode := tbLink^.Items^[tbLink^.Count-1];
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
      CurrElmt := tbLink^.Elements[CurrNode^.ItemCount];
   end;
   KeyRead := RNum;                   {Return RNum}
end;

Procedure GSO_IndexFile.KeySort(kl : Integer; sa : SortStatus);
begin
   ixColl := New(GSP_IndxColl, Init(kl, sa));
end;

Procedure GSO_IndexFile.KeyUpdate(rec : longint; st : string; Apnd : boolean);
var
   em_hold : boolean;                 {holds ExactMatch flag during this}
   old_key : ixKeyString;
   old_num : longint;
   shrrsl  : Word;
   icr     : Word;

{
   This routine deletes the current entry by overlaying the remaining entries
   over the entry location, and then decrementing the entry count.  The
   routine then saves the nodes back to disk, deleting nodes where needed.
   Node objects are released as they are written.
}
   Procedure KeyDelete;
   begin
      tbLink^.NodeEntryDelete(CurrNode^.Etry_No);
      tbLink^.WriteAllNodes(AtLeaf);
   end;

{  This routine inserts an entry by making room in the current data array
   and inserting the new entry.  The entry count is then incremented.  The
   routine then saves the nodes back to disk, expanding nodes where needed.
   Node objects are released as they are written.  The routine will first
   find the record that is just after the record key.  This is necessary
   to ensure a new duplicate key is properly inserted after any existing
   matching keys.
}
   Procedure KeyInsert;
   var
      nu_key : longint;
   begin
      nu_key := KeyFind(st);          {Find a matching key.}
      if nu_key <> 0 then             {If there is a match, continue looking}
         while (ixKey_St = Work_Key) and (not ixEOF) do
            nu_key := KeyRead(Next_Record);
      ixKey_St := PadR(Work_Key,Key_Lgth);
      ixKey_Num := rec;
      tbLink^.NodeEntryInsert(CurrNode^.Etry_No,ixKey_St,0,rec);
      tbLink^.WriteAllNodes(AtLeaf);
      if not ixFollowKey then
      begin
         ixKey_St := old_key;
         ixKey_Num := old_num;
      end;
   end;


begin
   old_key := ixKey_St;
   old_num := ixKey_Num;
   Work_Key := Ndx_AdjVal(st);        {Set key comparison value}
   em_hold := dbExactMatch;
   dbExactMatch := true;
   if dfFileShrd then
   begin
      icr := 0;
      repeat
         shrrsl := LockRec(0,NdxBlokSize);
         inc(icr);
      until (shrrsl = 0) or (icr > AccessTries);
      if shrrsl <>  0 then
      begin
         Error(dosAccessDenied, ndxKeyUpdateError);
         exit;
      end;
   end;
   if Apnd then                   {Tests for Append vs Update}
      KeyInsert
   else
   begin
      if KeyLocRec(rec) then
      begin
         if Work_Key <> ixKey_St then
         begin
            KeyDelete;
            KeyInsert;
         end;
      end;
   end;
   if dfFileShrd then shrrsl := UnLock;
   dbExactMatch := em_hold;
end;



function GSO_IndexFile.Ndx_AdjVal(st : string): string;
var
   Work_Key : string;
   Work_Num : gsDouble;
   dt       : longint;
   rl       : Word;
begin
   if ixKey_Typ = 'C' then
   begin                              {if a character key field then --}
      if dbExactMatch then
         Work_Key := PadR(st,Key_Lgth)
      else
         Work_Key := st;
   end
   else
   begin
      if ixKey_Typ = 'D' then
      begin
         dt := GS_Date_Juln(st);
         str(dt,st);
      end;
      MakeDouble(st,Work_Num,rl);
      if rl <> 0 then Error(tpFloatPointInvld, ndxNdx_AdjValError);
      move(Work_Num, Work_Key[1], 8);
      Work_Key[0] := #8;
   end;
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
   Flush;
   tbLink^.ReleaseAllNodes;
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
   Ndx_NextBlock := FileSize div NdxBlokSize;
end;

Procedure GSO_IndexFile.Ndx_PutHdr;
begin
   Ndx_Hdr.Next_Blk := Ndx_NextBlock;
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


