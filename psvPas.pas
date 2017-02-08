{*******************************************************}
{               RichEdit Syntax HighLight               }
{                     version 2.0                       }
{ Author:                                               }
{ Serhiy Perevoznyk                                     }
{ serge_perevoznyk@hotmail.com                          }
{*******************************************************}

{The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynHighlighterPas.pas, released 2000-04-17.
The Original Code is based on the mwPasSyn.pas file from the
mwEdit component suite by Martin Waldenburg and other developers, the Initial
Author of this file is Martin Waldenburg.
Portions created by Martin Waldenburg are Copyright (C) 1998 Martin Waldenburg.
All Rights Reserved.
The Original Code can be obtained from http://synedit.sourceforge.net/
}

unit psvPas;

interface

uses
  {SysUtils, }Windows{, Classes, Controls}, psvSyntax{, Graphics}, Avl;

type
  TtkTokenKind = (tkAsm, tkComment, tkIdentifier, tkKey, tkNull, tkNumber,
    tkSpace, tkString, tkSymbol, tkUnknown);

  TRangeState = (rsANil, rsAnsi, rsAnsiAsm, rsAsm, rsBor, rsBorAsm, rsProperty,
    rsUnKnown);

  TProcTableProc = procedure of object;

  PIdentFuncTableFunc = ^TIdentFuncTableFunc;
  TIdentFuncTableFunc = function: TtkTokenKind of object;

  TpsvPasRTF = class(TpsvRTFSyntax)
  private
    fAsmStart: Boolean;
    fRange: TRangeState;
    fLine: PChar;
    fLineNumber: Integer;
    fProcTable: array[#0..#255] of TProcTableProc;
    Run: LongInt;
    fStringLen: Integer;
    fToIdent: PChar;
    fIdentFuncTable: array[0..191] of TIdentFuncTableFunc;
    fTokenPos: Integer;
    FTokenID: TtkTokenKind;
    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: string): Boolean;
    function Func15: TtkTokenKind;
    function Func19: TtkTokenKind;
    function Func20: TtkTokenKind;
    function Func21: TtkTokenKind;
    function Func23: TtkTokenKind;
    function Func25: TtkTokenKind;
    function Func27: TtkTokenKind;
    function Func28: TtkTokenKind;
    function Func32: TtkTokenKind;
    function Func33: TtkTokenKind;
    function Func35: TtkTokenKind;
    function Func37: TtkTokenKind;
    function Func38: TtkTokenKind;
    function Func39: TtkTokenKind;
    function Func40: TtkTokenKind;
    function Func41: TtkTokenKind;
    function Func44: TtkTokenKind;
    function Func45: TtkTokenKind;
    function Func47: TtkTokenKind;
    function Func49: TtkTokenKind;
    function Func52: TtkTokenKind;
    function Func54: TtkTokenKind;
    function Func55: TtkTokenKind;
    function Func56: TtkTokenKind;
    function Func57: TtkTokenKind;
    function Func59: TtkTokenKind;
    function Func60: TtkTokenKind;
    function Func61: TtkTokenKind;
    function Func63: TtkTokenKind;
    function Func64: TtkTokenKind;
    function Func65: TtkTokenKind;
    function Func66: TtkTokenKind;
    function Func69: TtkTokenKind;
    function Func71: TtkTokenKind;
    function Func73: TtkTokenKind;
    function Func75: TtkTokenKind;
    function Func76: TtkTokenKind;
    function Func79: TtkTokenKind;
    function Func81: TtkTokenKind;
    function Func84: TtkTokenKind;
    function Func85: TtkTokenKind;
    function Func87: TtkTokenKind;
    function Func88: TtkTokenKind;
    function Func91: TtkTokenKind;
    function Func92: TtkTokenKind;
    function Func94: TtkTokenKind;
    function Func95: TtkTokenKind;
    function Func96: TtkTokenKind;
    function Func97: TtkTokenKind;
    function Func98: TtkTokenKind;
    function Func99: TtkTokenKind;
    function Func100: TtkTokenKind;
    function Func101: TtkTokenKind;
    function Func102: TtkTokenKind;
    function Func103: TtkTokenKind;
    function Func105: TtkTokenKind;
    function Func106: TtkTokenKind;
    function Func117: TtkTokenKind;
    function Func126: TtkTokenKind;
    function Func129: TtkTokenKind;
    function Func132: TtkTokenKind;
    function Func133: TtkTokenKind;
    function Func136: TtkTokenKind;
    function Func141: TtkTokenKind;
    function Func143: TtkTokenKind;
    function Func166: TtkTokenKind;
    function Func168: TtkTokenKind;
    function Func191: TtkTokenKind;
    function AltFunc: TtkTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PChar): TtkTokenKind;
    procedure MakeMethodTables;
    procedure AddressOpProc;
    procedure AsciiCharProc;
    procedure AnsiProc;
    procedure BorProc;
    procedure BraceOpenProc;
    procedure ColonOrGreaterProc;
    procedure CRProc;
    procedure IdentProc;
    procedure IntegerProc;
    procedure LFProc;
    procedure LowerProc;
    procedure NullProc;
    procedure NumberProc;
    procedure PointProc;
    procedure RoundOpenProc;
    procedure SemicolonProc;
    procedure SlashProc;
    procedure SpaceProc;
    procedure StringProc;
    procedure SymbolProc;
    procedure UnknownProc;
  protected
    function GetEol: Boolean; override;
    function GetRange: Pointer;
    function GetToken: string; override;
    function GetTokenAttribute: integer; override;
    function GetTokenID: TtkTokenKind;
    function GetTokenKind: integer; 
    function GetTokenPos: Integer; 
    procedure Next; override;
    procedure ResetRange; 
    procedure SetLine(NewValue: string; LineNumber:Integer); override;
    procedure SetRange(Value: Pointer);
    procedure  PrepareToken(var AToken : string); override;
    function PrepareOutput(Attr: integer; AToken : string): string; override;
  public
    constructor Create;
  end;

