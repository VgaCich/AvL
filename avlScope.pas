unit avlScope;

interface

uses
  Windows, Avl;

type
  TScope = class(TGraphicControl)
  private
    fAllowed : boolean;
    fOnUpdate  : TNotifyEvent;
    DrawBuffer : TBitmap;
    DrawTimer  : TTimer;
    fActive    : boolean;
    fBaseColor,           { Baseline color }
    fColor,               { Background color }
    fGridColor,           { Grid line color }
    fLineColor : TColor;  { Position line color }
    fBaseLine,
    fGridSize,
    fPosition,            { Value to plot }
    fInterval  : integer; { Update speed in 1/10 seconds }
    procedure SetActive(value:boolean);
    procedure SetGridSize(value:integer);
    procedure SetBaseLine(value:integer);
    procedure SetInterval(value:integer);
  protected
    Oldpos, PrevPos : integer;
    CalcBase, Counter : integer;
    procedure   Updatescope2(Sender:TObject);
    procedure   Loaded; //override;
    procedure   SetBounds(ALeft, ATop, AWidth, AHeight: Integer); //override;
  public
    procedure   Paint; override;
    constructor Create(AnOwner: TWinControl); //override;
    destructor  Destroy; override;
    procedure   Free;
    procedure   Clear;
//  published
    property Baseline : integer read fBaseline write SetBaseLine;
    property Gridsize : integer read fGridSize write SetGridSize;
    property Active   : boolean read fActive write SetActive;
    property Position : Integer read fPosition write fPosition;
    property Interval : Integer read fInterval write SetInterval;
    { Color properties }
    property Color     : TColor read fColor     write fColor;
    property Gridcolor : TColor read fGridColor write fGridColor;
    property Linecolor : TColor read fLineColor write fLineColor;
    property Basecolor : TColor read fBaseColor write fBaseColor;

    property OnUpdate  : TNotifyEvent read fOnUpdate write fOnUpdate;
    { Standard properties }
    property Height;
    property Width;
    { Standard events }
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

  TIndicator = class(TGraphicControl)
  private
    FDrawBuffer: TBitmap;
    FShaddow,
    FForeground,
    FBackground : TColor;
    FPosition  : Integer;
    procedure SetPosition(value:integer);
    procedure SetForeground(value:TColor);
    procedure SetBackground(value:TColor);
  protected
    procedure   Paint; override;
    procedure   SetBounds(ALeft, ATop, AWidth, AHeight: Integer); //override;
    procedure   UpdateDrawBuffer;
  public
    constructor Create(anOwner: TWinControl); //override;
    destructor  Destroy; override;
    procedure   Free;
//  published
    property Position  : integer read FPosition write SetPosition;
    property Background: TColor read FBackground write SetBackground;
    property Foreground: TColor read fForeground write SetForeground;
    { Standard properties }
    property Height;
    property Width;
    { Standard events }
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

  TSimplePie = class(TGraphicControl)
  private
    FDrawBuffer: TBitmap;
    FShaddow1,
    FShaddow2,
    FBasecolor,
    FUsedColor: TColor;

    FPosition : Integer;
    procedure SetPosition(value:integer);
    procedure SetBasecolor(value:TColor);
    procedure SetUsedcolor(value:TColor);

  protected
    procedure   Paint; override;
    procedure   UpdateDrawBuffer(h,w:integer);
    procedure   SetBounds(ALeft, ATop, AWidth, AHeight: Integer); //override;

  public
    constructor Create(AnOwner: TWinControl); //override;
    destructor  Destroy; override;
    procedure   Free;

//  published
    { Special properties }
    property Position : integer read FPosition write SetPosition;
    property Basecolor: TColor  read FBasecolor write SetBasecolor;
    property Usedcolor: TColor  read FUsedcolor write SetUsedcolor;
    { Standard events }
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

{ --- Tscope2 ----------------------------------------------------------------- }

constructor TScope.Create(AnOwner:TWinControl);
begin
  inherited Create(AnOwner);
  CanvasInit ;

  DrawBuffer:=TBitmap.Create;
  DrawBuffer.Width := 208;
  DrawBuffer.Height := 120;
  DrawBuffer.Canvas.Brush.Color:=FColor;
  DrawBuffer.Canvas.Brush.Style:=bsSolid;
  DrawBuffer.Canvas.Pen.Width:=1;
  DrawBuffer.Canvas.Pen.Style:=psSolid;

  DrawTimer:=TTimer.Create;
  DrawTimer.OnTimer:=Updatescope2;
  DrawTimer.Enabled:=FALSE;  
  DrawTimer.Interval:=500;

  Height   :=120;
  Width    :=208;
  fAllowed:=FALSE;

  Color    :=clBlack;
  GridColor:=clGreen;
  LineColor:=clLime;
  BaseColor:=clRed;

  BaseLine:=50;
  GridSize:=12;

  FPosition :=50;
  FInterval :=50;
  Counter:=1;

  fAllowed  :=TRUE;
  Clear;
