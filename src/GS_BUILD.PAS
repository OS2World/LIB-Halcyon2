Program GS_Build;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                      Halcyon/2 TPU/TPP/TPW/VPI Builder

           GS_BUILD (C) 1996 of ThE ToY Of Virtual Reality Group

                              No rights reserved 

       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       This unit builds the TPU/TPP/TPW/VPI units for all units.
       No action is accomplished except to compile all units.

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 }

{$I VDB_FLAG.INC} {Os/2 & Dos Compiler flags!}

uses
   USE32,
   GSOBSHEL,
   {$IFNDEF WINDOWS}
    {$IfnDef Os2}
    GSOB_EDT,
    GSV_FLDS,
    SMPLSTUF,
    XTRASTUF,
    {$EndIf}
   {$ENDIF}
   GSOB_DSK,
   GSOB_GEN,
   GSOB_DTE,
   GSOB_OBJ,
   GSOB_NDX, { - DBase indexes support  }
   GSOB_NTX, { - Clipper indexes support}
   GSOB_INX,
   GSOB_STR,
   GSOB_DBS,
   GSOB_FLP,
   GSOB_DBF, {fixate this DBT function!Procedure GSO_DBFBuild.WriteDBT;}
   GSOB_VAR,
   GSOB_MMO,
   GSXT_BRO, { - FileBrowser }
   GSXT_SCH; { - Fast DBSearch routine }

begin
end.
