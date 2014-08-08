unit GSOBShel;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                           dBase III/IV File Handler

           GSOBSHEL (C) 1996 of ThE ToY Of Virtual Reality Group
               (Original Copyright of Richard F. Griffin)

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       This unit provides access to Halcyon/2 dBase Objects
       using high-level procedures and functions that make Object
       Oriented Programming transparent to the user.  It provides a
       selection of commands similar to the dBase format.

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

interface

Uses Use32, GSOB_Var, GSOB_DBS;

type
   CaptureError  = Procedure(Code, Info: Integer);
   CaptureStatus = Procedure(stat1,stat2,stat3 : longint);
   FilterCheck   = Function: boolean;
   FormulaProc   = Function(st: string; var fmrec : GSR_FormRec): boolean;
   XtractFunc    = Function(var st: string; fmrec: GSR_FormRec): boolean;

   pDBFObject = ^DBFObject;
   DBFObject = object(GSO_dBHandler)
      DBFAlias    : {$IfNdef Os2} string[10] {$Else} string {$EndIf};
      DBFFilter   : FilterCheck;
      DBFFormula  : FormulaProc;
      DBFXtract   : XtractFunc;
      constructor Init(FName : string);
      Procedure   Error(Code, Info: Integer); virtual;
      Procedure   Formula(st : string; var fmrec : GSR_FormRec); virtual;
      Function    FormXtract(fmrec : GSR_FormRec) : string; virtual;
      Procedure   StatusUpdate(stat1,stat2,stat3 : longint); virtual;
      Function    TestFilter : boolean; virtual;
   end;

var
   CapError   : CaptureError;
   CapStatus  : CaptureStatus;
   DBFActive  : pDBFObject;
   DBFUsed    : Integer;
   DBFAreas   : array[0..40] of pDBFObject;
   LastError  : Integer;

