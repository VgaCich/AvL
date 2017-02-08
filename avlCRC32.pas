unit avlCRC32;

interface

uses AvL, avlUtils;

function CRC32Next(CRC32Current: LongWord; const Data; Count: LongWord): LongWord;
function CRC32Done(CRC32: LongWord): LongWord; register;
function CRC32Initialization: Pointer;
function StreamCRC32(Source: TStream; Count: Longint): LongWord;

const
  CRC32Init: LongWord = $FFFFFFFF;

implementation

const
  CRC32Polynomial = $EDB88320;
  IcsPlusIoPageSize=65535;

var
  CRC32Table: array [Byte] of Cardinal;


function CRC32Next(CRC32Current: LongWord; const Data; Count: LongWord): LongWord; register;
asm
//@@file://EAX - CRC32Current; EDX - Data; ECX - Count
  test  ecx, ecx
  jz    @@EXIT
  PUSH  ESI
  MOV   ESI, EDX//  file://Data

@@Loop:
    MOV EDX, EAX                       // copy CRC into EDX
    LODSB                              // load next byte into AL
    XOR EDX, EAX                       // put array index into DL
    SHR EAX, 8                         // shift CRC one byte right
    SHL EDX, 2                         // correct EDX (*4 - index in array)
    XOR EAX, DWORD PTR CRC32Table[EDX] // calculate next CRC value
  dec   ECX
  JNZ   @@Loop                         // LOOP @@Loop
  POP   ESI
@@EXIT:
end;//Crc32Next

function CRC32Done(CRC32: LongWord): LongWord; register;
asm
  NOT   EAX
end;//Crc32Done

function CRC32Initialization: Pointer;
asm
  push    EDI
  STD
  mov     edi, OFFSET CRC32Table+ ($400-4)  // Last DWORD of the array
  mov     edx, $FF  // array size

@im0:
  mov     eax, edx  // array index
  mov     ecx, 8
@im1:
  shr     eax, 1
  jnc     @Bit0
  xor     eax, CRC32Polynomial  // <магическое> число - тоже что у ZIP,ARJ,RAR,:
@Bit0:
  dec     ECX
  jnz     @im1

  stosd
  dec     edx
  jns     @im0

  CLD
  pop     EDI
  mov     eax, OFFSET CRC32Table
end;//Crc32Initialization

function StreamCRC32(Source: TStream; Count: Longint): LongWord;
var
  BufSize, N: Integer;
  Buffer: PChar;
begin
  Result:=CRC32Init;
  Buffer:=nil;
  if Count = 0 then begin
    Source.Position:= 0;
    Count:= Source.Size;
  end;     
  if Count>IcsPlusIoPageSize then BufSize:=IcsPlusIoPageSize else BufSize:=Count;
  GetMem(Pointer(Buffer), BufSize);
  try
    while Count <> 0 do begin
      if Count > BufSize then N := BufSize else N := Count;
      Source.ReadBuffer(Buffer^, N);
      Result:=CRC32Next(Result,Buffer^,N);
      Dec(Count, N);
    end;
  finally
    Result:=CRC32Done(Result);
    FreeMemAndNil(Pointer(Buffer), BufSize);
  end;
end;

end.
