unit avlStringBuilder;

interface

uses AvL;

type
  TStringBuilder = class
  private
    FData: string;
    FLength: Integer;
    procedure EnsureCapacity(Needed: Integer);
    function GetCapacity: Integer;
    procedure SetCapacity(Value: Integer);
  public
    function Append(const S: string): TStringBuilder; overload;
    function Append(C: Char): TStringBuilder; overload;
    function Clear: TStringBuilder;
    function ToString: string;
    property Length: Integer read FLength;
    property Capacity: Integer read GetCapacity write SetCapacity;
  end;
  
implementation

procedure TStringBuilder.EnsureCapacity(Needed: Integer);
var
  C: Integer;
begin
  if Needed <= Capacity then Exit;
  C := Max(Capacity, 64);
  while C < Needed do
    if C > MaxInt div 2 then
      C := Needed
    else
      C := C * 2;
  Capacity := C;
end;

function TStringBuilder.GetCapacity: Integer;
begin
  Result := System.Length(FData);
end;

procedure TStringBuilder.SetCapacity(Value: Integer);
begin
  SetLength(FData, Max(Value, FLength));
end;

function TStringBuilder.Append(const S: string): TStringBuilder;
var
  N: Integer;
begin
  N := System.Length(S);
  if N > 0 then
  begin
    EnsureCapacity(FLength + N);
    UniqueString(FData);
    Move(S[1], FData[FLength + 1], N);
    Inc(FLength, N);
  end;
  Result := Self;
end;

function TStringBuilder.Append(C: Char): TStringBuilder;
begin
  EnsureCapacity(FLength + 1);
  UniqueString(FData);
  FData[FLength + 1] := C;
  Inc(FLength);
  Result := Self;
end;

function TStringBuilder.Clear: TStringBuilder;
begin
  FLength := 0;
  Result := Self;
end;

function TStringBuilder.ToString: string;
begin
  SetLength(FData, FLength);
  Result := FData;
end;

end.