var ExitSave      : pointer;

   Function   Alias : string;                                       Export;
   Function   ALock : boolean;                                      Export;
   Procedure  DBAppend;                                             Export;
   Procedure  ClearRecord;                                          Export;
   Procedure  CloseDataBases;                                       Export;
   Procedure  CopyStructure(filname : string);                      Export;
   Procedure  CopyTo(filname : string);                             Export;
   Function   CurrentArea : byte;                                   Export;
   Function   Date: longint;                                        Export;
   Function   DBF : string;                                         Export;
   Function   DBFError : Integer;                                   Export;
   Function   dBOF : boolean;                                       Export;
   Function   Deleted : boolean;                                    Export;
   Procedure  DeleteRec;                                            Export;
   Function   dEOF : boolean;                                       Export;
   Function   Field(n : byte) : string;                             Export;
   Function   FieldCount : byte;                                    Export;
   Function   FieldDec(n : byte) : byte;                            Export;
   Function   FieldLen(n : byte) : byte;                            Export;
   Function   FieldNo(fn : string) : byte;                          Export;
   Function   FieldType(n : byte) : char;                           Export;
   Function   FileExist(FName : string) : boolean;                  Export;
   Procedure  Find(ss : string);                                    Export;
   Function   FLock : boolean;                                      Export;
   Procedure  FlushDBF;                                             Export;
   Function   Found : boolean;                                      Export;
   Procedure  Go(n : longint);                                      Export;
   Procedure  GoBottom;                                             Export;
   Procedure  GoTop;                                                Export;
   Procedure  Index(INames : string);                               Export;
   Procedure  IndexOn(filname, formla : string);                    Export;
   Function   LUpdate: string;                                      Export;
   Procedure  Pack;                                                 Export;
   Procedure  RecallRec;                                            Export;
   Function   RecCount : longint;                                   Export;
   Function   RecNo : longint;                                      Export;
   Function   RecSize : Word;                                       Export;
   Procedure  Reindex;                                              Export;
   Procedure  Replace;                                              Export;
   Function   RLock : boolean;                                      Export;
   Procedure  Select(Obj : byte);                                   Export;
   Procedure  SetCenturyOff;                                        Export;
   Procedure  SetCenturyOn;                                         Export;
   Procedure  SetDateStyle(dt : DateTypes);                         Export;
   Procedure  SetDBFCacheOff;                                       Export;
   Procedure  SetDBFCacheOn;                                        Export;
   Procedure  SetDeletedOff;                                        Export;
   Procedure  SetDeletedOn;                                         Export;
   Procedure  SetErrorCapture(UserRoutine : CaptureError);          Export;
   Procedure  SetExactOff;                                          Export;
   Procedure  SetExactOn;                                           Export;
   Procedure  SetExclusiveOff;                                      Export;
   Procedure  SetExclusiveOn;                                       Export;
   Procedure  SetFileHandles(hndls : byte);                         Export;
   Procedure  SetFilterThru(UserRoutine : FilterCheck);             Export;
   Procedure  SetFlushOff;                                          Export;
   Procedure  SetFlushOnAppend;                                     Export;
   Procedure  SetFlushOnWrite;                                      Export;
   Procedure  SetFormulaProcess(UserRoutine1 : FormulaProc;
                                UserRoutine2: XtractFunc);          Export;
   Procedure  SetLockOff;                                           Export;
   Procedure  SetLockOn;                                            Export;
   Procedure  SetOrderTo(order : Integer);                          Export;
   Procedure  SetStatusCapture(UserRoutine : CaptureStatus);        Export;
   Procedure  Skip(n : longint);                                    Export;
   Procedure  SortTo(filname, formla: string; sortseq: SortStatus); Export;
   Procedure  Unlock;                                               Export;
   Procedure  UnlockAll;                                            Export;
   Procedure  Use(FName : string);                                  Export;
   Procedure  Zap;                                                  Export;

     {dBase field handling routines}

   Procedure  AssignMemo(st, nm : string);                          Export;
   Procedure  SaveMemo(st, nm : string);                            Export;
   Procedure  MemoClear;                                            Export;
   function   MemoGetLine(linenum : Integer) : string;              Export;
   Procedure  MemoInsLine(linenum : Integer; st : string);          Export;
   procedure  MemoGet(st : string);                                 Export;
   procedure  MemoGetN(n : Integer);                                Export;
   Procedure  MemoWidth(l : Integer);                               Export;
   function   MemoLines : Integer;                                  Export;
   procedure  MemoPut(st : string);                                 Export;
   procedure  MemoPutN(n : Integer);                                Export;
   Function   DateGet(st : string) : longint;                       Export;
   Function   DateGetN(n : Integer) : longint;                      Export;
   Procedure  DatePut(st : string; jdte : longint);                 Export;
   Procedure  DatePutN(n : Integer; jdte : longint);                Export;
   Function   FieldGet(fnam : string) : string;                     Export;
   Function   FieldGetN(fnum : Integer) : string;                   Export;
   Procedure  FieldPut(fnam, st : string);                          Export;
   Procedure  FieldPutN(fnum : Integer; st : string);               Export;
   Function   LogicGet(st : string) : boolean;                      Export;
   Function   LogicGetN(n : Integer) : boolean;                     Export;
   Procedure  LogicPut(st : string; b : boolean);                   Export;
   Procedure  LogicPutN(n : Integer; b : boolean);                  Export;
   Function   NumberGet(st : string) : FloatNum;                    Export;
   Function   NumberGetN(n : Integer) : FloatNum;                   Export;
   Procedure  NumberPut(st : string; r : FloatNum);                 Export;
   Procedure  NumberPutN(n : Integer; r : FloatNum);                Export;
   Function   StringGet(fnam : string) : string;                    Export;
   Function   StringGetN(fnum : Integer) : string;                  Export;
   Procedure  StringPut(fnam, st : string);                         Export;
   Procedure  StringPutN(fnum : Integer; st : string);              Export;

     {dBase type functions}

function CTOD(strn : string) : longint;                             Export;
function DTOC(jul : longint) : string;                              Export;
function DTOS(jul : longint) : string;                              Export;

     {Default capture procedures}

Procedure DefCapError(Code, Info : Integer);                             Export;
Procedure DefCapStatus(stat1,stat2,stat3 : longint);                     Export;
Function  DefFilterCk: boolean;                                          Export;
Function  DefFormulaBuild(st: string; var fmrec: GSR_FormRec): boolean;  Export;
Function  DefFormulaXtract(var st: string; fmrec: GSR_FormRec): boolean; Export;

     {Extended Hacking procedures}

