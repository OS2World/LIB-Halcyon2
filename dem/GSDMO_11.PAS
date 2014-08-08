program GSDMO_11;
{------------------------------------------------------------------------------
                         DBase Relational File Maker

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       This unit creates the files that will be used to demonstrate
       how to link the relationships between dBase files for data
       retrieval based on common fields in two files.

       The code is fairly complex in this routine, since it is busy
       creating random data for transaction records.  It is available
       for review, with no promise of how much this will contribute
       to an understanding of specific Griffin Solutions commands.

       This will first build a master file and then create a transaction
       file using the UNIQUEID field in the master file as the key.  The
       transactions will insert the UNIQUEID field in each record as the
       MASTERID field.  This field will be used to link back to the master
       record.

       A Master file index on the UNIQUEID field will be created.
       A Master file index on the LASTNAME+FIRSTNAME will be created.
       A Transaction file index on the MASTERID field will be created.

       The Master file will have the structure as defined in GSOB_GEN.PAS.
       The Transaction file structure is:

             MASTERID     C    8   0      Uses UNIQUEID from Master Record
             FULLNAME     C   40   0      In Lastname~FirstName format
             TRANDATE     D    8   0
             AMOUNT       N    8   2
             PAYTYPE      C    1   0

       New procedures/functions introduced are:

                 FieldPut
                 NumberPut

-------------------------------------------------------------------------------}

uses
   USE32,
   GSOB_Str,
   GSOB_DBF,
   GSOB_Gen,
   GSOB_Var,
   GSOBShel,
   {$IFDEF WINDOWS}
      WinCRT,
      WinDOS;
   {$ELSE}
      CRT,
      DOS;
   {$ENDIF}


var
   t : string;
   ix : integer;
   rn : integer;
   FLoc : integer;

   tfRanNum   : word;
   tfUniqId   : string[8];
   tfFullName : string[40];
   tfTranDate : longint;
   tfAmount   : FloatNum;
   tfPayType  : FloatNum;
   tfPayTypeS : string[1];

            {Routine to create a transaction file}

Procedure MakeTranFile;
var
   f : GSO_DB3Build;
begin
   f.Init('GSDMO_TF');
   f.InsertField('MASTERID','C',8,0);
   f.InsertField('FULLNAME','C',40,0);
   f.InsertField('TRANDATE','D',8,0);
   f.InsertField('AMOUNT','N',8,2);
   f.InsertField('PAYTYPE','C',1,0);
   f.Done;
end;

begin
   ClrScr;
   Writeln('Making GSDMO_MF.DBF Master File');
   MakeTestData(3,'GSDMO_MF', 20, false);
   WriteLn('GSDMO_MF Complete');
   Writeln('Making GSDMO_TF.DBF Transaction File');
   MakeTranFile;
   WriteLn('GSDMO_TF Complete');
   WriteLn('Creating Transactions');
   Select(1);
   Use('GSDMO_MF');
   IndexOn('GSDMO_ID','UNIQUEID');
   IndexOn('GSDMO_NM','LASTNAME + FIRSTNAME');
   Select(2);
   Use('GSDMO_TF');
   IndexOn('GSDMO_TN','MASTERID');
   Randomize;
   for rn := 1 to 50 do
   begin
      ix := Random(20) + 1;
      Select(1);
      Go(ix);                           {Read a random master record}
      tfUniqId := FieldGet('UNIQUEID');
      tfFullName := StringGet('LASTNAME') + '~' +
                    StringGet('FIRSTNAME');
      tfTranDate := Date - Random(31);
      tfAmount := (Random(30000) + 100);
      tfAmount := tfAmount/100;
      tfPayType := Random(4);
      str(tfPayType:1:0,tfPayTypeS);
      Select(2);                        {Change to area 2}
      ClearRecord;
      FieldPut('MASTERID',tfUniqId);
      StringPut('FULLNAME',tfFullName);
      DatePut('TRANDATE',tfTranDate);
      NumberPut('AMOUNT',tfAmount);     {Store tfAmount in AMOUNT}
      FieldPut('PAYTYPE',tfPayTypeS);
      dbAppend;
   end;
   WriteLn('Finished');
   CloseDataBases;
end.
