{---------------------------------------------------------}
{                                                         }
{                     AvlThreadedTimer                    }
{                       Version 1.0                       }
{                                                         }
{           Модуль для использования сверхточного         }
{               таймера (точность около 1мс).             }
{                                                         }
{                Поддерживает библиотеки:                 }
{                          Avl                            }
{                                                         }
{                      Avenger[NhT]                       }
{               E-Mail: xavenger@mail.ru                  }
{               Home-Page: http://www.nht                 }
{                                                         }
{---------------------------------------------------------}

//Используемая библиотека:
//Необходимо раскоментировать ТОЛЬКО одну строку!
{$define Avl}
//{$define Kol}     //Пока не поддерживает!!!

unit avlThdTimer;

interface

uses
  Windows,
{$ifdef Avl}
  Avl;
{$endif}{$ifdef Kol}
  Kol;
{$endif}

type
  TAvlThreadedTimer = class;

  TTimerThread = class(TThread)
    OwnerTimer: TAvlThreadedTimer;
    procedure Execute; override;
  end;

  TAvlThreadedTimer = class
  private
    FEnabled: boolean;
    FInterval: word;
    FOnTimer: TNotifyEvent;
    FTimerThread: TTimerThread;
    FThreadPriority: TThreadPriority;
  protected
    procedure UpdateTimer;
    procedure SetEnabled(value: boolean);
    procedure SetInterval(value: word);
    procedure SetThreadPriority(value: TThreadPriority);
    procedure Timer; dynamic;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default true;
    property Interval: Word read FInterval write SetInterval default 1000;
    property Priority: TThreadPriority read FThreadPriority write SetThreadPriority default tpNormal;
    property OnTimer: TNotifyEvent read FOnTimer write FOnTimer;
  end;

implementation

procedure TTimerThread.Execute;
begin
  Priority := OwnerTimer.FThreadPriority;
  repeat
   SleepEx(OwnerTimer.FInterval, False);
   Synchronize(OwnerTimer.Timer);
  until Terminated;
end;

constructor TAvlThreadedTimer.Create;
begin
  FEnabled := True;
  FInterval := 1000;
  FThreadPriority := tpNormal;
  FTimerThread := TTimerThread.Create(False);
  FTimerThread.OwnerTimer := Self;
end;

destructor TAvlThreadedTimer.Destroy;
begin
  FEnabled := False;
  UpdateTimer;
  FTimerThread.Free;
  inherited Destroy;
end;

procedure TAvlThreadedTimer.UpdateTimer;
begin
  if not FTimerThread.Suspended then FTimerThread.Suspend;
  if (FInterval <> 0) and FEnabled then
   if FTimerThread.Suspended then FTimerThread.Resume;
end;

procedure TAvlThreadedTimer.SetEnabled(value: boolean);
begin
  if value <> FEnabled then
   begin
    FEnabled := value;
    UpdateTimer;
   end;
end;

procedure TAvlThreadedTimer.SetInterval(value: Word);
begin
  if Value <> FInterval then
   begin
    FInterval := value;
    UpdateTimer;
   end;
end;

procedure TAvlThreadedTimer.SetThreadPriority(value: TThreadPriority);
begin
  if value <> FThreadPriority then
   begin
    FThreadPriority := Value;
//    FTimerThread.Priority := Value;
    UpdateTimer;
   end;
end;

procedure TAvlThreadedTimer.Timer;
begin
  if Assigned(FOnTimer) then FOnTimer(Self);
end;

end.
