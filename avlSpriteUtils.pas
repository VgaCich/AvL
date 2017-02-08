unit avlSpriteUtils;


interface


uses windows, AvL;


procedure GenerateOpacityTable( var p:pointer; Opacity:double);
procedure TransPaint24bpp( pb1,pb2: tbitmap; OpacityTable: pointer);

procedure FPTransPaint24bpp( pb1,pb2: tbitmap; Opacity: double);

procedure MMXTransPaint32bpp( pb1,pb2: tbitmap; Opacity: double);
procedure MMXTransPaint24bpp( pb1,pb2: tbitmap; Opacity: double);

procedure TransPut8bpp( p1,p2: tbitmap; TransColor: integer);
procedure TransPut16bpp( p1,p2: tbitmap; TransColor: integer);
procedure TransPut24bpp( p1,p2: tbitmap; TransColor: integer);
procedure TransPut32bpp( p1,p2: tbitmap; TransColor: integer);

procedure MMXTransPut8bpp( p1,p2: tbitmap; TransColor: integer);
procedure MMXTransPut16bpp( p1,p2: tbitmap; TransColor: integer);

procedure MMXMaskPut( pb1,pb2: tbitmap; x,y: integer; TransColor: integer);
procedure MMXMaskPut8bpp( p1,p2: tbitmap; TransColor: integer);
procedure MMXMaskPut16bpp( p1,p2: tbitmap; TransColor: integer);

procedure MaskPut8bpp( p1,p2: tbitmap; TransColor: integer);
procedure MaskPut16bpp( p1,p2: tbitmap; TransColor: integer);
procedure MaskPut24bpp( p1,p2: tbitmap; TransColor: integer);
procedure MaskPut32bpp( p1,p2: tbitmap; TransColor: integer);

procedure TransPut( pb1,pb2: tbitmap; x,y: integer; TransColor: integer);
procedure MMXTransPut( pb1,pb2: tbitmap; x,y: integer; TransColor: integer);
procedure MaskPut( pb1,pb2: tbitmap; x,y: integer; TransColor: integer);

procedure TransPaint( pb1,pb2: tbitmap; x,y: integer; OpacityTable: pointer);
procedure FPTransPaint( pb1,pb2: tbitmap; x,y: integer; Opacity: double);
procedure MMXTransPaint( pb1,pb2: tbitmap; x,y: integer; Opacity: double);

procedure MMXSpritePut( pb1,pb2: tbitmap; x,y,transcolor: integer; Opacity: double);
procedure SpritePut( pb1,pb2: tbitmap; x,y,transcolor: integer; OpacityTable: pointer);

procedure Put( pb1,pb2: tbitmap; x,y: integer);
procedure Get( pb1,pb2: tbitmap; x,y: integer);

function NewBitmapEx( W, H: Integer; BPP: TPixelFormat ): tbitmap;
function Color2Color16( Color: TColor ): WORD;


var
  PutMode: ( pmNormal, pmHFlip, pmVFlip, pmHVFlip);


implementation

function Color2RGB( Color: TColor ): TColor;
begin
  if Color < 0 then
    Result := GetSysColor(Color and $FF) else
    Result := Color;
end;

function Color2Color16( Color: TColor ): WORD;
begin
  Color := Color2RGB( Color );
  Result := (Color shr 19) and $1F or
            (Color shr 5) and $7E0 or
            (Color shl 8) and $F800;
end;

procedure GenerateOpacityTable;
var
  i: integer;
  pp: ^byte;
begin
  getmem( p, 256);
  pp:= p;
  for i:= 0 to 255 do
    begin
      byte( pp^):= lo( trunc( i*Opacity));
      inc( cardinal( pp));
    end;
end;


procedure TransPaint;
var
  p1, p2: pointer;
  x0, xFrom, xTo, dx, sx, YFrom, YTo, dy, sy, i: integer;
begin
{  if not ((pb1.PixelFormat=pf24bit) or (pb1.PixelFormat=pf32bit)) or
    not ((pb2.PixelFormat=pf24bit) or (pb2.PixelFormat=pf32bit)) then
     raise Exception.Create( e_Custom, 'This bitmap format is not supported!');
  if not (pb1.PixelFormat=pb2.PixelFormat) then
    raise Exception.Create( e_Custom, 'Bitmap formats should be identical!');}

  dx:= 0;
  dy:= 0;
  x0:= 0;
  sx:= pb2.Width;
  sy:= pb2.Height;
  YFrom:= y;
  YTo:= y+pb2.Height-1;
  XFrom:= x;
  XTo:= x+pb2.Width-1;
  if (YFrom>pb1.Height-1) or (XFrom>pb1.Width-1)
   or (YTo<0) or (XTo<0)
    then exit;

  if XFrom<0 then
    begin
      dx:= -XFrom;
      sx:= sx+XFrom;
      inc( x0, -XFrom);
      XFrom:= 0;
    end;

  if YFrom<0 then
    begin
      dy:= -YFrom;
      sy:= sy+YFrom;
      YFrom:= 0;
    end;

  if XTo>=pb1.Width then
    dec( sx, XTo-pb1.Width+1);

  if YTo>=pb1.Height then
    dec( sy, YTo-pb1.Height+1);

  if pb1.PixelFormat=pf24bit then
    for i:=0 to sy-1 do
      begin
        p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*3);
        p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*3);
        asm
          push  ebx
          push  edi
          push  esi
          mov   edi, p1
          mov   ebx, OpacityTable
          mov   ecx, sx
          mov   eax, ecx
          mov   esi, p2
          add   ecx, ecx
          add   ecx, eax
        @loop:
          xor   dl, dl
          lodsb
          sub   al, [edi]
          sbb   dl, ah

          xlatb
          xchg   dl, al
          xlatb

          add   [edi], dl
          sub   [edi], al

          inc   edi

          loop  @loop

          pop   esi
          pop   edi
          pop   ebx
        end;
      end
  else
    for i:=0 to sy-1 do
      begin
        p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*4);
        p2:= pointer( cardinal( pb2.ScanLine[dy+i])+x0*4);
        asm
          push  ebx
          push  edi
          push  esi
          mov   edi, p1
          mov   ebx, OpacityTable
          mov   ecx, sx
          mov   esi, p2
          shl   ecx, 2
        @loop:
          xor   ah, ah
          lodsb
          sub   al, [edi]
          sbb   ah, ah
          xlatb
          xchg   ah, al
          xlatb
          add   [edi], ah
          sub   [edi], al
          inc   edi
          loop  @loop

          mov   ecx, sx
          mov   esi, p2
          mov   edi, esi
          mov   edx, $00FFFFFF
          shr   ecx, 2
        @loop2: // занулить старшие байты в пикселах
          lodsd
          and   eax, edx
          stosd
          loop  @loop2

          pop   esi
          pop   edi
          pop   ebx
        end;
      end;
end;

procedure FPTransPaint;
var
  p1, p2: pointer;
  x0, xFrom, xTo, dx, sx, YFrom, YTo, dy, sy, i, j0: integer;
