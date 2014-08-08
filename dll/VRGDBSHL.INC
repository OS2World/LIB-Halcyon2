{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                  dBase III/IV DLL File Loader/Shell

           VRGDBSHL (C) 1996 of ThE ToY Of Virtual Reality Group

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       The 'Virtual Reality Group DB (III/IV) Shell' provide
       a complete shell to the VRGDBENG.DLL, with loader/unloader
       for "STATIC" linkable library.

       Simply add this code to your program and provide it the
       VRGDBENG.DLL recompiled with the 'USELIB' switch!

       Under Dos add 'const dbDLLName  = 'VRGDBENG';' and
       include 'VRGDBSHL.INC' in the main source code!

       Under Vp/2 add 'const dbDLLName  = 'VRGDBENG';' and
       put  '$Dynamic System', '$L VRGDBENG.LIB' and after all
       include 'VRGDBSHL.INC' in the main source code!

{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

  type DateTypes = (American,ANSI,British,French,German,Italian,Japan,USA, MDY, DMY, YMD);  {GSOB_DTE.PAS}
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

 {// Exportable functions declared here //}

 Function   Alias : string;                                       far; external dbDLLName;
 Function   ALock : boolean;                                      far; external dbDLLName;
 Procedure  DBAppend;                                             far; external dbDLLName;
 Procedure  ClearRecord;                                          far; external dbDLLName;
 Procedure  CloseDataBases;                                       far; external dbDLLName;
 Procedure  CopyStructure(filname : string);                      far; external dbDLLName;
 Procedure  CopyTo(filname : string);                             far; external dbDLLName;
 Function   CurrentArea : byte;                                   far; external dbDLLName;
 Function   Date: longint;                                        far; external dbDLLName;
 Function   DBF : string;                                         far; external dbDLLName;
 Function   DBFError : Integer;                                   far; external dbDLLName;
 Function   dBOF : boolean;                                       far; external dbDLLName;
 Function   Deleted : boolean;                                    far; external dbDLLName;
 Procedure  DeleteRec;                                            far; external dbDLLName;
 Function   dEOF : boolean;                                       far; external dbDLLName;
 Function   Field(n : byte) : string;                             far; external dbDLLName;
 Function   FieldCount : byte;                                    far; external dbDLLName;
 Function   FieldDec(n : byte) : byte;                            far; external dbDLLName;
 Function   FieldLen(n : byte) : byte;                            far; external dbDLLName;
 Function   FieldNo(fn : string) : byte;                          far; external dbDLLName;
 Function   FieldType(n : byte) : char;                           far; external dbDLLName;
 Function   FileExist(FName : string) : boolean;                  far; external dbDLLName;
 Procedure  Find(ss : string);                                    far; external dbDLLName;
 Function   FLock : boolean;                                      far; external dbDLLName;
 Procedure  FlushDBF;                                             far; external dbDLLName;
 Function   Found : boolean;                                      far; external dbDLLName;
 Procedure  Go(n : longint);                                      far; external dbDLLName;
 Procedure  GoBottom;                                             far; external dbDLLName;
 Procedure  GoTop;                                                far; external dbDLLName;
 Procedure  Index(INames : string);                               far; external dbDLLName;
 Procedure  IndexOn(filname, formla : string);                    far; external dbDLLName;
 Function   LUpdate: string;                                      far; external dbDLLName;
 Procedure  Pack;                                                 far; external dbDLLName;
 Procedure  RecallRec;                                            far; external dbDLLName;
 Function   RecCount : longint;                                   far; external dbDLLName;
 Function   RecNo : longint;                                      far; external dbDLLName;
 Function   RecSize : Word;                                       far; external dbDLLName;
 Procedure  Reindex;                                              far; external dbDLLName;
 Procedure  Replace;                                              far; external dbDLLName;
 Function   RLock : boolean;                                      far; external dbDLLName;
 Procedure  Select(Obj : byte);                                   far; external dbDLLName;
 Procedure  SetCenturyOff;                                        far; external dbDLLName;
 Procedure  SetCenturyOn;                                         far; external dbDLLName;
 Procedure  SetDateStyle(dt : DateTypes);                         far; external dbDLLName;
 Procedure  SetDBFCacheOff;                                       far; external dbDLLName;
 Procedure  SetDBFCacheOn;                                        far; external dbDLLName;
 Procedure  SetDeletedOff;                                        far; external dbDLLName;
 Procedure  SetDeletedOn;                                         far; external dbDLLName;
 Procedure  SetErrorCapture(UserRoutine : CaptureError);          far; external dbDLLName;
 Procedure  SetExactOff;                                          far; external dbDLLName;
 Procedure  SetExactOn;                                           far; external dbDLLName;
 Procedure  SetExclusiveOff;                                      far; external dbDLLName;
 Procedure  SetExclusiveOn;                                       far; external dbDLLName;
 Procedure  SetFileHandles(hndls : byte);                         far; external dbDLLName;
 Procedure  SetFilterThru(UserRoutine : FilterCheck);             far; external dbDLLName;
 Procedure  SetFlushOff;                                          far; external dbDLLName;
 Procedure  SetFlushOnAppend;                                     far; external dbDLLName;
 Procedure  SetFlushOnWrite;                                      far; external dbDLLName;
 Procedure  SetFormulaProcess(UserRoutine1 : FormulaProc; UserRoutine2: XtractFunc); far; external dbDLLName;
 Procedure  SetLockOff;                                           far; external dbDLLName;
 Procedure  SetLockOn;                                            far; external dbDLLName;
 Procedure  SetOrderTo(order : Integer);                          far; external dbDLLName;
 Procedure  SetStatusCapture(UserRoutine : CaptureStatus);        far; external dbDLLName;
 Procedure  Skip(n : longint);                                    far; external dbDLLName;
 Procedure  SortTo(filname, formla: string; sortseq: SortStatus); far; external dbDLLName;
 Procedure  Unlock;                                               far; external dbDLLName;
 Procedure  UnlockAll;                                            far; external dbDLLName;
 Procedure  Use(FName : string);                                  far; external dbDLLName;
 Procedure  Zap;                                                  far; external dbDLLName;

     {dBase field handling routines}

 Procedure  AssignMemo(st, nm : string);                          far; external dbDLLName;
 Procedure  SaveMemo(st, nm : string);                            far; external dbDLLName;
 Procedure  MemoClear;                                            far; external dbDLLName;
 Function   MemoGetLine(linenum : Integer) : string;              far; external dbDLLName;
 Procedure  MemoInsLine(linenum : Integer; st : string);          far; external dbDLLName;
 procedure  MemoGet(st : string);                                 far; external dbDLLName;
 procedure  MemoGetN(n : Integer);                                far; external dbDLLName;
 Procedure  MemoWidth(l : Integer);                               far; external dbDLLName;
 function   MemoLines : Integer;                                  far; external dbDLLName;
 procedure  MemoPut(st : string);                                 far; external dbDLLName;
 procedure  MemoPutN(n : Integer);                                far; external dbDLLName;
 Function   DateGet(st : string) : longint;                       far; external dbDLLName;
 Function   DateGetN(n : Integer) : longint;                      far; external dbDLLName;
 Procedure  DatePut(st : string; jdte : longint);                 far; external dbDLLName;
 Procedure  DatePutN(n : Integer; jdte : longint);                far; external dbDLLName;
 Function   FieldGet(fnam : string) : string;                     far; external dbDLLName;
 Function   FieldGetN(fnum : Integer) : string;                   far; external dbDLLName;
 Procedure  FieldPut(fnam, st : string);                          far; external dbDLLName;
 Procedure  FieldPutN(fnum : Integer; st : string);               far; external dbDLLName;
 Function   LogicGet(st : string) : boolean;                      far; external dbDLLName;
 Function   LogicGetN(n : Integer) : boolean;                     far; external dbDLLName;
 Procedure  LogicPut(st : string; b : boolean);                   far; external dbDLLName;
 Procedure  LogicPutN(n : Integer; b : boolean);                  far; external dbDLLName;
 Function   NumberGet(st : string) : FloatNum;                    far; external dbDLLName;
 Function   NumberGetN(n : Integer) : FloatNum;                   far; external dbDLLName;
 Procedure  NumberPut(st : string; r : FloatNum);                 far; external dbDLLName;
 Procedure  NumberPutN(n : Integer; r : FloatNum);                far; external dbDLLName;
 Function   StringGet(fnam : string) : string;                    far; external dbDLLName;
 Function   StringGetN(fnum : Integer) : string;                  far; external dbDLLName;
 Procedure  StringPut(fnam, st : string);                         far; external dbDLLName;
 Procedure  StringPutN(fnum : Integer; st : string);              far; external dbDLLName;

     {dBase type functions}

 function CTOD(strn : string) : longint;                          far; external dbDLLName;
 function DTOC(jul : longint) : string;                           far; external dbDLLName;
 function DTOS(jul : longint) : string;                           far; external dbDLLName;

     {Default capture procedures}

 Procedure DefCapError(Code, Info : Integer);                            far; external dbDLLName;
 Procedure DefCapStatus(stat1,stat2,stat3 : longint);                    far; external dbDLLName;
 Function  DefFilterCk: boolean;                                         far; external dbDLLName;
 Function  DefFormulaBuild(st: string; var fmrec: GSR_FormRec): boolean; far; external dbDLLName;
 Function  DefFormulaXtract(var st: string; fmrec: GSR_FormRec): boolean;far; external dbDLLName;

     {Extended Hacking procedures}

 Procedure SetDBExt(vDBExt:String);                               far; external dbDLLName;

