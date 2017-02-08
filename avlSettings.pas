unit avlSettings;

interface

uses
  Windows, AvL, AvlUtils;

type
  TSettingsSource = (ssNone, ssIni, ssRegistry); 
  TSettings = class
  private
    FAppName: string;
    FSource: TSettingsSource;
    function GetPath(Source: TSettingsSource; const Key: string = ''): string;
    procedure SetSource(const Value: TSettingsSource);
  public
    constructor Create(const AppName: string);
    function ReadBool(const Section, Ident: string; Default: Boolean): Boolean;
    function ReadInteger(const Section, Ident: string; Default: Integer): Integer;
    function ReadString(const Section, Ident, Default: string): string;
    procedure WriteBool(const Section, Ident: string; Value: Boolean);
    procedure WriteInteger(const Section, Ident: string; Value: Integer);
    procedure WriteString(const Section, Ident, Value: string);
    procedure EraseSection(const Section: string);
    procedure RestoreFormState(const Name: string; Form: TForm);
    procedure SaveFormState(const Name: string; Form: TForm);
    function ValueExists(const Section, Ident: string): Boolean;
    property Source: TSettingsSource read FSource write SetSource;
  end;

implementation

constructor TSettings.Create(const AppName: string);
begin
  FAppName := AppName;
  if FileExists(GetPath(ssIni)) then FSource := ssIni
  else if RegKeyExists(HKEY_CURRENT_USER, GetPath(ssRegistry)) then FSource := ssRegistry
  else FSource := ssNone;
end;

procedure TSettings.EraseSection(const Section: string);
begin
  case FSource of
    ssIni: IniEraseSection(GetPath(ssIni), Section);
    ssRegistry: RegKeyDelete(HKEY_CURRENT_USER, GetPath(ssRegistry, Section));
  end;
end;

function TSettings.GetPath(Source: TSettingsSource; const Key: string = ''): string;
begin
  Result := '';
  case Source of
    ssIni: Result := ChangeFileExt(FullExeName, '.ini');
    ssRegistry: Result := 'Software\' + FAppName;
  end;
  if Key <> '' then
    Result := AddTrailingBackslash(Result) + Key;
end;

function TSettings.ReadBool(const Section, Ident: string; Default: Boolean): Boolean;
var
  Key: HKey;
begin
  case FSource of
    ssNone: Result := Default;
    ssIni: Result := IniGetInt(GetPath(ssIni), Section, Ident, Ord(Default)) <> 0;
    ssRegistry: begin
      Key := RegKeyOpenRead(HKEY_CURRENT_USER, GetPath(ssRegistry, Section));
      if RegKeyValExists(Key, Ident)
        then Result := RegKeyGetInt(Key, Ident) <> 0
        else Result := Default;
      RegKeyClose(Key);
    end;
  end;
end;

function TSettings.ReadInteger(const Section, Ident: string; Default: Integer): Integer;
var
  Key: HKey;
begin
  case FSource of
    ssNone: Result := Default;
    ssIni: Result := IniGetInt(GetPath(ssIni), Section, Ident, Default);
    ssRegistry: begin
      Key := RegKeyOpenRead(HKEY_CURRENT_USER, GetPath(ssRegistry, Section));
      if RegKeyValExists(Key, Ident)
        then Result := RegKeyGetInt(Key, Ident)
        else Result := Default;
      RegKeyClose(Key);
    end;
  end;
end;

function TSettings.ReadString(const Section, Ident, Default: string): string;
var
  Key: HKey;
begin
  case FSource of
    ssNone: Result := Default;
    ssIni: Result := IniGetStr(GetPath(ssIni), Section, Ident, Default);
    ssRegistry: begin
      Key := RegKeyOpenRead(HKEY_CURRENT_USER, GetPath(ssRegistry, Section));
      if RegKeyValExists(Key, Ident)
        then Result := RegKeyGetStr(Key, Ident)
        else Result := Default;
      RegKeyClose(Key);
    end;
  end;
