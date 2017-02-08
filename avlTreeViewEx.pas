unit avlTreeViewEx;

interface

uses
  Windows, Messages, CommCtrl, AvL;

type
  TExpandMode = (emToggle, emExpand, emCollapse);
  TTreeViewEx = class(TTreeView)
  private
    function GetSelected: Integer;
    procedure SetSelected(const Value: Integer);
  public
    constructor Create(AParent: TWinControl);
    function ItemInsert(Parent, InsertAfter: Integer; Text: string; Obj: TObject): Integer;
    procedure DeleteItem(Item: Integer);
    function GetItemText(Item: Integer): string;
    function GetItemParent(Item: Integer): Integer;
    function GetItemObject(Item: Integer): TObject;
    function ItemExpanded(Item: Integer): Boolean;
    procedure ExpandItem(Item: Integer; Mode: TExpandMode);
    function ItemAtPoint(X, Y: Integer): Integer;
    property Selected: Integer read GetSelected write SetSelected;
  end;

implementation

{ TTreeViewEx }

constructor TTreeViewEx.Create(AParent: TWinControl);
begin
  inherited;
  Style := Style or TVS_EDITLABELS or TVS_SHOWSELALWAYS;
end;

procedure TTreeViewEx.DeleteItem(Item: Integer);
begin
  Perform(TVM_DELETEITEM, 0, Item);
end;

procedure TTreeViewEx.ExpandItem(Item: Integer; Mode: TExpandMode);
const
  Actions: array[Boolean] of Integer = (TVE_COLLAPSE, TVE_EXPAND);
  Modes: array[TExpandMode] of Integer = (TVE_TOGGLE, TVE_EXPAND, TVE_COLLAPSE);
var
  NMHdr: TNMTreeView;
begin
  Perform(TVM_EXPAND, Modes[Mode], Item);
  NMHdr.hdr.hwndFrom := Handle;
  NMHdr.hdr.code := TVN_ITEMEXPANDED;
  NMHdr.action := Actions[ItemExpanded(Item)];
  NMHdr.itemNew.hItem := CommCtrl.HTreeItem(Item);
  NMHdr.itemNew.mask := TVIF_STATE or TVIF_HANDLE or TVIF_PARAM;
  NMHdr.itemNew.stateMask := $FFFF;
  Perform(TVM_GETITEM, 0, Integer(@NMHdr.itemNew));
  SendMessage(GetWindowLong(Handle, GWL_HWNDPARENT), WM_NOTIFY, 0, Integer(@NMHdr));
end;

function TTreeViewEx.GetItemObject(Item: Integer): TObject;
var
  TVI: TTVItem;
begin
  Result := nil;
  if Item = 0 then Exit;
  TVI.mask := TVIF_PARAM or TVIF_HANDLE;
  TVI.hItem := HTreeItem(Item);
  Perform(TVM_GETITEM, 0, Integer(@TVI));
  Result := TObject(TVI.lParam);
end;

function TTreeViewEx.GetItemText(Item: Integer): string;
var
  TVI: TTVItem;
  Buf: array[0..255] of Char;
begin
  Result := '';
  if Item = 0 then Exit;
  TVI.mask := TVIF_TEXT or TVIF_HANDLE;
  TVI.hItem := HTreeItem(Item);
  TVI.pszText := @Buf;
  TVI.cchTextMax := 256;
  Perform(TVM_GETITEM, 0, Integer(@TVI));
  Result := string(Buf);
end;

function TTreeViewEx.GetItemParent(Item: Integer): Integer;
begin
  Result := Perform(TVM_GETNEXTITEM, TVGN_PARENT, Item);
end;

function TTreeViewEx.GetSelected: Integer;
begin
  Result := Perform(TVM_GETNEXTITEM, TVGN_CARET, 0);
end;

function TTreeViewEx.ItemAtPoint(X, Y: Integer): Integer;
var
  HTI: TTVHitTestInfo;
begin
  HTI.pt := Point(X, Y);
  Result := Perform(TVM_HITTEST, 0, Integer(@HTI));
end;

function TTreeViewEx.ItemExpanded(Item: Integer): Boolean;
var
  Itm: TTVItem;
begin
  Itm.hItem := HTreeItem(Item);
  Itm.mask := TVIF_STATE;
  Itm.stateMask := TVIS_EXPANDED;
  Perform(TVM_GETITEM, 0, Integer(@Itm));
  Result := (Itm.state and TVIS_EXPANDED) <> 0; 
end;

function TTreeViewEx.ItemInsert(Parent, InsertAfter: Integer; Text: string; Obj: TObject): Integer;
var
  TVIns: TTVInsertStruct;
begin
  TVIns.hParent := HTreeItem(Parent);
  TVIns.hInsertAfter := HTreeItem(InsertAfter);
  TVIns.item.mask := TVIF_TEXT or TVIF_IMAGE or TVIF_SELECTEDIMAGE or TVIF_PARAM;
  TVIns.item.iImage := I_IMAGECALLBACK;
  TVIns.item.iSelectedImage := I_IMAGECALLBACK;
  TVIns.item.pszText := PChar(Text);
  TVIns.item.lParam := Integer(Obj);
  Result := Perform(TVM_INSERTITEM, 0, Integer(@TVIns));
end;

procedure TTreeViewEx.SetSelected(const Value: Integer);
begin
  Perform(TVM_SELECTITEM, TVGN_CARET, Value);
  Perform(TVM_ENSUREVISIBLE, 0, Value);
end;

end.