Procedure SetDBExt(vDBExt:String);                                  Export;


implementation

Uses GSOB_Str,
     GSOB_DBF,
     GSOB_Dsk,
     GSOB_Dte,
    {$IFDEF WINDOWS}
       WinDos,
       Strings;
    {$ELSE}
       Dos;
    {$ENDIF}


{-----------------------------------------------------------------------------
                            Data Capture Procedures
------------------------------------------------------------------------------}

Constructor DBFObject.Init(FName : string);
begin
   GSO_dBHandler.Init(FName);
   DBFFilter := DefFilterCk;
   DBFFormula := DefFormulaBuild;
   DBFXtract := DefFormulaXtract;
end;

Procedure DBFObject.Error(Code, Info : Integer);
begin
   CapError(Code, Info);
end;

Procedure DBFObject.Formula(st : string; var fmrec : GSR_FormRec);
begin
   if not DBFFormula(st, fmrec) then GSO_dBHandler.Formula(st, fmrec);
end;

Function  DBFObject.FormXtract(fmrec : GSR_FormRec) : string;
var
   st : string;
begin
   if DBFXtract(st, fmrec) then FormXtract := st
   else FormXtract := GSO_dBHandler.FormXtract(fmrec);
end;

Procedure DBFObject.StatusUpdate(stat1,stat2,stat3 : longint);
begin
   CapStatus(stat1,stat2,stat3);
end;

Function DBFObject.TestFilter : boolean;
begin
   if DBFFilter then
      TestFilter := GSO_dBHandler.TestFilter
   else
      TestFilter := false;
end;


                    {Default capture routines}

{$F+}
Procedure DefCapError(Code, Info : Integer);
begin
   RunError(Code);
end;

Procedure DefCapStatus(stat1,stat2,stat3 : longint);
begin
end;

Function DefFilterCk: boolean;
begin
   DefFilterCk := true;
end;

Function DefFormulaBuild(st: string; var fmrec : GSR_FormRec): boolean;
begin
   DefFormulaBuild := false;
end;

Function  DefFormulaXtract(var st: string; fmrec: GSR_FormRec): boolean;
begin
   DefFormulaXtract := false;
end;
{$F-}
{-----------------------------------------------------------------------------
                        High-Level Procedures/Functions
------------------------------------------------------------------------------}

Procedure ConfirmUsedArea;
begin
   if DBFActive = nil then RunError(gsAreaIsNotInUse);
end;

Function Alias : string;
begin
   if DBFActive <> nil then
      Alias := DBFActive^.DBFAlias
   else Alias := '';
end;

Function ALock : boolean;
begin
   ConfirmUsedArea;
   ALock := DBFActive^.LokApnd;
end;

Procedure DBAppend;
begin
   ConfirmUsedArea;
   DBFActive^.Append;
end;

Procedure ClearRecord;
begin
   ConfirmUsedArea;
   DBFActive^.Blank;
end;

Procedure CloseDatabases;
var i : Integer;
begin
   for i := 1 to 40 do
      if DBFAreas[i] <> nil then
      begin
         Dispose(DBFAreas[i], Done);
         DBFAreas[i] := nil;
      end;
end;

Procedure  CopyStructure(filname : string);
begin
   ConfirmUsedArea;
   DBFActive^.CopyStructure(filname);
end;

Procedure  CopyTo(filname : string);
begin
   ConfirmUsedArea;
   DBFActive^.CopyFile(filname);
end;

function CTOD(strn : string) : longint;
var
   v : longint;
begin
   v := GS_Date_Juln(strn);
   if v > 0 then CTOD := v else CTOD := 0;
end;

Function CurrentArea : byte;
begin
   CurrentArea := DBFUsed;
end;

Function Date: longint;
begin
   Date := GS_Date_Curr;
end;

{$IFDEF WINDOWS}
Function DBF : string;
var
   ExpFile : PChar;
begin
   if DBFActive = nil then DBF := ''
      else
      begin
         GetMem(ExpFile, 80);
         StrPCopy(ExpFile, DBFActive^.dfFileName);
         FileExpand(ExpFile, ExpFile);
         DBF := ExpFile^;
         FreeMem(ExpFile, 80);
      end;
