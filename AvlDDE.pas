unit AvlDDE;

{$R-,T-,H+,X+}

interface

uses
  Windows, DDEML, Avl;

type
  TDDEObj = class(TObject)
   public
     DDEType: string;
     Name: string;
   end;

  TDataMode = (ddeAutomatic, ddeManual);
  TMacroEvent = procedure(Sender: TDDEObj; Msg: TStringList) of object;

  TDdeClientItem = class;

  { TDdeClientConv }

  TDdeClientConv = class(TDDEObj)
  private
    FDdeService: string;
    FDdeTopic: string;
    FConv: HConv;
    FCnvInfo: TConvInfo;
    FItems: TList;
    FHszApp: HSZ;
    FHszTopic: HSZ;
    FDdeFmt: Integer;
    FOnClose: TOnEvent;
    FOnOpen: TOnEvent;
    FAppName: string;
    FDataMode: TDataMode;
    FConnectMode: TDataMode;
    FWaitStat: Boolean;
    FFormatChars: Boolean;
    procedure SetDdeService(const Value: string);
    procedure SetDdeTopic(const Value: string);
    procedure SetService(const Value: string);
    procedure SetTopic(const Value: string);
    procedure SetConnectMode(NewMode: TDataMode);
    procedure SetFormatChars(NewFmt: Boolean);
    procedure XactComplete;
    procedure SrvrDisconnect;
    procedure DataChange(DdeDat: HDDEData; hszIt: HSZ);
  protected
    function CreateDdeConv(FHszAp: HSZ; FHszTop: HSZ): Boolean;
    function GetCliItemByName(const ItemName: string): TDDEObj;
    function GetCliItemByCtrl(ACtrl: TDdeClientItem): TDDEObj;
    function OnSetItem(aCtrl: TDdeClientItem; const S: string): Boolean;
    procedure OnAttach(aCtrl: TDdeClientItem);
    procedure OnDetach(aCtrl: TDdeClientItem);
    procedure Close; virtual;
    procedure Open; virtual;
    function ChangeLink(const App, Topic, Item: string): Boolean;
    procedure ClearItems;
  public
    destructor Destroy; override;
    function OpenLink: Boolean;
    function SetLink(const Service, Topic: string): Boolean;
    procedure CloseLink;
    function StartAdvise: Boolean;
    function PokeDataLines(const Item: string; Data: TStringList): Boolean;
    function PokeData(const Item: string; Data: PChar): Boolean;
    function ExecuteMacroLines(Cmd: TStringList; waitFlg: Boolean): Boolean;
    function ExecuteMacro(Cmd: PChar; waitFlg: Boolean): Boolean;
    function RequestData(const Item: string): PChar;
    property DdeFmt: Integer read FDdeFmt;
    property WaitStat: Boolean read FWaitStat;
    property Conv: HConv read FConv;
    property DataMode: TDataMode read FDataMode write FDataMode;
    constructor Create;
  public
    property ServiceApplication: string read FAppName write FAppName;
    property DdeService: string read FDdeService write SetDdeService;
    property DdeTopic: string read FDdeTopic write SetDdeTopic;
    property ConnectMode: TDataMode read FConnectMode write SetConnectMode default ddeAutomatic;
    property FormatChars: Boolean read FFormatChars write SetFormatChars default False;
    property OnClose: TOnEvent read FOnClose write FOnClose;
    property OnOpen: TOnEvent read FOnOpen write FOnOpen;
  end;

{ TDdeClientItem }

  TDdeClientItem = class(TDDEObj)
  private
    FLines: TStringList;
    FDdeClientConv: TDdeClientConv;
    FDdeClientItem: string;
    FOnChange: TOnEvent;
    function GetText: string;
    procedure SetDdeClientItem(const Val: string);
    procedure SetDdeClientConv(Val: TDdeClientConv);
    procedure SetText(const S: string);
    procedure SetLines(L: TStringList);
    procedure OnAdvise;
  protected
  public
    destructor Destroy; override;
    constructor Create;
  public
    property Text: string read GetText write SetText;
    property Lines: TStringList read FLines write SetLines;
    property DdeConv: TDdeClientConv read FDdeClientConv write SetDdeClientConv;
    property DdeItem: string read FDdeClientItem write SetDdeClientItem;
    property OnChange: TOnEvent read FOnChange write FOnChange;
  end;

{ TDdeServerConv }

  TDdeServerConv = class(TDDEObj)
  private
    FOnOpen: TOnEvent;
    FOnClose: TOnEvent;
    FOnExecuteMacro: TMacroEvent;
    FItems: TList;
  protected
    procedure Connect; virtual;
    procedure Disconnect; virtual;
  public
    destructor Destroy; override;
    function ExecuteMacro(Data: HDdeData): LongInt;
    constructor Create;
  public
    property OnOpen: TOnEvent read FOnOpen write FOnOpen;
    property OnClose: TOnEvent read FOnClose write FOnClose;
    property OnExecuteMacro: TMacroEvent read FOnExecuteMacro write FOnExecuteMacro;
  end;

{ TDdeServerItem }

//  PDdeServerItem =^TDdeServerItem;
  TDdeServerItem = class(TDDEObj)
  private
    FLines: TStringList;
    FServerConv: TDdeServerConv;
    FOnChange: TOnEvent;
    FOnPokeData: TOnEvent;
    FFmt: Integer;
    procedure ValueChanged;
  protected
    function GetText: string;
    procedure SetText(const Item: string);
    procedure SetLines(Value: TStringList);
    procedure SetServerConv(SConv: TDdeServerConv);
  public
    destructor Destroy; override;
    function PokeData(Data: HDdeData): LongInt;
    procedure Change; virtual;
    property Fmt: Integer read FFmt;
    constructor Create;
  public
    property Conv: TDdeServerConv read FServerConv write SetServerConv;
    property Text: string read GetText write SetText;
    property Lines: TStringList read FLines write SetLines;
    property OnChange: TOnEvent read FOnChange write FOnChange;
    property OnPokeData: TOnEvent read FOnPokeData write FOnPokeData;
  end;

  { TDdeMgr }

