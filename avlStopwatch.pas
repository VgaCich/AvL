unit avlStopwatch;

interface

uses Windows, AvL;

type
  IStopwatch = interface
    procedure Start;
    procedure Stop;
    procedure Reset;
    procedure Restart;
    function IsRunning: Boolean;
    function ElapsedTicks: Int64;
    function ElapsedMilliseconds: Double;
  end;
  TStopwatch = class(TInterfacedObject, IStopwatch)
  private
    FFrequency, FStart, FElapsed: Int64;
    FRunning: Boolean;
  public
    constructor Create;
    class function StartNew: IStopwatch;
    procedure Start;
    procedure Stop;
    procedure Reset;
    procedure Restart;
    function IsRunning: Boolean;
    function ElapsedTicks: Int64;
    function ElapsedMilliseconds: Double;
  end;

implementation

constructor TStopwatch.Create;
begin
  inherited Create;
  if not QueryPerformanceFrequency(FFrequency) then
    raise Exception.Create('High-resolution timer is unavailable');
end;

class function TStopwatch.StartNew: IStopwatch;
begin
  Result := TStopwatch.Create;
  Result.Start;
end;

procedure TStopwatch.Start;
begin
  if not FRunning then
  begin
    QueryPerformanceCounter(FStart);
    FRunning := True;
  end;
end;

procedure TStopwatch.Stop;
var T: Int64;
begin
  if FRunning then
  begin
    QueryPerformanceCounter(T);
    Inc(FElapsed, T - FStart);
    FRunning := False;
  end;
end;

procedure TStopwatch.Reset;
begin
  FElapsed := 0;
  FRunning := False;
end;

procedure TStopwatch.Restart;
begin
  Reset;
  Start;
end;

function TStopwatch.ElapsedTicks: Int64;
var T: Int64;
begin
  Result := FElapsed;
  if FRunning then
  begin
    QueryPerformanceCounter(T);
    Inc(Result, T - FStart);
  end;
end;

function TStopwatch.ElapsedMilliseconds: Double;
begin
  Result := ElapsedTicks * 1000 / FFrequency;
end;

function TStopwatch.IsRunning: Boolean;
begin
  Result := FRunning;
end;

end.