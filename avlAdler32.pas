unit avlAdler32;

interface

uses AvL;

function NextAdler32(Adler: Cardinal; Buffer: PByte; Len: Cardinal): Cardinal;
function StreamAdler32(Source: TStream; Count: Cardinal): Cardinal;

implementation

const
  MaxBufSize=65536;

{$L adler32.obj}
function NextAdler32(Adler: Cardinal; Buffer: PByte; Len: Cardinal): Cardinal; external;

function  StreamAdler32(Source: TStream; Count: Cardinal): Cardinal;
var
  BufSize, N: Integer;
  Buffer: Pointer;
begin
  Result:=1;
  Buffer:=nil;
  if Count=0 then
  begin
    Source.Position:=0;
    Count:=Source.Size;
  end;
  if Count>MaxBufSize
    then BufSize:=MaxBufSize
    else BufSize:=Count;
  GetMem(Buffer, BufSize);
  try
    while Count<>0 do
    begin
      if Count>BufSize
        then N:=BufSize
        else N:=Count;
      Source.ReadBuffer(Buffer^, N);
      Result:=NextAdler32(Result, Buffer, N);
      Dec(Count, N);
    end;
  finally
    if Buffer<>nil then FreeMem(Buffer, BufSize);
  end;
end;

end.