begin
{  if not ((pb1.PixelFormat=pf24bit) or (pb1.PixelFormat=pf32bit)) or
    not ((pb2.PixelFormat=pf24bit) or (pb2.PixelFormat=pf32bit)) then
     raise Exception.Create( e_Custom, 'This bitmap format is not supported!');
  if not (pb1.PixelFormat=pb2.PixelFormat) then
    raise Exception.Create( e_Custom, 'Bitmap formats should be identical!');}

  dx:= 0;
  dy:= 0;
  x0:= 0;
  sx:= pb2.Width;
  sy:= pb2.Height;
  YFrom:= y;
  YTo:= y+pb2.Height-1;
  XFrom:= x;
  XTo:= x+pb2.Width-1;
  if (YFrom>pb1.Height-1) or (XFrom>pb1.Width-1)
   or (YTo<0) or (XTo<0)
    then exit;

  if XFrom<0 then
    begin
      dx:= -XFrom;
      sx:= sx+XFrom;
      inc( x0, -XFrom);
      XFrom:= 0;
    end;

  if YFrom<0 then
    begin
      dy:= -YFrom;
      sy:= sy+YFrom;
      YFrom:= 0;
    end;

  if XTo>=pb1.Width then
    dec( sx, XTo-pb1.Width+1);

  if YTo>=pb1.Height then
    dec( sy, YTo-pb1.Height+1);

  if pb1.PixelFormat=pf24bit then
    for i:=0 to sy-1 do
      begin
        p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*3);
        p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*3);
        asm
          push      edi
          push      esi

          mov       esi, p2
          mov       edi, p1
          mov       ecx, sx

          xor       eax, eax
          mov       edx, ecx
          mov       [j0], eax
          add       ecx, ecx
          mov       [j0], eax
          add       ecx, edx

          // X*(1-Op)+Y*Op = X - X*Op + Y*Op = X + (Y-X)*Op

        @loop:
          fld       [Opacity]        // Op, -
          lodsb
          mov       byte ptr [j0], al
          fild      [j0]             // Y, Op, -

          mov       al, [edi]
          mov       byte ptr [j0], al
          fild      [j0]             // X, Y, Op,-
          fst       st(3)            // X, Y, Op, X, -

          fsubp                      // Y-X, Op, X, -
          fmulp                      // (Y-X)*Op, X, -
          faddp                      // X + (Y-X)*Op, -

          fistp     [j0]             // -

          mov       al, byte ptr [j0]
          stosb
          loop      @loop

          pop       esi
          pop       edi
        end;
      end
  else
    for i:=0 to sy-1 do
      begin
        p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*4);
        p2:= pointer( cardinal( pb2.ScanLine[dy+i])+x0*4);
        asm
          push      edi
          push      esi

          mov       esi, p2
          mov       edi, p1
          mov       ecx, sx

          xor       eax, eax
          mov       [j0], eax
          shl       ecx, 2

          // X*(1-Op)+Y*Op = X - X*Op + Y*Op = X + (Y-X)*Op

        @loop:
          fld       [Opacity]        // Op, -
          lodsb
          mov       byte ptr [j0], al
          fild      [j0]             // Y, Op, -

          mov       al, [edi]
          mov       byte ptr [j0], al
          fild      [j0]            // X, Y, Op,-
          fst       st(3)            // X, Y, Op, X, -

          fsubp                      // Y-X, Op, X, -
          fmulp                      // (Y-X)*Op, X, -
          faddp                      // X + (Y-X)*Op, -

          fistp     [j0]             // -

          mov       al, byte ptr [j0]
          stosb
          loop      @loop

          pop       esi
          pop       edi
        end;
      end;
end;

procedure MMXTransPaint;
var
  p1, p2: pointer;
  _op, op, x0, xFrom, xTo, dx, sx, YFrom, YTo, dy, sy, i, size: integer;
begin
{  if not ((pb1.PixelFormat=pf24bit) or (pb1.PixelFormat=pf32bit)) or
    not ((pb2.PixelFormat=pf24bit) or (pb2.PixelFormat=pf32bit)) then
     raise Exception.Create( e_Custom, 'This bitmap format is not supported!');
  if not (pb1.PixelFormat=pb2.PixelFormat) then
    raise Exception.Create( e_Custom, 'Bitmap formats should be identical!');}

  dx:= 0;
  dy:= 0;
  x0:= 0;
  sx:= pb2.Width;
  sy:= pb2.Height;
  YFrom:= y;
  YTo:= y+pb2.Height-1;
  XFrom:= x;
  XTo:= x+pb2.Width-1;
  if (YFrom>pb1.Height-1) or (XFrom>pb1.Width-1)
   or (YTo<0) or (XTo<0)
    then exit;

  if XFrom<0 then
    begin
      dx:= -XFrom;
      sx:= sx+XFrom;
      inc( x0, -XFrom);
      XFrom:= 0;
    end;

  if YFrom<0 then
    begin
      dy:= -YFrom;
      sy:= sy+YFrom;
      YFrom:= 0;
    end;

  if XTo>=pb1.Width then
    dec( sx, XTo-pb1.Width+1);

  if YTo>=pb1.Height then
    dec( sy, YTo-pb1.Height+1);

  op:= lo(trunc(opacity*255));
  if op<2 then
    exit;
  if op>253 then
    begin
      Put( pb1, pb2, x, y);
      exit;
    end;
  _op:= 255-op;

  if pb1.PixelFormat=pf24bit then
    for i:=0 to sy-1 do
      begin
        p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*3);
        p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*3);
        size:= sx*3 div 4;
        asm
          push      edi
          push      esi

          mov       esi, p2
          mov       edi, p1
          mov       ecx, size
          pxor      mm7, mm7    // mm7 = 0
          mov       eax, op
          push      ax
          push      ax
          push      ax
          push      ax
          movq      mm6, [esp]  // mm6 - прямые множители прозрачности

          mov       eax, $00FF00FF
          mov       edx, 4      // инкремент указателей
          push      eax
          push      eax
          movq      mm5, [esp]  // mm5 - $00FF00FF00FF00FF

          mov       eax, _op
          push      ax
          push      ax
          push      ax
          push      ax
          movq      mm3, [esp]  // mm3 - обратные множители (коэффициенты) прозрачности

          // X*(1-Op)+Y*Op = X - X*Op + Y*Op = X + (Y-X)*Op
        @loop:
          movd      mm0, [esi]  // взять источник
          movd      mm1, [edi]  // взять приемник
          punpcklbw mm0, mm7    // распаковать младшие байты (мл.половины) в слова
          punpcklbw mm1, mm7    // распаковать младшие байты (мл.половины) в слова

          pmullw    mm0, mm6
          pmullw    mm1, mm3
          paddw     mm0, mm1
          psrlq     mm0, 8

          pand      mm0, mm5    // обрезать лишние разряды
          packuswb  mm0, mm7    // упаковать перед записью на место

          movd      eax, mm0    // записать результат
          stosd

          add       esi, edx
          loop      @loop

          add       esp, 24
          emms
          pop       esi
          pop       edi
        end;
      end
  else
    for i:=0 to sy-1 do
      begin
        p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*4);
        p2:= pointer( cardinal( pb2.ScanLine[dy+i])+x0*4);
        asm
          push      edi
          push      esi

          mov       esi, p2
          mov       edi, p1
          mov       ecx, sx
          pxor      mm7, mm7    // mm7 = 0

          mov       eax, op
          push      ax
          push      ax
          push      ax
          push      ax
          movq      mm6, [esp]  // mm6 - прямые множители (коэффициенты) прозрачности

          mov       eax, $00FF00FF
          mov       edx, 4      // инкремент указателей
          push      eax
          push      eax
          movq      mm5, [esp]  // mm5 - $00FF00FF00FF00FF

          mov       eax, _op
          push      ax
          push      ax
          push      ax
          push      ax
          movq      mm3, [esp]  // mm3 - обратные множители (коэффициенты) прозрачности

          // X*(1-Op)+Y*Op = X - X*Op + Y*Op = X + (Y-X)*Op
        @loop:
          movd      mm0, [esi]  // взять источник
          movd      mm1, [edi]  // взять приемник
          punpcklbw mm0, mm7    // распаковать младшие байты (мл.половины) источника
          punpcklbw mm1, mm7    // распаковать младшие байты (мл.половины) приемника

          pmullw    mm0, mm6
          pmullw    mm1, mm3
          paddw     mm0, mm1
          psrlq     mm0, 8

          pand      mm0, mm5    // обрезать лишние разряды
          packuswb  mm0, mm7    // упаковать перед записью на место
          movd      eax, mm0    // записать результат
          stosd
          add       esi, edx
          loop      @loop

          add       esp, 24
          emms
          pop       esi
          pop       edi
        end;
      end;
end;

procedure TransPaint24bpp;
var
  p1, p2: pointer;
  size: integer;
begin
  p1:= pb1.ScanLine[pb1.Height-1];
  p2:= pb2.ScanLine[pb1.Height-1];
  size:= ( pb1.Width+1)*pb1.Height;
  asm
    push  ebx
    push  edi
    push  esi
    mov   edi, p1
    mov   ebx, OpacityTable
    mov   ecx, size
    mov   eax, ecx
    mov   esi, p2
    add   ecx, ecx
    add   ecx, eax
  @loop:
    xor   dh, dh
    lodsb
    sub   al, [edi]
    sbb   dh, dh
    xlatb
    xchg   dh, al
    xlatb
    add   [edi], dh
    sub   [edi], al
    inc   edi
    loop  @loop

    pop   esi
    pop   edi
    pop   ebx
  end;
end;

procedure TransPut;
var
  p1, p2: pointer;
  xFrom, xTo, dx, sx, YFrom, YTo, dy, sy, i: integer;
