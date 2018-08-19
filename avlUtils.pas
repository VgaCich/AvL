{(c)VgaSoft, 2004-2007}
unit avlUtils;

interface

uses Windows, AvL;

type
  TSysCharSet = set of Char;

function StrEnd(const Str: PChar): PChar;
function StrCopy(Dest: PChar; const Source: PChar): PChar;
function CompareStr(const S1, S2: string): Integer;
function StrCat(Dest, Source: PChar): PChar;
function ChangeFileExt(const FileName, Extension: string): string;
function FirstDelimiter(const Delimiters, S: String): Integer;
function PosEx(const SubStr, S: string; Offset: Cardinal = 1): Integer;
function TryStrToInt(const S: string; out Value: Integer): Boolean;
function TryStrToFloat(const S: string; out Value: Single): Boolean;
function StrToCar(const S: string): Cardinal;
function StrToInt64(const S: string): Int64;
function StrToInt64Def(const S: string; const Default: Int64): Int64;
function Int64ToStr(const I: Int64): string;
function HexToByte(const Hex: string): byte;
function FloatToStr2(M: Real; I, D: Integer): string;
function FloatToStrF(X: Extended): string;
function BoolToStr(B: Boolean): string;
function FileTimeToDateTime(T: TFileTime): TDateTime;
function NoFirst(const S: string): string;
function ForceDirectories(Dir: string): Boolean;
function ExcludeTrailingBackslash(const S: string): string;
procedure ExcludeTrailingBackslashV(var S: string);
function AddTrailingBackslash(const S: string): string;
procedure AddTrailingBackslashV(var S: string);
function CorrectFileName(const FileName: string): string;
function FlSize(const FileName: string): Cardinal;
function DirSize(Dir: string): Cardinal;
function FlModifyTime(const FileName: string): TDateTime;
function LoadFile(const FileName: string): string;
procedure SaveFile(const FileName, Data: string);
procedure RemoveVoidStrings(Strings: TStringList);
procedure FreeMemAndNil(var P: Pointer; Size: integer);
procedure FAN(var Obj);
procedure ClearList(List: TList);
procedure FreeList(var List: TList);
function SLValueName(const S: string): string;
function ExePath: string;
procedure VGetMem(var P: Pointer; Size: Cardinal);
procedure VFreeAndNil(var P: Pointer; Size: Cardinal);
function UniTempFile: string;
function FontToStr(Font: TFont): string;
procedure StrToFont(S: string; Font: TFont);
function Tok(const Sep: string; var S: string): string;
function GetTempDir: string;
function MessageDlg(const Text, Title: string; Style: Cardinal): Integer;
procedure MessageFmt(const Fmt: string; const Args: array of const);
function FullExeName: string;
function SizeToStr(Size: Int64): string;
function EtaToStr(Left, Speed: Int64): string;
function CheckPath(const Path: string; Abs: Boolean): Boolean;
{function GetShiftState: TShiftState; }
function FindCmdLineSwitch(const Switch: string; SwitchChars: TSysCharSet; IgnoreCase: Boolean): Boolean;
procedure CutFirstDirectory(var S: string);
function MinimizeName(const Filename: string; MaxLen: Integer): string;
function IncPtr(Ptr: Pointer; N: Integer = 1): Pointer;
function IntToStrLZ(I, Len: Integer): string;
function ANSI2OEM(const S: string): string;
procedure GetPrivilege(const Privilege: string);
function ExecAndWait(const CmdLine: string): Boolean;
function GUIDToString(const GUID: TGUID): string;
procedure SelfDelete;
function FileAttributesToStr(Attributes: Integer): string;
function DateTimeToUnix(const AValue: TDateTime): Int64;
function UnixToDateTime(const AValue: Int64): TDateTime;
function LerpColor(A, B: TColor; F: Single): TColor;
function MakeMethod(Func: Pointer; Data: Pointer = nil): TMethod;

implementation

function StrEnd(const Str: PChar): PChar; assembler;
asm
        MOV     EDX,EDI
        MOV     EDI,EAX
        MOV     ECX,0FFFFFFFFH
        XOR     AL,AL
        REPNE   SCASB
        LEA     EAX,[EDI-1]
        MOV     EDI,EDX
end;

