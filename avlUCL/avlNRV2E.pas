{(c)VgaSoft, 2004}
unit avlNRV2E;

interface

uses
  Windows, AvL, avlCompress, avlUtils, UCLAPI;

type
  TNRV2ECompressor=class(TCustomCompressor)
    FBuffer, FOutBuffer: Pointer;
    FBufSize, FOutBufSize, FBufPos: Cardinal;
    FCallback: TUCLProgressCallback;
    FCompressionLevel: integer;
  private
    procedure CompressBuffer;
  public
    constructor Create(AWriteProc: TCompressorWriteProc;
      AProgressProc: TCompressorProgressProc; CompressionLevel: Integer); override;
    destructor Destroy; override;
    procedure Compress(const Buffer; Count: Longint); override;
    procedure Finish; override;
  end;

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

//var
//  i: integer = 0;

const
  CBufSize=1048576;
  UCLDataError='NRV2E: Compressed data is corrupted';

{TNRV2ECompressor}

procedure Callback(TextSize, CodeSize: Cardinal; State: Integer; User: Pointer);
begin
  if Assigned(TNRV2ECompressor(User).ProgressProc)
    then TNRV2ECompressor(User).ProgressProc(CodeSize);
end;

constructor TNRV2ECompressor.Create(AWriteProc: TCompressorWriteProc;
      AProgressProc: TCompressorProgressProc; CompressionLevel: Integer);
begin
  inherited Create(AWriteProc, AProgressProc, CompressionLevel);
  FCompressionLevel:=CompressionLevel;
  GetMem(FBuffer, CBufSize);
  FBufSize:=CBufSize;
  FOutBufSize:=UCLOutputBlockSize(CBufSize);
  GetMem(FOutBuffer, FOutBufSize);
  FBufPos:=0;
  FCallback.Callback:=Callback;
  FCallback.User:=Self;
end;

destructor TNRV2ECompressor.Destroy;
begin
  if FBufPos<>0 then Finish;
  FreeMemAndNil(FBuffer, CBufSize);
  FreeMemAndNil(FOutBuffer, UCLOutputBlockSize(CBufSize));
end;

procedure TNRV2ECompressor.CompressBuffer;
var
  Res: integer;
begin
  if FBufSize=0 then Exit;
  FOutBufSize:=UCLOutputBlockSize(FBufSize);
  Res:=ucl_nrv2e_99_compress(FBuffer, FBufSize, FOutBuffer, FOutBufSize, @FCallback,
                             FCompressionLevel, nil, nil);
  if (Res<>UCL_E_OK) then
    begin
      raise ECompressError.CreateFmt('NRV2E: cannot compress block (%d)', [Res]);
      Exit;
    end;
  WriteProc(FOutBufSize, SizeOf(FOutBufSize));
  WriteProc(FOutBuffer^, FOutBufSize);
  FBufPos:=0;
end;

procedure TNRV2ECompressor.Compress(const Buffer; Count: longint);
var
  BufPos, IncSize: Cardinal;
begin
  BufPos:=0;
  while (FBufSize-FBufPos)<Count do
  begin
    IncSize:=FBufSize-FBufPos;
    CopyMemory(IncPtr(FBuffer, FBufPos), IncPtr(@Buffer, BufPos), IncSize);
    try
      CompressBuffer;
    except
      raise;
      Exit;
    end;
    Inc(BufPos, IncSize);
    Dec(Count, IncSize);
  end;
  CopyMemory(IncPtr(FBuffer, FBufPos), IncPtr(@Buffer, BufPos), Count);
  Inc(FBufPos, Count);
end;

procedure TNRV2ECompressor.Finish;
begin
  FBufSize:=FBufPos;
  CompressBuffer;
  FBufSize:=CBufSize;
end;

{TNRV2EDecompressor}

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