begin
{  if not (pb1.PixelFormat=pb2.PixelFormat) then
    raise Exception.Create( e_Custom, 'Bitmap formats should be identical!');}

  dx:= 0;
  dy:= 0;
  sx:= pb2.Width;
  sy:= pb2.Height;
  YFrom:= y;
  YTo:= y+pb2.Height-1;
  XFrom:= x;
  XTo:= x+pb2.Width-1;
  if (YFrom>pb1.Height-1) or (XFrom>pb1.Width-1)
   or (YTo<0) or (XTo<0)
    then exit;

  if XFrom<0 then
    begin
      dx:= -XFrom;
      sx:= sx+XFrom;
      XFrom:= 0;
    end;

  if YFrom<0 then
    begin
      dy:= -YFrom;
      sy:= sy+YFrom;
      YFrom:= 0;
    end;

  if XTo>=pb1.Width then
    dec( sx, XTo-pb1.Width+1);

  if YTo>=pb1.Height then
    dec( sy, YTo-pb1.Height+1);

  case pb1.PixelFormat of
    pf8bit:
      for i:=0 to sy-1 do
        begin
          p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom);
          p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx);
          asm
            push  edi
            push  esi
            mov   edx, TransColor
            mov   edi, p1
            mov   ecx, sx
            mov   esi, p2
          @loop:
            lodsb
            cmp   al, dl
            jz    @next
            stosb
            loop  @loop
            jmp   @end
          @next:
            inc   edi
            loop  @loop
          @end:
            pop   esi
            pop   edi
          end;
       end;
    pf16bit:
      for i:=0 to sy-1 do
        begin
          p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*2);
          p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*2);
          asm
            push  edi
            push  esi
            mov   edx, TransColor
            mov   edi, p1
            mov   ecx, sx
            mov   esi, p2
          @loop:
            lodsw
            cmp   ax, dx
            jz    @next
            stosw
            loop  @loop
            jmp   @end
          @next:
            inc   edi
            inc   edi
            loop  @loop
          @end:
            pop   esi
            pop   edi
          end;
       end;
    pf24bit:
      for i:=0 to sy-1 do
        begin
          p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*3);
          p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*3);
          asm
            push  ebx
            push  edi
            push  esi
            mov   ebx, TransColor
            mov   edx, $FFFFFF
            mov   edi, p1
            rol   ebx, 16
            mov   ecx, sx
            mov   esi, p2
            and   ebx, edx
          @loop:
            lodsd
            and   eax, edx
            dec   esi
            cmp   eax, ebx
            jz    @next
            stosw
            shr   eax, 16
            stosb
            loop  @loop
            jmp   @end
          @next:
            add   edi, 3
            loop  @loop
          @end:
            pop   esi
            pop   edi
            pop   ebx
          end;
       end;
    pf32bit:
      for i:=0 to sy-1 do
        begin
          p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*4);
          p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*4);
          asm
            push  ebx
            push  edi
            push  esi
            mov   ebx, TransColor
            mov   edi, p1
            rol   ebx, 16
            mov   edx, $FFFFFF
            mov   ecx, sx
            and   ebx, edx
            mov   esi, p2
          @loop:
            lodsd
            and   eax, edx
            cmp   eax, ebx
            jz    @next
            stosd
            loop  @loop
            jmp   @end
          @next:
            add   edi, 4
            loop  @loop
          @end:
            pop   esi
            pop   edi
            pop   ebx
          end;
       end;
  end;
end;

procedure MaskPut;
var
  p1, p2: pointer;
  xFrom, xTo, dx, sx, YFrom, YTo, dy, sy, i: integer;
begin
{  if not (pb1.PixelFormat=pb2.PixelFormat) then
    raise Exception.Create( e_Custom, 'Bitmap formats should be identical!');}

  dx:= 0;
  dy:= 0;
  sx:= pb2.Width;
  sy:= pb2.Height;
  YFrom:= y;
  YTo:= y+pb2.Height-1;
  XFrom:= x;
  XTo:= x+pb2.Width-1;
  if (YFrom>pb1.Height-1) or (XFrom>pb1.Width-1)
   or (YTo<0) or (XTo<0)
    then exit;

  if XFrom<0 then
    begin
      dx:= -XFrom;
      sx:= sx+XFrom;
      XFrom:= 0;
    end;

  if YFrom<0 then
    begin
      dy:= -YFrom;
      sy:= sy+YFrom;
      YFrom:= 0;
    end;

  if XTo>=pb1.Width then
    dec( sx, XTo-pb1.Width+1);

  if YTo>=pb1.Height then
    dec( sy, YTo-pb1.Height+1);

  case pb1.PixelFormat of
    pf8bit:
      for i:=0 to sy-1 do
        begin
          p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom);
          p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx);
          asm
            push  edi
            push  esi
            mov   edx, TransColor
            mov   edi, p1
            mov   ecx, sx
            mov   esi, p2
          @loop:
            lodsb
            cmp   al, dl
            jnz    @next
            stosb
            loop  @loop
            jmp   @end
          @next:
            inc   edi
            loop  @loop
          @end:
            pop   esi
            pop   edi
          end;
       end;
    pf16bit:
      for i:=0 to sy-1 do
        begin
          p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*2);
          p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*2);
          asm
            push  edi
            push  esi
            mov   edx, TransColor
            mov   edi, p1
            mov   ecx, sx
            mov   esi, p2
          @loop:
            lodsw
            cmp   ax, dx
            jnz    @next
            stosw
            loop  @loop
            jmp   @end
          @next:
            inc   edi
            inc   edi
            loop  @loop
          @end:
            pop   esi
            pop   edi
          end;
       end;
    pf24bit:
      for i:=0 to sy-1 do
        begin
          p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*3);
          p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*3);
          asm
            push  ebx
            push  edi
            push  esi
            mov   ebx, TransColor
            mov   edx, $FFFFFF
            mov   edi, p1
            rol   ebx, 16
            mov   ecx, sx
            mov   esi, p2
            and   ebx, edx
          @loop:
            lodsd
            and   eax, edx
            dec   esi
            cmp   eax, ebx
            jnz    @next
            stosw
            shr   eax, 16
            stosb
            loop  @loop
            jmp   @end
          @next:
            add   edi, 3
            loop  @loop
          @end:
            pop   esi
            pop   edi
            pop   ebx
          end;
       end;
    pf32bit:
      for i:=0 to sy-1 do
        begin
          p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*4);
          p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*4);
          asm
            push  ebx
            push  edi
            push  esi
            mov   ebx, TransColor
            mov   edi, p1
            rol   ebx, 16
            mov   edx, $FFFFFF
            mov   ecx, sx
            and   ebx, edx
            mov   esi, p2
          @loop:
            lodsd
            and   eax, edx
            cmp   eax, ebx
            jnz    @next
            stosd
            loop  @loop
            jmp   @end
          @next:
            add   edi, 4
            loop  @loop
          @end:
            pop   esi
            pop   edi
            pop   ebx
          end;
       end;
  end;
end;

procedure TransPut24bpp;
var
  i,j: integer;
  pp1, pp2: pointer;
begin
  j:= p1.Width;
  for i:=p1.Height-1 downto 0 do
    begin
      pp1:= p1.ScanLine[i];
      pp2:= p2.ScanLine[i];
      asm
        push  ebx
        push  edi
        push  esi
        mov   ebx, TransColor
        mov   edx, $FFFFFF
        mov   edi, pp1
        rol   ebx, 16
        mov   ecx, j
        mov   esi, pp2
        and   ebx, edx
      @loop:
        lodsd
        and   eax, edx
        dec   esi
        cmp   eax, ebx
        jz    @next
        stosw
        shr   eax, 16
        stosb
        loop  @loop
        jmp   @end
      @next:
        add   edi, 3
        loop  @loop
      @end:
        pop   esi
        pop   edi
        pop   ebx
      end;
    end;
end;

procedure TransPut32bpp;
var
  j: integer;
  pp1, pp2: pointer;
begin
  j:= p1.Width*p1.Height;
  pp1:= p1.ScanLine[ p1.Height-1];
  pp2:= p2.ScanLine[ p1.Height-1];
  asm
    push  ebx
    push  edi
    push  esi
    mov   ebx, TransColor
    mov   edi, pp1
    rol   ebx, 16
    mov   edx, $FFFFFF
    mov   ecx, j
    and   ebx, edx
    mov   esi, pp2
  @loop:
    lodsd
    and   eax, edx
    cmp   eax, ebx
    jz    @next
    stosd
    loop  @loop
    jmp   @end
  @next:
    add   edi, 4
    loop  @loop
  @end:
    pop   esi
    pop   edi
    pop   ebx
  end;
end;

procedure TransPut16bpp;
var
  j: integer;
  pp1, pp2: pointer;
