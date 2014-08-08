program GSDMO_22;
{------------------------------------------------------------------------------
                               Getting More Files Open

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       This unit demonstrates how to increase the number of files that can
       be opened in a program.

       The program will open all the *.PAS files in the current directory.
       The procedure SetFileHandles() will allow the program to open as
       many files as needed at the same time, up to the number passed as
       the argument (not to exceed 255).  This number cannot exceed the
       value given in the FILES= command in the AUTOEXEC.BAT file.

       New procedures/functions introduced are:

                 SetFileHandles

-------------------------------------------------------------------------------}

uses
   USE32,
   GSOB_Var,
   GSOBShel,
   {$IFDEF WINDOWS}
      WinDos,
      WinCRT;
   {$ELSE}
      Dos,
      CRT;
   {$ENDIF}

        {The following types map DOS and WINDOWS TP names to be the same}

{$IFNDEF WINDOWS}
const
   faArchive = Archive;
type
   TSearchRec = SearchRec;
{$ENDIF}

var
  DirInfo: TSearchRec;
  filary : array[0..99] of text;
  i      : integer;

begin
   ClrScr;

   SetFileHandles(99);            {Comment out to confirm default limit}

   FindFirst('*.PAS', faArchive, DirInfo);
   {FindFirst('*.exe', faArchive, DirInfo);}
   i := 0;
   while DosError = 0 do
   begin
      WriteLn(i:3,'  ',DirInfo.Name);
      Assign(filary[i],DirInfo.Name);
      Reset(filary[i]);
      inc(i);
      FindNext(DirInfo);
   end;
end.




