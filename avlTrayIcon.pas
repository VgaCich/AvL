//www.nht-team.net
//Version: 1.1
unit avlTrayIcon;

interface

uses
 Windows, Messages, Avl;

const
  // User-defined message sent by the trayicon
  WM_TRAYNOTIFY = WM_USER + 1024;

  {$EXTERNALSYM NIM_ADD}
  NIM_ADD         = $00000000;
  {$EXTERNALSYM NIM_MODIFY}
  NIM_MODIFY      = $00000001;
  {$EXTERNALSYM NIM_DELETE}
  NIM_DELETE      = $00000002;

  {$EXTERNALSYM NIF_MESSAGE}
  NIF_MESSAGE     = $00000001;
  {$EXTERNALSYM NIF_ICON}
  NIF_ICON        = $00000002;
  {$EXTERNALSYM NIF_TIP}
  NIF_TIP         = $00000004;  

  // Key select events (Space and Enter)
  NIN_SELECT           = WM_USER + 0;
  NINF_KEY             = 1;
  NIN_KEYSELECT        = NINF_KEY or NIN_SELECT;

  // Events returned by balloon hint
  NIN_BALLOONSHOW      = WM_USER + 2;
  NIN_BALLOONHIDE      = WM_USER + 3;
  NIN_BALLOONTIMEOUT   = WM_USER + 4;
  NIN_BALLOONUSERCLICK = WM_USER + 5;

  // Constants used for balloon hint feature
  NIIF_NONE            = $00000000;
  NIIF_INFO            = $00000001;
  NIIF_WARNING         = $00000002;
  NIIF_ERROR           = $00000003;
  NIIF_ICON_MASK       = $0000000F; // Reserved for WinXP
  NIIF_NOSOUND         = $00000010; // Reserved for WinXP

  // Additional uFlags constants for TNotifyIconDataEx
  NIF_STATE            = $00000008;
  NIF_INFO             = $00000010;
  NIF_GUID             = $00000020;

  // Additional dwMessage constants for Shell_NotifyIcon
  NIM_SETFOCUS         = $00000003;
  NIM_SETVERSION       = $00000004;
  NOTIFYICON_VERSION   = 3; // Used with the NIM_SETVERSION message
//==============================================================================

