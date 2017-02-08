unit avlCompress;

{
  Inno Setup
  Copyright (C) 1997-2004 Jordan Russell
  Portions by Martijn Laan
  For conditions of distribution and use, see LICENSE.TXT.

  Abstract compression classes, and some generic compression-related functions

  $jrsoftware: issrc/Projects/Compress.pas,v 1.6 2004/02/28 02:16:16 jr Exp $
}

interface

uses
  AVL;

type
  ECompressError = class(Exception);
  ECompressDataError = class(ECompressError);
  ECompressInternalError = class(ECompressError);

  TCompressorProgressProc = procedure(BytesProcessed: Cardinal) of object;
  TCompressorWriteProc = procedure(const Buffer; Count: Longint) of object;
  TCustomCompressorClass = class of TCustomCompressor;
  TCustomCompressor = class
  private
    FProgressProc: TCompressorProgressProc;
    FWriteProc: TCompressorWriteProc;
  protected
    property ProgressProc: TCompressorProgressProc read FProgressProc;
    property WriteProc: TCompressorWriteProc read FWriteProc;
  public
    constructor Create(AWriteProc: TCompressorWriteProc;
      AProgressProc: TCompressorProgressProc; CompressionLevel: Integer); virtual;
    procedure Compress(const Buffer; Count: Longint); virtual; abstract;
    procedure Finish; virtual; abstract;
  end;

  TDecompressorReadProc = function(var Buffer; Count: Longint): Longint of object;
  TCustomDecompressorClass = class of TCustomDecompressor;
  TCustomDecompressor = class
  private
    FReadProc: TDecompressorReadProc;
  protected
    property ReadProc: TDecompressorReadProc read FReadProc;
  public
    constructor Create(AReadProc: TDecompressorReadProc); virtual;
    procedure DecompressInto(var Buffer; Count: Longint); virtual; abstract;
    procedure Reset; virtual; abstract;
  end;

implementation

{ TCustomCompressor }

constructor TCustomCompressor.Create(AWriteProc: TCompressorWriteProc;
  AProgressProc: TCompressorProgressProc; CompressionLevel: Integer);
begin
  inherited Create;
  FWriteProc := AWriteProc;
  FProgressProc := AProgressProc;
end;

{ TCustomDecompressor }

constructor TCustomDecompressor.Create(AReadProc: TDecompressorReadProc);
begin
  inherited Create;
  FReadProc := AReadProc;
end;

end.