end;

procedure TScope.Loaded;
{ Finished loading, now allow redraw when control is changed
}
begin
//  Inherited Loaded;
  fAllowed:=TRUE;
end;

procedure TScope.Clear;
{ Redraw control, re-calculate grid etc
}
var
  a : integer;
begin
  CalcBase :=(height-round(height/100*FBaseline));
  With DrawBuffer.Canvas do begin
    Brush.Color:=FColor;
    Pen.Style  :=psClear;
    Rectangle(0,0,Width+1,height+1);
    Pen.Style:=psSolid;
    Pen.Color:=FGridColor;
    Pen.Width:=1;
    { Vertical lines }
    a:=Width;
    While a>0 do begin
      MoveTo(a-1,0);
      LineTo(a-1,Height);
      dec(a,FGridSize);
    end;
    { Horizontal lines - above Baseline }
    a:=CalcBase;
    while a<height do begin
      inc(a,FGridSize);
      MoveTo(0    ,a);
      LineTo(Width,a);
    end;
    { Horizontal lines - below Baseline }
    a:=CalcBase;
    while a>0 do begin
      Dec(a,FGridSize);
      MoveTo(0    ,a);
      LineTo(Width,a);
    end;
    { Baseline }
    Pen.Color:=FBaseColor;
    MoveTo(0,CalcBase);
    LineTo(Width,CalcBase);

    { Start new position-line on baseline... }
    OldPos   :=CalcBase;
    PrevPos  :=CalcBase;
    {
    // Draws a line from 0,baseline to width, new pos
    Pen.Color:=FLineColor;
    MoveTo(0,height);
    LineTo(Width,height-round(height/100*position));
    }
    counter:=1;
  end;
end;

procedure TScope.Free;
{ Free control and all internal objects
}
begin
  DrawTimer .Free;
  DrawBuffer.Free;
  Inherited Free;
end;

destructor TScope.Destroy;
begin
  if DrawTimer<>nil then DrawTimer.Destroy;
  if DrawBuffer<>nil then DrawBuffer.Destroy;
  inherited Destroy;
end;

procedure TScope.SetBaseLine(value:integer);
{ Set base-linje value
}
begin
  fBaseLine:=value;
  CalcBase :=(height-round(height/100*FBaseline));
  if fAllowed then begin
    Clear;
    {if parent<>NIl then }Paint;
  end;
end;

procedure TScope.SetInterval(value:integer);
{ Set Scroll delay
}
begin
  DrawTimer.Enabled :=FALSE;
  CalcBase :=(height-round(height/100*FBaseline));
  DrawTimer.Interval:=value*10;
  fInterval:=value;
  DrawTimer.Enabled :=FActive;
end;

procedure TScope.SetGridSize(value:integer);
{ Set grid size }
begin
  fGridSize:=(value div 2)*2;
  if fAllowed then begin
    Clear;
    {if parent<>NIl then }Paint;
  end;
end;

procedure TScope.SetActive(value:boolean);
{ Start scrolling
}
begin
  CalcBase :=(height-round(height/100*FBaseline));
  DrawTimer.Interval:=Interval*10;
  DrawTimer.Enabled :=value;
  fActive:=Value;
end;

procedure TScope.Updatescope2(Sender:TObject);
var
  a : integer;
  Des, Src : TRect;
