unit GSOB_Str;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                         String Handling Processor

           GSOB_STR (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved 

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       This unit handles string conversions.

       Note: please refer to original Halcyon Code for other
             informations about Dos functions.

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} {Os/2 & Dos Compiler flags!}

interface
uses
   Use32,
   GSOB_Dte,
   {$IFDEF WINDOWS}
      WinDOS;
   {$ELSE}
      DOS;
   {$ENDIF}

type
   {$IfnDef Os2}
    {$IFOPT N+}
       FloatTyp = Extended;
    {$ELSE}
       FloatTyp = Real;
    {$ENDIF}
   {$Else}
      FloatTyp = Extended;
   {$EndIf}

function AllCaps(t : string) : string;
procedure CnvAscToStr(var asc, st; lth : Integer);
procedure CnvStrToAsc(var st, asc; lth : Integer);
function PadL(strn : string; lth : Integer) : string;
function PadR(strn : string; lth : Integer) : string;
function StrCompare(var s1,s2) : Integer;
function StrDate(jul : longint) : string;
function StrNumber(num : FloatTyp; lth,dec : Integer) : string;
function StrWholeNum(num : longint; lth : Integer) : string;
function StrLogic(tf : boolean) : string;
function Strip_Flip(st : string) : string;
function StripChar(ch : Char; st : string) : string;
function SubStr(s : string; b,l : Integer) : string;
function TrimL(strn : string):string; {Deletes leading spaces}
function TrimR(strn : string):string; {Deletes trailing spaces}
function Unique_Field : string;       {Used to create a unique 8-byte string}
function ValDate(strn : string) : longint;
function ValNumber(strn : string) : FloatTyp;
function ValWholeNum(strn : string) : Longint;
function ValLogic(strn : string) : boolean;


implementation


function AllCaps(t : string) : string;
var
   i : Integer;
   l : Integer;
   s : string;
begin
   l := length(t);                 {Load string length}
   move(t,s,l+1);                  {Load work string}
   for i := 1 to l do s[i] := upcase(s[i]);
   AllCaps := s;
end;

procedure CnvAscToStr(var asc, st; lth : Integer);
var
   a : array[0..255] of byte absolute asc;
   s : string[255] absolute st;
   i : Integer;