begin
  TransColor:= color2color16(TransColor);
  j:= p1.Width*p1.Height;
  pp1:= p1.ScanLine[p1.Height-1];
  pp2:= p2.ScanLine[p1.Height-1];
  asm
    push  edi
    push  esi
    mov   edx, TransColor
    mov   edi, pp1
    mov   ecx, j
    mov   esi, pp2
  @loop:
    lodsw
    cmp   ax, dx
    jz    @next
    stosw
    loop  @loop
    jmp   @end
  @next:
    inc   edi
    inc   edi
    loop  @loop
  @end:
    pop   esi
    pop   edi
  end;
end;

procedure TransPut8bpp;
var
  j: integer;
  pp1, pp2: pointer;
begin
  j:= (p1.Width+3)*p1.Height;
  pp1:= p1.ScanLine[p1.Height-1];
  pp2:= p2.ScanLine[p1.Height-1];
  asm
    push  edi
    push  esi
    mov   edx, TransColor
    mov   edi, pp1
    mov   ecx, j
    mov   esi, pp2
  @loop:
    lodsb
    cmp   al, dl
    jz    @next
    stosb
    loop  @loop
    jmp   @end
  @next:
    inc   edi
    loop  @loop
  @end:
    pop   esi
    pop   edi
  end;
end;

procedure MaskPut24bpp;
var
  i,j: integer;
  pp1, pp2: pointer;
begin
  j:= p1.Width;
  for i:=p1.Height-1 downto 0 do
    begin
      pp1:= p1.ScanLine[i];
      pp2:= p2.ScanLine[i];
      asm
        push  ebx
        push  edi
        push  esi
        mov   ebx, TransColor
        mov   edx, $FFFFFF
        mov   edi, pp1
        rol   ebx, 16
        mov   ecx, j
        mov   esi, pp2
        and   ebx, edx
      @loop:
        lodsd
        and   eax, edx
        dec   esi
        cmp   eax, ebx
        jnz   @next
        stosw
        shr   eax, 16
        stosb
        loop  @loop
        jmp   @end
      @next:
        add   edi, 3
        loop  @loop
      @end:
        pop   esi
        pop   edi
        pop   ebx
      end;
    end;
end;

procedure MaskPut32bpp;
var
  j: integer;
  pp1, pp2: pointer;
begin
  j:= p1.Width*p1.Height;
  pp1:= p1.ScanLine[ p1.Height-1];
  pp2:= p2.ScanLine[ p1.Height-1];
  asm
    push  ebx
    push  edi
    push  esi
    mov   ebx, TransColor
    mov   edi, pp1
    rol   ebx, 16
    mov   edx, $FFFFFF
    mov   ecx, j
    and   ebx, edx
    mov   esi, pp2
  @loop:
    lodsd
    and   eax, edx
    cmp   eax, ebx
    jnz   @next
    stosd
    loop  @loop
    jmp   @end
  @next:
    add   edi, 4
    loop  @loop
  @end:
    pop   esi
    pop   edi
    pop   ebx
  end;
end;

procedure MaskPut16bpp;
var
  j: integer;
  pp1, pp2: pointer;
begin
  TransColor:= color2color16(TransColor);
  j:= (p1.Width+1)*(p1.Height{+1});
  pp1:= p1.ScanLine[p1.Height-1];
  pp2:= p2.ScanLine[p1.Height-1];
  asm
    push  edi
    push  esi
    mov   edx, TransColor
    mov   edi, pp1
    mov   ecx, j
    mov   esi, pp2
  @loop:
    lodsw
    cmp   ax, dx
    jnz   @next
    stosw
    loop  @loop
    jmp   @end
  @next:
    inc   edi
    inc   edi
    loop  @loop
  @end:
    pop   esi
    pop   edi
  end;
end;

procedure MaskPut8bpp;
var
  j: integer;
  pp1, pp2: pointer;
begin
  j:= (p1.Width+3)*(p1.Height);
  pp1:= p1.ScanLine[p1.Height-1];
  pp2:= p2.ScanLine[p1.Height-1];
  asm
    push  edi
    push  esi
    mov   edx, TransColor
    mov   edi, pp1
    mov   ecx, j
    mov   esi, pp2
  @loop:
    lodsb
    cmp   al, dl
    jnz   @next
    stosb
    loop  @loop
    jmp   @end
  @next:
    inc   edi
    loop  @loop
  @end:
    pop   esi
    pop   edi
  end;
end;

procedure MMXTransPut;
var
  p1, p2: pointer;
  xFrom, xTo, dx, sx, YFrom, YTo, dy, sy, i: integer;
//  E: Exception;
begin
{  try
    if not ((pb1.PixelFormat=pf8bit) or (pb1.PixelFormat=pf16bit)) or
      not ((pb2.PixelFormat=pf8bit) or (pb2.PixelFormat=pf16bit)) then
        begin
          e:=Exception.Create( e_Custom, 'This bitmap format is not supported!');
          e. errorcode:= 0;
          raise e;
        end;

    if not (pb1.PixelFormat=pb2.PixelFormat) then
      raise Exception.Create( e_Custom, 'Bitmap formats should be identical!');
  except on E: Exception do
    begin
    end;
  end;}

  dx:= 0;
  dy:= 0;
  sx:= pb2.Width;
  sy:= pb2.Height;
  YFrom:= y;
  YTo:= y+pb2.Height-1;
  XFrom:= x;
  XTo:= x+pb2.Width-1;
  if (YFrom>pb1.Height-1) or (XFrom>pb1.Width-1)
   or (YTo<0) or (XTo<0)
    then exit;

  if XFrom<0 then
    begin
      dx:= -XFrom;
      sx:= sx+XFrom;
      XFrom:= 0;
    end;

  if YFrom<0 then
    begin
      dy:= -YFrom;
      sy:= sy+YFrom;
      YFrom:= 0;
    end;

  if XTo>=pb1.Width then
    dec( sx, XTo-pb1.Width+1);

  if YTo>=pb1.Height then
    dec( sy, YTo-pb1.Height+1);

  if pb1.PixelFormat=pf8bit then
    for i:=0 to sy-1 do
      begin
        p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom);
        p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx);
        asm
          push     edi
          push     esi

          mov      edx, TransColor
          mov      dh, dl

          push     dx
          push     dx
          push     dx
          push     dx
          movq     mm2, [esp] // прозрачный цвет

          mov      edi, p1
          mov      ecx, sx

          xor      edx, edx
          shr      ecx, 3
          not      edx
          push     edx
          push     edx
          movq     mm4, [esp] // $FFFFFFFF.FFFFFFFF

          mov      esi, p2
          mov      edx, 8
          add      esp, edx
          sub      edi, edx

        @loop:
          add      edi, edx
          movq     mm0, [esi] // взять источник
          add      esi, edx
          movq     mm3, mm0   // сохранить источник

          pcmpeqb  mm3, mm2   // сравнить источник с прозрачным цветом

          pxor     mm3, mm4   // обратить маску прозрачности
          pand     mm0, mm3   // наложить маску прозрачности на источник
          pxor     mm3, mm4   // обратить маску прозрачности

          pand     mm3, [edi] // наложить инверсную маску прозрачности на приемник
          por      mm0, mm3   // объединить источник и приемник
          movq     [edi], mm0 // сохранить результат

          loop     @loop

          add      esp, edx

          add      edi, edx
          mov      edx, TransColor
          mov      ecx, sx
          and      ecx, 7
        @loop2:
          lodsb
          cmp      al, dl
          jz       @next
          mov      [edi], al
        @next:
          inc      edi
          loop     @loop2

          emms
          pop      esi
          pop      edi
        end;
     end
   else
    for i:=0 to sy-1 do
      begin
        p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*2);
        p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*2);
        asm
          push     edi
          push     esi

          mov      edx, TransColor

          push     dx
          mov      edi, p1
          push     dx
          mov      ecx, sx
          push     dx
          push     dx
          movq     mm2, [esp] // прозрачный цвет

          xor      edx, edx
          shr      ecx, 2
          not      edx
          push     edx
          push     edx
          movq     mm4, [esp] // $FFFFFFFF.FFFFFFFF

          mov      edx, 8
          mov      esi, p2
          add      esp, edx
          sub      edi, edx

        @loop:
          add      edi, edx
          movq     mm0, [esi] // взять источник
          add      esi, edx
          movq     mm3, mm0   // сохранить источник

          pcmpeqw  mm3, mm2   // сравнить источник с прозрачным цветом

          pxor     mm3, mm4   // обратить маску прозрачности
          pand     mm0, mm3   // наложить маску прозрачности на источник
          pxor     mm3, mm4   // обратить маску прозрачности

          pand     mm3, [edi] // наложить инверсную маску прозрачности на приемник
          por      mm0, mm3   // объединить источник и приемник
          movq     [edi], mm0 // сохранить результат

          loop     @loop
          emms

          add      esp, edx

          add      edi, edx
          mov      ecx, sx
          mov      edx, TransColor
          and      ecx, 3

        @loop2:
          lodsw
          cmp      ax, dx
          jz       @next
          mov      [edi], ax
        @next:
          inc      edi
          inc      edi
          loop     @loop2

          pop      esi
          pop      edi
        end;
     end;
