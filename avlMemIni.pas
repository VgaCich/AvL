{(c)VgaSoft, 2004}
unit avlMemIni;

interface

uses AvL, avlUtils;

type
  EMemIniError=class(Exception);
  TMemIni = class
  private
    FFileName: string;
    FIni: TList;
    FSectNames: TStringList;
    FFromFile: boolean;
    procedure ProcessIni(Ini: TStringList);
    procedure CreateSection(Section: string);
  public
    constructor Create(const FileName: String); overload;
    constructor Create(Stream: TStream); overload;
    destructor Destroy; override;
    procedure ReadSection(const Section: String; Strings: TStringList);
    procedure ReadSections(Strings: TStringList);
    procedure ReadSectionValues(const Section: String; Strings: TStringList);
    procedure WriteBool(const Section, Ident: string; Value: Boolean);
    procedure WriteInteger(const Section, Ident: String; Value: Longint);
    procedure WriteString(const Section, Ident, Value: String);
    procedure EraseSection(const Section: String);
    procedure DeleteKey(const Section, Ident: String);
    procedure Save; overload;
    procedure Save(Stream: TStream); overload;
    function SectionExists(const Section: String): Boolean;
    function ReadBool(const Section, Ident: string; Default: Boolean): Boolean;
    function ReadInteger(const Section, Ident: String; Default: Longint): Longint;
    function ReadString(const Section, Ident, Default: String): String;
  end;

implementation

constructor TMemIni.Create(const FileName: string);
var
  Temp: TStringList;
begin
  try
    if not FileExists(FileName)
      then raise EMemIniError.Create('File '+FileName+' not exist');
    FFromFile:=true;
    FFileName:=FileName;
    Temp:=TStringList.Create;
    Temp.LoadFromFile(FileName);
    ProcessIni(Temp);
  finally
    FAN(Temp);
  end;
end;

constructor TMemIni.Create(Stream: TStream);
var
  Temp: TStringList;
begin
  try
    FFromFile:=false;
    Temp:=TStringList.Create;
    Temp.LoadFromStream(Stream);
    ProcessIni(Temp);
  finally
    FAN(Temp);
  end;
end;

destructor TMemIni.Destroy;
var
  i: integer;
begin
//  Save;
  for i:=0 to FIni.Count-1 do
    if Assigned(FIni[i]) then TObject(FIni[i]).Free;
  FAN(FIni);
  FAN(FSectNames);
end;

procedure TMemIni.ProcessIni(Ini: TStringList);
var
  i: integer;
begin
  RemoveVoidStrings(Ini);
  for i:=Ini.Count-1 downto 0 do
    if TrimLeft(Ini[i])[1]=';' then Ini.Delete(i);
  FIni:=TList.Create;
  FSectNames:=TStringList.Create;
  FSectNames.Duplicates:=dupError;
  for i:=0 to Ini.Count-1 do
    if (Ini[i][1]='[') and (Ini[i][Length(Ini[i])]=']') then
    begin
      FIni.Add(TStringList.Create);
      FSectNames.Add(Copy(Ini[i], 2, Length(Ini[i])-2));
    end
    else if FIni.Count>0 then TStringList(FIni[FIni.Count-1]).Add(Ini[i]);
end;

procedure TMemIni.CreateSection(Section: string);
begin
  FSectNames.Add(Section);
  FIni.Add(TStringList.Create);
end;

procedure TMemIni.ReadSection(const Section: string; Strings: TStringList);
begin
  if not SectionExists(Section) then Exit;
  Strings.Assign(FIni[FSectNames.IndexOf(Section)]);
end;

procedure TMemIni.ReadSections(Strings: TStringList);
begin
  Strings.Assign(FSectNames);
end;

procedure TMemIni.ReadSectionValues(const Section: string; Strings: TStringList);
var
  i: integer;
begin
  Strings.Clear;
  ReadSection(Section, Strings);
  if Strings.Count=0 then Exit;
  for i:=0 to Strings.Count-1 do
    Strings[i]:=Copy(Strings[i], FirstDelimiter('=', Strings[i])+1, MaxInt);
end;

procedure TMemIni.WriteBool(const Section, Ident: string; Value: Boolean);
begin
  WriteInteger(Section, Ident, integer(Value));
end;

procedure TMemIni.WriteInteger(const Section, Ident: string; Value: LongInt);
begin
  WriteString(Section, Ident, IntToStr(Value));
end;

procedure TMemIni.WriteString(const Section, Ident, Value: string);
begin
  if not SectionExists(Section) then CreateSection(Section);
  TStringList(FIni[FSectNames.IndexOf(Section)]).Values[Ident]:=Value;
end;

procedure TMemIni.EraseSection(const Section: string);
var
  Index: integer;
begin
  Index:=FSectNames.IndexOf(Section);
  if Index=-1 then Exit;
  if Assigned(FIni[Index]) then TObject(FIni[Index]).Free;
  FIni.Delete(Index);
  FSectNames.Delete(Index);
end;

procedure TMemIni.DeleteKey(const Section, Ident: string);
var
  Index: integer;
begin
  Index:=FSectNames.IndexOf(Section);
  if Index=-1 then Exit;
  TStringList(FIni[Index]).Delete(TStringList(FIni[Index]).IndexOfName(Ident));
end;

procedure TMemIni.Save;
var
  OFile: TFileStream;
begin
  if not FFromFile then Exit;
  try
    OFile:=TFileStream.Create(FFileName, fmCreate);
    Save(OFile);
  finally
    FAN(OFile);
  end;
end;

procedure TMemIni.Save(Stream: TStream);
var
  i, j: integer;
  Temp: TStringList;
begin
  try
    Temp:=TStringList.Create;
    for i:=0 to FIni.Count-1 do
    begin
      Temp.Add('['+FSectNames[i]+']');
      RemoveVoidStrings(TStringList(FIni[i]));
      for j:=0 to TStringList(FIni[i]).Count-1 do
        Temp.Add(TStringList(FIni[i])[j]);
      Temp.Add('');
    end;
    Temp.SaveToStream(Stream);
  finally
    FAN(Temp);
  end;
end;

function TMemIni.SectionExists(const Section: string): boolean;
begin
  Result:=FSectNames.IndexOf(Section)<>-1;
end;

function TMemIni.ReadBool(const Section, Ident: string; Default: Boolean): Boolean;
begin
  Result:=ReadInteger(Section, Ident, integer(Default))<>0;
end;

function TMemIni.ReadInteger(const Section, Ident: String; Default: Longint): Longint;
begin
  Result:=StrToInt(ReadString(Section, Ident, IntToStr(Default)));
end;

function TMemIni.ReadString(const Section, Ident, Default: String): String;
begin
  Result:=Default;
  if FSectNames.IndexOf(Section)=-1 then Exit;
  Result:=TStringList(FIni[FSectNames.IndexOf(Section)]).Values[Ident];
end;

end.
