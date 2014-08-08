unit GSOB_Var;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                      dBase III/IV File Handler Variables

           GSOB_VAR (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved 

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       This unit contains global constants, types, and variables used
       by Halcyon/2 units.

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

interface

Uses Use32;

const

   {                  Run Time Error Codes                        }

   dosInvalidFunct   =    1;         {Invalid function number}
   dosFileNotFound   =    2;         {File not found}
   dosPathNotFound   =    3;         {Path not found}
   dosTooManyFiles   =    4;         {Too many open files}
   dosAccessDenied   =    5;         {File access denied}
   dosInvalidHandle  =    6;         {Invalid file handle}
   dosInvalidAccess  =   12;         {Invalid file access code}
   dosInvalidDrive   =   15;         {Invalid drive number}
   dosCantRemoveDir  =   16;         {Cannot remove current directory}
   dosCantRename     =   17;         {Cannot rename across drives}
   dosLockViolated   =   33;         {Attempted to read locked disk}
   dosDiskReadError  =  100;         {Disk read error}
   dosDiskWriteError =  101;         {Disk write error}
   dosFileNotAssgd   =  102;         {File not assigned}
   dosFileNotOpen    =  103;         {File not open}
   dosNotOpenInput   =  104;         {File not open for input}
   dosNotOpenOutput  =  105;         {File not open for output}
   dosInvalidNumber  =  106;         {Invalid numeric format}
   dosWriteProtected =  150;         {Disk is write-protected}
   dosBadStructure   =  151;         {Bad drive request struct length}
   dosDriveNotReady  =  152;         {Drive not ready}
   dosDataCRCError   =  154;         {CRC error in data}
   dosDiskSeekError  =  156;         {Disk seek error}
   dosMediaUnknown   =  157;         {Unknown media type}
   dosSectorNotFound =  158;         {Sector Not Found}
   dosPrinterNoPaper =  159;         {Printer out of paper}
   dosWriteFault     =  160;         {Device write fault}
   dosReadFault      =  161;         {Device read fault}
   dosHardwareFail   =  162;         {Hardware failure}
   tpDivideByZero    =  200;         {Division by zero}
   tpRangeCheck      =  201;         {Range check error}
   tpStackOverflow   =  202;         {Stack overflow error}
   tpHeapOverflow    =  203;         {Heap overflow error}
   tpInvalidPointer  =  204;         {Invalid pointer operation}
   tpFloatPointOflow =  205;         {Floating point overflow}
   tpFloatPointUFlow =  206;         {Floating point underflow}
   tpFloatPointInvld =  207;         {Invalid floating point operation}
   tpNoOverlayMngr   =  208;         {Overlay manager not installed}
   tpOverlayReadErr  =  209;         {Overlay file read error}
   tpObjectNotInit   =  210;         {Object not initialized}
   tpAbstractCall    =  211;         {Call to abstract method}
   tpStreamRegError  =  212;         {Stream registration error}
   tpCollectionIndex =  213;         {Collection index out of range}
   tpCollectionOFlow =  214;         {Collection overflow error}
   gsBadDBFHeader    = 1001;         {dBase DBF file header invalid}
   gsDBFRangeError   = 1002;         {dBase record request beyond EOF}
   gsInvalidField    = 1003;         {dBase field name is invalid}
   gsBadFieldType    = 1004;         {dBase field is of incorrect type}
   gsBadDBTRecord    = 1005;         {dBase memo record has format error}
   gsBadFormula      = 1006;         {Formula expression cannot be translated}
   gsFileAlreadyOpen = 1007;         {Dest file for sort or copy already open}
   gsAreaIsNotInUse  = 1008;         {Object is not initialized in file area}

   {               Extended Run Time Error Code Information             }

                             {GSOB_DSK errors}
   dskAddToFileError = 1112;         {Error in GSO_DiskFile.AddToFile}
   dskCloseError     = 1103;         {Error in GSO_DiskFile.Close}
   dskEraseError     = 1104;         {Error in GSO_DiskFile.Erase}
   dskFileSizeError  = 1105;         {Error in GSO_DiskFile.FileSize}
   dskFlushError     = 1111;         {Error in GSO_DiskFile.Flush}
   dskReadError      = 1101;         {Error in GSO_DiskFile.Read}
   dskRenameError    = 1106;         {Error in GSO_DiskFile.ReName}
   dskResetError     = 1107;         {Error in GSO_DiskFile.Reset}
   dskRewriteError   = 1108;         {Error in GSO_DiskFile.Write}
   dskTruncateError  = 1109;         {Error in GSO_DiskFile.Truncate}
   dskWriteError     = 1102;         {Error in GSO_DiskFile.Write}

                             {GSOB_DBF errors}
   dbfAppendError     = 1206;        {Error in GSO_dBaseDBF.Append}
   dbfCheckFieldError = 1299;        {Error in GSO_dBaseFLD.CheckField}
   dbfGetRecError     = 1207;        {Error in GSO_dBaseDBF.GetRec}
   dbfHdrWriteError   = 1201;        {Error in GSO_dBaseDBF.HdrWrite}
   dbfInitError       = 1204;        {Error in GSO_dBaseDBF.Init}
   dbfPutRecError     = 1202;        {Error in GSO_dBaseDBF.PutRec}
   dbfLongNameMemo    = 1230;        {Error in GSO_DBFBuild.WriteDBT}

                             {GSOB_DBS errors}
   dbsFormulaError    = 2101;        {Error in GSO_dBHandler.Formula}
   dbsMemoGetError    = 2102;        {Error in GSO_dBHandler.MemoGet}
   dbsMemoGetNError   = 2103;        {Error in GSO_dBHandler.MemoGetN}
   dbsMemoPutNError   = 2104;        {Error in GSO_dBHandler.MemoPutN}
   dbsPackError       = 2105;        {Error in GSO_dBHandler.Pack}
   dbsSortFile        = 2107;        {Error in GSO_dBHandler.SortFile}
   dbsZapError        = 2106;        {Error in GSO_dBHandler.Zap}

                             {GSOB_NDX errors}
   ndxInitError        = 5101;       {Error in GSO_IndexFile.Init}
   ndxNdx_AdjValError  = 5102;       {Error in GSO_IndexFile.Ndx_AdjVal}
   ndxKeyUpdateError   = 5103;       {Error in GSO_IndexFile.KeyUpdate}

                             {GSOB_INX errors}
   inxRetrieveKeyError = 5211;       {Error in GSO_IdxColl.RetrieveKey}

                              {GSOB_MMO errors}
   mmoInitError        = 6101;       {Error in GSO_dBMemo.Init}
   mmoMemoPutError     = 6102;       {Error in GSO_dBMemo.MemoPut}
   mmoMemoSetParamErr  = 6199;       {Error in GSO_dBMemo4.MemoSetParam}

                             {GSOBShel errors}
   shelConfirmUsedArea = 7101;       {Accessed a file area that is not Use'd}


   {                     Status Reporting Codes                         }

   StatusStart     = -1;
   StatusStop      = 0;
   StatusIndexTo   = 1;
   StatusIndexWr   = 2;
   StatusSort      = 5;
   StatusCopy      = 6;
   StatusPack      = 11;
   StatusSearch    = 21;
   GenFStatus      = 901;

   {               Globally used constants and types                    }

   GS_dBase_MaxMemoRec  = 512; {Size of each block of memo file data}

   DB3File         = $03;       {First byte of dBase III(+) file}
   DB4File         = $03;       {First byte of dBase IV file}
   DB3WithMemo     = $83;       {First byte of dBase III(+) file with memo}
   DB4WithMemo     = $8B;       {First byte of dBase IV file with memo}
   FXPWithMemo     = $F5;       {First byte of FoxPro file with memo}

   GS_dBase_UnDltChr = $20;     {Character for Undeleted Record}
   GS_dBase_DltChr   = $2A;     {Character for Deleted Record}

   EOFMark    : byte = $1A;     {Character used for EOF in text files}

   Next_Record = -1;            {Token value passed to read next record}
   Prev_Record = -2;            {Token value passed to read previous record}
   Top_Record  = -3;            {Token value passed to read first record}
   Bttm_Record = -4;            {Token value passed to read final record}

   ValueHigh   =  1;            {Token value passed for key comparison high}
   ValueLow    = -1;            {Token value passed for key comparison low}
   ValueEqual  =  0;            {Token value passed for key comparison equal}

   dbOn         : boolean = true;
   dbOff        : boolean = false;

   cDBExt       : String = '.DBF';

type
   DateTypes = (American,ANSI,British,French,German,Italian,Japan,
                USA, MDY, DMY, YMD);

   SortStatus = (SortUp, SortDown, NoSort);

   {$IfnDef Os2}
    {$IFOPT N+}
       FloatNum = Extended;
    {$ELSE}
       FloatNum = Real;
    {$ENDIF}
   {$Else}
      FloatNum = Extended;
   {$EndIf}

Var
   {$IfDef Os2}
     DBExtension : String;
   {$Else}
     DBExtension : String[4];
   {$EndIf}

implementation

begin
 DBExtension := cDBExt; {Default DBF extension}
end.
