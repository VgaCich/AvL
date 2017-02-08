unit avlNatCompare;

interface

uses
  Windows, AvL;

function CompareTextNatural(const S1, S2: string): Integer;

implementation

function _isdigit(c: AnsiChar): Boolean; cdecl;
var
  CharType: Word;
begin
  GetStringTypeExA(LOCALE_USER_DEFAULT, CT_CTYPE1, @c, SizeOf(c), CharType);
  Result := Boolean(CharType and C1_DIGIT);
end;

function _isspace(c: AnsiChar): Boolean; cdecl;
var
  CharType: Word;
begin
  GetStringTypeExA(LOCALE_USER_DEFAULT, CT_CTYPE1, @c, SizeOf(c), CharType);
  Result := (CharType and C1_SPACE) <> 0;
end;

function __ltoupper(c: AnsiChar): AnsiChar; cdecl;
begin
  CharUpper(@c);
  Result := c;
end;

{$L strnatcmp.obj}

function _strnatcmp(const a, b: PChar): Integer; cdecl; external;
function _strnatcasecmp(const a, b: PChar): Integer; cdecl; external;

type
  TStrCmpLogicalW = function(psz1, psz2: PWideChar): Integer; stdcall;

var
  shlwapidll: HModule = 0;
  StrCmpLogicalW: TStrCmpLogicalW = nil;

function CompareTextNatural(const S1, S2: string): Integer;
begin
  if Assigned(StrCmpLogicalW) then
    Result := StrCmpLogicalW(PWideChar(WideString(S1)), PWideChar(WideString(S2)))
  else
    Result := _strnatcasecmp(PChar(S1), PChar(S2));
end;

initialization

  shlwapidll := LoadLibrary('shlwapi.dll');
  if shlwapidll <> 0 then
    StrCmpLogicalW := GetProcAddress(shlwapidll, 'StrCmpLogicalW');

finalization

  FreeLibrary(shlwapidll);

end.