//  PDdeMgr =^TDdeMgr;
  TDdeMgr = class(TDDEObj)
  private
    FAppName: string;
    FHszApp: HSZ;
    FConvs: TList;
    FCliConvs: TList;
    FConvCtrls: TList;
    FDdeInstId: Longint;
    FLinkClipFmt: Word;
    procedure Disconnect(DdeSrvrConv: TDDEObj);
    function GetSrvrConv(const Topic: string ): TDDEObj;
    function AllowConnect(hszApp: HSZ; hszTopic: HSZ): Boolean;
    function AllowWildConnect(hszApp: HSZ; hszTopic: HSZ): HDdeData;
    function Connect(Conv: HConv; hszTopic: HSZ; SameInst: Boolean): Boolean;
    procedure PostDataChange(const Topic: string; Item: string);
    procedure SetAppName(const ApName: string);
    procedure ResetAppName;
    function  GetServerConv(const Topic: string): TDdeServerConv;
    procedure InsertServerConv(SConv: TDdeServerConv);
    procedure RemoveServerConv(SConv: TDdeServerConv);
  public
    destructor Destroy; override;
    function GetExeName: string;     // obsolete
    property DdeInstId: LongInt read FDdeInstId write FDdeInstId;
    property AppName: string read FAppName write SetAppName;
    property LinkClipFmt: Word read FLinkClipFmt;
    constructor Create;
  end;

var
  ddeMgr: TDdeMgr;

implementation

uses Consts;

type
  EDdeError = class(Exception);
  TDdeSrvrConv = class;

  { TDdeSrvrItem }

  TDdeSrvrItem = class(TDDEObj)
  private
    FConv: TDdeSrvrConv;
    FItem: string;
    FHszItem: HSZ;
    FSrvr: TDdeServerItem;
  protected
    procedure SetItem(const Value: string);
  public
    destructor Destroy; override;
    function RequestData(Fmt: Word): HDdeData;
    procedure PostDataChange;
    property Conv: TDdeSrvrConv read FConv write FConv;
    property Item: string read FItem write SetItem;
    property Srvr: TDdeServerItem read FSrvr write FSrvr;
    property HszItem: HSZ read FHszItem;
    constructor Create;
  end;

{ TDdeSrvrConv }

  TDdeSrvrConv = class(TDDEObj)
  private
    FTopic: string;
    FHszTopic: HSZ;
    FForm: TForm;
    FSConv: TDdeServerConv;
    FConv: HConv;
    FItems: TList;
  protected
    function GetControl(DdeConv: TDdeServerConv; const ItemName: string): TDdeServerItem;
    function GetSrvrItem(hszItem: HSZ): TDdeSrvrItem;
  public
    destructor Destroy; override;
    function RequestData(_Conv: HConv; hszTop: HSZ; hszItem: HSZ;
      Fmt: Word): HDdeData;
    function AdvStart(_Conv: HConv; hszTop: HSZ; hszItem: HSZ;
      Fmt: Word): Boolean;
    procedure AdvStop(_Conv: HConv; hszTop: HSZ; hszItem: HSZ);
    function PokeData(_Conv: HConv; hszTop: HSZ; hszItem: HSZ; Data: HDdeData;
      Fmt: Integer): LongInt;
    function ExecuteMacro(_Conv: HConv; hszTop: HSZ; Data: HDdeData): Integer;
    function GetItem(const ItemName: string): TDdeSrvrItem;
    property Conv: HConv read FConv;
    property Form: TForm read FForm;
    property SConv: TDdeServerConv read FSConv;
    property Topic: string read FTopic write FTopic;
    property HszTopic: HSZ read FHszTopic;
    constructor Create;
  end;

  { TDdeCliItem }

  TDdeCliItem = class(TDDEObj)
  protected
    FItem: string;
    FHszItem: HSZ;
    FCliConv: TDdeClientConv;
    FCtrl: TDdeClientItem;
    function StartAdvise: Boolean;
    function StopAdvise: Boolean;
    procedure StoreData(DdeDat: HDDEData);
    procedure DataChange;
    function AccessData(DdeDat: HDDEData; pDataLen: PDWORD): Pointer;
    procedure ReleaseData(DdeDat: HDDEData);
  public
    destructor Destroy; override;
    function RefreshData: Boolean;
    function SetItem(const S: string): Boolean;
    procedure SrvrDisconnect;
    property HszItem: HSZ read FHszItem;
    property Control: TDdeClientItem read FCtrl write FCtrl;
    constructor Create(ADS: TDdeClientConv);
  public
    property Item: string read FItem;
  end;

procedure DDECheck(Success: Boolean);
var
  err: Integer;
  ErrStr: string;
begin
  if Success then Exit;
  err := DdeGetLastError(DDEMgr.DdeInstId);
  case err of
    DMLERR_LOW_MEMORY, DMLERR_MEMORY_ERROR: ErrStr := Format(SDdeMemErr, [err]);
    DMLERR_NO_CONV_ESTABLISHED: ErrStr := Format(SDdeConvErr, [err]);
  else
    ErrStr := Format(SDdeErr, [err]);
  end;
  raise EDdeError.Create(ErrStr);
end;

function DdeMgrCallBack(CallType, Fmt : UINT; Conv: HConv; hsz1, hsz2: HSZ;
  Data: HDDEData; Data1, Data2: DWORD): HDDEData; stdcall;
var
  ci: TConvInfo;
  ddeCli: TDDEObj;
  ddeSrv: TDdeSrvrConv;
  ddeObj: TDDEObj;
  xID: DWORD;
