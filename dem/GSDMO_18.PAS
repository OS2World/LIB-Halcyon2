program GSDMO_18;
{-----------------------------------------------------------------------------
                             DBase Error Handler

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       Demonstrates use of error handling for fatal errors.

       The following is an example of inserting a user-supplied error
       handling procedure.  This sample program demonstrates how this
       procedure may be installed in a user's program.  All calls to
       Error anywhere in the file object's heirarchy will come through
       this 'hook'.

       The program assigns a user-supplied routine to process run error
       information.   A 'hook' is available to allow the user to gain
       access to the runtime errors generated by Griffin Solutions objects.
       The default procedure DefCapError halts the program using RunError.
       If the user chooses to take advantage of error capture to allow
       graceful recovery or shutdown, it is done by replacing DefCapError
       with his or her own routines via SetErrorCapture.

       Note that the assigned procedure must use far calls ($F+).

       Griffin Solutions routines call Error for non-recoverable errors.
       The call is:  Error(Code, Info).  Constants passed as arguments
       are contained in the GSOB_VAR unit.  The User supplied program must
       process the error using Code as the run error code.  Info provides
       additional information about the error.

       This example routine traps Error Code and Info arguments and then
       translates to text by using an array of error code records.  Several
       errors have been embedded in the program's main code that will
       cause RunTime Errors to occur--can you find them all?
       (answers at the end of the program list)

------------------------------------------------------------------------------}

uses
   USE32,
   GSOB_Var,
   GSOBShel,
   GSOB_Gen,
   {$IFDEF WINDOWS}
      WinCRT,
      WinDOS;
   {$ELSE}
      CRT,
      DOS;
   {$ENDIF}



type
   ErrListRec = record
      ErrCode : integer;
      ErrStr  : string[40];
   end;

const
   ErrCount = 79;

   ErrListAry : array[1..ErrCount] of ErrListRec = (
         (ErrCode: 1; ErrStr: 'Invalid function number'),
         (ErrCode: 2; ErrStr: 'File not found'),
         (ErrCode: 3; ErrStr: 'Path not found'),
         (ErrCode: 4; ErrStr: 'Too many open files'),
         (ErrCode: 5; ErrStr: 'File access denied'),
         (ErrCode: 6; ErrStr: 'Invalid file handle'),
         (ErrCode: 12; ErrStr: 'Invalid file access code'),
         (ErrCode: 15; ErrStr: 'Invalid drive number'),
         (ErrCode: 16; ErrStr: 'Cannot remove current directory'),
         (ErrCode: 17; ErrStr: 'Cannot rename across drives'),
         (ErrCode: 33; ErrStr: 'Attempted to read locked disk'),
         (ErrCode: 100; ErrStr: 'Disk read error'),
         (ErrCode: 101; ErrStr: 'Disk write error'),
         (ErrCode: 102; ErrStr: 'File not assigned'),
         (ErrCode: 103; ErrStr: 'File not open'),
         (ErrCode: 104; ErrStr: 'File not open for input'),
         (ErrCode: 105; ErrStr: 'File not open for output'),
         (ErrCode: 106; ErrStr: 'Invalid numeric format'),
         (ErrCode: 150; ErrStr: 'Disk is write-protected'),
         (ErrCode: 151; ErrStr: 'Bad drive request struct length'),
         (ErrCode: 152; ErrStr: 'Drive not ready'),
         (ErrCode: 154; ErrStr: 'CRC error in data'),
         (ErrCode: 156; ErrStr: 'Disk seek error'),
         (ErrCode: 157; ErrStr: 'Unknown media type'),
         (ErrCode: 158; ErrStr: 'Sector Not Found'),
         (ErrCode: 159; ErrStr: 'Printer out of paper'),
         (ErrCode: 160; ErrStr: 'Device write fault'),
         (ErrCode: 161; ErrStr: 'Device read fault'),
         (ErrCode: 162; ErrStr: 'Hardware failure'),
         (ErrCode: 200; ErrStr: 'Division by zero'),
         (ErrCode: 201; ErrStr: 'Range check error'),
         (ErrCode: 202; ErrStr: 'Stack overflow error'),
         (ErrCode: 203; ErrStr: 'Heap overflow error'),
         (ErrCode: 204; ErrStr: 'Invalid pointer operation'),
         (ErrCode: 205; ErrStr: 'Floating point overflow'),
         (ErrCode: 206; ErrStr: 'Floating point underflow'),
         (ErrCode: 207; ErrStr: 'Invalid floating point operation'),
         (ErrCode: 208; ErrStr: 'Overlay manager not installed'),
         (ErrCode: 209; ErrStr: 'Overlay file read error'),
         (ErrCode: 210; ErrStr: 'Object not initialized'),
         (ErrCode: 211; ErrStr: 'Call to abstract method'),
         (ErrCode: 212; ErrStr: 'Stream registration error'),
         (ErrCode: 213; ErrStr: 'Collection index out of range'),
         (ErrCode: 214; ErrStr: 'Collection overflow error'),
         (ErrCode: 1001; ErrStr: 'dBase DBF file header invalid'),
         (ErrCode: 1002; ErrStr: 'dBase record request beyond EOF'),
         (ErrCode: 1003; ErrStr: 'dBase field name is invalid'),
         (ErrCode: 1004; ErrStr: 'dBase field is of incorrect type'),
         (ErrCode: 1005; ErrStr: 'dBase memo record has format error'),
         (ErrCode: 1006; ErrStr: 'Formula expression cannot be translated'),
         (ErrCode: 1112; ErrStr: 'Error in GSO_DiskFile.AddToFile'),
         (ErrCode: 1103; ErrStr: 'Error in GSO_DiskFile.Close'),
         (ErrCode: 1104; ErrStr: 'Error in GSO_DiskFile.Erase'),
         (ErrCode: 1105; ErrStr: 'Error in GSO_DiskFile.FileSize'),
         (ErrCode: 1111; ErrStr: 'Error in GSO_DiskFile.Flush'),
         (ErrCode: 1101; ErrStr: 'Error in GSO_DiskFile.Read'),
         (ErrCode: 1106; ErrStr: 'Error in GSO_DiskFile.ReName'),
         (ErrCode: 1107; ErrStr: 'Error in GSO_DiskFile.Reset'),
         (ErrCode: 1108; ErrStr: 'Error in GSO_DiskFile.Write'),
         (ErrCode: 1109; ErrStr: 'Error in GSO_DiskFile.Truncate'),
         (ErrCode: 1102; ErrStr: 'Error in GSO_DiskFile.Write'),
         (ErrCode: 1206; ErrStr: 'Error in GSO_dBaseDBF.Append'),
         (ErrCode: 1299; ErrStr: 'Error in GSO_dBaseFLD.CheckField'),
         (ErrCode: 1207; ErrStr: 'Error in GSO_dBaseDBF.GetRec'),
         (ErrCode: 1201; ErrStr: 'Error in GSO_dBaseDBF.HdrWrite'),
         (ErrCode: 1204; ErrStr: 'Error in GSO_dBaseDBF.Init'),
         (ErrCode: 1202; ErrStr: 'Error in GSO_dBaseDBF.PutRec'),
         (ErrCode: 2101; ErrStr: 'Error in GSO_dBHandler.Formula'),
         (ErrCode: 2102; ErrStr: 'Error in GSO_dBHandler.MemoGet'),
         (ErrCode: 2103; ErrStr: 'Error in GSO_dBHandler.MemoGetN'),
         (ErrCode: 2104; ErrStr: 'Error in GSO_dBHandler.MemoPutN'),
         (ErrCode: 2105; ErrStr: 'Error in GSO_dBHandler.Pack'),
         (ErrCode: 2106; ErrStr: 'Error in GSO_dBHandler.Zap'),
         (ErrCode: 5101; ErrStr: 'Error in GSO_IndexFile.Init'),
         (ErrCode: 5102; ErrStr: 'Error in GSO_IndexFile.Ndx_AdjVal'),
         (ErrCode: 5211; ErrStr: 'Error in GSO_IdxColl.RetrieveKey'),
         (ErrCode: 6101; ErrStr: 'Error in GSO_dBMemo.Init'),
         (ErrCode: 6102; ErrStr: 'Error in GSO_dBMemo.MemoPut'),
         (ErrCode: 6199; ErrStr: 'Error in GSO_dBMemo4.MemoSetParam'));