end;

procedure TSettings.RestoreFormState(const Name: string; Form: TForm);
begin
  Form.SetBounds(ReadInteger(Name, 'Left', Form.Left),
                 ReadInteger(Name, 'Top', Form.Top),
                 ReadInteger(Name, 'Width', Form.Width),
                 ReadInteger(Name, 'Height', Form.Height));
  Form.WindowState := ReadInteger(Name, 'State', Form.WindowState);
end;

procedure TSettings.SaveFormState(const Name: string; Form: TForm);
begin
  WriteInteger(Name, 'State', Form.WindowState);
  if Form.WindowState <> wsMaximized then
  begin
    WriteInteger(Name, 'Left', Form.Left);
    WriteInteger(Name, 'Top', Form.Top);
    WriteInteger(Name, 'Width', Form.Width);
    WriteInteger(Name, 'Height', Form.Height);
  end;
end;

procedure TSettings.SetSource(const Value: TSettingsSource);
var
  Key: HKey;
  Keys: TSList;
  i: Integer;
begin
  if FSource = Value then Exit;
  if Value <> ssIni then
    DeleteFile(GetPath(ssIni));
  if Value <> ssRegistry then
  begin
    Key := RegKeyOpenRead(HKEY_CURRENT_USER, GetPath(ssRegistry));
    RegKeyGetKeyNamesSL(Key, Keys);
    RegKeyClose(Key);
    for i := 0 to Keys.Count - 1 do
      RegKeyDelete(HKEY_CURRENT_USER, GetPath(ssRegistry, Keys.Strings[i]));
    RegKeyDelete(HKEY_CURRENT_USER, GetPath(ssRegistry));
  end;
  FSource := Value;
  if Value = ssIni then
    CloseHandle(FileCreate(GetPath(ssIni)));
  if Value = ssRegistry then
    RegKeyClose(RegKeyOpenCreate(HKEY_CURRENT_USER, GetPath(ssRegistry)));
end;

function TSettings.ValueExists(const Section, Ident: string): Boolean;
var
  Key: HKey;
begin
  case FSource of
    ssNone: Result := false;
    ssIni: Result := IniValueExists(GetPath(ssIni), Section, Ident);
    ssRegistry: begin
      Key := RegKeyOpenRead(HKEY_CURRENT_USER, GetPath(ssRegistry, Section));
      Result := RegKeyValExists(Key, Ident);
      RegKeyClose(Key);
    end;
  end;
end;

procedure TSettings.WriteBool(const Section, Ident: string; Value: Boolean);
var
  Key: HKey;
begin
  case FSource of
    ssIni: IniSetInt(GetPath(ssIni), Section, Ident, Ord(Value));
    ssRegistry: begin
      Key := RegKeyOpenCreate(HKEY_CURRENT_USER, GetPath(ssRegistry, Section));
      RegKeySetInt(Key, Ident, Ord(Value));
      RegKeyClose(Key);
    end;
  end;
end;

procedure TSettings.WriteInteger(const Section, Ident: string; Value: Integer);
var
  Key: HKey;
begin
  case FSource of
    ssIni: IniSetInt(GetPath(ssIni), Section, Ident, Value);
    ssRegistry: begin
      Key := RegKeyOpenCreate(HKEY_CURRENT_USER, GetPath(ssRegistry, Section));
      RegKeySetInt(Key, Ident, Value);
      RegKeyClose(Key);
    end;
  end;
end;

procedure TSettings.WriteString(const Section, Ident, Value: string);
var
  Key: HKey;
begin
  case FSource of
    ssIni: IniSetStr(GetPath(ssIni), Section, Ident, Value);
    ssRegistry: begin
      Key := RegKeyOpenCreate(HKEY_CURRENT_USER, GetPath(ssRegistry, Section));
      RegKeySetStr(Key, Ident, Value);
      RegKeyClose(Key);
    end;
  end;
end;

end.