end;

procedure MMXTransPut8bpp;
var
  j: integer;
  pp1, pp2: pointer;
begin
  j:= (p1.Width+3)*p1.Height;
  pp1:= p1.ScanLine[ p1.Height-1];
  pp2:= p2.ScanLine[ p1.Height-1];
  asm
    push     edi
    push     esi

    mov      edx, TransColor
    mov      dh, dl

    push     dx
    push     dx
    push     dx
    push     dx
    movq     mm2, [esp] // прозрачный цвет

    mov      edi, pp1
    mov      ecx, j

    xor      edx, edx
    shr      ecx, 3
    not      edx
    push     edx
    push     edx
    movq     mm4, [esp] // $FFFFFFFF.FFFFFFFF

    mov      esi, pp2
    mov      edx, 8
    add      esp, edx
    sub      edi, edx

  @loop:
    add      edi, edx
    movq     mm0, [esi] // взять источник
    add      esi, edx
    movq     mm3, mm0   // сохранить источник

    pcmpeqb  mm3, mm2   // сравнить источник с прозрачным цветом

    pxor     mm3, mm4   // обратить маску прозрачности
    pand     mm0, mm3   // наложить маску прозрачности на источник
    pxor     mm3, mm4   // обратить маску прозрачности

    pand     mm3, [edi] // наложить инверсную маску прозрачности на приемник
    por      mm0, mm3   // объединить источник и приемник
    movq     [edi], mm0 // сохранить результат

    loop     @loop

    add      esp, edx
    add      edi, edx
    mov      edx, TransColor
    mov      ecx, j
    and      ecx, 7
  @loop2:
    lodsb
    cmp      al, dl
    jnz      @next
    mov      [edi], al
  @next:
    inc      edi
    loop     @loop2
    emms

    pop      esi
    pop      edi
  end;
end;

procedure MMXTransPut16bpp;
var
  j: integer;
  pp1, pp2: pointer;
begin
  TransColor:= color2color16(TransColor);
  j:= p1.Width*p1.Height;
  pp1:= p1.ScanLine[ p1.Height-1];
  pp2:= p2.ScanLine[ p1.Height-1];
  asm
    push     edi
    push     esi

    mov      edx, TransColor

    push     dx
    mov      edi, pp1
    push     dx
    mov      ecx, j
    push     dx
    push     dx
    movq     mm2, [esp] // прозрачный цвет

    xor      edx, edx
    shr      ecx, 2
    not      edx
    push     edx
    push     edx
    movq     mm4, [esp] // $FFFFFFFF.FFFFFFFF

    mov      edx, 8
    mov      esi, pp2
    add      esp, edx
    sub      edi, edx

  @loop:
    add      edi, edx
    movq     mm0, [esi] // взять источник
    add      esi, edx
    movq     mm3, mm0   // сохранить источник

    pcmpeqw  mm3, mm2   // сравнить источник с прозрачным цветом

    pxor     mm3, mm4   // обратить маску прозрачности
    pand     mm0, mm3   // наложить маску прозрачности на источник
    pxor     mm3, mm4   // обратить маску прозрачности

    pand     mm3, [edi] // наложить инверсную маску прозрачности на приемник
    por      mm0, mm3   // объединить источник и приемник
    movq     [edi], mm0 // сохранить результат

    loop     @loop

    add      esp, edx
    mov      edx, TransColor
    mov      ecx, j
    and      ecx, 1
    lodsb
    cmp      al, dl
    jnz      @next
    mov      [edi], al
  @next:
    inc      edi
    emms

    pop      esi
    pop      edi
  end;
end;

procedure MMXMaskPut;
var
  p1, p2: pointer;
  xFrom, xTo, dx, sx, YFrom, YTo, dy, sy, i: integer;
//  E: Exception;
begin
{  try
    if not ((pb1.PixelFormat=pf8bit) or (pb1.PixelFormat=pf16bit)) or
      not ((pb2.PixelFormat=pf8bit) or (pb2.PixelFormat=pf16bit)) then
        begin
          e:=Exception.Create( e_Custom, 'This bitmap format is not supported!');
          e. errorcode:= 0;
          raise e;
        end;

    if not (pb1.PixelFormat=pb2.PixelFormat) then
      raise Exception.Create( e_Custom, 'Bitmap formats should be identical!');
  except on E: Exception do
    begin
    end;
  end;  }

  dx:= 0;
  dy:= 0;
  sx:= pb2.Width;
  sy:= pb2.Height;
  YFrom:= y;
  YTo:= y+pb2.Height-1;
  XFrom:= x;
  XTo:= x+pb2.Width-1;
  if (YFrom>pb1.Height-1) or (XFrom>pb1.Width-1)
   or (YTo<0) or (XTo<0)
    then exit;

  if XFrom<0 then
    begin
      dx:= -XFrom;
      sx:= sx+XFrom;
      XFrom:= 0;
    end;

  if YFrom<0 then
    begin
      dy:= -YFrom;
      sy:= sy+YFrom;
      YFrom:= 0;
    end;

  if XTo>=pb1.Width then
    dec( sx, XTo-pb1.Width+1);

  if YTo>=pb1.Height then
    dec( sy, YTo-pb1.Height+1);

  if pb1.PixelFormat=pf8bit then
    for i:=0 to sy-1 do
      begin
        p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom);
        p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx);
        asm
          push     edi
          push     esi

          mov      edx, TransColor
          mov      dh, dl

          push     dx
          push     dx
          push     dx
          push     dx
          movq     mm2, [esp] // прозрачный цвет

          mov      edi, p1
          mov      ecx, sx

          xor      edx, edx
          shr      ecx, 3
          not      edx
          push     edx
          push     edx
          movq     mm4, [esp] // $FFFFFFFF.FFFFFFFF

          mov      esi, p2
          mov      edx, 8
          add      esp, edx
          sub      edi, edx

        @loop:
          add      edi, edx
          movq     mm0, [esi] // взять источник
          add      esi, edx
          movq     mm3, mm0   // сохранить источник

          pcmpeqb  mm3, mm2   // сравнить источник с прозрачным цветом

          pand     mm0, mm3   // наложить маску прозрачности на источник
          pxor     mm3, mm4   // обратить маску прозрачности

          pand     mm3, [edi] // наложить инверсную маску прозрачности на приемник
          por      mm0, mm3   // объединить источник и приемник
          movq     [edi], mm0 // сохранить результат

          loop     @loop
          emms

          add      esp, edx

          add      edi, edx
          mov      edx, TransColor
          mov      ecx, sx
          and      ecx, 7
        @loop2:
          lodsb
          cmp      al, dl
          jnz      @next
          mov      [edi], al
        @next:
          inc      edi
          loop     @loop2

          pop      esi
          pop      edi
        end;
     end
   else
    for i:=0 to sy-1 do
      begin
        p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*2);
        p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*2);
        asm
          push     edi
          push     esi

          mov      edx, TransColor

          push     dx
          mov      edi, p1
          push     dx
          mov      ecx, sx
          push     dx
          push     dx
          movq     mm2, [esp] // прозрачный цвет

          xor      edx, edx
          shr      ecx, 2
          not      edx
          push     edx
          push     edx
          movq     mm4, [esp] // $FFFFFFFF.FFFFFFFF

          mov      edx, 8
          mov      esi, p2
          add      esp, edx
          sub      edi, edx

        @loop:
          add      edi, edx
          movq     mm0, [esi] // взять источник
          add      esi, edx
          movq     mm3, mm0   // сохранить источник

          pcmpeqw  mm3, mm2   // сравнить источник с прозрачным цветом

          pand     mm0, mm3   // наложить маску прозрачности на источник
          pxor     mm3, mm4   // обратить маску прозрачности

          pand     mm3, [edi] // наложить инверсную маску прозрачности на приемник
          por      mm0, mm3   // объединить источник и приемник
          movq     [edi], mm0 // сохранить результат

          loop     @loop
          emms

          add      esp, edx

          add      edi, edx
          mov      ecx, sx
          mov      edx, TransColor
          and      ecx, 3

        @loop2:
          lodsw
          cmp      ax, dx
          jnz      @next
          mov      [edi], ax
        @next:
          inc      edi
          inc      edi
          loop     @loop2

          pop      esi
          pop      edi
        end;
     end;
end;