end;
{$ELSE}
Function DBF : string;
begin
   if DBFActive = nil then DBF := ''
      else DBF := FExpand(DBFActive^.dfFileName);
end;
{$ENDIF}


Function DBFError : Integer;
begin
   ConfirmUsedArea;
   DBFError := LastError;
   LastError := 0;
end;

Function dBOF : boolean;
begin
   ConfirmUsedArea;
   dBOF := DBFActive^.File_TOF;
end;

Function Deleted : boolean;
begin
   ConfirmUsedArea;
   Deleted := DBFActive^.DelFlag;
end;

Procedure DeleteRec;
begin
   ConfirmUsedArea;
   DBFActive^.Delete;
end;

Function dEOF : boolean;
begin
   ConfirmUsedArea;
   dEOF := DBFActive^.File_EOF;
end;

function DTOC(jul : longint) : string;
begin
   DTOC := GS_Date_View(jul);
end;

function DTOS(jul : longint) : string;
begin
   DTOS := GS_Date_DBStor(jul);
end;

Function Field(n : byte) : string;
var
   st : string;
begin
   ConfirmUsedArea;
   st := DBFActive^.FieldName(n);
   if st = '' then LastError := 220 else LastError := 0;
   Field := st;
end;

Function FieldCount : byte;
begin
   ConfirmUsedArea;
   FieldCount := DBFActive^.NumFields;
end;

Function FieldDec(n : byte) : byte;
begin
   ConfirmUsedArea;
   FieldDec := DBFActive^.FieldDecimals(n);
end;

Function FieldLen(n : byte) : byte;
begin
   ConfirmUsedArea;
   FieldLen := DBFActive^.FieldLength(n);
end;

Function FieldNo(fn : string) : byte;
var
   mtch : boolean;
   i,
   ix   : Integer;
   za   : string[16];
begin
   ConfirmUsedArea;
   fn := TrimR(AllCaps(fn));
   ix := DBFActive^.NumFields;
   i := 1;
   mtch := false;
   while (i <= ix) and not mtch do
   begin
      CnvAscToStr(DBFActive^.Fields^[i].FieldName,za,11);
      if za = fn then mtch := true else inc(i);
   end;
   if mtch then FieldNo := i else FieldNo := 0;
end;

Function FieldType(n : byte) : char;
begin
   ConfirmUsedArea;
   FieldType := DBFActive^.FieldType(n);
end;

Function FileExist(FName : string): boolean;
begin
   FileExist := GS_FileExists(FName);
end;

Procedure Find(ss : string);
var b : boolean;
begin
   ConfirmUsedArea;
   b := DBFActive^.FindNear(ss);
end;

Function FLock : boolean;
begin
   ConfirmUsedArea;
   FLock := DBFActive^.LokFile;
end;

Procedure FlushDBF;
begin
   ConfirmUsedArea;
   DBFActive^.Flush;
end;

Function Found : boolean;
begin
   ConfirmUsedArea;
   Found := DBFActive^.Found;
end;

Procedure Go(n : longint);
var
   b : longint;
   s : string;
begin
   ConfirmUsedArea;
   if (n < 1) or (n > DBFActive^.NumRecs) then exit;
   DBFActive^.GetRec(n);
   if DBFActive^.IndexMaster <> nil then
   begin
      s := DBFActive^.FormXtract(DBFActive^.IndexMaster^.FormRec);
      b := DBFActive^.IndexMaster^.KeyFind(s);
      while (b <> n) and (b <> 0) do
         b := DBFActive^.IndexMaster^.KeyRead(Next_Record);
   end;
end;

Procedure GoBottom;
begin
   ConfirmUsedArea;
   DBFActive^.GetRec(Bttm_Record);
end;

Procedure GoTop;
begin
   ConfirmUsedArea;
   DBFActive^.GetRec(Top_Record);
end;

Procedure Index(INames : string);
begin
   ConfirmUsedArea;
   if INames <> '' then SetDBFCacheOff;
   DBFActive^.Index(INames);
end;