begin
  With DrawBuffer.Canvas do begin
    Pen.Color:=FGridColor;

    Des.Top   :=0;
    Des.Left  :=0;
    Des.Right :=Width-2;
    Des.Bottom:=Height;

    Src.Top   :=0;
    Src.Left  :=2;
    Src.Right :=Width;
    Src.Bottom:=Height;
    { Copy bitmap leftwards }
    CopyRect(Des,DrawBuffer.Canvas,Src);

    { Draw new area }
    Pen.Color:=FColor;
    Pen.Width:=2;
    MoveTo(Width-1,0);
    LineTo(Width-1,Height);
    Pen.Color:=FGridColor;
    Pen.Width:=1;
    { Draw vertical line if needed }
    If counter=(GridSize div 2) then begin
      MoveTo(Width-1,0);
      LineTo(Width-1,Height);
      counter:=0;
    end;
    Inc(counter);
    { Horizontal lines - above Baseline }
    a:=CalcBase;
    while a<height do begin
      inc(a,FGridSize);
      MoveTo(Width-2,a);
      LineTo(Width  ,a);
    end;
    { Horizontal lines - below Baseline }
    a:=CalcBase;
    while a>0 do begin
      Dec(a,FGridSize);
      MoveTo(Width-2,a);
      LineTo(Width  ,a);
    end;
    { Baseline }
    Pen.Color:=FBaseColor;
    MoveTo(Width-2,CalcBase);
    LineTo(Width  ,CalcBase);
    { Draw position for line }
    Pen.Color:=FLineColor;
    a:=height-round(height/100*position);
    MoveTo(Width-4,OldPos);
    LineTo(Width-2,PrevPos);
    LineTo(Width-0,a);
    OldPos :=PrevPos;
    PrevPos:=a;
  end;
  paint;
  If assigned(FOnUpdate) then fOnUpdate(SELF);
end;

procedure TScope.Paint;
var
  Rect : TRect;
begin
  //Inherited Paint;
  DrawBuffer.Height:=Height;
  DrawBuffer.Width :=Width;
  Rect.Top:=0;
  Rect.Left:=0;
  Rect.Right:=Width;
  Rect.Bottom:=Height;
  Canvas.CopyRect(Rect, DrawBuffer.Canvas, Rect);
  FAllowed:=True;


  //DrawBuffer.Draw(Canvas.Handle, 0, 0);
end;

procedure TScope.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
{ Recalulate control after move and/or resize
}
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  DrawBuffer.Height:=Height;
  DrawBuffer.Width :=Width;
//  if (csDesigning in ComponentState) and (fAllowed) then begin
//    Clear;
//  end;
end;     

{ --- TSimplePie2 ------------------------------------------------------------- }

function SetShaddow(color:TColor):TColor;
type
  ColorConvert = record
    case byte of
      0 : (z:TColor);
      1 : (a,b,c,d : byte);
  end;
begin
  ColorConvert(result).a:=ColorConvert(color).a div 2;
  ColorConvert(result).b:=ColorConvert(color).b div 2;
  ColorConvert(result).c:=ColorConvert(color).c div 2;
  ColorConvert(result).d:=ColorConvert(color).d div 2;
end;

constructor TSimplePie.Create(AnOwner:TWinControl);
begin
  inherited Create(AnOwner);
  CanvasInit ;
  Height    := 64;
  Width     :=128;
  FDrawBuffer:=TBitmap.Create;
  FDrawBuffer.Width :=Width;
  FDrawBuffer.Height:=Height;
  FPosition := 64;
  FBaseColor:=$00FF00FF;
  FUsedColor:=$00FF0000;
  FShaddow1 :=SetShaddow(FBaseColor);
  FShaddow2 :=SetShaddow(FUsedColor);
  UpdateDrawBuffer(height,width);
end;

destructor  TSimplePie.Destroy;
begin
  if FDrawBuffer<>NIL then
    FDrawBuffer.Destroy;
  Inherited Destroy;
end;

procedure TSimplePie.Free;
begin
  FDrawBuffer.Free;
  Inherited Free;
end;

procedure TSimplePie.SetPosition(value:integer);
begin
  if value>100 then value:=100;
  if value<  0 then value:=  0;
  FPosition:=Value;
  UpdateDrawBuffer(height,width);
  Paint;
end;

procedure TSimplePie.UpdateDrawBuffer(h,w:integer);
var
  x,y : integer;
begin
  With FDrawBuffer.Canvas do begin
    h:=h-12;
    w:=w- 1;
    Brush.Color:=clBtnFace;
    Pen.Color  :=clBtnFace;
    Rectangle(0,0,w+2,h+14);
    // Top
    Pen.Color  :=clBlack;
    Brush.Color:=FBasecolor;
    Ellipse(  1,  1, 1+w, 1+h);
    Arc    (  1, 12, 1+w, 12+h, 1,12+(h div 2),1+w,12+(h div 2) );
    Moveto (  1, 12+(h div 2));
    LineTo (  1,  1+(h div 2));
    LineTo (  1+w div 2,1+(h div 2));
    Moveto (  w, 12+(h div 2));
    LineTo (  w,  1+(h div 2));
    // Calc point on ellipse using position
    x:=round(1+(w div 2)-cos(2*pi/100*position)*(w div 2));
    y:=round(1+(h div 2)-sin(2*pi/100*position)*(h div 2));
    // Draw line from center to point
    MoveTo(1+(w div 2),1+(h div 2));
    LineTo(          x,          y);
    // Fill area
    Brush.Color:=FUsedcolor;
    If position>0 then
      FloodFill(2,h div 2,clBlack,fsBorder);
    If position>51 then begin
      LineTo(          x,       11+y);
      Brush.Color:=FShaddow2;
      FloodFill(w-1,12+(h div 2),clBlack,fsBorder);
    end;
    if position<98 then begin
      Brush.Color:=FShaddow1;
      FloodFill(  2,12+(h div 2),clBlack,fsBorder);
    end;
  end;
