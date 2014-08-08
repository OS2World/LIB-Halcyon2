unit GSOB_FlP;
{ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                          Floating Point Formatting

           GSOB_FLP (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved 

       ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
       This unit handles the routines to create and compare floating
       point types used in dBase indexes.  These routines save 10K of
       memory over the $N,E option for numeric coprocessor emulation.
       Note that no math or number to string conversion is required.
       This allows for a far smaller unit.

       dBase III indexes use type double to store all numeric and date
       field keys.

       dBase IV .MDX indexes use type double to store date fields.  A
       BCD storage type is used to store Number and Float types.

       These routines will create both types for insertion into an index.
       Comparison routines are also included to allow searches of indexes.

  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }

{$I VDB_FLAG.INC} { Os/2 & Dos Compiler flags! }

{$O+} {Vp/2 simply skip this...}

interface

Uses Use32;

type

{-----------------------------------------------------------------------------
   gsDouble type simulates IEEE double precision type.
   Memory layout is:

                                 gsDouble Bytes
        ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÁÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿
       [7]      [6]      [5]      [4]      [3]      [2]      [1]      [0]
    76543210 76543210 76543210 76543210 76543210 76543210 76543210 76543210
    seeeeeee³eeeemmmm³mmmmmmmm³mmmmmmmm³mmmmmmmm³mmmmmmmm³mmmmmmmm³mmmmmmmm
    ³ÀÁÁÁÁÁÁÄÁÁÁÙÀÁÁÁÄÁÁÁÁÁÁÁÁÄÁÁÁÁÁÁÁÁÄÁÁÁÁÁÁÁÁÄÁÁÁÁÁÁÁÁÄÁÁÁÁÁÁÁÁÄÁÁÁÁÁÁÁÙ
    ³  Exponent                        Mantissa
    ÀÄ Sign

    Note the value is stored opposite from its representation; that is, the
    sign/(MSB exponent) byte is stored in gsDouble[7].  The next byte, with
    the (LSB exponent)/ (MSB Mantissa) is gsDouble[6]; and so on.....

-----------------------------------------------------------------------------}

   gsDouble    = array[0..7] of byte;

{-----------------------------------------------------------------------------
   gsFltBCD type simulates the type used by dBase IV to store .MDX numeric
   values.  This routine uses 'best guess' estimates of how the field is
   computed.  There are some inconsistencies.  For example, gsFltBCD[1]
   contains the sign and number of used bits, but does not follow a logical
   pattern since whole numbers with less than 6 digits show 41 bits used.
   All other cases show actual bits used.

   Memory layout is:

                                 gsFltBCD Bytes
        ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄ......ÄÄÄÄ¿
       [0]      [1]     [2]     [3]     [4]     [5]     [6]           [11]
    76543210 76543210 7-4 3-0 7-4 3-0 7-4 3-0 7-4 3-0 7-4 3-0        7-4 3-0
    pppppppp³seeeeeee³d00 d01³d02 d03³d04 d05³d06 d07³d08 d09³......³d19 d20³
    ÀÁÁÅÁÁÁÙ ³ÀÁÁÅÁÁÙ ÀÁÁÄÁÁÁÄÁÁÁÄÁÁÁÄÁÁÁÂÁÁÁÄÁÁÁÄÁÁÁÄÁÁÁÄÁÁÁÄ......ÄÁÁÁÄÁÁÙ
    Digits   ³   ÀÄÄÄ¿               BCD Digits
    Left of  À Sign  À BCD Digits
    Decimal            Used.  (In
    ($34 = 0)          Bits (BCD
                       digits * 4)
                       + 1 for sign

-----------------------------------------------------------------------------}

   gsFltBCD    = array[0..11] of byte;

function CmprDouble(var val1, val2) : Integer;
function CmprFltBCD(var val1, val2) : Integer;
procedure MakeDouble(C_String: string;var dtype: gsDouble;var rcode : Word);
procedure MakeFltBCD(C_String: string;var btype: gsFltBCD;var rcode : Word);
function CnvrtDouble(var dtype) : string;

implementation

const
   MaxNibble     = 64;
   MaxBcdNibble  = 20;
   EndNibble     = 63;

var
   Index         : Integer;
   DecPlaces     : Integer;
   TotPlaces     : Integer;
   RndgFlag      : boolean;
   InDecimals    : boolean;
   InExponent    : boolean;
   PositiveNum   : boolean;
   PositiveExp   : boolean;

   Mantissa      : array[0..MaxNibble] of byte;
   Exponent      : array[1..3] of byte;
   DecExponent   : Integer;

   BinExponent   : Word;
   GrtrZero      : boolean;
   DumpBit       : byte;

   rmdr,
   LSp,
   i             : Integer;

   DblAry        : array[1..16] of byte;
   DblWrk        : gsDouble;

   BCDWrk        : gsFltBCD;

function CmprDouble(var val1, val2) : Integer;
var
   v1       : gsDouble absolute val1;
   v2       : gsDouble absolute val2;
   val1neg,
   val2neg  : boolean;
   flg      : boolean;
   rslt     : Integer;
   loop     : Integer;
begin
   val1neg := v1[7] > 127;
   val2neg := v2[7] > 127;
   flg := val1neg = val2neg;
   if not flg then
   begin
      if val1neg then CmprDouble := -1 else CmprDouble := 1;
      exit;
   end;
   loop := 7;
   rslt := 0;
   while (rslt = 0) and (loop >= 0) do
   begin
      if v1[loop] < v2[loop] then rslt := -1
         else if v1[loop] > v2[loop] then rslt := 1;
      loop:= loop-1;
   end;
   if val1neg then rslt := rslt*(-1);
   CmprDouble := rslt;
end;

function CmprFltBCD(var val1, val2) : Integer;
var
   v1       : gsFltBcd absolute val1;
   v2       : gsFltBcd absolute val2;
   val1neg,
   val2neg  : boolean;
   flg      : boolean;
   rslt     : Integer;
   loop     : Integer;
begin
   val1neg := v1[1] > 127;
   val2neg := v2[1] > 127;
   flg := val1neg = val2neg;
   if not flg then
   begin
      if val1neg then CmprFltBCD := -1 else CmprFltBCD := 1;
      exit;
   end;
   rslt := 0;
   if v1[0] < v2[0] then rslt := -1
      else if v1[0] > v2[0] then rslt := 1;
   loop := 11;
   while (rslt = 0) and (loop >= 2) do
   begin
      if v1[loop] < v2[loop] then rslt := -1
         else if v1[loop] > v2[loop] then rslt := 1;
      loop:= loop-1;
   end;
   if val1neg then rslt := rslt*(-1);
   CmprFltBCD := rslt;
end;

procedure MakeDouble(C_String: string;var dtype: gsDouble;var rcode : Word);

   procedure AdjustMantissa;
   begin
      if DecExponent < 0 then
      begin
         while DecExponent < 0 do
         begin
            while Mantissa[1] = 0 do
            begin
               move(Mantissa[2], Mantissa[1], EndNibble);
               dec(BinExponent,4);
            end;
            for i := 1 to pred(EndNibble) do
            begin
               Mantissa[succ(i)] := Mantissa[succ(i)] +
                                    ((Mantissa[i] mod 10) * 16);
               Mantissa[i] := Mantissa[i] div 10;
            end;
            Mantissa[EndNibble] := Mantissa[EndNibble] div 10;
            inc(DecExponent);
         end;
      end
      else
                         {test for exponent > 0}
         if DecExponent > 0 then
         begin
            while DecExponent > 0 do
            begin
               if Mantissa[1] <> 0 then
               begin
                  rmdr := Mantissa[EndNibble];
                  move(Mantissa[1], Mantissa[2], pred(EndNibble));
                  Mantissa[1] := 0;
                  inc(BinExponent,4);
                  if rmdr > 7 then
                  begin
                     inc(Mantissa[EndNibble]);
                     i := EndNibble;
                     while Mantissa[i] > 15 do
                     begin
                        Mantissa[i] := Mantissa[i] and $0F;
                        dec(i);
                        inc(Mantissa[i]);
                     end;
                  end;
               end;
               Mantissa[EndNibble] :=  (Mantissa[EndNibble] * 10);
               for i := pred(EndNibble) downto 1 do
               begin
                  Mantissa[i] := (Mantissa[i] * 10) +
                                 (Mantissa[succ(i)] shr 4);
                  Mantissa[succ(i)] :=
                                  Mantissa[succ(i)] and $0F;
               end;
               dec(DecExponent);
            end;
         end;
   end;



begin
   rcode := 0;
   PositiveNum := true;
   PositiveExp := true;
   DecPlaces := 0;
   DecExponent := 0;
   RndgFlag  := true;
   InDecimals := false;
   InExponent := false;
   FillChar(Mantissa,MaxNibble+1,#0);
   FillChar(Exponent,3,#0);
   if C_String <> '' then
   begin
      LSp := 1;
      while (C_String[LSp] = ' ') and (LSp <= ord(C_String[0])) do
         LSp := LSp+1;
      for Index := LSp to length(C_String) do
      begin
         case C_String[Index] of

         '+'      : if InDecimals then PositiveExp := true
                       else PositiveNum := true;

         '-'      : if InExponent then PositiveExp := false
                       else PositiveNum := false;

         '0'..'9' : begin
                       if InDecimals then inc(DecPlaces);
                       if InExponent then
                       begin
                          DecExponent := (DecExponent * 10) +
                                         byte(C_String[Index]) and $0F;
                       end
                       else
                       begin
                          if Mantissa[1] = 0 then
                          begin
                             Mantissa[EndNibble] :=
                                             (Mantissa[EndNibble] * 10) +
                                             (byte(C_String[Index]) and $0F);
                             for i := pred(EndNibble) downto 1 do
                             begin
                                Mantissa[i] := (Mantissa[i] * 10) +
                                               (Mantissa[succ(i)] shr 4);
                                Mantissa[succ(i)] :=
                                                Mantissa[succ(i)] and $0F;
                             end;
                          end
                          else
                          begin
                             if RndgFlag then
                             begin
                                RndgFlag := false;
                                if C_String[Index] > '4' then
                                                     inc(Mantissa[EndNibble]);
                             end;
                             if not InDecimals then dec(DecPlaces);
                          end;
                       end;
                    end;


         '.'      : InDecimals := true;

         'e',
         'E'      : begin
                       InExponent := true;
                       InDecimals := false;
                    end;

         else       begin
                       rcode := Index;
                    end;
         end;
      end;

      if not PositiveExp then DecExponent := DecExponent * -1;
      DecExponent := DecExponent - DecPlaces;

      GrtrZero := false;
      for i := 1 to EndNibble do if Mantissa[i] > 0 then GrtrZero := true;

      if GrtrZero then
      begin

         BinExponent := EndNibble*4;
         AdjustMantissa;
         while Mantissa[1] = 0 do
         begin
            move(Mantissa[2], Mantissa[1], EndNibble);
            dec(BinExponent,4);
         end;


         DumpBit := 0;
         while DumpBit = 0 do
         begin
            dec(BinExponent);
            for i := 1 to EndNibble do Mantissa[i] := Mantissa[i] shl 1;
            DumpBit := Mantissa[1] and $10;
            for i := 1 to EndNibble do
            begin
               if Mantissa[succ(i)] > 15 then inc(Mantissa[i]);
               Mantissa[i] := Mantissa[i] and $0F;
            end;
         end;

         if Mantissa[14] > 7 then
         begin
            inc(Mantissa[13]);
            i := 13;
            while (Mantissa[i] > 15) and (i > 0) do
            begin
               Mantissa[i] := Mantissa[i] and $0F;
               dec(i);
               inc(Mantissa[i]);
            end;
         end;

         BinExponent := BinExponent + 1023;
         for i := 3 downto 1 do
         begin
            Exponent[i] := BinExponent and $000F;
            BinExponent := BinExponent shr 4;
         end;

      end;
      if not PositiveNum then Exponent[1] := Exponent[1] or $08;
   end;

   DblWrk[7] := (Exponent[1] shl 4) + Exponent[2];
   DblWrk[6] := (Exponent[3] shl 4) + Mantissa[1];
   DblWrk[5] := (Mantissa[2] shl 4) + Mantissa[3];
   DblWrk[4] := (Mantissa[4] shl 4) + Mantissa[5];
   DblWrk[3] := (Mantissa[6] shl 4) + Mantissa[7];
   DblWrk[2] := (Mantissa[8] shl 4) + Mantissa[9];
   DblWrk[1] := (Mantissa[10] shl 4) + Mantissa[11];
   DblWrk[0] := (Mantissa[12] shl 4) + Mantissa[13];
   dtype := DblWrk;
end;



procedure MakeFltBCD(C_String: string;var btype: gsFltBCD;var rcode : Word);
begin
   rcode := 0;
   PositiveNum := true;
   PositiveExp := true;
   DecPlaces := 0;
   TotPlaces := 0;
   DecExponent := 0;
   InDecimals := false;
   InExponent := false;
   FillChar(Mantissa,MaxBCDNibble+1,#0);
   if C_String <> '' then
   begin
      LSp := 1;
      while (C_String[LSp] = ' ') and (LSp <= ord(C_String[0])) do
         LSp := LSp+1;
      for Index := LSp to length(C_String) do
      begin
         case C_String[Index] of

         '+'      : if InDecimals then PositiveExp := true
                       else PositiveNum := true;

         '-'      : if InExponent then PositiveExp := false
                       else PositiveNum := false;

         '0'..'9' : begin
                       if InDecimals then inc(DecPlaces);
                       if InExponent then
                       begin
                          DecExponent := (DecExponent * 10) +
                                         byte(C_String[Index]) and $0F;
                       end
                       else
                       begin
                          Mantissa[TotPlaces] := byte(C_String[Index]) and $0F;
                          inc(TotPlaces);
                       end;
                    end;

         '.'      : InDecimals := true;

         'e',
         'E'      : begin
                       InExponent := true;
                       InDecimals := false;
                    end;

         else       begin
                       rcode := Index;
                    end;
         end;
      end;

      if not PositiveExp then DecExponent := DecExponent * -1;
      DecExponent := DecExponent - (TotPlaces - DecPlaces);

      GrtrZero := false;
      for i := 0 to MaxNibble-1 do if Mantissa[i] > 0 then GrtrZero := true;

      if not GrtrZero then
      begin
         TotPlaces := 0;
         DecExponent := 0;
      end;
      TotPlaces := TotPlaces * 4;
      if not PositiveNum then TotPlaces := TotPlaces or $80;
   end;

   BCDWrk[0] := DecExponent + $34;
   BCDWrk[1] := TotPlaces + 1;
   for i := 0 to 9 do
      BCDWrk[i+2] := (Mantissa[i*2] shl 4) + Mantissa[(i*2)+1];
   btype := BCDWrk;
end;

function CnvrtDouble(var dtype) : string;
var
   dbl_in : gsDouble absolute dtype;
   rnum   : real;
   rpsudo : array[0..5] of byte absolute rnum;
   st     : string;
begin
   PositiveNum := dbl_in[7] < $80;
   Exponent[1] := (dbl_in[7] shr 4) and $07;
   Exponent[2] := dbl_in[7] and $0F;
   Exponent[3] := (dbl_in[6] shr 4) and $0F;
   BinExponent := 0;
   for i := 1 to 3 do
      BinExponent := (BinExponent shl 4) or Exponent[i];
   BinExponent := BinExponent - 1023;
   rpsudo[0] := BinExponent + 129;
   rpsudo[5] := (dbl_in[6] shl 3) and $78;
   rpsudo[5] := (dbl_in[5] shr 5) or rpsudo[5];
   if not PositiveNum then rpsudo[5] := rpsudo[5] or $80;
   rpsudo[4] := (dbl_in[5] shl 3);
   rpsudo[4] := (dbl_in[4] shr 5) or rpsudo[4];
   rpsudo[3] := (dbl_in[4] shl 3);
   rpsudo[3] := (dbl_in[3] shr 5) or rpsudo[3];
   rpsudo[2] := (dbl_in[3] shl 3);
   rpsudo[2] := (dbl_in[2] shr 5) or rpsudo[2];
   rpsudo[1] := (dbl_in[2] shl 3);
   rpsudo[1] := (dbl_in[1] shr 5) or rpsudo[1];
   str(rnum,st);
   CnvrtDouble := st;
end;

end.