Procedure IndexOn(filname, formla: string);
var order : Integer;
begin
   ConfirmUsedArea;
   SetDBFCacheOff;
   order := DBFActive^.IndexTo(filname, formla);
end;

Function LUpdate: string;
var
   yy, mm, dd : Word;
   hh, mn, ss : Word;
   fd         : longint;
begin
   if DBFActive = nil then LUpdate := ''
   else
   begin
      GS_FileDateTime(DBFActive^.dfFiletype,yy,mm,dd,hh,mn,ss);
      fd := GS_Date_MDY2Jul(mm,dd,yy);
      LUpdate := GS_Date_View(fd);
   end;
end;

Procedure Pack;
begin
   ConfirmUsedArea;
   DBFActive^.Pack;
end;

Procedure RecallRec;
begin
   ConfirmUsedArea;
   DBFActive^.Undelete;
end;

Function RecCount : longint;
begin
   ConfirmUsedArea;
   RecCount := DBFActive^.RecsInFile;
end;

Function RecNo : longint;
begin
   ConfirmUsedArea;
   RecNo := DBFActive^.RecNumber;
end;

Function RecSize : Word;
begin
   ConfirmUsedArea;
   RecSize := DBFActive^.RecLen;
end;

Procedure Reindex;
begin
   ConfirmUsedArea;
   DBFActive^.Reindex;
end;

Procedure Replace;
begin
   ConfirmUsedArea;
   DBFActive^.Replace;
end;

Function RLock : boolean;
begin
   ConfirmUsedArea;
   RLock := DBFActive^.LokRcrd;
end;

Procedure Select(Obj : byte);
var
   b : longint;
   s : string;
begin
   if (Obj < 1) or (Obj > 40) then exit;
   DBFUsed := Obj;
   DBFActive := DBFAreas[Obj];
   if DBFActive <> nil then
      if DBFActive^.IndexMaster <> nil then
         if DBFActive^.RecNumber = 0 then GoTop
         else
         begin
            s := DBFActive^.FormXtract(DBFActive^.IndexMaster^.FormRec);
            b := DBFActive^.IndexMaster^.KeyFind(s);
            while (b <> DBFActive^.RecNumber) and (b <> 0) do
               b := DBFActive^.IndexMaster^.KeyRead(Next_Record);
         end;
end;

Procedure SetCenturyOff;
begin
   SetCentury(dbOff);
end;

Procedure SetCenturyOn;
begin
   SetCentury(dbOn);
end;

Procedure SetDateStyle(dt : DateTypes);
begin
   GS_Date_Type := DateCountry(dt);
end;

Procedure SetDBFCacheOff;
begin
   ConfirmUsedArea;
   DBFActive^.SetDBFCache(dbOff);
end;

Procedure SetDBFCacheOn;
begin
   ConfirmUsedArea;
   if DBFActive^.IndexMaster <> nil then exit;
   DBFActive^.SetDBFCache(dbOn);
end;

Procedure SetDeletedOff;
begin
   SetDeleted(dbOff);
end;

Procedure SetDeletedOn;
begin
   SetDeleted(dbOn);
end;

Procedure SetErrorCapture(UserRoutine : CaptureError);
begin
   CapError := UserRoutine;
end;

Procedure SetExactOff;
begin
   SetExact(dbOff);
end;

Procedure SetExactOn;
begin
   SetExact(dbOn);
end;

Procedure SetExclusiveOff;
begin
   GS_SetExclusive(dbOff);
end;

Procedure SetExclusiveOn;
begin
   GS_SetExclusive(dbOn);
end;

Procedure SetFileHandles(hndls : byte);
var
   b : boolean;
begin
   b := GS_ExtendHandles(hndls);
end;

Procedure SetFilterThru(UserRoutine : FilterCheck);
begin
   ConfirmUsedArea;
   DBFActive^.DBFFilter := UserRoutine;
end;

Procedure SetFlushOff;
begin
   ConfirmUsedArea;
   DBFActive^.dfFileFlsh := NeverFlush;
end;

Procedure SetFlushOnAppend;
begin
   ConfirmUsedArea;
   DBFActive^.dfFileFlsh := AppendFlush;
end;

Procedure SetFlushOnWrite;
begin
   ConfirmUsedArea;
   DBFActive^.dfFileFlsh := WriteFlush;
