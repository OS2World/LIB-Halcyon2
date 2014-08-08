Unit VRGDBSHL;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                  dBase III/IV DLL File Loader/Shell

           VRGDBSHL (C) 1996 of ThE ToY Of Virtual Reality Group

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       The 'Virtual Reality Group DB (III/IV) Shell' provide
       a complete shell to the VRGDBENG.DLL, with loader/unloader
       for dinamically linkable library.

       DllError values:
       -1  LoadDBModule must be called
       -2  DynaNum doesn't exist
       -3  Unknown error
       rc  Error alues as in the Api called!

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

Interface

Uses Use32;

const MaxExports        = 140;
    {$IfDef Os2}
      dbDLLName : PChar = 'VRGDBENG';
    {$Else}
      dbDLLName = 'VRGDBENG.DLL';     {Dos version requires an Extension for .DLL names!}
    {$EndIf}

type DateTypes = (American,ANSI,British,French,German,Italian,Japan,USA, MDY, DMY, YMD);  {GSOB_VAR.PAS}
     GSR_FormRec = record                                                                 {GSOB_DBS.PAS}
        FType : Char;
        FDcml : byte;
        FSize : SmallInt;
        FPosn : array[0..32] of SmallInt;
        FAlias: string[10];
       end;

     SortStatus = (SortUp, SortDown, NoSort);                                             {GSOB_VAR.PAS}
   {$IfnDef Os2}                                                                          {GSOB_VAR.PAS}
    {$IFOPT N+}
     FloatNum = Extended;
    {$ELSE}
     FloatNum = Real;
    {$ENDIF}
   {$Else}
     FloatNum = Extended;
   {$EndIf}

     CaptureError  = Procedure(Code, Info: Integer);
     CaptureStatus = Procedure(stat1,stat2,stat3 : longint);
     FilterCheck   = Function: boolean;
     FormulaProc   = Function(st: string; var fmrec : GSR_FormRec): boolean;
     XtractFunc    = Function(var st: string; fmrec: GSR_FormRec): boolean;

     tAlias             = Function: string;
     tALock             = Function: boolean;
     tDBAppend          = Procedure;
     tClearRecord       = Procedure;
     tCloseDataBases    = Procedure;
     tCopyStructure     = Procedure(filname : string);
     tCopyTo            = Procedure(filname : string);
     tCurrentArea       = Function: byte;
     tDate              = Function: longint;
     tDBF               = Function: string;
     tDBFError          = Function: Integer;
     tdBOF              = Function: boolean;
     tDeleted           = Function: boolean;
     tDeleteRec         = Procedure;
     tdEOF              = Function: boolean;
     tField             = Function(n : byte) : string;
     tFieldCount        = Function: byte;
     tFieldDec          = Function(n : byte) : byte;
     tFieldLen          = Function(n : byte) : byte;
     tFieldNo           = Function(fn : string) : byte;
     tFieldType         = Function(n : byte) : char;
     tFileExist         = Function(FName : string) : boolean;
     tFind              = Procedure(ss : string);
     tFLock             = Function: boolean;
     tFlushDBF          = Procedure;
     tFound             = Function: boolean;
     tGo                = Procedure(n : longint);
     tGoBottom          = Procedure;
     tGoTop             = Procedure;
     tIndex             = Procedure(INames : string);
     tIndexOn           = Procedure(filname, formla : string);
     tLUpdate           = Function: string;
     tPack              = Procedure;
     tRecallRec         = Procedure;
     tRecCount          = Function: longint;
     tRecNo             = Function: longint;
     tRecSize           = Function: Word;
     tReindex           = Procedure;
     tReplace           = Procedure;
     tRLock             = Function: boolean;
     tSelect            = Procedure(Obj : byte);
     tSetCenturyOff     = Procedure;
     tSetCenturyOn      = Procedure;
     tSetDateStyle      = Procedure(dt : DateTypes);
     tSetDBFCacheOff    = Procedure;
     tSetDBFCacheOn     = Procedure;
     tSetDeletedOff     = Procedure;
     tSetDeletedOn      = Procedure;
     tSetErrorCapture   = Procedure(UserRoutine : CaptureError);
     tSetExactOff       = Procedure;
     tSetExactOn        = Procedure;
     tSetExclusiveOff   = Procedure;
     tSetExclusiveOn    = Procedure;
     tSetFileHandles    = Procedure(hndls : byte);
     tSetFilterThru     = Procedure(UserRoutine : FilterCheck);
     tSetFlushOff       = Procedure;
     tSetFlushOnAppend  = Procedure;
     tSetFlushOnWrite   = Procedure;
     tSetFormulaProcess = Procedure(UserRoutine1 : FormulaProc; UserRoutine2: XtractFunc);
     tSetLockOff        = Procedure;
     tSetLockOn         = Procedure;
     tSetOrderTo        = Procedure(order : Integer);
     tSetStatusCapture  = Procedure(UserRoutine : CaptureStatus);
     tSkip              = Procedure(n : longint);
     tSortTo            = Procedure(filname, formla: string; sortseq: SortStatus);
     tUnlock            = Procedure;
     tUnlockAll         = Procedure;
     tUse               = Procedure(FName : string);
     tZap               = Procedure;

       {dBase field handling routines}

     tAssignMemo        = Procedure(st, nm : string);
     tSaveMemo          = Procedure(st, nm : string);
     tMemoClear         = Procedure;
     tMemoGetLine       = Function(linenum : Integer) : string;
     tMemoInsLine       = Procedure(linenum : Integer; st : string);
     tMemoGet           = Procedure(st : string);
     tMemoGetN          = Procedure(n : Integer);
     tMemoWidth         = Procedure(l : Integer);
     tMemoLines         = Function: Integer;
     tMemoPut           = Procedure(st : string);
     tMemoPutN          = Procedure(n : Integer);
     tDateGet           = Function(st : string) : longint;
     tDateGetN          = Function(n : Integer) : longint;
     tDatePut           = Procedure(st : string; jdte : longint);
     tDatePutN          = Procedure(n : Integer; jdte : longint);
     tFieldGet          = Function(fnam : string) : string;
     tFieldGetN         = Function(fnum : Integer) : string;
     tFieldPut          = Procedure(fnam, st : string);
     tFieldPutN         = Procedure(fnum : Integer; st : string);
     tLogicGet          = Function(st : string) : boolean;
     tLogicGetN         = Function(n : Integer) : boolean;
     tLogicPut          = Procedure(st : string; b : boolean);
     tLogicPutN         = Procedure(n : Integer; b : boolean);
     tNumberGet         = Function(st : string) : FloatNum;
     tNumberGetN        = Function(n : Integer) : FloatNum;
     tNumberPut         = Procedure(st : string; r : FloatNum);
     tNumberPutN        = Procedure(n : Integer; r : FloatNum);
     tStringGet         = Function(fnam : string) : string;
     tStringGetN        = Function(fnum : Integer) : string;
     tStringPut         = Procedure(fnam, st : string);
     tStringPutN        = Procedure(fnum : Integer; st : string);

       {dBase type functions}

     tCTOD = Function(strn : string) : longint;
     tDTOC = Function(jul : longint) : string;
     tDTOS = Function(jul : longint) : string;

       {Default capture procedures}

     tDefCapError      = Procedure(Code, Info : Integer);
     tDefCapStatus     = Procedure(stat1,stat2,stat3 : longint);
     tDefFilterCk      = Function: boolean;
     tDefFormulaBuild  = Function(st: string; var fmrec: GSR_FormRec): boolean;
     tDefFormulaXtract = Function(var st: string; fmrec: GSR_FormRec): boolean;

       {Extended Hacking procedures}

     tSetDBExt  = Procedure(vDBExt:String);

