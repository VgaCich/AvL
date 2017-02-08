unit avlNRV2EStream;

interface

uses
  AvL, avlUtils, UCLAPI;

const
  NRV2EBlockSize = 65536;

type
  ECompress = class(Exception)
  end;
  TNRV2EStream = class(TStream)
  private
    FData: TStream;
    FSize, FPosition, FBlockIndex: Integer;
    FBlockChanged: Boolean;
    FBlock: array[0 .. NRV2EBlockSize - 1] of Byte;
    FLevel: Integer;
    procedure SetLevel(Value: Integer);
    function BlockSize(Size: Word; Last: Boolean; DataSize: Integer = -1): Integer;
    function BlockIndex(Pos: Integer): Integer;
    procedure FindBlock(Index: Integer);
    function LastBlock(DataSize: Integer = -1): Integer;
    procedure MoveTail(NewBlockSize: Integer);
    procedure ReadBlock(Index: Integer);
    procedure SaveBlock(Index: Integer);
  protected
    function GetSize: Longint; override;
    procedure SetSize(NewSize: Longint); override;
  public
    constructor Create(Data: TStream);
    destructor Destroy; override;
    procedure Flush;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    property CompressionLevel: Integer read FLevel write SetLevel;
  end;

implementation

const
  SNoData = 'Compressed data stream is nil';
  SNoEnoughData = 'Compressed data stream doesn''t contain required block';
  SBlockDecompressionError = 'Block decompression error (%d)';
  SBlockCompressionError = 'Block compression error (%d)';
  NRV2ECompBlockSize = NRV2EBlockSize + NRV2EBlockSize div 8 + 256;

{ TNRV2EStream }

function TNRV2EStream.BlockIndex(Pos: Integer): Integer;
begin
  Result := Pos div NRV2EBlockSize;
end;

function TNRV2EStream.BlockSize(Size: Word; Last: Boolean; DataSize: Integer): Integer;
begin
  if DataSize < 0 then
    DataSize := FSize;
  if Size = 0 then
    if Last then
      Result := (DataSize - 1) mod NRV2EBlockSize + 1
    else
      Result := NRV2EBlockSize
  else
    Result := Size;
end;

constructor TNRV2EStream.Create(Data: TStream);
begin
  inherited Create;
  if not Assigned(Data) then
    raise ECompress.Create(SNoData);
  FLevel := 1;
  FData := Data;
  FData.Position := 0;
  if FData.Size < SizeOf(FSize) then
  begin
    FSize := 0;
    FData.Write(FSize, SizeOf(FSize));
  end
    else FData.ReadBuffer(FSize, SizeOf(FSize));
  ReadBlock(0);
end;

destructor TNRV2EStream.Destroy;
begin
  Flush;
  inherited;
end;

procedure TNRV2EStream.FindBlock(Index: Integer);
var
  Size: Word;
  DataSize, Block, BlockSize: Integer;
begin
  FData.Position := 0;
  if FData.Read(DataSize, SizeOf(DataSize)) <> SizeOf(DataSize) then
    raise ECompress.Create(SNoEnoughData);
  for Block := 0 to Index - 1 do
  begin
    if FData.Read(Size, SizeOf(Size)) < SizeOf(Size) then
      raise ECompress.Create(SNoEnoughData);
    BlockSize := Self.BlockSize(Size, Block = LastBlock(DataSize), DataSize);
    if FData.Size - FData.Position < BlockSize then
      raise ECompress.Create(SNoEnoughData);
    FData.Seek(BlockSize, soFromCurrent);
  end;
end;

procedure TNRV2EStream.Flush;
begin
  if FBlockChanged then
    SaveBlock(FBlockIndex);
end;

function TNRV2EStream.GetSize: Longint;
begin
  Result := FSize;
end;

function TNRV2EStream.LastBlock(DataSize: Integer): Integer;
begin
  if DataSize < 0 then
    DataSize := FSize;
  Result := (DataSize + NRV2EBlockSize - 1) div NRV2EBlockSize - 1;