end;

procedure TSimplePie.Paint;
begin
  inherited Paint;
  //Canvas.Draw(0,0,FDrawBuffer);
  FDrawBuffer.Draw(Canvas.Handle, 0, 0);
end;

procedure TSimplePie.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(aLeft,aTop,aWidth,aHeight);
  If FDrawBuffer<>NIL then begin
    FDrawBuffer.Destroy;
    FDrawBuffer:=TBitmap.Create;
    FDrawBuffer.Height:=aHeight;
    FDrawBuffer.Width :=aWidth;
    UpdateDrawBuffer(aHeight,aWidth);
  end;
end;

procedure TSimplePie.SetBasecolor(value:TColor);
begin
  FBasecolor:=value;
  FShaddow1:=SetShaddow(FBaseColor);
  UpdateDrawBuffer(height,width);
  Paint;
end;

procedure TSimplePie.SetUsedColor(value:TColor);
begin
  FUsedColor:=value;
  FShaddow2:=SetShaddow(FUsedColor);
  UpdateDrawBuffer(height,width);
  Paint;
end;

{ --- Tindicator2 ------------------------------------------------------------- }

constructor TIndicator.Create(anOwner: TWinControl);
begin
  inherited Create(anOwner);
  CanvasInit;

  Height     :=  128;
  Width      :=   32;
  FPosition  :=    40;

  FDrawBuffer := TBitmap.Create ;
  FDrawBuffer.Width := Width;
  FDrawBuffer.Height := Height;

  FForeground:=clLime;
  FBackground:=clBlack;
  FShaddow   :=SetShaddow(FForeground);
end;

destructor  TIndicator.Destroy;
begin
  If FDrawBuffer<>NIL then
    FDrawBuffer.free;
  Inherited Destroy;
end;

procedure TIndicator.Free;
begin
  FDrawBuffer.Free;
  Inherited Free;
end;

procedure TIndicator.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  Inherited ;
  If FDrawBuffer<>NIL then begin
    FDrawBuffer.Destroy;
    FDrawBuffer:=TBitmap.Create;
    FDrawBuffer.Height:=aHeight;
    FDrawBuffer.Width :=aWidth;
  end;
end;

procedure TIndicator.UpdateDrawBuffer;
var
  a,b,c,d,n : integer;
begin
  With FDrawBuffer.Canvas do begin
    Brush.Color:=FBackground;
    Pen.Color:=FBackground;
    Rectangle(0,0,width,height);
    n:=(height) div 3-2;
    b:=(width div 2);
    d:=round(n/256*(256-position));
    Pen.Color:=FShaddow;
    For a:=0 to n do begin
      if a=d then
        Pen.Color:=FForeground;
      c:=3*a+2;
      MoveTo(b-1,c); LineTo(4,c);
      MoveTo(b+1,c); LineTo(Width-5,c);
      c:=3*a+3;
      MoveTo(b+1,c); LineTo(Width-5,c);
      MoveTo(b-1,c); LineTo(4,c);
    end;
  end;
end;

procedure TIndicator.Paint;
begin
  UpdateDrawBuffer;
//  Canvas.Draw(0,0,FDrawbuffer);
  FDrawbuffer.Draw(Canvas.Handle, 0, 0);
end;

procedure TIndicator.SetForeground(value:TColor);
begin
  FShaddow:=SetShaddow(value);
  FForeground:=value;
  UpdateDrawBuffer;
  Paint;
end;

procedure TIndicator.SetBackground(value:TColor);
begin
  FBackground:=value;
  UpdateDrawBuffer;
  Paint;
end;

procedure TIndicator.SetPosition(value:integer);
begin
  If value>256 then value:=256;
  If value<  0 then value:=  0;
  FPosition:=Value;
  Paint;
end;

end.