procedure MMXMaskPut8bpp;
var
  j: integer;
  pp1, pp2: pointer;
begin
  j:= (p1.Width+3)*p1.Height;
  pp1:= p1.ScanLine[ p1.Height-1];
  pp2:= p2.ScanLine[ p1.Height-1];
  asm
    push     edi
    push     esi

    mov      edx, TransColor
    mov      dh, dl

    push     dx
    push     dx
    push     dx
    push     dx
    movq     mm2, [esp] // прозрачный цвет

    mov      edi, pp1
    mov      ecx, j

    xor      edx, edx
    shr      ecx, 3
    not      edx
    push     edx
    push     edx
    movq     mm4, [esp] // $FFFFFFFF.FFFFFFFF

    mov      esi, pp2
    mov      edx, 8
    add      esp, edx
    sub      edi, edx

  @loop:
    add      edi, edx
    movq     mm0, [esi] // взять источник
    add      esi, edx
    movq     mm3, mm0   // сохранить источник

    pcmpeqb  mm3, mm2   // сравнить источник с прозрачным цветом

    pand     mm0, mm3   // наложить маску прозрачности на источник
    pxor     mm3, mm4   // обратить маску прозрачности

    pand     mm3, [edi] // наложить инверсную маску прозрачности на приемник
    por      mm0, mm3   // объединить источник и приемник
    movq     [edi], mm0 // сохранить результат

    loop     @loop

    add      esp, edx
    emms

    pop      esi
    pop      edi
  end;
end;

procedure MMXMaskPut16bpp;
var
  j: integer;
  pp1, pp2: pointer;
begin
  TransColor:= color2color16(TransColor);
  j:= (p1.Width+2)*p1.Height;
  pp1:= p1.ScanLine[ p1.Height-1];
  pp2:= p2.ScanLine[ p1.Height-1];
  asm
    push     edi
    push     esi

    mov      edx, TransColor

    push     dx
    mov      edi, pp1
    push     dx
    mov      ecx, j
    push     dx
    push     dx
    movq     mm2, [esp] // прозрачный цвет

    xor      edx, edx
    shr      ecx, 2
    not      edx
    push     edx
    push     edx
    movq     mm4, [esp] // $FFFFFFFF.FFFFFFFF

    mov      edx, 8
    mov      esi, pp2
    add      esp, edx
    sub      edi, edx

  @loop:
    add      edi, edx
    movq     mm0, [esi] // взять источник
    add      esi, edx
    movq     mm3, mm0   // сохранить источник

    pcmpeqw  mm3, mm2   // сравнить источник с прозрачным цветом

    pand     mm0, mm3   // наложить маску прозрачности на источник
    pxor     mm3, mm4   // обратить маску прозрачности

    pand     mm3, [edi] // наложить инверсную маску прозрачности на приемник
    por      mm0, mm3   // объединить источник и приемник
    movq     [edi], mm0 // сохранить результат

    loop     @loop

    add      esp, edx
    emms

    pop      esi
    pop      edi
  end;
end;

procedure FPTransPaint24bpp;
var
  p1, p2: pointer;
  size: integer;
begin
  p1:= pb1.ScanLine[pb1.Height-1];
  p2:= pb2.ScanLine[pb1.Height-1];
  size:= (pb1.Width+1)*pb1.Height;
  asm
    push      edi
    push      esi

    mov       esi, p2
    mov       edi, p1
    mov       ecx, size

    xor       eax, eax
    mov       edx, ecx
    mov       [p1], eax
    add       ecx, ecx
    add       ecx, edx

    // X*(1-Op)+Y*Op = X - X*Op + Y*Op = X + (Y-X)*Op

  @loop:
    fld       [Opacity]        // Op, -
    lodsb
    mov       byte ptr [p1], al
    fild      [p1]             // Y, Op, -

    mov       al, [edi]
    mov       byte ptr [p1], al
    fild      [p1]             // X, Y, Op,-
    fst       st(3)            // X, Y, Op, X, -

    fsubp                      // Y-X, Op, X, -
    fmulp                      // (Y-X)*Op, X, -
    faddp                      // X + (Y-X)*Op, -

    fistp     [p1]             // -

    mov       al, byte ptr [p1]
    stosb
    loop      @loop

    pop       esi
    pop       edi
  end;
end;

procedure MMXTransPaint32bpp;
var
  p1, p2: pointer;
  size, op, _op: integer;
begin
  p1:= pb1.ScanLine[pb1.height-1];
  p2:= pb2.ScanLine[pb1.height-1];
  size:= pb1.Width*pb1.height;
  op:= lo(trunc(opacity*255));
  if op<2 then
    exit;
  if op>253 then
    begin
      Put( pb1, pb2, 0, 0);
      exit;
    end;
  _op:= 255-op;
  asm
    push      edi
    push      esi

    mov       esi, p2
    mov       edi, p1
    mov       ecx, size
    pxor      mm7, mm7    // mm7 = 0

    mov       eax, op
    push      ax
    push      ax
    push      ax
    push      ax
    movq      mm6, [esp]  // mm6 - прямые множители (коэффициенты) прозрачности

    mov       eax, $00FF00FF
    mov       edx, 4      // инкремент указателей
    push      eax
    push      eax
    movq      mm5, [esp]  // mm5 - $00FF00FF00FF00FF

    mov       eax, _op
    push      ax
    push      ax
    push      ax
    push      ax
    movq      mm3, [esp]  // mm3 - обратные множители (коэффициенты) прозрачности

    // X*(1-Op)+Y*Op = X - X*Op + Y*Op = X + (Y-X)*Op
  @loop:
    movd      mm0, [esi]  // взять источник
    movd      mm1, [edi]  // взять приемник
    punpcklbw mm0, mm7    // распаковать младшие байты (мл.половины) источника
    punpcklbw mm1, mm7    // распаковать младшие байты (мл.половины) приемника

    pmullw    mm0, mm6
    pmullw    mm1, mm3
    paddw     mm0, mm1
    psrlq     mm0, 8

    pand      mm0, mm5    // обрезать лишние разряды
    packuswb  mm0, mm7    // упаковать перед записью на место
    movd      eax, mm0    // записать результат
    stosd
    add       esi, edx
    loop      @loop

    add       esp, 24
    emms
    pop       esi
    pop       edi
  end;
end;

procedure MMXTransPaint24bpp;
var
  p1, p2: pointer;
  size, op, _op: integer;
begin
  p1:= pb1.ScanLine[pb1.height-1];
  p2:= pb2.ScanLine[pb1.height-1];
  size:= (pb1.Width+1)*pb1.height*3 div 4;
  op:= lo(trunc(opacity*255));
  if op<2 then
    exit;
  if op>253 then
    begin
      Put( pb1, pb2, 0, 0);
      exit;
    end;
  _op:= 255-op;
  asm
    push      edi
    push      esi

    mov       esi, p2
    mov       edi, p1
    mov       ecx, size
    pxor      mm7, mm7    // mm7 = 0
    mov       eax, op
    push      ax
    push      ax
    push      ax
    push      ax
    movq      mm6, [esp]  // mm6 - прямые множители прозрачности

    mov       eax, $00FF00FF
    mov       edx, 4      // инкремент указателей
    push      eax
    push      eax
    movq      mm5, [esp]  // mm5 - $00FF00FF00FF00FF

    mov       eax, _op
    push      ax
    push      ax
    push      ax
    push      ax
    movq      mm3, [esp]  // mm3 - обратные множители (коэффициенты) прозрачности

    // X*(1-Op)+Y*Op = X - X*Op + Y*Op = X + (Y-X)*Op
  @loop:
    movd      mm0, [esi]  // взять источник
    movd      mm1, [edi]  // взять приемник
    punpcklbw mm0, mm7    // распаковать младшие байты (мл.половины) в слова
    punpcklbw mm1, mm7    // распаковать младшие байты (мл.половины) в слова

    pmullw    mm0, mm6
    pmullw    mm1, mm3
    paddw     mm0, mm1
    psrlq     mm0, 8

    pand      mm0, mm5    // обрезать лишние разряды
    packuswb  mm0, mm7    // упаковать перед записью на место

    movd      eax, mm0    // записать результат
    stosd

    add       esi, edx
    loop      @loop

    add       esp, 24
    emms
    pop       esi
    pop       edi
  end;
end;

procedure Put;
var
  p1, p2: pointer;
  xFrom, xTo, dx, sx, YFrom, YTo, dy, sy, i, size: integer;