var Alias             : tAlias;
    ALock             : tALock;
    DBAppend          : tDBAppend;
    ClearRecord       : tClearRecord;
    CloseDataBases    : tCloseDataBases;
    CopyStructure     : tCopyStructure;
    CopyTo            : tCopyTo;
    CurrentArea       : tCurrentArea;
    Date              : tDate;
    DBF               : tDBF;
    DBFError          : tDBFError;
    dBOF              : tdBOF;
    Deleted           : tDeleted;
    DeleteRec         : tDeleteRec;
    dEOF              : tdEOF;
    Field             : tField;
    FieldCount        : tFieldCount;
    FieldDec          : tFieldDec;
    FieldLen          : tFieldLEn;
    FieldNo           : tFieldNo;
    FieldType         : tFieldType;
    FileExist         : tFileExist;
    Find              : tFind;
    FLock             : tFLock;
    FlushDBF          : tFlushDBF;
    Found             : tFound;
    Go                : tGo;
    GoBottom          : tGoBottom;
    GoTop             : tGoTop;
    Index             : tIndex;
    IndexOn           : tIndexOn;
    LUpdate           : tLUpdate;
    Pack              : tPack;
    RecallRec         : tRecallRec;
    RecCount          : tRecCount;
    RecNo             : tRecNo;
    RecSize           : tRecSize;
    Reindex           : tReIndex;
    Replace           : tReplace;
    RLock             : tRLock;
    Select            : tSelect;
    SetCenturyOff     : tSetCenturyOff;
    SetCenturyOn      : tSetCenturyOn;
    SetDateStyle      : tSetDateStyle;
    SetDBFCacheOff    : tSetDBFCacheOff;
    SetDBFCacheOn     : tSetDBFCacheOn;
    SetDeletedOff     : tSetDeletedOff;
    SetDeletedOn      : tSetDeletedOn;
    SetErrorCapture   : tSetErrorCapture;
    SetExactOff       : tSetExactOff;
    SetExactOn        : tSetExactOn;
    SetExclusiveOff   : tSetExclusiveOff;
    SetExclusiveOn    : tSetExclusiveOn;
    SetFileHandles    : tSetFileHandles;
    SetFilterThru     : tSetFilterThru;
    SetFlushOff       : tSetFlushOff;
    SetFlushOnAppend  : tSetFlushOnAppend;
    SetFlushOnWrite   : tSetFlushOnWrite;
    SetFormulaProcess : tSetFormulaProcess;
    SetLockOff        : tSetLockOff;
    SetLockOn         : tSetLockOn;
    SetOrderTo        : tSetOrderTo;
    SetStatusCapture  : tSetStatusCapture;
    Skip              : tSkip;
    SortTo            : tSortTo;
    Unlock            : tUnlock;
    UnlockAll         : tUnlockAll;
    Use               : tUse;
    Zap               : tZap;

     {dBase field handling routines}

    AssignMemo        : tAssignMemo;
    SaveMemo          : tSaveMemo;
    MemoClear         : tMemoClear;
    MemoGetLine       : tMemoGetLine;
    MemoInsLine       : tMemoInsLine;
    MemoGet           : tMemoGet;
    MemoGetN          : tMemoGetN;
    MemoWidth         : tMemoWidth;
    MemoLines         : tMemoLines;
    MemoPut           : tMemoPut;
    MemoPutN          : tMemoPutN;
    DateGet           : tDateGet;
    DateGetN          : tDateGetN;
    DatePut           : tDatePut;
    DatePutN          : tDatePutN;
    FieldGet          : tFieldGet;
    FieldGetN         : tFieldGetN;
    FieldPut          : tFieldPut;
    FieldPutN         : tFieldPutN;
    LogicGet          : tLogicGet;
    LogicGetN         : tLogicGetN;
    LogicPut          : tLogicPut;
    LogicPutN         : tLogicPutN;
    NumberGet         : tNumberGet;
    NumberGetN        : tNumberGetN;
    NumberPut         : tNumberPut;
    NumberPutN        : tNumberPutN;
    StringGet         : tStringGet;
    StringGetN        : tStringGetN;
    StringPut         : tStringPut;
    StringPutN        : tStringPutN;

     {dBase type functions}

    CTOD              : tCTOD;
    DTOC              : tDTOC;
    DTOS              : tDTOS;

     {Default capture procedures}

   DefCapError        : tDefCapError;
   DefCapStatus       : tDefCapStatus;
   DefFilterCk        : tDefFilterCk;
   DefFormulaBuild    : tDefFormulaBuild;
   DefFormulaXtract   : tDefFormulaXtract;

     {Extended Hacking procedures}

   SetDBExt           : tSetDBExt;