end;

Procedure SetFormulaProcess(UserRoutine1 : FormulaProc;
                            UserRoutine2: XtractFunc);
begin
   DBFActive^.DBFFormula := UserRoutine1;
   DBFActive^.DBFXtract := UserRoutine2;
end;

Procedure SetLockOff;
var i : Integer;
begin
   GS_ShareAuto(dbOff);
end;

Procedure SetLockOn;
begin
   GS_ShareAuto(dbOn);
end;

Procedure SetOrderTo(order : Integer);
var b : boolean;
begin
   ConfirmUsedArea;
   b := DBFActive^.IndexOrder(order);
end;

Procedure SetStatusCapture(UserRoutine : CaptureStatus);
begin
   CapStatus := UserRoutine;
end;

Procedure Skip(n : longint);
begin
   ConfirmUsedArea;
   DBFActive^.Skip(n);
end;

Procedure SortTo(filname, formla: string; sortseq : SortStatus);
begin
   ConfirmUsedArea;
   DBFActive^.SortFile(filname, formla, sortseq);
end;

Procedure Unlock;
var
   i   : Integer;
   rsl : Word;
begin
   ConfirmUsedArea;
   DBFActive^.LokOff;
   if DBFActive^.WithMemo then rsl := DBFActive^.MemoFile^.Unlock;
   for i := 1 to IndexesAvail do
      if DBFActive^.IndexStack[i] <> nil then
         rsl := DBFActive^.IndexStack[i]^.Unlock;
end;

Procedure UnlockAll;
var i : Integer;
begin
   for i := 1 to 40 do
      if DBFAreas[i] <> nil then
         while DBFAreas[i]^.dfLockRec do DBFAreas[i]^.LokOff;
   GS_ClearLocks;
end;