type
  TTimeoutOrVersion = packed record
    case Integer of        // 0: Before Win2000; 1: Win2000 and up
      0: (uTimeout: UINT);
      1: (uVersion: UINT); // Only used when sending a NIM_SETVERSION message
    end;

  TNotifyIconDataEx = packed record
    cbSize: DWORD;
    hWnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array[0..127] of AnsiChar; // Previously 64 chars, now 128
    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array[0..255] of AnsiChar;
    TimeoutOrVersion: TTimeoutOrVersion;
    szInfoTitle: array[0..63] of AnsiChar;
    dwInfoFlags: DWORD;
{$IFDEF _WIN32_IE_600}
    guidItem: TGUID;  // Reserved for WinXP; define _WIN32_IE_600 if needed
{$ENDIF}
  end;


 TAvlTrayIcon = class(TComponent)
  private
    NIDE: TNotifyIconDataEx; 
    FActive: Boolean;
    FIcon: HICON;
    FHandle:Integer;
    FToolTip: string;
    FBalloonText: string;
    FBalloonTitle: string;
    FOnBalloonShow: TOnEvent;
    FOnBalloonHide: TOnEvent;
    FOnBalloonClick: TOnEvent;
    FOnBalloonTimeOut: TOnEvent;
    FOnMouseUp: TOnMouse;
    FOnMouseDown: TOnMouse;
    FOnMouseMove: TOnMouse;
    FOnMouseDblClk: TOnEvent;
    FOnQueryEndSession: TOnMessage;
    procedure WndProcTray(var Message: TMessage);
    procedure SetActive(const Value: Boolean);
    procedure SetIcon(const Value: HICON);
    procedure SetToolTip(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadIcon(IconName: PChar);
    {* Загружает иконку в трей. (см. Icon)}
    procedure ShowBalloon(const IconType: Word);
    {* Показать balloon.
    !<i>IconType:</i>
    !NIIF_NONE - без иконки,
    !NIIF_INFO - иконка Information,
    !NIIF_WARNING - иконка Warning,
    !NIIF_ERROR - иконка Error.}
    procedure HideBalloon;
    {* Скрыть balloon.}    
    property Icon: HICON read FIcon write SetIcon;
    {* Иконка в трее. (см. LoadTrayIcon)}
    property Active: Boolean read FActive write SetActive;
    {* TRUE/FALSE - показать/убрать иконку в трее.}
    property ToolTip: string read FToolTip write SetToolTip;
    {* Всплывающая подсказка.}
    property BalloonText: string read FBalloonText write FBalloonText;
    {* Текст ballon'а.}
    property BalloonTitle: string read FBalloonTitle write FBalloonTitle;
    {* Заголовок balloon'а.}
    property OnBalloonShow: TOnEvent read FOnBalloonShow write FOnBalloonShow;
    {* При показе balloon'а.}
    property OnBalloonHide: TOnEvent read FOnBalloonHide write FOnBalloonHide;
    {* При скрытии balloon'а.}
    property OnBalloonClick: TOnEvent read FOnBalloonClick write FOnBalloonClick;
    {* При нажатии левой кнопки мыши на balloon'е.}
    property OnBalloonTimeOut: TOnEvent read FOnBalloonTimeOut write FOnBalloonTimeOut;
    {* При нажатии правой кнопки мыши на balloon'е и при его закрытии.}
    property OnMouseMove: TOnMouse read FOnMouseMove write FOnMouseMove;
    {*}
    property OnMouseDown: TOnMouse read FOnMouseDown write FOnMouseDown;
    {*}
    property OnMouseUp: TOnMouse read FOnMouseUp write FOnMouseUp;
    {*} 
    property OnMouseDblClick: TOnEvent read FOnMouseDblClk write FOnMouseDblClk;
    {*}
    property OnQueryEndSession: TOnMessage read FOnQueryEndSession write FOnQueryEndSession;
    {*}
 end; 

implementation

var
  WM_TASKBARCREATED: DWORD; // Обновление(крах) Explorer'а

function Shell_NotifyIcon(dwMessage: DWORD; lpData: Pointer): BOOL; stdcall; external 'shell32.dll' name 'Shell_NotifyIconA'

{ TAvlTrayIcon }

procedure TAvlTrayIcon.LoadIcon(IconName: PChar);
begin
 Icon := Windows.LoadIcon(hInstance, IconName);
end;

//==============================================================================
//=== ОБРАБОТЧИК ОБЪЕКТА
//==============================================================================
procedure TAvlTrayIcon.WndProcTray(var Message: TMessage);
var
  Coord: TPoint;
  x, y:Integer;     
begin
  GetCursorPos(Coord); // Координаты мыши
  x := Coord.x;
  y := Coord.y;
  with Message do
   begin
  //=== Показать иконку(и) в трее, после обновления(краха) Explorer'а ===
    if Msg = WM_TASKBARCREATED then
     begin
      if FActive then
       begin
        Active := False;
        Active := True;
       end;
     end;

    if Msg = WM_TRAYNOTIFY then
     case lParam of
      NIN_BALLOONSHOW: if Assigned(FOnBalloonShow) then FOnBalloonShow(Self);
      NIN_BALLOONHIDE: if Assigned(FOnBalloonHide) then FOnBalloonHide(Self);
      NIN_BALLOONUSERCLICK: if Assigned(OnBalloonClick) then FOnBalloonClick(Self);
      NIN_BALLOONTIMEOUT: if Assigned(FOnBalloonTimeOut) then FOnBalloonTimeOut(Self);

      WM_LBUTTONDBLCLK: if Assigned(FOnMouseDblClk) then FOnMouseDblClk(Self);
      WM_MOUSEMOVE: if Assigned(FOnMouseMove) then FOnMouseMove(Self, mbLeft, [], x, y);

      WM_LBUTTONDOWN: if Assigned(FOnMouseDown) then FOnMouseDown(Self, mbLeft, [], x, y);
      WM_RBUTTONDOWN: if Assigned(FOnMouseDown) then FOnMouseDown(Self, mbRight, [], x, y);
      WM_MBUTTONDOWN: if Assigned(FOnMouseDown) then FOnMouseDown(Self, mbMiddle, [], x, y);

      WM_LBUTTONUP: if Assigned(FOnMouseUp) then FOnMouseUp(Self, mbLeft, [], x, y);
      WM_RBUTTONUP: if Assigned(FOnMouseUp) then FOnMouseUp(Self, mbRight, [], x, y);
      WM_MBUTTONUP: if Assigned(FOnMouseUp) then FOnMouseUp(Self, mbMiddle, [], x, y);
     end;

     if Msg = WM_QUERYENDSESSION
       then if Assigned(FOnQueryEndSession)
         then FOnQueryEndSession(Message)
         else Result:=1;
   end;  
end;

//==============================================================================
//=== КОНСТРУКТОР ДЛЯ КЛАССА
//==============================================================================
constructor TAvlTrayIcon.Create;
begin
  WM_TASKBARCREATED := RegisterWindowMessage('TaskbarCreated');
  FHandle := AllocateHWnd(WndProcTray);
end;

//==============================================================================
//=== Destructor КЛАССА
//==============================================================================
destructor TAvlTrayIcon.Destroy;
begin
  inherited;
  Shell_NotifyIcon(NIM_DELETE, @NIDE);
end;

//==============================================================================
//=== ПОКАЗАТЬ Balloon
//==============================================================================
procedure TAvlTrayIcon.ShowBalloon(const IconType: Word);
begin
  with NIDE do
  begin
    uFlags := NIF_INFO;
    dwInfoFlags := IconType;
    lstrcpy(szInfoTitle, PChar(FBalloonTitle)); // Заголовок Balloon`а
    lstrcpy(szInfo, PChar(FBalloonText)); // Текст Balloon`а
    Shell_NotifyIcon(NIM_MODIFY, @NIDE);
    szInfoTitle[0] := #0;
    szInfo[0] := #0;
  end;
end;

//==============================================================================
//=== СКРЫТЬ Balloon
//==============================================================================
procedure TAvlTrayIcon.HideBalloon;
begin
  NIDE.uFlags := NIF_INFO;
  Shell_NotifyIcon(NIM_MODIFY, @NIDE);
end;

//==============================================================================
//=== АКТИВИЗАЦИЯ ИКОНКИ
//==============================================================================
procedure TAvlTrayIcon.SetActive(const Value: Boolean);
begin
  if FActive = Value then Exit;
  FActive := Value;
  if FIcon <= 0 then Exit;  // Выход, если нет иконки 
  if FHandle = 0 then Exit; // Выход, если окно не создано
                            // Если не выйти, то иконка не правильно зарегистрируется
  if FActive then
   begin // Добавить иконку
    FillChar(NIDE, SizeOf(NIDE), 0); // Зачистка мусора
    with NIDE do
     begin
      cbSize := SizeOf(NIDE);
      //=== Иконки должны различаться по номерам ===
      uID := DWORD(@Self); // Номер иконки
      hIcon := FIcon;      // Handle иконки
      hWnd := FHandle; // Handle окна
      lstrcpy(szTip, PChar(FToolTip));   // Надпись над иконкой
      uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
      uCallbackMessage := WM_TRAYNOTIFY; // Наш обарботчик
     end;
    Shell_NotifyIcon(NIM_ADD, @NIDE);
   end
  else // Удалить иконку
   Shell_NotifyIcon(NIM_DELETE, @NIDE);
end;

procedure TAvlTrayIcon.SetIcon(const Value: HICON);
begin
  FIcon := Value;
  if FActive then
  begin
    NIDE.hIcon := FIcon; // Handle иконки
    NIDE.uFlags := NIF_ICON or NIF_INFO;
    if not Shell_NotifyIcon(NIM_MODIFY, @NIDE) then
      Active := TRUE;
  end;
end;

procedure TAvlTrayIcon.SetToolTip(const Value: string);
begin
  FToolTip := Value;
  if FActive then
  begin
    lstrcpy(NIDE.szTip, PChar(FToolTip));
    NIDE.uFlags := NIF_TIP;
    Shell_NotifyIcon(NIM_MODIFY, @NIDE);
  end;
end;

end.
