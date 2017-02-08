unit avlIStreamAdapter;

interface

uses
  Windows, AvL;

type
  Largeint = Int64;
  PLargeint = ^Largeint;
  POleStr  = PWideChar;
  TCLSID = TGUID;
  PStatStg = ^TStatStg;
  TStatStg = record
    pwcsName: POleStr;
    dwType: Longint;
    cbSize: Largeint;
    mtime: TFileTime;
    ctime: TFileTime;
    atime: TFileTime;
    grfMode: Longint;
    grfLocksSupported: Longint;
    clsid: TCLSID;
    grfStateBits: Longint;
    reserved: Longint;
  end;
  ISequentialStream = interface(IUnknown)
    ['{0c733a30-2a1c-11ce-ade5-00aa0044773d}']
    function Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult; stdcall;
    function Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult; stdcall;
  end;
  IStream = interface(ISequentialStream)
    ['{0000000C-0000-0000-C000-000000000046}']
    function Seek(dlibMove: Largeint; dwOrigin: Longint; libNewPosition: PLargeint): HResult; stdcall;
    function SetSize(libNewSize: Largeint): HResult; stdcall;
    function CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint; out cbWritten: Largeint): HResult; stdcall;
    function Commit(grfCommitFlags: Longint): HResult; stdcall;
    function Revert: HResult; stdcall;
    function LockRegion(libOffset: Largeint; cb: Largeint; dwLockType: Longint): HResult; stdcall;
    function UnlockRegion(libOffset: Largeint; cb: Largeint; dwLockType: Longint): HResult; stdcall;
    function Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult; stdcall;
    function Clone(out stm: IStream): HResult; stdcall;
  end;
  TIStreamAdapter = class(TInterfacedObject, IStream)
  private
    FStream: TStream;
  public
    constructor Create(Stream: TStream);
    function Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult; stdcall;
    function Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult; stdcall;
    function Seek(dlibMove: Largeint; dwOrigin: Longint; libNewPosition: PLargeint): HResult; stdcall;
    function SetSize(libNewSize: Largeint): HResult; stdcall;
    function CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint; out cbWritten: Largeint): HResult; stdcall;
    function Commit(grfCommitFlags: Longint): HResult; stdcall;
    function Revert: HResult; stdcall;
    function LockRegion(libOffset: Largeint; cb: Largeint; dwLockType: Longint): HResult; stdcall;
    function UnlockRegion(libOffset: Largeint; cb: Largeint; dwLockType: Longint): HResult; stdcall;
    function Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult; stdcall;
    function Clone(out stm: IStream): HResult; stdcall;
  end;

function CreateIStreamOnMemory(Mem: Pointer; Size: Integer; var Stream: IStream): HGLOBAL; //Don't forget to free returned HGLOBAL after use

const
  STREAM_SEEK_SET = 0;
  STREAM_SEEK_CUR = 1;
  STREAM_SEEK_END = 2;

implementation

function CreateStreamOnHGlobal(hglob: HGlobal; fDeleteOnRelease: BOOL; out stm: IStream): HResult; stdcall; external 'ole32.dll';

function CreateIStreamOnMemory(Mem: Pointer; Size: Integer; var Stream: IStream): HGLOBAL;
var
  GlobBuf: Pointer;
begin
  Result := GlobalAlloc(GMEM_FIXED, Size);
  if Result <> 0 then
  begin
    GlobBuf := GlobalLock(Result);
    Move(Mem^, GlobBuf^, Size);
    GlobalUnlock(Result);
    CreateStreamOnHGlobal(Result, false, Stream);
  end;
end;

{ TIStreamAdapter }

function TIStreamAdapter.Clone(out stm: IStream): HResult;
begin
  Result := E_NOTIMPL;
end;

function TIStreamAdapter.Commit(grfCommitFlags: Integer): HResult;
begin
  Result := S_OK;
end;

function TIStreamAdapter.CopyTo(stm: IStream; cb: Largeint; out cbRead, cbWritten: Largeint): HResult;
begin
  Result := E_NOTIMPL;
end;

constructor TIStreamAdapter.Create(Stream: TStream);
begin
  inherited Create;
  FStream := Stream;
end;

function TIStreamAdapter.LockRegion(libOffset, cb: Largeint; dwLockType: Integer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TIStreamAdapter.Read(pv: Pointer; cb: Integer; pcbRead: PLongint): HResult;
var
  Read: Longint;
begin
  try
    Read := FStream.Read(pv^, cb);
    if Assigned(pcbRead) then pcbRead^ := Read;
    if Read < cb
      then Result := S_FALSE
      else Result := S_OK;
  except
    Result := E_FAIL;
  end;
end;

function TIStreamAdapter.Revert: HResult;
begin
  Result := E_NOTIMPL;
end;

function TIStreamAdapter.Seek(dlibMove: Largeint; dwOrigin: Longint; libNewPosition: PLargeint): HResult;
var
  NewPosition: Largeint;
begin
  try
    NewPosition := FStream.Seek(dlibMove, dwOrigin);
    if Assigned(libNewPosition) then libNewPosition^ := NewPosition;
    Result := S_OK;
  except
    Result := E_FAIL;
  end;
end;

function TIStreamAdapter.SetSize(libNewSize: Largeint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TIStreamAdapter.Stat(out statstg: TStatStg; grfStatFlag: Integer): HResult;
begin
  try
    ZeroMemory(@statstg, SizeOf(statstg));
    statstg.dwType := 2;
    statstg.cbSize := FStream.Size;
    Result := S_OK;
  except
    Result := E_FAIL;
  end;
end;

function TIStreamAdapter.UnlockRegion(libOffset, cb: Largeint; dwLockType: Integer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TIStreamAdapter.Write(pv: Pointer; cb: Integer; pcbWritten: PLongint): HResult;
var
  Written: Longint;
begin
  try
    Written := FStream.Write(pv^, cb);
    if Assigned(pcbWritten) then pcbWritten^ := Written;
    Result := S_OK;
  except
    Result := E_FAIL;
  end;
end;

end.