function StrCopy(Dest: PChar; const Source: PChar): PChar; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     ECX,0FFFFFFFFH
        XOR     AL,AL
        REPNE   SCASB
        NOT     ECX
        MOV     EDI,ESI
        MOV     ESI,EDX
        MOV     EDX,ECX
        MOV     EAX,EDI
        SHR     ECX,2
        REP     MOVSD
        MOV     ECX,EDX
        AND     ECX,3
        REP     MOVSB
        POP     ESI
        POP     EDI
end;

function CompareStr(const S1, S2: string): Integer; assembler;
asm
        PUSH    ESI
        PUSH    EDI
        MOV     ESI,EAX
        MOV     EDI,EDX
        OR      EAX,EAX
        JE      @@1
        MOV     EAX,[EAX-4]
@@1:    OR      EDX,EDX
        JE      @@2
        MOV     EDX,[EDX-4]
@@2:    MOV     ECX,EAX
        CMP     ECX,EDX
        JBE     @@3
        MOV     ECX,EDX
@@3:    CMP     ECX,ECX
        REPE    CMPSB
        JE      @@4
        MOVZX   EAX,BYTE PTR [ESI-1]
        MOVZX   EDX,BYTE PTR [EDI-1]
@@4:    SUB     EAX,EDX
        POP     EDI
        POP     ESI
end;

function StrCat(Dest, Source: PChar): PChar;
begin
  StrCopy(StrEnd(Dest), Source);
  Result:=Dest;
end;

function ChangeFileExt(const FileName, Extension: string): string;
var
  I: Integer;
begin
  I := LastDelimiter('.',Filename);
  if (I = 0) or (FileName[I] <> '.') then I := MaxInt;
  Result := Copy(FileName, 1, I - 1) + Extension;
end;

function FirstDelimiter(const Delimiters, S: String): Integer;
var
  n: LongWord;
begin
  Result := 1;
  for n := Result to Length(S) do
   if S[n] = Delimiters then
    begin
     Result := n;
     Exit;
    end;
end;

function PosEx(const SubStr, S: string; Offset: Cardinal = 1): Integer;
var
  I,X: Integer;
  Len, LenSubStr: Integer;
begin
  if Offset = 1 then
    Result := Pos(SubStr, S)
  else
  begin
    I := Offset;
    LenSubStr := Length(SubStr);
    Len := Length(S) - LenSubStr + 1;
    while I <= Len do
    begin
      if S[I] = SubStr[1] then
      begin
        X := 1;
        while (X < LenSubStr) and (S[I + X] = SubStr[X + 1]) do
          Inc(X);
        if (X = LenSubStr) then
        begin
          Result := I;
          exit;
        end;
      end;
      Inc(I);
    end;
    Result := 0;
  end;
end;

function TryStrToInt(const S: string; out Value: Integer): Boolean;
var
  E: Integer;
begin
  Val(S, Value, E);
  Result := E = 0;
end;

function TryStrToFloat(const S: string; out Value: Single): Boolean;
var
  E: Integer;
begin
  Val(S, Value, E);
  Result := E = 0;
end;

function StrToCar(const S: string): Cardinal;
var
  E: integer;
begin
  Val(S, Result, E);
end;

function StrToInt64(const S: string): Int64;
var
  E: Integer;
begin
  Val(S, Result, E);
end;

function StrToInt64Def(const S: string; const Default: Int64): Int64;
var
  E: Integer;
begin
  Val(S, Result, E);
  if E <> 0 then Result := Default;
end;

function Int64ToStr(const I: Int64): string;
begin
  Str(I, Result);
end;

function HexToByte(const Hex: string): byte;
var
  i: byte;
begin
  Result:=0;
  if Length(Hex)<>2 then Exit;
  for i:=1 to 2 do
    if Hex[i] in ['0'..'9']
      then Result := (Result shl 4) or (Ord(Hex[i]) - Ord('0'))
      else if Hex[i] in ['A'..'F']
        then Result := (Result shl 4) or (Ord(Hex[i]) - Ord('A') + 10)
        else if Hex[i] in ['a'..'f']
          then Result := (Result shl 4) or (Ord(Hex[i]) - Ord('a') + 10)
          else Break;
end;

function FloatToStr2(M: Real; I, D: Integer): string;
begin
  Str(M:I:D, Result);
end;

function FloatToStrF(X: Extended): string;
begin
  Str(X, Result);
end;

