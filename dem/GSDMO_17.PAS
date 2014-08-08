program GSDMO_17;
{-----------------------------------------------------------------------------
                             DBase Status Checker

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       Demonstrates use of status checking for long duration operations

       Several functions in GS_dBase can take some time to complete
       (e.g., IndexOn and Pack).  For this reason, a 'hook' is available
       to allow the user to gain access and track progress.  The default
       procedure DefCapStatus ignores the status.  If the user chooses to
       take advantage of progress reporting, it is done by replacing
       DefCapStatus with his or her own routines via SetStatusCapture.
       The status may be ignored again later by setting the default
       via SetCaptureStatus(DefCapStatus).

       The following is an example of inserting a user-supplied status
       reporting procedure.  This sample program demonstrates how this
       procedure may be installed in a user's program.  All calls to
       StatusUpdate anywhere in the file object's heirarchy will come
       through this 'hook'.

       Constants passed as arguments are contained in the GSOB_VAR unit,
       they are:

       StatusStart     = -1;   Passed to indicate a routine will be passing
                               status update information.

       StatusStop      = 0;    Signals termination by a routine, cancelling
                               status update processing.

       StatusIndexTo   = 1;    Token for identifying IndexTo as the routine
                               passing status information during sort phase.

       StatusIndexWr   = 2;    Token for identifying IndexTo as the routine
                               passing status information during write phase.

       StatusSort      = 5;    Token for identifying Sort as the routine
                               passing status information.

       StatusCopy      = 6;    Token for identifying Copy as the routine
                               passing status information during file writing.

       StatusPack      = 11;   Token for identifying Pack as the routine
                               passing status information.

       GenFStatus      = 901;  Token for file record creation report.

       The structure of a StatusUpdate call is:

       StatusUpdate(statword1, statword2, statword3);

       where the statword* values are type longint and will vary depending on
       the contents of statword1.  For example:

       if     statword1 = StatusStart
       then:  statword2 = the calling routine token (StatusIndexTo or
                          StatusPack.
              statword3 = the number of records to be processed.

       if     statword1 = StatusStop
       then:  statword2 = 0
              statword3 = 0

       if      statword1 = StatusCopy/StatusIndexTo/StatusPack/StatusSort
       then:   statword2 = current record number being processed
               statword3 = 0

       if      statword1 = StatusIndexWr
       then:   statword2 = current record number being processed
               statword3 = Pass number

       New procedures/functions introduced are:

                 DeleteRec
                 Pack
                 SetExclusiveOn
                 SetStatusCapture

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


var
   i       : integer;

{-----------------------------------------------------------------------------}
{$F+}
Procedure UserCaptureStatus(stat1,stat2,stat3 : longint);
begin
   case stat1 of
      StatusStart  : begin
                        GotoXY(1,WhereY);
                        case stat2 of
                            StatusPack  :  system.write('[ Pack Progress ]');
                            StatusIndexTo :
                                    system.write('[ Index Sort Progress ]');
                            StatusIndexWr :
                                    system.write('[ Index Write Progress ]');
                            GenFStatus      :
                                    system.write('[ Creation Progress ]');
                         end;
                         Writeln;
                         GotoXY(26,WhereY);
                         system.write('Total Records to Process = ',stat3);
                      end;
      StatusStop    : begin
                         GoToXY(79,WhereY);
                         Writeln;
                         Writeln('Finished');
                      end;
      GenFStatus,
      StatusPack,
      StatusIndexTo : begin
                         GoToXy(1,WhereY);
                         system.write('Record Number ',stat2,'  ');
                      end;
      StatusIndexWr : begin
                         GoToXy(1,WhereY);
                         system.write('Record Number ',stat2,'  ');
                         GoToXy(60,WhereY);
                         system.write('Pass Number ',stat3,'  ');
                      end;
   end;
end;
{$F-}
{----------------------------------------------------------------------------}


{                               Main Program                                 }


begin
   ClrScr;
   SetExclusiveOn;                      {Must be exclusive for Pack to work}
   SetStatusCapture(UserCaptureStatus);

   writeln('Creating GSDMO_17.DBF');
   MakeTestData(3,'GSDMO_17', 0, false);
   writeln('GSDMO_17.DBF Created');

   Select(1);
   Use('GSDMO_17');
   AddTestData(DBFActive,500);
   IndexOn('GSDMO_17','LASTNAME');
   i := 1;
   GoTop;
   while not dEOF do
   begin
      writeln(i:6,'  ',
              FieldGet('LASTNAME'),'   ',
              FieldGet('FIRSTNAME'),
              RecNo:8);
      if odd(i) then DeleteRec;
      Skip(1);
      inc(i);
   end;
   Pack;               {will also reindex}
   CloseDataBases;
end.
