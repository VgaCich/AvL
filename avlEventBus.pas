unit avlEventBus;

interface

uses
  AvL;

type
  TEventHandler = procedure(Sender: TObject; const Args: array of const) of object;
  TEventBus = class
  private
    FEvents: array of record
      Name: string;
      Listeners: array of TEventHandler;
    end;
    function Compare(L1, L2: TEventHandler): Boolean;
  public
    destructor Destroy; override;
    function RegisterEvent(const EventName: string): Integer;
    function GetEventId(const EventName: string): Integer;
    procedure ClearEvents;
    function AddListener(EventId: Integer; Listener: TEventHandler): Boolean; overload;
    function AddListener(const EventName: string; Listener: TEventHandler): Boolean; overload;
    procedure RemoveListener(Listener: TEventHandler);
    procedure RemoveListeners(const Listeners: array of TEventHandler);
    function SendEvent(EventId: Integer; Sender: TObject; const Args: array of const): Boolean; overload;
    function SendEvent(const EventName: string; Sender: TObject; const Args: array of const): Boolean; overload;
  end;

var
  EventBus: TEventBus;

implementation

{ TEventBus }

destructor TEventBus.Destroy;
begin
  ClearEvents;
  inherited;
end;

function TEventBus.AddListener(EventId: Integer; Listener: TEventHandler): Boolean;
var
  i: Integer;
begin
  Result := false;
  if (EventId < 0) or (EventId > High(FEvents)) then Exit;
  with FEvents[EventId] do
  begin
    for i := 0 to High(Listeners) do
      if Compare(Listeners[i], Listener) then Exit;
    SetLength(Listeners, Length(Listeners) + 1);
    Listeners[High(Listeners)] := Listener;
    Result := true;
  end;
end;

function TEventBus.AddListener(const EventName: string; Listener: TEventHandler): Boolean;
begin
  Result := AddListener(GetEventId(EventName), Listener);
end;

procedure TEventBus.ClearEvents;
begin
  Finalize(FEvents);
end;

function TEventBus.Compare(L1, L2: TEventHandler): Boolean;
begin
  Result := (TMethod(L1).Code = TMethod(L2).Code) and (TMethod(L1).Data = TMethod(L2).Data);
end;

function TEventBus.GetEventId(const EventName: string): Integer;
begin
  for Result := 0 to High(FEvents) do
    if FEvents[Result].Name = EventName then Exit;
  Result := -1;
end;

function TEventBus.RegisterEvent(const EventName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to High(FEvents) do
    if FEvents[i].Name = EventName then Exit;
  Result := Length(FEvents);
  SetLength(FEvents, Result + 1);
  FEvents[Result].Name := EventName;
end;

procedure TEventBus.RemoveListener(Listener: TEventHandler);
var
  Event, i: Integer;
begin
  for Event := 0 to High(FEvents) do
    with FEvents[Event] do
    begin
      i := 0;
      while i < Length(Listeners) do
        if Compare(Listeners[i], Listener) then
        begin
          while i < High(Listeners) do
          begin
            Listeners[i] := Listeners[i + 1];
            Inc(i);
          end;
          SetLength(Listeners, Length(Listeners) - 1);
        end
        else
          Inc(i);
    end;
end;

procedure TEventBus.RemoveListeners(const Listeners: array of TEventHandler);
var
  i: Integer;
begin
  for i := 0 to High(Listeners) do
    RemoveListener(Listeners[i]);
end;

function TEventBus.SendEvent(EventId: Integer; Sender: TObject; const Args: array of const): Boolean;
var
  i: Integer;
begin
  Result := false;
  if (EventId < 0) or (EventId > High(FEvents)) then Exit;
  with FEvents[EventId] do
    for i := 0 to High(Listeners) do
      Listeners[i](Sender, Args);
  Result := true;
end;

function TEventBus.SendEvent(const EventName: string; Sender: TObject; const Args: array of const): Boolean;
begin
  SendEvent(GetEventId(EventName), Sender, Args);
end;

initialization
  EventBus := TEventBus.Create;

finalization
  FreeAndNil(EventBus);

end.