begin
  Result := 0;
  case CallType of
    XTYP_CONNECT:
      Result := HDdeData(ddeMgr.AllowConnect(hsz2, hsz1));
    XTYP_WILDCONNECT:
      Result := ddeMgr.AllowWildConnect(hsz2, hsz1);
    XTYP_CONNECT_CONFIRM:
      ddeMgr.Connect(Conv, hsz1, Boolean(Data2));
    32930:
      ddeMgr.Connect(Conv, hsz1, Boolean(Data2));
  end;
  if Conv <> 0 then
  begin
    ci.cb := sizeof(TConvInfo);
    if CallType = XTYP_XACT_COMPLETE then
      xID := Data1
    else
      xID := QID_SYNC;
    if DdeQueryConvInfo(Conv, xID, @ci) = 0 then Exit;
    case CallType of
      XTYP_ADVREQ:
        begin
          ddeSrv := TDdeSrvrConv(ci.hUser);
          Result := ddeSrv.RequestData(Conv, hsz1, hsz2, Fmt);
        end;
      XTYP_REQUEST:
        begin
          ddeSrv := TDdeSrvrConv(ci.hUser);
          Result := ddeSrv.RequestData(Conv, hsz1, hsz2, Fmt);
        end;
      XTYP_ADVSTOP:
        begin
          ddeSrv := TDdeSrvrConv(ci.hUser);
          ddeSrv.AdvStop(Conv, hsz1, hsz2);
        end;
      XTYP_ADVSTART:
        begin
          ddeSrv := TDdeSrvrConv(ci.hUser);
          Result := HDdeData(ddeSrv.AdvStart(Conv, hsz1, hsz2, Fmt));
        end;
      XTYP_POKE:
        begin
          ddeSrv := TDdeSrvrConv(ci.hUser);
          Result := HDdeData(ddeSrv.PokeData(Conv, hsz1, hsz2, Data, Fmt));
        end;
      XTYP_EXECUTE:
        begin
          ddeSrv := TDdeSrvrConv(ci.hUser);
          Result := HDdeData(ddeSrv.ExecuteMacro(Conv, hsz1, Data));
        end;
      XTYP_XACT_COMPLETE:
        begin
          ddeCli := TDDEObj(ci.hUser);
          if ddeCli <> nil then TDdeClientConv(ddeCli).XactComplete
        end;
      XTYP_ADVDATA:
        begin
          ddeCli := TDDEObj(ci.hUser);
          TDdeClientConv(ddeCli).DataChange(Data, hsz2);
        end;
      XTYP_DISCONNECT:
        begin
          ddeObj := TDDEObj(ci.hUser);
          if ddeObj <> nil then
          begin
             if ddeObj.DDEType = 'TDdeClientConv' then
              TDdeClientConv(ddeObj).SrvrDisconnect
            else
              ddeMgr.Disconnect(ddeObj);
          end;
        end;
    end;
  end;
end;

{ TDdeMgr }

constructor TDdeMgr.Create;
begin
  FDdeInstId := 0;
  DDECheck(DdeInitialize(FDdeInstId, DdeMgrCallBack, APPCLASS_STANDARD, 0) = 0);
  FConvs := TList.Create;
  FCliConvs := TList.Create;
  FConvCtrls := TList.Create;
  AppName := ParamStr(0);
end;

destructor TDdeMgr.Destroy;
var
  I: Integer;
begin
  if FConvs <> nil then
  begin
    for I := 0 to FConvs.Count - 1 do
      TDdeSrvrConv(FConvs.Items[I]).Free;
    FConvs.Free;
    FConvs := nil;
  end;
  if FCliConvs <> nil then
  begin
    for I := 0 to FCliConvs.Count - 1 do
      TDdeSrvrConv(FCliConvs.Items[I]).Free;
    FCliConvs.Free;
    FCliConvs := nil;
  end;
  if FConvCtrls <> nil then
  begin
    FConvCtrls.Free;
    FConvCtrls := nil;
  end;
  ResetAppName;
  DdeUnInitialize(FDdeInstId);
  inherited Destroy;
end;

function TDdeMgr.AllowConnect(hszApp: HSZ; hszTopic: HSZ): Boolean;
var
  Topic: string;
  Buffer: array[0..4095] of Char;
//  Form: TForm;
  SConv: TDdeServerConv;
begin
  Result := False;
  if (hszApp = 0) or (DdeCmpStringHandles(hszApp, FHszApp) = 0)  then
  begin
    SetString(Topic, Buffer, DdeQueryString(FDdeInstId, hszTopic, Buffer,
      SizeOf(Buffer), CP_WINANSI));
    SConv := GetServerConv(Topic);
    if SConv <> nil then Result := True
  end;
end;

function TDdeMgr.AllowWildConnect(hszApp: HSZ; hszTopic: HSZ): HDdeData;
var
  conns: packed array[0..1] of THSZPair;
begin
  Result := 0;
  if hszTopic = 0 then Exit;
  if AllowConnect(hszApp, hszTopic) = True then
  begin
    conns[0].hszSvc := FHszApp;
    conns[0].hszTopic := hszTopic;
    conns[1].hszSvc := 0;
    conns[1].hszTopic := 0;
    Result := DdeCreateDataHandle(ddeMgr.DdeInstId, @conns,
      2 * sizeof(THSZPair), 0, 0, CF_TEXT, 0);
  end;
end;

function TDdeMgr.Connect(Conv: HConv; hszTopic: HSZ; SameInst: Boolean): Boolean;
var
  Topic: string;
  Buffer: array[0..4095] of Char;
  DdeConv: TDdeSrvrConv;
begin
  Result := False;
  DdeConv := TDdeSrvrConv.Create;   
  SetString(Topic, Buffer, DdeQueryString(FDdeInstId, hszTopic, Buffer,
    SizeOf(Buffer), CP_WINANSI));
  DdeConv.Topic := Topic;
  DdeConv.FSConv := GetServerConv(Topic);
  if DdeConv.FSConv = nil then exit;
  DdeConv.FConv := Conv;
  DdeSetUserHandle(Conv, QID_SYNC, DWORD(DdeConv));
  FConvs.Add(DdeConv);
  if DdeConv.FSConv <> nil then DdeConv.FSConv.Connect;
  Result := True;
end;

procedure TDdeMgr.Disconnect(DdeSrvrConv: TDDEObj);
var
  DdeConv: TDdeSrvrConv;
begin
  DdeConv := TDdeSrvrConv(DdeSrvrConv);
  if DdeConv.FSConv <> nil then DdeConv.FSConv.Disconnect;
  if DdeConv.FConv <> 0 then DdeSetUserHandle(DdeConv.FConv, QID_SYNC, 0);
  DdeConv.FConv := 0;
  if FConvs <> nil then
  begin
    FConvs.Delete(FConvs.IndexOf(DdeConv));
    DdeConv.Free;
  end;
end;

function TDdeMgr.GetExeName: string;
begin
  Result := ParamStr(0);
end;

procedure TDdeMgr.SetAppName(const ApName: string);
var
  Dot: Integer;
begin
  ResetAppName;
  FAppName := ExtractFileName(ApName);
  Dot := Pos('.', FAppName);
  if Dot <> 0 then
    Delete(FAppName, Dot, Length(FAppName));
  FHszApp := DdeCreateStringHandle(FDdeInstId, PChar(FAppName), CP_WINANSI);
  DdeNameService(FDdeInstId, FHszApp, 0, DNS_REGISTER);
