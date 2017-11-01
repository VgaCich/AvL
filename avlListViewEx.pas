unit avlListViewEx;

interface

uses
  Windows, Messages, CommCtrl, AvL;

type
  TListViewEx = class(TListView)
  private
    function GetItemObject(Index: Integer): TObject;
    function GetSelected(Index: Integer): Integer;
    procedure SetItemObject(Index: Integer; const Value: TObject);
    function GetColumnWidth(Index: Integer): Integer;
    procedure SetColumnWidth(Index: Integer; const Value: Integer);
  public
    function ItemAtPoint(X, Y: Integer): Integer;
    property ItemObject[Index: Integer]: TObject read GetItemObject write SetItemObject;
    property Selected[Index: Integer]: Integer read GetSelected;
    property ColumnWidth[Index: Integer]: Integer read GetColumnWidth write SetColumnWidth;
  end;

implementation

function TListViewEx.GetItemObject(Index: Integer): TObject;
var
  Item: TLVItem;
begin
  Result := nil;
  ZeroMemory(@Item, SizeOf(Item));
  Item.mask := LVIF_PARAM;
  Item.iItem := Index;
  if Perform(LVM_GETITEM, 0, Integer(@Item)) <> 0 then
    Result := TObject(Item.lParam);
end;

function TListViewEx.GetSelected(Index: Integer): Integer;
begin
  Result := -1;
  if (Index < 0) or (Index >= SelCount) then Exit;
  repeat
    Result := Perform(LVM_GETNEXTITEM, Result, LVNI_ALL or LVNI_SELECTED);
    Dec(Index);
  until (Index < 0) or (Result < 0);
end;

procedure TListViewEx.SetItemObject(Index: Integer; const Value: TObject);
var
  Item: TLVItem;
begin
  ZeroMemory(@Item, SizeOf(Item));
  Item.mask := LVIF_PARAM;
  Item.iItem := Index;
  Item.lParam := Integer(Value);
  Perform(LVM_SETITEM, 0, Integer(@Item));
end;

function TListViewEx.ItemAtPoint(X, Y: Integer): Integer;
var
  HTI: TLVHitTestInfo;
begin
  HTI.pt := Point(X, Y);
  Result := Perform(LVM_HITTEST, 0, Integer(@HTI));
end;

function TListViewEx.GetColumnWidth(Index: Integer): Integer;
begin
  Result := Perform(LVM_GETCOLUMNWIDTH, Index, 0);
end;

procedure TListViewEx.SetColumnWidth(Index: Integer; const Value: Integer);
begin
  Perform(LVM_SETCOLUMNWIDTH, Index, MakeLParam(Value, 0));
end;

end.
