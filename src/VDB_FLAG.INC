{
       ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 presents: 'Halcyon/2' for Vp & Os/2

        Compiler Defines section:

        CLIPPER   - force Clipper .NTX compatibility

        FINAL     - force compiler to make a fast & small file than
                    in DEBUG (default) mode

        FINALDLL  - used to build the HALCYON DLL support files
         ³          same as FINAL but optimized for VRGDBENG.DLL
         ³           - no switch to obtain a DLL with std. exports
         ÃUSELIB     - used for static linking
         ÀUSELIBSHL  - used for GSOBSHEL internal static linking;
                       useful also for dynamic version of all
                       Halcyon modules!

        LSXPWR    - leave this voice for LSXPower full support

        TEST      - works only for GSOB_GEN, let you see working
                    progress for large DBF files
       ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        Port Ver. 3.01b - 11/1996 - Fixed all Os/2 api and numeric
                                    values. Added 32b DLL support!
             Ver. 3.5r1 - 12/1996 - First public Beta! 
       ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
}


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ DEFINES ÄÄ AREA ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{$DEFINE FINAL}
{ $ DEFINE CLIPPER}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ $ DEFINE FINALDLL}
{ $ DEFINE USELIB}
{ $ DEFINE USELIBSHL}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ $ DEFINE TEST}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{$DEFINE LSXPWR}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

{$N+,E+}                              {For extra precisions 19-20 digits!   }
{&Delphi+}                            {Delphi support, valid only under Vp/2}
{&G3-}      { 386 code enabled }      {Modify &G flags for your system      }
{&G4-}      { 486 code enabled }
{&G5+}      { 586 code enabled }

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{$IFDEF FINAL}      {build only units}
 {$UNDEF FINALDLL}
{$ENDIF}

{$IFDEF FINALDLL}   {build only dlls}
 {$UNDEF FINAL}
{$ENDIF}

{$IFDEF USELIB}     {use only for static linking of VRGDBENG.DLL}
 {$UNDEF USELIBSHL}
{$ENDIF}

{$IFDEF USELIBSHL}  {use only for static linking of VRGDBENG.DLL in GSOBSHEL}
 {$UNDEF USELIB}
{$ENDIF}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

{$IFDEF FINAL}
    {$S-,R-,L-,D-,V-,X+}
    {&Optimize+,Speed+,SmartLink+,Frame+}               {Vp/2 only}
{$ELSE}
    {$S+,R+,L+,D+}
{$ENDIF}

{$IFDEF FINALDLL}
  {&Cdecl+,OrgName+,Optimize+,Speed+,Frame+,SmartLink+} {Vp/2 only}
  {$D-,L-,R-,S-,V-,X+}
{$ENDIF}

{$IFnDEF OS2}
 {$Define USE16}
{$ENDIF}

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ERROR ÄÄÄ CHECK ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

{$IFnDEF FINAL}
 {$IFnDEF FINALDLL}
  ERROR: you must define FINAL or FINALDLL
 {$ENDIF}
{$ENDIF}

{$IFndEF USELIB}
 {$IFNDEF USELIBSHL}
  {ERROR: you must define USELIB or USELIBSHL testinf..dfsdfasdfa}
 {$ENDIF}
{$ENDIF}

