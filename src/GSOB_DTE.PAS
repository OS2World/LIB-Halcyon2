unit GSOB_Dte;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                             Date Processor

           GSOB_DTE (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved 

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       This unit handles date conversion.

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

{$O+}

interface

uses  Use32,
   {$IFDEF WINDOWS}
      WinDOS;
   {$ELSE}
      DOS;
   {$ENDIF}

const
   GS_Date_JulInv  =  -1;             {constant for invalid Julian day}

type
   GS_Date_StrTyp  = string[10];
   GS_Date_ValTyp  = longint;
   GS_Date_CenTyp  = string[2];
   DateCountry = (American,ANSI,British,French,German,Italian,Japan,USA, MDY, DMY, YMD);

var
   GS_Date_Century : boolean;
   GS_Date_Type    : DateCountry;

function  GS_Date_CurCentury : GS_Date_CenTyp;
function  GS_Date_Curr : GS_Date_ValTyp;
function  GS_Date_DBStor(nv : GS_Date_ValTyp) : GS_Date_StrTyp;
function  GS_Date_View(nv : GS_Date_ValTyp) : GS_Date_StrTyp;
function  GS_Date_Juln(sdate : GS_Date_StrTyp) : GS_Date_ValTyp;
function  GS_Date_MDY2Jul(month, day, year : Word) : GS_Date_ValTyp;
procedure GS_Date_Jul2MDY(jul : GS_Date_ValTyp; var month, day, year  : Word);


implementation

const
   JulianConstant =  1721119;  {constant for Julian day for 02-28-0000}
   JulianMin      =  1721120;  {constant for Julian day for 03-01-0000}
   JulianMax      =  25657575; {constant for Julian day for 12-31-65535}

   ThisCentury : GS_Date_CenTyp = '';

type
   Str4 = string[4];


function DateType_MDY(mm, dd, yy: Str4): GS_Date_StrTyp;
var
   ss  : string[10];
begin
   case GS_Date_Type of
      American,
      MDY         : ss := '  /  /    ';
      USA         : ss := '  -  -    ';
   end;
   if GS_Date_Century then ss[0] := #10 else ss[0] := #8;
   if mm <> '' then
   begin
      move(mm[1],ss[1],2);
      move(dd[1],ss[4],2);
      if GS_Date_Century then
         move(yy[1],ss[7],4)
      else
         move(yy[3],ss[7],2);
   end;
   DateType_MDY := ss;
end;

function DateType_DMY(mm, dd, yy: Str4): GS_Date_StrTyp;
var
   ss  : string[10];
begin
   case GS_Date_Type of
      British,
      French,
      DMY         : ss := '  /  /    ';
      German      : ss := '  .  .    ';
      Italian     : ss := '  -  -    ';
   end;
   if GS_Date_Century then ss[0] := #10 else ss[0] := #8;
   if mm <> '' then
   begin
      move(dd[1],ss[1],2);
      move(mm[1],ss[4],2);
      if GS_Date_Century then
         move(yy[1],ss[7],4)
      else
         move(yy[3],ss[7],2);
   end;
   DateType_DMY := ss;
end;

function DateType_YMD(mm, dd, yy: Str4): GS_Date_StrTyp;
var
   ss  : string[10];
begin
   case GS_Date_Type of
      Japan,
      YMD         : ss := '    /  /  ';
      ANSI        : ss := '    .  .  ';
   end;
   if not GS_Date_Century then system.Delete(ss,1,2);
   if mm <> '' then
   begin
      if GS_Date_Century then
      begin
         move(yy[1],ss[1],4);
         move(mm[1],ss[6],2);
         move(dd[1],ss[9],2);
      end
      else
      begin
         move(yy[3],ss[1],2);
         move(mm[1],ss[4],2);
         move(dd[1],ss[7],2);
      end;
   end;
   DateType_YMD := ss;
end;

function LeapYearTrue (year : Word)  : boolean;
begin
   LeapYearTrue := false;
   if (year mod 4 = 0) then
      if (year mod 100 <> 0) or (year mod 400 = 0) then
         if (year mod 4000 <> 0) then
            LeapYearTrue :=  true;
end;

function DateOk (month, day, year  : Word) : boolean;
var
   daz : Integer;
begin
   if (day <> 0) and
      ((month > 0) and (month < 13)) and
      ((year <> 0) or (month > 2)) then
   begin
      case month of
         2  : begin
                 daz := 28;
                 if (LeapYearTrue(year)) then inc(daz);
              end;
         4,
         6,
         9,
         11 : daz := 30;
         else  daz := 31;
      end;
      DateOk := day <= daz;
   end
   else DateOk := false;
end;

function GS_Date_MDY2Jul(month, day, year : Word) : GS_Date_ValTyp;
var
   wmm,
   wyy,
   jul  : longint;
begin
   wyy := year;
   if (month > 2) then wmm  := month - 3
      else
      begin
         wmm := month + 9;
         dec(wyy);
      end;
   jul := (wyy div 4000) * 1460969;
   wyy := (wyy mod 4000);
   jul := jul +
            (((wyy div 100) * 146097) div 4) +
            (((wyy mod 100) * 1461) div 4) +
            (((153 * wmm) + 2) div 5) +
            day +
            JulianConstant;
   if (jul < JulianMin) or (JulianMax < jul) then
      jul := GS_Date_JulInv;
   GS_Date_MDY2Jul := jul;
end;

procedure GS_Date_Jul2MDY(jul : GS_Date_ValTyp; var month, day, year  : Word);
var
   tmp1 : longint;
   tmp2 : longint;
begin
   if (JulianMin <= jul) and (jul <= JulianMax) then
      begin
         tmp1  := jul - JulianConstant; {will be at least 1}
         year  := ((tmp1-1) div 1460969) * 4000;
         tmp1  := ((tmp1-1) mod 1460969) + 1;
         tmp1  := (4 * tmp1) - 1;
         tmp2  := (4 * ((tmp1 mod 146097) div 4)) + 3;
         year  := (100 * (tmp1 div 146097)) + (tmp2 div 1461) + year;
         tmp1  := (5 * (((tmp2 mod 1461) + 4) div 4)) - 3;
         month :=   tmp1 div 153;
         day   := ((tmp1 mod 153) + 5) div 5;
         if (month < 10) then
            month  := month + 3
         else
            begin
               month  := month - 9;
               year := year + 1;
            end {else}
      end {if}
   else
      begin
         month := 0;
         day   := 0;
         year  := 0;
      end; {else}
end;

function  GS_Date_CurCentury : GS_Date_CenTyp;
Var
  month, day, year, cw : Word;
begin
   if ThisCentury = '' then
   begin
      GetDate(year,month,day,cw);
      year := year div 100;
      Str(year:2, ThisCentury);
   end;
   GS_Date_CurCentury := ThisCentury
end;

function GS_Date_Curr : GS_Date_ValTyp;
Var
  month, day, year, cw : Word;
begin
   GetDate(year,month,day,cw);
   GS_Date_Curr := GS_Date_MDY2Jul(month, day, year);
end;

function GS_Date_DBStor(nv : GS_Date_ValTyp) : GS_Date_StrTyp;
var
   mm,
   dd,
   yy  : Word;
   ss  : string[8];
   sg  : string[4];
   i   : Integer;
begin
   ss := '        ';
   if nv > GS_Date_JulInv then
   begin
      GS_Date_Jul2MDY(nv,mm,dd,yy);
      str(mm:2,sg);
      move(sg[1],ss[5],2);
      str(dd:2,sg);
      move(sg[1],ss[7],2);
      str(yy:4,sg);
      move(sg[1],ss[1],4);
      for i := 1 to 8 do if ss[i] = ' ' then ss[i] := '0';
   end;
   GS_Date_DBStor := ss;
end;

function GS_Date_View(nv : GS_Date_ValTyp) : GS_Date_StrTyp;
var
   mm,
   dd,
   yy  : Word;
   ss  : string[10];
   sg1,
   sg2,
   sg3 : string[4];
   i   : Integer;
begin
   if nv > GS_Date_JulInv then
   begin
      GS_Date_Jul2MDY(nv,mm,dd,yy);
      if mm = 0 then sg1 := ''
      else
      begin
         str(mm:2,sg1);
         str(dd:2,sg2);
         str(yy:4,sg3);
      end;
   end else sg1 := '';
   case GS_Date_Type of
         American,
         USA,
         MDY          : ss := DateType_MDY(sg1,sg2,sg3);

         British,
         French,
         German,
         Italian,
         DMY          : ss := DateType_DMY(sg1,sg2,sg3);

         ANSI,
         Japan,
         YMD         : ss := DateType_YMD(sg1,sg2,sg3);
      end;
   if sg1 <> '' then
      for i := 1 to length(ss) do if ss[i] = ' ' then ss[i] := '0';
   GS_Date_View := ss;
end;

function GS_Date_Juln(sdate : GS_Date_StrTyp) : GS_Date_ValTyp;
var
   t      : string[10];
   valu,
   yy,
   mm,
   dd     : string[4];
   mmn,
   ddn,
   yyn    : Word;
   i      : Integer;
   rsl    : Integer;
   okDate : boolean;
   co     : longint;
begin
   mm:= '';
   dd := '';
   yy := '';
   t := sdate;
   rsl := 0;
   for i := length(t) downto 1 do
      if t[i] < '0' then rsl := i;
   if rsl = 0 then
   begin
      mm := copy(t,5,2);
      dd := copy(t,7,2);
      yy := copy(t,1,4);
   end
   else
   begin
      case GS_Date_Type of
         American,
         USA,
         MDY          : begin
                           mm := copy(t,1,2);
                           dd := copy(t,4,2);
                           yy := copy(t,7,4);
                        end;
         British,
         French,
         German,
         Italian,
         DMY          : begin
                           dd := copy(t,1,2);
                           mm := copy(t,4,2);
                           yy := copy(t,7,4);
                        end;
         Japan,
         YMD         : begin
                           yy := copy(t,1,rsl-1);
                           mm := copy(t,rsl+1,2);
                           dd := copy(t,rsl+4,2);
                        end;
      end;
      if length(yy) = 2 then yy := GS_Date_CurCentury+yy;
   end;
   okDate := false;
   val(mm,mmn,rsl);
   if rsl = 0 then
   begin
      val(dd,ddn,rsl);
      if rsl = 0 then
      begin
         val(yy,yyn,rsl);
         if rsl = 0 then
         begin
            if DateOk(mmn,ddn,yyn) then okDate := true;
         end;
      end;
   end;
   if not okDate then
      co := GS_Date_JulInv
   else
   begin
      co := GS_Date_MDY2Jul(mmn, ddn, yyn);
   end;
   GS_Date_Juln := co;
end;

begin
   GS_Date_Century := false;
   GS_Date_Type := American;
end.
