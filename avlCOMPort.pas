unit avlCOMPort;

interface

uses
  Windows, AvL;

type
  TFlowControl = (fcNone, fcHardware, fcSoftware, fcBoth);
  TCOMPortInfo = record
    Name: string;
    Index: Integer;
  end;
  TCOMPorts = array of TCOMPortInfo;
  TCOMPort=class
  private
    FHandle: THandle;
    FReadImmediately: Boolean;
    FDCB: TDCB;
    FOnReceive: TOnEvent;
    function GetBitRate: Integer;
    function GetDataBits: Integer;
    function GetParity: Integer;
    function GetStopBits: Integer;
    procedure SetBitRate(const Value: Integer);
    procedure SetDataBits(const Value: Integer);
    procedure SetFlowControl(const Value: TFlowControl);
    procedure SetParity(const Value: Integer);
    procedure SetStopBits(const Value: Integer);
    procedure UpdateState;
    procedure SetReadImmediately(const Value: Boolean);
  public
    constructor Create(Port: Integer; BufSize: Integer = 1024);
    destructor Destroy; override;
    function Read(out Data; Count: Integer): Integer;
    function Write(const Data; Count: Integer): Integer; overload;
    function Write(const Data: string): Integer; overload;
    procedure Flush;
    procedure Purge(RX: Boolean = true; TX: Boolean = true);
    property BitRate: Integer read GetBitRate write SetBitRate;
    property DataBits: Integer read GetDataBits write SetDataBits;
    property FlowControl: TFlowControl write SetFlowControl;
    property Parity: Integer read GetParity write SetParity;
    property StopBits: Integer read GetStopBits write SetStopBits;
    property ReadImmediately: Boolean read FReadImmediately write SetReadImmediately;
    property OnReceive: TOnEvent read FOnReceive write FOnReceive;
  end;

procedure EnumCOMPorts(var List: TCOMPorts);

implementation

procedure EnumCOMPorts(var List: TCOMPorts);
var
  i: Integer;
  PortHandle: THandle;
begin
  Finalize(List);
  for i:=1 to 256 do
  begin
    PortHandle:=FileOpen('\\.\COM'+IntToStr(i), fmOpenRead);
    if PortHandle<>INVALID_HANDLE_VALUE then
    try
      SetLength(List, Length(List) + 1);
      List[High(List)].Name:='COM'+IntToStr(i);
      List[High(List)].Index:=i;
    finally
      CloseHandle(PortHandle);
    end;
  end;
end;

const
  dcb_Binary = $00000001;
  dcb_ParityCheck = $00000002;
  dcb_OutxCtsFlow = $00000004;
  dcb_OutxDsrFlow = $00000008;
  dcb_DtrControlMask = $00000030;
  dcb_DtrControlDisable = $00000000;
  dcb_DtrControlEnable = $00000010;
  dcb_DtrControlHandshake = $00000020;
  dcb_DsrSensitvity = $00000040;
  dcb_TXContinueOnXoff = $00000080;
  dcb_OutX = $00000100;
  dcb_InX = $00000200;
  dcb_ErrorChar = $00000400;
  dcb_NullStrip = $00000800;
  dcb_RtsControlMask = $00003000;
  dcb_RtsControlDisable = $00000000;
  dcb_RtsControlEnable = $00001000;
  dcb_RtsControlHandshake = $00002000;
  dcb_RtsControlToggle = $00003000;
  dcb_AbortOnError = $00004000;
  dcb_Reserveds = $FFFF8000;