end;

procedure TDdeMgr.ResetAppName;
begin
  if FHszApp <> 0 then
  begin
    DdeNameService(FDdeInstId, FHszApp, 0, DNS_UNREGISTER);
    DdeFreeStringHandle(FDdeInstId, FHszApp);
  end;
  FHszApp := 0;
end;

function TDdeMgr.GetServerConv(const Topic: string): TDdeServerConv;
var
  I: Integer;
  SConv: TDdeServerConv;
begin
  Result := nil;
  for I := 0 to FConvCtrls.Count - 1 do
  begin
    SConv := TDdeServerConv(FConvCtrls.Items[I]);
    if AnsiCompareText(SConv.Name, Topic) = 0 then
    begin
      Result := SConv;
      Exit;
    end;
  end;
end;

function TDdeMgr.GetSrvrConv(const Topic: string ): TDDEObj;
var
  I: Integer;
  Conv: TDdeSrvrConv;
begin
  Result := nil;
  for I := 0 to FConvs.Count - 1 do
  begin
    Conv := FConvs.Items[I];
    if AnsiCompareText(Conv.Topic, Topic) = 0 then
    begin
      Result := Conv;
      Exit;
    end;
  end;
end;

procedure TDdeMgr.PostDataChange(const Topic: string; Item: string);
var
  Conv: TDdeSrvrConv;
  Itm: TDdeSrvrItem;
begin
  Conv := TDdeSrvrConv(GetSrvrConv(Topic));
  If Conv <> nil then
  begin
    Itm := Conv.GetItem(Item);
    if Itm <> nil then Itm.PostDataChange;
  end;
end;

procedure TDdeMgr.InsertServerConv(SConv: TDdeServerConv);
begin
  FConvCtrls.Add(SConv);
end;

procedure TDdeMgr.RemoveServerConv(SConv: TDdeServerConv);
begin
  FConvCtrls.delete(FConvCtrls.IndexOf(SConv));
end;

constructor TDdeClientConv.Create;
begin
  FItems      := TList.Create ;
  DDEType     := 'TDdeClientConv';
  ConnectMode := ddeManual;
end;

destructor TDdeClientConv.Destroy;
begin
  CloseLink;
  FItems.Free;
  FItems := nil;
  inherited Destroy;
end;

procedure TDdeClientConv.OnAttach(aCtrl: TDdeClientItem);
var
  ItemLnk: TDdeCliItem;
begin
  ItemLnk := TDdeCliItem.Create(Self);   
  FItems.Add(ItemLnk);
  ItemLnk.Control := aCtrl;
  ItemLnk.SetItem('');
end;

procedure TDdeClientConv.OnDetach(aCtrl: TDdeClientItem);
var
  ItemLnk: TDdeCliItem;
begin
  ItemLnk := TDdeCliItem(GetCliItemByCtrl(aCtrl));
  if ItemLnk <> nil then
  begin
    ItemLnk.SetItem('');
    FItems.delete(FItems.IndexOf(ItemLnk));
    ItemLnk.Free;
  end;
end;

function TDdeClientConv.OnSetItem(aCtrl: TDdeClientItem; const S: string): Boolean;
var
  ItemLnk: TDdeCliItem;
begin
  Result := True;
  ItemLnk := TDdeCliItem(GetCliItemByCtrl(aCtrl));

  if (ItemLnk = nil) and (Length(S) > 0) then
  begin
    OnAttach (aCtrl);
    ItemLnk := TDdeCliItem(GetCliItemByCtrl(aCtrl));
  end;

  if (ItemLnk <> nil) and (Length(S) = 0) then
  begin
    OnDetach (aCtrl);
  end
  else if ItemLnk <> nil then
  begin
    Result := ItemLnk.SetItem(S);
    if Not (Result) then
      OnDetach (aCtrl);  {error occurred, do cleanup}
  end;
end;

function TDdeClientConv.GetCliItemByCtrl(ACtrl: TDdeClientItem): TDDEObj;
var
  ItemLnk: TDdeCliItem;
  I: word;
begin
  Result := nil;
  I := 0;
  while I < FItems.Count do
  begin
    ItemLnk := FItems.Items[I];
    if ItemLnk.Control = aCtrl then
    begin
      Result := ItemLnk;
      Exit;
    end;
    Inc(I);
  end;
end;

function TDdeClientConv.ChangeLink(const App, Topic, Item: string): Boolean;
begin
  CloseLink;
  SetService(App);
  SetTopic(Topic);
  Result := OpenLink;
  if Not Result then
  begin
    SetService('');
    SetTopic('');
  end;
end;

function TDdeClientConv.OpenLink: Boolean;
var
  CharVal: array[0..255] of Char;
  Res: Boolean;
begin
  Result := False;
  if FConv <> 0 then Exit;

  if (Length(DdeService) = 0) and (Length(DdeTopic) = 0) then
  begin
    ClearItems;
    Exit;
  end;

  if FHszApp = 0 then
  begin
    StrPCopy(CharVal, DdeService);
    FHszApp := DdeCreateStringHandle(ddeMgr.DdeInstId, CharVal, CP_WINANSI);
  end;
  if FHszTopic = 0 then
  begin
    StrPCopy(CharVal, DdeTopic);
    FHszTopic := DdeCreateStringHandle(ddeMgr.DdeInstId, CharVal, CP_WINANSI);
  end;
  Res := CreateDdeConv(FHszApp, FHszTopic);
  if Not Res then
  begin
    if Not((Length(DdeService) = 0) and
      (Length(ServiceApplication) = 0)) then
    begin
      if Length(ServiceApplication) <> 0 then
        StrPCopy(CharVal, ServiceApplication)
      else
        StrPCopy(CharVal, DdeService + ' ' + DdeTopic);
      if WinExec(CharVal, SW_SHOWMINNOACTIVE) >= 32 then
        Res := CreateDdeConv(FHszApp, FHszTopic);
    end;
  end;
  if Not Res then
  begin
    ClearItems;
    Exit;
  end;
  if FCnvInfo.wFmt <> 0 then FDdeFmt := FCnvInfo.wFmt
  else FDdeFmt := CF_TEXT;
  if StartAdvise = False then Exit;
  Open;
  DataChange(0, 0);
  Result := True;
