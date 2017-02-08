unit avlFileClass;

{
  Inno Setup
  Copyright (C) 1997-2004 Jordan Russell
  Portions by Martijn Laan
  For conditions of distribution and use, see LICENSE.TXT.

  TFile class
  Better than File and TFileStream in that does more extensive error checking
  and uses descriptive, localized system error messages.

  $jrsoftware: issrc/Projects/FileClass.pas,v 1.9 2004/03/17 07:41:19 jr Exp $
}

interface

uses
  Windows, AVL, avlInt64Em;

type
  TFileCreateDisposition = (fdCreateAlways, fdCreateNew, fdOpenExisting, fdOpenAlways);
  TFileAccess = (faRead, faWrite, faReadWrite);
  TFileSharing = (fsNone, fsRead, fsWrite, fsReadWrite);

  TFile = class
  private
    FHandle: THandle;
    function GetCappedSize: Cardinal;
    function GetPosition: Integer64;
    function GetSize: Integer64;
    class procedure RaiseLastError;
  public
    constructor Create(const AFilename: String; ACreateDisposition: TFileCreateDisposition;
      AAccess: TFileAccess; ASharing: TFileSharing);
    destructor Destroy; override;
    function Read(var Buffer; Count: Cardinal): Cardinal;
    procedure ReadBuffer(var Buffer; Count: Cardinal);
    procedure Seek(Offset: Cardinal);
    procedure Seek64(Offset: Integer64);
    procedure SeekToEnd;
    procedure Truncate;
    procedure WriteBuffer(const Buffer; Count: Cardinal);
    property CappedSize: Cardinal read GetCappedSize;
    property Handle: THandle read FHandle;
    property Position: Integer64 read GetPosition;
    property Size: Integer64 read GetSize;
  end;

  EFileError = class(Exception)
  private
    FErrorCode: DWORD;
  public
    property ErrorCode: DWORD read FErrorCode;
  end;

implementation

const
  SGenericIOError = 'File I/O error %d';

{ TFile }

constructor TFile.Create(const AFilename: String; ACreateDisposition: TFileCreateDisposition;
  AAccess: TFileAccess; ASharing: TFileSharing);
const
  AccessFlags: array[TFileAccess] of DWORD =
    (GENERIC_READ, GENERIC_WRITE, GENERIC_READ or GENERIC_WRITE);
  SharingFlags: array[TFileSharing] of DWORD =
    (0, FILE_SHARE_READ, FILE_SHARE_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE);
  Disps: array[TFileCreateDisposition] of DWORD =
    (CREATE_ALWAYS, CREATE_NEW, OPEN_EXISTING, OPEN_ALWAYS);
begin
  inherited Create;
  FHandle := CreateFile(PChar(AFilename), AccessFlags[AAccess],
    SharingFlags[ASharing], nil, Disps[ACreateDisposition],
    FILE_ATTRIBUTE_NORMAL, 0);
  if (FHandle = 0) or (FHandle = INVALID_HANDLE_VALUE) then
    RaiseLastError;
end;

destructor TFile.Destroy;
begin
  if (FHandle <> 0) and (FHandle <> INVALID_HANDLE_VALUE) then
    CloseHandle(FHandle);
  inherited;
end;

function TFile.GetPosition: Integer64;
begin
  Result.Hi := 0;
  Result.Lo := SetFilePointer(FHandle, 0, @Result.Hi, FILE_CURRENT);
  if (Result.Lo = $FFFFFFFF) and (GetLastError <> 0) then
    RaiseLastError;
end;

function TFile.GetSize: Integer64;
begin
  Result.Lo := GetFileSize(FHandle, @Result.Hi);
  if (Result.Lo = $FFFFFFFF) and (GetLastError <> 0) then
    RaiseLastError;
end;

function TFile.GetCappedSize: Cardinal;
{ Like GetSize, but capped at $7FFFFFFF }
var
  S: Integer64;
begin
  S := GetSize;
  if (S.Hi = 0) and (S.Lo and $80000000 = 0) then
    Result := S.Lo
  else
    Result := $7FFFFFFF;
end;

class procedure TFile.RaiseLastError;
var
  ErrorCode: DWORD;
  S: String;
  E: EFileError;
begin
  ErrorCode := GetLastError;
  S := SysErrorMessage(ErrorCode);
  if S = '' then begin
    { In case there was no text for the error code. Shouldn't get here under
      normal circumstances. }
    S := Format(SGenericIOError, [ErrorCode]);
  end;
  E := EFileError.Create(S);
  E.FErrorCode := ErrorCode;
  raise E;
end;

function TFile.Read(var Buffer; Count: Cardinal): Cardinal;
begin
  if not ReadFile(FHandle, Buffer, Count, DWORD(Result), nil) then
    RaiseLastError;
end;

procedure TFile.ReadBuffer(var Buffer; Count: Cardinal);
begin
  if Read(Buffer, Count) <> Count then begin
    { Raise localized "Reached end of file" error }
    SetLastError(ERROR_HANDLE_EOF);
    RaiseLastError;
  end;
end;

procedure TFile.Seek(Offset: Cardinal);
var
  I: Integer64;
begin
  I.Hi := 0;
  I.Lo := Offset;
  Seek64(I);
end;

procedure TFile.Seek64(Offset: Integer64);
begin
  if (SetFilePointer(FHandle, Integer(Offset.Lo), @Offset.Hi,
      FILE_BEGIN) = $FFFFFFFF) and (GetLastError <> 0) then
    RaiseLastError;
end;

procedure TFile.SeekToEnd;
var
  DistanceHigh: Integer;
begin
  DistanceHigh := 0;
  if (SetFilePointer(FHandle, 0, @DistanceHigh, FILE_END) = $FFFFFFFF) and
     (GetLastError <> 0) then
    RaiseLastError;
end;

procedure TFile.Truncate;
begin
  if not SetEndOfFile(FHandle) then
    RaiseLastError;
end;

procedure TFile.WriteBuffer(const Buffer; Count: Cardinal);
var
  BytesWritten: DWORD;
begin
  if not WriteFile(FHandle, Buffer, Count, BytesWritten, nil) then
    RaiseLastError;
  if BytesWritten <> Count then begin
    { I'm not aware of any case where WriteFile will return True but a short
      BytesWritten count. (An out-of-disk-space condition causes False to be
      returned.) But if that does happen, raise a generic-sounding localized
      "The system cannot write to the specified device" error. }
    SetLastError(ERROR_WRITE_FAULT);
    RaiseLastError;
  end;
end;

end.