implementation


var
  Identifiers: array[#0..#255] of ByteBool;
  mHashTable: array[#0..#255] of Integer;

procedure MakeIdentTable;
var
  I, J: Char;
begin
  for I := #0 to #255 do
  begin
    Case I of
      '_', '0'..'9', 'a'..'z', 'A'..'Z': Identifiers[I] := True;
    else Identifiers[I] := False;
    end;
    J := UpCase(I);
    Case I of
      'a'..'z', 'A'..'Z', '_': mHashTable[I] := Ord(J) - 64;
    else mHashTable[Char(I)] := 0;
    end;
  end;
end;

procedure TpsvPasRTF.InitIdent;
var
  I: Integer;
  pF: PIdentFuncTableFunc;
begin
  pF := PIdentFuncTableFunc(@fIdentFuncTable);
  for I := Low(fIdentFuncTable) to High(fIdentFuncTable) do begin
    pF^ := AltFunc;
    Inc(pF);
  end;
  fIdentFuncTable[15] := Func15;
  fIdentFuncTable[19] := Func19;
  fIdentFuncTable[20] := Func20;
  fIdentFuncTable[21] := Func21;
  fIdentFuncTable[23] := Func23;
  fIdentFuncTable[25] := Func25;
  fIdentFuncTable[27] := Func27;
  fIdentFuncTable[28] := Func28;
  fIdentFuncTable[32] := Func32;
  fIdentFuncTable[33] := Func33;
  fIdentFuncTable[35] := Func35;
  fIdentFuncTable[37] := Func37;
  fIdentFuncTable[38] := Func38;
  fIdentFuncTable[39] := Func39;
  fIdentFuncTable[40] := Func40;
  fIdentFuncTable[41] := Func41;
  fIdentFuncTable[44] := Func44;
  fIdentFuncTable[45] := Func45;
  fIdentFuncTable[47] := Func47;
  fIdentFuncTable[49] := Func49;
  fIdentFuncTable[52] := Func52;
  fIdentFuncTable[54] := Func54;
  fIdentFuncTable[55] := Func55;
  fIdentFuncTable[56] := Func56;
  fIdentFuncTable[57] := Func57;
  fIdentFuncTable[59] := Func59;
  fIdentFuncTable[60] := Func60;
  fIdentFuncTable[61] := Func61;
  fIdentFuncTable[63] := Func63;
  fIdentFuncTable[64] := Func64;
  fIdentFuncTable[65] := Func65;
  fIdentFuncTable[66] := Func66;
  fIdentFuncTable[69] := Func69;
  fIdentFuncTable[71] := Func71;
  fIdentFuncTable[73] := Func73;
  fIdentFuncTable[75] := Func75;
  fIdentFuncTable[76] := Func76;
  fIdentFuncTable[79] := Func79;
  fIdentFuncTable[81] := Func81;
  fIdentFuncTable[84] := Func84;
  fIdentFuncTable[85] := Func85;
  fIdentFuncTable[87] := Func87;
  fIdentFuncTable[88] := Func88;
  fIdentFuncTable[91] := Func91;
  fIdentFuncTable[92] := Func92;
  fIdentFuncTable[94] := Func94;
  fIdentFuncTable[95] := Func95;
  fIdentFuncTable[96] := Func96;
  fIdentFuncTable[97] := Func97;
  fIdentFuncTable[98] := Func98;
  fIdentFuncTable[99] := Func99;
  fIdentFuncTable[100] := Func100;
  fIdentFuncTable[101] := Func101;
  fIdentFuncTable[102] := Func102;
  fIdentFuncTable[103] := Func103;
  fIdentFuncTable[105] := Func105;
  fIdentFuncTable[106] := Func106;
  fIdentFuncTable[117] := Func117;
  fIdentFuncTable[126] := Func126;
  fIdentFuncTable[129] := Func129;
  fIdentFuncTable[132] := Func132;
  fIdentFuncTable[133] := Func133;
  fIdentFuncTable[136] := Func136;
  fIdentFuncTable[141] := Func141;
  fIdentFuncTable[143] := Func143;
  fIdentFuncTable[166] := Func166;
  fIdentFuncTable[168] := Func168;
  fIdentFuncTable[191] := Func191;
end;

function TpsvPasRTF.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  while ToHash^ in ['a'..'z', 'A'..'Z'] do
  begin
    inc(Result, mHashTable[ToHash^]);
    inc(ToHash);
  end;
  if ToHash^ in ['_', '0'..'9'] then inc(ToHash);
  fStringLen := ToHash - fToIdent;
end; { KeyHash }

function TpsvPasRTF.KeyComp(const aKey: string): Boolean;
var
  I: Integer;
  Temp: PChar;
begin
  Temp := fToIdent;
  if Length(aKey) = fStringLen then
  begin
    Result := True;
    for i := 1 to fStringLen do
    begin
      if mHashTable[Temp^] <> mHashTable[aKey[i]] then
      begin
        Result := False;
        break;
      end;
      inc(Temp);
    end;
  end else Result := False;
end; { KeyComp }

function TpsvPasRTF.Func15: TtkTokenKind;
begin
  if KeyComp('If') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func19: TtkTokenKind;
begin
  if KeyComp('Do') then Result := tkKey else
    if KeyComp('And') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func20: TtkTokenKind;
begin
  if KeyComp('As') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func21: TtkTokenKind;
begin
  if KeyComp('Of') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func23: TtkTokenKind;
begin
  if KeyComp('End') then begin
    Result := tkKey;
    fRange := rsUnknown;
  end else
    if KeyComp('In') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func25: TtkTokenKind;
begin
  if KeyComp('Far') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func27: TtkTokenKind;
begin
  if KeyComp('Cdecl') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func28: TtkTokenKind;
begin
  if KeyComp('Is') then Result := tkKey else
    if KeyComp('Read') then
    begin
      if fRange = rsProperty then Result := tkKey else Result := tkIdentifier;
    end else
      if KeyComp('Case') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func32: TtkTokenKind;
begin
  if KeyComp('Label') then Result := tkKey else
    if KeyComp('Mod') then Result := tkKey else
      if KeyComp('File') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func33: TtkTokenKind;
begin
  if KeyComp('Or') then Result := tkKey else
    if KeyComp('Asm') then
    begin
      Result := tkKey;
      fRange := rsAsm;
      fAsmStart := True;
    end else Result := tkIdentifier;
end;

function TpsvPasRTF.Func35: TtkTokenKind;
begin
  if KeyComp('Nil') then Result := tkKey else
    if KeyComp('To') then Result := tkKey else
      if KeyComp('Div') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func37: TtkTokenKind;
begin
  if KeyComp('Begin') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func38: TtkTokenKind;
begin
  if KeyComp('Near') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func39: TtkTokenKind;
begin
  if KeyComp('For') then Result := tkKey else
    if KeyComp('Shl') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func40: TtkTokenKind;
begin
  if KeyComp('Packed') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func41: TtkTokenKind;
begin
  if KeyComp('Else') then Result := tkKey else
    if KeyComp('Var') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func44: TtkTokenKind;
begin
  if KeyComp('Set') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func45: TtkTokenKind;
begin
  if KeyComp('Shr') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func47: TtkTokenKind;
begin
  if KeyComp('Then') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func49: TtkTokenKind;
begin
  if KeyComp('Not') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func52: TtkTokenKind;
begin
  if KeyComp('Pascal') then Result := tkKey else
    if KeyComp('Raise') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func54: TtkTokenKind;
begin
  if KeyComp('Class') then Result := tkKey
  else Result := tkIdentifier;
end;

function TpsvPasRTF.Func55: TtkTokenKind;
begin
  if KeyComp('Object') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func56: TtkTokenKind;
begin
  if KeyComp('Index') then
  begin
    if fRange = rsProperty then Result := tkKey else Result := tkIdentifier;
  end else
    if KeyComp('Out') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func57: TtkTokenKind;
begin
  if KeyComp('Goto') then Result := tkKey else
    if KeyComp('While') then Result := tkKey else
      if KeyComp('Xor') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func59: TtkTokenKind;
begin
  if KeyComp('Safecall') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func60: TtkTokenKind;
begin
  if KeyComp('With') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func61: TtkTokenKind;
begin
  if KeyComp('Dispid') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func63: TtkTokenKind;
begin
  if KeyComp('Public') then Result := tkKey else
    if KeyComp('Record') then Result := tkKey else
      if KeyComp('Array') then Result := tkKey else
        if KeyComp('Try') then Result := tkKey else
          if KeyComp('Inline') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func64: TtkTokenKind;
begin
  if KeyComp('Unit') then Result := tkKey else
    if KeyComp('Uses') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func65: TtkTokenKind;
begin
  if KeyComp('Repeat') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func66: TtkTokenKind;
begin
  if KeyComp('Type') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func69: TtkTokenKind;
begin
  if KeyComp('Default') then Result := tkKey else
    if KeyComp('Dynamic') then Result := tkKey else
      if KeyComp('Message') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func71: TtkTokenKind;
begin
  if KeyComp('Stdcall') then Result := tkKey else
    if KeyComp('Const') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func73: TtkTokenKind;
begin
  if KeyComp('Except') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func75: TtkTokenKind;
begin
  if KeyComp('Write') then
  begin
    if fRange = rsProperty then Result := tkKey else Result := tkIdentifier;
  end else Result := tkIdentifier;
end;

function TpsvPasRTF.Func76: TtkTokenKind;
begin
  if KeyComp('Until') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func79: TtkTokenKind;
begin
  if KeyComp('Finally') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func81: TtkTokenKind;
begin
  if KeyComp('Stored') then
  begin
    if fRange = rsProperty then Result := tkKey else Result := tkIdentifier;
  end else
    if KeyComp('Interface') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func84: TtkTokenKind;
begin
  if KeyComp('Abstract') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func85: TtkTokenKind;
begin
  if KeyComp('Forward') then Result := tkKey else
    if KeyComp('Library') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func87: TtkTokenKind;
begin
  if KeyComp('String') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func88: TtkTokenKind;
begin
  if KeyComp('Program') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func91: TtkTokenKind;
begin
  if KeyComp('Downto') then Result := tkKey else
    if KeyComp('Private') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func92: TtkTokenKind;
begin
  if KeyComp('Inherited') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func94: TtkTokenKind;
begin
  if KeyComp('Assembler') then Result := tkKey else
    if KeyComp('Readonly') then
    begin
      if fRange = rsProperty then Result := tkKey else Result := tkIdentifier;
    end else Result := tkIdentifier;
end;

function TpsvPasRTF.Func95: TtkTokenKind;
begin
  if KeyComp('Absolute') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func96: TtkTokenKind;
begin
  if KeyComp('Published') then Result := tkKey else
    if KeyComp('Override') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func97: TtkTokenKind;
begin
  if KeyComp('Threadvar') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func98: TtkTokenKind;
begin
  if KeyComp('Export') then Result := tkKey else
    if KeyComp('Nodefault') then
    begin
      if fRange = rsProperty then Result := tkKey else Result := tkIdentifier;
    end else Result := tkIdentifier;
end;

function TpsvPasRTF.Func99: TtkTokenKind;
begin
  if KeyComp('External') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func100: TtkTokenKind;
begin
  if KeyComp('Automated') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func101: TtkTokenKind;
begin
  if KeyComp('Register') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func102: TtkTokenKind;
begin
  if KeyComp('Function') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func103: TtkTokenKind;
begin
  if KeyComp('Virtual') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func105: TtkTokenKind;
begin
  if KeyComp('Procedure') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func106: TtkTokenKind;
begin
  if KeyComp('Protected') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func117: TtkTokenKind;
begin
  if KeyComp('Exports') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func126: TtkTokenKind;
begin
  Result := tkIdentifier;
end;

function TpsvPasRTF.Func129: TtkTokenKind;
begin
  if KeyComp('Dispinterface') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func132: TtkTokenKind;
begin
  Result := tkIdentifier;
end;

function TpsvPasRTF.Func133: TtkTokenKind;
begin
  if KeyComp('Property') then
  begin
    Result := tkKey;
    fRange := rsProperty;
  end else Result := tkIdentifier;
end;

function TpsvPasRTF.Func136: TtkTokenKind;
begin
  if KeyComp('Finalization') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func141: TtkTokenKind;
begin
  if KeyComp('Writeonly') then
  begin
    if fRange = rsProperty then Result := tkKey else Result := tkIdentifier;
  end else Result := tkIdentifier;
end;

function TpsvPasRTF.Func143: TtkTokenKind;
begin
  if KeyComp('Destructor') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func166: TtkTokenKind;
begin
  if KeyComp('Constructor') then Result := tkKey else
    if KeyComp('Implementation') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func168: TtkTokenKind;
begin
  if KeyComp('Initialization') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.Func191: TtkTokenKind;
begin
  if KeyComp('Resourcestring') then Result := tkKey else
    if KeyComp('Stringresource') then Result := tkKey else Result := tkIdentifier;
end;

function TpsvPasRTF.AltFunc: TtkTokenKind;
begin
  Result := tkIdentifier
end;

function TpsvPasRTF.IdentKind(MayBe: PChar): TtkTokenKind;
var
  HashKey: Integer;
begin
  fToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey < 192 then Result := fIdentFuncTable[HashKey] else
    Result := tkIdentifier;
end;

procedure TpsvPasRTF.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      #0: fProcTable[I] := NullProc;
      #10: fProcTable[I] := LFProc;
      #13: fProcTable[I] := CRProc;
      #1..#9, #11, #12, #14..#32:
        fProcTable[I] := SpaceProc;
      '#': fProcTable[I] := AsciiCharProc;
      '$': fProcTable[I] := IntegerProc;
      #39: fProcTable[I] := StringProc;
      '0'..'9': fProcTable[I] := NumberProc;
      'A'..'Z', 'a'..'z', '_':
        fProcTable[I] := IdentProc;
      '{': fProcTable[I] := BraceOpenProc;
      '}', '!', '"', '%', '&', '('..'/', ':'..'@', '['..'^', '`', '~':
        begin
          case I of
            '(': fProcTable[I] := RoundOpenProc;
            '.': fProcTable[I] := PointProc;
            ';': fProcTable[I] := SemicolonProc;                                
            '/': fProcTable[I] := SlashProc;
            ':', '>': fProcTable[I] := ColonOrGreaterProc;
            '<': fProcTable[I] := LowerProc;
            '@': fProcTable[I] := AddressOpProc;
          else
            fProcTable[I] := SymbolProc;
          end;
        end;
    else
      fProcTable[I] := UnknownProc;
    end;
end;

constructor TpsvPasRTF.Create;
begin
  inherited Create;
  InitIdent;
  MakeMethodTables;
  fRange := rsUnknown;
  fAsmStart := False;
  CreateColorTable([clNavy,
                    clBlack,
                    clBlack,
                    clBlack,
                    clNavy,
                    clBlack, 
                    clBlack, 
                    clGreen]);
end; { Create }

procedure TpsvPasRTF.SetLine(NewValue: string; LineNumber:Integer);
begin
  fLine := PChar(NewValue);
  Run := 0;
  fLineNumber := LineNumber;
  Next;
end; { SetLine }

procedure TpsvPasRTF.AddressOpProc;
begin
  fTokenID := tkSymbol;
  inc(Run);
  if fLine[Run] = '@' then inc(Run);
end;

procedure TpsvPasRTF.AsciiCharProc;
begin
  fTokenID := tkString;
  inc(Run);
  while FLine[Run] in ['0'..'9'] do inc(Run);
end;

procedure TpsvPasRTF.BorProc;
begin
  case fLine[Run] of
     #0: NullProc;
    #10: LFProc;
    #13: CRProc;
    else begin
      fTokenID := tkComment;
      repeat
        if fLine[Run] = '}' then begin
          Inc(Run);
          if fRange = rsBorAsm then
            fRange := rsAsm
          else
            fRange := rsUnKnown;
          break;
        end;
        Inc(Run);
      until fLine[Run] in [#0, #10, #13];
    end;
  end;
end;

procedure TpsvPasRTF.BraceOpenProc;
begin
  if fRange = rsAsm then
    fRange := rsBorAsm
  else
    fRange := rsBor;
  BorProc;
end;

procedure TpsvPasRTF.ColonOrGreaterProc;
begin
  fTokenID := tkSymbol;
  inc(Run);
  if fLine[Run] = '=' then inc(Run);
end;

procedure TpsvPasRTF.CRProc;
begin
  fTokenID := tkSpace;
  inc(Run);
  if fLine[Run] = #10 then inc(Run);
end;

procedure TpsvPasRTF.IdentProc;
begin
  fTokenID := IdentKind((fLine + Run));
  inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do inc(Run);
end;

procedure TpsvPasRTF.IntegerProc;
begin
  inc(Run);
  fTokenID := tkNumber;
  while FLine[Run] in ['0'..'9', 'A'..'F', 'a'..'f'] do inc(Run);
end;

procedure TpsvPasRTF.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TpsvPasRTF.LowerProc;
begin
  fTokenID := tkSymbol;
  inc(Run);
  if fLine[Run] in ['=', '>'] then inc(Run);
end;

procedure TpsvPasRTF.NullProc;
begin
  fTokenID := tkNull;
end;

procedure TpsvPasRTF.NumberProc;
begin
  inc(Run);
  fTokenID := tkNumber;
  while FLine[Run] in ['0'..'9', '.', 'e', 'E'] do
  begin
    case FLine[Run] of
      '.':
        if FLine[Run + 1] = '.' then break;
    end;
    inc(Run);
  end;
end;

procedure TpsvPasRTF.PointProc;
begin
  fTokenID := tkSymbol;
  inc(Run);
  if fLine[Run] in ['.', ')'] then inc(Run);
end;

procedure TpsvPasRTF.AnsiProc;
begin
  case fLine[Run] of
     #0: NullProc;
    #10: LFProc;
    #13: CRProc;
  else
    fTokenID := tkComment;
    repeat
      if (fLine[Run] = '*') and (fLine[Run + 1] = ')') then begin
        Inc(Run, 2);
        if fRange = rsAnsiAsm then
          fRange := rsAsm
        else
          fRange := rsUnKnown;
        break;
      end;
      Inc(Run);
    until fLine[Run] in [#0, #10, #13];
  end;
end;

procedure TpsvPasRTF.RoundOpenProc;
begin
  Inc(Run);
  case fLine[Run] of
    '*':
      begin
        Inc(Run);
        if fRange = rsAsm then
          fRange := rsAnsiAsm
        else
          fRange := rsAnsi;
        fTokenID := tkComment;
        if not (fLine[Run] in [#0, #10, #13]) then
          AnsiProc;
      end;
    '.':
      begin
        inc(Run);
        fTokenID := tkSymbol;
      end;
  else
    fTokenID := tkSymbol;
  end;
end;

{begin}
procedure TpsvPasRTF.SemicolonProc;
begin
  Inc(Run);
  fTokenID := tkSymbol;
  if fRange = rsProperty then
    fRange := rsUnknown;
end;
{end}                                                                           

procedure TpsvPasRTF.SlashProc;
begin
  Inc(Run);
  if fLine[Run] = '/' then begin
    fTokenID := tkComment;
    repeat
      Inc(Run);
    until fLine[Run] in [#0, #10, #13];
  end else
    fTokenID := tkSymbol;
end;

procedure TpsvPasRTF.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while FLine[Run] in [#1..#9, #11, #12, #14..#32] do inc(Run);
end;

procedure TpsvPasRTF.StringProc;
begin
  fTokenID := tkString;
  Inc(Run);
  while not (fLine[Run] in [#0, #10, #13]) do begin
    if fLine[Run] = #39 then begin
      Inc(Run);
      if fLine[Run] <> #39 then
        break;
    end;
    Inc(Run);
  end;
end;

procedure TpsvPasRTF.SymbolProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TpsvPasRTF.UnknownProc;
begin
  inc(Run);
  fTokenID := tkUnknown;
end;

procedure TpsvPasRTF.Next;
begin
  fAsmStart := False;
  fTokenPos := Run;
  case fRange of
    rsAnsi, rsAnsiAsm:
      AnsiProc;
    rsBor, rsBorAsm:
      BorProc;
  else
    fProcTable[fLine[Run]];
  end;
end;


function TpsvPasRTF.GetEol: Boolean;
begin
  Result := fTokenID = tkNull;
end;

function TpsvPasRTF.GetToken: string;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TpsvPasRTF.GetTokenID: TtkTokenKind;
begin
  if not fAsmStart and (fRange = rsAsm)
    and not (fTokenId in [tkNull, tkComment, tkSpace])
  then
    Result := tkAsm
  else
    Result := fTokenId;
end;

function TpsvPasRTF.GetTokenAttribute: integer;
begin
  case GetTokenID of
    tkAsm: Result := 9;
    tkComment: Result := 1;
    tkIdentifier: Result := 2;
    tkKey: Result := 3;
    tkNumber: Result := 4;
    tkSpace: Result := 5;
    tkString: Result := 6;
    tkSymbol: Result := 7;
    tkUnknown: Result := 8;
  else
    Result := 9;
  end;
end;

function TpsvPasRTF.GetTokenKind: integer;
begin
  Result := Ord(GetTokenID);
end;

function TpsvPasRTF.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

function TpsvPasRTF.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

procedure TpsvPasRTF.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

procedure TpsvPasRTF.ResetRange;
begin
  fRange:= rsUnknown;
end;

procedure TpsvPasRTF.PrepareToken(var AToken : string);
var St : string;
begin
  St := AToken;
  St := StringReplace(St,'\','\\',[rfReplaceAll]);
  St := StringReplace(St,'{','\{',[rfReplaceAll]);
  St := StringReplace(St,'}','\}',[rfReplaceAll]);  
  AToken := St;
end;

function TpsvPasRTF.PrepareOutput(Attr: integer; AToken : string): string;
begin
  case Attr of 
    1 : Result  := '\cf1 \i '+ AToken +'\i0 ';
    3 : Result  := '\cf3 \b '+ AToken +'\b0 ';
  else
   Result := Format('\cf%d %s',[Attr,AToken]);
  end;
end;

initialization
  MakeIdentTable;


end.

