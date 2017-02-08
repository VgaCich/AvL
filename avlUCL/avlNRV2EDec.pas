{(c)VgaSoft, 2004}
unit avlNRV2EDec;

interface

uses
  Windows, AvL, avlUtils, avlCustomDecompressor, UCLAPI;

type
  TNRV2EDecompressor=class(TCustomDecompressor)
    FBuffer, FInBuffer: Pointer;
    FBufSize, FInBufSize, FBufPos: Cardinal;
  private
    procedure DecompressNext;
  public
    constructor Create(AReadProc: TDecompressorReadProc); override;
    destructor Destroy; override;
    procedure DecompressInto(var Buffer; Count: Longint); override;
    procedure Reset; override;
  end;

implementation

const
  CBufSize=1048576;
  UCLDataError='NRV2E: Compressed data is corrupted';

constructor TNRV2EDecompressor.Create(AReadProc: TDecompressorReadProc);
begin
  inherited Create(AReadProc);
  GetMem(FBuffer, CBufSize+3);
  FInBufSize:=UCLOutputBlockSize(CBufSize);
  GetMem(FInBuffer, FInBufSize);
  DecompressNext;
end;

destructor TNRV2EDecompressor.Destroy;
begin
  FreeMemAndNil(FBuffer, CBufSize+3);
  FreeMemAndNil(FInBuffer, UCLOutputBlockSize(CBufSize));
end;

procedure TNRV2EDecompressor.DecompressInto(var Buffer; Count: longint);
var
  BufPos, IncSize: integer;
begin
  BufPos:=0;
  while (FBufSize-FBufPos)<Count do
  begin
    IncSize:=FBufSize-FBufPos;
    CopyMemory(IncPtr(@Buffer, BufPos), IncPtr(FBuffer, FBufPos), IncSize);
    try
      DecompressNext;
    except
      raise;
      Exit;
    end;
    Inc(BufPos, IncSize);
    Dec(Count, IncSize);
  end;
  CopyMemory(IncPtr(@Buffer, BufPos), IncPtr(FBuffer, FBufPos), Count);
  Inc(FBufPos, Count);
end;

procedure TNRV2EDecompressor.DecompressNext;
begin
  FBufSize:=CBufSize;
  if (ReadProc(FInBufSize, SizeOf(FInBufSize))<>SizeOf(FInBufSize)) or
     (ReadProc(FInBuffer^, FInBufSize)<>FInBufSize) or
     (ucl_nrv2e_decompress_asm_safe_8(FInBuffer, FInBufSize, FBuffer, FBufSize, nil)<>UCL_E_OK)
    then raise ECompressError.Create(UCLDataError);
  FBufPos:=0;
end;

procedure TNRV2EDecompressor.Reset;
begin
  DecompressNext;
end;

end.
