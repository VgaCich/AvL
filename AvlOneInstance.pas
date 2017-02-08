unit avlOneInstance;

interface

uses
  Windows;

function IsRunning(ID: PAnsiChar): Boolean;

implementation

var
  Mutex: Integer;

function IsRunning(ID: PAnsiChar): Boolean;
begin
  Mutex:=CreateMutex(nil, true, ID);
  Result:=GetLastError=ERROR_ALREADY_EXISTS;
end;

initialization

finalization
  ReleaseMutex(Mutex);

end.
