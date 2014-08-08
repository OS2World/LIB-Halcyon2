unit GSOB_MMo;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                        dBase III/IV Memo File Handler

           GSOB_MMO (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved 

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       This unit handles the objects for all dBase III/IV Memo (.DBT)
       file operations.

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

{$O+} {Vp/2 simply skip this!}

interface

uses
     Use32,
     {$IFDEF WINDOWS}
        Objects,
     {$ENDIF}
     GSOB_Var,
     GSOB_Dsk,
     GSOB_Obj,
     GSOB_Str;

type

   moFileStatus = (Invalid, NotOpen, NotUpdated, Updated);

   GSR_MoFieldUsed   = record
      DBIV       : SmallInt;
      StartLoc   : SmallInt;
      LenMemo    : longint;
   end;

   GSR_MoFieldEmty   = record
      NextEmty   : longint;
      BlksEmty   : longint;
   end;

   GSP_dBMemo = ^GSO_dBMemo;
   GSO_dBMemo  = object(GSO_DiskFile)
      TypeMemo     : Byte;            {83 for dBase III; 8B for dBase IV}
      dStatus      : moFileStatus;    {Holds status code of file}
      MemoCollect  : GSP_LineCollection;
      MemoLineRtn  : Byte;
      Memo_Loc     : Longint;         {Current Memo record}
      Memo_Bloks   : Word;
      Edit_Lgth    : Word;

      constructor Init(FName : string; DBVer : byte);
      destructor  Done; virtual;
      procedure   Close; virtual;
      procedure   HuntAvailBlock(numbytes : longint); virtual;
      procedure   MemoBlockRelease(rpt : longint); virtual;
      Function    MemoBlocks(rpt : longint): Word; virtual;
      Procedure   MemoClear; virtual;
      procedure   MemoGet(rpt : longint); virtual;
      function    MemoGetLine(linenum : Integer) : string; virtual;
      Procedure   MemoInsLine(linenum : Integer; st : string); virtual;
      function    MemoLines : Integer; virtual;
      function    MemoPut(rpt : longint) : longint; virtual;
      procedure   MemoPutLast; virtual;
      procedure   MemoSetParam(var bl,mc,bc: longint;var fi: boolean); virtual;
      procedure   MemoWidth(l : Integer); virtual;
      procedure   Open; virtual;
   end;

   GSP_dBMemo3 = ^GSO_dBMemo3;
   GSO_dBMemo3 = object(GSO_dbMemo)
   end;

   GSP_dBMemo4 = ^GSO_dBMemo4;
   GSO_dBMemo4 = object(GSO_dbMemo)
      procedure   MemoBlockRelease(rpt : longint); virtual;
      Function    MemoBlocks(rpt : longint): Word; virtual;
      procedure   HuntAvailBlock(numbytes : longint); virtual;
      procedure   MemoPutLast; virtual;
      procedure   MemoSetParam(var bl,mc,bc: longint;var fi: boolean); virtual;
   end;

{------------------------------------------------------------------------------
                            IMPLEMENTATION SECTION
------------------------------------------------------------------------------}

implementation

var
   bCnt,                              {Will hold bytes in memo field}
   bLmt,                              {dB4 = bytes in memo; dB3 = zero}
   lCnt : longint;                    {Counter for line length in characters}
   mCnt,                              {Counter for input buffer char position}
   tcnt  :  longint;                  {Counter for blocks needed}
   fini    : boolean;                 {Flag set when end of memo field found}
   Valu_Line : string;
   Mem_Block : array [0..GS_dBase_MaxMemoRec*2] of byte;    {Output buffer}
   Mem_UsedBlok : GSR_MoFieldUsed absolute Mem_Block;
   Mem_EmtyBlok : GSR_MoFieldEmty absolute Mem_Block;

{------------------------------------------------------------------------------
                                GSO_dBMemo
------------------------------------------------------------------------------}


CONSTRUCTOR GSO_dBMemo.Init(FName : string; DBVer : byte);
begin
   GSO_DiskFile.Init(FName+'.DBT',dfReadWrite+dfSharedDenyNone);
   TypeMemo := DBVer;
   Edit_Lgth := 70;
   if dfFileExst then
   begin
      dStatus := NotOpen;             {Set file status to 'Not Open'   }
      MemoCollect := New(GSP_LineCollection, Init(50,10));
   end
   else
   begin
      dStatus := Invalid;
      Error(dosFileNotFound, mmoInitError);
   end;
end;

destructor GSO_dBMemo.Done;
begin
   Close;
   Dispose(MemoCollect, Done);
   GSO_DiskFile.Done;
end;

PROCEDURE GSO_dBMemo.Close;
begin
   MemoCollect^.FreeAll;
   GSO_DiskFile.Close;
   dStatus := NotOpen;
end;

procedure GSO_dBMemo.HuntAvailBlock(numbytes : longint);
var
   BlksReq : Integer;

   procedure NewDB3Block;
   begin
      with Mem_EmtyBlok do
      begin
         Read(0, Mem_Block, 1);    {read header block from the .DBT}
         Memo_Loc := NextEmty;
         NextEmty := NextEmty + BlksReq;
         Write(0, Mem_Block, 1);
      end;
   end;

   procedure OldDB3Block;
   begin
      Memo_Bloks := MemoBlocks(Memo_Loc);
      if Memo_Bloks < BlksReq then NewDB3Block;
   end;


begin
   BlksReq := (numbytes div GS_dBase_MaxMemoRec)+1;
   if (Memo_Loc > 0) then
      OldDB3Block
   else
      NewDB3Block;
   Memo_Bloks := BlksReq;
   mCnt := 0;
end;

Procedure GSO_dBMemo.MemoBlockRelease(rpt : longint);
begin                          {dummy to match GSO_dBMemo4.MemoBlockRelease}
end;

Function GSO_dBMemo.MemoBlocks(rpt : longint): Word;
var
   match   : boolean;
   blks    : Word;
   i       : Integer;
begin
   blks := 0;
   match := false;
   Read(rpt, Mem_Block, 1);
   while not match do
   begin
      inc(blks);
      i := 0;
      while (Mem_Block[i] <> EOFMark) and (i < GS_dBase_MaxMemoRec) do
         inc(i);
      if (i >= GS_dBase_MaxMemoRec) then
         Read(-1, Mem_Block, 1)
      else
         match := true;
   end;
   MemoBlocks := blks;
end;

Procedure GSO_dBMemo.MemoGet(rpt : longint);
BEGIN                       { Get Memo Field }
   Memo_Loc := rpt;                   {Save starting block number}
   Memo_Bloks := 0;                   {Initialize blocks read}
   if MemoCollect^.Count > 0 then MemoCollect^.FreeAll;
   if (Memo_Loc = 0) then exit;
   Read(Memo_Loc, Mem_Block, 1);
   MemoSetParam(bLmt, mCnt, bCnt, fini);
   lCnt := 0;                         {line length counter}
   while (not fini) do             {loop until done (EOF mark)}
   begin
      inc(Memo_Bloks);
      while (mCnt < GS_dBase_MaxMemoRec) and (fini = false) do
      begin
         case Mem_Block[mCnt] of   {Check for control characters}
            $1A : begin
                     fini := true; {End of Memo field}
                     if lcnt> 0 then
                     begin
                        Valu_Line[0] := chr(lcnt);
                        MemoCollect^.InsertItem($0D,Valu_Line);
                     end;
                  end;
            $8D : begin            {Soft Return (Wordstar and dBase editor)}
                     if (Valu_Line[lCnt] <> ' ') and
                        (Valu_Line[lCnt] <> '-') and
                        (lCnt > 0) then
                     begin
                        inc(lCnt); {Add to line length count}
                        Valu_Line[lcnt] := ' ';
                                   {Insert a space in storage}
                     end;
                  end;
            $0A : begin            {Linefeed}
                  end;             {Ignore these characters}
            $0D : begin            {Hard Return}
                     Valu_Line[0] := chr(lcnt);
                     MemoCollect^.InsertItem($0D,Valu_Line);
                     lCnt := 0;
                  end;
            else                   {Here for other characters}
            begin
               inc(lCnt);          {Add to line length count}
               Valu_Line[lcnt] :=  chr(Mem_Block[mCnt]);
                                   {Insert the character in storage}
            end;
         end;
         if lCnt > Edit_Lgth then
                                   {If lcnt longer than Memo_Width, you}
                                   {must word wrap to Memo_Width length}
                                   {or less}
         begin
            while (Valu_Line[lCnt] <> ' ') and
                  (Valu_Line[lCnt] <> '-') and
                  (lCnt > 0) do dec(lCnt);
                                   {Repeat search for space or hyphen until}
                                   {found or current line exhausted}
            if (lCnt = 0) then lcnt := Edit_Lgth;
                                   {If no break point, truncate line}
            Valu_Line[0] := chr(lcnt);
            MemoCollect^.InsertItem($8D,Valu_Line);
            Valu_Line[0] := chr(Edit_Lgth+1);
            system.delete(Valu_Line,1,lCnt);
            lCnt := byte(Valu_Line[0]);
         end;
         inc(mCnt);                {Step to next input buffer location}
         inc(bCnt);                {Increment total bytes read}
         if not fini and (bCnt = bLmt) then
         begin
            fini := true; {End of Memo field}
            if lcnt> 0 then
            begin
               Valu_Line[0] := chr(lcnt);
               MemoCollect^.InsertItem($0D,Valu_Line);
            end;
         end;
      end;
      if not fini then Read(Memo_Loc+Memo_Bloks, Mem_Block, 1);
      mCnt := 0;                   {Counter into disk read buffer}
   end;
END;                        { Get Memo Field }


function GSO_dBMemo.MemoGetLine(linenum : Integer) : string;
var
   P : GSP_LineBuf;
begin
   P := MemoCollect^.At(linenum);
   if P <> nil then
   begin
      MemoGetLine := P^.LineText;
      MemoLineRtn := P^.LineRetn;
   end
      else MemoGetLine := '';
end;

Procedure GSO_dBMemo.MemoInsLine(linenum : Integer; st : string);
begin
   if linenum < 0 then MemoCollect^.InsertItem($0D,st)
      else if linenum < MemoCollect^.Count then
          MemoCollect^.InsertItemAt($0D,st,linenum);
end;

Function GSO_dBMemo.MemoLines : Integer;
begin
   MemoLines := MemoCollect^.Count;
end;

Procedure GSO_dBMemo.MemoClear;
begin
   if MemoCollect^.Count > 0 then MemoCollect^.FreeAll;
end;

Function GSO_dBMemo.MemoPut(rpt : longint) : longint;
var
   rsl : Word;
   i,j : Integer;
   P : GSP_LineBuf;
BEGIN                       { Put Memo Field }
   i := 0;
   repeat
      if dfFileShrd then
         rsl := LockRec(0,1)
      else rsl := 0;
      inc(i);
   until (rsl = 0) or (i = 10);
   if i = 10 then Error(dosAccessDenied,mmoMemoPutError);
   Memo_Loc := rpt;
   bCnt := MemoCollect^.ByteCount;      {Get count of bytes in memo field}
   if bcnt = 0 then
   begin
      MemoPut := 0;
      rsl := UnLock;
      exit;
   end;
   HuntAvailBlock(bCnt);
   lCnt := 0;                         {line length counter}
   tCnt := Memo_Loc;
   j := Memolines-1;
   for i := 0 to j do
   begin
      P := MemoCollect^.At(i);
      if P <> nil then
      begin
         Valu_Line := P^.LineText;
         Move(Valu_Line[1],Mem_Block[mCnt],ord(Valu_Line[0]));
         mCnt := mCnt + length(Valu_Line);
         Mem_Block[mCnt] := P^.LineRetn;
         Mem_Block[mCnt+1] := $0A;
         inc(mCnt,2);
         if (mCnt > GS_dBase_MaxMemoRec) then
         begin
            Write(tcnt, Mem_Block, 1);   {Write a block to the .DBT}
            inc(tcnt);
            mCnt := mCnt mod GS_dBase_MaxMemoRec;
                                      {Get excess buffer length used}
            Move(Mem_Block[GS_dBase_MaxMemoRec],Mem_Block[0],mCnt);
                                      {Move excess to beginning of buffer}
         end;
      end;
   end;
   if (mCnt = GS_dBase_MaxMemoRec) then
   begin
      Write(tcnt, Mem_Block, 1);   {Write a block to the .DBT}
      inc(tcnt);
      mCnt := 0;
   end;
   MemoPutLast;
   if (mCnt < GS_dBase_MaxMemoRec) then
      FillChar(Mem_Block[mcnt],GS_dBase_MaxMemoRec - mcnt,#0);
   Write(tcnt, Mem_Block, 1);        {Write the last block to the .DBT}
   MemoPut := Memo_Loc;
   rsl := UnLock;
end;

Procedure GSO_dBMemo.MemoPutLast;
begin
   Mem_Block[mCnt] := EOFMark;
   inc(mCnt);
   Mem_Block[mCnt] := EOFMark;
   inc(mCnt);
end;

Procedure GSO_dBMemo.MemoSetParam(var bl,mc,bc: longint;var fi: boolean);
begin
   bLmt := 0;
   mCnt := 0;                   {Counter into disk read buffer}
   bCnt := 0;
   fini := false;                     {Reset done flag to false}
end;


Procedure GSO_dBMemo.MemoWidth(l : Integer);
begin
   Edit_Lgth := l;
end;

PROCEDURE GSO_dBMemo.Open;
BEGIN
   if dStatus <= NotOpen then
   begin
      Reset(GS_dBase_MaxMemoRec);     {If memo file, then open .DBT file}
      dStatus := NotUpdated;
   end;
END;

{------------------------------------------------------------------------------
                                GSO_dBMemo4
------------------------------------------------------------------------------}

procedure GSO_dBMemo4.HuntAvailBlock(numbytes : longint);
var
   BlksReq : Integer;
   WBlok1  : longint;
   WBlok2  : longint;
   WBlok3  : longint;

   procedure FitDB4Block;
   var
      match   : boolean;
   begin
      match := false;
      Read(0, Mem_Block, 1);    {read header block from the .DBT}
      WBlok3 := FileSize;
      if WBlok3 = 0 then     {empty file, fill up header block}
      begin
         inc(WBlok3);
         FillChar(Mem_Block[24],GS_dBase_MaxMemoRec-24,#0);
         Write(0, Mem_Block, 1);
      end;
      with Mem_EmtyBlok do
      begin
         WBlok1 := NextEmty;
         WBlok2 := 0;
         while not match and (WBlok1 <> WBlok3) do
         begin
            Read(WBlok1,Mem_Block,1);
            if BlksEmty >= BlksReq then
            begin
               match := true;
               WBlok3 := NextEmty;
               if BlksEmty > BlksReq then      {free any blocks not needed}
               begin
                  WBlok3 := WBlok1+BlksReq;
                  BlksEmty := BlksEmty - BlksReq;
                  Write(WBlok3,Mem_Block,1);
               end;
            end
            else                            {new memo won't fit this chunk}
            begin
               WBlok2 := WBlok1;            {keep previous available chunk}
               WBlok1 := NextEmty;          {get next available chunk}
            end;
         end;
         if not match then WBlok3 := WBlok3 + BlksReq;
         Read(WBlok2, Mem_Block, 1);
         NextEmty := WBlok3;
         Write(WBlok2, Mem_Block, 1);
      end;
   end;

begin
   BlksReq := ((numbytes+8) div GS_dBase_MaxMemoRec)+1;
   if (Memo_Loc > 0) then MemoBlockRelease(Memo_Loc);
   FitDB4Block;
   Memo_Loc := WBlok1;
   Memo_Bloks := BlksReq;
   Mem_UsedBlok.DBIV := -1;
   Mem_UsedBlok.StartLoc:= 8;
   Mem_UsedBlok.LenMemo := numbytes+8;
   mCnt := 8;
end;

Procedure GSO_dBMemo4.MemoBlockRelease(rpt : longint);
var
   blks     : Word;
begin
   blks := MemoBlocks(rpt);
   with Mem_EmtyBlok do
   begin
      Read(0, Mem_Block, 1);
      BlksEmty := blks;
      Write(rpt, Mem_Block, 1);
      NextEmty := rpt;
      BlksEmty := 0;
      Write(0, Mem_Block, 1);
   end;
end;

Function GSO_dBMemo4.MemoBlocks(rpt : longint): Word;
var
   blks : Word;
begin
   blks := 0;
   with Mem_UsedBlok do
   begin
      Read(rpt, Mem_Block, 1);
      if DBIV = -1 then
         blks := (LenMemo div GS_dBase_MaxMemoRec)+1;
   end;
   MemoBlocks := blks;
end;

Procedure GSO_dBMemo4.MemoPutLast;
begin
end;

Procedure GSO_dBMemo4.MemoSetParam(var bl,mc,bc: longint;var fi: boolean);
begin
   if Mem_UsedBlok.DBIV = -1 then
   begin
      bLmt := Mem_UsedBlok.LenMemo;
      mCnt := Mem_UsedBlok.StartLoc;
      bCnt := mCnt;                   {init total byte count}
      fini := bCnt = bLmt;            {test for zero bytes in memo}
   end
   else Error(gsBadDBTRecord, mmoMemoSetParamErr);
end;


end.
{-----------------------------------------------------------------------------}
                                     END
