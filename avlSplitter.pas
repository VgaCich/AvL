unit avlSplitter;

interface

uses
  Windows, AvL;

type
  TSplitter = class(TPanel)
  private
    FOnMove: TOnEvent;
    FVertical, FMoving: Boolean;
    FDefColor: TColor;
    FMaxPos: Integer;
    FMinPos: Integer;
    function GetRight: Integer;
    function GetBottom: Integer;
    procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Move(Pos: Integer);
    procedure SetMaxPos(const Value: Integer);
    procedure SetMinPos(const Value: Integer);
  public
    constructor Create(AParent: TWinControl; Vertical: Boolean);
    property OnMove: TOnEvent read FOnMove write FOnMove;
    property MinPos: Integer read FMinPos write SetMinPos;
    property MaxPos: Integer read FMaxPos write SetMaxPos;
    property Right: Integer read GetRight;
    property Bottom: Integer read GetBottom;
  end;

implementation

{ TSplitter }

constructor TSplitter.Create(AParent: TWinControl; Vertical: Boolean);
begin
  inherited Create(AParent, '');
  FVertical := Vertical;
  FDefColor := Color;
  Bevel := bvNone;
  FMinPos := 0;
  if Vertical then
  begin
    Width := 4;
    FMaxPos := Parent.ClientWidth - Width;
    Cursor:=LoadCursor(0, IDC_SIZEWE);
  end
  else begin
    Height := 4;
    FMaxPos := Parent.ClientHeight - Height;
    Cursor:=LoadCursor(0, IDC_SIZENS);
  end;
  OnMouseDown := MouseDown;
  OnMouseUp := MouseUp;
  OnMouseMove := MouseMove;
end;

function TSplitter.GetBottom: Integer;
begin
  Result := Top + Height;
end;

function TSplitter.GetRight: Integer;
begin
  Result := Left + Width;
end;

procedure TSplitter.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FMoving := true;
    Color := clGray;
    SetCapture(Handle);
  end;
end;

procedure TSplitter.MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if FMoving then
    if FVertical
      then Move(Left + X - Width div 2)
      else Move(Top + Y - Height div 2);
end;

procedure TSplitter.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and FMoving then
  begin
    FMoving := false;
    Color := FDefColor;
    ReleaseCapture;
  end;
end;

procedure TSplitter.Move(Pos: Integer);
begin
  if FVertical
    then Left := Max(FMinPos, Min(Pos, FMaxPos))
    else Top := Max(FMinPos, Min(Pos, FMaxPos));
  if Assigned(FOnMove) then
    FOnMove(Self);
end;

procedure TSplitter.SetMinPos(const Value: Integer);
begin
  FMinPos := Value;
  if (FVertical and (Left < Value)) or (not FVertical and (Top < Value)) then
    Move(Value);
end;

procedure TSplitter.SetMaxPos(const Value: Integer);
begin
  FMaxPos := Value;
  if (FVertical and (Left > Value)) or (not FVertical and (Top > Value)) then
    Move(Value);
end;

end.
