unit GSOB_OBJ;

{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                            Collection Handler

           GSOB_OBJ (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved 

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       This unit handles the objects for collections.  This is an
       abbreviated version of the BorLand Objects unit.

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

interface

Uses
{$IfDef WINDOWS}
   Objects,
{$Else}
   Use32;

const

  {$IfDef Os2}
   MaxCollectionSize = 512*1024*1024 div SizeOf(Pointer);
  {$Else}
   MaxCollectionSize = 65520 div SizeOf(Pointer);
  {$EndIf}

   coAbstrError = 211;            { Call to Abstract Method }
   coIndexError = 213;            { Index out of range }
   coOverflow   = 214;            { Overflow }


type

   PObject = ^TObject;
   TObject = object
      constructor Init;
      procedure   Error(Code, Info: Integer); virtual;
      procedure   Free;
      destructor  Done; virtual;
   end;

   PString = ^String;

   PByteArray = ^TByteArray;
  {$IfDef Os2}
   TByteArray = array[0..512*1024*1024] of byte;
  {$Else}
   TByteArray = array [0..32767] of byte;
  {$EndIf}

   PColPntrs = ^TColPntrs;
   TColPntrs = array[0..MaxCollectionSize - 1] of Pointer;


   PCollection = ^TCollection;
   TCollection = object(TObject)
      Items       : PColPntrs;
      Count       : Integer;
      Limit       : Integer;
      Delta       : Integer;
      constructor Init(ALimit, ADelta: Integer);
      destructor  Done; virtual;
      function    At(Index: Integer): Pointer;
      procedure   AtDelete(Index: Integer);
      procedure   AtInsert(Index: Integer; Item: Pointer);
      procedure   AtPut(Index: Integer; Item: Pointer);
      procedure   Delete(Item: Pointer);
      procedure   DeleteAll;
      procedure   Free(Item: Pointer);
      procedure   FreeAll;
      procedure   FreeItem(Item: Pointer); virtual;
      function    IndexOf(Item: Pointer): Integer; virtual;
      procedure   Insert(Item: Pointer); virtual;
      procedure   SetLimit(ALimit: Integer); virtual;
   end;

   PSortedCollection = ^TSortedCollection;
   TSortedCollection = object(TCollection)
      Duplicates  : Boolean;
      constructor Init(ALimit, ADelta: Integer);
      function    Compare(Key1, Key2: Pointer): Integer; virtual;
      function    IndexOf(Item: Pointer): Integer; virtual;
      procedure   Insert(Item: Pointer); virtual;
      function    KeyOf(Item: Pointer): Pointer; virtual;
      function    Search(Key: Pointer; var Index: Integer): Boolean; virtual;
   end;

   PStringCollection = ^TStringCollection;
   TStringCollection = object(TSortedCollection)
      function    Compare(Key1, Key2: Pointer): Integer; virtual;
      procedure   FreeItem(Item: Pointer); virtual;
   end;


procedure DisposeStr(p: PString);
function  NewStr(s: string): PString;


{$ENDIF}

type
   GSP_LineBuf = ^GSR_LineBuf;
   GSR_LineBuf = record
      LineRetn :  byte;
      LineText :  string;
   end;

   GSP_LineCollection = ^GSO_LineCollection;
   GSO_LineCollection = object(TCollection)
      function   ByteCount : longint; virtual;
      procedure  FreeItem(Item : pointer); virtual;
      procedure  InsertItem(rtn : byte; var st : string); virtual;
      procedure  InsertItemAt(rtn : byte;var st : string;i : Integer); virtual;
   end;


implementation

{$IFNDEF WINDOWS}
{------------------------------------------------------------------------------
                             Global Procedures/Functions
------------------------------------------------------------------------------}

procedure Abstract;
begin
  RunError(coAbstrError);
end;

procedure DisposeStr(p: PString);
begin
  if P <> nil then FreeMem(p, Length(p^) + 1);
end;

function NewStr(S: String): PString;
var
  p: PString;
begin
  if s = '' then p := nil else
  begin
    GetMem(p, Length(s) + 1);
    p^ := s;
  end;
  NewStr := p;
end;

{------------------------------------------------------------------------------
                                  TObject
------------------------------------------------------------------------------}

constructor TObject.Init;
begin
end;

Procedure TObject.Error(Code, Info : Integer);
begin
   RunError(Code);
end;

procedure TObject.Free;
begin
   Dispose(PObject(@Self), Done);
end;

destructor TObject.Done;
begin
end;


{------------------------------------------------------------------------------
                                  TCollection
------------------------------------------------------------------------------}

constructor TCollection.Init(ALimit, ADelta: Integer);
begin
   TObject.Init;
   Items := nil;
   Count := 0;
   Limit := 0;
   Delta := ADelta;
   SetLimit(ALimit);
end;

destructor TCollection.Done;
begin
   FreeAll;
   SetLimit(0);
end;

function TCollection.At(Index: Integer): Pointer;
begin
   if (Index < 0) or (Index >= Count) then
   begin
      Error(coIndexError,0);
      At := nil;
   end
      else At := Items^[Index];
end;

procedure TCollection.AtDelete(Index: Integer);
begin
   if (Index >= 0) and (Index < Count) then
   begin
      if Index < Count-1 then
         move(Items^[Index+1],Items^[Index],((Count-1)-Index)*4);
      dec(Count);
   end
   else Error(coIndexError,0);
end;

procedure TCollection.AtInsert(Index: Integer; Item: Pointer);
begin
   if (Index >= 0) and (Index <= Count) then
   begin
      if Count = Limit then SetLimit(Limit+Delta);
      if Index <> Count then
         move(Items^[Index],Items^[Index+1],(Count-Index)*4);
      Items^[Index] := Item;
      inc(Count);
   end
   else Error(coIndexError,0);
end;

procedure TCollection.AtPut(Index: Integer; Item: Pointer);
begin
   if (Index >= 0) and (Index <= Count) then
      Items^[Index] := Item
   else Error(coIndexError,0);
end;

procedure TCollection.Delete(Item: Pointer);
begin
   AtDelete(IndexOf(Item));
end;

procedure TCollection.DeleteAll;
begin
   Count := 0;
end;

procedure TCollection.Free(Item: Pointer);
begin
   Delete(Item);
   FreeItem(Item);
end;

procedure TCollection.FreeAll;
var
  I: Integer;
begin
   for I := 0 to Count - 1 do FreeItem(At(I));
   Count := 0;
end;

procedure TCollection.FreeItem(Item: Pointer);
begin
   if Item <> nil then Dispose(PObject(Item), Done);
end;

function TCollection.IndexOf(Item: Pointer): Integer;
var
   i          : Integer;
   foundit    : boolean;
begin
   foundit := false;
   i := 0;
   while not foundit and (i < Count) do
   begin
      foundit := Item = Items^[i];
      if not foundit then inc(i);
   end;
   if foundit then IndexOf := i else IndexOf := -1;
end;

procedure TCollection.Insert(Item: Pointer);
begin
   AtInsert(Count, Item);
end;

procedure TCollection.SetLimit(ALimit: Integer);
var
   AItems: PColPntrs;
begin
   if ALimit < Count then ALimit := Count;
   if ALimit > MaxCollectionSize then ALimit := MaxCollectionSize;
   if ALimit <> Limit then
   begin
      if ALimit = 0 then AItems := nil else
      begin
         GetMem(AItems, ALimit * SizeOf(Pointer));
         if (Count <> 0) and (Items <> nil) then
            Move(Items^, AItems^, Count * SizeOf(Pointer));
      end;
      if Limit <> 0 then FreeMem(Items, Limit * SizeOf(Pointer));
      Items := AItems;
      Limit := ALimit;
   end;
end;

{------------------------------------------------------------------------------
                               TSortedCollection
------------------------------------------------------------------------------}

constructor TSortedCollection.Init(ALimit, ADelta: Integer);
begin
   TCollection.Init(ALimit, ADelta);
   Duplicates := False;
end;

function TSortedCollection.Compare(Key1, Key2: Pointer): Integer;
begin
   Abstract;
end;

function TSortedCollection.IndexOf(Item: Pointer): Integer;
var
   I: Integer;
begin
   IndexOf := -1;
   if Search(KeyOf(Item), I) then
   begin
      if Duplicates then
         while (I < Count) and (Item <> Items^[I]) do Inc(I);
      if I < Count then IndexOf := I;
   end;
end;

procedure TSortedCollection.Insert(Item: Pointer);
var
   I: Integer;
begin
   if not Search(KeyOf(Item), I) or Duplicates then AtInsert(I, Item);
end;

function TSortedCollection.KeyOf(Item: Pointer): Pointer;
begin
   KeyOf := Item;
end;

function TSortedCollection.Search(Key: Pointer; var Index: Integer): Boolean;
var
   L, H, I, C: Integer;
begin
   Search := False;
   L := 0;
   H := Count - 1;
   while L <= H do
   begin
      I := (L + H) shr 1;
      C := Compare(KeyOf(Items^[I]), Key);
      if C < 0 then L := I + 1 else
      begin
         H := I - 1;
         if C = 0 then
         begin
            Search := True;
            if not Duplicates then L := I;
         end;
      end;
   end;
   Index := L;
end;

{ ----------------------------------------------------------------------------
                               TStringCollection
-----------------------------------------------------------------------------}

function TStringCollection.Compare(Key1, Key2: Pointer): Integer;
var
   PSt1 : PString absolute Key1;
   PSt2 : PString absolute Key2;
   flg  : Integer;
   eql  : boolean;
begin
{$IfDef Os2}
   eql := PSt1^ = PSt2^;
   Asm
    PUSHF
    POP   ECx
    MOV   flg,ECx
   end;
   if eql then Compare := 0
      else if (flg and $0080) = 0 then
             Compare := 1             {Key1 > Key2 if sign flag 0}
           else Compare := -1;        {Key1 < Key2 if sign flag 1}
{$Else}
   eql := PSt1^ = PSt2^;
   Inline(              {Get flag register in flg}
     $9C/                   {  PUSHF           ;Push flag register}
     $59/                   {  POP     CX      ;Get flag register in CX}
     $89/$4E/<flg);         {  MOV     <flg,CX ;Store CX in flg}
   if eql then Compare := 0
      else if (flg and $0080) = 0 then
             Compare := 1             {Key1 > Key2 if sign flag 0}
           else Compare := -1;        {Key1 < Key2 if sign flag 1}
{$EndIf}
end;

procedure TStringCollection.FreeItem(Item: Pointer);
begin
   DisposeStr(Item);
end;


{$ENDIF} { IFnDEF windows }
{------------------------------------------------------------------------------
                              GSO_LineCollection
------------------------------------------------------------------------------}

function GSO_LineCollection.ByteCount : longint;
var
   i : longint;
   v : Integer;
   p : GSP_LineBuf;
begin
   i := 0;
   for v := 0 to Count-1 do
   begin
      p := At(v);
      if p <> nil then
      begin
         i := i + byte(p^.LineText[0]);
         inc(i,2);
      end;
   end;
   ByteCount := i;
end;

procedure GSO_LineCollection.FreeItem(Item: Pointer);
var
   p : GSP_LineBuf absolute Item;
begin
   FreeMem(p, byte(p^.LineText[0])+2);
end;

Procedure GSO_LineCollection.InsertItem(rtn : byte; var st : string);
var
   p : GSP_LineBuf;
begin
   GetMem(p, byte(st[0])+2);
   p^.LineRetn := rtn;
   p^.LineText := st;
   Insert(p);
end;

Procedure GSO_LineCollection.InsertItemAt(rtn : byte; var st : string;
                                          i : Integer);
var
   p : GSP_LineBuf;
begin
   GetMem(p, byte(st[0])+2);
   p^.LineRetn := rtn;
   p^.LineText := st;
   AtInsert(i,p);
end;



end.

