unit Use32;

interface

{$IFDEF USE16}
  {$UNDEF USE32}
{$ENDIF}

type
{$IFDEF USE32}
  Integer    = System.Longint;
  Word       = System.Longint;
const
  MaxInt     = MaxLongint;
{$ELSE}
  SmallInt   = System.Integer;
  SmallWord  = System.Word;
{$ENDIF}
type
  PByte      = ^Byte;
  PWord      = ^Word;
  PLongint   = ^Longint;
  PSmallInt  = ^SmallInt;
  PSmallWord = ^SmallWord;

implementation

end.
