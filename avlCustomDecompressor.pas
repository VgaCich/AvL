unit avlCustomDecompressor;

interface

uses
  Windows, AvL;
  
type
  ECompressError = class(Exception);
  ECompressDataError = class(ECompressError);
  ECompressInternalError = class(ECompressError);

{TCustomDecompressor}

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

{TCustomDecompressor}

constructor TCustomDecompressor.Create(AReadProc: TDecompressorReadProc);
begin
  inherited Create;
  FReadProc := AReadProc;
end;

end.