end;

procedure TDdeClientConv.CloseLink;
var
  OldConv: HConv;
begin
  if FConv <> 0 then
  begin
    OldConv := FConv;
    SrvrDisconnect;
    FConv := 0;
    DdeSetUserHandle(OldConv, QID_SYNC, 0);
    DdeDisconnect(OldConv);
  end;

  if FHszApp <> 0 then
  begin
    DdeFreeStringHandle(ddeMgr.DdeInstId, FHszApp);
    FHszApp := 0;
  end;

  if FHszTopic <> 0 then
  begin
    DdeFreeStringHandle(ddeMgr.DdeInstId, FHszTopic);
    FHszTopic := 0;
  end;
  SetService('');
  SetTopic('');
end;

procedure TDdeClientConv.ClearItems;
var
  ItemLnk: TDdeCliItem;
  i: word;
begin
  if FItems.Count = 0 then Exit;

  for I := 0 to FItems.Count - 1 do
  begin
    ItemLnk := TDdeCliItem(FItems.Items[0]);
    ItemLnk.Control.DdeItem := '';
  end;
end;

function TDdeClientConv.CreateDdeConv(FHszAp: HSZ; FHszTop: HSZ): Boolean;
var
  Context: TConvContext;
begin
  FillChar(Context, SizeOf(Context), 0);
  with Context do
  begin
    cb := SizeOf(TConvConText);
    iCodePage := CP_WINANSI;
  end;
  FConv := DdeConnect(ddeMgr.DdeInstId, FHszAp, FHszTop, @Context);
  Result := FConv <> 0;
  if Result then
  begin
    FCnvInfo.cb := sizeof(TConvInfo);
    DdeQueryConvInfo(FConv, QID_SYNC, @FCnvInfo);
    DdeSetUserHandle(FConv, QID_SYNC, LongInt(Self));
  end;
end;

function TDdeClientConv.StartAdvise: Boolean;
var
  ItemLnk: TDdeCliItem;
  i: word;
begin
  Result := False;
  if FConv = 0 then Exit;

  i := 0;
  while i < FItems.Count do
  begin
    ItemLnk := TDdeCliItem(FItems.Items[i]);
    if Not ItemLnk.StartAdvise then
    begin
      ItemLnk.Control.DdeItem := '';
    end else
      Inc(i);
    if i >= FItems.Count then
      break;
  end;
  Result := True;
end;

function TDdeClientConv.ExecuteMacroLines(Cmd: TStringList; waitFlg: Boolean): Boolean;
begin
  Result := False;
  if (FConv = 0) or FWaitStat then Exit;
  Result := ExecuteMacro(PChar(Cmd.Text), waitFlg);
end;

function TDdeClientConv.ExecuteMacro(Cmd: PChar; waitFlg: Boolean): Boolean;
var
  hszCmd: HDDEData;
  hdata: HDDEData;
  ddeRslt: LongInt;
begin
  Result := False;
  if (FConv = 0) or FWaitStat then Exit;
  hszCmd := DdeCreateDataHandle(ddeMgr.DdeInstId, Cmd, StrLen(Cmd) + 1,
    0, 0, FDdeFmt, 0);
  if hszCmd = 0 then Exit;
  if waitFlg = True then FWaitStat := True;
  hdata := DdeClientTransaction(Pointer(hszCmd), DWORD(-1), FConv, 0, FDdeFmt,
     XTYP_EXECUTE, TIMEOUT_ASYNC, @ddeRslt);
  if hdata = 0 then FWaitStat := False
  else Result := True;
end;

function TDdeClientConv.PokeDataLines(const Item: string; Data: TStringList): Boolean;
begin
  Result := False;
  if (FConv = 0) or FWaitStat then Exit;
  Result := PokeData(Item, PChar(Data.Text));
end;

function TDdeClientConv.PokeData(const Item: string; Data: PChar): Boolean;
var
  hszDat: HDDEData;
  hdata: HDDEData;
  hszItem: HSZ;
begin
  Result := False;
  if (FConv = 0) or FWaitStat then Exit;
  hszItem := DdeCreateStringHandle(ddeMgr.DdeInstId, PChar(Item), CP_WINANSI);
  if hszItem = 0 then Exit;
  hszDat := DdeCreateDataHandle (ddeMgr.DdeInstId, Data, StrLen(Data) + 1,
    0, hszItem, FDdeFmt, 0);
  if hszDat <> 0 then
  begin
    hdata := DdeClientTransaction(Pointer(hszDat), DWORD(-1), FConv, hszItem,
      FDdeFmt, XTYP_POKE, TIMEOUT_ASYNC, nil);
    Result := hdata <> 0;
  end;
  DdeFreeStringHandle (ddeMgr.DdeInstId, hszItem);
end;

function TDdeClientConv.RequestData(const Item: string): PChar;
var
  hData: HDDEData;
  ddeRslt: LongInt;
  hItem: HSZ;
  pData: Pointer;
  Len: Integer;
begin
  Result := nil;
  if (FConv = 0) or FWaitStat then Exit;
  hItem := DdeCreateStringHandle(ddeMgr.DdeInstId, PChar(Item), CP_WINANSI);
  if hItem <> 0 then
  begin
    hData := DdeClientTransaction(nil, 0, FConv, hItem, FDdeFmt,
      XTYP_REQUEST, 10000, @ddeRslt);
    DdeFreeStringHandle(ddeMgr.DdeInstId, hItem);
    if hData <> 0 then
    try
      pData := DdeAccessData(hData, @Len);
      if pData <> nil then
      try
        GetMem(Result, Len + 1);
        Move(pData^, Result^, len);    // data is binary, may contain nulls
        Result[len] := #0;
      finally
        DdeUnaccessData(hData);
      end;
    finally
      DdeFreeDataHandle(hData);
    end;
  end;
end;

function TDdeClientConv.GetCliItemByName(const ItemName: string): TDDEObj;
var
  ItemLnk: TDdeCliItem;
  i: word;
begin
  Result := nil;
  i := 0;
  while i < FItems.Count do
  begin
    ItemLnk := TDdeCliItem(FItems.Items[i]);
    if ItemLnk.Item = ItemName then
    begin
      Result := ItemLnk;
      Exit;
    end;
    Inc(i);
  end;
