Unit GSOB_Dsk;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                               Disk File Handler

           GSOB_DSK (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       This unit handles the objects for all untyped disk file I/O.

       Note: please refer to original Halcyon Code for other
             informations about Dos functions.

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

{$IfnDef Os2} {Cannot be Overlayed!!!}
 {$O-,V-}
{$EndIf}

interface
uses Use32,
     GSOB_Var,
    {$IfDef Os2}
      Os2Def,
      Os2Base,
    {$EndIf}
    {$IFDEF WINDOWS}
      WinDOS,
      WinProcs,
      Objects,
      Strings;
    {$ELSE}
      DOS,
      GSOB_Obj;
    {$ENDIF}

const

   {File Modes (including sharing)}

   {$IfnDef Os2}
    dfReadOnly        = 0;
    dfWriteOnly       = 1;
    dfReadWrite       = 2;
    dfSharedDenyAll   = 16;
    dfSharedDenyWrite = 32;
    dfSharedDenyRead  = 48;
    dfSharedDenyNone  = 64;

    dfDirtyRead : longint = $40000000;

   {$Else}

    dfReadOnly        = open_access_readOnly;
    dfWriteOnly       = open_access_writeOnly;
    dfReadWrite       = open_access_ReadWrite;

    dfSharedDenyAll   = open_share_denyReadWrite;
    dfSharedDenyWrite = open_share_denyWrite;
    dfSharedDenyRead  = open_share_denyRead;
    dfSharedDenyNone  = open_share_denyNone;

    dfDirtyRead : longint = $40000000;
   {$EndIF}

type

   {$IFNDEF WINDOWS}
      TFileRec    = FileRec;
     {$IfnDef Os2}
      TRegisters  = Registers;
     {$EndIf}
      TSearchRec  = SearchRec;
      TDateTime   = DateTime;
   {$ENDIF}

   dfFlushStatus = (NeverFlush,WriteFlush,AppendFlush,UnLockFlush);

   GSP_DiskFile = ^GSO_DiskFile;
   GSO_DiskFile = Object(TObject)
      dfFileHndl : Word;
      dfFileErr  : Word;       {I/O error code}
      dfFileExst : boolean;    {True if file exists}
      dfFileName : string[80];
      dfFilePosn : longint;
      dfFileRSiz : Word;
      dfFileShrd : boolean;
      dfFileMode : byte;
      dfFileType : file;
      dfFileInfo : TSearchRec;
      dfFileFlsh : dfFlushStatus;
      dfGoodRec  : Word;
      dfLockRec  : Boolean;
      dfLockPos  : Longint;
      dfLockLth  : Longint;

      Constructor  Init(Fname : string; Fmode : byte);
      destructor   Done; virtual;
      Procedure    AddtoFile(var dat; len, StepBack : Word); virtual;
      Procedure    Assign(FName : string); virtual;
      Procedure    Close; virtual;
      Procedure    Erase; virtual;
      Procedure    Error(Code, Info : Integer); virtual;
      Function     FileSize : longint; virtual;
      Procedure    Flush; virtual;
      Function     LockFile : Word; virtual;
      Function     LockRec(FilePosition,FileLength : Longint) : Word; virtual;
      Procedure    Read(blk : longint; var dat; len : Word); virtual;
      Procedure    Rename(Fname : string); virtual;
      Procedure    Reset(len : Word); virtual;
      Procedure    ReWrite(len : Word); virtual;
      Procedure    SetFlushCondition(Condition : dfFlushStatus); virtual;
      Procedure    Truncate(loc : longint); virtual;
      Function     UnLock : Word; virtual;
      Procedure    Write(blk : longint; var dat; len : Word); virtual;
   end;

Var FindFileInfo : TSearchRec;

Function Temp_File : string;                       {Internal use only}
Function getFSize(FName:string): longint;
Function FileSplit(Part:byte;Full:string): string; {Internal use only}
Function getFileDrive(Full:string): string;
Function getFileDirectory(Full:string): string;
Function getFileName(Full:string): string;
Function getFileExt(Full:string): string;

Procedure GS_ClearLocks;
Function  GS_ExtendHandles(HndlCount : byte) : boolean;
Procedure GS_FileDateTime(var f: file; var Year,Month,Day,Hour,Min,Sec: Word);
Function  GS_FileExists(Fname : string) : boolean;
Function  GS_FileIsOpen(fnam : string): boolean;
Function  GS_Flush(Hndl : Word): Word;
Function  GS_LockFile(Hndl : Word; FilePosition,FileLength : LongInt) : Word;
Function  GS_RetryFile(Wait,Retry : Word) : Word;
Function  GS_UnLockFile(Hndl : Word; FilePosition,FileLength : LongInt) : Word;
Function  GS_ShareAllowed : boolean;
Procedure GS_ShareAuto(tf : boolean);
Function  GS_AutoShare : boolean;
Function  GS_Exclusive : boolean;
Procedure GS_SetExclusive(tf : boolean);
{------------------------------------------------------------------------------
                            IMPLEMENTATION SECTION
------------------------------------------------------------------------------}

implementation

const
   RetriesChgd   : boolean = false;
   AutomaticShare: boolean = false;
   ShareChecked  : boolean = false;
   ShareAllowed  : boolean = false;
   UseExclusive  : boolean = true;
   HandlesExtnd  : boolean = false;

var
   istrue        : boolean;
   ExitSave      : pointer;
   ObjtLog       : TCollection;

   NewHandleTable: array[0..255] of byte;   { New table for handles }
   OldHandleTable: pointer;                 { Pointer to original table }
   OldNumHandles : byte;                    { Original number of handles }


{------------------------------------------------------------------------------
                            Internal Functions
------------------------------------------------------------------------------}

{$IfnDef Os2}  { Used only under Dos }
function HiLong(Long : LongInt) : Word;
{ This inline directive is similar to Turbo's Hi() function, except }
{ it returns the high word of a LongInt                             }
  Inline(
    $5A/       {pop      dx    ; low word of long}
    $58);      {pop      ax    ; hi word of long }

function LowLong(Long : LongInt) : Word;
{ This inline directive is similar to Turbo's Lo() function, except }
{ it returns the Low word of a LongInt                              }
  Inline(
    $5A/       {pop      dx    ; low word of long}
    $58/       {pop      ax    ; hi word of long}
    $89/$D0);  {mov      ax,dx ; return lo word as function result in Ax}
{$EndIF}

function Temp_File : string;
var
   h, mn, s, hund : Word;
   hundchk        : Word;
   LS             : string;
begin
   GetTime(h,mn,s,hund);           {Call TP 5.5 procedure for current time}
   hundchk := hund;                {GetTime(Hour, Minute, Second, Sec100) }
   repeat
      GetTime(h,mn,s,hund);        {Call TP 5.5 procedure for current time}
   until hundchk <> hund;          {Ensures always a unique time}
   LS := 'GS'+chr((mn div 10)+65)+chr((mn mod 10)+65);
   LS := LS+chr((s div 10)+65)+chr((s mod 10)+65);
   LS := LS+chr((hund div 10)+65)+chr((hund mod 10)+65);
   LS := LS+'.$$$';
   Temp_File := LS;                {Return the unique field}
 end;

function getFSize(Fname:string): longint; {returns  -1   if file not found}
var F : file of byte;
begin
    Assign(F,Fname);
    {$I-}
    Reset(F);
    {$I+}
    if IOResult <> 0 then
    begin
       getFSize := -1;
       exit;
    end;
    getFSize := FileSize(F);
    Close(F);
end; {FSize}

function FileSplit(Part:byte;Full:string): string; {used internally}
var D : DirStr;
    N : NameStr;
    E : ExtStr;
begin
   FSplit(Full,D,N,E);
   Case Part of
   1 : FileSplit := D;
   2 : FileSplit := N;
   3 : FileSplit := E;
   end;
end; {FileSplit}

function getFileDrive(Full:string): string;
var Temp : string;
    P : byte;
begin
   Temp := FileSplit(1,Full);
   P := Pos(':',Temp);
   if P <> 2 then
      getFileDrive := ''
   else
      getFileDrive := upcase(Temp[1]);
end; {FileDrive}

function getFileDirectory(Full:string): string;
var Temp : string;
    P    : byte;
begin
   Temp := FileSplit(1,Full);
   P := Pos(':',Temp);
   if P = 2 then
      Delete(Temp,1,2);                 {remove drive}
   if (Temp[length(Temp)]  ='\') and (temp <> '\') then
      Delete(temp,length(Temp),1);      {remove last backslash}
   getFileDirectory := Temp;
end; {FileDirectory}

function getFileName(Full:string): string;
begin getFileName := FileSplit(2,Full);
end; {FileName}

function getFileExt(Full:string): string;
var Temp : string;
begin
   Temp := FileSplit(3,Full);
   if (Temp = '') or (Temp = '.') then getFileExt := temp
   else
     {$IfDef Os2}
      getFileExt := copy(Temp,2,length(Temp));
     {$Else}
      getFileExt := copy(Temp,2,3);
     {$EndIf}
end; {FileExt}

{------------------------------------------------------------------------------
                              Global Routines
------------------------------------------------------------------------------}

Function FileNameIs(hdl: Word): string ;
var
   i    : Integer;
   rslt : Word;
   optr : GSP_DiskFile;
begin
   if ObjtLog.Count > 0 then
   begin
      FileNameIs := '';
      for i := 0 to ObjtLog.Count-1 do
      begin
         optr :=  ObjtLog.Items^[i];
         if optr^.dfFileHndl = hdl then
            FileNameIs := optr^.dfFileName;
      end;
   end
   else FileNameIs := '';
end;



Procedure GS_ClearLocks;
var
   i    : Integer;
   rslt : Word;
   optr : GSP_DiskFile;
begin
   if ObjtLog.Count > 0 then
   begin
      for i := 0 to ObjtLog.Count-1 do
      begin
         optr :=  ObjtLog.Items^[i];
         with optr^ do
            if dfLockRec then
               rslt := GS_UnLockFile(dfFileHndl,dfLockPos,dfLockLth);
      end;
   end;
end;

Function GS_Exclusive : boolean;
begin
   if not ShareChecked then
      UseExclusive := not GS_ShareAllowed;
   GS_Exclusive := UseExclusive;
end;

Function GS_ExtendHandles(HndlCount : byte) : boolean;
var {$IfnDef Os2}
     reg    : TRegisters;
     hcnt   : word;
     pfxcnt : pointer;
     pfxtbl : pointer;
    {$Else}
     hcnt   : apiret;
    {$EndIf}
begin
   GS_ExtendHandles := false;
   if HandlesExtnd then exit;
   if HndlCount <= 20 then exit;
  {$IfnDef Os2}
   if lo(DosVersion) = 2 then exit;       { Can't handle DOS Ver 2}
  {$EndIf}
{$IFDEF WINDOWS}
   hcnt := SetHandleCount(HndlCount);
{$ELSE}
{$IfDef Os2}
   hcnt := DosSetMaxFH(HndlCount);
{$Else}
{$IFDEF DPMI}
   Reg.BX := HndlCount;
   Reg.AH := $67;
   Reg.Ds := 0;
   Reg.Es := 0;
   MsDos(Reg);
{$ELSE}
   fillchar(NewHandleTable,sizeof(NewHandleTable),$FF);
                                          { Initialize new handles as unused }
   pfxcnt := Ptr(PrefixSeg, $0032);
   pfxtbl := Ptr(PrefixSeg, $0034);

   OldNumHandles := byte(pfxcnt^);        { Get old table length }
   OldHandleTable := pointer(pfxtbl^);
                                          { Save address of old table }
   byte(pfxcnt^) := HndlCount;            { Set new table length }
   pointer(Pfxtbl^) := Addr(NewHandleTable);
                                          { Point to new handle table }
   move(OldHandleTable^,NewHandleTable,OldNumHandles);
            { Copy the current handle table to the new handle table }
{$ENDIF}
{$ENDIF}
{$EndIF}
  {$IfDef Os2}
   if hcnt = NO_Error then begin
  {$EndIF}
   HandlesExtnd := true;
   GS_ExtendHandles := true;
  {$IfDef Os2}
   end else HandlesExtnd := true; {if hcnt...}
  {$EndIF}
end;

Procedure GS_FileDateTime(var f: file; var Year,Month,Day,Hour,Min,Sec: Word);
var dt    : DateTime;
    ftime : longint;
begin
   GetFTime(f,ftime); { Get creation time }
   UnpackTime(ftime,dt);
   Year  := dt.Year;
   Month := dt.Month;
   Day   := dt.Day;
   Hour  := dt.Hour;
   Min   := dt.Min;
   Sec   := dt.Sec;
end;

{$IFDEF WINDOWS}
Function  GS_FileExists(Fname : string) : boolean;
var
   NulEnd : array[0..80] of byte;
   pNulEnd : PChar;
begin
   if (FName <> '') then
   begin
      pNulEnd := @NulEnd;
      pNulEnd := StrPCopy(pNulEnd, FName);
      FindFirst(pNulEnd, $27, FindFileInfo);
      if DosError = 0 then
         GS_FileExists := true
      else
      begin
         GS_FileExists := false;
         FillChar(FindFileInfo,SizeOf(FindFileInfo),#0);
      end;
   end
   else
   begin
      GS_FileExists := false;
      FillChar(FindFileInfo,SizeOf(FindFileInfo),#0);
   end;
end;
{$ELSE}
Function  GS_FileExists(Fname : string) : boolean;
begin
   if (FName <> '') then
   begin
      FindFirst(FName, $27, FindFileInfo);
      if DosError = 0 then
         GS_FileExists := true
      else
      begin
         GS_FileExists := false;
         FillChar(FindFileInfo,SizeOf(FindFileInfo),#0);
      end;
   end
   else
   begin
      GS_FileExists := false;
      FillChar(FindFileInfo,SizeOf(FindFileInfo),#0);
   end;
end;
{$ENDIF}

Function GS_FileIsOpen(fnam : string): boolean;
var
   fmode : byte;
   frslt : Word;
   filx  : file;
   fopn  : boolean;
begin
   fmode := FileMode;
   FileMode := 18;
   System.Assign(filx, fnam);
   frslt := IOResult;               {Clear IOResult}
   {$I-}  System.Reset(filx); {$I+}
   frslt := IOResult;
   if frslt = 0 then System.Close(filx);
   if frslt = 2 then frslt := 0;
   fopn := frslt <> 0;
   FileMode := fmode;
   GS_FileIsOpen := fopn;
end;


Function GS_Flush(Hndl : Word): Word;
{$IfDef Os2}
 {$IfDef LSXPWR} {LsxPower support}
 // a Matt Yourst' suggested correction for LsxPower Support!
 var rc             : ApiRet; // API return code
 begin
  rc := DosResetBuffer(Hndl);
  case rc of
   NO_ERROR             : GS_Flush := 0;
   ERROR_FILE_NOT_FOUND : GS_Flush := 1;
   ERROR_ACCESS_DENIED  : GS_Flush := 2;
   ERROR_INVALID_HANDLE : GS_Flush := 3;
  end; {case}
  if rc <> NO_ERROR then exit;
 end;
 {$else}
var ReadHandle     : hFile;  // Read handle of pipe
    WriteHandle    : hFile;  // Write handle of pipe
    PipeSize       : ULong;  // Size of pipe
    rc             : ApiRet; // API return code
begin
    PipeSize       := 42;
    // Create a new PIPE for handler...
    rc := DosCreatePipe(ReadHandle, WriteHandle, PipeSize);
    if rc <> No_Error then
    begin
     GS_Flush := rc; {DosCreatePipe error}
     exit;
    end;
    // Duplicate handle for file
    rc := DosDupHandle(Hndl,WriteHandle);
    if rc <> NO_ERROR then begin
     GS_Flush := 1;
     exit;
    end; {If rc...}
    // Closes pipe & handles
    rc := DosClose(ReadHandle); {uninteresting result}
    rc := DosClose(WriteHandle);
 case rc of
  NO_ERROR             : GS_Flush := 0;
  ERROR_FILE_NOT_FOUND : GS_Flush := 1;
  ERROR_ACCESS_DENIED  : GS_Flush := 2;
  ERROR_INVALID_HANDLE : GS_Flush := 3;
 end; {case}
 if rc <> NO_ERROR then exit;
end;
 {$EndIf} {Os/2 & LsxPower Support}
{$Else} {dos file flusher}
var Reg  : TRegisters;
begin
  Reg.AH := $45;             {DOS function to duplicate a file handle}
  Reg.BX := Hndl;
  Reg.Ds := 0;
  Reg.Es := 0;
  MsDos(Reg);
  if Odd(Reg.Flags) then     {Check if carry flag is set}
    begin
      GS_Flush := 1;
      exit;
    end;
  Reg.BX := Reg.AX;          {Put new file handle into BX}
  Reg.AH := $3E;             {Dos function to close a file handle}
  Reg.Ds := 0;
  Reg.Es := 0;
  MsDos(Reg);
  if Odd(Reg.Flags) then     {Check if carry flag is set}
    begin
       GS_Flush := 2;
       exit;
    end;
   GS_Flush := 0;
end;
{$EndIf}

Function GS_LockFile(Hndl : Word; FilePosition,FileLength : LongInt) : Word;
var
 {$IfDef Os2}
  Rc                   : apiret;
  LockArea, UnlockArea : FileLock;
 {$Else}
  Reg : TRegisters;
  H,L : Word;
  rsl : Word;
 {$EndIF}
begin
   if UseExclusive then
   begin
      if ShareAllowed then GS_LockFile := 0
         else GS_LockFile := 1;
      exit;
   end;
  {$IfDef Os2}
   FillChar(LockArea,SizeOf(LockArea),0);
   FillChar(UnLockArea,SizeOf(UnLockArea),0);
   with LockArea do begin {Set lock area from FilePosition to FileLength}
     lOffset := FilePosition;
     lRange  := FileLength;
    end; {with}
   Rc := DosSetFileLocks(Hndl,UnLockArea,LockArea,2000,0); {2 seconds to wait, Exclusive Lock (no atomic)}
   {DosSetFileLocks returns one of the following values:
     0         No_Error
     1         Error_Invalid_Function
     6         Error_Invalid_Handle
     33        Error_Lock_Violation
     36        Error_Sharing_Buffer_Exceeded
     87        Error_Invalid_Parameter
     95        Error_Interrupt
     174       Error_Atomic_Lock_Not_Supported
     175       Error_Read_Locks_Not_Supported             }
   GS_LockFile := Rc;
  {$Else}
   with Reg do begin
      Ax := $5C00; {DOS call 5Ch}
      Bx := Hndl;
      Cx := HiLong(FilePosition);
      Dx := LowLong(FilePosition);
      Si := HiLong(FileLength);
      Di := LowLong(FileLength);
      Ds := 0;
      Es := 0;
      MsDos(Reg);
      if Odd(Reg.Flags) then     {Check if carry flag is set}
         rsl := Ax
      else
         rsl := 0;
   end;
   GS_LockFile := rsl;
  {$EndIf}
end;

Function GS_RetryFile(Wait,Retry : Word) : Word;
var
 {$IfDef Os2}
  W,R : Word;
 {$Else}
  Reg : TRegisters;
 {$EndIF}
begin
   if UseExclusive then
   begin
      if ShareAllowed then GS_RetryFile := 0
         else GS_RetryFile := 1;
      exit;
   end;
  {$IfDef Os2}
   for R := 1 to Retry do
    for W := 1 to (Wait*1000) do {nil};
   GS_RetryFile := 0;
   RetriesChgd := true;
  {$Else}
   with Reg do begin
      Ax := $440B;
      Cx := Wait;         {Num of 1/18 sec loops between retries (default = 1)}
      Dx := Retry;        {Num of times to retry (default = 3)}
      Ds := 0;
      Es := 0;
      MsDos(Reg);
      if Odd(Reg.Flags) then     {Check if carry flag is set}
         GS_RetryFile := Ax
      else
      begin
         GS_RetryFile := 0;
         RetriesChgd := true;
      end;
   end;
  {$EndIf}
end;

Function GS_UnLockFile(Hndl : Word; FilePosition,FileLength : LongInt) : Word;
var
 {$IfDef Os2}
  Rc                   : apiret;
  LockArea, UnlockArea : FileLock;
 {$Else}
  Reg : TRegisters;
  H,L : Word;
  rsl : word;
 {$EndIf}
begin
   if UseExclusive then
   begin
      if ShareAllowed then GS_UnlockFile := 0
         else GS_UnLockFile := 1;
      exit;
   end;
  {$IfDef Os2}
   FillChar(LockArea,SizeOf(LockArea),0);
   FillChar(UnLockArea,SizeOf(UnLockArea),0);
   with UnLockArea do begin  {Set lock area from FilePosition to FileLength}
     lOffset := FilePosition;
     lRange  := FileLength;
    end; {with}
   Rc := DosSetFileLocks(Hndl,UnLockArea, LockArea, 2000,0); {2 seconds to wait, Exclusive Lock (no atomic)}
   {DosSetFileLocks returns one of the following values:
     0         No_Error
     1         Error_Invalid_Function
     6         Error_Invalid_Handle
     33        Error_Lock_Violation
     36        Error_Sharing_Buffer_Exceeded
     87        Error_Invalid_Parameter
     95        Error_Interrupt
     174       Error_Atomic_Lock_Not_Supported
     175       Error_Read_Locks_Not_Supported             }
   GS_UnLockFile := Rc;
  {$Else}
   with Reg do begin
      Ax := $5C01; {DOS call 5Ch, subfunction 1}
      Bx := Hndl;
      Cx := HiLong(FilePosition);
      Dx := LowLong(FilePosition);
      Si := HiLong(FileLength);
      Di := LowLong(FileLength);
      Ds := 0;
      Es := 0;
      MsDos(Reg);
      if Odd(Reg.Flags) then     {Check if carry flag is set}
         rsl := Ax
      else
         rsl := 0;
   end;
   GS_UnLockFile := rsl;
  {$EndIf}
end;

Function GS_ShareAllowed : boolean;
begin
   if not ShareChecked then
   begin
      UseExclusive := false;
      ShareAllowed := true;
      ShareChecked := true;
      AutomaticShare := true;
   end;
   GS_ShareAllowed := ShareAllowed;
end;

Procedure  GS_SetExclusive(tf : boolean);
begin
   if GS_Exclusive then
      if tf then exit;
   if not ShareAllowed then
      if not tf then exit;
   UseExclusive := tf;
end;

Procedure  GS_ShareAuto(tf : boolean);
begin
   if GS_ShareAllowed then AutomaticShare := tf
      else AutomaticShare := false;
end;

Function  GS_AutoShare : boolean;
begin
   GS_AutoShare := AutomaticShare;
end;

{------------------------------------------------------------------------------
                              GSO_DiskFile
------------------------------------------------------------------------------}

Constructor GSO_DiskFile.Init(Fname : string; Fmode : byte);
var attr : Word;
begin
   dfFileMode := Fmode;
   if GS_Exclusive then dfFileMode := dfFileMode and $07;
   dfFileShrd := dfFileMode > 8;
   Assign(FName);
   dfFileHndl := 0;
   dfFileRSiz := 0;
   dfLockRec := false;
   dfFileFlsh := NeverFlush;
   ObjtLog.Insert(@Self);
end;

destructor GSO_DiskFile.Done;
begin
   GSO_DiskFile.Close;
   ObjtLog.Delete(@Self);
end;

Procedure GSO_DiskFile.AddToFile(var dat; len, StepBack : Word);
var
   LRslt : Word;
   FLen  : Longint;
begin
   FLen := FileSize - StepBack;
   dfFileErr := IOResult;              {Clear IOResult}
   (*$I-*) System.Seek(dFFileType, FLen); (*$I+*)
   dfFileErr := IOResult;
   IF dfFileErr = 0 THEN               {If seek ok, read the record}
   begin
      (*$I-*) BlockWrite(dfFileType, dat, len, dfGoodRec); (*$I+*)
      dfFileErr := IOResult;
      dfFilePosn := (FLen+len);
   end;
   if dfFileErr <> 0 then Error(dfFileErr,dskAddToFileError);
   if (dfFileFlsh = WriteFlush) or
      (dfFileFlsh = AppendFlush) then Flush;
end;

Procedure GSO_DiskFile.Assign(FName : string);
begin
   dfFileName := FName;
   dfFileExst := GS_FileExists(FName);
   dfFileInfo := FindFileInfo;
   if not dfFileExst then FillChar(dfFileInfo,SizeOf(dfFileInfo),#0);
   {07/22/93 fix}
  {$IfDef Os2}
   if (dfFileInfo.Attr and open_share_DenyReadWrite) > 0 then
  {$Else}
   if (dfFileInfo.Attr and $01) > 0 then
  {$EndIf}
      if dfFileShrd then dfFileMode := dfReadOnly+dfSharedDenyWrite
         else dfFileMode := dfReadOnly;

   System.Assign(dfFileType, FName);
   DosError := 0;
   dfFilePosn := 0;
end;

Procedure GSO_DiskFile.Close;
var
   rsl : Word;
begin
   if TFileRec(dfFileType).Mode = fmClosed then exit;
   if dfLockRec then rsl := UnLock;
   dfFileErr := IOResult;              {Clear IOResult}
   (*$I-*) System.Close(dfFileType); {$I+}
   dfFileErr := IOResult;
   if dfFileErr <> 0 then Error(dfFileErr,dskCloseError);
end;

Procedure GSO_DiskFile.Erase;
begin
   if dfFileShrd then Error(dosAccessDenied,dskEraseError)
   else
   begin
      dfFileErr := IOResult;              {Clear IOResult}
      (*$I-*) System.Erase(dfFileType); {$I+}
      dfFileErr := IOResult;
      if dfFileErr <> 0 then Error(dfFileErr,dskEraseError);
   end;
end;

Procedure GSO_DiskFile.Error(Code, Info : Integer);
begin
   RunError(Code);
end;

Function GSO_DiskFile.FileSize : longint;
begin
   dfFileErr := IOResult;              {Clear IOResult}
   (*$I-*) FileSize := System.FileSize(dfFileType); {$I+}
   dfFileErr := IOResult;
   if dfFileErr <> 0 then Error(dfFileErr,dskFileSizeError);
end;

Procedure GSO_DiskFile.Flush;
begin
   dfFileErr := GS_Flush(dfFileHndl);
   if dfFileErr <> 0 then Error(dfFileErr,dskFlushError);
end;

Function GSO_DiskFile.LockFile : Word;
begin
   LockFile := LockRec(0,FileSize*dfFileRSiz);
end;

Function GSO_DiskFile.LockRec(FilePosition,FileLength: LongInt): Word;
begin
   if not dfFileShrd then dfFileErr := 1
   else
      if dfLockRec then
      begin
         if (FilePosition = dfLockPos) and (FileLength = dfLockLth) then
            dfFileErr := 0
         else
            dfFileErr := dosLockViolated;
      end
      else
      begin
         dfLockPos := FilePosition;
         dfLockLth := FileLength;
         dfFileErr := GS_LockFile(dfFileHndl,dfLockPos,dfLockLth);
         dfLockRec := dfFileErr = 0;
      end;
   LockRec := dfFileErr;
end;

Procedure GSO_DiskFile.Read(blk : longint; var dat; len : Word);
begin
   if blk = -1 then blk := dfFilePosn;
   dfFileErr := IOResult;              {Clear IOResult}
   (*$I-*) System.Seek(dFFileType, blk); (*$I+*)
   dfFileErr := IOResult;
   IF dfFileErr = 0 THEN               {If seek ok, read the record}
   BEGIN
      (*$I-*) BlockRead(dfFileType, dat, len, dfGoodRec); (*$I+*)
      dfFileErr := IOResult;
      dfFilePosn := (blk+len);
   end;
   if dfFileErr <> 0 then Error(dfFileErr,dskReadError);
end;

Procedure GSO_DiskFile.Rename(Fname : string);
begin
   if dfFileShrd then Error(dosAccessDenied,dskRenameError)
   else
   begin
      dfFileErr := IOResult;              {Clear IOResult}
      (*$I-*) System.Rename(dfFileType, FName); {$I+}
      dfFileName := Fname;
      dfFileErr := IOResult;
      if dfFileErr <> 0 then Error(dfFileErr,dskRenameError);
   end;
end;

Procedure GSO_DiskFile.Reset(len : Word);
var
   Handle : Word absolute dfFileType;
   OldMode : byte;
begin
   OldMode := FileMode;
   FileMode := dfFileMode;
   dfFileErr := IOResult;              {Clear IOResult}
   (*$I-*) System.Reset(dfFileType, len); (*$I+*)
   dfFileErr := IOResult;
   if dfFileErr <> 0 then Error(dfFileErr,dskResetError);
   dfFilePosn := 0;
   dfFileRSiz := len;
   dfFileHndl := Handle;
   FileMode := OldMode;
   if dfFileShrd then
      if LockRec(0,1) = 1 then
         dfFileShrd := false
      else dfFileErr := Unlock;
end;

Procedure GSO_DiskFile.ReWrite(len : Word);
var
   Handle : Word absolute dfFileType;
   OldMode : byte;
begin
   OldMode := FileMode;
   FileMode := dfFileMode;
   dfFileErr := IOResult;              {Clear IOResult}
   (*$I-*) System.ReWrite(dfFileType, len); (*$I+*)
   dfFileErr := IOResult;
   if dfFileErr <> 0 then Error(dfFileErr,dskRewriteError);
   dfFilePosn := 0;
   dfFileRSiz := len;
   dfFileHndl := Handle;
   FileMode := OldMode;
   if dfFileShrd then
      if LockRec(0,1) = 1 then
         dfFileShrd := false
      else dfFileErr := Unlock;
end;

Procedure GSO_DiskFile.SetFlushCondition(Condition : dfFlushStatus);
begin
   dfFileFlsh := Condition;
end;

Procedure GSO_DiskFile.Truncate(loc : longint);
begin
   if dfFileShrd then Error(dosAccessDenied,dskTruncateError)
   else
   begin
      if loc = -1 then loc := dfFilePosn;
      dfFileErr := IOResult;              {Clear IOResult}
      (*$I-*) Seek(dfFileType, loc); (*$I+*)
      dfFileErr := IOResult;
      if dfFileErr = 0 then
      begin
         (*$I-*) System.Truncate(dfFileType); {$I+}
         dfFileErr := IOResult;
      end;
      if dfFileErr <> 0 then Error(dfFileErr,dskTruncateError)
   end;
end;

Function GSO_DiskFile.UnLock : Word;
var
   ulokok : Word;
begin
   UnLock := 0;
   if not dfLockRec then exit;
   ulokok := GS_UnLockFile(dfFileHndl,dfLockPos,dfLockLth);
   dfLockRec :=  ulokok <> 0;
   UnLock := ulokok;
   if dfFileFlsh = UnLockFlush then Flush;
end;

Procedure GSO_DiskFile.Write(blk : longint; var dat; len : Word);
var
   LRslt : Word;
begin
   if blk = -1 then blk := dfFilePosn;
   dfFileErr := IOResult;              {Clear IOResult}
   (*$I-*) System.Seek(dFFileType, blk); (*$I+*)
   dfFileErr := IOResult;
   IF dfFileErr = 0 THEN               {If seek ok, read the record}
   begin
      (*$I-*) BlockWrite(dfFileType, dat, len, dfGoodRec); (*$I+*)
      dfFileErr := IOResult;
      dfFilePosn := (blk+len);
   end;
   if dfFileErr <> 0 then Error(dfFileErr,dskWriteError);
   if dfFileFlsh = WriteFlush then Flush;
end;

{------------------------------------------------------------------------------
                           Setup and Exit Routines
------------------------------------------------------------------------------}

{$F+}
procedure ExitHandler;
var rslt : Word;
begin
   GS_ClearLocks;
   if RetriesChgd then
   begin
      UseExclusive := false;
      rslt := GS_RetryFile(1,3);
   end;
   ExitProc := ExitSave;
end;
{$F-}

begin
   ObjtLog.Init(32,16);
   ExitSave := ExitProc;
   ExitProc := @ExitHandler;
end.
{-----------------------------------------------------------------------------}
                                   END