{-----------------------------------------------------------------------------}
{$F+}
Procedure UserCaptureError(Code, Info : integer);
var
   i  : integer;
   ch : char;
begin
   writeln('Fatal Error Encountered in:');

   i := 0;
   repeat
      inc(i)
   until (ErrListAry[i].ErrCode = Code) or (i > ErrCount);
   if i <= ErrCount then
      writeln('Code = ', Code:4,' ',ErrListAry[i].ErrStr)
   else
      writeln('Code = ', Code:4,' Unknown');

   i := 0;
   repeat
      inc(i)
   until (ErrListAry[i].ErrCode = Info) or (i > ErrCount);
   if i <= ErrCount then
      writeln('Info = ', Info:4,' ',ErrListAry[i].ErrStr)
   else
      writeln('Info = ', Info:4,' Unknown');

   write('Press any key to continue');
   ch := ReadKey;
   writeln;
   Halt;
end;
{$F-}
{-----------------------------------------------------------------------------}


{                              Main Program                                }

var
   c : char;

begin
                       {Create a file}
   if not FileExist('GSDMO_18.DBF') then
   begin
      writeln('Creating GSDMO_18.DBF');
      MakeTestData(3,'GSDMO_18', 20, false);
      writeln('GSDMO_18.DBF Created');
   end;

   ClrScr;
{   SetExclusiveOn;}                   {Must be exclusive for Pack to work}
   SetErrorCapture(UserCaptureError);
   Select(1);
   Use('GSDMO_xx');
   Pack;
   IndexOn('GSDMO_18','LASTNAME+FIRTNAME');
   CloseDataBases;
   write('Successful Completion!  Press any key to continue');
   c := ReadKey;
   writeln;
end.

{---------------------------------------------------------------------------
                                 ANSWERS

     1.  Should be   Use(GSDMO_18);
     2.  Should be   IndexOn('GSDMO_18','LASTNAME+FIRSTNAME');
     3.  Remove comments from SetExclusiveOn.  Have to have Exclusive
         ownership of the file to allow Pack to work.  Multiuser file
         sharing is the default and has to be reset before the file is
         'Use'ed.