end;

procedure TDdeClientConv.XactComplete;
begin
   FWaitStat := False;
end;

procedure TDdeClientConv.SrvrDisconnect;
var
  ItemLnk: TDdeCliItem;
  i: word;
begin
  if FConv <> 0 then Close;
  FConv := 0;
  i := 0;
  while i < FItems.Count do
  begin
    ItemLnk := TDdeCliItem(FItems.Items[i]);
    ItemLnk.SrvrDisconnect;
    inc(i);
  end;
end;

procedure TDdeClientConv.DataChange(DdeDat: HDDEData; hszIt: HSZ);
var
  ItemLnk: TDdeCliItem;
  i: word;
begin
  i := 0;
  while i < FItems.Count do
  begin
    ItemLnk := TDdeCliItem(FItems.Items[i]);
    if (hszIt = 0) or (ItemLnk.HszItem = hszIt) then
    begin
        { data has changed and we found a link that might be interested }
      ItemLnk.StoreData(DdeDat);
    end;
    Inc(i);
  end;
end;

function TDdeClientConv.SetLink(const Service, Topic: string): Boolean;
begin
  CloseLink;
{  if FConnectMode = ddeAutomatic then}
  if False then
    Result := ChangeLink(Service, Topic, '')
  else begin
    SetService(Service);
    SetTopic(Topic);
    DataChange(0,0);
    Result := True;
  end;
end;

procedure TDdeClientConv.SetConnectMode(NewMode: TDataMode);
begin
  if FConnectMode <> NewMode then
  begin
{    if (NewMode = ddeAutomatic) and (Length(DdeService) <> 0) and
      (Length(DdeTopic) <> 0) and not OpenLink then
      raise Exception.CreateRes(@SDdeNoConnect);}
    FConnectMode := NewMode;
  end;
end;

procedure TDdeClientConv.SetFormatChars(NewFmt: Boolean);
begin
  if FFormatChars <> NewFmt then
  begin
    FFormatChars := NewFmt;
    if FConv <> 0 then DataChange(0, 0);
  end;
end;

procedure TDdeClientConv.SetDdeService(const Value: string);
begin
   fDDEService := Value;
end;

procedure TDdeClientConv.SetDdeTopic(const Value: string);
begin
   fDDETopic := Value;
end;

procedure TDdeClientConv.SetService(const Value: string);
begin
  FDdeService := Value;
end;

procedure TDdeClientConv.SetTopic(const Value: string);
begin
  FDdeTopic := Value;
end;

procedure TDdeClientConv.Close;
begin
  if Assigned(FOnClose) then FOnClose(@Self);   
end;

procedure TDdeClientConv.Open;
begin
  if Assigned(FOnOpen) then FOnOpen(@Self);
end;

constructor TDdeClientItem.Create;
begin
  FLines  := TStringList.Create  ;
  DDEType := 'TDdeClientItem';
end;

destructor TDdeClientItem.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

procedure TDdeClientItem.SetDdeClientConv(Val: TDdeClientConv);
var
  OldItem: string;
begin
  if Val <> FDdeClientConv then
  begin
    OldItem := DdeItem;
    FDdeClientItem := '';
    if FDdeClientConv <> nil then
      FDdeClientConv.OnDetach (Self);

    FDdeClientConv := Val;
    if FDdeClientConv <> nil then
    begin
      if Length(OldItem) <> 0 then SetDdeClientItem (OldItem);
    end;
  end;
end;

procedure TDdeClientItem.SetDdeClientItem(const Val: string);
begin
  if FDdeClientConv <> nil then
  begin
    FDdeClientItem := Val;
    if Not FDdeClientConv.OnSetItem (Self, Val) then
    begin
      if not ((FDdeClientConv.FConv = 0) { and
        (FDdeClientConv.ConnectMode = ddeManual)}) then
        FDdeClientItem := '';
    end;
  end;
end;

procedure TDdeClientItem.OnAdvise;
begin
  if Assigned(FOnChange) then FOnChange(@Self);
end;

function TDdeClientItem.GetText: string;
begin
  if FLines.Count > 0 then
    Result := FLines.Strings[0]
  else Result := '';
end;

procedure TDdeClientItem.SetText(const S: string);
begin
end;

procedure TDdeClientItem.SetLines(L: TStringList);
begin
end;

constructor TDdeCliItem.Create(ADS: TDdeClientConv);
begin
  FHszItem := 0;
  FCliConv := ADS;
  DDEType  := 'TDdeCliItem';
end;

destructor TDdeCliItem.Destroy;
begin
  StopAdvise;
  inherited Destroy;
end;

function TDdeCliItem.SetItem(const S: string): Boolean;
var
  OldItem: string;
begin
  Result := False;
  OldItem := Item;
  if FHszItem <> 0 then StopAdvise;

  FItem := S;
  //FCtrl.Lines := TStringList.Create ;
  FCtrl.Lines.Clear;

  if (Length(Item) <> 0) then
  begin
    if (FCliConv.Conv <> 0) then
    begin
      Result := StartAdvise;
      if Not Result then
        FItem := '';
    end
    else {if FCliConv.ConnectMode = ddeManual then} Result := True;
  end;
  RefreshData;
end;

procedure TDdeCliItem.StoreData(DdeDat: HDDEData);
var
  Len: Longint;
  Data: string;
  I: Integer;
