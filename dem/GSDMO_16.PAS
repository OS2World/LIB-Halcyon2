program GSDMO_16;
{------------------------------------------------------------------------------
                    DBase File and Memo Editor (External)

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       This program reads a dBase file 'GSDMO_07.DBF with memo file
       'GSDMO_07.DBT'.   It uses an external editor to work with the
       memo fields.  Use F4 in the editor to exit. The program will
       stop when the editor is exited without updating.

            --- WILL NOT COMPILE AS A WINDOWS APPLICATION ---

       About the external editor:

                              TEXT EDITOR 2.5

       Text Editor (TE) 2.5 is a public domain, full screen ASCII text
       editor for the IBM PC and close compatibles which uses commands
       similar to those used in WordStar and Sidekick.  Primary uses for
       TE are to create/edit batch files, generate forms, edit files cap-
       tured by telecommunications programs, write E-mail and simulate a
       "smart" typewriter.

       Features include: 1) Program size of 29,904 bytes.  2) Edit file
       size as large as available memory.  3) Display commands on pop-up
       help screen, prompt for subcommands.  4) Insert, delete, split, join
       a line.  5) Copy, delete, move, read, write, shift, hide, display a
       marked block.  6) Print a file/block to LPT1-LPT3.  7) Enter any
       ASCII code.  8) Find/replace a phrase.  9) Temporary return to DOS.
       10) Set left/right margins and page length.  11) Word wrap.
       12) Format (justify) a paragraph.

       This archive contains the following files:
          TEREAD.1ST   This file.
          TE.EXE       The actual Text Editor program.
          TE.DOC       TE 2.5 User's Guide (10 pages).
          TEMOD.EXE    Utility to change TE.EXE colors, cursor size, margins,
                       etc.
          TEG.HLP      TE 2.5 Command Summary (1 page).

       Written by:  John Haluska,
                    310 W. Imperial Ave. #6,
                    El Segundo, CA 90245.
                    CompuServe 74000,1106

-------------------------------------------------------------------------------}

{$M 8192,0,65536}      {Needed to allow room for the 'Exec'ed editor}

uses
   USE32,
   CRT,
   Dos,
   GSOB_Dsk,
   GSOBShel;
const
   TxFileName = 'GSDMO_07.MMO';
var
   TxFile  : Text;
   t1      : longint;
   t2      : longint;
   c       : char;
   domore  : boolean;

                     {Procedure to display the memo field}

procedure MemoToDiskFile(fldname: string);
var
   i,
   ml   : integer;

begin
   Rewrite(TxFile);
   MemoGet('COMMENTS');
   ml := MemoLines;
   if ml <> 0 then
      for i := 1 to ml do
         Writeln(TxFile,MemoGetLine(i))
   else
   Writeln(TxFile,' ');               {at least one byte in the file}
   Close(TxFile);
end;

procedure DiskFileToMemo(fldname: string);
var
   i   : integer;
   s   : string;
   m1,
   m2  : string[10];
begin
   m1 := FieldGet('COMMENTS');
   MemoClear;
   Reset(TxFile);
   while not EOF(TxFile) do
   begin
      Readln(TxFile,s);
      MemoInsLine(-1,s);
   end;
   Close(TxFile);
   MemoPut('COMMENTS');
   m2 := FieldGet('COMMENTS');
            {If the memo field number has changed, save the DBF record}
   if m1 <> m2 then Replace;
end;

                               {Main program}
begin
   ClrScr;
   domore := true;

   if not FileExist('GSDMO_07.DBF') then
   begin
      writeln('File GSDMO_07.DBF not found.  Run GSDMO_07 to create.');
      halt;
   end;
                       {The 'Real' example starts here}

   Assign(TxFile,TxFileName);
   Rewrite(TxFile);

   Use('GSDMO_07');
   MemoWidth(75);        {sets width of the memo line.  Default is 50}
   GoTop;
   while not dEOF and domore do
   begin
      ClrScr;
      writeln(FieldGet('LASTNAME'),', ',
              FieldGet('FIRSTNAME'));
      MemoToDiskFile('COMMENTS');
      if FileExist(TxFileName) then t1 := FindFileInfo.Time;
     {$IfDef Os2}
      Exec('E.EXE',TxFileName);
     {$Else}
      Exec('TE.EXE',TxFileName);
     {$EndIf}
      if FileExist(TxFileName) then t2 := FindFileInfo.Time;
      if t1 <> t2 then                {File was updated}
         DiskFileToMemo('COMMENTS')
      else
         domore := false;
      Skip(1);
   end;
   CloseDataBases;
end.