function BoolToStr(B: Boolean): string;
const
  Str: array[Boolean] of string=('False', 'True');
begin
  Result:=Str[B];
end;

function FileTimeToDateTime(T: TFileTime): TDateTime;
var
  T1: TFileTime;
  S: TSystemTime;
begin
  FileTimeToLocalFileTime(T, T1);
  FileTimeToSystemTime(T1, S);
  SystemTimeToDateTime(S, Result);
end;

function NoFirst(const S: string): string;
begin
  Result:=Copy(S, 2, MaxInt);
end;

function ForceDirectories(Dir: string): Boolean;
begin
  Result := True;
  Dir := ExcludeTrailingBackslash(Dir);
  if (Length(Dir) < 3) or DirectoryExists(Dir)
    or (ExtractFilePath(Dir) = Dir) then Exit; // avoid 'xyz:\' problem.
  Result := ForceDirectories(ExtractFilePath(Dir)) and CreateDir(Dir);
end;

function ExcludeTrailingBackslash(const S: string): string;
begin
  if (S<>'') and (S[Length(S)]='\')
    then Result:=Copy(S, 1, Length(S)-1)
    else Result:=S;
end;

procedure ExcludeTrailingBackslashV(var S: string);
begin
  S:=ExcludeTrailingBackslash(S);
end;

function AddTrailingBackslash(const S: string): string;
begin
  if (S<>'') and (S[Length(S)]<>'\')
    then Result:=S+'\'
    else Result:=S;
end;

procedure AddTrailingBackslashV(var S: string);
begin
  S:=AddTrailingBackslash(S);
end;

function CorrectFileName(const FileName: string): string;
var
  i: Integer;
begin
  Result := FileName;
  for i := 1 to Length(FileName) do
    if Result[i] in ['/', '\', ':', '|', '<', '>', '*', '?', '"'] then
      Result[i] := '_';
end;

function FlSize(const FileName: string): Cardinal;
var
  Fl: TFileStream;
begin
  try
    Fl:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
    Result:=Fl.Size;
  finally
    FAN(Fl);
  end;
end;

function DirSize(Dir: string): Cardinal;
var
  SR: TSearchRec;
begin
  Result := 0;
  AddTrailingBackslashV(Dir);
  if FindFirst(Dir+'*', faAnyFile, SR)=0 then
    repeat
      if SR.Attr and faDirectory = faDirectory then
      begin
        if (SR.Name<>'.') and (SR.Name<>'..')
          then Inc(Result, DirSize(Dir+SR.Name));
      end
        else Inc(Result, SR.Size);
    until FindNext(SR)<>0;
  FindClose(SR);
end;

function FlModifyTime(const FileName: string): TDateTime;
var
  Fl: TFileStream;
  FT: TFileTime;
begin
  try
    Fl:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
    GetFileTime(Fl.Handle, nil, nil, @FT);
    Result:=FileTimeToDateTime(FT);
  finally
    FAN(Fl);
  end;
end;

function LoadFile(const FileName: string): string;
var
  F: TFileStream;
begin
  Result := '';
  F := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(Result, F.Size);
    F.Read(Result[1], F.Size);
  finally
    FAN(F);
  end;
end;

procedure SaveFile(const FileName, Data: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    F.Write(Data[1], Length(Data));
    F.Size := Length(Data);
  finally
    FAN(F);
  end;
end;

procedure RemoveVoidStrings(Strings: TStringList);
var
  i: integer;
begin
  for i:=Strings.Count-1 downto 0 do
    if Strings[i]='' then Strings.Delete(i);
end;

procedure FreeMemAndNil(var P: Pointer; Size: integer);
begin
  if P<>nil then FreeMem(P, Size);
  P:=nil;
end;

procedure FAN(var Obj);
begin
  if Pointer(Obj)=nil then Exit;
  TObject(Obj).Free;
  Pointer(Obj):=nil;
end;

procedure ClearList(List: TList);
var
  i: integer;
begin
  if List=nil then Exit;
  for i:=0 to List.Count-1 do
    if Assigned(List[i]) then TObject(List[i]).Free;
end;

procedure FreeList(var List: TList);
begin
  ClearList(List);
  FAN(List);
end;

function SLValueName(const S: string): string;
begin
  Result:=Copy(S, 1, FirstDelimiter('=', S)-1);
end;

function ExePath: string;
begin
  Result:=ExtractFilePath(FullExeName);
end;

procedure VGetMem(var P: Pointer; Size: Cardinal);
begin
  P:=VirtualAlloc(nil, Size, MEM_COMMIT, PAGE_READWRITE);
  if P=nil then raise Exception.CreateFmt('VirtualAlloc error (%d)', [GetLastError]);
end;

procedure VFreeAndNil(var P: Pointer; Size: Cardinal);
begin
  if P=nil then Exit;
  if not VirtualFree(P, Size, MEM_DECOMMIT)
    then raise Exception.CreateFmt('VirtualFree error (%d)', [GetLastError]);
  P:=nil;
end;

function UniTempFile: string;
var
  buf: array[0..MAX_PATH] of Char;
begin
  Result := '';
  if GetTempFileName(PChar(TempDir), PChar(string(ExtractFileName(ExeName))), 0, @buf[0]) <> 0 then
  begin
    Result := buf;
    DeleteFile(Result);
  end;
end;

const Sep='|';

function FontToStr(Font: TFont): string;

  function YesNo(Exp: Boolean): Char;
  begin
    if Exp
      then Result:='Y'
      else Result:='N';
  end;

begin
  Result:=IntToStr(Font.Charset)+Sep+IntToStr(Font.Color)+Sep+IntToStr(Font.Height)+
    Sep+IntToStr(Font.Width)+Sep+Font.Name+Sep+IntToStr(Ord(Font.Pitch))+Sep+
    IntToStr(Font.Size)+Sep+YesNo(fsBold in Font.Style)+YesNo(fsItalic in Font.Style)+
    YesNo(fsUnderline in Font.Style)+YesNo(fsStrikeOut in Font.Style);
end;

procedure StrToFont(S: string; Font: TFont);
begin
  if S='' then Exit;
  Font.Charset:=StrToInt(Tok(Sep, S));
  Font.Color:=StrToInt(Tok(Sep, S));
  Font.Height:=StrToInt(Tok(Sep, S));
  Font.Width:=StrToInt(Tok(Sep, S));
  Font.Name:=Tok(Sep, S);
  Font.Pitch:=TFontPitch(StrToInt(Tok(Sep, S)));
  Font.Size:=StrToInt(Tok(Sep, S));
  Font.Style:=[];
  if S[1]='Y' then
    Font.Style:=Font.Style+[fsBold];
  if S[2]='Y' then
    Font.Style:=Font.Style+[fsItalic];
  if S[3]='Y' then
    Font.Style:=Font.Style+[fsUnderline];
  if S[4]='Y' then
    Font.Style:=Font.Style+[fsStrikeOut];
end;

function Tok(const Sep: string; var S: string): string;

  function IsOneOf(C: Char; const S: string): Boolean;
  var
    i: integer;
  begin
    Result:=false;
    for i:=1 to Length(S) do
    begin
      if C=S[i] then
      begin
        Result:=true;
        Exit;
      end;
    end;
  end;

var
  C: Char;
begin
  Result:='';
  if S='' then Exit;
  C:=S[1];
  while IsOneOf(C, Sep) do
  begin
    Delete(S, 1, 1);
    if S='' then Exit;
    C:=S[1];
  end;
  while (not IsOneOf(C, Sep)) and (S<>'') do
  begin
    Result:=Result+C;
    Delete(S, 1, 1);
    if S='' then Exit;
    C:=S[1];
  end;
end;

function GetTempDir: string;
begin
  Result:=UniTempFile;
  AddTrailingBackslashV(Result);
end;

function MessageDlg(const Text, Title: string; Style: Cardinal): Integer;
begin
  Result:=MessageBox(MsgDefHandle, PChar(Text), PChar(Title), Style);
end;

procedure MessageFmt(const Fmt: string; const Args: array of const);
begin
  ShowMessage(Format(Fmt, Args));
end;

function FullExeName: string;
begin
  Result:=ExpandFileName(ExeName);
end;

function SizeToStr(Size: Int64): string;
const
  Names: array[0..4] of string = (' B', ' KB', ' MB', ' GB', ' TB');
var
  i, r: Integer;
begin
  i := 0;
  while (i < High(Names)) and (Size > 1023) do
  begin
    r := Size mod 1024;
    Size := Size div 1024;
    Inc(i);
  end;
  Result := IntToStr(Size);
  if (i > 0) and (Length(Result) < 3) then
    Result := Result + Copy(FloatToStr2(r / 1024, 1, 3 - Length(Result)), 2, MaxInt);
  Result := Result + Names[i];
end;

function EtaToStr(Left, Speed: Int64): string;
var
  Secs: Integer;
begin
  Result := '-';
  if (Speed = 0) or (Left = 0) then
    Exit;
  Secs := Left div Speed;
  if Secs < 60 then
    Result := Int64ToStr(Secs) + ' s'
  else if Secs < 3600 then
    Result := Format('%d:%02d m', [Secs div 60, Secs mod 60])
  else if Secs < 86400 then
    Result := Format('%d:%02d h', [Secs div 3600, (Secs mod 3600) div 60])
  else
    Result := Format('%d d %d h', [Secs div 86400, (Secs mod 86400) div 3600]);
end;

function CheckPath(const Path: string; Abs: Boolean): Boolean;
const
  CIncorPathChar=['/', ':', '*', '?', '"', '<', '>', '|'];
var
  i, Start: Integer;
begin
  if Abs then
  begin
    Result:=not ((Length(Path)<2) or (UpperCase(Path[1])<#65) or (UpperCase(Path[1])>#90) or (Path[2]<>':') or
      ((Length(Path)>2) and (Path[3]<>'\')));
    Start:=3;
  end
  else begin
    Result:=true;
    Start:=1;
  end;
  if not Result then Exit;
  for i:=Start to Length(Path) do
  begin
    if Path[i] in CIncorPathChar then Result:=false;
    if (Path[i]='\') and (Path[i-1]='\') then Result:=false;
  end;
end;

{function GetShiftState: TShiftState;
begin
  Result := [];
  if Keys and MK_SHIFT <> 0 then Include(Result, ssShift);
  if Keys and MK_CONTROL <> 0 then Include(Result, ssCtrl);
  if Keys and MK_LBUTTON <> 0 then Include(Result, ssLeft);
  if Keys and MK_RBUTTON <> 0 then Include(Result, ssRight);
  if Keys and MK_MBUTTON <> 0 then Include(Result, ssMiddle);
  if GetKeyState(VK_MENU) < 0 then Include(Result, ssAlt);
end; }

function FindCmdLineSwitch(const Switch: string; SwitchChars: TSysCharSet; IgnoreCase: Boolean): Boolean;
var
  I: Integer;
  S: string;
begin
  for I := 1 to ParamCount do
  begin
    S := ParamStr(I);
    if (SwitchChars = []) or (S[1] in SwitchChars) then
      if IgnoreCase then
      begin
        if (AnsiCompareText(Copy(S, 2, Maxint), Switch) = 0) then
        begin
          Result := True;
          Exit;
        end;
      end
      else begin
        if (AnsiCompareStr(Copy(S, 2, Maxint), Switch) = 0) then
        begin
          Result := True;
          Exit;
        end;
      end;
  end;
  Result := False;
end;

procedure CutFirstDirectory(var S: string);
var
  Root: Boolean;
  P: Integer;
begin
  if S = '\' then
    S := ''
  else
  begin
    if S[1] = '\' then
    begin
      Root := True;
      Delete(S, 1, 1);
    end
    else
      Root := False;
    if S[1] = '.' then
      Delete(S, 1, 4);
    P := AnsiPos('\',S);
    if P <> 0 then
    begin
      Delete(S, 1, P);
      S := '...\' + S;
    end
    else
      S := '';
    if Root then
      S := '\' + S;
  end;
end;

function MinimizeName(const Filename: string; MaxLen: Integer): string;
var
  Drive: string;
  Dir: string;
  Name: string;
begin
  Result:=FileName;
  Dir:=ExtractFilePath(Result);
  Name:=ExtractFileName(Result);
  if (Length(Dir)>=2) and (Dir[2]=':') then
  begin
    Drive:=Copy(Dir, 1, 2);
    Delete(Dir, 1, 2);
  end
  else
    Drive:='';
  while ((Dir<>'') or (Drive<>'')) and (Length(Result)>MaxLen) do
  begin
    if Dir='\...\' then
    begin
      Drive:='';
      Dir:='...\';
    end
    else if Dir='' then
      Drive:=''
    else
      CutFirstDirectory(Dir);
    Result:=Drive+Dir+Name;
  end;
end;

function IncPtr(Ptr: Pointer; N: Integer = 1): Pointer;
begin
  Result := Pointer(Cardinal(Ptr) + N);
end;

function IntToStrLZ(I, Len: Integer): string;
begin
  Result:=IntToStr(I);
  while Length(Result)<Len do Result:='0'+Result;
end;

function ANSI2OEM(const S: string): string;
begin
  SetLength(Result, Length(S));
  CharToOem(PChar(S), PChar(Result));
end;

procedure GetPrivilege(const Privilege: string);
var
  TokenPriv: TTokenPrivileges;
  TokenHandle: THandle;
begin
  if (Win32Platform = VER_PLATFORM_WIN32_NT) then
  begin
    if OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES, TokenHandle) then
      if LookupPrivilegeValue(nil, Pchar(Privilege), TokenPriv.Privileges[0].LUID) then
      begin
        TokenPriv.PrivilegeCount:=1;
        TokenPriv.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
        AdjustTokenPrivileges(TokenHandle, false, TokenPriv, 0, TTokenPrivileges(nil^), DWORD(nil^));
      end;
  end;
end;

function ExecAndWait(const CmdLine: string): Boolean;
var
  SI: TStartupInfo;
  PI: TProcessInformation;
begin
  FillChar(SI, SizeOf(SI) , 0);
  with SI do
  begin
    cb := SizeOf( SI);
  end;
  if not CreateProcess(nil, PChar(CmdLine), nil, nil, false, Create_default_error_mode,
                nil, nil, SI, PI)
    then begin
      //ShowMessage(SysErrorMessage(GetLastError));
      Result:=false;
      Exit;
    end;
  WaitForSingleObject(PI.hProcess, infinite);
  Result:=true;
end;

function GUIDToString(const GUID: TGUID): string;
begin
  with GUID do Result:=Format('{%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x}',
    [D1, D2, D3, D4[0], D4[1], D4[2], D4[3], D4[4], D4[5], D4[6], D4[7]]);
end;

procedure SelfDelete;
var
  BatFileName, Bat: string;
  BatFile: THandle;
begin
  BatFileName := ChangeFileExt(UniTempFile, '.bat');
  Bat := 'ping 127.0.0.1 -n 10 > nul'#13#10 +
         'del "' + FullExeName + '"'#13#10 +
         'del "' + BatFileName + '"'#13#10;
  BatFile := FileCreate(BatFileName);
  FileWrite(BatFile, Bat[1], Length(Bat));
  CloseHandle(BatFile);
  WinExec(PChar(BatFileName), SW_HIDE);
end;

function FileAttributesToStr(Attributes: Integer): string;
begin
  Result := '----';
  if Attributes and FILE_ATTRIBUTE_ARCHIVE <> 0 then
    Result[2] := 'a';
  if Attributes and FILE_ATTRIBUTE_HIDDEN <> 0 then
    Result[3] := 'h';
  if Attributes and FILE_ATTRIBUTE_READONLY <> 0 then
    Result[1] := 'r';
  if Attributes and FILE_ATTRIBUTE_SYSTEM <> 0 then
    Result[4] := 's';
end;

const
  UnixDateDelta = 25569.0 + 693594.0; //AvL seems to use Delphi 1 TDateTime
  SecsPerDay = 86400;

function DateTimeToUnix(const AValue: TDateTime): Int64;
begin
  Result := Round((AValue - UnixDateDelta) * SecsPerDay);
end;

function UnixToDateTime(const AValue: Int64): TDateTime;
begin
  Result := AValue / SecsPerDay + UnixDateDelta;
end;

function LerpColor(A, B: TColor; F: Single): TColor;
const
  M1: Integer = $00FF00FF;
  M2: Integer = $FF00FF00;
var
  F1, F2: Integer;
begin
  F2 := Round(256 * F);
  F1 := 256 - F2;
  Result := (((((A and M1) * F1) + ((B and M1) * F2)) shr 8) and M1) or
            (((((A and M2) * F1) + ((B and M2) * F2)) shr 8) and M2);
end;

function MakeMethod(Func: Pointer; Data: Pointer = nil): TMethod;
begin
  Result.Code := Func;
  Result.Data:= Data;
end;

end.