begin
  if DdeDat = 0 then
  begin
    RefreshData;
    Exit;
  end;

  Data := PChar(AccessData(DdeDat, @Len));
  if Data <> '' then
  begin
    FCtrl.Lines.Text := Data;
    ReleaseData(DdeDat);
    if FCliConv.FormatChars = False then
    begin
      for I := 1 to Length(Data) do
        if (Data[I] > #0) and (Data[I] < ' ') then Data[I] := ' ';
      FCtrl.Lines.Text := Data;
    end;
  end;
  DataChange;
end;

function TDdeCliItem.RefreshData: Boolean;
var
  ddeRslt: LongInt;
  DdeDat: HDDEData;
       i: integer;
begin
  Result := False;
  if (FCliConv.Conv <> 0) and (FHszItem <> 0) then
  begin
    if FCliConv.WaitStat = True then Exit;
    for i := 1 to 3 do begin
       DdeDat := DdeClientTransaction(nil, DWORD(-1), FCliConv.Conv, FHszItem,
      FCliConv.DdeFmt, XTYP_REQUEST, 1000, @ddeRslt);
      if DdeDat <> 0 then break;
    end;
    if DdeDat = 0 then Exit
    else begin
      StoreData(DdeDat);
      DdeFreeDataHandle(DdeDat);
      Result := True;
      Exit;
    end;
  end;
  DataChange;
end;

function TDdeCliItem.AccessData(DdeDat: HDDEData; pDataLen: PDWORD): Pointer;
begin
  Result := DdeAccessData(DdeDat, pDataLen);
end;

procedure TDdeCliItem.ReleaseData(DdeDat: HDDEData);
begin
  DdeUnaccessData(DdeDat);
end;

function TDdeCliItem.StartAdvise: Boolean;
var
  ddeRslt: LongInt;
  hdata: HDDEData;
begin
  Result := False;
  if FCliConv.Conv = 0 then Exit;
  if Length(Item) = 0 then Exit;
  if FHszItem = 0 then
    FHszItem := DdeCreateStringHandle(ddeMgr.DdeInstId, PChar(Item), CP_WINANSI);
  hdata := DdeClientTransaction(nil, DWORD(-1), FCliConv.Conv, FHszItem,
    FCliConv.DdeFmt, XTYP_ADVSTART or XTYPF_NODATA, 1000, @ddeRslt);
  if hdata = 0 then
  begin
    DdeGetLastError(ddeMgr.DdeInstId);
    DdeFreeStringHandle(ddeMgr.DdeInstId, FHszItem);
    FHszItem := 0;
    FCtrl.Lines.Clear;
  end else
    Result := True;
end;

function TDdeCliItem.StopAdvise: Boolean;
var
  ddeRslt: LongInt;
begin
  if FCliConv.Conv <> 0 then
    if FHszItem <> 0 then
      DdeClientTransaction(nil, DWORD(-1), FCliConv.Conv, FHszItem,
        FCliConv.DdeFmt, XTYP_ADVSTOP, 1000, @ddeRslt);
  SrvrDisconnect;
  Result := True;
end;

procedure TDdeCliItem.SrvrDisconnect;
begin
  if FHszItem <> 0 then
  begin
    DdeFreeStringHandle(ddeMgr.DdeInstId, FHszItem);
    FHszItem := 0;
  end;
end;

procedure TDdeCliItem.DataChange;
begin
  FCtrl.OnAdvise;
end;

constructor TDdeServerItem.Create;
begin
  FFmt    := CF_TEXT;
  FLines  := TStringList.Create ;
  DDEType := 'TDdeServerItem';
end;

destructor TDdeServerItem.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

procedure TDdeServerItem.SetServerConv(SConv: TDdeServerConv);
var i: integer;
begin
  FServerConv := SConv;
  i := SConv.FItems.IndexOf(self);
  if i = -1 then SConv.FItems.Add(self);
end;

function TDdeServerItem.GetText: string;
begin
  if FLines.Count > 0 then
    Result := FLines.Strings[0]
  else Result := '';
end;

procedure TDdeServerItem.SetText(const Item: string);
begin
  FFmt := CF_TEXT;
  FLines.Clear;
  FLines.Add(Item);
  ValueChanged;
end;

procedure TDdeServerItem.SetLines(Value: TStringList);
begin
  if AnsiCompareStr(Value.Text, FLines.Text) <> 0 then
  begin
    FFmt := CF_TEXT;
    FLines.Assign(Value);
    ValueChanged;
  end;
end;

procedure TDdeServerItem.ValueChanged;
begin
  if Assigned(FOnChange) then FOnChange(@Self);
  if FServerConv <> nil then
    ddeMgr.PostDataChange(FServerConv.Name, Name)
  else
    ddeMgr.PostDataChange(Name, Name);
end;

function TDdeServerItem.PokeData(Data: HDdeData): LongInt;
var
  Len: Integer;
  pData: Pointer;
begin
  Result := dde_FNotProcessed;
  pData := DdeAccessData(Data, @Len);
  if pData <> nil then
  begin
    Lines.Text := PChar(pData);
    DdeUnaccessData(Data);
    ValueChanged;
    if Assigned(FOnPokeData) then FOnPokeData(Self);
    Result := dde_FAck;
  end;
end;

procedure TDdeServerItem.Change;
begin
  if Assigned(FOnChange) then FOnChange(@Self);
end;

constructor TDdeServerConv.Create;
begin
   FItems  := TList.Create ;
   DDEType := 'TDdeServerConv';
   ddeMgr.InsertServerConv(Self);
end;

destructor TDdeServerConv.Destroy;
begin
  FItems.Free;
  ddeMgr.RemoveServerConv(Self);
  inherited Destroy;
end;

function TDdeServerConv.ExecuteMacro(Data: HDdeData): LongInt;
var
  Len: Integer;
  pData: Pointer;
  MacroLines: TStringList;
begin
  Result := dde_FNotProcessed;
  pData := DdeAccessData(Data, @Len);
  if pData <> nil then
  begin
    if Assigned(FOnExecuteMacro) then
    begin
      MacroLines := TStringList.Create;
      MacroLines.Text := PChar(pData);
      FOnExecuteMacro(Self, MacroLines);
      MacroLines.Free;
    end;
    Result := dde_FAck;
  end;
end;

procedure TDdeServerConv.Connect;
begin
  if Assigned(FOnOpen) then FOnOpen(@Self);
end;

procedure TDdeServerConv.Disconnect;
begin
  if Assigned(FOnClose) then FOnClose(@Self);
end;

constructor TDdeSrvrConv.Create;
begin
  FItems  := TList.Create;
  DDEType := 'TDdeSrvrConv';
end;

destructor TDdeSrvrConv.Destroy;
var
  I: Integer;
begin
  if FItems <> nil then
  begin
    for I := 0 to FItems.Count - 1 do
      TDdeSrvrItem(FItems.Items[I]).Free;
    FItems.Free;
    FItems := nil;
  end;
  if FConv <> 0 then DdeDisconnect(FConv);
  if FHszTopic <> 0 then
  begin
    DdeFreeStringHandle(ddeMgr.DdeInstId, FHszTopic);
    FHszTopic := 0;
  end;
  inherited Destroy;
end;

function TDdeSrvrConv.AdvStart(_Conv: HConv; hszTop: HSZ; hszItem: HSZ;
  Fmt: Word): Boolean;
var
  Srvr: TDdeServerItem;
  Buffer: array[0..4095] of Char;
  SrvrItem: TDdeSrvrItem;
begin
  Result := False;
  if Fmt <> CF_TEXT then Exit;
  DdeQueryString(ddeMgr.DdeInstId, hszItem, Buffer, SizeOf(Buffer), CP_WINANSI);
  Srvr := GetControl(FSConv, Buffer);
  if Srvr = nil then Exit;
  SrvrItem := TDdeSrvrItem.Create ;  
  SrvrItem.Srvr  := Srvr;
  SrvrItem.Item  := Buffer;
  SrvrItem.FConv := Self;
  FItems.Add(SrvrItem);
  if FHszTopic = 0 then
    FHszTopic := DdeCreateStringHandle(ddeMgr.DdeInstId, PChar(Topic), CP_WINANSI);
  Result := True;
end;

procedure TDdeSrvrConv.AdvStop(_Conv: HConv; hszTop: HSZ; hszItem :HSZ);
var
  SrvrItem: TDdeSrvrItem;
begin
  SrvrItem := GetSrvrItem(hszItem);
  if SrvrItem <> nil then
  begin
    FItems.delete(FItems.IndexOf(SrvrItem));
    SrvrItem.Free;
  end;
end;

function TDdeSrvrConv.PokeData(_Conv: HConv; hszTop: HSZ; hszItem: HSZ;
  Data: HDdeData; Fmt: Integer): LongInt;
var
  Srvr: TDdeServerItem;
  Buffer: array[0..4095] of Char;
begin
  Result := dde_FNotProcessed;
  if Fmt <> CF_TEXT then Exit;
  DdeQueryString(ddeMgr.DdeInstId, hszItem, Buffer, SizeOf(Buffer), CP_WINANSI);
  Srvr := GetControl(FSConv, Buffer);
  if Srvr <> nil then Result := Srvr.PokeData(Data);
end;

function TDdeSrvrConv.ExecuteMacro(_Conv: HConv; hszTop: HSZ;
  Data: HDdeData): Integer;
begin
  Result := dde_FNotProcessed;
  if (FSConv <> nil)  then
    Result := FSConv.ExecuteMacro(Data);
end;

function TDdeSrvrConv.RequestData(_Conv: HConv; hszTop: HSZ; hszItem :HSZ;
  Fmt: Word): HDdeData;
var
  Data: string;
  Buffer: array[0..4095] of Char;
  SrvrIt: TDdeSrvrItem;
  Srvr: TDdeServerItem;
begin
  Result := 0;
  SrvrIt := GetSrvrItem(hszItem);
  if SrvrIt <> nil then
    Result := SrvrIt.RequestData(Fmt)
  else
  begin
    DdeQueryString(ddeMgr.DdeInstId, hszItem, Buffer, SizeOf(Buffer), CP_WINANSI);
    Srvr := GetControl(FSConv, Buffer);
    if Srvr <> nil then
    begin
      if Fmt = CF_TEXT then
      begin
        Data := Srvr.Lines.Text;
        Result := DdeCreateDataHandle(ddeMgr.DdeInstId, PChar(Data),
          Length(Data) + 1, 0, hszItem, Fmt, 0 );
      end;
    end;
  end;
end;

function TDdeSrvrConv.GetControl(DdeConv: TDdeServerConv; const ItemName: string): TDdeServerItem;
var
  I: Integer;
  Srvr: TDdeServerItem;
begin
  Result := nil;
  for i := 0 to ddeconv.FItems.Count - 1 do begin
     Srvr := ddeconv.FItems.Items[i];
     if Srvr.Name = ItemName then begin
        result := Srvr;
        exit;
     end;
  end;
end;

function TDdeSrvrConv.GetItem(const ItemName: string): TDdeSrvrItem;
var
  I: Integer;
  Item: TDdeSrvrItem;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
  begin
    Item := FItems.Items[I];
    If Item.Item = ItemName then
    begin
      Result := Item;
      Exit;
    end;
  end;
end;

function TDdeSrvrConv.GetSrvrItem(hszItem: HSZ): TDdeSrvrItem;
var
  I: Integer;
  Item: TDdeSrvrItem;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
  begin
    Item := FItems.Items[I];
    If DdeCmpStringHandles(Item.HszItem, hszItem) = 0 then
    begin
      Result := Item;
      Exit;
    end;
  end;
end;

constructor TDdeSrvrItem.Create;
begin
  DDEType := 'TDdeSrvrItem';
{   FConv := AOwner;}
end;

destructor TDdeSrvrItem.Destroy;
begin
  if FHszItem <> 0 then
  begin
    DdeFreeStringHandle(ddeMgr.DdeInstId, FHszItem);
    FHszItem := 0;
  end;
  inherited Destroy;
end;

function TDdeSrvrItem.RequestData(Fmt: Word): HDdeData;
var
  Data: string;
  Buffer: array[0..4095] of Char;
begin
  Result := 0;
  SetString(FItem, Buffer, DdeQueryString(ddeMgr.DdeInstId, FHszItem, Buffer,
    SizeOf(Buffer), CP_WINANSI));
  if Fmt = CF_TEXT then
  begin
    Data := FSrvr.Lines.Text;
    Result := DdeCreateDataHandle(ddeMgr.DdeInstId, PChar(Data), Length(Data) + 1,
      0, FHszItem, Fmt, 0 );
  end;
end;

procedure TDdeSrvrItem.PostDataChange;
begin
  DdePostAdvise(ddeMgr.DdeInstId, FConv.HszTopic, FHszItem);
end;

procedure TDdeSrvrItem.SetItem(const Value: string);
begin
  FItem := Value;
  if FHszItem <> 0 then
  begin
    DdeFreeStringHandle(ddeMgr.DdeInstId, FHszItem);
    FHszItem := 0;
  end;
  if Length(FItem) > 0 then
    FHszItem := DdeCreateStringHandle(ddeMgr.DdeInstId, PChar(FItem), CP_WINANSI);
end;

initialization
  ddeMgr := TDdeMgr.Create ;  //Инициализация DDE

finalization
  ddeMgr.Free;                //Деинициализация DDE

end.