end;

procedure TNRV2EStream.MoveTail(NewBlockSize: Integer);
var
  Size: Word;
  Delta, MoveSize, BufSize, BlockPos: Integer;
  MovBuffer: array[0 .. NRV2EBlockSize - 1] of Byte;
begin
  BlockPos := FData.Position;
  try
    FData.Read(Size, SizeOf(Size));
    Delta := NewBlockSize - BlockSize(Size, false);
    MoveSize := FData.Size - FData.Position - BlockSize(Size, false);
    if Delta > 0 then
    begin
      FData.Seek(0, soFromEnd);
      while MoveSize > 0 do
      begin
        BufSize := Min(MoveSize, NRV2EBlockSize);
        FData.Seek(-BufSize, soFromCurrent);
        FData.Read(MovBuffer[0], BufSize);
        FData.Seek(Delta - BufSize, soFromCurrent);
        FData.Write(MovBuffer[0], BufSize);
        FData.Seek(-(BufSize + Delta), soFromCurrent);
        Dec(MoveSize, BufSize);
      end;
    end
    else if Delta < 0 then
    begin
      FData.Seek(-MoveSize, soFromEnd);
      while MoveSize > 0 do
      begin
        BufSize := Min(MoveSize, NRV2EBlockSize);
        FData.Read(MovBuffer[0], BufSize);
        FData.Seek(Delta - BufSize, soFromCurrent);
        FData.Write(MovBuffer[0], BufSize);
        FData.Seek(-Delta, soFromCurrent);
        Dec(MoveSize, BufSize);
      end;
      FData.Size := FData.Size + Delta;
    end;
  finally
    FData.Position := BlockPos;
  end;
end;

function TNRV2EStream.Read(var Buffer; Count: Integer): Longint;
var
  Ptr: Pointer;
  BlockSize: Integer;
begin
  Ptr := @Buffer;
  Result := 0;
  while (Count > 0) and (FPosition < FSize) do
  begin
    BlockSize := Min(Min(Count, NRV2EBlockSize - FPosition mod NRV2EBlockSize), FSize - FPosition);
    Move(FBlock[FPosition mod NRV2EBlockSize], Ptr^, BlockSize);
    Ptr := IncPtr(Ptr, BlockSize);
    Dec(Count, BlockSize);
    Inc(Result, BlockSize);
    Inc(FPosition, BlockSize);
    if BlockIndex(FPosition) > FBlockIndex then
      ReadBlock(BlockIndex(FPosition));
  end;
end;

procedure TNRV2EStream.ReadBlock(Index: Integer);
var
  Size: Word;
  DecSize: Cardinal;
  Res: Integer;
  Buffer: array[0 .. NRV2EBlockSize - 1] of Byte;
begin
  if FBlockChanged then
    SaveBlock(FBlockIndex);
  if Index <= LastBlock then
  begin
    FindBlock(Index);
    if FData.Read(Size, SizeOf(Size)) < SizeOf(Size) then
      raise ECompress.Create(SNoEnoughData);
    if FData.Size - FData.Position < BlockSize(Size, Index = LastBlock) then
      raise ECompress.Create(SNoEnoughData);
    DecSize := BlockSize(0, (Index = LastBlock) and (Size = 0));
    if Size > 0 then
    begin
      FData.Read(Buffer[0], Size);
      Res := ucl_nrv2e_decompress_asm_safe_8(@Buffer[0], Size, @FBlock[0], DecSize, nil);
      if (Res <> UCL_E_OK){ or (DecSize <> BlockSize(0, Index = LastBlock))} then
        raise ECompress.CreateFmt(SBlockDecompressionError, [Res]);
      FillChar(FBlock[DecSize], NRV2EBlockSize - DecSize, 0);
    end
      else FData.Read(FBlock[0], DecSize);
  end
    else FillChar(FBlock[0], NRV2EBlockSize, 0);
  FBlockIndex := Index;
  FBlockChanged := false;
