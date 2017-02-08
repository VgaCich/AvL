unit LeakDetect;

interface

implementation

uses
  Windows;

var
  HPS, HPF: THeapStatus;

initialization

  HPS:=GetHeapStatus;

finalization

  HPF:=GetHeapStatus;
  if HPS.TotalAllocated<>HPF.TotalAllocated
    then MessageBox(0, 'Memory leak detected', 'Warning', MB_ICONEXCLAMATION);

end.