unit LeakDetect;

interface

var
  LeakMessageEnabled: Boolean = true;

implementation

uses
  Windows;

var
  HPS, HPF: THeapStatus;
  S: string;

initialization

  HPS:=GetHeapStatus;

finalization

  HPF:=GetHeapStatus;
  Str(HPF.TotalAllocated - HPS.TotalAllocated, S);
  if LeakMessageEnabled and (HPS.TotalAllocated <> HPF.TotalAllocated) then
    MessageBox(0, PChar('Memory leak detected: ' + S + ' bytes leaked'), 'Warning', MB_ICONEXCLAMATION);

end.