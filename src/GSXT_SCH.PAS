unit GSXT_Sch;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                               DBase Filters

           GSXT_SCH (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved 

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       A unit for rapidly searching dBase Record Fields for a string.

       Procedure is called as follows:

          Result := SearchDBF(s, FNum, fromtop)

       Where:
              s          = The string to search for
              FNum       = The record field to search
              fromtop    = Boolean true to start from the top of the file,
                           false to continue from the current record.
              Result     = Starting position of the found string in the
                           field, or zero if the string is not found.

       The file in the selected file (using GSOBShel) will be searched for
       the record field that matches the string s.  Records will be read
       through whatever filters are set (deleted records ignored, etc.).
       When a match is found the starting location within the field is
       returned and the file is positioned with the matching record as
       the current record.  If no match, zero is returned and the current
       record is positioned to the initial position as when the call was
       made.

       NOTE THAT THIS TEST IS NOT CASE SENSITIVE!!

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

interface
uses Use32, GSOB_Str, GSOBShel, GSOB_DBF, GSOB_Var;

Function SearchDBF(s : string; var FNum : Word; fromtop: boolean): Word;

implementation

Function SearchDBF(s : string; var FNum : Word; fromtop: boolean): Word;
var
   BTable: string;
   MTable: string;
   crd : boolean;
   ia : pointer;
   lr : longint;
   sloc: Word;
   i   : Integer;
   Strt: Word;
   Size: Word;
   rnum: longint;
begin
   if (FNum = 0) or (FNum > FieldCount) then
   begin
      SearchDBF := 0;
      exit;
   end;
   BTable := AllCaps(s);
   with DBFActive^ do
   begin
      StatusUpdate(StatusStart,StatusSearch,NumRecs);
      lr := RecNo;
      ia := IndexMaster;
      IndexMaster := nil;
      crd := CacheRead;
      SetDBFCache(dbOn);

      Strt := 1;
      if FNum > 1 then
         for i := 1 to FNum-1 do
            Strt := Strt + FieldLen(i);
      Size := FieldLen(FNum);

      if fromtop then GoTop else Skip(1);
      rnum := RecNo;
      sloc := 0;

      while not File_EOF and (sloc = 0) do
      begin
         move(CurRecord^[Strt],MTable[1],Size);
         MTable[0] := chr(Size);
         MTable := AllCaps(MTable);
         sloc := pos(BTable,MTable);
         if sloc = 0 then
         begin
            inc(rnum);
            StatusUpdate(StatusSearch,rnum,0);
            GetRec(rnum);
         end;
      end;
      SetDBFCache(crd);
      IndexMaster := ia;
      if sloc > 0 then
         Go(rnum)            {Reset for index}
      else
         GO(lr);
      SearchDBF := sloc;
      StatusUpdate(StatusStop,0,0);
   end;
end;

end.
