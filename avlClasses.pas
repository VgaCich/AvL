//(c) VgaSoft, 2004-2007
unit avlClasses;

interface

uses
  Windows, AvL;

type
  TDLCListItem=class;
  TDLCListCheckFunc=function(Item: TDLCListItem; Data: Integer): Boolean of object;
  TDLCListItem=class
  protected
    FNext, FPrev: TDLCListItem;
    FRefCount: Integer;
    procedure Remove;
  public
    constructor Create(PrevItem: TDLCListItem);
    destructor Destroy; override;
    procedure ClearList;
    procedure ResetList;
    function  FindItem(CheckFunc: TDLCListCheckFunc; Data: Integer): TDLCListItem;
    procedure AddRef;
    procedure Release;
    property Next: TDLCListItem read FNext;
    property Prev: TDLCListItem read FPrev;
  end;

implementation

constructor TDLCListItem.Create(PrevItem: TDLCListItem);
begin
  inherited Create;
  if Assigned(PrevItem) then
  begin
    FNext:=PrevItem.FNext;
    FPrev:=PrevItem;
    PrevItem.FNext:=Self;
    FNext.FPrev:=Self;
  end
  else begin
    FNext:=Self;
    FPrev:=Self;
  end;
  FRefCount:=1;
end;

destructor TDLCListItem.Destroy;
begin
  Remove;
  inherited Destroy;
end;

procedure TDLCListItem.Remove;
begin
  if (FPrev<>Self) and (FNext<>Self) and Assigned(FPrev) and Assigned(FNext) then
  begin
    FPrev.FNext:=FNext;
    FNext.FPrev:=FPrev;
  end;
end;

procedure TDLCListItem.ClearList;
begin
  if not Assigned(FNext) then Exit;
  while FNext<>Self do FNext.Free;
end;

procedure TDLCListItem.ResetList;
begin
  Remove;
  FNext:=Self;
  FPrev:=Self;
end;

function TDLCListItem.FindItem(CheckFunc: TDLCListCheckFunc; Data: Integer): TDLCListItem;
begin
  if CheckFunc(Self, Data) then
  begin
    Result:=Self;
    Exit;
  end;
  Result:=Self.FNext;
  while (Result<>Self) do
    if CheckFunc(Result, Data)
      then Exit
      else Result:=Result.FNext;
  Result:=nil;
end;

procedure TDLCListItem.AddRef;
begin
  Inc(FRefCount);
end;

procedure TDLCListItem.Release;
begin
  if not Assigned(Self) then Exit;
  Dec(FRefCount);
  if FRefCount<=0 then Destroy;
end;

end.