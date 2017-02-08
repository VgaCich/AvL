{ ------------------------------------------------------------------------------
  (c)VgaSoft,2004

  UCL is Copyright (c) 1996-2002 Markus Franz Xaver Johannes Oberhumer
  All Rights Reserved.

  Markus F.X.J. Oberhumer
  <markus@oberhumer.com>
  http://www.oberhumer.com/opensource/ucl/

------------------------------------------------------------------------------ }

unit UCLAPI;

interface

const
  { Error codes for the compression/decompression functions. Negative
    values are errors, positive values will be used for special but
    normal events. }
  { }
  UCL_E_OK = 0;
  UCL_E_ERROR = -1;
  UCL_E_INVALID_ARGUMENT = -2;
  UCL_E_OUT_OF_MEMORY = -3;
  //* compression errors */
  { }
  UCL_E_NOT_COMPRESSIBLE = -101;
  //* decompression errors */
  { }
  UCL_E_INPUT_OVERRUN = -201;
  UCL_E_OUTPUT_OVERRUN = -202;
  UCL_E_LOOKBEHIND_OVERRUN = -203;
  UCL_E_EOF_NOT_FOUND = -204;
  UCL_E_INPUT_NOT_CONSUMED = -205;
  UCL_E_OVERLAP_OVERRUN = -206;

type
  PCardinal = ^Cardinal;

  PUCLProgressCallback = ^TUCLProgressCallback;
  TUCLProgressCallback = record
    Callback: procedure(TextSize, CodeSize: Cardinal; State: Integer; User: Pointer);
    User: Pointer;
  end;

  PUCLCompressConfig = ^TUCLCompressConfig;
  TUCLCompressConfig = record
    bb_endian: Integer;
    bb_size: Integer;
    max_offset: Cardinal;
    max_match: Cardinal;
    s_level: Integer;
    h_level: Integer;
    p_level: Integer;
    c_flags: Integer;
    m_size: Cardinal;
  end;

{ Calculates the worst-case data expansion for non-compressible data. }
function UCLOutputBlockSize(const InputBlockSize: Cardinal): Cardinal;

{ Compresses a block of data. }
function ucl_nrv2e_99_compress(
  const InBlock: Pointer;
  InSize: Cardinal;
  OutBlock: Pointer;
  var OutSize: Cardinal;
  CB: PUCLProgressCallback;
  Level: Integer;
  const Conf: PUCLCompressConfig;
  Result: PCardinal): Integer;

{ Decompresses a block of data }

function ucl_nrv2e_decompress_asm_safe_8(
  const Src: Pointer;
  src_len: Cardinal;
  dst: Pointer;
  var dst_len: Cardinal;
  wrkmem: Pointer): Integer; cdecl;

implementation

function UCLOutputBlockSize(const InputBlockSize: Cardinal): Cardinal;
begin
  Result := InputBlockSize + InputBlockSize div 8 + 256;
end;

function _malloc(const Size: Cardinal): Pointer; cdecl;
begin
  GetMem(Result, Size);
end;

procedure _free(const p: Pointer); cdecl;
begin
  FreeMem(p);
end;

function _memcpy(Dest: Pointer; const Src: Pointer; n: Cardinal): Pointer; cdecl;
begin
  Result := Dest;
  Move(Src^, Result^, n);
end;

function _memset(const Source: Pointer; const Value: Integer; const Count: Cardinal): Pointer; cdecl;
begin
  Result := Source;
  FillChar(Result^, Count, Value);
end;

{$L n2e_99.obj}
{$L n2e_d_n4.obj}
{$L alloc.obj}

function ucl_nrv2e_99_compress; external;

function ucl_nrv2e_decompress_asm_safe_8; external;

end.



