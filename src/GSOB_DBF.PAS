unit GSOB_DBF;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                          dBase III/IV File Handler

           GSOB_DBF (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved 

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       This unit handles the object for all dBase III/IV file (.DBF)
       operations.  The object to manipulate the fields in the
       records of a dBase file is also contained here.

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

interface

uses
     Use32,
     GSOB_Var,
     GSOB_Dte,
     GSOB_Dsk,    {File handler}
     GSOB_Str,    {String handling Routines}
     {$IFDEF WINDOWS}
        WinDOS,
        Objects;     {Collection handler}
     {$ELSE}
        DOS,
        GSOB_Obj;
     {$ENDIF}

const

   UseDelRecord : boolean = true;      {True if deleted records are used}
   dbExactMatch : boolean = false;

type

   dbFileStatus = (Invalid, NotOpen, NotUpdated, Updated);

   GSP_DBFHeader = ^GSR_DBFHeader;
   GSR_DBFHeader = Record
      DBType     : Byte;
      Year       : Byte;
      Month      : Byte;
      Day        : Byte;
      RecCount   : LongInt;
      Location   : SmallInt;
      RecordLen  : SmallInt;
      Reserved   : Array[1..20] of Byte;
   end;

   GSP_DBFField = ^GSR_DBFField;
   GSR_DBFField = Record
      FieldName    : array[0..10] of char;
      FieldType    : Char;
      FieldAddress : pointer;
      FieldLen     : Byte;
      FieldDec     : Byte;
      FieldNum     : SmallInt;          {Used by GS to hold the field number}
      Reserved     : Array[1..12] of Char;
   end;

   GSP_FieldArray = ^GSA_FieldArray;
   GSA_FieldArray  = ARRAY[1..512] OF GSR_DBFField;

   GSP_dBaseDBF = ^GSO_dBaseDBF;
   GSO_dBaseDBF = object(GSO_DiskFile)
      HeadProlog   : GSR_DBFHeader;   {Image of file header}
      dStatus      : dbFileStatus;    {Holds Status Code of file}
      NumRecs      : LongInt;         {Number of records in file}
      HeadLen      : Integer;         {Header + Field Descriptor length}
      RecLen       : Integer;         {Length of record}
      NumFields    : Integer;         {Number of fields in the record}
      DelFlag      : boolean;         {True if record deleted}
      Fields       : GSP_FieldArray;  {Pointer to memory array holding}
                                      {field descriptors}
      RecNumber    : LongInt;         {Physical record number last read}
      CurRecord    : PByteArray;      {Pointer to memory array holding}
                                      {the current record data.  Refer}
                                      {to Appendix B for record structure}
      File_EOF     : boolean;         {True if access tried beyond end of file}
      File_TOF     : boolean;         {True if access tried before record 1}
      FileVers     : byte;
      FileIsLocked : boolean;
      LockCount    : Word;
      CONSTRUCTOR Init(FName : string);
      DESTRUCTOR  Done; virtual;
      PROCEDURE   Append; virtual;
      PROCEDURE   Close; virtual;
      Procedure   Flush; virtual;
      PROCEDURE   GetRec(RecNum: LongInt); virtual;
      Procedure   HdrWrite; virtual;
      Function    LokApnd: boolean; virtual;
      Function    LokFile: boolean; virtual;
      Function    LokIt(fposn,flgth: longint): boolean;
      Procedure   LokOff; virtual;
      Function    LokRcrd: boolean; virtual;
      PROCEDURE   Open; virtual;
      PROCEDURE   PutRec(RecNum : LongInt); virtual;
      Function    RecsInFile: Longint; virtual;
      Procedure   Replace; virtual;
   end;

   GSP_dBaseFld = ^GSO_dBaseFld;
   GSO_dBaseFld = object(GSO_dBaseDBF)
      WithMemo     : boolean;         {True if memo file present}
      FieldPtr     : GSP_DBFField;
      Constructor  Init(FName : string);
      Function     AnalyzeField(var fldst: string) : GSP_DBFField; virtual;
      Procedure    Blank; virtual;
      Function     CheckField(var st : string; ftyp : char) : GSP_DBFField;
      Function     DateGet(st : string) : longint; virtual;
      Function     DateGetN(n : Integer) : longint; virtual;
      Procedure    DatePut(st : string; jdte : longint); virtual;
      Procedure    DatePutN(n : Integer; jdte : longint); virtual;
      Procedure    Delete; virtual;
      Function     FieldGet(fnam : string) : string; virtual;
      Function     FieldGetN(fnum : Integer) : string; virtual;
      Procedure    FieldPut(fnam, st : string); virtual;
      Procedure    FieldPutN(fnum : Integer; st : string); virtual;
      Function     FieldDecimals(i : Integer) : Integer; virtual;
      Function     FieldLength(i : Integer) : Integer; virtual;
      Function     FieldName(i : Integer) : string; virtual;
      Function     FieldType(i : Integer) : char; virtual;
      Procedure    GetRec(RecNum: LongInt); virtual;
      Function     LogicGet(st : string) : boolean; virtual;
      Function     LogicGetN(n : Integer) : boolean; virtual;
      Procedure    LogicPut(st : string; b : boolean); virtual;
      Procedure    LogicPutN(n : Integer; b : boolean); virtual;
      Function     NumberGet(st : string) : FloatNum; virtual;
      Function     NumberGetN(n : Integer) : FloatNum; virtual;
      Procedure    NumberPut(st : string; r : FloatNum); virtual;
      Procedure    NumberPutN(n : Integer; r : FloatNum); virtual;
      Function     StringGet(fnam : string) : string; virtual;
      Function     StringGetN(fnum : Integer) : string; virtual;
      Procedure    StringPut(fnam, st : string); virtual;
      Procedure    StringPutN(fnum : Integer; st : string); virtual;
      Procedure    Undelete; virtual;
   end;


   GSP_DBFBuild = ^GSO_DBFBuild;
   GSO_DBFBuild = object(TCollection)
      dbTypeNoMo  : byte;
      dbTypeMemo  : byte;
      dFile       : GSP_DiskFile;
      mFile       : GSP_DiskFile;
      HeadRec     : GSR_DBFHeader;
      FileName    : string;
      hasMemo     : boolean;
      dbRecLen    : SmallInt;         {dbRecLen := RecordLen - it must be 16 bit}
      dbTitle     : {$IfnDef Os2} string[8] {$Else} string {$EndIf};
      Constructor Init(FName : string);
      Destructor  Done; virtual;
      Procedure   InsertField(s : string; t : char; l,d : Integer); virtual;
      Procedure   WriteDBF; virtual;
      Procedure   WriteDBT; virtual;
   end;

   GSP_DB3Build = ^GSO_DB3Build;
   GSO_DB3Build = GSO_DBFBuild;

   GSP_DB4Build = ^GSO_DB4Build;
   GSO_DB4Build = object(GSO_DBFBuild)
      Constructor Init(FName : string);
      Procedure   WriteDBT; virtual;
   end;

Procedure SetCentury(tf: boolean);
Procedure SetDateType(dt : DateCountry);
Procedure SetDeleted(tf: boolean);
Procedure SetExact(tf: boolean);


{------------------------------------------------------------------------------
                            IMPLEMENTATION SECTION
------------------------------------------------------------------------------}

implementation

const
   EohMark      : Byte = $0D;          {Byte stored at end of the header}
   AccessTries  : Word = 1000;         {Attempts to access file before stop}

{-----------------------------------------------------------------------------
                              Global Functions
-----------------------------------------------------------------------------}

PROCEDURE SetCentury(tf: boolean);
BEGIN
   GS_Date_Century := tf;
END;

Procedure SetDateType(dt : DateCountry);
BEGIN
   GS_Date_Type := dt;
END;

PROCEDURE SetDeleted(tf: boolean);
BEGIN
   UseDelRecord := not tf;
END;

PROCEDURE SetExact(tf: boolean);
BEGIN
   dbExactMatch := tf;
END;

{------------------------------------------------------------------------------
                                GSO_dBaseDBF
------------------------------------------------------------------------------}


CONSTRUCTOR GSO_dBaseDBF.Init(FName : string);
VAR
   fl : Integer;                   {field length working variable}

   Function ProcessHeader: boolean;
   BEGIN             {ProcessHeader}
      GSO_DiskFile.Read(0, HeadProlog, 32);
      CASE HeadProlog.DBType OF        {test for valid dBase types}
         DB3File,
         DB3WithMemo,
        {$IfnDef Os2}
         DB4File,                      {note that under Vp/2 this costruction is not valid as DB3File = DB4File!}
        {$EndIf}
         DB4WithMemo,
         FXPWithMemo : begin                            {Good File}
                          FileVers := HeadProlog.DBType;
                          HeadLen := HeadProlog.Location;  {length of header}
                          RecLen := HeadProlog.RecordLen;  {Length of record}
                       end;
         ELSE
         BEGIN
            FileVers := 0;       {If not a valid dBase file, stop}
            Error(gsBadDBFHeader,dbfInitError);
         END;
      END;                      {CASE}
      ProcessHeader := FileVers <> 0;
   END;                      {ProcessHeader}

begin
   GSO_DiskFile.Init(FName+DBExtension,dfReadWrite+dfSharedDenyNone);
   if dfFileExst then
   begin
      Reset(1);                       {File length of one byte}
      if not ProcessHeader then exit; {Load file structure information}
      NumRecs := RecsInFile;          {Get record counr}
      RecNumber := 0;                 {Set current record to zero}
      File_EOF := false;              {Set End of File flag to false}
      File_TOF := false;              {Set Top of File flag to false};
      fl := HeadLen-33;               {Size of field descriptors}
      GetMem(Fields, fl);             {Allocate memory for fields buffer.}
      NumFields := fl div 32;         {Number of fields}
      GSO_DiskFile.Read(-1, Fields^, fl);          {Store field data}
      GSO_DiskFile.Close;             {Finished with file for now}
      GetMem(CurRecord, RecLen+1);    {Allocate memory for record buffer}
      CurRecord^[RecLen] := EofMark;  {End of file flag after record}
      FileIsLocked := false;
      LockCount := 0;
      dStatus := NotOpen;             {Set file status to 'Not Open'   }
   end
   else
   begin
      dStatus := Invalid;
      Error(dosFileNotFound,dbfInitError);    {Error -- No such file}
      CurRecord := nil;
      Fields := nil;
   end;
end;

Destructor GSO_dBaseDBF.Done;
begin
   GSO_dBaseDBF.Close;              {Close the file before finishing up}
   if CurRecord <> nil then FreeMem(CurRecord, RecLen+1);
                                    {DeAllocate memory for record buffer}
   if Fields <> nil then FreeMem(Fields, HeadLen-33);
                                    {DeAllocate memory for fields buffer.}
   GSO_DiskFile.Done;
end;

PROCEDURE GSO_dBaseDBF.Append;
VAR
   icr : Word;
   b1A : Word;
   FSz : longint;
BEGIN
   icr := 0;
   if GS_AutoShare then
   begin
      repeat inc(icr) until LokApnd or (icr > AccessTries);  {Append Lock}
      if icr > AccessTries then
      begin                                    {If not successful....}
         Error(dosAccessDenied,dbfAppendError);
         exit;
      end;
   end;
   dStatus := Updated;             {Set file status to 'Updated'}

   FSz := FileSize;
   FSz := (FileSize-HeadLen);
   b1A := FSz mod RecLen;

   AddToFile(CurRecord^, RecLen+1, b1A);      {Append}
   LokOff;
   RecNumber := NumRecs+1;           {Store record number as current record }
   HdrWrite;
END;

PROCEDURE GSO_dBaseDBF.Close;
begin
   IF dStatus = NotOpen THEN exit;     {Exit if file not open}
   IF dStatus = Updated THEN HdrWrite; {Write new header information if the}
                                       {file was updated in any way}
   GSO_DiskFile.Close;                 {Go close file}
   dStatus := NotOpen;                 {Set objectname.dStatus to 'NotOpen'}
END;                        { GS_dBase_Close }

Procedure GSO_dBaseDBF.Flush;
var
   holdflush : dfFlushStatus;
begin
   holdflush := dfFileFlsh;        {turn off flush temporarily to avoid}
   dfFileFlsh := NeverFlush;       {an endless loop if WriteFlush, as the}
   HdrWrite;                       {header write would call Flush again}
   dfFileFlsh := holdflush;
   GSO_DiskFile.Flush;
end;

PROCEDURE GSO_dBaseDBF.GetRec(RecNum : LongInt);
VAR
   RNum   : LongInt;                  {Local working variable  }
BEGIN
   if NumRecs = 0 then
   begin
      File_EOF := true;
      File_TOF := true;
      exit;
   end;
   RNum := RecNum;                    {Store RecNum locally for modification}
   File_EOF := false;                 {Initialize End of File Flag to false}
   File_TOF := false;
   case RNum of
      Next_Record : RNum := RecNumber + 1;   {Advance one record}
      Prev_Record : begin
                       RNum := RecNumber - 1;   {Back up one record}
                       if RNum = 0 then
                       begin
                          RNum := 1;
                          File_TOF := true;
                          Exit;
                       end;
                    end;
      Top_Record  : RNum := 1;               {Set to the first record}
      Bttm_Record : begin
                       NumRecs := RecsInFile;   {Set to the last record}
                       RNum := NumRecs;
                    end;
      else
         if (RNum < 1) then
         begin
            Error(gsDBFRangeError,dbfGetRecError);
            exit;
         end
         else
         begin
            if (RNum > NumRecs) then
            begin
               NumRecs := RecsInFile;    {Confirm set to the last record}
               if (RNum > NumRecs) then  {Still out of range?}
               begin
                  File_EOF := true;
                  exit;
               end;
            end;
         end;
   end;
   Read(HeadLen+((RNum-1) * RecLen), CurRecord^, RecLen);
                                      {Read RecLen bytes into memory buffer}
                                      {for the correct physical record}
   if dfGoodRec < RecLen then
   begin
      File_EOF := true;
      exit;
   end;
   RecNumber := RNum;                 {Set objectname.RecNumber = this record }
   if CurRecord^[0] = GS_dBase_DltChr then DelFlag := true
      else DelFlag := false;
END;                  {GetRec}

Procedure GSO_dBaseDBF.HdrWrite;
var
   rsl : Word;
   icr : Word;
   yy, mm, dd, wd : Word;     {Local variables to get today's date}
begin
   if dfFileShrd and not FileIsLocked then
   begin
      icr := 0;
      repeat
         rsl := GS_LockFile(dfFileHndl,0,8);
         inc(icr);
      until (rsl = 0) or (icr > AccessTries);
      if rsl <>  0 then
      begin
         Error(dosAccessDenied, dbfHdrWriteError);
         exit;
      end;
   end;
   GetDate (yy,mm,dd,wd);          {Call TP's GetDate procedure}
   HeadProlog.year := yy-1900;     {Extract the Year}
   HeadProlog.month := mm;         {Extract the Month}
   HeadProlog.day := dd;           {Extract the Day}
   NumRecs := RecsInFile;
   HeadProlog.RecCount := NumRecs; {Update number records in file}
   Write(0, HeadProlog, 8);
   if dfFileShrd and not FileIsLocked then
      rsl := GS_UnLockFile(dfFileHndl,0,8);
   dStatus := NotUpdated;          {Reset updated status}
end;

Function GSO_dBaseDBF.LokApnd: boolean;
begin
   LokApnd := LokIt(FileSize+dfDirtyRead, RecLen+1);
end;

Function GSO_dBaseDBF.LokFile: boolean;
begin
   FileIsLocked := LokIt(dfDirtyRead, dfDirtyRead-1); {Lock all possible filesize}
   LokFile := FileIsLocked;
end;

Function GSO_dBaseDBF.LokIt(fposn,flgth: longint): boolean;
var
   rsl : Word;
begin
   if dfFileShrd then
   begin
      if not dfLockRec then LockCount := 0;
      if FileIsLocked then rsl := 0
         else rsl := LockRec(fposn,flgth);
      if rsl = 0 then inc(LockCount);
      LokIt := rsl = 0;
   end
   else LokIt := true;
end;

Function GSO_dBaseDBF.LokRcrd: boolean;
begin
   LokRcrd := LokIt((HeadLen+((RecNumber-1)*RecLen))+dfDirtyRead,RecLen);
end;

Procedure GSO_dBaseDBF.LokOff;
var
   rsl : Word;
begin
   if not dfLockRec then
   begin
      LockCount := 0;
      exit;
   end;
   dec(LockCount);
   if LockCount > 0 then exit;   {Could have stacked locks if programmer}
   rsl := Unlock;                {and automatic locking.  Only unlock   }
                                 {when stack cleared.                   }
   if (dfFileFlsh = UnlockFlush) then HdrWrite;
   FileIsLocked := false;
end;

PROCEDURE GSO_dBaseDBF.Open;
BEGIN              { GS_dBase_Open }
   if dStatus = NotOpen then          {Do only if file not already open}
   begin
      Reset(1);                       {Open .DBF file}
      dStatus := NotUpdated;          {Set status to 'Not Updated' }
      RecNumber := 0;                 {Set current record to zero }
      LockCount := 0;
   end;
END;               { GS_dBase_Open }

PROCEDURE GSO_dBaseDBF.PutRec(RecNum : LongInt);
VAR
   Result : Word;                     {Local Variable}
   RNum   : LongInt;                  {Local Variable}
   HNum   : Longint;
   icr    : Word;
BEGIN
   RNum := RecNum;
   IF (RNum > NumRecs) or (RNum < 1) then Append
   else
   begin
      HNum := RecNumber;
      RecNumber := RNum;
      icr := 0;
      if GS_AutoShare then
      begin
         repeat inc(icr) until LokRcrd or (icr > AccessTries);  {Record Lock}
         if icr > AccessTries then
         begin                                    {If not successful....}
            Error(dosAccessDenied,dbfPutRecError);
            RecNumber := HNum;
            exit;
         end;
      end;
      dStatus := Updated;            {Set file status to 'Updated'}
      Write(HeadLen+((RNum-1)*RecLen), CurRecord^, RecLen);
      LokOff;
   end;
END;                        {PutRec}

Function GSO_dBaseDBF.RecsInFile: Longint;
begin
   RecsInFile := (FileSize-HeadLen) div RecLen;
end;

Procedure GSO_dBaseDBF.Replace;
begin
   PutRec(RecNumber);
end;

{------------------------------------------------------------------------------
                          GSO_dBaseFld Working Routines
------------------------------------------------------------------------------}

Function FieldLocate(fdsc: GSP_FieldArray; st: string; var i: Integer):boolean;
var
   mtch : boolean;
   ix   : Integer;
   za   : string[16];
begin
   st := TrimR(AllCaps(st));
   ix := i;
   i := 1;
   mtch := false;
   while (i <= ix) and not mtch do
   begin
      CnvAscToStr(GSR_DBFField(fdsc^[i]).FieldName,za,11);
      if za = st then mtch := true else inc(i);
   end;
   FieldLocate := mtch;
end;

Function FieldPull(fr: GSP_DBFField) : string;
var
   s : string;
begin
   with fr^ do
   begin
      move(FieldAddress^,s[1], FieldLen);
      s[0] := chr(FieldLen);
      FieldPull := s;
   end;
end;

Procedure FieldPush(fr: GSP_DBFField; st : string);
begin
   with fr^ do
   begin
      if FieldType in ['C','L','D'] then st := PadR(st,FieldLen)
         else st := PadL(st,FieldLen);
      move(st[1],FieldAddress^,FieldLen);
   end;
end;

Function StringPull(fr: GSP_DBFField) : string;
var
   s : string;
   d : longint;
begin
   with fr^ do
   begin
      move(FieldAddress^,s[1],FieldLen);
      s[0] := chr(FieldLen);
      s := TrimR(s);
      case FieldType of
         'D' : begin
                  d := ValDate(s);
                  if d > 0 then s := StrDate(d)
                  else
                  begin
                     s :=  '00/00/00';
                     if GS_Date_Century then s := s + '00';
                  end;
               end;
         'L' : s := StrLogic(ValLogic(s));
         'M' : begin
                  s := TrimL(s);
                  if s > '0' then  s := '---MEMO---' else s := '---memo---';
               end;
         'F',
         'N' : s := TrimL(s);
      end;
   end;
   StringPull := s;
end;

Procedure StringPush(fr: GSP_DBFField; st : string);
var
   d : longint;
begin
   if fr^.FieldType = 'D' then
      st := GS_Date_dBStor(GS_Date_Juln(st));
   FieldPush(fr, st);
end;

{------------------------------------------------------------------------------
                                GSO_dBaseFld
------------------------------------------------------------------------------}

constructor GSO_dBaseFld.Init(FName : string);
var
   i   : Integer;
   offset : Integer;
begin
   GSO_dBaseDBF.Init(FName);
   offset := 1;
   for i := 1 to NumFields do
   begin
      Fields^[i].FieldNum := i;
      Fields^[i].FieldAddress := @CurRecord^[offset];
      offset := offset + Fields^[i].FieldLen;
   end;
   Case FileVers of
      DB3WithMemo,
      DB4WithMemo,
      FXPWithMemo : WithMemo := true;
      else WithMemo := false;
   end;
   DelFlag := false;
end;

function GSO_dBaseFld.AnalyzeField(var fldst : string) : GSP_DBFField;
var
LastFieldCk : Integer;
begin
   LastFieldCk := NumFields;
   if FieldLocate(Fields,fldst,LastFieldCk) then
      AnalyzeField := @Fields^[LastFieldCk]
   else
      AnalyzeField := nil;
end;

procedure GSO_dBaseFld.Blank;
begin
   FillChar(CurRecord^[0], RecLen, ' '); {Fill spaces for RecLen bytes}
end;

function  GSO_dBaseFld.CheckField(var st: string; ftyp: char): GSP_DBFField;
var
   FPtr : GSP_DBFField;
begin
   FPtr := AnalyzeField(st);
   if FPtr = nil then
      Error(gsInvalidField,dbfCheckFieldError)
   else if FPtr^.FieldType <> ftyp then
      Error(gsBadFieldType,dbfCheckFieldError);
   CheckField := FPtr;
end;

function  GSO_dBaseFld.DateGet(st : string) : longint;
var
   v : longint;
begin
   FieldPtr := CheckField(st,'D');
   v := 0;
   if (FieldPtr <> nil) then
      v := ValDate(FieldPull(FieldPtr));
   DateGet := v;
end;

function  GSO_dBaseFld.DateGetN(n : Integer) : longint;
var
   v : longint;
begin
   if (n > NumFields) or (n < 1) then v := 0
   else
   begin
      FieldPtr := @Fields^[n];
      v := ValDate(FieldPull(FieldPtr));
   end;
   DateGetN := v;
end;

Procedure GSO_dBaseFld.DatePut(st : string; jdte : longint);
begin
   FieldPtr := CheckField(st,'D');
   if (FieldPtr <> nil) then
       FieldPush(FieldPtr,GS_Date_dBStor(jdte));
end;

Procedure GSO_dBaseFld.DatePutN(n : Integer; jdte : longint);
begin
   if (n > NumFields) or (n < 1) then exit;
   FieldPtr := @Fields^[n];
   FieldPush(FieldPtr,GS_Date_dBStor(jdte));
end;

Procedure GSO_dBaseFld.Delete;
begin
   DelFlag := true;                   {Set Delete Flag to true}
   CurRecord^[0] := GS_dBase_DltChr;  {Put '*' in first byte of current record}
   GSO_dBaseDBF.PutRec(RecNumber);    {Write the current record to disk }
end;                 {GS_dBase_Delete}

Function GSO_dBaseFld.FieldGet(fnam : string) : string;
begin
   FieldPtr := AnalyzeField(fnam);
   if (FieldPtr <> nil)  then
      FieldGet := FieldPull(FieldPtr)
         else FieldGet := '';
end;

Function GSO_dBaseFld.FieldGetN(fnum : Integer) : string;
begin
   if (fnum > NumFields) or (fnum < 1) then
   begin
      FieldGetN := '';
      exit;
   end;
   FieldPtr := @Fields^[fnum];
   FieldGetN := FieldPull(FieldPtr);
end;

Procedure GSO_dBaseFld.FieldPut(fnam, st : string);
begin
   FieldPtr := AnalyzeField(fnam);
   if (FieldPtr <> nil)  then
      FieldPush(FieldPtr,st);
end;

Procedure GSO_dBaseFld.FieldPutN(fnum : Integer; st : string);
begin
   if (fnum > NumFields) or (fnum < 1) then exit;
   FieldPtr := @Fields^[fnum];
   FieldPush(FieldPtr,st);
end;

function GSO_dBaseFld.FieldDecimals(i : Integer) : Integer;
begin
   if (i > NumFields) or (i < 1) then
   begin
      FieldDecimals := 0;
      exit;
   end;
   FieldPtr := @Fields^[i];
   FieldDecimals := FieldPtr^.FieldDec;
end;

function GSO_dBaseFld.FieldLength(i : Integer) : Integer;
begin
   if (i > NumFields) or (i < 1) then
   begin
      FieldLength := 0;
      exit;
   end;
   FieldPtr := @Fields^[i];
   FieldLength := FieldPtr^.FieldLen;
end;

function GSO_dBaseFld.FieldName(i : Integer) : string;
var
   st : string[16];
   p  : Integer;
begin
   if (i > NumFields) or (i < 1) then
   begin
      FieldName := '';
      exit;
   end;
   FieldPtr := @Fields^[i];
   move(FieldPtr^.FieldName,st[1],10);
   st[0] := #10;
   p := pos(#0,st);
   if p > 0 then st[0] := chr(p-1);
   FieldName := st;
end;

function GSO_dBaseFld.FieldType(i : Integer) : char;
begin
   if (i > NumFields) or (i < 1) then
   begin
      FieldType := #0;
      exit;
   end;
   FieldPtr := @Fields^[i];
   FieldType := FieldPtr^.FieldType;
end;

PROCEDURE GSO_dBaseFld.GetRec(RecNum : LongInt);
VAR
   RNum   : LongInt;                  {Local working variable  }
BEGIN
   GSO_dBaseDBF.GetRec(RecNum);
   if RecNum > 0 then exit;     {done if physical record access}
   if DelFlag and (not UseDelRecord) then
   begin
      RNum := RecNumber;
      while DelFlag and (not (File_EOF or File_TOF)) do
      begin
         case RecNum of
            Top_Record,
            Next_Record : inc(RNum);
            Bttm_Record,
            Prev_Record : dec(RNum);
         end;
         if RNum < 1 then File_TOF := true
            else if RNum > NumRecs then File_EOF := true
               else GSO_dBaseDBF.GetRec(RNum);
      end;
   end;
end;

function  GSO_dBaseFld.LogicGet(st : string) : boolean;
var
   v : boolean;
begin
   FieldPtr := CheckField(st,'L');
   v := false;
   if (FieldPtr <> nil) then
      v := ValLogic(FieldPull(FieldPtr));
   LogicGet := v;
end;

function  GSO_dBaseFld.LogicGetN(n : Integer) : boolean;
var
   v : boolean;
begin
   if (n > NumFields) or (n < 1) then v := false
   else
   begin
      FieldPtr := @Fields^[n];
      v := ValLogic(FieldPull(FieldPtr));
   end;
   LogicGetN := v;
end;

Procedure GSO_dBaseFld.LogicPut(st : string; b : boolean);
begin
   FieldPtr := CheckField(st,'L');
   if (FieldPtr <> nil)  then
      FieldPush(FieldPtr,StrLogic(b));
end;

Procedure GSO_dBaseFld.LogicPutN(n : Integer; b : boolean);
begin
   if (n > NumFields) or (n < 1) then exit;
   FieldPtr := @Fields^[n];
   FieldPush(FieldPtr,StrLogic(b));
end;

function GSO_dBaseFld.NumberGet(st : string) : FloatNum;
var
   v : FloatNum;
begin
   FieldPtr := CheckField(st,'N');
   v := 0;
   if (FieldPtr <> nil) then
      v := ValNumber(FieldPull(FieldPtr));
   NumberGet := v;
end;

function  GSO_dBaseFld.NumberGetN(n : Integer) : FloatNum;
var
   v : FloatNum;
begin
   if (n > NumFields) or (n < 1) then v := 0
   else
   begin
      FieldPtr := @Fields^[n];
      v := ValNumber(FieldPull(FieldPtr));
   end;
   NumberGetN := v;
end;

Procedure GSO_dBaseFld.NumberPut(st : string; r : FloatNum);
begin
   FieldPtr := CheckField(st,'N');
   if (FieldPtr <> nil)  then
      FieldPush(FieldPtr,StrNumber(r,FieldPtr^.FieldLen,FieldPtr^.FieldDec));
end;

Procedure GSO_dBaseFld.NumberPutN(n : Integer; r : FloatNum);
begin
   if (n > NumFields) or (n < 1) then exit;
   FieldPtr := @Fields^[n];
   FieldPush(FieldPtr,StrNumber(r,FieldPtr^.FieldLen,FieldPtr^.FieldDec));
end;

Function GSO_dBaseFld.StringGet(fnam : string) : string;
begin
   FieldPtr := AnalyzeField(fnam);
   if (FieldPtr <> nil)  then
      StringGet := StringPull(FieldPtr)
         else StringGet := '';
end;

Function GSO_dBaseFld.StringGetN(fnum : Integer) : string;
begin
   if (fnum > NumFields) or (fnum < 1) then
   begin
      StringGetN := '';
      exit;
   end;
   FieldPtr := @Fields^[fnum];
   StringGetN := StringPull(FieldPtr);
end;

Procedure GSO_dBaseFld.StringPut(fnam, st : string);
begin
   FieldPtr := AnalyzeField(fnam);
   if (FieldPtr <> nil)  then
      StringPush(FieldPtr,st);
end;

Procedure GSO_dBaseFld.StringPutN(fnum : Integer; st : string);
begin
   if (fnum > NumFields) or (fnum < 1) then exit;
   FieldPtr := @Fields^[fnum];
   StringPush(FieldPtr,st);
end;

Procedure GSO_dBaseFld.UnDelete;
begin
   DelFlag := false;                   {Set Delete flag to false}
   CurRecord^[0] := GS_dBase_UnDltChr; {Put ' ' in first byte of current record}
   GSO_dBaseDBF.PutRec(RecNumber);     {Write the current record to disk }
end;

{-----------------------------------------------------------------------------
                            GSO_DBFBuild
-----------------------------------------------------------------------------}

Constructor GSO_DBFBuild.Init(FName : string);
{var i,j : Integer;}
begin
   TCollection.Init(32,32);
   hasMemo := false;
   dbTypeNoMo := DB3File;
   dbTypeMemo := DB3WithMemo;
   Filename := AllCaps(FName);
   dbRecLen := 1;
   {i := length(FileName);
   j := i;
   while (i > 0) and not (FileName[i] in ['\',':']) do
   begin
      if FileName[i] = '.' then j := i-1;
      i := i-1;
   end;
   i := i+1;
   dbTitle := copy(FileName,i,(j-i)+1);}
   dbTitle := getFileName(FileName);
end;

Destructor GSO_DBFBuild.Done;
var
   i : Integer;
   f : GSP_DBFField;
begin
   dFile := New(GSP_DiskFile, Init(FileName+DBExtension,dfReadWrite));
   dFile^.Rewrite(1);
   WriteDBF;
   Dispose(dFile, Done);
   if HasMemo then WriteDBT;
   for i := 0 to Count-1 do
   begin
      f := at(i);
      dispose(f);
   end;
   DeleteAll;
   TCollection.Done;
end;

procedure GSO_DBFBuild.InsertField(s : string; t : char; l,d : Integer);
var
   f : GSP_DBFField;
begin
   New(f);
   s := AllCaps(s);
   CnvStrToAsc(s,f^.FieldName,11);
   f^.FieldType := upcase(t);
   case f^.FieldType of
      'D' : begin
               l := 8;
               d := 0;
            end;
      'L' : begin
               l := 1;
               d := 0;
            end;
      'M' : begin
               l := 10;
               d := 0;
               hasMemo := true;
            end;
   end;
   f^.FieldLen := l;
   f^.FieldDec := d;
   f^.FieldAddress := nil;
   f^.FieldNum := 0;
   FillChar(f^.Reserved,12,#0);
   if f^.FieldType = 'M' then hasMemo := true;
   dbRecLen := dbRecLen + l;
   Insert(f);
end;

Procedure GSO_DBFBuild.WriteDBF;
var
   i : Integer;
   yy, mm, dd, wd : Word;             {Variables to hold GetDate values}

BEGIN
   if hasMemo then HeadRec.DBType := dbTypeMemo
      else HeadRec.DBType := dbTypeNoMo;
   GetDate (yy,mm,dd,wd);
   HeadRec.year := yy-1900; {Year}
   HeadRec.month := mm; {Month}
   HeadRec.day := dd; {Day}
   HeadRec.RecCount := 0;
   HeadRec.Location := (Count*32) + 33;
   HeadRec.RecordLen := dbRecLen;
   FillChar(HeadRec.Reserved,20,#0);
   dFile^.Write(0, HeadRec, 32);
   for i := 0 to Count-1 do
      dFile^.Write(-1, Items^[i]^, 32);
   dFile^.Write(-1, EohMark, 1);            {Put EOH marker }
   dFile^.Write(-1, EofMark, 1);            {Put EOF marker }
END;

Procedure GSO_DBFBuild.WriteDBT;
var
   buf : array[0..31] of byte;
   i : Integer;
begin
   FillChar(buf,32,#0);
   buf[0] := $01;
  {$IfDef Os2}
    if SizeOf(dbTitle) > 8 then Error(dbfLongNameMemo,dbfLongNameMemo);
  {$EndIf}
   mFile := New(GSP_DiskFile, Init(FileName+'.DBT',dfReadWrite));
   mFile^.Rewrite(1);
   mFile^.Write(0, buf, 32);
   FillChar(buf,32,#0);
   for i := 1 to 15 do mFile^.Write(-1, buf, 32);
   mFile^.Write(-1, EofMark, 1);
   Dispose(mFile, Done);
end;

{-----------------------------------------------------------------------------
                                GSO_DB4Build
-----------------------------------------------------------------------------}

Constructor GSO_DB4Build.Init(FName : string);
begin
   GSO_DBFBuild.Init(FName);
   dbTypeNoMo := DB4File;
   dbTypeMemo := DB4WithMemo;
end;

Procedure GSO_DB4Build.WriteDBT;
var
   buf : array[0..31] of byte;
begin
   FillChar(buf,32,#0);
   buf[0] := $01;
  {$IfDef Os2}
    if SizeOf(dbTitle) > 8 then Error(dbfLongNameMemo,dbfLongNameMemo);
  {$EndIf}
   move(dbTitle[1],buf[8],length(dbTitle));
   buf[18] := $02;
   buf[19] := $01;
   buf[21] := $02;
   mFile := New(GSP_DiskFile, Init(FileName+'.DBT',dfReadWrite));
   mFile^.Rewrite(1);
   mFile^.Write(0, buf, 24);
   Dispose(mFile, Done);
end;


end.
{-----------------------------------------------------------------------------}
                                      END
