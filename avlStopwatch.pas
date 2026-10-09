unit avlStopwatch;

interface

uses Windows, AvL;

type
  TStopwatch = class
  private
    FFrequency, FStart, FElapsed: Int64;
    FRunning: Boolean;
    function GetElapsedTicks: Int64;
    function GetElapsedMilliseconds: Double;
  public
    constructor Create;
    class function StartNew: TStopwatch;
    procedure Start;
    procedure Stop;
    procedure Reset;
    procedure Restart;
    property IsRunning: Boolean read FRunning;
    property ElapsedTicks: Int64 read GetElapsedTicks;
    property ElapsedMilliseconds: Double read GetElapsedMilliseconds;
  end;

implementation

constructor TStopwatch.Create;
begin
  inherited Create;
  if not QueryPerformanceFrequency(FFrequency) then
    raise Exception.Create('High-resolution timer is unavailable');
end;

class function TStopwatch.StartNew: TStopwatch;
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

function TStopwatch.GetElapsedTicks: Int64;
var T: Int64;
begin
  Result := FElapsed;
  if FRunning then
  begin
    QueryPerformanceCounter(T);
    Inc(Result, T - FStart);
  end;
end;

function TStopwatch.GetElapsedMilliseconds: Double;
begin
  Result := GetElapsedTicks * 1000 / FFrequency;
end;

end.