begin
   move(a,s[1],lth);
   s[0] := chr(lth);
   i := pos(#0,s);
   if i > 0 then dec(i)
      else i := lth;
   s[0] := chr(i);
end;

procedure CnvStrToAsc(var st, asc; lth : Integer);
var
   a : array[0..255] of byte absolute asc;
   s : string[255] absolute st;
   t : string;
   i : Integer;
begin
   t := s;
   FillChar(a,lth,#0);
   i := length(t);
   if i >= lth then i := lth;
   move(t[1],a,i);
end;

function PadL(strn : string; lth : Integer) : string;
var
   wks : string;
   i   : Integer;
begin
   i := length(strn);                    {Load string length}
   move(strn,wks,i+1);                   {Load work string}
   if i >= lth then
   begin
      if i > lth then delete(wks,1,i-lth);
      PadL := wks;
      exit;
   end;
   FillChar(wks[1],lth,' ');
   move(strn[1],wks[(lth-i)+1],i);
   wks[0] := chr(lth);
   PadL := wks;
end;

function PadR(strn : string; lth : Integer) : string;
var
   wks : string;
   i   : Integer;
begin
   FillChar(wks[1],lth,' ');
   i := length(strn);                    {Load string length}
   move(strn,wks,i+1);                   {Load work string}
   wks[0] := chr(lth);
   PadR := wks;
end;

function StrCompare(var s1,s2) : Integer;
var
   st1 : string absolute s1;
   st2 : string absolute s2;
   flg : Integer;
   eql : boolean;
begin
   eql := st1 = st2;
   if eql then StrCompare := 0
      else if (st1 > st2) then
         StrCompare := 1             {s1 > s2 if sign flag 0}
            else StrCompare := -1;   {s1 < s2 if sign flag 1}
end;

function StrDate(jul : longint) : string;
begin
   StrDate := GS_Date_View(jul);
end;

function StrNumber(num : FloatTyp; lth,dec : Integer) : string;
var
   s : string;
begin
   Str(num:lth:dec,s);
   StrNumber := s;
end;

function StrWholeNum(num : longint; lth : Integer) : string;
var
   s : string;
begin
   Str(num:lth,s);
   StrWholeNum := s;
end;

function StrLogic(tf : boolean) : string;
begin
   if tf then StrLogic := 'T' else StrLogic := 'F';
end;

Function Strip_Flip(st : string) : string;
var
   wst,
   wstl : string;
   i    : Integer;
begin
   wst := TrimR(st);
   wst := wst + ' ';
   i := pos('~', wst);
   if i <> 0 then
   begin
      wstl := substr(wst,1,pred(i));
      system.delete(wst,1,i);
      wst := wst + wstl;
   end;
   Strip_Flip := wst;
end;

function StripChar(ch : Char; st : string) : string;
var
   wks : string;
   i   : Integer;
begin
   i := length(st);                      {Load string length}
   move(st,wks,i+1);                     {Load work string}
   while Pos(ch,wks) <> 0 do Delete(wks, Pos(ch, wks), 1);
   StripChar := wks;
end;

Function SubStr(s : string; b,l : Integer) : string;
var
   st : string;
   i  : Integer;
begin
   st := '';
   if b < 0 then b := 1;
   st := copy(s, b, l);
   SubStr := st;
end;

function TrimL(strn : string) : string;
var
   st : string;
begin
   move(strn,st,length(strn)+1);      {Load work string}
   st := strn;                        {Load work string}
   while (length(st) > 0) and (st[1] = ' ') do delete(st, 1, 1);
                                      {Loop to delete leading spaces}
   TrimL := st;                       {Return trimmed string}
end;

function TrimR(strn : string) : string;
var
   l  : Integer;
   st : string;
begin
   l := length(strn);                 {Load string length}
   move(strn,st,l+1);                 {Load work string}
   st[0] := '*';                      {Ensure string length is not decimal 32,}
                                      {which is an ASCII space}
   while st[l] = ' ' do dec(l);       {Loop searching down to first non-blank}
   st[0] := chr(l);                   {Set string to new length}
   TrimR := st;                       {Return trimmed length}
end;

const
   chrsavail : string[36]
             = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
   LastUnique : string[8] = '        ';


function Unique_Field : string;
var
   y, mo, d, dow  : Word;
   h, mn, s, hund : Word;
   wk, ymd, hms   : longint;
   LS             : string;

{
                   旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
                   �  Beginning of Unique_Field function  �
                   읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
}
begin
   repeat
      GetTime(h,mn,s,hund);           {Call TP 5.5 procedure for current time}
      GetDate(y,mo,d,dow);            {Call TP 5.5 procedure for current date}
      ymd := 10000+(mo*100)+d;
      hms := ((h+10)*1000000)+(longint(mn)*10000)+(s*100)+hund;
      wk := ymd mod 26;
      LS := chrsavail[succ(wk) + 10];
      ymd := ymd div 26;
      repeat
         wk := ymd mod 36;
         LS := LS + chrsavail[succ(wk)];
         ymd := ymd div 36;
      until ymd = 0;
      repeat
         wk := hms mod 36;
         LS := LS + chrsavail[succ(wk)];
         hms := hms div 36;
      until hms= 0;
   until LS <> LastUnique;
   LastUnique := LS;
   Unique_Field := LS;                {Return the unique field}
 end;

function ValDate(strn : string) : longint;
var
   v : longint;
begin
   v := GS_Date_Juln(strn);
   if v > 0 then ValDate := v else ValDate := 0;
end;

function ValNumber(strn : string) : FloatTyp;
var
   r : Integer;
   n : FloatTyp;
begin
   val(strn,n,r);
   if r <> 0 then ValNumber := 0
      else ValNumber := n;
end;

function ValWholeNum(strn : string) : longint;
var
   r,n : Integer;
begin
   val(strn,n,r);
   if r <> 0 then ValWholeNum := 0
      else ValWholeNum := n;
end;

function ValLogic(strn : string) : boolean;
var
   c : char;
begin
   if strn[0] <> #1 then ValLogic := false
   else
   begin
      c := strn[1];
      if c in ['T','t','Y','y'] then ValLogic := true
         else ValLogic := false;
   end;
end;


end.
{-----------------------------------------------------------------------------}
                                        END