function EnableDynalink (DynaNum : Longint) : Boolean; {Try to enable dynalink DynaNum}
function EnableAllDynaLinks                 : Boolean; {Try to enable all dynalinks   }
function LoadDBModule                       : Boolean; {Try to Load .DLL              }
function FreeDBModule                       : Boolean; {Try to UnLoad .DLL            }

type tErrorList = array [1..MaxExports] of longint;
var  DLLError   : Longint; {Error occurred while loading DLL or enabling instances}
     ErrorList  : ^tErrorList;


Implementation { 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� }

Uses
 {$IfDef Os2}
  Os2Def, Os2Base;    { Vp/2 version         }
 {$Else}
  WinProcs, WinTypes; { DPMI/Uindous version }
 {$EndIf}

Var
 {$IfDef Os2}
  ModuleHandle : hModule; {Os/2 Module handle}
 {$Else}
  ModuleHandle : THandle; {Dos Module handle }
 {$EndIf}


{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
{   굇 EnableDynalink 굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
{
   NOTES:
   this function uses std. DosQueryProcAddr to enable module DynaNum.
   EnableDynaLink is true if no error occurs. DllError will contain the
   rc value! If DllError is <> 0 when EnableDynaLink is called then none is done
   and DllError will take -3 value that means an unknow error occurred before;
   so if you want to use again EDL you must put DllError := 0.
   -2 DllError is raised if the DynaNum doesn't exist!
   Only functions numbers are used to get more speed for long processes!

   Note for sytax:
     rc := DosQueryProcAddr(  // ! TRY TO ENABLE DYNALINK FOR MODULE DynaNum !
     ModuleHandle,            // Handle to module
     DynaNum,                 // No ProcName specified
     nil,                     // ProcName (not specified)
     @Alias...);              // Address returned
}
function EnableDynaLink (DynaNum : Longint) : Boolean;
{$IfDef Os2}
Var rc : ApiRet; {Return code}
begin
 if DllError = 0 then begin
  Case DynaNum of
      1 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Alias);
      2 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @ALock);
      3 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @DBAppend);
      4 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @ClearRecord);
      5 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @CloseDataBases);
      6 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @CopyStructure);
      7 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @CopyTo);
      8 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @CurrentArea);
      9 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Date);
     10 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @DBF);
     11 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @DBFError);
     12 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @dBOF);
     13 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Deleted);
     14 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @DeleteRec);
     15 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @dEOF);
     16 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Field);
     17 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @FieldCount);
     18 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @FieldDec);
     19 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @FieldLen);
     20 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @FieldNo);
     21 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @FieldType);
     22 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @FileExist);
     23 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Find);
     24 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @FLock);
     25 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @FlushDBF);
     26 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Found);
     27 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Go);
     28 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @GoBottom);
     29 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @GoTop);
     30 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Index);
     31 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @IndexOn);
     32 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @LUpdate);
     33 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Pack);
     34 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @RecallRec);
     35 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @RecCount);
     36 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @RecNo);
     37 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @RecSize);
     38 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Reindex);
     39 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Replace);
     40 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @RLock);
     41 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Select);
     42 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetCenturyOff);
     43 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetCenturyOn);
     44 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetDateStyle);
     45 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetDBFCacheOff);
     46 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetDBFCacheOn);
     47 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetDeletedOff);
     48 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetDeletedOn);
     49 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetErrorCapture);
     50 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetExactOff);
     51 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetExactOn);
     52 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetExclusiveOff);
     53 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetExclusiveOn);
     54 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetFileHandles);
     55 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetFilterThru);
     56 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetFlushOff);
     57 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetFlushOnAppend);
     58 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetFlushOnWrite);
     59 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetFormulaProcess);
     60 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetLockOff);
     61 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetLockOn);
     62 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetOrderTo);
     63 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetStatusCapture);
     64 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Skip);
     65 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SortTo);
     66 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Unlock);
     67 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @UnlockAll);
     68 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Use);
     69 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @Zap);

     80 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @AssignMemo);
     81 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SaveMemo);
     82 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @MemoClear);
     83 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @MemoGetLine);
     84 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @MemoInsLine);
     85 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @MemoGet);
     86 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @MemoGetN);
     87 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @MemoWidth);
     88 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @MemoLines);
     89 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @MemoPut);
     90 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @MemoPutN);
     91 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @DateGet);
     92 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @DateGetN);
     93 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @DatePut);
     94 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @DatePutN);
     95 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @FieldGet);
     96 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @FieldGetN);
     97 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @FieldPut);
     98 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @FieldPutN);
     99 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @LogicGet);
    100 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @LogicGetN);
    101 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @LogicPut);
    102 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @LogicPutN);
    103 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @NumberGet);
    104 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @NumberGetN);
    105 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @NumberPut);
    106 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @NumberPutN);
    107 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @StringGet);
    108 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @StringGetN);
    109 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @StringPut);
    110 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @StringPutN);

    120 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @CTOD);
    121 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @DTOC);
    122 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @DTOS);

    130 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @DefCapError);
    131 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @DefCapStatus);
    132 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @DefFilterCk);
    133 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @DefFormulaBuild);
    134 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @DefFormulaXtract);

    140 : rc := DosQueryProcAddr(ModuleHandle, DynaNum, nil, @SetDBExt);
   else rc := -2; {dynalink not found}
  end; {case}
 end else rc := -3; {unknown error}
 if DllError <> -1 then DllError := rc;
 EnableDynaLink := DllError = No_Error;
{$Else}
begin
 if DllError = 0 then begin
  Case DynaNum of
      1 : begin
           @Alias             := GetProcAddress(ModuleHandle,'Alias');
           if @Alias = nil then DllError := -2;
          end;
      2 : begin
           @ALock             := GetProcAddress(ModuleHandle,'ALock');
           if @ALock = nil then DllError := -2;
          end;
      3 : begin
           @DBAppend          := GetProcAddress(ModuleHandle,'DBAppend');
           if @DBAppend = nil then DllError := -2;
          end;
      4 : begin
           @ClearRecord       := GetProcAddress(ModuleHandle,'ClearRecord');
           if @ClearRecord = nil then DllError := -2;
          end;
      5 : begin
           @CloseDataBases    := GetProcAddress(ModuleHandle,'CloseDataBases');
           if @CloseDataBases = nil then DllError := -2;
          end;
      6 : begin
           @CopyStructure     := GetProcAddress(ModuleHandle,'CopyStructure');
           if @CopyStructure = nil then DllError := -2;
          end;
      7 : begin
           @CopyTo            := GetProcAddress(ModuleHandle,'CopyTo');
           if @CopyTo = nil then DllError := -2;
          end;
      8 : begin
           @CurrentArea       := GetProcAddress(ModuleHandle,'CurrentArea');
           if @CurrentArea = nil then DllError := -2;
          end;
      9 : begin
           @Date              := GetProcAddress(ModuleHandle,'Date');
           if @Date = nil then DllError := -2;
          end;
     10 : begin
           @DBF               := GetProcAddress(ModuleHandle,'DBF');
           if @DBF = nil then DllError := -2;
          end;
     11 : begin
           @DBFError          := GetProcAddress(ModuleHandle,'DBFError');
           if @DBFError = nil then DllError := -2;
          end;
     12 : begin
           @dBOF              := GetProcAddress(ModuleHandle,'dBOF');
           if @dBOF = nil then DllError := -2;
          end;
     13 : begin
           @Deleted           := GetProcAddress(ModuleHandle,'Deleted');
           if @Deleted = nil then DllError := -2;
          end;
     14 : begin
           @DeleteRec         := GetProcAddress(ModuleHandle,'DeleteRec');
           if @DeleteRec = nil then DllError := -2;
          end;
     15 : begin
           @dEOF              := GetProcAddress(ModuleHandle,'dEOF');
           if @dEOF = nil then DllError := -2;
          end;
     16 : begin
           @Field             := GetProcAddress(ModuleHandle,'Field');
           if @Field = nil then DllError := -2;
          end;
     17 : begin
           @FieldCount        := GetProcAddress(ModuleHandle,'FieldCount');
           if @FieldCount = nil then DllError := -2;
          end;
     18 : begin
           @FieldDec          := GetProcAddress(ModuleHandle,'FieldDec');
           if @FieldDec = nil then DllError := -2;
          end;
     19 : begin
           @FieldLen          := GetProcAddress(ModuleHandle,'FieldLen');
           if @FieldLen = nil then DllError := -2;
          end;
     20 : begin
           @FieldNo           := GetProcAddress(ModuleHandle,'FieldNo');
           if @FieldNo = nil then DllError := -2;
          end;
     21 : begin
           @FieldType         := GetProcAddress(ModuleHandle,'FieldType');
           if @FieldType = nil then DllError := -2;
          end;
     22 : begin
           @FileExist         := GetProcAddress(ModuleHandle,'FileExist');
           if @FileExist = nil then DllError := -2;
          end;
     23 : begin
           @Find              := GetProcAddress(ModuleHandle,'Find');
           if @Find = nil then DllError := -2;
          end;
     24 : begin
           @FLock             := GetProcAddress(ModuleHandle,'FLock');
           if @FLock = nil then DllError := -2;
          end;
     25 : begin
           @FlushDBF          := GetProcAddress(ModuleHandle,'FlushDBF');
           if @FlushDBF = nil then DllError := -2;
          end;
     26 : begin
           @Found             := GetProcAddress(ModuleHandle,'Found');
           if @Found = nil then DllError := -2;
          end;
     27 : begin
           @Go                := GetProcAddress(ModuleHandle,'Go');
           if @Go = nil then DllError := -2;
          end;
     28 : begin
           @GoBottom          := GetProcAddress(ModuleHandle,'GoBottom');
           if @GoBottom = nil then DllError := -2;
          end;
     29 : begin
           @GoTop             := GetProcAddress(ModuleHandle,'GoTop');
           if @GoTop = nil then DllError := -2;
          end;
     30 : begin
           @Index             := GetProcAddress(ModuleHandle,'Index');
           if @Index = nil then DllError := -2;
          end;
     31 : begin
           @IndexOn           := GetProcAddress(ModuleHandle,'IndexOn');
           if @IndexOn = nil then DllError := -2;
          end;
     32 : begin
           @LUpdate           := GetProcAddress(ModuleHandle,'LUpdate');
           if @LUpdate = nil then DllError := -2;
          end;
     33 : begin
           @Pack              := GetProcAddress(ModuleHandle,'Pack');
           if @Pack = nil then DllError := -2;
          end;
     34 : begin
           @RecallRec         := GetProcAddress(ModuleHandle,'RecallRec');
           if @RecallRec = nil then DllError := -2;
          end;
     35 : begin
           @RecCount          := GetProcAddress(ModuleHandle,'RecCount');
           if @RecCount = nil then DllError := -2;
          end;
     36 : begin
           @RecNo             := GetProcAddress(ModuleHandle,'RecNo');
           if @RecNo = nil then DllError := -2;
          end;
     37 : begin
           @RecSize           := GetProcAddress(ModuleHandle,'RecSize');
           if @RecSize = nil then DllError := -2;
          end;
     38 : begin
           @Reindex           := GetProcAddress(ModuleHandle,'Reindex');
           if @ReIndex = nil then DllError := -2;
          end;
     39 : begin
           @Replace           := GetProcAddress(ModuleHandle,'Replace');
           if @Replace = nil then DllError := -2;
          end;
     40 : begin
           @RLock             := GetProcAddress(ModuleHandle,'RLock');
           if @RLock = nil then DllError := -2;
          end;
     41 : begin
           @Select            := GetProcAddress(ModuleHandle,'Select');
           if @Select = nil then DllError := -2;
          end;
     42 : begin
           @SetCenturyOff     := GetProcAddress(ModuleHandle,'SetCenturyOff');
           if @SetCenturyOff = nil then DllError := -2;
          end;
     43 : begin
           @SetCenturyOn      := GetProcAddress(ModuleHandle,'SetCenturyOn');
           if @SetCenturyOn = nil then DllError := -2;
          end;
     44 : begin
           @SetDateStyle      := GetProcAddress(ModuleHandle,'SetDateStyle');
           if @SetDateStyle = nil then DllError := -2;
          end;
     45 : begin
           @SetDBFCacheOff    := GetProcAddress(ModuleHandle,'SetDBFCacheOff');
           if @SetDBFCacheOff = nil then DllError := -2;
          end;
     46 : begin
           @SetDBFCacheOn     := GetProcAddress(ModuleHandle,'SetDBFCacheOn');
           if @SetDBFCacheOn = nil then DllError := -2;
          end;
     47 : begin
           @SetDeletedOff     := GetProcAddress(ModuleHandle,'SetDeletedOff');
           if @SetDeletedOff = nil then DllError := -2;
          end;
     48 : begin
           @SetDeletedOn      := GetProcAddress(ModuleHandle,'SetDeletedOn');
           if @SetDeletedOn = nil then DllError := -2;
          end;
     49 : begin
           @SetErrorCapture   := GetProcAddress(ModuleHandle,'SetErrorCapture');
           if @SetErrorCapture = nil then DllError := -2;
          end;
     50 : begin
           @SetExactOff       := GetProcAddress(ModuleHandle,'SetExactOff');
           if @SetExactOff = nil then DllError := -2;
          end;
     51 : begin
           @SetExactOn        := GetProcAddress(ModuleHandle,'SetExactOn');
           if @SetExactOn = nil then DllError := -2;
          end;
     52 : begin
           @SetExclusiveOff   := GetProcAddress(ModuleHandle,'SetExclusiveOff');
           if @SetExclusiveOff = nil then DllError := -2;
          end;
     53 : begin
           @SetExclusiveOn    := GetProcAddress(ModuleHandle,'SetExclusiveOn');
           if @SetExclusiveOn = nil then DllError := -2;
          end;
     54 : begin
           @SetFileHandles    := GetProcAddress(ModuleHandle,'SetFileHandles');
           if @SetFileHandles = nil then DllError := -2;
          end;
     55 : begin
           @SetFilterThru     := GetProcAddress(ModuleHandle,'SetFilterThru');
           if @SetFilterThru = nil then DllError := -2;
          end;
     56 : begin
           @SetFlushOff       := GetProcAddress(ModuleHandle,'SetFlushOff');
           if @SetFlushOff = nil then DllError := -2;
          end;
     57 : begin
           @SetFlushOnAppend  := GetProcAddress(ModuleHandle,'SetFlushOnAppend');
           if @SetFlushOnAppend = nil then DllError := -2;
          end;
     58 : begin
           @SetFlushOnWrite   := GetProcAddress(ModuleHandle,'SetFlushOnWrite');
           if @SetFlushOnWrite = nil then DllError := -2;
          end;
     59 : begin
           @SetFormulaProcess := GetProcAddress(ModuleHandle,'SetFormulaProcess');
           if @SetFormulaProcess = nil then DllError := -2;
          end;
     60 : begin
           @SetLockOff        := GetProcAddress(ModuleHandle,'SetLockOff');
           if @SetLockOff = nil then DllError := -2;
          end;
     61 : begin
           @SetLockOn         := GetProcAddress(ModuleHandle,'SetLockOn');
           if @SetLockOn = nil then DllError := -2;
          end;
     62 : begin
           @SetOrderTo        := GetProcAddress(ModuleHandle,'SetOrderTo');
           if @SetOrderTo = nil then DllError := -2;
          end;
     63 : begin
           @SetStatusCapture  := GetProcAddress(ModuleHandle,'SetStatusCapture');
           if @SetStatusCapture = nil then DllError := -2;
          end;
     64 : begin
           @Skip              := GetProcAddress(ModuleHandle,'Skip');
           if @Skip = nil then DllError := -2;
          end;
     65 : begin
           @SortTo            := GetProcAddress(ModuleHandle,'SortTo');
           if @SortTo = nil then DllError := -2;
          end;
     66 : begin
           @Unlock            := GetProcAddress(ModuleHandle,'Unlock');
           if @Unlock = nil then DllError := -2;
          end;
     67 : begin
           @UnLockAll         := GetProcAddress(ModuleHandle,'UnlockAll');
           if @UnLockAll = nil then DllError := -2;
          end;
     68 : begin
           @Use               := GetProcAddress(ModuleHandle,'Use');
           if @Use = nil then DllError := -2;
          end;
     69 : begin
           @Zap               := GetProcAddress(ModuleHandle,'Zap');
           if @Zap = nil then DllError := -2;
          end;

     80 : begin
           @AssignMemo        := GetProcAddress(ModuleHandle,'AssignMemo');
           if @AssignMemo = nil then DllError := -2;
          end;
     81 : begin
           @SaveMemo          := GetProcAddress(ModuleHandle,'SaveMemo');
           if @SaveMemo = nil then DllError := -2;
          end;
     82 : begin
           @MemoClear         := GetProcAddress(ModuleHandle,'MemoClear');
           if @MemoClear = nil then DllError := -2;
          end;
     83 : begin
           @MemoGetLine       := GetProcAddress(ModuleHandle,'MemoGetLine');
           if @MemoGetLine = nil then DllError := -2;
          end;
     84 : begin
           @MemoInsLine       := GetProcAddress(ModuleHandle,'MemoInsLine');
           if @MemoInsLine = nil then DllError := -2;
          end;
     85 : begin
           @MemoGet           := GetProcAddress(ModuleHandle,'MemoGet');
           if @MemoGet = nil then DllError := -2;
          end;
     86 : begin
           @MemoGetN          := GetProcAddress(ModuleHandle,'MemoGetN');
           if @MemoGetN = nil then DllError := -2;
          end;
     87 : begin
           @MemoWidth         := GetProcAddress(ModuleHandle,'MemoWidth');
           if @MemoWidth = nil then DllError := -2;
          end;
     88 : begin
           @MemoLines         := GetProcAddress(ModuleHandle,'MemoLines');
           if @MemoLines = nil then DllError := -2;
          end;
     89 : begin
           @MemoPut           := GetProcAddress(ModuleHandle,'MemoPut');
           if @MemoPut = nil then DllError := -2;
          end;
     90 : begin
           @MemoPutN          := GetProcAddress(ModuleHandle,'MemoPutN');
           if @MemoPutN = nil then DllError := -2;
          end;
     91 : begin
           @DateGet           := GetProcAddress(ModuleHandle,'DateGet');
           if @DateGet = nil then DllError := -2;
          end;
     92 : begin
           @DateGetN          := GetProcAddress(ModuleHandle,'DateGetN');
           if @DateGetN = nil then DllError := -2;
          end;
     93 : begin
           @DatePut           := GetProcAddress(ModuleHandle,'DatePut');
           if @DatePut = nil then DllError := -2;
          end;
     94 : begin
           @DatePutN          := GetProcAddress(ModuleHandle,'DatePutN');
           if @DatePutN = nil then DllError := -2;
          end;
     95 : begin
           @FieldGet          := GetProcAddress(ModuleHandle,'FieldGet');
           if @FieldGet = nil then DllError := -2;
          end;
     96 : begin
           @FieldGetN         := GetProcAddress(ModuleHandle,'FieldGetN');
           if @FieldGetN = nil then DllError := -2;
          end;
     97 : begin
           @FieldPut          := GetProcAddress(ModuleHandle,'FieldPut');
           if @FieldPut = nil then DllError := -2;
          end;
     98 : begin
           @FieldPutN         := GetProcAddress(ModuleHandle,'FieldPutN');
           if @FieldPutN = nil then DllError := -2;
          end;
     99 : begin
           @LogicGet          := GetProcAddress(ModuleHandle,'LogicGet');
           if @LogicGet = nil then DllError := -2;
          end;
    100 : begin
           @LogicGetN         := GetProcAddress(ModuleHandle,'LogicGetN');
           if @LogicGetN = nil then DllError := -2;
          end;
    101 : begin
           @LogicPut          := GetProcAddress(ModuleHandle,'LogicPut');
           if @LogicPut = nil then DllError := -2;
          end;
    102 : begin
           @LogicPutN         := GetProcAddress(ModuleHandle,'LogicPutN');
           if @LogicPutN = nil then DllError := -2;
          end;
    103 : begin
           @NumberGet         := GetProcAddress(ModuleHandle,'NumberGet');
           if @NumberGet = nil then DllError := -2;
          end;
    104 : begin
           @NumberGetN        := GetProcAddress(ModuleHandle,'NumberGetN');
           if @NumberGetN = nil then DllError := -2;
          end;
    105 : begin
           @NumberPut         := GetProcAddress(ModuleHandle,'NumberPut');
           if @NumberPut = nil then DllError := -2;
          end;
    106 : begin
           @NumberPutN        := GetProcAddress(ModuleHandle,'NumberPutN');
           if @NumberPutN = nil then DllError := -2;
          end;
    107 : begin
           @StringGet         := GetProcAddress(ModuleHandle,'StringGet');
           if @StringGet = nil then DllError := -2;
          end;
    108 : begin
           @StringGetN        := GetProcAddress(ModuleHandle,'StringGetN');
           if @StringGetN = nil then DllError := -2;
          end;
    109 : begin
           @StringPut         := GetProcAddress(ModuleHandle,'StringPut');
           if @StringPut = nil then DllError := -2;
          end;
    110 : begin
           @StringPutN        := GetProcAddress(ModuleHandle,'StringPutN');
           if @StringPutN = nil then DllError := -2;
          end;

    120 : begin
           @CTOD := GetProcAddress(ModuleHandle,'CTOD');
           if @CTOD = nil then DllError := -2;
          end;
    121 : begin
           @DTOC := GetProcAddress(ModuleHandle,'DTOC');
           if @DTOC = nil then DllError := -2;
          end;
    122 : begin
           @DTOS := GetProcAddress(ModuleHandle,'DTOS');
           if @DTOS = nil then DllError := -2;
          end;

    130 : begin
           @DefCapError      := GetProcAddress(ModuleHandle,'DefCapError');
           if @DefCapError = nil then DllError := -2;
          end;
    131 : begin
           @DefCapStatus     := GetProcAddress(ModuleHandle,'DefCapStatus');
           if @DefCapStatus = nil then DllError := -2;
          end;
    132 : begin
           @DefFilterCk      := GetProcAddress(ModuleHandle,'DefFilterCk');
           if @DefFilterCk = nil then DllError := -2;
          end;
    133 : begin
           @DefFormulaBuild  := GetProcAddress(ModuleHandle,'DefFormulaBuild');
           if @DefFormulaBuild = nil then DllError := -2;
          end;
    134 : begin
           @DefFormulaXtract := GetProcAddress(ModuleHandle,'DefFormulaXtract');
           if @DefFormulaXtract = nil then DllError := -2;
          end;

    140 : begin
           @SetDBExt := GetProcAddress(ModuleHandle,'SetDBExt');
           if @SetDBExt = nil then DllError := -2;
          end;
   else DllError := -2; {dynalink not found}
  end; {case}
 end else DllError := -3; {unknown error}
 EnableDynaLink := DllError = 0;
{$EndIf}
end; {EnableDynaLink}


