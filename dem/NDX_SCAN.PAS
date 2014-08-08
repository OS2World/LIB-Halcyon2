Program Ndx_Scan;
{------------------------------------------------------------------------------
                          DBase File Index Analyze

       -------------------------------------------------------------
       This program can be used to analyze a .NDX file.  Note it uses the
       GSOB_NDX unit directly, showing the unit works independent of the
       dBase engine.   This example only works on character keys.  Numeric
       or date keys are not displayed.

-------------------------------------------------------------------------------}

uses Use32, Crt, Dos, GSOB_NDX;

var
   RPag      : LongInt;
   i,j,k,v   : integer;
   rl        : integer;
   ct        : integer;
   recnode,
   Less_Than : boolean;
   WorkNode  : GSP_InxNode;
   Next_Blk  : Longint;
   Ndx_F     : GSO_IndexFile;
   FName     : string;

begin
   Clrscr;
   Write('Enter Index File (without .NDX extension): ');
   Readln(FName);
   NDX_F.Init(FNAME);
   with NDX_F do
   begin
   Next_Blk := Ndx_NextBlock;
   writeln('--------------------------------------------------');
   writeln('File Name = ',dfFileName);
   writeln('Key Expression = ',ixKey_Form);
   writeln('Key Length = ',Key_Lgth,
                '   Maximum Keys/Block = ',Max_Keys);
   writeln('Root =',Ndx_Root:5,'   Next Block Available:',Next_Blk:5);
   tbLink^.FreeAll;
   WorkNode := tbLink^.FetchTop;
   writeln('Data records are at Level ',tbLink^.Count,
                ' in the hierarchy.');
   window(1,7,80,25);
   RPag := Ndx_Root;
   while (RPag < Next_Blk) and (RPag <> 0) do
   begin
      WorkNode := tbLink^.NodeGet(RPag);
      k := WorkNode^.ItemCount;
      System.write(RPag:5,'  [',k:2,']');
      CurrElmt :=  tbLink^.Elements[0];
      recnode := not WorkNode^.nonLeaf;
      v := 1;
      i := 1;
      while (i <= k) do
      begin
         CurrElmt :=  tbLink^.Elements[i-1];
         with CurrElmt^ do
         begin
            System.write('':v,Block_Ax:5);
            v := 12;
            if (i = k) and not recnode then System.write('    0 - empty')
            else
               begin
                  System.write(Recrd_Ax:5,' ');
                  if Ndx_Hdr.Data_Typ = 0 then
                     for j := 1 to Key_Lgth do
                        System.write(Char_Fld[j]);
               end;
         end;
         System.WRITELN;
         inc(i);
      end;
      system.writeln;
      System.Write('Enter Block (0 to Quit): ');
      Readln(RPag);
      tbLink^.FreeAll;
   end;
   end;
end.