constructor TCOMPort.Create(Port: Integer; BufSize: Integer = 1024);
begin
  inherited Create;
  FHandle:=FileOpen('\\.\COM'+IntToStr(Port), fmOpenReadWrite);
  if FHandle=INVALID_HANDLE_VALUE then raise Exception.Create('Couldn''t open port COM'+IntToStr(Port)+#13+SysErrorMessage(GetLastError));
  ZeroMemory(@FDCB, SizeOf(FDCB));
  FDCB.DCBlength:=SizeOf(FDCB);
  GetCommState(FHandle, FDCB);
  with FDCB do
  begin
    Flags:=dcb_Binary;
    XonLim:=256;
    XoffLim:=16;
    XonChar:=#17;
    XoffChar:=#19;
  end;
  UpdateState;
  if not SetupComm(FHandle, BufSize, BufSize) then raise Exception.Create('Couldn''t setup port'#13+SysErrorMessage(GetLastError));
end;

destructor TCOMPort.Destroy;
begin
  CloseHandle(FHandle);
  inherited;
end;

function TCOMPort.GetBitRate: Integer;
begin
  Result:=FDCB.BaudRate;
end;

function TCOMPort.GetDataBits: Integer;
begin
  Result:=FDCB.ByteSize;
end;

function TCOMPort.GetParity: Integer;
begin
  Result:=FDCB.Parity;
end;

function TCOMPort.GetStopBits: Integer;
begin
  Result:=FDCB.StopBits;
end;

procedure TCOMPort.Flush;
begin
  FlushFileBuffers(FHandle);
end;

procedure TCOMPort.Purge(RX: Boolean = true; TX: Boolean = true);
var
  Flags: Cardinal;
begin
  Flags:=0;
  if RX then Flags:=Flags or PURGE_RXABORT or PURGE_RXCLEAR;
  if TX then Flags:=Flags or PURGE_TXABORT or PURGE_TXCLEAR;
  PurgeComm(FHandle, Flags);
end;

function TCOMPort.Read(out Data; Count: Integer): Integer;
begin
  Result:=FileRead(FHandle, Data, Count);
end;

procedure TCOMPort.SetBitRate(const Value: Integer);
begin
  FDCB.BaudRate:=Value;
  UpdateState;
end;

procedure TCOMPort.SetDataBits(const Value: Integer);
begin
  FDCB.ByteSize:=Value;
  UpdateState;
end;

procedure TCOMPort.SetFlowControl(const Value: TFlowControl);
begin
  FDCB.Flags:=FDCB.Flags and not (dcb_OutxCtsFlow or dcb_OutxDsrFlow or
    dcb_DtrControlMask or dcb_OutX or dcb_InX or dcb_RtsControlMask);
  case Value of
    fcNone: ;
    fcHardware: FDCB.Flags:=FDCB.Flags or dcb_OutxCtsFlow or dcb_RtsControlHandshake;
    fcSoftware: FDCB.Flags:=FDCB.Flags or dcb_OutX or dcb_InX;
    fcBoth: FDCB.Flags:=FDCB.Flags or dcb_OutxCtsFlow or dcb_RtsControlHandshake
      or dcb_OutX or dcb_InX;
  end;
  UpdateState;
end;

procedure TCOMPort.SetParity(const Value: Integer);
begin
  FDCB.Parity:=Value;
  UpdateState;
end;

procedure TCOMPort.SetStopBits(const Value: Integer);
begin
  FDCB.StopBits:=Value;
  UpdateState;
end;

procedure TCOMPort.UpdateState;
const
  StopBits: array[Boolean] of Integer = (2, 1);
  ParityBits: array[Boolean] of Integer = (1, 0);
var
  SymbolTime: Integer;
  Timeouts: TCommTimeouts;
begin
  if not SetCommState(FHandle, FDCB) then
    raise Exception.Create('Couldn''t set port state'#13+SysErrorMessage(GetLastError));
  SymbolTime:=Round((FDCB.ByteSize+StopBits[FDCB.StopBits=ONESTOPBIT]+ParityBits[FDCB.Parity=NOPARITY]+1)/FDCB.BaudRate);
  with Timeouts do
  begin
    if FReadImmediately then
    begin
      Timeouts.ReadIntervalTimeout:=MAXDWORD;
      Timeouts.ReadTotalTimeoutMultiplier:=0;
      Timeouts.ReadTotalTimeoutConstant:=0;
    end
    else begin
      Timeouts.ReadIntervalTimeout:=16*SymbolTime;
      Timeouts.ReadTotalTimeoutMultiplier:=4*SymbolTime;
      Timeouts.ReadTotalTimeoutConstant:=1000;
    end;
    Timeouts.WriteTotalTimeoutMultiplier:=4*SymbolTime;
    Timeouts.WriteTotalTimeoutConstant:=1000;
  end;
  if not SetCommTimeouts(FHandle, Timeouts) then raise Exception.Create('Couldn''t set port timeouts'#13+SysErrorMessage(GetLastError));
end;

function TCOMPort.Write(const Data; Count: Integer): Integer;
begin
  Result:=FileWrite(FHandle, Data, Count);
end;

function TCOMPort.Write(const Data: string): Integer;
begin
  Result:=Write(Data[1], Length(Data)); 
end;

procedure TCOMPort.SetReadImmediately(const Value: Boolean);
begin
  if Value = FReadImmediately then Exit;
  FReadImmediately := Value;
  UpdateState;
end;

end.