{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
{   굇 EnableAllDynalinks 굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
{
   NOTES:
   this function uses EnableDynalink to enable all modules in the library.
   DllError will take the number of the errors occurred during process.
   ErrorList is raised with the list of errors for each module.
   -3 DllError is raised if a previous error is found!
}
function EnableAllDynaLinks : Boolean;
var Count    : longint;
    ErrCount : longint;

 procedure EDL(c:longint); {SubDynaLinks loader}
 begin
  EnableDynaLink(c);
  ErrorList^[c] := DllError;
  if DllError <> 0 then Inc(ErrCount);
  DllError := 0;
 end;

begin
 if DllError = 0 then begin
  ErrCount := 0;
  if MaxAvail > SizeOf(tErrorList) then GetMem(ErrorList, SizeOf(tErrorList))
   else ErrorList := nil;
  FillChar(ErrorList^, SizeOf(tErrorList), 0);
  for Count :=   1 to  69 do EDL(Count); {first 69 modules}
  for Count :=  80 to 110 do EDL(Count); {next 30 modules }
  for Count := 120 to 122 do EDL(Count); {next 3 modules  }
  for Count := 130 to 134 do EDL(Count); {next 5 modules  }
      Count := 140;          EDL(Count); {the last module }
  if ErrCount = 0 then
    if ErrorList <> nil then
     begin
      FreeMem(ErrorList, SizeOf(tErrorList));
      ErrorList := nil;
     end; {if ErroList...}
 end else ErrCount := -3; {a previous error occurred!}
 DllError := ErrCount;
 EnableAllDynalinks := ErrCount = 0;
end; {EnableAllDynalinks}


{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
{   굇 LoadDBModule 굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
{
   NOTES:
   this function uses std. DosLoadModule to load the dbDLLName. It will be true
   if no error occurs. DllError will take the 'rc' value.
}
function LoadDBModule : Boolean;
{$IfDef Os2}
Var LoadError  : Array[0..255] of Char; {Area for Load failure information}
    rc         : ApiRet;                {Return code                      }
begin
  rc := DosLoadModule(       { ! TRY TO LOAD dbDLL !      }
    LoadError,               { Failure information buffer }
    sizeof(LoadError),       { Size of buffer             }
    dbDLLName,               { Module to load             }
    ModuleHandle);           { Module handle returned     }
  DllError := rc;
  LoadDBModule := DllError = No_Error;
{$Else}
Begin
 ModuleHandle := LoadLibrary(dbDLLName);
 if ModuleHandle >= 32 then DllError := 0
  else DllError := ModuleHandle;
 LoadDbModule := DllError = 0; {Dll loaded}
{$EndIf}
end; {LoadDBModule}


{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
{   굇 FreeDBModule 굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
{
   NOTES:
   this function uses std. DosFreeModule to free the dbDLLName. It will be true
   if no error occurs. DllError will take the 'rc' value.
}
function FreeDBModule : Boolean;
{$IfDef Os2}
var rc : ApiRet; {Return code}
begin
  rc := DosFreeModule(ModuleHandle);
  if ErrorList <> nil then FreeMem(ErrorList, SizeOf(tErrorList));
  DllError := rc;
  FreeDBModule := DllError = No_Error;
  if DllError = No_Error then DllError := -1; {start code for DLL reload}
{$Else}
Begin
FreeLibrary(ModuleHandle);
if ErrorList <> nil then FreeMem(ErrorList, SizeOf(tErrorList));
DllError := -1; {start code for DLL reload}
{$EndIf}
end; {FreeDBModule}


{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
{  굇 DBHeapErr 굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
{
   NOTES:
   New Heap Manager! ;^)
}

function DBHeapErr( Size: Integer ): Integer;
begin
 DBHeapErr := 1;
end;



begin
 HeapError := @DBHeapErr; {new heap manager, usually you should use this function in the root program}
 DllError  := -1;         {you must use LoadDBModule to change this value}
 ErrorList := nil;        {you must use EnableDynaLink to change this value}
end.
