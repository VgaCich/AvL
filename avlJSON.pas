unit avlJSON; 

interface

uses
  Windows, AvL, avlMath;

type
  TJsonSettings = record
    MaxMemory: Cardinal;
    Settings: Integer;
    MemAlloc: function(Size: Cardinal; Zero: Integer; UserData: Pointer): Pointer; cdecl;
    MemFree: procedure(P, UserData: Pointer); cdecl;
    UserData: Pointer;
    ValueExtra: Cardinal;
  end;
  TJsonType = (jtNone, jtObject, jtArray, jtInteger, jtDouble, jtString, jtBoolean, jtNull);
  PJsonValue = ^TJsonValue;
  TJsonObjectEntry = record
    Name: PChar;
    NameLength: Cardinal;
    Value: PJsonValue;
  end;
  TJsonObjectEntries = array[0 .. MaxInt div SizeOf(TJsonObjectEntry) - 1] of TJsonObjectEntry;
  PJsonObjectEntries = ^TJsonObjectEntries;
  TJsonArrayEntries = array[0 .. MaxInt div SizeOf(PJsonValue) - 1] of PJsonValue;
  PJsonArrayEntries = ^ TJsonArrayEntries;
  TJsonValue = record
    Parent: PJsonValue;
    case VType: TJsonType of
      jtObject: (Obj: record
        Length: Cardinal;
        Values: PJsonObjectEntries;
      end);
      jtArray: (Arr: record
        Length: Cardinal;
        Values: PJsonArrayEntries;
      end);
      jtInteger: (Int: Int64);
      jtDouble: (Dbl: Double);
      jtString: (Str: record
        Length: Cardinal;
        Value: PChar;
      end);
      jtBoolean: (Bool: Integer);
  end;

const
  JsonEnableComments = $01;
  JsonErrorMax = 128;
//extern const struct _json_value json_value_none;

function JsonParse(Json: PChar; Length: Cardinal): PJsonValue; overload;
function JsonParse(const Json: string): PJsonValue; overload;
function JsonParseEx(const Settings: TJsonSettings; Json: PChar; Length: Cardinal; Error: PChar): PJsonValue; overload;
function JsonParseEx(const Settings: TJsonSettings; const Json: string; var Error: string): PJsonValue; overload;
procedure JsonFree(Value: PJsonValue);
procedure JsonFreeEx(const Settings: TJsonSettings; Value: PJsonValue);
function JsonBool(Value: PJsonValue): Boolean;
function JsonInt(Value: PJsonValue): Int64;
function JsonFloat(Value: PJsonValue): Double;
function JsonStr(Value: PJsonValue): string;
function JsonWStr(Value: PJsonValue): WideString;
function JsonItem(Value: PJsonValue; Index: Cardinal): PJsonValue; overload;
function JsonItem(Value: PJsonValue; const Name: string): PJsonValue; overload;
function JsonExtractItem(Value: PJsonValue; Index: Cardinal): PJsonValue; overload;
function JsonExtractItem(Value: PJsonValue; const Name: string): PJsonValue; overload;
function JsonToStr(Json: PJsonValue; Depth: Integer = 0): string;

implementation

var __turboFloat: word;

const
  BoolToStr: array[Boolean] of string = ('false', 'true');

function _isdigit(c: Integer): LongBool; cdecl;
begin
  Result := (c >= Ord('0')) and (c <= Ord('9'));
end;

function _calloc(Num, Size: Cardinal): Pointer; cdecl;
begin
  GetMem(Result, Num * Size);
  FillChar(Result^, Num * Size, 0);
end;

function _malloc(Size: Cardinal): Pointer; cdecl;
begin
  GetMem(Result, Size);
end;

procedure _free(P: Pointer); cdecl;
begin
  FreeMem(P);
end;

function _memcpy(Dest, Src: Pointer; Size: Cardinal): Pointer; cdecl;
begin
  Move(Src^, Dest^, Size);
  Result := Dest;
end;

function _memset(Dest: Pointer; C: Integer; Size: Cardinal): Pointer; cdecl;
begin
  FillChar(Dest^, Size, Char(C));
  Result := Dest;
end;

function _pow(Base, Exp: Double): Double; cdecl;
begin
  Result := Power(Base, Exp);
end;

procedure _sprintf;
asm
  JMP wsprintf
end;

procedure __llmul;
asm
  jmp System.@_llmul
end;

{$L json.obj}

function _json_parse(Json: PChar; Length: Cardinal): PJsonValue; cdecl; external;
function _json_parse_ex(const Settings: TJsonSettings; Json: PChar; Length: Cardinal; Error: PChar): PJsonValue; cdecl; external;
procedure _json_value_free(Value: PJsonValue); cdecl; external;
procedure _json_value_free_ex(const Settings: TJsonSettings; Value: PJsonValue); cdecl; external;

function DummyValue(Value: PJsonValue): PJsonValue;
begin
  Result := _calloc(1, SizeOf(TJsonValue));
  Result.Parent := Value.Parent;
  Result.VType := jtInteger;
end;

function JsonParse(Json: PChar; Length: Cardinal): PJsonValue;
begin
  Result := _json_parse(Json, Length);
end;

