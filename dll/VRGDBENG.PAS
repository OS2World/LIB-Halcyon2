Library VRGDBENG;
{ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                        dBase III/IV DLL File exporter

           VRGDBENG (C) 1996 of ThE ToY Of Virtual Reality Group

       ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
       The 'Virtual Reality Group DB (III/IV) Engine' provide
       creation of Os/2 and Dos DLL for use of Halcyon/2 as a
       dinamic/static linkable library.

  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
{   ±± MsDos & Uindows DLLs ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±  }
{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
{$IfnDef Os2}
 Uses GSOBSHEL;
 {$D DB III/IV 32 bit Engine - v. 3.5 (c) 1996 The Toy - Virtual Reality Group}
 EXPORTS
   Alias             index  1,
   ALock             index  2,
   DBAppend          index  3,
   ClearRecord       index  4,
   CloseDataBases    index  5,
   CopyStructure     index  6,
   CopyTo            index  7,
   CurrentArea       index  8,
   Date              index  9,
   DBF               index 10,
   DBFError          index 11,
   dBOF              index 12,
   Deleted           index 13,
   DeleteRec         index 14,
   dEOF              index 15,
   Field             index 16,
   FieldCount        index 17,
   FieldDec          index 18,
   FieldLen          index 19,
   FieldNo           index 20,
   FieldType         index 21,
   FileExist         index 22,
   Find              index 23,
   FLock             index 24,
   FlushDBF          index 25,
   Found             index 26,
   Go                index 27,
   GoBottom          index 28,
   GoTop             index 29,
   Index             index 30,
   IndexOn           index 31,
   LUpdate           index 32,
   Pack              index 33,
   RecallRec         index 34,
   RecCount          index 35,
   RecNo             index 36,
   RecSize           index 37,
   Reindex           index 38,
   Replace           index 39,
   RLock             index 40,
   Select            index 41,
   SetCenturyOff     index 42,
   SetCenturyOn      index 43,
   SetDateStyle      index 44,
   SetDBFCacheOff    index 45,
   SetDBFCacheOn     index 46,
   SetDeletedOff     index 47,
   SetDeletedOn      index 48,
   SetErrorCapture   index 49,
   SetExactOff       index 50,
   SetExactOn        index 51,
   SetExclusiveOff   index 52,
   SetExclusiveOn    index 53,
   SetFileHandles    index 54,
   SetFilterThru     index 55,
   SetFlushOff       index 56,
   SetFlushOnAppend  index 57,
   SetFlushOnWrite   index 58,
   SetFormulaProcess index 59,
   SetLockOff        index 60,
   SetLockOn         index 61,
   SetOrderTo        index 62,
   SetStatusCapture  index 63,
   Skip              index 64,
   SortTo            index 65,
   Unlock            index 66,
   UnlockAll         index 67,
   Use               index 68,
   Zap               index 69,

   AssignMemo        index 80,
   SaveMemo          index 81,
   MemoClear         index 82,
   MemoGetLine       index 83,
   MemoInsLine       index 84,
   MemoGet           index 85,
   MemoGetN          index 86,
   MemoWidth         index 87,
   MemoLines         index 88,
   MemoPut           index 89,
   MemoPutN          index 90,
   DateGet           index 91,
   DateGetN          index 92,
   DatePut           index 93,
   DatePutN          index 94,
   FieldGet          index 95,
   FieldGetN         index 96,
   FieldPut          index 97,
   FieldPutN         index 98,
   LogicGet          index 99,
   LogicGetN         index 100,
   LogicPut          index 101,
   LogicPutN         index 102,
   NumberGet         index 103,
   NumberGetN        index 104,
   NumberPut         index 105,
   NumberPutN        index 106,
   StringGet         index 107,
   StringGetN        index 108,
   StringPut         index 109,
   StringPutN        index 110,

   CTOD              index 120,
   DTOC              index 121,
   DTOS              index 122,

   DefCapError        index 130,
   DefCapStatus       index 131,
   DefFilterCk        index 132,
   DefFormulaBuild    index 133,
   DefFormulaXtract   index 134,

   SetDBExt           index 140;
{$EndIf} {Dos flag}



{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
{   ±± Os/2 DLLs ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±  }
{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
{$IfDef Os2}

//  NOTES: {$EXPORTS: ...} parameters.
//ş BYNAME forces the linker to export all interface symbols of units specified in {$Export UnitName} statements as well
//  as all procedures and function exported by means of the Export standard directive to be exported by name. An appropriate
//  import library is created.

//ş BYORDINAL causes symbols to be exported by ordinal numbers. An appropriate import library is created. The names of the
//  exported symbols are still available in the DLL, so they can be imported by name by creating another import library by
//  running the IMPLIB utility on the DLL.

//ş NONAME The same as BYORDINAL, but names of exported symbols are deleted from the DLL. Exported symbols can be imported
//  only by ordinal number by means of the import library that is automatically created by the compiler. This causes the
//  smallest DLLs to be created and is the default setting.



 {$IfDef USELIB}
  // Remember to add this code to your program/library:
  // {$IfDef USELIB}
  //  {$DYNAMIC System, GSOBSHEL}
  //  {$L VRGDBENG.LIB}
  // {$EndIf}
  Uses GSOBSHEL;
  {$EXPORT  System GSOBSHEL}
  {$EXPORT: BYORDINAL}
  {&LINKER
    LIBRARY 'VRGDBENG' INITINSTANCE TERMGLOBAL
    CODE PRELOAD
    DATA PRELOAD MULTIPLE NONSHARED
    DESCRIPTION 'DB III/IV 32 bit Engine - v. 3.5b r1 (c) 1996 The Toy -  Virtual Reality Group'
    STACKSIZE 16384
  }
 {$EndIf} {USELIB flag}



 {$IfDef USELIBSHL}
  // Remember to add this code to your program/library:
  // Uses Use32, GSOB_Var, GSOB_Str, GSOB_DBF, GSOB_DBS, GSOB_Dsk, GSOB_Dte;
  // {$IfDef USELIBSHL}
  //  {$DYNAMIC System, GSOB_Var, GSOB_Str, GSOB_DBF, GSOB_DBS, GSOB_Dsk, GSOB_Dte}
  //  {$L VRGDBENG.LIB}
  // {$EndIf}
  Uses GSOB_Var,
       GSOB_Str,
       GSOB_DBF,
       GSOB_DBS,
       GSOB_Dsk,
       GSOB_Dte;
  {&EXPORT  System}
  {&EXPORT  GSOB_Var, GSOB_Str, GSOB_DBF, GSOB_DBS, GSOB_Dsk, GSOB_Dte}
  {&EXPORT: BYNAME}
  {&LINKER
     LIBRARY 'VRGDBENG' INITINSTANCE TERMGLOBAL
     CODE PRELOAD
     DATA PRELOAD MULTIPLE NONSHARED
     DESCRIPTION 'DB III/IV 32 bit Engine - v. 3.5b r1 (c) 1996 The Toy -  Virtual Reality Group'
     STACKSIZE 16384
  }
 {$EndIf} {USELIBSHL flag}



{$IfnDef USELIB}
 {$IfnDef USELIBSHL}
  Uses Use32, GSOBSHEL;
  {$EXPORT  System, Use32}
  {$Export: BYORDINAL}
  {&LINKER
    LIBRARY 'VRGDBENG' INITINSTANCE TERMGLOBAL
    CODE PRELOAD
    DATA PRELOAD MULTIPLE NONSHARED
    DESCRIPTION 'DB III/IV 32 bit Engine - v. 3.5b r1 (c) 1996 The Toy -  Virtual Reality Group'
    STACKSIZE 16384
    EXPORTS
      Alias             @1 RESIDENTNAME
      ALock             @2 RESIDENTNAME
      DBAppend          @3 RESIDENTNAME
      ClearRecord       @4 RESIDENTNAME
      CloseDataBases    @5 RESIDENTNAME
      CopyStructure     @6 RESIDENTNAME
      CopyTo            @7 RESIDENTNAME
      CurrentArea       @8 RESIDENTNAME
      Date              @9 RESIDENTNAME
      DBF               @10 RESIDENTNAME
      DBFError          @11 RESIDENTNAME
      dBOF              @12 RESIDENTNAME
      Deleted           @13 RESIDENTNAME
      DeleteRec         @14 RESIDENTNAME
      dEOF              @15 RESIDENTNAME
      Field             @16 RESIDENTNAME
      FieldCount        @17 RESIDENTNAME
      FieldDec          @18 RESIDENTNAME
      FieldLen          @19 RESIDENTNAME
      FieldNo           @20 RESIDENTNAME
      FieldType         @21 RESIDENTNAME
      FileExist         @22 RESIDENTNAME
      Find              @23 RESIDENTNAME
      FLock             @24 RESIDENTNAME
      FlushDBF          @25 RESIDENTNAME
      Found             @26 RESIDENTNAME
      Go                @27 RESIDENTNAME
      GoBottom          @28 RESIDENTNAME
      GoTop             @29 RESIDENTNAME
      Index             @30 RESIDENTNAME
      IndexOn           @31 RESIDENTNAME
      LUpdate           @32 RESIDENTNAME
      Pack              @33 RESIDENTNAME
      RecallRec         @34 RESIDENTNAME
      RecCount          @35 RESIDENTNAME
      RecNo             @36 RESIDENTNAME
      RecSize           @37 RESIDENTNAME
      ReIndex           @38 RESIDENTNAME
      Replace           @39 RESIDENTNAME
      RLock             @40 RESIDENTNAME
      Select            @41 RESIDENTNAME
      SetCenturyOff     @42 RESIDENTNAME
      SetCenturyOn      @43 RESIDENTNAME
      SetDateStyle      @44 RESIDENTNAME
      SetDBFCacheOff    @45 RESIDENTNAME
      SetDBFCacheOn     @46 RESIDENTNAME
      SetDeletedOff     @47 RESIDENTNAME
      SetDeletedOn      @48 RESIDENTNAME
      SetErrorCapture   @49 RESIDENTNAME
      SetExactOff       @50 RESIDENTNAME
      SetExactOn        @51 RESIDENTNAME
      SetExclusiveOff   @52 RESIDENTNAME
      SetExclusiveOn    @53 RESIDENTNAME
      SetFileHandles    @54 RESIDENTNAME
      SetFilterThru     @55 RESIDENTNAME
      SetFlushOff       @56 RESIDENTNAME
      SetFlushOnAppend  @57 RESIDENTNAME
      SetFlushOnWrite   @58 RESIDENTNAME
      SetFormulaProcess @59 RESIDENTNAME
      SetLockOff        @60 RESIDENTNAME
      SetLockOn         @61 RESIDENTNAME
      SetOrderTo        @62 RESIDENTNAME
      SetStatusCapture  @63 RESIDENTNAME
      Skip              @64 RESIDENTNAME
      SortTo            @65 RESIDENTNAME
      Unlock            @66 RESIDENTNAME
      UnlockAll         @67 RESIDENTNAME
      Use               @68 RESIDENTNAME
      Zap               @69 RESIDENTNAME

      AssignMemo        @80 RESIDENTNAME
      SaveMemo          @81 RESIDENTNAME
      MemoClear         @82 RESIDENTNAME
      MemoGetLine       @83 RESIDENTNAME
      MemoInsLine       @84 RESIDENTNAME
      MemoGet           @85 RESIDENTNAME
      MemoGetN          @86 RESIDENTNAME
      MemoWidth         @87 RESIDENTNAME
      MemoLines         @88 RESIDENTNAME
      MemoPut           @89 RESIDENTNAME
      MemoPutN          @90 RESIDENTNAME
      DateGet           @91 RESIDENTNAME
      DateGetN          @92 RESIDENTNAME
      DatePut           @93 RESIDENTNAME
      DatePutN          @94 RESIDENTNAME
      FieldGet          @95 RESIDENTNAME
      FieldGetN         @96 RESIDENTNAME
      FieldPut          @97 RESIDENTNAME
      FieldPutN         @98 RESIDENTNAME
      LogicGet          @99 RESIDENTNAME
      LogicGetN         @100 RESIDENTNAME
      LogicPut          @101 RESIDENTNAME
      LogicPutN         @102 RESIDENTNAME
      NumberGet         @103 RESIDENTNAME
      NumberGetN        @104 RESIDENTNAME
      NumberPut         @105 RESIDENTNAME
      NumberPutN        @106 RESIDENTNAME
      StringGet         @107 RESIDENTNAME
      StringGetN        @108 RESIDENTNAME
      StringPut         @109 RESIDENTNAME
      StringPutN        @110 RESIDENTNAME

      CTOD              @120 RESIDENTNAME
      DTOC              @121 RESIDENTNAME
      DTOS              @122 RESIDENTNAME

      DefCapError        @130 RESIDENTNAME
      DefCapStatus       @131 RESIDENTNAME
      DefFilterCk        @132 RESIDENTNAME
      DefFormulaBuild    @133 RESIDENTNAME
      DefFormulaXtract   @134 RESIDENTNAME

      SetDBExt           @140 RESIDENTNAME
  }
 {$EndIf}
{$EndIf} {USELIB & USELIBSHL flags not defined}

{$EndIf} {Os/2 flag}



{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
{   ±± ERROR CHECK ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±  }
{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
{$IfnDef FINALDLL}
 ERROR: you must define FINALDLL for a complete DLL creation!
{$EndIf}

Begin
End.