begin

  dx:= 0;
  dy:= 0;
  sx:= pb2.Width;
  sy:= pb2.Height;
  YFrom:= y;
  YTo:= y+pb2.Height-1;
  XFrom:= x;
  XTo:= x+pb2.Width-1;
  if (YFrom>pb1.Height-1) or (XFrom>pb1.Width-1)
   or (YTo<0) or (XTo<0)
    then exit;

  if XFrom<0 then
    begin
      dx:= -XFrom;
      sx:= sx+XFrom;
      XFrom:= 0;
    end;

  if YFrom<0 then
    begin
      dy:= -YFrom;
      sy:= sy+YFrom;
      YFrom:= 0;
    end;

  if XTo>=pb1.Width then
    dec( sx, XTo-pb1.Width+1);

  if YTo>=pb1.Height then
    dec( sy, YTo-pb1.Height+1);

  case pb1.PixelFormat of
    pf8bit:
      begin
        size:=1;
      end;
    pf16bit:
      begin
        size:=2;
        sx:= sx*2;
      end;
    pf24bit:
      begin
        size:=3;
        sx:= sx*3;
      end;
    pf32bit:
      begin
        size:=4;
        sx:= sx*4;
      end;
  end;

  case PutMode of
    pmNormal:
      begin
        for i:=0 to sy-1 do
          begin
            p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*size);
            p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*size);
            asm
              push  edi
              push  esi
              mov   edi, p1
              mov   ecx, sx
              mov   esi, p2
              shr   ecx, 2
            @loop:
              lodsd
              stosd
              loop  @loop

              mov   ecx, sx
              and   ecx, 3
              jcxz  @end
            @loop2:
              lodsb
              stosb
              loop  @loop2
            @end:
              pop   esi
              pop   edi
            end;
          end;
      end;
    pmHFlip:
      begin
        for i:=0 to sy-1 do
          begin
            p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*size+sx);
            p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*size);
            asm
              push  edi
              push  esi
              mov   edi, p1
              mov   ecx, sx
              mov   esi, p2
            @loop:
              lodsb
              mov   [edi], al
              dec   edi
              loop  @loop

              pop   esi
              pop   edi
            end;
          end;
      end;
    pmVFlip:
      begin
        for i:=0 to sy-1 do
          begin
            p1:= pointer( cardinal( pb1.ScanLine[YFrom+sy-1-i])+XFrom*size);
            p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*size);
            asm
              push  edi
              push  esi
              mov   edi, p1
              mov   ecx, sx
              mov   esi, p2
              shr   ecx, 2
            @loop:
              lodsd
              stosd
              loop  @loop

              mov   ecx, sx
              and   ecx, 3
              jcxz  @end
            @loop2:
              lodsb
              stosb
              loop  @loop2
            @end:
              pop   esi
              pop   edi
            end;
          end;
      end;
    pmHVFlip:
      begin
        for i:=0 to sy-1 do
          begin
            p1:= pointer( cardinal( pb1.ScanLine[YFrom+sy-1-i])+XFrom*size+sx);
            p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*size);
            asm
              push  edi
              push  esi
              mov   edi, p1
              mov   ecx, sx
              mov   esi, p2
            @loop:
              lodsb
              mov   [edi], al
              dec   edi
              loop  @loop

              pop   esi
              pop   edi
            end;
          end;
      end;
  end;
end;

procedure MMXSpritePut;
var
  p1, p2: pointer;
  _op, op, x0, xFrom, xTo, dx, sx, YFrom, YTo, dy, sy, i, size: integer;
begin
{  if not ((pb1.PixelFormat=pf24bit) or (pb1.PixelFormat=pf32bit)) or
    not ((pb2.PixelFormat=pf24bit) or (pb2.PixelFormat=pf32bit)) then
     raise Exception.Create( e_Custom, 'This bitmap format is not supported!');
  if not (pb1.PixelFormat=pb2.PixelFormat) then
    raise Exception.Create( e_Custom, 'Bitmap formats should be identical!');}

  dx:= 0;
  dy:= 0;
  x0:= 0;
  sx:= pb2.Width;
  sy:= pb2.Height;
  YFrom:= y;
  YTo:= y+pb2.Height-1;
  XFrom:= x;
  XTo:= x+pb2.Width-1;
  if (YFrom>pb1.Height-1) or (XFrom>pb1.Width-1)
   or (YTo<0) or (XTo<0)
    then exit;

  if XFrom<0 then
    begin
      dx:= -XFrom;
      sx:= sx+XFrom;
      inc( x0, -XFrom);
      XFrom:= 0;
    end;

  if YFrom<0 then
    begin
      dy:= -YFrom;
      sy:= sy+YFrom;
      YFrom:= 0;
    end;

  if XTo>=pb1.Width then
    dec( sx, XTo-pb1.Width+1);

  if YTo>=pb1.Height then
    dec( sy, YTo-pb1.Height+1);

  op:= lo( trunc( opacity*255));
{  if op<2 then
    exit;
  if op>253 then
    begin
      Put( pb1, pb2, x, y);
      exit;
    end;}
  _op:= 255-op;

  if pb1.PixelFormat=pf24bit then
    for i:=0 to sy-1 do
      begin
        p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*3);
        p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*3);
        asm
          push      edi
          push      esi
          push      ebx

          mov       esi, p2
          mov       edi, p1
          mov       ecx, sx
          pxor      mm7, mm7    // mm7 = 0
          mov       eax, op
          push      ax
          push      ax
          push      ax
          push      ax
          movq      mm6, [esp]  // mm6 - прямые множители прозрачности

          mov       eax, $00FF00FF
          mov       edx, 3      // инкремент указателей
          push      eax
          push      eax
          movq      mm5, [esp]  // mm5 - $00FF00FF00FF00FF

          mov       eax, $00FFFFFF
          push      eax
          movd      mm4, [esp]  // mm4 - $0000000000FFFFFF

          mov       eax, _op
          mov       ebx, transcolor
          push      ax
          push      ax
          push      ax
          push      ax
          rol       ebx, 16
          movq      mm3, [esp]  // mm3 - обратные множители (коэффициенты) прозрачности
          and       ebx, $00FFFFFF

          // X*(1-Op)+Y*Op = X - X*Op + Y*Op = X + (Y-X)*Op
        @loop:
          lodsd
          dec       esi
          cmp       eax, ebx
          jz        @next
          movd      mm0, eax    // взять источник
          movd      mm1, [edi]  // взять приемник
          punpcklbw mm0, mm7    // распаковать младшие байты (мл.половины) в слова
          pand      mm1, mm4

          pmullw    mm0, mm6
          punpcklbw mm1, mm7    // распаковать младшие байты (мл.половины) в слова
          pmullw    mm1, mm3
          paddw     mm0, mm1
          psrlq     mm0, 8

          pand      mm0, mm5    // обрезать лишние разряды
          packuswb  mm0, mm7    // упаковать перед записью на место
//          pand      mm0, mm4

          movd      eax, mm0    // записать результат
          and       [edi], $ff000000
          or        [edi], eax
        @next:

          add       edi, edx
          loop      @loop

        @end:

          add       esp, 28
          emms
          pop       ebx
          pop       esi
          pop       edi
        end;
      end
  else
    for i:=0 to sy-1 do
      begin
        p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*4);
        p2:= pointer( cardinal( pb2.ScanLine[dy+i])+x0*4);
        asm
          push      edi
          push      esi
          push      ebx

          mov       esi, p2
          mov       edi, p1
          mov       ecx, sx
          pxor      mm7, mm7    // mm7 = 0

          mov       eax, op
          push      ax
          push      ax
          push      ax
          push      ax
          movq      mm6, [esp]  // mm6 - прямые множители (коэффициенты) прозрачности

          mov       eax, $00FF00FF
          mov       edx, 4      // инкремент указателей
          push      eax
          push      eax
          movq      mm5, [esp]  // mm5 - $00FF00FF00FF00FF

          mov       eax, _op
          push      ax
          push      ax
          push      ax
          push      ax
          mov       ebx, transcolor
          movq      mm3, [esp]  // mm3 - обратные множители (коэффициенты) прозрачности
          rol       ebx, 16

          // X*(1-Op)+Y*Op = X - X*Op + Y*Op = X + (Y-X)*Op
        @loop:
          lodsd
          and       eax, $00FFFFFF
          cmp       eax, ebx
          jz        @next
          movd      mm0, eax    // взять источник
          movd      mm1, [edi]  // взять приемник
          punpcklbw mm0, mm7    // распаковать младшие байты (мл.половины) источника
          punpcklbw mm1, mm7    // распаковать младшие байты (мл.половины) приемника

          pmullw    mm0, mm6
          pmullw    mm1, mm3
          paddw     mm0, mm1
          psrlq     mm0, 8

          pand      mm0, mm5    // обрезать лишние разряды
          packuswb  mm0, mm7    // упаковать перед записью на место
          movd      [edi], mm0  // записать результат

        @next:
          add       edi, edx
          loop      @loop

        @end:

          add       esp, 24
          emms
          pop       ebx
          pop       esi
          pop       edi
        end;
      end;
