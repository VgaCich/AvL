(**************************************************)
(*                                                *)
(*                 AvlMedia                       *)
(*                Version 1.0                     *)
(*                                                *)
(*         Copyright (c) 2000-2003                *)
(*             Avenger, by NhT                    *)
(*                                                *)
(*         http://www.nht-team.org/               *)
(*         E-Mail: xavenger@mail.ru               *)
(*                                                *)
(**************************************************)
unit avlMedia;

interface

uses Windows, MMSystem;

type
  TavlMedia = class
  private
    FFileName: String;
    FDeviceID: Word;
    FFlags: Longint;
    Opened: Boolean;
    FDisplay: THandle;
    function GetPosition: Longint;
    function GetLength: Longint;
    procedure SetPosition(Value: Longint);
    procedure SetDisplay(const Value: THandle);
  public
    constructor Create;

    function IsOpened:Boolean;
    procedure Open;
    procedure Close;
    procedure Play;
    procedure Stop;
    procedure Pause;
  published
    property Display: THandle read FDisplay write SetDisplay;  
    property FileName:String read FFileName write FFileName;
    property Length:Integer read GetLength;
    property Position:Integer read GetPosition write SetPosition;
  end;

implementation

procedure TavlMedia.Close;
var
 GenParm: TMCI_Generic_Parms;
begin
 mciSendCommand(FDeviceID, mci_Close, FFlags, Longint(@GenParm));
 Opened:=False;
end;

function TavlMedia.GetLength: Longint;
var
  StatusParm: TMCI_Status_Parms;
begin
 Result := -1;  {Result is -1 if device is not open}
 if not Opened then Exit;
 FFlags := mci_Wait or mci_Status_Item;
 StatusParm.dwItem := mci_Status_Length;
 mciSendCommand( FDeviceID, mci_Status, FFlags, Longint(@StatusParm));
 Result := StatusParm.dwReturn;
end;

function TavlMedia.GetPosition: Longint;
var
  StatusParm: TMCI_Status_Parms;
begin
 Result := -1;
 if not Opened then Exit;
 FFlags := mci_Wait or mci_Status_Item;
 StatusParm.dwItem := mci_Status_Position;
 mciSendCommand( FDeviceID, mci_Status, FFlags, Longint(@StatusParm));
 Result := StatusParm.dwReturn;
end;

procedure TavlMedia.Open;
var
  OpenParm: TMCI_Open_Parms;
begin
  { zero out memory }
  FillChar(OpenParm, SizeOf(TMCI_Open_Parms), 0);
//  if MCIOpened then
  Close; {must close MCI Device first before opening another}

  OpenParm.dwCallback := 0;
  OpenParm.lpstrElementName := PChar(FFileName);

  FFlags := MCI_OPEN_ELEMENT;

  mciSendCommand(0, mci_Open, FFlags, Longint(@OpenParm));
  FDeviceID := OpenParm.wDeviceID;
  Opened:=True;
end;

function TavlMedia.IsOpened: Boolean;
begin
 Result := Opened;
end;

procedure TavlMedia.Pause;
var
 GenParm: TMCI_Generic_Parms;
begin
 mciSendCommand( FDeviceID, mci_Pause, 0, Longint(@GenParm));
end;

procedure TavlMedia.Play;
var
 PlayParm: TMCI_Play_Parms;
begin
 mciSendCommand(FDeviceID, mci_Play, 0, Longint(@PlayParm));
end;

procedure TavlMedia.SetPosition(Value: Integer);
var
  SeekParm: TMCI_Seek_Parms;
begin
 if not Opened then Exit;  {raises exception if device is not open}

 FFlags := mci_Wait;
 FFlags := FFlags or mci_To;

 SeekParm.dwTo := Value;
 mciSendCommand( FDeviceID, mci_Seek, FFlags, Longint(@SeekParm));
end;

procedure TavlMedia.Stop;
var
  GenParm: TMCI_Generic_Parms;
begin
 mciSendCommand( FDeviceID, mci_Stop, 0, Longint(@GenParm));
 SetPosition(0);
end;


constructor TavlMedia.Create;
begin
 Opened:=False;
end;

procedure TavlMedia.SetDisplay(const Value: THandle);
var
  AWindowParm: TMCI_Anim_Window_Parms;
  FError: MCIERROR;
begin
  if (Value <> 0) and Opened then
  begin
    FFlags := mci_Wait or mci_Anim_Window_hWnd;
    AWindowParm.Wnd := Longint(Value);
    FError := mciSendCommand( FDeviceID, mci_Window, FFlags, Longint(@AWindowParm) );
    if FError <> 0 then
      FDisplay := 0 {alternate window not supported}
    else
     FDisplay := Value; {alternate window supported}
  end
  else FDisplay := Value;
end;

end.
