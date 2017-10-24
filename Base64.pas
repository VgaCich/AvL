// (c) Sha 2003-2005

// Быстрые функции для преобразования бинарых данных в Base64-представление
// и обратно. Работают быстрее аналогов из Indy и ICS.
unit Base64;

interface

// Функции со строковым параметром возвращают преобразованную строку.
// Функции, работающие с буферами, возвращают количество полученных байтов.
// Base64Encode преобразует бинарную строку в Base64-строку или
// копирует (с преобразованием) данные из бинарного буфера в Base64-буфер.
function Base64Encode(const StringToEncode: string): string; overload;
function Base64Encode(BufToEncode, BufEncoded: pointer; LenToEncode: integer): integer; overload;
// Base64Decode преобразует Base64-строку в бинарную строку или
// копирует (с преобразованием) данные из Base64-буфера в бинарный буфер.
function Base64Decode(const StringToDecode: string): string; overload;
function Base64Decode(BufToDecode, BufDecoded: pointer; LenToDecode: integer): integer; overload;

implementation

const
  Base64Nil = '=';
  Base64EncodeTable: array[0..63] of char = (
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/');
  Base64DecodeTable: array[0..255] of byte = (
    99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 64, 99, 99, 64, 99, 99, //'64' for #10,#13
    99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, //'99' for not Base64 codes
    99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 62, 99, 99, 99, 63, //'62' for '+', '63' for '/'
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 99, 99, 99, 99, 99, 99,
    99, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 99, 99, 99, 99, 99,
    99, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 99, 99, 99, 99, 99,
    99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
    99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
    99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
    99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
    99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
    99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
    99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
    99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99);

// Base64Encode преобразует бинарную строку в Base64-строку.

function Base64Encode(const StringToEncode: string): string; overload;
var
  len, ch0, ch1: integer;
  p, q: pChar;
begin;
  p := pointer(StringToEncode);
  len := length(StringToEncode);
  ch0 := ((len + 2) div 3) * 4;
  Setlength(Result, ch0);
  if ch0 > 0 then
  begin;
    q := pointer(Result);
    pInteger(@q[ch0 - 4])^ := ord(Base64Nil) * $01010101;
    repeat;
      ch0 := Ord(p[0]);
      q[0] := Base64EncodeTable[ch0 shr 2];
      ch0 := (ch0 and $03) shl 4;
      if len <= 1 then
        q[1] := Base64EncodeTable[ch0]
      else begin;
        ch1 := Ord(p[1]);
        q[1] := Base64EncodeTable[ch0 + (ch1 shr 4)];
        ch1 := (ch1 and $0F); ch1 := ch1 + ch1; ch1 := ch1 + ch1;
        if len <= 2 then
          q[2] := Base64EncodeTable[ch1]
        else begin;
          ch0 := Ord(p[2]);
          q[2] := Base64EncodeTable[ch1 + (ch0 shr 6)];
          q[3] := Base64EncodeTable[ch0 and $3F];
        end;
      end;
      len := len - 3;
      p := p + 3;
      q := q + 4;
    until len <= 0;
  end;
end;

// Base64Encode копирует (с преобразованием) данные из бинарного буфера
// в Base64-буфер.

function Base64Encode(BufToEncode, BufEncoded: pointer; LenToEncode: integer): integer; overload;
var
  ch0, ch1: integer;
  p, q: pChar;
begin;
  p := BufToEncode;
  Result := ((LenToEncode + 2) div 3) * 4;
  if Result > 0 then
  begin;
    q := BufEncoded;
    pInteger(@q[Result - 4])^ := ord(Base64Nil) * $01010101;
    repeat;
      ch0 := Ord(p[0]);
      q[0] := Base64EncodeTable[ch0 shr 2];
      ch0 := (ch0 and $03) shl 4;
      if LenToEncode <= 1 then
        q[1] := Base64EncodeTable[ch0]
      else begin;
        ch1 := Ord(p[1]);
        q[1] := Base64EncodeTable[ch0 + (ch1 shr 4)];
        ch1 := (ch1 and $0F); ch1 := ch1 + ch1; ch1 := ch1 + ch1;
        if LenToEncode <= 2 then
          q[2] := Base64EncodeTable[ch1]
        else begin;
          ch0 := Ord(p[2]);
          q[2] := Base64EncodeTable[ch1 + (ch0 shr 6)];
          q[3] := Base64EncodeTable[ch0 and $3F];
        end;
      end;
      LenToEncode := LenToEncode - 3;
      p := p + 3;
      q := q + 4;
    until LenToEncode <= 0;
  end;
end;

// Base64Decode преобразует Base64-строку в бинарную строку.

function Base64Decode(const StringToDecode: string): string; overload;
type
  WordArray = array[0..$1FFFFFFF] of word;
  pWordArray = ^WordArray;
var
  ch0, ch1: integer;
  p, q, terminator, lastdword: pChar;
label
  TestCrLf, Done, Error;
begin;
  ch0 := length(StringToDecode);
  if ch0 >= 4 then
  begin;
    SetLength(Result, ch0 - (ch0 shr 2));
    p := pointer(Result);
    q := pointer(StringToDecode);
    terminator := @q[ch0];
    lastdword := @q[ch0 - 4];
    while true do
    begin;
      if q > lastdword then goto TestCrLf;
      ch0 := Base64DecodeTable[ord(q[0])];
      if ch0 >= 64 then while true do
        begin;
          inc(q);
          if ch0 > 64 then goto Error;
          TestCrLf:
          if q >= terminator then goto Done;
          ch0 := Base64DecodeTable[ord(q[0])];
          if ch0 < 64 then
          begin;
            if q <= lastdword then break;
            if q >= terminator then goto Done;
            goto Error;
          end;
        end;

      ch1 := Base64DecodeTable[ord(q[1])];
      if ch1 >= 64 then goto Error;
      p^ := chr((ch0 shl 2) + (ch1 shr 4)); inc(p);

      ch0 := pWordArray(q)[1];
      if ch0 <> ord(Base64Nil) * (256 + 1) then
      begin;
        ch0 := Base64DecodeTable[ch0 and 255];
        if ch0 >= 64 then goto Error;
        p^ := chr((ch1 shl 4) + (ch0 shr 2)); inc(p);

        ch1 := ord(q[3]);
        if ch1 <> ord(Base64Nil) then
        begin;
          ch1 := Base64DecodeTable[ch1];
          if ch1 >= 64 then goto Error;
          p^ := chr(ch0 shl 6 + ch1); inc(p);
        end;
      end;

      inc(q, 4);
    end;
    Done:
    SetLength(Result, p - pointer(Result));
  end
  else
    Error:
    Result := '';
end;

// Base64Decode копирует (с преобразованием) данные из Base64-буфера
// в бинарный буфер.

function Base64Decode(BufToDecode, BufDecoded: pointer; LenToDecode: integer): integer; overload;
type
  WordArray = array[0..$1FFFFFFF] of word;
  pWordArray = ^WordArray;
var
  ch0, ch1: integer;
  p, q, terminator, lastdword: pChar;
label
  TestCrLf, Done, Error;
begin;
  if LenToDecode >= 4 then
  begin;
    p := BufDecoded;
    q := pointer(BufToDecode);
    terminator := @q[LenToDecode];
    lastdword := @q[LenToDecode - 4];
    while true do
    begin;
      if q > lastdword then goto TestCrLf;
      ch0 := Base64DecodeTable[ord(q[0])];
      if ch0 >= 64 then while true do
        begin;
          inc(q);
          if ch0 > 64 then goto Error;
          TestCrLf:
          if q >= terminator then goto Done;
          ch0 := Base64DecodeTable[ord(q[0])];
          if ch0 < 64 then
          begin;
            if q <= lastdword then break;
            if q >= terminator then goto Done;
            goto Error;
          end;
        end;

      ch1 := Base64DecodeTable[ord(q[1])];
      if ch1 >= 64 then goto Error;
      p^ := chr((ch0 shl 2) + (ch1 shr 4)); inc(p);

      ch0 := pWordArray(q)[1];
      if ch0 <> ord(Base64Nil) * (256 + 1) then
      begin;
        ch0 := Base64DecodeTable[ch0 and 255];
        if ch0 >= 64 then goto Error;
        p^ := chr((ch1 shl 4) + (ch0 shr 2)); inc(p);

        ch1 := ord(q[3]);
        if ch1 <> ord(Base64Nil) then
        begin;
          ch1 := Base64DecodeTable[ch1];
          if ch1 >= 64 then goto Error;
          p^ := chr(ch0 shl 6 + ch1); inc(p);
        end;
      end;

      inc(q, 4);
    end;
    Done:
    Result := p - pChar(BufDecoded);
  end
  else
    Error:
    Result := 0;
end;

end.

