unit GSXT_Bro;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                               Browse Unit

           GSXT_BRO (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved 

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       This unit handles calls for a file browser.  Records may be
       scrolled left, right, up and down in a window by using these
       calls.  The dBase file must be initialized through
       GSOBSHEL.PAS calls prior to calling these routines.

       Description:

          Procedure StartBrowse(lincnt, linwidth: integer);

             Initializes browse activity.  The lincnt argument is the
             number of lines that can be displayed on screen.  The
             linwidth argument is the line size to be displayed on
             screen.  Must be called before any other command.

          Procedure ResetBrowse;

             Resets the browse function by releasing memory.  Must be
             called to close the browse activity.

          Function GetBrowseHeader(bline: word): string;

             Returns the portion of the header line starting at bline
             for the maximum length that can be displayed on screen.

          Function GetBrowseLine(linnum, bline: word): string;

             Returns the portion of the data record to be displayed
             starting at bline position within the string array of the
             record.  The function will return a string of the length
             that can be displayed on screen.  Linnum is the row to be
             selected, based on the record's relative position in the
             display window.  UpdateBrowse must be called initially to
             select the range of records to be displayed.

          Function GetBrowseRecord(linnum: integer): longint;

             Returns the physical record number for the record at linnum.
             Linnum is the row to be selected, based on the record's
             relative position in the display window.  UpdateBrowse must
             be called initially to select the range of records to be
             displayed.

          Function GetBrowseBar(bline: word): string;

             Returns a separator line to be placed between the header and
             data records.  This line is created by scanning the portion
             of the header line starting at bline for the maximum length
             that can be displayed on screen.  If the position in the
             header contains the value in broSeparator, then the value
             from broIntersect is inserted in the line, otherwise the
             value in broHorizontal is inserted.

          Procedure MoveBrowseLeft(var posn: word);

             Used to compute the scroll position for a scroll left.
             Decrements posn by 1.  It then tests to see if posn is less
             than 1 and sets it to 1 if it is less.  This value is used
             by other calls to identify the starting scroll position for
             GetBrowseLine and GetBrowseHeader.

          Procedure MoveBrowseRight(var posn: word);

             Used to compute the scroll position for a scroll right.
             Increments posn by 1.  It then tests to see if posn is
             greater than (length of the record - max line that can
             be displayed), and adjusts to that length if greater.
             This prevents scrolling beyond the length of the record.
             The value returned in posn is used by other calls to
             identify the starting scroll position for GetBrowseLine
             and GetBrowseHeader.

          Procedure RenewBrowseLine(linnum: word);

             Rereads the physical record for the record displayed at
             linnum.  Linnum is the row to be selected, based on the
             record's relative position in the display window.
             UpdateBrowse must be called initially to select the range
             of records to be displayed.  This routine needs to be called
             if a record is updated during the browse activity.

          Procedure TabBrowseLeft(var posn: word);

             Used to compute the scroll position for a tab left.
             Decrements posn to the start of the previous field, unless
             already at field 1.  This value is used by other calls to
             identify the starting scroll position for GetBrowseLine and
             GetBrowseHeader.

          Procedure TabBrowseRight(var posn: word);

             Used to compute the scroll position for a tab right.
             Increments posn to the start of the next field.  It then
             tests to see if posn is greater than (length of the record -
             max line that can be displayed), and adjusts to that length
             if greater. This prevents scrolling beyond the length of
             the record.  The value returned in posn is used by other
             calls to identify the starting scroll position for
             GetBrowseLine and GetBrowseHeader.

          Procedure UpdateBrowse(action: longint);

             Retrieves records from the database file based on the command
             in action.  Valid commands are: broLnDn, broLnUp, broTop,
             broBttm, broPgDn, and broPgUp.  It retrieves as many records
             as is necessary to fill the number of lines specified in the
             StartBrowse command.

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

interface

Uses
   Use32,
   GSOB_Dte,
   GSOB_Var,
   GSOBShel,
{$IFDEF WINDOWS}
   Objects;
{$ELSE}
   GSOB_Obj;
{$ENDIF}

const

   broSeparator  = #179;
   broHorizontal = #196;
   broIntersect  = #197;

   broLnDn = -1;
   broLnUp = -2;
   broTop  = -3;
   broBttm = -4;
   broPgDn = -5;
   broPgUp = -6;

Procedure StartBrowse(lincnt, linwidth: Integer);
Procedure ResetBrowse;
Procedure MoveBrowseLeft(var posn: Word);
Procedure MoveBrowseRight(var posn: Word);
Procedure TabBrowseLeft(var posn: Word);
Procedure TabBrowseRight(var posn: Word);
Procedure UpdateBrowse(action: longint);
Function GetBrowseHeader(bline: Word): string;
Function GetBrowseLine(linnum, bline: Word): string;
Function GetBrowseRecord(linnum: Integer): longint;
Function GetBrowseBar(bline: Word): string;
Procedure RenewBrowseLine(linnum: Word);

implementation

type
   GSPbroLine = ^GSRbroLine;
   GSRbroLine = record
      LineRcrd :  longint;
      LineText :  Array [0..16383] of byte;
   end;

   GSPbroLineColl = ^GSObroLineColl;
   GSObroLineColl = object(TCollection)
      LineBufSize: Integer;
      LinesAvail : Integer;
      LinesWidth : Integer;
      LineHead   : GSPbroLine;
      procedure  FreeItem(Item : pointer); virtual;
      procedure  InsertItem(Item : pointer);
      procedure  InsertItemAt(Item : pointer; i : Integer);
   end;

var
   broObject : GSObroLineColl;
   Separator : char;

{------------------------------------------------------------------------------
                              GSObro_LineColl
------------------------------------------------------------------------------}

procedure GSObroLineColl.FreeItem(Item: Pointer);
var
   p : GSPbroLine absolute Item;
begin
   if Item <> nil then FreeMem(p, LineBufSize);
end;

Procedure GSObroLineColl.InsertItem(Item: Pointer);
var
   p : GSPbroLine absolute Item;
begin
   Insert(p);
end;

Procedure GSObroLineColl.InsertItemAt(Item: Pointer; i: Integer);
var
   p : GSPbroLine absolute Item;
begin
   AtInsert(i,p);
end;

{------------------------------------------------------------------------------
                              Browse Routines
------------------------------------------------------------------------------}

Function SizeOfLine: Word;
var
   ix : Integer;
   ls : Word;
begin
   ls := 0;
   with DBFActive^ do
   begin
      for ix := 1 to NumFields do
      begin
         ls := ls + FieldLen(ix) + 1;
         if (FieldType(ix) = 'D') and GS_Date_Century then inc(ls,2);
      end;
      SizeOfLine := ls;
   end;
end;

Procedure MakeHeader;
var
   ix : Integer;
   iv : Integer;
   ls : Word;
   p  : PByteArray;
   t  : string;
begin
   GetMem(p, broObject.LineBufSize);
   broObject.LineHead := GSPbroLine(p);
   FillChar(p^,broObject.LineBufSize,' ');
   ls := 4;
   with DBFActive^ do
   begin
      for ix := 1 to NumFields do
      begin
         iv := FieldLen(ix);
         if (FieldType(ix) = 'D') and GS_Date_Century then inc(iv,2);
         t := FieldName(ix);
         if length(t) > iv then
            move(t[1],p^[ls],iv)
         else
            move(t[1],p^[ls],length(t));
         ls := ls + iv;
         move(separator,p^[ls],1);
         ls := ls + 1;
      end;
   end;
end;

Function FillInLine: GSPbroLine;
var
   ix : Integer;
   ls : Word;
   p  : PByteArray;
   t  : string;
begin
   GetMem(p, broObject.LineBufSize);
   FillChar(p^,broObject.LineBufSize,' ');
   ls := 4;
   with DBFActive^ do
   begin
      for ix := 1 to NumFields do
      begin
         t := FieldGetN(ix);
         case FieldType(ix) of
            'C',
            'G',
            'L',
            'N'  : begin
                   end;
            'D',
            'M'  : begin
                      t := StringGetN(ix);
                  end;
         end;
         move(t[1],p^[ls],length(t));
         ls := ls + FieldLen(ix);
         if (FieldType(ix) = 'D') and GS_Date_Century then inc(ls,2);
         move(separator,p^[ls],1);
         ls := ls + 1;
      end;
      move(RecNumber,p^,4);
      FillInLine := GSPbroLine(p);
   end;
end;

Procedure StartBrowse(lincnt, linwidth: Integer);
begin
   Separator := broSeparator;
   broObject.Init(lincnt, 8);
   broObject.LineBufSize := SizeOfLine + 4;
   broObject.LinesAvail := lincnt;
   if linwidth > broObject.LineBufSize-4 then
      linwidth := broObject.LineBufSize-4;
   broObject.LinesWidth := linwidth;
   MakeHeader;
end;

Procedure ResetBrowse;
begin
   FreeMem(broObject.LineHead, broObject.LineBufSize);
   broObject.Done;
end;

Procedure MoveBrowseLeft(var posn: Word);
begin
   dec(posn);
   if posn <= 0 then posn := 1;
end;

Procedure MoveBrowseRight(var posn: Word);
begin
   inc(posn);
   if posn > (broObject.LineBufSize - broObject.LinesWidth) - 3 then
      posn := (broObject.LineBufSize - broObject.LinesWidth) - 3;
end;

Procedure TabBrowseLeft(var posn: Word);
var
   ix : Integer;
   lv : Integer;
   ls : Word;
begin
   ls := 0;
   lv := 0;
   ix := 1;
   with DBFActive^ do
   begin
      while (ix <= NumFields) and (posn > ls) do
      begin
         lv := ls;
         ls := ls + FieldLen(ix) + 1;
         if (FieldType(ix) = 'D') and GS_Date_Century then inc(ls,2);
         inc(ix);
      end;
   end;
   posn := lv;
   if posn = 0 then posn := 1;
end;

Procedure TabBrowseRight(var posn: Word);
var
   ix : Integer;
   ls : Word;
begin
   ls := 0;
   ix := 1;
   with DBFActive^ do
   begin
      while (ix <= NumFields) and (posn >= ls) do
      begin
         ls := ls + FieldLen(ix) + 1;
         if (FieldType(ix) = 'D') and GS_Date_Century then inc(ls,2);
         inc(ix);
      end;
   end;
   posn := ls;
   if posn > (broObject.LineBufSize - broObject.LinesWidth) - 3 then
      posn := (broObject.LineBufSize - broObject.LinesWidth) - 3;
end;


Procedure UpdateBrowse(action: longint);
var
   ix : Integer;
   p  : GSPbroLine;
   ln : longint;
begin
   with DBFActive^ do
   begin
      case action of
         broLnDn      : begin
                           p := broObject.At(broObject.Count-1);
                           ln := p^.LineRcrd;
                           Go(ln);
                           GetRec(Next_Record);
                           if not File_EOF then
                           begin
                              if broObject.Count >= broObject.LinesAvail then
                                 broObject.Free(broObject.At(0));
                              broObject.Insert(FillInLine);
                           end;
                        end;

         broLnUp      : begin
                           p := broObject.At(0);
                           ln := p^.LineRcrd;
                           Go(ln);
                           GetRec(Prev_Record);
                           if not File_TOF then
                           begin
                              if broObject.Count >= broObject.LinesAvail then
                                 broObject.Free
                                           (broObject.At(broObject.Count-1));
                              broObject.AtInsert(0, FillInLine);
                           end;
                        end;

         broTop       : begin
                           broObject.FreeAll;
                           GetRec(Top_Record);
                           ix := 0;
                           while (ix < broObject. LinesAvail) and
                                 not File_EOF do
                           begin
                              broObject.Insert(FillInLine);
                              GetRec(Next_Record);
                              inc(ix);
                           end;
                        end;

         broBttm      : begin
                           broObject.FreeAll;
                           GetRec(Bttm_Record);
                           ix := 0;
                           while (ix < broObject.LinesAvail) and
                                 not File_TOF do
                           begin
                              broObject.AtInsert(0,FillInLine);
                              GetRec(Prev_Record);
                              inc(ix);
                           end;
                        end;

         broPgDn      : begin
                           p := broObject.At(broObject.Count-1);
                           broObject.Delete(p);
                           ln := p^.LineRcrd;
                           broObject.FreeAll;
                           broObject.Insert(p);
                           Go(ln);
                           GetRec(Next_Record);
                           ix := 1;
                           while (ix < broObject.LinesAvail) and
                                 not File_EOF do
                           begin
                              broObject.Insert(FillInLine);
                              if (ix < broObject.LinesAvail-1) then
                                 GetRec(Next_Record);
                              inc(ix);
                           end;
                        end;

         broPgUp      : begin

                           p := broObject.At(0);
                           ln := p^.LineRcrd;
                           Go(ln);
                           Skip((broObject.LinesAvail*-1)+1);
                           broObject.FreeAll;
                           ix := 1;
                           while (ix <= broObject.LinesAvail) and
                                 not File_EOF do
                           begin
                              broObject.Insert(FillInLine);
                              if (ix < broObject.LinesAvail) then
                                 GetRec(Next_Record);
                              inc(ix);
                           end;

                           {
                           p := broObject.At(0);
                           ln := p^.LineRcrd;
                           Go(ln);
                           ix := 1;
                           GetRec(Prev_Record);
                           while (ix < broObject.LinesAvail) and
                                 not File_TOF do
                           begin
                              if broObject.Count >= broObject.LinesAvail then
                                 broObject.Free
                                           (broObject.At(broObject.Count-1));
                              broObject.AtInsert(0,FillInLine);
                              GetRec(Prev_Record);
                              inc(ix);
                           end;
                           }
                        end;

         else           begin
                           if (action > 0) and (action <= NumRecs) then
                           begin
                              p := broObject.At(broObject.Count-1);
                              ln := p^.LineRcrd;
                              broObject.FreeAll;
                              Go(action);
                              ix := 0;
                              while (ix < broObject. LinesAvail) and
                                    not File_EOF do
                              begin
                                 broObject.Insert(FillInLine);
                                 GetRec(Next_Record);
                                 inc(ix);
                              end;
                           end;
                        end;
      end;
   end;
end;

Function GetBrowseHeader(bline: Word): string;
var
   ix : Integer;
   p  : PByteArray;
   t  : string;
begin
   p := pointer(broObject.LineHead);
   ix := broObject.LinesWidth;
   if (bline > (broObject.LineBufSize-ix) - 3) then
   begin
      GetBrowseHeader := '';
      exit;
   end;
   move(p^[bline+3], t[1], ix);
   t[0] := chr(ix);
   GetBrowseHeader := t;
end;

Function GetBrowseLine(linnum, bline: Word): string;
var
   ix : Integer;
   p  : PByteArray;
   t  : string;
begin
   if (linnum < 1) or (linnum > broObject.Count) then
   begin
      GetBrowseLine := '';
      exit;
   end;
   p := broObject.At(linnum-1);
   ix := broObject.LinesWidth;
   if (bline > (broObject.LineBufSize-ix) - 3) then
   begin
      GetBrowseLine := '';
      exit;
   end;
   move(p^[bline+3], t[1], ix);
   t[0] := chr(ix);
   GetBrowseLine := t;
end;

Procedure RenewBrowseLine(linnum: Word);
var
   ln : longint;
   ix : Integer;
   p  : PByteArray;
   t  : string;
begin
   ln := GetBrowseRecord(linnum);
   if ln = 0 then exit;
   go(ln);
   p := broObject.At(linnum-1);
   broObject.FreeItem(p);
   broObject.AtPut(linnum-1,FillInLine);
end;

Function GetBrowseRecord(linnum: Integer): longint;
var
   lx : longint;
   p  : PByteArray;
begin
   if (linnum < 1) or (linnum > broObject.Count) then
   begin
      GetBrowseRecord := 0;
      exit;
   end;
   p := broObject.At(linnum-1);
   move(p^,lx,4);
   GetBrowseRecord := lx;
end;

Function GetBrowseBar(bline: Word): string;
var
   ix : Integer;
   t  : string;
begin
   t := GetBrowseHeader(bline);
   for ix := 1 to length(t) do
     if t[ix] = broSeparator then
        t[ix] := broIntersect
     else
        t[ix] := broHorizontal;
   GetBrowseBar := t;
end;

end.