end;

procedure TNRV2EStream.SaveBlock(Index: Integer);
var
  Size: Word;
  BlockPos, Delta, MoveSize, BufSize, Res: Integer;
  Buffer: array[0 .. NRV2ECompBlockSize - 1] of Byte;
  MovBuffer: array[0 .. NRV2EBlockSize - 1] of Byte;
  DataSize, EncSize: Cardinal;
begin
  EncSize := NRV2ECompBlockSize;
  DataSize := BlockSize(0, Index = LastBlock);
  Res := ucl_nrv2e_99_compress(@FBlock[0], DataSize, @Buffer[0], EncSize, nil, FLevel, nil, nil);
  if Res <> UCL_E_OK then
    raise ECompress.CreateFmt(SBlockCompressionError, [Res]);
  if EncSize >= DataSize then
  begin
    EncSize := DataSize;
    Size := 0;
    Move(FBlock[0], Buffer[0], EncSize);
  end
    else Size := EncSize;
  FindBlock(Index);
  if Index < LastBlock then
    MoveTail(EncSize);
  FData.Write(Size, SizeOf(Size));
  FData.Write(Buffer[0], EncSize);
  if (Index = LastBlock) and (FData.Size > FData.Position) then
    FData.Size := FData.Position;
  FData.Position := 0;
  FData.Write(FSize, SizeOf(FSize));
  FBlockChanged := false;
end;

function TNRV2EStream.Seek(Offset: Integer; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: FPosition := FPosition + Offset;
    soFromEnd: FPosition := FSize + Offset;
  end;
  FPosition := Max(0, Min(FPosition, FSize));
  if BlockIndex(FPosition) <> FBlockIndex then
    ReadBlock(BlockIndex(FPosition));
  Result := FPosition;
end;

procedure TNRV2EStream.SetLevel(Value: Integer);
begin
  FLevel := Max(1, Min(Value, 10));
end;

procedure TNRV2EStream.SetSize(NewSize: Integer);
var
  Pos, BufSize: Integer;
  Buffer: array[0 .. NRV2EBlockSize - 1] of Byte;
begin
  {TODO: optimize}
  inherited;
  Pos := FPosition;
  Flush;
  if NewSize > FSize then
  begin
    Seek(0, soFromEnd);
    FillChar(Buffer[0], NRV2EBlockSize, 0);
    Dec(NewSize, FSize);
    while NewSize > 0 do
    begin
      BufSize := Min(NewSize, NRV2EBlockSize);
      Write(Buffer[0], BufSize);
      Dec(NewSize, BufSize);
    end;
  end
  else if NewSize < FSize then
  begin
    FSize := NewSize;
    FData.Position := 0;
    FData.Write(FSize, SizeOf(FSize));
    FindBlock(LastBlock + 1);
    FData.Size := FData.Position;
    if FBlockIndex > LastBlock then FBlockChanged := false;
  end;
  Position := Pos;
end;

function TNRV2EStream.Write(const Buffer; Count: Integer): Longint;
var
  Ptr: Pointer;
  BlockSize: Integer;
begin
  Ptr := @Buffer;
  Result := 0;
  while Count > 0 do
  begin
    BlockSize := Min(Count, NRV2EBlockSize - FPosition mod NRV2EBlockSize);
    Move(Ptr^, FBlock[FPosition mod NRV2EBlockSize], BlockSize);
    Ptr := IncPtr(Ptr, BlockSize);
    Dec(Count, BlockSize);
    Inc(Result, BlockSize);
    Inc(FPosition, BlockSize);
    FSize := Max(FSize, FPosition);
    if BlockIndex(FPosition) > FBlockIndex then
    begin
      SaveBlock(FBlockIndex);
      ReadBlock(BlockIndex(FPosition));
    end;
  end;
  FBlockChanged := true;
end;

end.