function JsonParse(const Json: string): PJsonValue; overload;
begin
  Result := _json_parse(PChar(Json), Length(Json));
end;

function JsonParseEx(const Settings: TJsonSettings; Json: PChar; Length:
  Cardinal; Error: PChar): PJsonValue;
begin
  Result := _json_parse_ex(Settings, Json, Length, Error);
end;

function JsonParseEx(const Settings: TJsonSettings; const Json: string; var
  Error: string): PJsonValue;
var
  Err: array[0..JsonErrorMax] of Char;
begin
  Result := _json_parse_ex(Settings, PChar(Json), Length(Json), Err);
  Error := string(Err);
end;

procedure JsonFree(Value: PJsonValue);
begin
  _json_value_free(Value);
end;

procedure JsonFreeEx(const Settings: TJsonSettings; Value: PJsonValue);
begin
  _json_value_free_ex(Settings, Value);
end;

function JsonBool(Value: PJsonValue): Boolean;
begin
  Result := Assigned(Value) and (Value.VType = jtBoolean) and (Value.Bool <> 0);
end;

function JsonInt(Value: PJsonValue): Int64;
begin
  if Assigned(Value) then
    case Value.VType of
      jtInteger: Result := Value.Int;
      jtDouble: Result := Trunc(Value.Dbl);
      else Result := 0;
    end
  else
    Result := 0;
end;

function JsonFloat(Value: PJsonValue): Double;
begin
  if Assigned(Value) then
    case Value.VType of
      jtInteger: Result := Value.Int;
      jtDouble: Result := Value.Dbl;
      else Result := 0.0;
    end
  else
    Result := 0.0;
end;

function JsonStr(Value: PJsonValue): string;
begin
  Result := JsonWStr(Value);
end;

function JsonWStr(Value: PJsonValue): WideString;
begin
  if Assigned(Value) and (Value.VType = jtString) then
    Result := UTF8Decode(Value.Str.Value)
  else
    Result := '';
end;

type
  PPJsonValue = ^PJsonValue;

function JsonFindItem(Value: PJsonValue; Index: Cardinal): PPJsonValue; overload;
begin
  Result := nil;
  if not Assigned(Value) or (Value.VType <> jtArray) or (Index >= Value.Arr.Length) then Exit;
  Result := @Value.Arr.Values[Index];
end;

function JsonFindItem(Value: PJsonValue; const Name: string): PPJsonValue; overload;
var
  i: Cardinal;
begin
  Result := nil;
  if not Assigned(Value) or (Value.VType <> jtObject) then Exit;
  for i := 0 to Value.Obj.Length - 1 do
    if Value.Obj.Values[i].Name = Name then
    begin
      Result := @Value.Obj.Values[i].Value;
      Break;
    end;
end;

function JsonItem(Value: PJsonValue; Index: Cardinal): PJsonValue;
var
  P: PPJsonValue;
begin
  P := JsonFindItem(Value, Index);
  if Assigned(P) then
    Result := P^
  else
    Result := nil;
end;

function JsonItem(Value: PJsonValue; const Name: string): PJsonValue;
var
  P: PPJsonValue;
begin
  P := JsonFindItem(Value, Name);
  if Assigned(P) then
    Result := P^
  else
    Result := nil;
end;

function JsonExtractItem(Value: PJsonValue; Index: Cardinal): PJsonValue;
var
  P: PPJsonValue;
begin
  P := JsonFindItem(Value, Index);
  if Assigned(P) then
  begin
    Result := P^;
    P^ := DummyValue(Result);
  end
  else
    Result := nil;
end;

function JsonExtractItem(Value: PJsonValue; const Name: string): PJsonValue;
var
  P: PPJsonValue;
begin
  P := JsonFindItem(Value, Name);
  if Assigned(P) then
  begin
    Result := P^;
    P^ := DummyValue(Result);
  end
  else
    Result := nil;
end;

function JsonToStr(Json: PJsonValue; Depth: Integer = 0): string;

  procedure AddLine(const S: string);
  var
    i: Integer;
  begin
    for i := 0 to Depth do
      Result := Result + '  ';
    Result := Result + S + #$0D#$0A;
  end;

var
  i: Integer;
begin
  Result := '';
  if not Assigned(Json) then Exit;
  case Json.VType of
    jtNone: AddLine('none');
    jtObject: begin
      AddLine('object:');
      for i := 0 to Json.Obj.Length - 1 do
        AddLine('  ' + string(Json.Obj.Values[i].Name) + ': ' + TrimLeft(JsonToStr(Json.Obj.Values[i].Value, Depth + 1)));
    end;
    jtArray: begin
      AddLine('array:');
      for i := 0 to Json.Arr.Length - 1 do
        Result := Result + JsonToStr(Json.Arr.Values[i], Depth + 1) + #$0D#$0A;
    end;
    jtInteger: AddLine('int: ' + Int64ToStr(Json.Int));
    jtDouble: AddLine('double: ' + FloatToStr(Json.Dbl));
    jtString: AddLine('string: ' + UTF8Decode(Json.Str.Value));
    jtBoolean: AddLine('bool: ' + BoolToStr[Json.Bool <> 0]);
    jtNull: AddLine('null');
  end;
  Delete(Result, Length(Result) - 1, 2);
end;

end.