end;

procedure SpritePut;
var
  p1, p2: pointer;
  _op, op, x0, xFrom, xTo, dx, sx, YFrom, YTo, dy, sy, i, size: integer;
begin
{  if not ((pb1.PixelFormat=pf24bit) or (pb1.PixelFormat=pf32bit)) or
    not ((pb2.PixelFormat=pf24bit) or (pb2.PixelFormat=pf32bit)) then
     raise Exception.Create( e_Custom, 'This bitmap format is not supported!');
  if not (pb1.PixelFormat=pb2.PixelFormat) then
    raise Exception.Create( e_Custom, 'Bitmap formats should be identical!');}

  dx:= 0;
  dy:= 0;
  x0:= 0;
  sx:= pb2.Width;
  sy:= pb2.Height;
  YFrom:= y;
  YTo:= y+pb2.Height-1;
  XFrom:= x;
  XTo:= x+pb2.Width-1;
  if (YFrom>pb1.Height-1) or (XFrom>pb1.Width-1)
   or (YTo<0) or (XTo<0)
    then exit;

  if XFrom<0 then
    begin
      dx:= -XFrom;
      sx:= sx+XFrom;
      inc( x0, -XFrom);
      XFrom:= 0;
    end;

  if YFrom<0 then
    begin
      dy:= -YFrom;
      sy:= sy+YFrom;
      YFrom:= 0;
    end;

  if XTo>=pb1.Width then
    dec( sx, XTo-pb1.Width+1);

  if YTo>=pb1.Height then
    dec( sy, YTo-pb1.Height+1);

  asm
    and   transcolor, $00FFFFFF
    rol   transcolor, 16
  end;
  if pb1.PixelFormat=pf24bit then
    for i:=0 to sy-1 do
      begin
        p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*3);
        p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*3);
        asm
          push  ebx
          push  edi
          push  esi
          mov   edi, p1
          mov   ebx, OpacityTable
          mov   ecx, sx
          mov   esi, p2
        @loop:
          lodsd
          dec   esi
          and   eax, $00FFFFFF
          cmp   eax, transcolor
          jz    @next

          xor   edx, edx
          sub   al, [edi]
          sbb   dl, dh
          xlatb
          xchg   dl, al
          xlatb
          add   [edi], dl
          sub   [edi], al
          inc   edi

          shr   eax, 8
          xor   edx, edx
          sub   al, [edi]
          sbb   dl, dh
          xlatb
          xchg   dl, al
          xlatb
          add   [edi], dl
          sub   [edi], al
          inc   edi

          mov   al, ah
          xor   edx, edx
          sub   al, [edi]
          sbb   dl, dh
          xlatb
          xchg   dl, al
          xlatb
          add   [edi], dl
          sub   [edi], al
          inc   edi

          loop  @loop
          jmp   @end

        @next:
          add   edi, 3
          loop  @loop

        @end:

          pop   esi
          pop   edi
          pop   ebx
        end;
      end
  else
    for i:=0 to sy-1 do
      begin
        p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*4);
        p2:= pointer( cardinal( pb2.ScanLine[dy+i])+x0*4);
        asm
          push  ebx
          push  edi
          push  esi
          mov   edi, p1
          mov   ebx, OpacityTable
          mov   ecx, sx
          mov   esi, p2
        @loop:
          lodsd
          and   eax, $00FFFFFF
          cmp   eax, transcolor
          jz    @next

          xor   edx, edx
          sub   al, [edi]
          sbb   dl, dh
          xlatb
          xchg   dl, al
          xlatb
          add   [edi], dl
          sub   [edi], al
          inc   edi

          shr   eax, 8
          xor   edx, edx
          sub   al, [edi]
          sbb   dl, dh
          xlatb
          xchg   dl, al
          xlatb
          add   [edi], dl
          sub   [edi], al
          inc   edi

          shr   eax, 8
          xor   edx, edx
          sub   al, [edi]
          sbb   dl, dh
          xlatb
          xchg   dl, al
          xlatb
          add   [edi], dl
          sub   [edi], al
          inc   edi

          mov   al, ah
          xor   edx, edx
          sub   al, [edi]
          sbb   dl, dh
          xlatb
          xchg   dl, al
          xlatb
          add   [edi], dl
          sub   [edi], al
          inc   edi

          loop  @loop
          jmp   @end

        @next:
          add   edi, 4
          loop  @loop

        @end:

          pop   esi
          pop   edi
          pop   ebx
        end;
      end;
end;

procedure Get;
var
  p1, p2: pointer;
  xFrom, xTo, dx, sx, YFrom, YTo, dy, sy, i, size: integer;
begin

  dx:= 0;
  dy:= 0;
  sx:= pb2.Width;
  sy:= pb2.Height;
  YFrom:= y;
  YTo:= y+pb2.Height-1;
  XFrom:= x;
  XTo:= x+pb2.Width-1;
  if (YFrom>pb1.Height-1) or (XFrom>pb1.Width-1)
   or (YTo<0) or (XTo<0)
    then exit;

  if XFrom<0 then
    begin
      dx:= -XFrom;
      sx:= sx+XFrom;
      XFrom:= 0;
    end;

  if YFrom<0 then
    begin
      dy:= -YFrom;
      sy:= sy+YFrom;
      YFrom:= 0;
    end;

  if XTo>=pb1.Width then
    dec( sx, XTo-pb1.Width+1);

  if YTo>=pb1.Height then
    dec( sy, YTo-pb1.Height+1);

  case pb1.PixelFormat of
    pf8bit:
      begin
        size:=1;
      end;
    pf16bit:
      begin
        size:=2;
        sx:= sx*2;
      end;
    pf24bit:
      begin
        size:=3;
        sx:= sx*3;
      end;
    pf32bit:
      begin
        size:=4;
        sx:= sx*4;
      end;
  end;

  case PutMode of
    pmNormal:
      begin
        for i:=0 to sy-1 do
          begin
            p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*size);
            p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*size);
            asm
              push  edi
              push  esi
              mov   edi, p2
              mov   ecx, sx
              mov   esi, p1
              shr   ecx, 2
            @loop:
              lodsd
              stosd
              loop  @loop

              mov   ecx, sx
              and   ecx, 3
              jcxz  @end
            @loop2:
              lodsb
              stosb
              loop  @loop2
            @end:
              pop   esi
              pop   edi
            end;
          end;
      end;
    pmHFlip:
      begin
        for i:=0 to sy-1 do
          begin
            p1:= pointer( cardinal( pb1.ScanLine[YFrom+i])+XFrom*size+sx);
            p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*size);
            asm
              push  edi
              push  esi
              mov   edi, p2
              mov   ecx, sx
              mov   esi, p1
            @loop:
              lodsb
              mov   [edi], al
              dec   edi
              loop  @loop

              pop   esi
              pop   edi
            end;
          end;
      end;
    pmVFlip:
      begin
        for i:=0 to sy-1 do
          begin
            p1:= pointer( cardinal( pb1.ScanLine[YFrom+sy-1-i])+XFrom*size);
            p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*size);
            asm
              push  edi
              push  esi
              mov   edi, p2
              mov   ecx, sx
              mov   esi, p1
              shr   ecx, 2
            @loop:
              lodsd
              stosd
              loop  @loop

              mov   ecx, sx
              and   ecx, 3
              jcxz  @end
            @loop2:
              lodsb
              stosb
              loop  @loop2
            @end:
              pop   esi
              pop   edi
            end;
          end;
      end;
    pmHVFlip:
      begin
        for i:=0 to sy-1 do
          begin
            p1:= pointer( cardinal( pb1.ScanLine[YFrom+sy-1-i])+XFrom*size+sx);
            p2:= pointer( cardinal( pb2.ScanLine[dy+i])+dx*size);
            asm
              push  edi
              push  esi
              mov   edi, p2
              mov   ecx, sx
              mov   esi, p1
            @loop:
              lodsb
              mov   [edi], al
              dec   edi
              loop  @loop

              pop   esi
              pop   edi
            end;
          end;
      end;
  end;
end;

function NewBitmapEx;
begin
  Result:= TBitmap.Create;
  Result.Width:= W;
  Result.Height:= H;
  if Result.pixelformat<>bpp then
    Result.pixelformat:= bpp;
end;

initialization
  PutMode:= pmNormal;
end.