Procedure Use(FName : string);
var i,j : Integer;
begin
   if DBFActive <> nil then dispose(DBFActive, Done);
   DBFActive := nil;
   DBFAreas[DBFUsed] := DBFActive;
   if FName = '' then exit;
   DBFActive := New(pDBFObject, Init(FName));
   DBFActive^.Open;
   DBFAreas[DBFUsed] := DBFActive;
   FName := AllCaps(TrimR(FName));
   i := length(FName);
   j := i;
   while (i > 0) and not (FName[i] in ['\',':']) do dec(i);
   DBFActive^.DBFAlias := copy(FName,i+1,(j-i));
   {DBFActive^.DBFAlias := getFileName(FName);}
end;

Procedure Zap;
begin
   ConfirmUsedArea;
   DBFActive^.Zap;
end;

{------------------------------------------------------------------------------
                           Field Access Routines
------------------------------------------------------------------------------}

Procedure AssignMemo(st, nm : string);
var
   i,
   ml   : Integer;
   Txfile : Text;
begin
   Assign(TxFile,nm);
   Rewrite(TxFile);
   DBFActive^.MemoGet(st);
   ml := DBFActive^.MemoLines;
   if ml <> 0 then
      for i := 1 to ml do
         Writeln(TxFile,DBFActive^.MemoGetLine(i));
   Close(TxFile);
end;

procedure SaveMemo(st, nm : string);
var
   i   : Integer;
   s   : string;
   m1,
   m2  : string[10];
   Txfile : Text;
begin
   m1 := DBFActive^.FieldGet(st);
   DBFActive^.MemoClear;
   Assign(TxFile,nm);
   Reset(TxFile);
   while not EOF(TxFile) do
   begin
      Readln(TxFile,s);
      DBFActive^.MemoInsLine(-1,s);
   end;
   Close(TxFile);
   DBFActive^.MemoPut(st);
   m2 := DBFActive^.FieldGet(st);
            {If the memo field number has changed, save the DBF record}
   if m1 <> m2 then DBFActive^.PutRec(DBFActive^.RecNumber);
end;

Procedure MemoClear;
begin
   DBFActive^.MemoClear;
end;

function MemoGetLine(linenum : Integer) : string;
begin
   MemoGetLine := DBFActive^.MemoGetLine(linenum);
end;

Procedure MemoInsLine(linenum : Integer; st : string);
begin
   DBFActive^.MemoInsLine(linenum, st);
end;

procedure MemoGet(st : string);
begin
   DBFActive^.MemoGet(st);
end;

procedure MemoGetN(n : Integer);
begin
   DBFActive^.MemoGetN(n);
end;

Procedure MemoWidth(l : Integer);
begin
   DBFActive^.MemoWidth(l);
end;

function MemoLines : Integer;
begin
   MemoLines := DBFActive^.Memolines;
end;

procedure MemoPut(st : string);
begin
   DBFActive^.MemoPut(st);
end;

procedure MemoPutN(n : Integer);
begin
   DBFActive^.MemoPutN(n);
end;

Function DateGet(st : string) : longint;
begin
   DateGet := DBFActive^.DateGet(st);
end;

Function DateGetN(n : Integer) : longint;
begin
   DateGetN := DBFActive^.DateGetN(n);
end;

Procedure DatePut(st : string; jdte : longint);
begin
   DBFActive^.DatePut(st, jdte);
end;

Procedure DatePutN(n : Integer; jdte : longint);
begin
   DBFActive^.DatePutN(n, jdte);
end;

Function FieldGet(fnam : string) : string;
begin
   FieldGet := DBFActive^.FieldGet(fnam);
end;

Function FieldGetN(fnum : Integer) : string;
begin
   FieldGetN := DBFActive^.FieldGetN(fnum);
end;

Procedure FieldPut(fnam, st : string);
begin
   DBFActive^.FieldPut(fnam, st);
end;

Procedure FieldPutN(fnum : Integer; st : string);
begin
   DBFActive^.FieldPutN(fnum, st);
end;

Function LogicGet(st : string) : boolean;
begin
   LogicGet := DBFActive^.LogicGet(st);
end;

Function LogicGetN(n : Integer) : boolean;
begin
   LogicGetN := DBFActive^.LogicGetN(n);
end;

Procedure LogicPut(st : string; b : boolean);
begin
   DBFActive^.LogicPut(st, b);
end;

Procedure LogicPutN(n : Integer; b : boolean);
begin
   DBFActive^.LogicPutN(n, b);
end;

Function NumberGet(st : string) : FloatNum;
begin
   NumberGet := DBFActive^.NumberGet(st);
end;

Function NumberGetN(n : Integer) : FloatNum;
begin
   NumberGetN := DBFActive^.NumberGetN(n);
end;

Procedure NumberPut(st : string; r : FloatNum);
begin
   DBFActive^.NumberPut(st, r);
end;

Procedure NumberPutN(n : Integer; r : FloatNum);
begin
   DBFActive^.NumberPutN(n, r);
end;

Function StringGet(fnam : string) : string;
begin
   StringGet := DBFActive^.StringGet(fnam);
end;

Function StringGetN(fnum : Integer) : string;
begin
   StringGetN := DBFActive^.StringGetN(fnum);
end;

Procedure StringPut(fnam, st : string);
begin
   DBFActive^.StringPut(fnam, st);
end;

Procedure StringPutN(fnum : Integer; st : string);
begin
   DBFActive^.StringPutN(fnum, st);
end;

{------------------------------------------------------------------------------
                         Extended Hacking procedures
------------------------------------------------------------------------------}
Procedure SetDBExt(vDBExt:String);
begin
 if vDBExt = '' then DBExtension := cDBExt { standard .DBF extension }
  else DBExtension := vDBExt;              { hacked .DBF extension   }
end;


{------------------------------------------------------------------------------
                           Setup and Exit Routines
------------------------------------------------------------------------------}

{var ExitSave      : pointer;}

{$F+}
procedure ExitHandler;
var
   i    : Integer;
begin
   CloseDatabases;
   ExitProc := ExitSave;
end;
{$F-}

begin
   ExitSave := ExitProc;
   ExitProc := @ExitHandler;
   CapError := DefCapError;
   CapStatus := DefCapStatus;
   DBFActive := nil;
   for DBFUsed := 0 to 40 do
   begin
      DBFAreas[DBFUsed] := nil;
   end;
   DBFUsed := 1;
   LastError := 0;
end.
{-----------------------------------------------------------------------------}
                                   END

