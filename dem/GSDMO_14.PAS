program GSDMO_14;
{------------------------------------------------------------------------------
                               DBase File Maker

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       Program that creates a dBase file.

       Demonstrates the use of GS_DB4Build to create a dBase file.  A
       file 'MYFILE.DBF' will be created.

-------------------------------------------------------------------------------}

uses
   USE32,
   GSOB_DBF;

var

   MyFile : GSO_DB4Build;   {Creates a dBase IV file}
                            {Use GSO_DB3Build for a dBase III file}

begin
   with MyFile do
   begin
      Init('MyFile');
                     {Insert the fields into the file}
      InsertField('FIELD1','C',8,0);      {Character, length 8}
      InsertField('SECOND','D',8,0);      {Date (length 8)}
      InsertField('THIRD','L',1,0);       {Logical (length 1)}
      InsertField('FOURTH','N',6,2);      {Number, length 6, 2 Decimals}
                     {End insertion by calling Done to close the file}
      Done;
   end;
end.
