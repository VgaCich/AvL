{-------------------------------------}
{              .::Avl::.              }
{      Version 1.06V from 14.09.06    }
{                                     }
{      http://www.nht-team.org/       }
{      E-Mail: xavenger@mail.ru       }
{-------------------------------------}

unit Avl;

{$O+}                               //Оптимизация кода включена

{$IFDEF VER140} { Delphi 6 }        //////////////////////////////////////////
  {$WARN SYMBOL_DEPRECATED OFF}     //Это строки отключают показ сообщений
  {$WARN SYMBOL_PLATFORM OFF}       //связанных с платформой .NET
{$ENDIF}                            //
                                    //
{$IFDEF VER150} { Delphi 7 }        //
  {$WARN SYMBOL_DEPRECATED OFF}     //          {$WARNINGS OFF}
  {$WARN SYMBOL_PLATFORM OFF}       //можно использовать только эту директиву
  {$WARN UNSAFE_CODE OFF}           //но она отключит все сообщения!
  {$WARN UNSAFE_TYPE OFF}           //
  {$WARN UNSAFE_CAST OFF}           //
{$ENDIF}                            //////////////////////////////////////////

{-----------------------------------------------------------------------------}

{$define EraseBkgnd}
{$define CtlColor}
{$define Paint}
{$define Command}
{$define Close}
{$define KeyDown}
{$define KeyUp}
{$define LButtonDown}
{$define LButtonUp}
{$define LButtonDblClk}
{$define RButtonDown}
{$define RButtonUp}
{$define MButtonDown}
{$define MButtonUp}
{$define MouseMove}
{$define SetFocus}
{$define KillFocus}
{$define Size}
{$define SysCommand}
{$define SetCursor}// - это пока не работает!

{
  Каждая из этих строк - одно сообщение, включая/выключая их можно уменьшить
  размер программы.

  Например если не используется смена цветов контролов и формы, и обработка
  сообщения OnPaint, то можно закомментировать строки в которых есть:
  EraseBkgnd, CtlColor и Paint.

------------------------------------------------------------------------------}

{$define asm_ver}

{ Если эта строка расскоментирована, то используются вставки на ассемблере,
  иначе используется только Pascal, желательно использовать ассемблер! }

//{$define CanvasAutoCreate}

{ Если эта строка расскоментирована, то Canvas будет создаваться автоматом,
  как в VCL если не создавать автоматом, то его всегда можно будет создать так:

  Button1.Canvas := TCanvas.Create(Button1.Handle)       - для Canvas
  Button1.Canvas.Brush := TBrush.Create(Button1.Canvas)  - для Brush
  Button1.Canvas.Pen := TPen.Create(Button1.Canvas)      - для Pen

  или так:

  Button1.CanvasInit ;

  Если Вы не собираетесь при рисовании использовать возможности Brush и/или
  Pen, то не создавайте их, тем самым с экономив ~ 1 Кб ;)

------------------------------------------------------------------------------}

{$define FontAutoCreate}

{ Если эта строка расскоментирована, то Font будет создаваться автоматом и
  все надписи на контролах будут выглядеть как в VCL.

  Если вы где-нить меняете шрифт вручную, то объект Font должен быть создан,
  это можно сделать так:

  Button1.Font := TFont.Create;
  Button1.Font.Control := Button1;

  Если Вас устраивают стандартный шрифт то не создавайте Font, тогда Вы
  сэкономите ~ 0.5 Кб ;)
  
------------------------------------------------------------------------------}

interface

uses Windows, Messages;

type
  TColor = Integer;
  TCursor = Integer;

const
  EoL  = #0;
  Cr   = #13;
  Lf   = #10;
  CrLf = #13#10;

  DefRec = '<Нет>';   //23.02.04
  _DefRec = '<None>'; //23.02.04

 { Colors }

  clScrollBar = TColor(COLOR_SCROLLBAR or $80000000);
  clBackground = TColor(COLOR_BACKGROUND or $80000000);
  clActiveCaption = TColor(COLOR_ACTIVECAPTION or $80000000);
  clInactiveCaption = TColor(COLOR_INACTIVECAPTION or $80000000);
  clMenu = TColor(COLOR_MENU or $80000000);
  clWindow = TColor(COLOR_WINDOW or $80000000);
  clWindowFrame = TColor(COLOR_WINDOWFRAME or $80000000);
  clMenuText = TColor(COLOR_MENUTEXT or $80000000);
  clWindowText = TColor(COLOR_WINDOWTEXT or $80000000);
  clCaptionText = TColor(COLOR_CAPTIONTEXT or $80000000);
  clActiveBorder = TColor(COLOR_ACTIVEBORDER or $80000000);
  clInactiveBorder = TColor(COLOR_INACTIVEBORDER or $80000000);
  clAppWorkSpace = TColor(COLOR_APPWORKSPACE or $80000000);
  clHighlight = TColor(COLOR_HIGHLIGHT or $80000000);
  clHighlightText = TColor(COLOR_HIGHLIGHTTEXT or $80000000);
  clBtnFace = TColor(COLOR_BTNFACE or $80000000);
  clBtnShadow = TColor(COLOR_BTNSHADOW or $80000000);
  clGrayText = TColor(COLOR_GRAYTEXT or $80000000);
  clBtnText = TColor(COLOR_BTNTEXT or $80000000);
  clInactiveCaptionText = TColor(COLOR_INACTIVECAPTIONTEXT or $80000000);
  clBtnHighlight = TColor(COLOR_BTNHIGHLIGHT or $80000000);
  cl3DDkShadow = TColor(COLOR_3DDKSHADOW or $80000000);
  cl3DLight = TColor(COLOR_3DLIGHT or $80000000);
  clInfoText = TColor(COLOR_INFOTEXT or $80000000);
  clInfoBk = TColor(COLOR_INFOBK or $80000000);

  clBlack = TColor($000000);
  clMaroon = TColor($000080);
  clGreen = TColor($008000);
  clOlive = TColor($008080);
  clNavy = TColor($800000);
  clPurple = TColor($800080);
  clTeal = TColor($808000);
  clGray = TColor($808080);
  clSilver = TColor($C0C0C0);
  clRed = TColor($0000FF);
  clLime = TColor($00FF00);
  clYellow = TColor($00FFFF);
  clBlue = TColor($FF0000);
  clFuchsia = TColor($FF00FF);
  clAqua = TColor($FFFF00);
  clLtGray = TColor($C0C0C0);
  clDkGray = TColor($808080);
  clWhite = TColor($FFFFFF);
  clNone = TColor($1FFFFFFF);
  clDefault = TColor($20000000);

  { Canvas CopyMode }

  cmBlackness = BLACKNESS;
  cmDstInvert = DSTINVERT;
  cmMergeCopy = MERGECOPY;
  cmMergePaint = MERGEPAINT;
  cmNotSrcCopy = NOTSRCCOPY;
  cmNotSrcErase = NOTSRCERASE;
  cmPatCopy = PATCOPY;
  cmPatInvert = PATINVERT;
  cmPatPaint = PATPAINT;
  cmSrcAnd = SRCAND;
  cmSrcCopy = SRCCOPY;
  cmSrcErase = SRCERASE;
  cmSrcInvert = SRCINVERT;
  cmSrcPaint = SRCPAINT;
  cmWhiteness = WHITENESS;

  { Cursors }

  crDefault     = TCursor(0);
  crNone        = TCursor(-1);
  crArrow       = TCursor(-2);
  crCross       = TCursor(-3);
  crIBeam       = TCursor(-4);
  crSize        = TCursor(-22);
  crSizeNESW    = TCursor(-6);
  crSizeNS      = TCursor(-7);
  crSizeNWSE    = TCursor(-8);
  crSizeWE      = TCursor(-9);
  crUpArrow     = TCursor(-10);
  crHourGlass   = TCursor(-11);
  crDrag        = TCursor(-12);
  crNoDrop      = TCursor(-13);
  crHSplit      = TCursor(-14);
  crVSplit      = TCursor(-15);
  crMultiDrag   = TCursor(-16);
  crSQLWait     = TCursor(-17);
  crNo          = TCursor(-18);
  crAppStart    = TCursor(-19);
  crHelp        = TCursor(-20);
  crHandPoint   = TCursor(-21);
  crSizeAll     = TCursor(-22);

  { icon indexes for standard bitmap }

  STD_CUT                 = 0;
  STD_COPY                = 1;
  STD_PASTE               = 2;
  STD_UNDO                = 3;
  STD_REDOW               = 4;
  STD_DELETE              = 5;
  STD_FILENEW             = 6;
  STD_FILEOPEN            = 7;
  STD_FILESAVE            = 8;
  STD_PRINTPRE            = 9;
  STD_PROPERTIES          = 10;
  STD_HELP                = 11;
  STD_FIND                = 12;
  STD_REPLACE             = 13;
  STD_PRINT               = 14;

  { OpenDialog }

  OFN_READONLY = $00000001;
  OFN_OVERWRITEPROMPT = $00000002;
  OFN_HIDEREADONLY = $00000004;
  OFN_NOCHANGEDIR = $00000008;
  OFN_SHOWHELP = $00000010;
  OFN_ENABLEHOOK = $00000020;
  OFN_ENABLETEMPLATE = $00000040;
  OFN_ENABLETEMPLATEHANDLE = $00000080;
  OFN_NOVALIDATE = $00000100;
  OFN_ALLOWMULTISELECT = $00000200;
  OFN_EXTENSIONDIFFERENT = $00000400;
  OFN_PATHMUSTEXIST = $00000800;
  OFN_FILEMUSTEXIST = $00001000;
  OFN_CREATEPROMPT = $00002000;
  OFN_SHAREAWARE = $00004000;
  OFN_NOREADONLYRETURN = $00008000;
  OFN_NOTESTFILECREATE = $00010000;
  OFN_NONETWORKBUTTON = $00020000;
  OFN_NOLONGNAMES = $00040000;
  OFN_EXPLORER = $00080000;
  OFN_NODEREFERENCELINKS = $00100000;
  OFN_LONGNAMES = $00200000;
  OFN_ENABLEINCLUDENOTIFY = $00400000;
  OFN_ENABLESIZING = $00800000;

  { TStream seek origins }

  soFromBeginning = FILE_BEGIN;
  soFromCurrent = FILE_CURRENT;
  soFromEnd = FILE_END;  

  { TFileStream create mode }

  fmCreate = $FFFF;

  { File open modes }

  fmOpenRead       = $0000;
  fmOpenWrite      = $0001;
  fmOpenReadWrite  = $0002;
  fmShareCompat    = $0000;
  fmShareExclusive = $0010;
  fmShareDenyWrite = $0020;
  fmShareDenyRead  = $0030;
  fmShareDenyNone  = $0040;

  { File attribute constants }

  faReadOnly  = $00000001;
  faHidden    = $00000002;
  faSysFile   = $00000004;
  faVolumeID  = $00000008;
  faDirectory = $00000010;
  faArchive   = $00000020;
  faAnyFile   = $0000003F;

{ File mode magic numbers }

  fmClosed = $D7B0;
  fmInput  = $D7B1;
  fmOutput = $D7B2;
  fmInOut  = $D7B3;

  { TStringList }

  MaxListSize = Maxint div 16;

  { Def Control Position/Size }

  Cw_UseDefault = Integer($80000000);

  { Form Position }

  poDefault      = 0;
  poScreenCenter = 1;

  { WindowState }

  wsMaximized = SW_MAXIMIZE;
  wsMinimized = SW_MINIMIZE;
  wsNormal    = SW_NORMAL;

  { TCommonControls Notify }

  NM_FIRST                 = 0-  0;       { generic to all controls }

  NM_OUTOFMEMORY           = NM_FIRST-1;
  NM_CLICK                 = NM_FIRST-2;
  NM_DBLCLK                = NM_FIRST-3;
  NM_RETURN                = NM_FIRST-4;
  NM_RCLICK                = NM_FIRST-5;
  NM_RDBLCLK               = NM_FIRST-6;
  NM_SETFOCUS              = NM_FIRST-7;
  NM_KILLFOCUS             = NM_FIRST-8;
  NM_CUSTOMDRAW            = NM_FIRST-12;
  NM_HOVER                 = NM_FIRST-13;
  NM_NCHITTEST             = NM_FIRST-14;   // uses NMMOUSE struct
  NM_KEYDOWN               = NM_FIRST-15;   // uses NMKEY struct
  NM_RELEASEDCAPTURE       = NM_FIRST-16;
  NM_SETCURSOR             = NM_FIRST-17;   // uses NMMOUSE struct
  NM_CHAR                  = NM_FIRST-18;   // uses NMCHAR struct

  { TTabControl }

  TCS_SCROLLOPPOSITE    = $0001;  // assumes multiline tab
  TCS_BOTTOM            = $0002;
  TCS_RIGHT             = $0002;
  TCS_MULTISELECT       = $0004;  // allow multi-select in button mode
  TCS_FLATBUTTONS       = $0008;
  TCS_FORCEICONLEFT     = $0010;
  TCS_FORCELABELLEFT    = $0020;
  TCS_HOTTRACK          = $0040;
  TCS_VERTICAL          = $0080;
  TCS_TABS              = $0000;
  TCS_BUTTONS           = $0100;
  TCS_SINGLELINE        = $0000;
  TCS_MULTILINE         = $0200;
  TCS_RIGHTJUSTIFY      = $0000;
  TCS_FIXEDWIDTH        = $0400;
  TCS_RAGGEDRIGHT       = $0800;
  TCS_FOCUSONBUTTONDOWN = $1000;
  TCS_OWNERDRAWFIXED    = $2000;
  TCS_TOOLTIPS          = $4000;
  TCS_FOCUSNEVER        = $8000;

  TCM_FIRST               = $1300;      { Tab control messages }

  TCN_FIRST                = 0-550;       { tab control }

  TCM_GETIMAGELIST       = TCM_FIRST + 2;
  TCM_SETIMAGELIST       = TCM_FIRST + 3;
  TCM_GETITEMCOUNT       = TCM_FIRST + 4;
  TCM_DELETEITEM         = TCM_FIRST + 8;
  TCM_DELETEALLITEMS     = TCM_FIRST + 9;
  TCM_GETITEMRECT        = TCM_FIRST + 10;
  TCM_GETCURSEL          = TCM_FIRST + 11;
  TCM_SETCURSEL          = TCM_FIRST + 12;
  TCM_HITTEST            = TCM_FIRST + 13;
  TCM_SETITEMEXTRA       = TCM_FIRST + 14;
  TCM_ADJUSTRECT         = TCM_FIRST + 40;
  TCM_SETITEMSIZE        = TCM_FIRST + 41;
  TCM_REMOVEIMAGE        = TCM_FIRST + 42;
  TCM_SETPADDING         = TCM_FIRST + 43;
  TCM_GETROWCOUNT        = TCM_FIRST + 44;
  TCM_GETTOOLTIPS        = TCM_FIRST + 45;
  TCM_SETTOOLTIPS        = TCM_FIRST + 46;
  TCM_GETCURFOCUS        = TCM_FIRST + 47;
  TCM_SETCURFOCUS        = TCM_FIRST + 48;
  TCM_SETMINTABWIDTH     = TCM_FIRST + 49;
  TCM_DESELECTALL        = TCM_FIRST + 50;
  TCM_HIGHLIGHTITEM      = TCM_FIRST + 51;
  TCM_SETEXTENDEDSTYLE   = TCM_FIRST + 52;  // optional wParam == mask
  TCM_GETEXTENDEDSTYLE   = TCM_FIRST + 53;

  TCIF_TEXT       = $0001;
  TCIF_IMAGE      = $0002;
  TCIF_RTLREADING = $0004;
  TCIF_PARAM      = $0008;
  TCIF_STATE      = $0010;

  TCM_GETITEM             = TCM_FIRST + 5;
  TCM_SETITEM             = TCM_FIRST + 6;
  TCM_INSERTITEM          = TCM_FIRST + 7;

//Events
  TCN_KEYDOWN             = TCN_FIRST - 0;
  TCN_SELCHANGE           = TCN_FIRST - 1;
  TCN_SELCHANGING         = TCN_FIRST - 2;
  TCN_GETOBJECT           = TCN_FIRST - 3;

  { TRichEdit }

  EM_EXLIMITTEXT                      = WM_USER + 53; 
  EM_SETBKGNDCOLOR                    = WM_USER + 67;
  EM_REDO                             = WM_USER + 84; 
  EM_CANREDO                          = WM_USER + 85;

  { TTrackBar }

  TBS_AUTOTICKS           = $0001;
  TBS_VERT                = $0002;
  TBS_HORZ                = $0000;
  TBS_TOP                 = $0004;
  TBS_BOTTOM              = $0000;
  TBS_LEFT                = $0004;
  TBS_RIGHT               = $0000;
  TBS_BOTH                = $0008;
  TBS_NOTICKS             = $0010;
  TBS_ENABLESELRANGE      = $0020;
  TBS_FIXEDLENGTH         = $0040;
  TBS_NOTHUMB             = $0080;
  TBS_TOOLTIPS            = $0100;

  TBM_GETPOS              = WM_USER;
  TBM_GETRANGEMIN         = WM_USER+1;
  TBM_GETRANGEMAX         = WM_USER+2;

  TBM_SETPOS              = WM_USER+5;  // +
  TBM_SETRANGEMIN         = WM_USER+7;  // +
  TBM_SETRANGEMAX         = WM_USER+8;  // +  

  { TProgressBar }

  PBS_SMOOTH              = 01;
  PBS_VERTICAL            = 04;

  PBM_SETRANGE            = WM_USER+1;
  PBM_SETPOS              = WM_USER+2;
  PBM_SETSTEP             = WM_USER+4;

  { TUpDown }

  REFRESH_PERIOD : Cardinal = 1;

  UDS_SETBUDDYINT         = $0002;  

  UDN_FIRST                = 0-721;
  UDN_DELTAPOS            = UDN_FIRST-1;    

  UDM_SETRANGE            = WM_USER+101;
  UDM_GETRANGE            = WM_USER+102;
  UDM_SETPOS              = WM_USER+103;
  UDM_GETPOS              = WM_USER+104;
  UDM_SETBUDDY            = WM_USER+105;
  UDM_GETBUDDY            = WM_USER+106;
  UDM_SETACCEL            = WM_USER+107;
  UDM_GETACCEL            = WM_USER+108;
  UDM_SETBASE             = WM_USER+109;
  UDM_GETBASE             = WM_USER+110;
  UDM_SETRANGE32          = WM_USER+111;
  UDM_GETRANGE32          = WM_USER+112;
  UDM_SETPOS32            = WM_USER+113;
  UDM_GETPOS32            = WM_USER+114;

  { THotKey }

  HKM_SETHOTKEY           = WM_USER+1;
  HKM_GETHOTKEY           = WM_USER+2;

  { TAnimate }

  ACM_OPEN                = WM_USER + 100;
  ACM_PLAY                = WM_USER + 101;
  ACM_STOP                = WM_USER + 102;

  { TDateTimePicker }

  DTS_SHORTDATEFORMAT = $0000;  // use the short date format
  DTS_UPDOWN          = $0001;  // use UPDOWN instead of MONTHCAL
  DTS_LONGDATEFORMAT  = $0004;  // use the long date format
  DTS_TIMEFORMAT      = $0009;  // use the time format


  DTM_FIRST         = $1000;
  DTM_GETSYSTEMTIME = DTM_FIRST + 1;
  DTM_SETSYSTEMTIME = DTM_FIRST + 2;

  GDT_VALID = 0;

  { TTreeView }

  {$EXTERNALSYM TVS_HASBUTTONS}
  TVS_HASBUTTONS          = $0001;
  {$EXTERNALSYM TVS_HASLINES}
  TVS_HASLINES            = $0002;
  {$EXTERNALSYM TVS_LINESATROOT}
  TVS_LINESATROOT         = $0004;
  {$EXTERNALSYM TVS_EDITLABELS}
  TVS_EDITLABELS          = $0008;
  {$EXTERNALSYM TVS_DISABLEDRAGDROP}
  TVS_DISABLEDRAGDROP     = $0010;
  {$EXTERNALSYM TVS_SHOWSELALWAYS}
  TVS_SHOWSELALWAYS       = $0020;
  {$EXTERNALSYM TVS_RTLREADING}
  TVS_RTLREADING          = $0040;
  {$EXTERNALSYM TVS_NOTOOLTIPS}
  TVS_NOTOOLTIPS          = $0080;
  {$EXTERNALSYM TVS_CHECKBOXES}
  TVS_CHECKBOXES          = $0100;
  {$EXTERNALSYM TVS_TRACKSELECT}
  TVS_TRACKSELECT         = $0200;
  {$EXTERNALSYM TVS_SINGLEEXPAND}
  TVS_SINGLEEXPAND        = $0400;
  {$EXTERNALSYM TVS_INFOTIP}
  TVS_INFOTIP             = $0800;
  {$EXTERNALSYM TVS_FULLROWSELECT}
  TVS_FULLROWSELECT       = $1000;
  {$EXTERNALSYM TVS_NOSCROLL}
  TVS_NOSCROLL            = $2000;
  {$EXTERNALSYM TVS_NONEVENHEIGHT}
  TVS_NONEVENHEIGHT       = $4000;

  TV_FIRST                = $1100;      { TreeView messages }

  TVM_SETIMAGELIST        = TV_FIRST + 9;

  TVSIL_NORMAL            = 0;
  TVSIL_STATE             = 2;

type
  HTREEITEM = ^_TREEITEM;
  _TREEITEM = packed record
  end;

const
  TVI_ROOT                = HTreeItem($FFFF0000);
  TVI_FIRST               = HTreeItem($FFFF0001);
  TVI_LAST                = HTreeItem($FFFF0002);
  TVI_SORT                = HTreeItem($FFFF0003);

  TVIF_TEXT               = $0001;
  {$EXTERNALSYM TVIF_IMAGE}
  TVIF_IMAGE              = $0002;
  {$EXTERNALSYM TVIF_PARAM}
  TVIF_PARAM              = $0004;
  {$EXTERNALSYM TVIF_STATE}
  TVIF_STATE              = $0008;
  {$EXTERNALSYM TVIF_HANDLE}
  TVIF_HANDLE             = $0010;
  {$EXTERNALSYM TVIF_SELECTEDIMAGE}
  TVIF_SELECTEDIMAGE      = $0020;
  {$EXTERNALSYM TVIF_CHILDREN}
  TVIF_CHILDREN           = $0040;
  {$EXTERNALSYM TVIF_INTEGRAL}
  TVIF_INTEGRAL           = $0080;

//msg
  TVM_INSERTITEMA          = TV_FIRST + 0;
  TVM_INSERTITEM          = TVM_INSERTITEMA;

  { TListView }

  LVM_FIRST               = $1000;      { ListView messages }

  {$EXTERNALSYM LVM_GETITEMCOUNT}
  LVM_GETITEMCOUNT        = LVM_FIRST + 4;  

  {$EXTERNALSYM LVM_INSERTCOLUMNA}
  LVM_INSERTCOLUMNA        = LVM_FIRST + 27;
  {$EXTERNALSYM LVM_INSERTCOLUMNW}
  LVM_INSERTCOLUMNW        = LVM_FIRST + 97;
  {$EXTERNALSYM LVM_INSERTCOLUMN}
  LVM_INSERTCOLUMN        = LVM_INSERTCOLUMNA;
  LVM_GETITEMA            = LVM_FIRST + 5;
  LVM_SETITEMA            = LVM_FIRST + 6;
  LVM_INSERTITEMA         = LVM_FIRST + 7;
  LVM_DELETEITEM          = LVM_FIRST + 8;
  LVM_DELETEALLITEMS      = LVM_FIRST + 9;
  LVM_ENSUREVISIBLE       = LVM_FIRST + 19;
  LVM_GETCOLUMN           = LVM_FIRST + 25;
  LVM_SETCOLUMN           = LVM_FIRST + 26;
  LVM_DELETECOLUMN        = LVM_FIRST + 28;
  LVM_GETITEMTEXTA        = LVM_FIRST + 45;
  LVM_SETITEMTEXT         = LVM_FIRST + 46;
  LVM_SORTITEMS           = LVM_FIRST + 48;
  LVM_SETEXTENDEDLISTVIEWSTYLE = LVM_FIRST + 54;
  LVM_GETSELECTEDCOUNT    = LVM_FIRST + 50;

  LVM_GETITEM            = LVM_GETITEMA;
  LVM_SETITEM            = LVM_SETITEMA;
  LVM_INSERTITEM         = LVM_INSERTITEMA;
  LVM_GETITEMTEXT        = LVM_GETITEMTEXTA;
  LVM_SETITEMPOSITION     = LVM_FIRST + 15;

  LVN_FIRST                = 0-100;       { listview }
  LVN_ITEMCHANGED         = LVN_FIRST-1;
  LVN_KEYDOWN             = LVN_FIRST-55;  

//nextitem

  LVNI_ALL                = $0000;
  LVNI_FOCUSED            = $0001;
  LVNI_SELECTED           = $0002;
  LVNI_CUT                = $0004;
  LVNI_DROPHILITED        = $0008;
  LVNI_ABOVE              = $0100;
  LVNI_BELOW              = $0200;
  LVNI_TOLEFT             = $0400;
  LVNI_TORIGHT            = $0800;

  LVM_GETNEXTITEM         = LVM_FIRST + 12;
  LVM_ARRANGE             = LVM_FIRST + 22;

//arrange

  LVA_DEFAULT             = $0000;
  LVA_ALIGNLEFT           = $0001;
  LVA_ALIGNTOP            = $0002;
  LVA_ALIGNRIGHT          = $0003;
  LVA_ALIGNBOTTOM         = $0004;
  LVA_SNAPTOGRID          = $0005;
  LVA_SORTASCENDING       = $0100;
  LVA_SORTDESCENDING      = $0200;

  { List View Styles }

  LVS_ICON                = $0000;
  LVS_REPORT              = $0001;
  LVS_SMALLICON           = $0002;
  LVS_LIST                = $0003;
  LVS_TYPEMASK            = $0003;
  LVS_SINGLESEL           = $0004;
  LVS_SHOWSELALWAYS       = $0008;
  LVS_SORTASCENDING       = $0010;
  LVS_SORTDESCENDING      = $0020;
  LVS_SHAREIMAGELISTS     = $0040;
  LVS_NOLABELWRAP         = $0080;
  LVS_AUTOARRANGE         = $0100;
  LVS_EDITLABELS          = $0200;
  LVS_OWNERDATA           = $1000;
  LVS_NOSCROLL            = $2000;
  LVS_TYPESTYLEMASK       = $FC00;
  LVS_ALIGNTOP            = $0000;
  LVS_ALIGNLEFT           = $0800;
  LVS_ALIGNMASK           = $0c00;
  LVS_OWNERDRAWFIXED      = $0400;
  LVS_NOCOLUMNHEADER      = $4000;
  LVS_NOSORTHEADER        = $8000;

  { List View Extended Styles }

  LVS_EX_GRIDLINES        = $00000001;
  LVS_EX_SUBITEMIMAGES    = $00000002;
  LVS_EX_CHECKBOXES       = $00000004;
  LVS_EX_TRACKSELECT      = $00000008;
  LVS_EX_HEADERDRAGDROP   = $00000010;
  LVS_EX_FULLROWSELECT    = $00000020; // applies to report mode only
  LVS_EX_ONECLICKACTIVATE = $00000040;
  LVS_EX_TWOCLICKACTIVATE = $00000080;
  LVS_EX_FLATSB           = $00000100;
  LVS_EX_REGIONAL         = $00000200;
  LVS_EX_INFOTIP          = $00000400; // listview does InfoTips for you
  LVS_EX_UNDERLINEHOT     = $00000800;
  LVS_EX_UNDERLINECOLD    = $00001000;
  LVS_EX_MULTIWORKAREAS   = $00002000;

//col

  LVCF_FMT                = $0001;
  LVCF_WIDTH              = $0002;
  LVCF_TEXT               = $0004;
  LVCF_SUBITEM            = $0008;
  LVCF_IMAGE              = $0010;
  LVCF_ORDER              = $0020;

//item

  LVIF_TEXT               = $0001;
  LVIF_IMAGE              = $0002;
  LVIF_PARAM              = $0004;
  LVIF_STATE              = $0008;
  LVIF_INDENT             = $0010;
  LVIF_NORECOMPUTE        = $0800;
  LVIF_DI_SETITEM         = $1000;

  LVIS_FOCUSED            = $0001;
  LVIS_SELECTED           = $0002;
  LVIS_CUT                = $0004;
  LVIS_DROPHILITED        = $0008;  

  { TImageList }

  {$EXTERNALSYM ILC_MASK}
  ILC_MASK                = $0001;
  {$EXTERNALSYM ILC_COLOR}
  ILC_COLOR               = $0000;
  {$EXTERNALSYM ILC_COLORDDB}
  ILC_COLORDDB            = $00FE;
  {$EXTERNALSYM ILC_COLOR4}
  ILC_COLOR4              = $0004;
  {$EXTERNALSYM ILC_COLOR8}
  ILC_COLOR8              = $0008;
  {$EXTERNALSYM ILC_COLOR16}
  ILC_COLOR16             = $0010;
  {$EXTERNALSYM ILC_COLOR24}
  ILC_COLOR24             = $0018;
  {$EXTERNALSYM ILC_COLOR32}
  ILC_COLOR32             = $0020;
  {$EXTERNALSYM ILC_PALETTE}
  ILC_PALETTE             = $0800;

//SetImageList
  LVSIL_NORMAL            = 0;
  LVSIL_SMALL             = 1;
  LVSIL_STATE             = 2;

  LVM_SETIMAGELIST        = LVM_FIRST + 3;  

  { THeaderControl }

  HDS_HORZ                = $00000000;
  HDS_BUTTONS             = $00000002;
  HDS_HOTTRACK            = $00000004;
  HDS_HIDDEN              = $00000008;
  HDS_DRAGDROP            = $00000040;
  HDS_FULLDRAG            = $00000080;

  HDI_WIDTH               = $0001;
  HDI_TEXT                = $0002;
  HDI_FORMAT              = $0004;

  HDF_LEFT                = 0;

  HDM_FIRST               = $1200;      { Header messages }  
  HDM_GETITEMCOUNT        = HDM_FIRST + 0;
  HDM_INSERTITEM          = HDM_FIRST + 1;
  HDM_DELETEITEM          = HDM_FIRST + 2;

  { TStatusBar }

  SB_SETTEXT              = WM_USER + 1;
  SB_GETTEXT              = WM_USER + 2;
  SB_SETPARTS             = WM_USER + 4;
  SB_GETPARTS             = WM_USER + 6;
  SB_SIMPLE               = WM_USER + 9;

  SBT_OWNERDRAW           = $1000;
  SBT_NOBORDERS           = $0100;
  SBT_POPOUT              = $0200;
  SBT_RTLREADING          = $0400;
  SBT_TOOLTIPS            = $0800;

  { TToolBar }

type
  _TBBUTTON = packed record
    iBitmap: Integer;
    idCommand: Integer;
    fsState: Byte;
    fsStyle: Byte;
    bReserved: array[1..2] of Byte;
    dwData: Longint;
    iString: Integer;
  end;
  TTBButton = _TBBUTTON;

  tagTBADDBITMAP = packed record
    hInst: THandle;
    nID: UINT;
  end;
  TTBAddBitmap = tagTBADDBITMAP;

const
  TBSTATE_CHECKED         = $01;
  TBSTATE_PRESSED         = $02;
  TBSTATE_ENABLED         = $04;
  TBSTATE_HIDDEN          = $08;
  TBSTATE_INDETERMINATE   = $10;
  TBSTATE_WRAP            = $20;
  TBSTATE_ELLIPSES        = $40;
  TBSTATE_MARKED          = $80;

  TBSTYLE_BUTTON          = $00;
  TBSTYLE_SEP             = $01;
  TBSTYLE_CHECK           = $02;
  TBSTYLE_GROUP           = $04;
  TBSTYLE_CHECKGROUP      = TBSTYLE_GROUP or TBSTYLE_CHECK;
  TBSTYLE_DROPDOWN        = $08;
  TBSTYLE_AUTOSIZE        = $0010; // automatically calculate the cx of the button
  TBSTYLE_NOPREFIX        = $0020; // if this button should not have accel prefix

  TBSTYLE_TOOLTIPS        = $0100;
  TBSTYLE_WRAPABLE        = $0200;
  TBSTYLE_ALTDRAG         = $0400;
  TBSTYLE_FLAT            = $0800;
  TBSTYLE_LIST            = $1000;
  TBSTYLE_CUSTOMERASE     = $2000;
  TBSTYLE_REGISTERDROP    = $4000;
  TBSTYLE_TRANSPARENT     = $8000;
  TBSTYLE_EX_DRAWDDARROWS = $00000001;

  TB_CHECKBUTTON          = WM_USER + 2;
  TB_PRESSBUTTON          = WM_USER + 3;
  TB_ISBUTTONCHECKED      = WM_USER + 10;
  TB_ISBUTTONPRESSED      = WM_USER + 11;
  TB_ADDBITMAP            = WM_USER + 19;
  TB_ADDBUTTONS           = WM_USER + 20;
  TB_GETBUTTON            = WM_USER + 23;
  TB_BUTTONCOUNT          = WM_USER + 24;
  TB_ADDSTRING            = WM_USER + 28;
  TB_BUTTONSTRUCTSIZE     = WM_USER + 30;
  TB_AUTOSIZE             = WM_USER + 33;  
  TB_CHANGEBITMAP         = WM_USER + 43;
  TB_GETBUTTONTEXT        = WM_USER + 45;
  TB_SETINDENT            = WM_USER + 47;
  TB_SETIMAGELIST         = WM_USER + 48;
  
  { TFontDialog }

  {$EXTERNALSYM CF_SCREENFONTS}
  CF_SCREENFONTS = $00000001;
  {$EXTERNALSYM CF_PRINTERFONTS}
  CF_PRINTERFONTS = $00000002;
  {$EXTERNALSYM CF_BOTH}
  CF_BOTH = CF_SCREENFONTS OR CF_PRINTERFONTS;
  {$EXTERNALSYM CF_SHOWHELP}
  CF_SHOWHELP = $00000004;
  {$EXTERNALSYM CF_ENABLEHOOK}
  CF_ENABLEHOOK = $00000008;
  {$EXTERNALSYM CF_ENABLETEMPLATE}
  CF_ENABLETEMPLATE = $00000010;
  {$EXTERNALSYM CF_ENABLETEMPLATEHANDLE}
  CF_ENABLETEMPLATEHANDLE = $00000020;
  {$EXTERNALSYM CF_INITTOLOGFONTSTRUCT}
  CF_INITTOLOGFONTSTRUCT = $00000040;
  {$EXTERNALSYM CF_USESTYLE}
  CF_USESTYLE = $00000080;
  {$EXTERNALSYM CF_EFFECTS}
  CF_EFFECTS = $00000100;
  {$EXTERNALSYM CF_APPLY}
  CF_APPLY = $00000200;
  {$EXTERNALSYM CF_ANSIONLY}
  CF_ANSIONLY = $00000400;
  {$EXTERNALSYM CF_SCRIPTSONLY}
  CF_SCRIPTSONLY = CF_ANSIONLY;
  {$EXTERNALSYM CF_NOVECTORFONTS}
  CF_NOVECTORFONTS = $00000800;
  {$EXTERNALSYM CF_NOOEMFONTS}
  CF_NOOEMFONTS = CF_NOVECTORFONTS;
  {$EXTERNALSYM CF_NOSIMULATIONS}
  CF_NOSIMULATIONS = $00001000;
  {$EXTERNALSYM CF_LIMITSIZE}
  CF_LIMITSIZE = $00002000;
  {$EXTERNALSYM CF_FIXEDPITCHONLY}
  CF_FIXEDPITCHONLY = $00004000;
  {$EXTERNALSYM CF_WYSIWYG}
  CF_WYSIWYG = $00008000; { must also have CF_SCREENFONTS & CF_PRINTERFONTS }
  {$EXTERNALSYM CF_FORCEFONTEXIST}
  CF_FORCEFONTEXIST = $00010000;
  {$EXTERNALSYM CF_SCALABLEONLY}
  CF_SCALABLEONLY = $00020000;
  {$EXTERNALSYM CF_TTONLY}
  CF_TTONLY = $00040000;
  {$EXTERNALSYM CF_NOFACESEL}
  CF_NOFACESEL = $00080000;
  {$EXTERNALSYM CF_NOSTYLESEL}
  CF_NOSTYLESEL = $00100000;
  {$EXTERNALSYM CF_NOSIZESEL}
  CF_NOSIZESEL = $00200000;
  {$EXTERNALSYM CF_SELECTSCRIPT}
  CF_SELECTSCRIPT = $00400000;
  {$EXTERNALSYM CF_NOSCRIPTSEL}
  CF_NOSCRIPTSEL = $00800000;
  {$EXTERNALSYM CF_NOVERTFONTS}
  CF_NOVERTFONTS = $01000000;

  { TrayIcon }

{const
  NIM_ADD         = $00000000;
  NIM_MODIFY      = $00000001;
  NIM_DELETE      = $00000002;

  NIF_MESSAGE     = $00000001;
  NIF_ICON        = $00000002;
  NIF_TIP         = $00000004;
  
type
  _NOTIFYICONDATAA = record
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..63] of AnsiChar;
  end;
  _NOTIFYICONDATAW = record
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..63] of WideChar;
  end;
  _NOTIFYICONDATA = _NOTIFYICONDATAA;
  TNotifyIconDataA = _NOTIFYICONDATAA;
  TNotifyIconData = TNotifyIconDataA;

  PNotifyIconDataA = ^TNotifyIconDataA;
  PNotifyIconData = PNotifyIconDataA;    }

type

{ From CommDlg.pas }

  PDevNames = ^tagDEVNAMES;
  tagDEVNAMES = packed record
    wDriverOffset: Word;
    wDeviceOffset: Word;
    wOutputOffset: Word;
    wDefault: Word;
  end;

  { Structure for PrintDlg function }
  PtagPD = ^tagPD;
  tagPD  = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hDevMode: HGLOBAL;
    hDevNames: HGLOBAL;
    hDC: HDC;
    Flags: DWORD;
    nFromPage: Word;
    nToPage: Word;
    nMinPage: Word;
    nMaxPage: Word;
    nCopies: Word;
    hInstance: HINST;
    lCustData: LPARAM;
    lpfnPrintHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpfnSetupHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpPrintTemplateName: PAnsiChar;
    lpSetupTemplateName: PAnsiChar;
    hPrintTemplate: HGLOBAL;
    hSetupTemplate: HGLOBAL;
  end;

  { Structure for PageSetupDlg function }
  PtagPSD = ^tagPSD;
  tagPSD  = packed record
    lStructSize: DWORD;
    hwndOwner: HWND;
    hDevMode: HGLOBAL;
    hDevNames: HGLOBAL;
    Flags: DWORD;
    ptPaperSize: TPoint;
    rtMinMargin: TRect;
    rtMargin: TRect;
    hInstance: HINST;
    lCustData: LPARAM;
    lpfnPageSetupHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpfnPagePaintHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpPageSetupTemplateName: PAnsiChar;
    hPageSetupTemplate: HGLOBAL;
  end;

  TPrinterInfo = packed record
    ADevice  : PChar;
    ADriver  : PChar;
    APort    : PChar;
    ADevMode : THandle;
  end;  

resourcestring     { From SysConst.pas }
  SUnknown = '<unknown>';
  SInvalidInteger = '''%s'' is not a valid integer value';
  SInvalidFloat = '''%s'' is not a valid floating point value';
  SInvalidDate = '''%s'' is not a valid date';
  SInvalidTime = '''%s'' is not a valid time';
  SInvalidDateTime = '''%s'' is not a valid date and time';
  STimeEncodeError = 'Invalid argument to time encode';
  SDateEncodeError = 'Invalid argument to date encode';
  SOutOfMemory = 'Out of memory';
  SInOutError = 'I/O error %d';
  SFileNotFound = 'File not found';
  SInvalidFilename = 'Invalid filename';
  STooManyOpenFiles = 'Too many open files';
  SAccessDenied = 'File access denied';
  SEndOfFile = 'Read beyond end of file';
  SDiskFull = 'Disk full';
  SInvalidInput = 'Invalid numeric input';
  SDivByZero = 'Division by zero';
  SRangeError = 'Range check error';
  SIntOverflow = 'Integer overflow';
  SInvalidOp = 'Invalid floating point operation';
  SZeroDivide = 'Floating point division by zero';
  SOverflow = 'Floating point overflow';
  SUnderflow = 'Floating point underflow';
  SInvalidPointer = 'Invalid pointer operation';
  SInvalidCast = 'Invalid class typecast';
  SAccessViolation = 'Access violation at address %p. %s of address %p';
  SStackOverflow = 'Stack overflow';
  SControlC = 'Control-C hit';
  SPrivilege = 'Privileged instruction';
  SOperationAborted = 'Operation aborted';
  SException = 'Exception %s in module %s at %p.'#$0A'%s%s';
  SExceptTitle = 'Application Error';
  SInvalidFormat = 'Format ''%s'' invalid or incompatible with argument';
  SArgumentMissing = 'No argument for format ''%s''';
  SInvalidVarCast = 'Invalid variant type conversion';
  SInvalidVarOp = 'Invalid variant operation';
  SDispatchError = 'Variant method calls not supported';
  SReadAccess = 'Read';
  SWriteAccess = 'Write';
  SResultTooLong = 'Format result longer than 4096 characters';
  SFormatTooLong = 'Format string too long';
  SVarArrayCreate = 'Error creating variant array';
  SVarNotArray = 'Variant is not an array';
  SVarArrayBounds = 'Variant array index out of bounds';
  SExternalException = 'External exception %x';
  SAssertionFailed = 'Assertion failed';
  SIntfCastError = 'Interface not supported';
  SSafecallException = 'Exception in safecall method'; 
  SAssertError = '%s (%s, line %d)';
  SAbstractError = 'Abstract Error';
  SModuleAccessViolation = 'Access violation at address %p in module ''%s''. %s of address %p';
  SCannotReadPackageInfo = 'Cannot access package information for package ''%s''';
  sErrorLoadingPackage = 'Can''t load package %s.'#13#10'%s';
  SInvalidPackageFile = 'Invalid package file ''%s''';
  SInvalidPackageHandle = 'Invalid package handle';
  SDuplicatePackageUnit = 'Cannot load package ''%s.''  It contains unit ''%s,''' +
    ';which is also contained in package ''%s''';
  SWin32Error = 'Win32 Error.  Code: %d.'#10'%s';
  SUnkWin32Error = 'A Win32 API function failed';
  SNL = 'Application is not licensed to use this feature';

  SNotSupported = 'This function is not supported by your version of Windows';

  SShortMonthNameJan = 'Jan';
  SShortMonthNameFeb = 'Feb';
  SShortMonthNameMar = 'Mar';
  SShortMonthNameApr = 'Apr';
  SShortMonthNameMay = 'May';
  SShortMonthNameJun = 'Jun';
  SShortMonthNameJul = 'Jul';
  SShortMonthNameAug = 'Aug';
  SShortMonthNameSep = 'Sep';
  SShortMonthNameOct = 'Oct';
  SShortMonthNameNov = 'Nov';
  SShortMonthNameDec = 'Dec';

  SLongMonthNameJan = 'January';
  SLongMonthNameFeb = 'February';
  SLongMonthNameMar = 'March';
  SLongMonthNameApr = 'April';
  SLongMonthNameMay = 'May';
  SLongMonthNameJun = 'June';
  SLongMonthNameJul = 'July';
  SLongMonthNameAug = 'August';
  SLongMonthNameSep = 'September';
  SLongMonthNameOct = 'October';
  SLongMonthNameNov = 'November';
  SLongMonthNameDec = 'December';

  SShortDayNameSun = 'Sun';
  SShortDayNameMon = 'Mon';
  SShortDayNameTue = 'Tue';
  SShortDayNameWed = 'Wed';
  SShortDayNameThu = 'Thu';
  SShortDayNameFri = 'Fri';
  SShortDayNameSat = 'Sat';

  SLongDayNameSun = 'Sunday';
  SLongDayNameMon = 'Monday';
  SLongDayNameTue = 'Tuesday';
  SLongDayNameWed = 'Wednesday';
  SLongDayNameThu = 'Thursday';
  SLongDayNameFri = 'Friday';
  SLongDayNameSat = 'Saturday';

var
  Win32Platform: Integer;//     = 0;
  Win32MajorVersion: Integer;// = 0;
  Win32MinorVersion: Integer;// = 0;
  Win32BuildNumber: Integer;//  = 0;
//  Win32CSDVersion: string;// = ''; //+remove 18.02.04 +add 06.09.03

//  MsgDefCaption:String='Info';
  MsgDefHandle: Integer;

  DefaultFont: string = 'MS Sans Serif';

  AppTerminated: Boolean;

type
  Int64Rec = packed record
    Lo, Hi: DWORD;
  end;

  TMethod = record
    Code, Data: Pointer;
  end;

  PByteArray = ^TByteArray;
  TByteArray = array[0..MaxInt-1] of Byte;

  TMessages = TMessage;

  TTextAlign = (taLeft, taRight, taCenter);

  TFormBorderStyle = (bsNone, bsSingle, bsSizeable, bsDialog, bsToolWindow, bsSizeToolWin);
  TBorderStyle = bsNone..bsSingle;

  TBevelType = (bvNone, bvLowered, bvRaised, bvSpace);
  TBorderIcon = (biSystemMenu{ Не исп. }, biMinimize, biMaximize, biHelp{ Не исп. });
  TBorderIcons = set of TBorderIcon;
  TMouseButton = (mbLeft, mbRight, mbMiddle);
  TShiftState = set of (ssShift, ssAlt, ssCtrl, ssLeft, ssRight, ssMiddle, ssDouble);
  TModifiers = set of (mAlt, mCtrl, mExt, mShift);
  TBkMode = (bk_Opaque,bk_Transparent,bk_Slide);

  TOnSimpleEvent = procedure of object;//stdcall;
  TOnEvent = procedure(Sender: TObject) of object;
  TNotifyEvent = procedure(Sender: TObject) of object;
  TOnREvent = function(Sender: TObject): Boolean of object;
  TOnKey = procedure(Sender: TObject; var Key: Word; Shift: TShiftState) of object;
  TOnMouse = procedure(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer) of object;
  TOnMouseMove = procedure(Sender: TObject; Shift: TShiftState; X, Y: Integer) of object;
  TOnMessage = function(var Msg: TMessages): Boolean of object;
  TOnMsg = function(var Msg: TMsg): Boolean of object;

  TWindowFunc = function(var Msg: TMsg; var Rslt: Integer): Boolean;

  LongRec = packed record
   Lo, Hi: Word;
  end;

  { TStream }

  TStream = class
   protected
     function GetPosition: Longint; virtual;
     procedure SetPosition(const Value: Longint);
     function GetSize: Longint; virtual;
     procedure SetSize(NewSize: Longint); virtual;
   public
     function CopyFrom(Source: TStream; Count: Longint): Longint;
     function Read(var Buffer; Count: Longint): Longint; {virtual;} dynamic; abstract;
     function Write(const Buffer; Count: Longint): Longint; dynamic; abstract;
     procedure ReadBuffer(var Buffer; Count: Longint);
     procedure WriteBuffer(const Buffer; Count: Longint);
     property Position: Longint read GetPosition write SetPosition;
     function Seek(Offset: Longint; Origin: Word): Longint; dynamic; abstract;
     property Size: Longint read GetSize write SetSize;
  end;

  { THandleStream }

  THandleStream = class(TStream)
  private
    FHandle: Integer;
  public
    constructor Create(AHandle: Integer);
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    property Handle: Integer read FHandle;
  end;

  TFileStream = class(THandleStream)
  protected
    procedure SetSize(NewSize: Longint); override;
  public
    constructor Create(const FileName: string; Mode: Word);
    destructor Destroy; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
  end;

{ TCustomMemoryStream abstract class }

  TCustomMemoryStream = class(TStream)
  private
    FMemory: Pointer;
    FSize, FPosition: Longint;
  protected
    procedure SetPointer(Ptr: Pointer; Size: Longint);
  public
    function Read(var Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    property Memory: Pointer read FMemory;
  end;

{ TMemoryStream }

  TMemoryStream = class(TCustomMemoryStream)
  private
    FCapacity: Longint;
    procedure SetCapacity(NewCapacity: Longint);
  protected
    function Realloc(var NewCapacity: Longint): Pointer; virtual;
    property Capacity: Longint read FCapacity write SetCapacity;
  public
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromFile(const FileName: string);
    procedure SetSize(NewSize: Longint); override;
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

{ TStringStream }

  TStringStream = class(TStream)
  private
    FDataString: string;
    FPosition: Integer;
  protected
    procedure SetSize(NewSize: Longint); override;
  public
    constructor Create(const AString: string);
    function Read(var Buffer; Count: Longint): Longint; override;
    function ReadString(Count: Longint): string;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    procedure WriteString(const AString: string);
    property DataString: string read FDataString;
  end;  

{ TResourceStream }

  TResourceStream = class(TCustomMemoryStream)
  private
    HResInfo: HRSRC;
    HGlobal: THandle;
    procedure Initialize(Instance: THandle; Name, ResType: PChar);
  public
    constructor Create(Instance: THandle; const ResName: string; ResType: PChar);
    constructor CreateFromID(Instance: THandle; ResID: Integer; ResType: PChar);
    destructor Destroy; override;    
  end;

{ Duplicate management }

  TDuplicates = (dupIgnore, dupAccept, dupError);

 { TList }

 PPointerList = ^TPointerList;
 TPointerList = array[0..MaxInt div 4 - 1] of Pointer;

 TList = class
 private
//   FAddBy: Integer;
   FCapacity: Integer; 
   FCount: Integer;
   FItems: PPointerList;
   function Get(Idx: Integer): Pointer;
   procedure Put(Idx: Integer; const Value: Pointer);
   procedure SetCount(const Value: Integer);
   procedure SetCapacity(Value:Integer);
 public
   destructor Destroy; override;
   function Add(Value: Pointer): Integer;
   procedure Clear;
   procedure Delete(Idx: Integer);
   function IndexOf(Value: Pointer): Integer;
   procedure Insert(Index: Integer; Value: Pointer);   
   function First: Pointer;
   function Last: Pointer;
   procedure Pack;   
   function Remove(Item: Pointer): Integer;

   property Capacity: Integer read FCapacity write SetCapacity;
   property Count: Integer read FCount write SetCount;
   property Items[Idx: Integer]: Pointer read Get write Put; default;
 end;

{ TThreadList class }

  TThreadList = class
  private
    FList: TList;
    FLock: TRTLCriticalSection;
    FDuplicates: TDuplicates;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Item: Pointer);
    procedure Clear;
    function  LockList: TList;
    procedure Remove(Item: Pointer);
    procedure UnlockList;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
  end; 

 { TStringList }

  TStringList = class;
  
  PStringItem = ^TStringItem;
  TStringItem = record
    FString: string;
    FObject: TObject;
  end;
  
  PStringItemList = ^TStringItemList;
  TStringItemList = array[0..MaxListSize] of TStringItem;

  TStringListSortCompare = function(List: TStringList; Index1, Index2: Integer): Integer;  

  TStringList = class
  private
    FList: PStringItemList;
    FCapacity: Integer;
    FCount: Integer;
    FOnChange:TOnEvent ;
    FSorted: Boolean;
    FDuplicates: TDuplicates;
    procedure Grow;
    procedure SetCapacity(NewCapacity: Integer);
    function GetTextStr: string;
    procedure SetTextStr(const Value: string); //override;
    function GetCapacity: Integer;
    procedure SetSorted(const Value: Boolean);
    procedure QuickSort(L, R: Integer; SCompare: TStringListSortCompare);
    procedure InsertItem(Index: Integer; const S: string);
    procedure ExchangeItems(Index1, Index2: Integer);
    function GetValue(const Name: string): string;
    procedure SetValue(const Name, Value: string); //virtual; abstract;
  protected
    function GetCount: Integer;  
    function GetObject(Index: Integer): TObject; virtual;
    function Get(Index: Integer): string;
    procedure Put(Index: Integer; const Value: string);
    procedure InsertObject(Index: Integer; const S: string; AObject: TObject);
    procedure PutObject(Index: Integer; AObject: TObject); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Strings: TStringList);    
    function Add(const S: string): Integer;// override;
    function AddObject(const S: string; Obj: TObject): Integer;
    property Capacity: Integer read GetCapacity write SetCapacity;
    procedure Changed; virtual;
    procedure Clear; //override;    
    property Count: Integer read GetCount;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    function IndexOf(const S: string): Integer;
    procedure Insert(Index: Integer; const S: string);    
    function IndexOfName(const Name: string): Integer;    
    property Values[const Name: string]: string read GetValue write SetValue;         
    property Strings[Index: Integer]: string read Get write Put; default;
    property Objects[Index: Integer]: TObject read GetObject write PutObject;
    procedure LoadFromFile(const FileName: string); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToFile(const FileName: string); virtual;
    procedure SaveToStream(Stream: TStream); virtual;        
    property Text: string read GetTextStr write SetTextStr;
    procedure Delete(Index: Integer);
    procedure Sort; //virtual;
    procedure CustomSort(Compare: TStringListSortCompare);    
    property Sorted: Boolean read FSorted write SetSorted;
    property OnChange: TOnEvent read FOnChange write FOnChange;
  end;

  TStrings = class(TStringList);

  TComponent = class
   private
   public
     constructor Create(AOwner: TComponent); virtual;
  end;

  TControl = class
   private
   public
  end;

  { TPersistent abstract class }

  TPersistent = class(TObject)
  end;

{ TPersistent class reference type }

  TPersistentClass = class of TPersistent;

  

  TWinControl = class ;
  TCanvas = class;

 { Font }
    TFontPitch = (fpDefault, fpFixed, fpVariable);
//    TFontCharset = 0..255;
//    TFontDataName = string[LF_FACESIZE - 1];
    TFontStyle = (fsBold, fsItalic, fsUnderline, fsStrikeOut);
    TFontStyles = set of TFontStyle;

  TFont = class
   private
     FHandle  : HFont;
     FControl : TWinControl;
     FCanvas  : TCanvas;
     FName: String;
     FBold,
     FItalic,
     FUnderline,
     FStrikeOut:Integer;
     FColor: TColor;
     FStyle: TFontStyles;
     FHeight: Integer;
     FWidth: Integer;
     FSize: Integer;
     FPitch: Integer;
    FCharset: Byte;
     procedure UpdateFont;
     procedure SetControl(const Value: TWinControl);
     procedure SetColor(const Value: TColor);
     procedure SetHeight(const Value: Integer);
     procedure SetName(const Value: String);
     procedure SetWidth(const Value: Integer);
     procedure SetSize(const Value: Integer);
     procedure SetPitch(const Value: TFontPitch);
    function GetPitch: TFontPitch;
    procedure SetCharset(const Value: Byte);
   protected
     FCtrlHandle: THandle;
     procedure SetStyle(Value: TFontStyles);
   public
     constructor Create; overload;
     constructor Create(Canvas: TCanvas); overload;
     property Handle: HFont read FHandle write FHandle;
     property Charset: Byte read FCharset write SetCharset;     
     property Color: TColor read FColor write SetColor;
     property Height: Integer read FHeight write SetHeight;
     property Width: Integer read FWidth write SetWidth;
     property Name: String read FName write SetName;
     property Pitch: TFontPitch read GetPitch write SetPitch;
     property Size: Integer read FSize write SetSize;
     property Style: TFontStyles read FStyle write SetStyle;
     property Control:TWinControl read FControl write SetControl;
  end;

  TPenStyle = (psSolid, psDash, psDot, psDashDot, psDashDotDot, psClear, psInsideFrame);
  TPenMode = (pmBlack, pmWhite, pmNop, pmNot, pmCopy, pmNotCopy,
              pmMergePenNot, pmMaskPenNot, pmMergeNotPen, pmMaskNotPen, pmMerge,
              pmNotMerge, pmMask, pmNotMask, pmXor, pmNotXor);

  TPen = class
  private
    FStyle:TPenStyle;
    FWidth: Integer;
    FColor: TColor;
    FHandle:Integer;
    DC:hDC;
    FMode: TPenMode;
    procedure UpdatePen;
    procedure SetWidth(const Value: Integer);
    procedure SetColor(const Value: Integer);
    procedure SetStyle(const Value: TPenStyle);
    procedure SetMode(const Value: TPenMode);
  public
    constructor Create(Canvas: TCanvas);

    property Handle: Integer read FHandle write FHandle;
    property Color: TColor read FColor write SetColor;
    property Style: TPenStyle read FStyle write SetStyle default psSolid;
    property Width:Integer read FWidth write SetWidth;
    property Mode: TPenMode read FMode write SetMode default pmCopy;    
 end;

 TBrushStyle = (bsSolid, bsClear, bsHorizontal, bsVertical, bsFDiagonal, bsBDiagonal, bsCross, bsDiagCross); 

 TBrush = class
  private
    FHandle: HBrush;
    FDC:hDC;
    FColor: TColor;
    FStyle: TBrushStyle;
    procedure SetColor(const Value: TColor);
    procedure Update;
    procedure SetStyle(const Value: TBrushStyle);
  public
    constructor Create(Canvas: TCanvas);

    property Handle: HBrush read FHandle write FHandle;
    property Color: TColor read FColor write SetColor default clWhite;
    property Style: TBrushStyle read FStyle write SetStyle default bsSolid;
 end;

  TFillStyle = (fsSurface, fsBorder);
  TCopyMode = Longint;
  TCanvasStates = (csHandleValid, csFontValid, csPenValid, csBrushValid);
  TCanvasState = set of TCanvasStates;

  TCanvas = class
  private
    FHandle:hDC;
    State: TCanvasState;
    FPen: TPen;
    FBrush: TBrush;
    FFont: TFont;
    FOnChanging: TOnEvent;
    FOnChange: TOnEvent;
    FCopyMode: TCopyMode;
    function GetPixel(X, Y: Integer): Integer;
    procedure SetPixel(X, Y: Integer; const Value: Integer);
    function GetClipRect: TRect;
    procedure CreateHandle;
    procedure CreateBrush;
    procedure CreateFont;
    procedure CreatePen;
  protected
    procedure Changed;
    procedure RequiredState(ReqState: TCanvasState);
  public
    constructor Create(Handle: Integer);
    constructor CreateFromDC(DC: hDC);
    destructor Destroy; override;

    procedure Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
    procedure CopyRect(const Dest: TRect; Canvas: TCanvas; const Source: TRect);
    procedure Ellipse(X1, Y1, X2, Y2: Integer);
    procedure FillRect(const Rect: TRect);
    procedure FloodFill(X, Y: Integer; Color: TColor; FillStyle: TFillStyle);    
    property Handle: hDC read FHandle write FHandle;
    procedure LineTo(X, Y: Integer);
    procedure Lock;    
    procedure MoveTo(X, Y: Integer);
    procedure Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);    
    procedure Polyline(const Points: array of TPoint);
    procedure Rectangle(X1, Y1, X2, Y2: Integer);
    function TextExtent(const Text: string): TSize;
    procedure TextOut(X, Y: Integer; const Text: string);
    function TextWidth(const Text: string): Integer;
    procedure Unlock;
    property Brush: TBrush read FBrush write FBrush;
    property ClipRect: TRect read GetClipRect;
    property Pen: TPen read FPen write FPen;
    property Font: TFont read FFont write FFont;
    property Pixels[X, Y: Integer]: Integer read GetPixel write SetPixel;
    property OnChange: TOnEvent read FOnChange write FOnChange;
    property OnChanging: TOnEvent read FOnChanging write FOnChanging;
    property CopyMode: TCopyMode read FCopyMode write FCopyMode default cmSrcCopy;
 end;

{ Graphics }

  { TBitmap }

  TPixelFormat = (pfDevice, pf1bit, pf4bit, pf8bit, pf15bit, pf16bit, pf24bit, pf32bit, pfCustom);
  TBitmapHandleType = (bmDIB, bmDDB);

  TBitmap = class
  private
    fHeight: Integer;
    fWidth: Integer;
    fHandle: HBitmap;
    FCanvas: TCanvas;
    fScanLineSize: Integer;
    fBkColor: TColor;
    fApplyBkColor2Canvas: procedure(Sender: TBitmap);
    fDetachCanvas: procedure(Sender: TBitmap);
    FCanvasAttached : Integer;
    fHandleType: TBitmapHandleType;
    fDIBHeader: PBitmapInfo;
    fDIBBits: Pointer;
    fDIBSize: Integer;
    fNewPixelFormat: TPixelFormat;
    fFillWithBkColor: procedure(BmpObj: TBitmap; DC: HDC; oldW, oldH: Integer );
    fTransMaskBmp: TBitmap;
    fTransColor: TColor;
    fGetDIBPixels: function(Bmp: TBitmap; X, Y: Integer): TColor;
    fSetDIBPixels: procedure(Bmp: TBitmap; X, Y: Integer; Value: TColor);
    //fScanLine0: PByte;
    //fScanLineDelta: Integer;
    //fPixelMask: DWORD;
    //fPixelsPerByteMask: Integer;
    //fBytesPerPixel: Integer;
    fDIBAutoFree: Boolean;
    function GetEmpty: Boolean;
    procedure SetHandleType(const Value: TBitmapHandleType);
    procedure FormatChanged;
    procedure ClearData;
    procedure ClearTransImage;
    function GetHandle: HBitmap;
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    function GetCanvas: TCanvas;
    procedure SetBkColor(const Value: TColor);
    procedure CanvasChanged(Sender: TObject);
    function GetScanLineSize: Integer;
    procedure RemoveCanvas;
    function GetPixelFormat: TPixelFormat;
    procedure SetPixelFormat(const Value: TPixelFormat);
    function GetScanLine(Y: Integer): Pointer;
    function GetDIBPalEntries(Idx: Integer): TColor;
    procedure SetDIBPalEntries(Idx: Integer; const Value: TColor);  
    procedure SetHandle(const Value: HBitmap);
    function GetDIBPalEntryCount: Integer;
//  protected
//    destructor Destroy; virtual;
  public
    constructor Create;
    constructor CreateNew(Width, Height: Integer);
    constructor CreateNewDIB(Width, Height: Integer; PixelFormat: TPixelFormat);

    destructor Destroy; override;

    function Assign(Bitmap: TBitmap): Boolean;
    function ReleaseHandle: HBitmap;

    procedure Clear;
    procedure Dormant;
    procedure Draw(DC: HDC; X, Y: Integer);
    procedure DrawStretch(DC: HDC; const Rect: TRect);
    procedure LoadFromFile(const Filename: String);
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToFile(const Filename: String);
    procedure SaveToStream(Stream: TStream); virtual;

    property BkColor: TColor read FBkColor write SetBkColor;
    property Canvas: TCanvas read GetCanvas;
    property Empty: Boolean read GetEmpty;
    property Handle: HBitmap read GetHandle write SetHandle;    
    property HandleType: TBitmapHandleType read FHandleType write SetHandleType;
    property Height: Integer read FHeight write SetHeight;
    property PixelFormat: TPixelFormat read GetPixelFormat write SetPixelFormat;    
    property ScanLineSize: Integer read GetScanLineSize;
    property Width: Integer read FWidth write SetWidth;

    property ScanLine[Y: Integer]: Pointer read GetScanLine;
    property DIBPalEntryCount: Integer read GetDIBPalEntryCount;
    property DIBPalEntries[Idx: Integer]: TColor read GetDIBPalEntries write SetDIBPalEntries;
  end;

{var
  DefaultPixelFormat: TPixelFormat = pf16bit;  }

  { TIcon }

//type
  TIcon = class
  private
    FRequestedSize: TPoint;

    FHandle: HICON;
    FMemoryImage: TCustomMemoryStream;
    FSize: TPoint;

    procedure HandleNeeded;
    procedure ImageNeeded;    
    function GetHandle: HICON;
    procedure NewImage(NewHandle: HICON; NewImage: TMemoryStream);
    procedure SetHandle(const Value: HICON);
  public
    constructor Create;

    procedure LoadFromFile(const Filename: string);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToFile(const Filename: string);
    procedure SaveToStream(Stream: TStream);

    property Handle: HICON read GetHandle write SetHandle;     
  end;
//----------------


//////////////////////////////////////////////////////////////////////////////

 TMenu = class
  private
   FHandle: hMenu;
   FParentHandle, FTag: Integer;
   Adder: Integer;
  public
   constructor Create(AParent: TWinControl; MainMenu: Boolean; const Template: array of PChar);
   destructor Destroy; override;
   procedure Popup(X, Y: Integer);
   procedure AddItem(S: String; I: Integer);
   property Handle: hMenu read FHandle write FHandle;
   property ParentHandle: Integer read FParentHandle write FParentHandle;
   property Tag: Integer read FTag write FTag;
 end;

 TWinControl = class//(TControl)
  private
    FBkMode        : TBkMode;
    FBrush         : HBrush;
    FCaption       : PChar;//ShortString;
    wClass         : TWndClass;

    FColor         : TColor;
    FDC            : HDC;
    FDefWndProc    : Longint;
    FFont          : TFont;
    FIcon          : hIcon;
    FId            : Byte;
    FTextColor     : TColor;
//   FTmpBrush      : HBrush;
    hwndTooltip    : Integer;

//nosort
    FLeft          : Integer;
    FTop           : Integer;
    FWidth         : Integer;
    FHeight        : integer;
    FHandle        : THandle;
    FParent        : TWinControl;
    FParentHandle  : THandle;
    FEnabled       : Boolean;
    FVisible       : Boolean;
    FUpdateCounter : Integer;

    FOnClose: TOnREvent;
    FOnCreate: TOnEvent;
    FOnDestroy: TOnEvent;
    FOnClick: TOnEvent;
    FOnDblClick: TOnEvent;
    FOnMouseDown: TOnMouse;
    FOnMessage: TOnMessage;
    FOnProcessMsg: TOnMsg;
    FOnMinimize: TOnREvent;
    FOnPaint: TOnEvent;
    FCanvas: TCanvas;
    FTag: Integer;
    FShowHint: Boolean;
    FHint: String;
    FCursor: TCursor;
//    FCursorHandle: THandle;
    FOnShow: TOnEvent;
    FOnHide: TOnEvent;
    FReadOnly: Boolean;
    FPasswordChar: Char;
    FMaxLength: Integer;
    FBorderStyle: TBorderStyle;
    FTagEx: String;
    FCtl3D: Boolean;
    FOnChange: TOnEvent;
    FOnMouseUp: TOnMouse;
    FOnMouseMove: TOnMouseMove;
    FOnKeyUp: TOnKey;
    FOnKeyDown: TOnKey;
    FOnResize: TOnEvent;
//-----------------------
//    fUpdCount: Integer;
{    fRefCount: Integer;

    fDynHandlers: TList;
    fOnDynHandlers: TWindowFunc;
    procedure RefDec;
    procedure RefInc;  }
//-----------------------
    function GetText: String;
    procedure SetText(const Value: String);
    procedure SetParentHandle(const Value: HWnd);
    function GetParentHandle : HWnd;
    procedure SetHeight(const Value: integer);
    procedure SetLeft(const Value: integer);
    procedure SetTop(const Value: integer);
    procedure SetWidth(const Value: integer);
    procedure SetVisible(const Value: Boolean);
    procedure SetIcon(Value: HIcon);
    procedure SetColor(const Value: Integer);
    procedure SetEnabled(Value: Boolean);
    procedure SetExStyle(const Value: longint);
    procedure SetStyle(const Value: longint);
    function GetClientHeight: integer;
    function GetClientWidth: integer;
    function GetHeight: integer;
    function GetLeft: integer;
    function GetTop: integer;
    function GetWidth: integer;
    procedure SetHint(const Value: String);
    procedure SetShowHint(const Value: Boolean);
    procedure SetCursor(const Value: TCursor);
    function GetVisible: Boolean;
    function GetSelLength: Integer;
    function GetSelStart: Integer;
    function GetSelText: string;
    procedure SetPasswordChar(const Value: Char);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetSelLength(const Value: Integer);
    procedure SetSelStart(const Value: Integer);
    procedure SetSelText(const Value: string);
    procedure SetMarginWidth(const Value: word);
    procedure SetMaxLength(const Value: Integer);
    function GetMarginWidth: word;
    function GetShiftState: TShiftState;
    procedure SetBorderStyle(const Value: TBorderStyle);
    procedure SetCtl3D(const Value: Boolean);
//    procedure SetClientHeight(const Value: integer);
{    function GetWCCanvas: TCanvas;
    procedure SetWCCanvas(const Value: TCanvas);}
//    procedure WMLButtonDown(var AMsg: TWMLButtonDown);
  protected
    FClassName     : String;
    FCustomData    : Pointer;
    FNext: TWinControl;
    FStyle         : Longint;
    FExStyle       : Longint;
    procedure CreateWnd;
    function GetWndProc : pointer;
    function WndProc(AMessage, WParam, LParam : Longint): Longint; virtual; stdcall;

    procedure ProcessMessage(var AMsg: TMessage);// virtual;

    procedure WMClose(var AMsg: TWMClose);
    procedure WMPaint(var AMsg: TWMPaint); virtual;
    procedure WMCommand(var AMsg : TWMCommand);// virtual;
    procedure WMCtlColor(var AMsg : TMessage);
    procedure WMDestroy(var AMsg: TWMDestroy);
    procedure WMEraseBkgnd(var AMsg : TWMEraseBkgnd);// virtual;
    procedure WMKeyDown(var AMsg: TWMKeyDown);
    procedure WMKeyUp(var AMsg: TWMKeyUp);    
    procedure WMLButtonDown(var AMsg: TWMLButtonDown);
    procedure WMLButtonUp(var AMsg: TWMLButtonUp);
    procedure WMRButtonUp(var AMsg: TWMRButtonUp);
    procedure WMMButtonUp(var AMsg: TWMMButtonUp);
    procedure WMMouseMove(var AMsg: TWMMouseMove);
    procedure WMRButtonDown(var AMsg: TWMRButtonDown);
    procedure WMMButtonDown(var AMsg: TWMMButtonDown);
    procedure WMSetFocus(var AMsg: TWMSetFocus);
    procedure WMKillFocus(var AMsg: TWMKillFocus);
    procedure WMSysCommand(var AMsg: TWMSysCommand);
    procedure WMSetCursor(var AMsg: TWMSetCursor);

    procedure Click; virtual;
    procedure DblClick; virtual;    
    procedure Change; virtual;
    procedure DoMouseDown(var AMsg: TWMMouse; Button: TMouseButton; Shift: TShiftState);// virtual;
    procedure DoMouseUp(var AMsg: TWMMouse; Button: TMouseButton; Shift: TShiftState);
    procedure SetButtonStyle(ADefault: Boolean);
    //All
    property BorderStyle:TBorderStyle read FBorderStyle write SetBorderStyle;
    //TForm, TLabel
    property Caption : String read GetText write SetText;
    //TEdit, TMemo
    property MarginWidth : word read GetMarginWidth write SetMarginWidth;
    property MaxLength: Integer read FMaxLength write SetMaxLength default 0;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelText: string read GetSelText write SetSelText;
    property PasswordChar: Char read FPasswordChar write SetPasswordChar default #0;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property Text : String read GetText write SetText;
    //TLabel
    property BkMode : TBkMode read FBkMode write FBkMode;
  public
{    function IsProcAttached( Proc: TWindowFunc ): Boolean;
    procedure AttachProcEx( Proc: TWindowFunc; ExecuteAfterAppletTerminated: Boolean );
    procedure AttachProc(Proc: TWindowFunc);
}
    procedure Dispatch(var AMsg); override; //Protected ???
    constructor Create(AParent :TWinControl); //virtual;
    destructor Destroy; override;
   function ProcessMsg(var Msg: TMsg): Boolean;
   procedure ProcessMessages;
   procedure Run;
   function GetWindowHandle: HWnd;

    procedure BeginUpdate;
    procedure EndUpdate;

    procedure CanvasInit;
    procedure BringToFront;
   procedure Invalidate;
   procedure SendToBack;
   procedure SetBounds(Left, Top, Width, Height: Integer);
   procedure SetFocus;
   procedure SetPosition(Left, Top:Integer);
   procedure SetSize(Width, Height:Integer);
   procedure Show;
   procedure ShowModal;
   procedure Hide;
   function Perform(msgcode: DWORD; wParam, lParam: Integer): Integer; stdcall;
    property Parent: TWinControl read FParent;
    property NextControl: TWinControl read FNext;
//   property Alignment:Integer read FAlignment write SetAlignment;
    property Canvas: TCanvas read {GetWC}FCanvas write {SetWC}FCanvas;
    property ClientWidth : integer read GetClientWidth;
    property ClientHeight : integer read GetClientHeight{ write SetClientHeight};
    property Color : Integer read FColor write SetColor;
    property Cursor: TCursor read FCursor write SetCursor;
    property CustomData: Pointer read FCustomData write FCustomData;
    property Ctl3D: Boolean read FCtl3D write SetCtl3D;
    property Enabled:Boolean read FEnabled write SetEnabled;
    property Font : TFont read FFont write FFont;
    property Hint: String read FHint write SetHint;
    property ShowHint: Boolean read FShowHint write SetShowHint;
    property Icon: HIcon read FIcon write SetIcon;
    property Style : Longint read FStyle write SetStyle;
    property ExStyle : longint read FExStyle write SetExStyle;
    property Tag: Integer read FTag write FTag;
    property TagEx: String read FTagEx write FTagEx;
//--

    property TextColor :Integer read FTextColor write FTextColor;
    property Handle:THandle read FHandle;
    property ParentHandle : HWnd read GetParentHandle write SetParentHandle;
    property Left : integer read GetLeft write SetLeft;
    property Top : integer read GetTop write SetTop;
    property Width : integer read GetWidth write SetWidth;
    property Height : integer read GetHeight write SetHeight;
    property Visible:Boolean read GetVisible write SetVisible;

    property OnClick   : TOnEvent read FOnClick write FOnClick;
    property OnDblClick   : TOnEvent read FOnDblClick write FOnDblClick;
    property OnChange  : TOnEvent read FOnChange write FOnChange;
    property OnCreate  : TOnEvent read FOnCreate write FOnCreate;
    property OnClose   : TOnREvent read FOnClose write FOnClose;
    property OnDestroy : TOnEvent read FOnDestroy write FOnDestroy;
    property OnKeyDown : TOnKey read FOnKeyDown write FOnKeyDown;
    property OnKeyUp   : TOnKey read FOnKeyUp write FOnKeyUp;
    property OnMessage : TOnMessage read FOnMessage write FOnMessage;
    property OnMinimize : TOnREvent read FOnMinimize write FOnMinimize;
    property OnMouseDown: TOnMouse read FOnMouseDown write FOnMouseDown;
    property OnMouseMove : TOnMouseMove read FOnMouseMove write FOnMouseMove;
    property OnMouseUp: TOnMouse read FOnMouseUp write FOnMouseUp;
    property OnPaint: TOnEvent read FOnPaint write FOnPaint;
    property OnProcessMsg: TOnMsg read FOnProcessMsg write FOnProcessMsg;
    property OnResize  : TOnEvent read FOnResize write FOnResize;
    property OnShow: TOnEvent read FOnShow write FOnShow;
    property OnHide: TOnEvent read FOnHide write FOnHide;
  end;

  TGraphicControl = class(TWinControl)
  private
//    FCanvas: TCanvas;
    procedure WMPaint_(var Message: TWMPaint); message WM_PAINT;
//    procedure WMNCPAINT(var Msg: TWMNcPaint); message WM_NCPAINT;    
  protected
    procedure Paint; virtual;
//    property Canvas: TCanvas read FCanvas;
  public
    constructor Create(AOwner: TWinControl);// override;
//    destructor Destroy; override;
  end;

  TApplication = class(TWinControl)
   private
    FTitle: String;
    procedure SetTitle(const Value: String);
   public
     constructor Create(Caption: String);
     property Title: String read FTitle write SetTitle;
  end;

 TForm = class(TWinControl)
 private
   FPosition: Byte;
   FBorderIcons: TBorderIcons;
   FBorderStyle: TFormBorderStyle;
   FMenu: hMenu;
    FAlphaBlend: Boolean;
    FAlphaBlendValue: Byte;
    FTransparentColor: Boolean;
    FTransparentColorValue: TColor;
    function GetWindowState: Integer;
   procedure SetFormPosition(const Value: Byte);
   procedure SetBorderStyle(const Value: TFormBorderStyle);
   procedure SetBorderIcons(const Value: TBorderIcons);
   procedure SetMainMenu(const Value: hMenu);
    procedure SetWindowState(const Value: Integer);
    procedure SetLayeredAttribs;
    procedure SetAlphaBlend(const Value: Boolean);
    procedure SetAlphaBlendValue(const Value: Byte);
    procedure SetTransparentColor(const Value: Boolean);
    procedure SetTransparentColorValue(const Value: TColor);
 protected
 public
   constructor Create(Parent:TWinControl; Caption: String);

   procedure Close;
   procedure CreateWindow;

   property AlphaBlend: Boolean read FAlphaBlend write SetAlphaBlend default False;
   property AlphaBlendValue: Byte read FAlphaBlendValue write SetAlphaBlendValue default 255;
   property TransparentColor: Boolean read FTransparentColor write SetTransparentColor;
   property TransparentColorValue: TColor read FTransparentColorValue write SetTransparentColorValue;

   property BorderStyle:TFormBorderStyle read FBorderStyle write SetBorderStyle;
   property BorderIcons:TBorderIcons read FBorderIcons write SetBorderIcons;
//   property MainMenu: TMenu read FMenu write SetMainMenu;
   property MainMenu: hMenu read FMenu write SetMainMenu;
   property Position:Byte read FPosition write SetFormPosition;
   property WindowState: Integer read GetWindowState write SetWindowState;

   property Caption;   
 end;

 TMDIForm = class(TForm)
 private
   FClientHandle: THandle;
   procedure Dispatch(var AMsg); override;
 public
   constructor Create(Parent:TWinControl; Caption: String);
   property ClientHandle: THandle read FClientHandle;
 end;

 TMDIChildForm = class(TForm)
 private
//   function ChildProc(hChild:DWORD;uMsg:DWORD;wParam:DWORD;lParam:DWORD):Longint; stdcall;
 public
   constructor Create(Parent: TMDIForm; Caption: String);
 end;

 procedure CloseForm(Form: TForm; Angle: Boolean; Close: Boolean);

type
 TLabel = class(TWinControl)
  private
    FAlignment: Integer;
    FTransparent: Boolean;
    procedure SetAlignment(const Value: Integer);
    procedure SetTransparent(const Value: Boolean);
  public
    constructor Create(AParent : TWinControl; Caption:String);// override;
    property Alignment:Integer read FAlignment write SetAlignment;
    property BorderStyle;
    property BkMode;
    property Transparent: Boolean read FTransparent write SetTransparent; //уст флаг FBkMode
    property Caption;
 end;

 TEdit = class(TWinControl)
  private
    FFlat: Boolean;
    procedure SetEditFlat(const Value: Boolean);
    function GetCanUndo: Boolean;
    function GetModified: Boolean;
    procedure SetModified(const Value: Boolean);
  public
    constructor Create(AParent : TWinControl; Text:String);// override;

    procedure Clear;
    procedure ClearSelection;                            //02.02.04
    procedure ClearUndo;                                 //02.02.04
    procedure CopyToClipboard;                           //02.02.04
    procedure CutToClipboard;                            //02.02.04
    procedure PasteFromClipboard;                        //02.02.04
    procedure SelectAll;                                 //02.02.04
    procedure Undo;                                      //02.02.04

    property BorderStyle;
    property CanUndo: Boolean read GetCanUndo;           //02.02.04
    property Flat: Boolean read FFlat write SetEditFlat; //17.10.03
    property MarginWidth;
    property MaxLength;
    property Modified: Boolean read GetModified write SetModified; //02.02.04
    property SelLength;
    property SelStart;
    property SelText;
    property PasswordChar;
    property ReadOnly;
    property Text;
 end;

  TSList = record
    Strings:array[0..32800] of String ;
    Count:Integer;
  end;

 TMemo = class(TWinControl)
  private
    //sl: TSList;
    function GetLineText: String;
    procedure SetLineText(const Value: String);
    function GetLineStrings(Index: Integer): String;
    procedure SetLineStrings(Index: Integer; const Value: String);
//    FLines: TStringList;
//    procedure SetLines(Sender: TObject);
  public
    constructor Create(AParent : TWinControl; Text:String);// override;

    procedure LoadFromFile(FileName: String);
    procedure SaveToFile(FileName: String);

    procedure Clear;
    procedure LineAdd(S: String);
    function  LineCurIndex: Integer;
    function  LineCount: Integer;
    procedure LineInsert(Index: Integer; S: String);

    function Undo: Boolean;

//  property Lines:TStringList read FLines write FLines;

    property LineStrings[Index: Integer]: String read GetLineStrings write SetLineStrings;
    property LineText: String read GetLineText write SetLineText;
    property MarginWidth;
    property MaxLength;
    property SelStart;
    property SelLength;
    property SelText;
    property PasswordChar;
    property ReadOnly;    
    property Text;
 end;

 TButton = class(TWinControl)
  private
    FDefault: Boolean;
    FFlat: Boolean;
    procedure SetDefault(const Value: Boolean);
    procedure SetFlat(const Value: Boolean);
  public
    constructor Create(AParent : TWinControl; Caption:String);// override;
    procedure Click; override;
    property Default: Boolean read FDefault write SetDefault;
    property Flat:Boolean read FFlat write SetFlat;
    property Caption;
 end; 

 TCheckBox = class(TWinControl)
  private
    FChecked: Boolean;
    procedure SetChecked(const Value: Boolean);
  protected
    procedure Click; override;
  public
    constructor Create(AParent : TWinControl; Caption:String);
    property Checked:Boolean read FChecked write SetChecked;

    property Caption;
 end;

var
  FHwnd: THandle;

type
 TRadioButton = class(TWinControl)
  private
    FChecked: Boolean;
    procedure SetChecked(const Value: Boolean);
    function GetChecked: Boolean;
  protected
    procedure Click; override;
  public
    constructor Create(AParent : TWinControl; Caption:String);
    property Checked:Boolean read GetChecked write SetChecked;

    property Caption;
 end;

  TListBoxStyle = (lbStandard, lbOwnerDrawFixed, lbOwnerDrawVariable, lbMultipleSel, lbSorted);

  TListBox = class(TWinControl)
  private
    FSorted: Boolean;
    function GetItemIndex: Integer;
    procedure SetItemIndex(const Value: Integer);
    function GetItem(Index: Integer): String;
    procedure SetLBSorted(const Value: Boolean);
    function GetLBObject(ItemIndex: Integer): TObject;
    procedure SetLBObject(ItemIndex: Integer; const Value: TObject);
    function GetLBItemText: String;
    procedure SetItem(ItemIndex: Integer; const Value: String);
  public
    constructor Create(AParent : TWinControl; Style: TListBoxStyle);

    function  ItemAdd(s: String): Integer;
    function  ItemCount: Integer;
    function  ItemInsert(Index: Integer; s: String): Integer;
    procedure ItemDelete(Index: Integer);

    procedure Clear;

    property Objects[ItemIndex: Integer] : TObject read GetLBObject write SetLBObject;
    property Items[ItemIndex: Integer]: String read GetItem write SetItem;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property ItemText: String read GetLBItemText{ write SetLBItemText};
    property Sorted: Boolean read FSorted write SetLBSorted;
  end;

  { TComboBox }

  TComboBoxStyle = (csDropDown, csSimple, csDropDownList, csOwnerDrawFixed, csOwnerDrawVariable);

  TComboBox = class(TWinControl)
  private
    function GetDroppedDown: Boolean;
    procedure SetDroppedDown(const Value: Boolean);
    procedure UpdateHeight;
    function GetItemIndex: Integer;
    procedure SetItemIndex(const Value: Integer);
    function GetItem(ItemIndex: Integer): String;
    procedure SetItem(ItemIndex: Integer; const Value: String);
//  protected
//    procedure DoMouseDown(var AMsg: TWMMouse; Button: TMouseButton; Shift: TShiftState);// override;
//    procedure WMDRAWITEM(var AMsg: TWmDrawItem); message WM_DRAWITEM;
  public
    constructor Create(AParent : TWinControl; Style: TComboBoxStyle);

    procedure Clear; 

    function  ItemAdd(const S: shortstring): Integer;
    function  ItemCount: Integer;
    procedure ItemDelete(ItemIndex: Integer);

    property DroppedDown: Boolean read GetDroppedDown write SetDroppedDown;
    property Items[ItemIndex: Integer]: String read GetItem write SetItem;    
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property Text;
 end;

  TComboBoxEx = class(TComboBox)
  private
    function GetObject(Index: Integer): TObject;
    procedure SetObject(Index: Integer; Value: TObject);
  public
    property Objects[Index: Integer]: TObject read GetObject write SetObject;
  end;

 { TScrollBar }

const
  CN_BASE              = $BC00;
  CN_HSCROLL           = CN_BASE + WM_HSCROLL;
  CN_VSCROLL           = CN_BASE + WM_VSCROLL;

type

 TScrollBar = class(TWinControl)
    procedure CNHScroll(var Message: TWMHScroll); message CN_HSCROLL;
    procedure CNVScroll(var Message: TWMVScroll); message CN_VSCROLL;
  private
    FMax: Integer;
    FMin: Integer;
    FPosition: Integer;
    procedure SetMax(const Value: Integer);
    procedure SetMin(const Value: Integer);
    procedure SetSBPosition(const Value: Integer);
  public
    constructor Create(AParent : TWinControl; Horizontal: Boolean);
    property Max: Integer read FMax write SetMax;
    property Min: Integer read FMin write SetMin;
    property Position: Integer read FPosition write SetSBPosition;
 end;

 TPanel = class(TWinControl)
  private
    FBevel: TBevelType;
    procedure WMPAINT_(var Msg: TMessage); message WM_PAINT;
    procedure WMNCPAINT_(var Msg: TMessage); message WM_NCPAINT;
    procedure RealPaint(var Msg: TMessage);
    procedure Paint(DC: HDC);
    procedure SetBevel(const Value: TBevelType);
  public
    constructor Create(AParent : TWinControl; Caption:String); 
    property Bevel: TBevelType read FBevel write SetBevel;
    property Caption;
 end;

 TSimplePanel = class(TWinControl)
  private
    FBorder: Integer;
    procedure SetBorder(const Value: Integer);
  public
    constructor Create(AParent : TWinControl; Caption:String);
    property Border: Integer read FBorder write SetBorder;
    property Caption;
 end;

 TGroupBox = class(TWinControl)
  private
  public
    constructor Create(AParent : TWinControl; Caption:String);
    property Caption;
 end;

//Additional
 TSpeedButton = class(TWinControl)
  private
    fGlyph: hBitmap;
    procedure SetGlyph(const Value: hBitmap);
  public
    constructor Create(AParent : TWinControl; Caption:String);
    procedure Click; override;
    //property Default: Boolean read FDefault write SetDefault;
    //property Flat:Boolean read FFlat write SetFlat;
    property Glyph: hBitmap read fGlyph write SetGlyph; 
    property Caption;
 end;

 TImage = class(TWinControl)
 private
    FBitmapRes: String;
    FIconHandle: THandle;
    FBitmap: hBitmap;
    procedure SetBitmapRes(const Value: String);
    procedure SetIconHandle(const Value: THandle);
    procedure SetBitmapHandle(const Value: hBitmap);
    function GetBitmap: TBitmap;
    procedure SetBitmap(const Value: TBitmap);
 public
    constructor Create(AParent : TWinControl);
    procedure LoadFromFile(FileName: String);
    property IconHandle: THandle read FIconHandle write SetIconHandle;
    property BitmapHandle: hBitmap read FBitmap write SetBitmapHandle;
    property BitmapRes:String read FBitmapRes write SetBitmapRes;
    property Bitmap: TBitmap read GetBitmap write SetBitmap;
 end;

{ TScrollBox = class(TWinControl)
  private
  public
   constructor Create(AParent : TWinControl; Text:String);
 end; }

 { TLabeledEdit }

 TLabeledEdit  = class(TEdit)
  private
    FLabelEd: TLabel;
    procedure WMMove(var AMsg: TMessage); message WM_MOVE;
  public
    constructor Create(AParent : TWinControl; LabelCaption, Text: String);

    property EditLabel: TLabel read FLabelEd write FLabelEd;
 end;

//Win32

 { TTabControl }

  TImageList = class;  
  TTabStyle = (tsTabs, tsButtons, tsFlatButtons);
  TTabPosition = (tpTop, tpBottom, tpLeft, tpRight);

  TTabControl = class(TWinControl)
  private
//    FOnSelect: TOnEvent;
    FTabStyle: TTabStyle;
    FImages: TImageList;
    FTabPosition: TTabPosition;
    function GetTabIndex: Integer;
    procedure SetTabIndex(const Value: Integer);
    procedure SetTabStyle(const Value: TTabStyle);
    procedure SetImages(const Value: TImageList);
    procedure SetTabPosition(const Value: TTabPosition);
  public
   constructor Create(AParent : TWinControl);

   function TabAdd(Caption: String): Integer ;
   function TabCount: Integer;
   function TabDelete(Index: Integer): Boolean;
   property TabIndex: Integer read GetTabIndex write SetTabIndex;
   function TabInsert(Caption: String; Index:Integer): Integer;
   procedure TabImageIndex(TabIndex, ImageIndex: Integer);

   property Images: TImageList read FImages write SetImages;
   property Style: TTabStyle read FTabStyle write SetTabStyle default tsTabs;
   property TabPosition: TTabPosition read FTabPosition write SetTabPosition default tpTop;
//  procedure WndProcTabControl(var Message: TMessage{ Self_: TWinControl; var Msg: TMsg; var Rslt: Integer });
//   property OnSelect: TOnEvent read FOnSelect write FOnSelect;
 end;

  { TImageList }

  TDrawingStyles = (dsBlend25, dsBlend50, dsMask, dsTransparent);
  TDrawingStyle = Set of TDrawingStyles;

  HIMAGELIST = THandle;

  TImageList = class
  private
    FHandle: THandle;
    FHeight: Integer;
    FWidth: Integer;
    FAllocBy: Integer;
    FBkColor: TColor;
    FMasked: Boolean;
    FDrawingStyle: TDrawingStyle;
    FBlendColor: TColor;
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    procedure SetAllocBy(const Value: Integer);
    procedure SetMasked(const Value: Boolean);
    function GetBkColor: TColor;
    procedure SetBkColor(const Value: TColor);
    function GetDrawStyle : DWord;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CreateList;

    function AddBitmap(Bmp, Msk : HBitmap): Integer;
    function AddMasked(Bmp: HBitmap; TransparentColor: TColor): Integer;    
    function AddIcon(Image: hIcon): Integer;

    function LoadSystemIcons(SmallIcons: Boolean): Boolean;  //!!!

    procedure Draw(DC: hDC; X, Y, Index: Integer);
    procedure DrawStretch(DC: hDC; Index: Integer; const Rect : TRect);
    property  DrawingStyle : TDrawingStyle read FDrawingStyle write FDrawingStyle;

    property AllocBy: Integer read FAllocBy write SetAllocBy;
    property BkColor: TColor read GetBkColor write SetBkColor;
    property BlendColor: TColor read FBlendColor write FBlendColor;
//    property BlendColor : TColor read GetBlendColor write SetBlendColor;
    property Handle: THandle read FHandle write FHandle;
    property Masked : Boolean read FMasked write SetMasked;
    property Height: Integer read FHeight write SetHeight;
    property Width: Integer read FWidth write SetWidth;
  end;

 { TRichEdit }

 TRichEdit = class(TWinControl)
  private
    RichEditDLL: THandle;
    FExMaxLength: Integer;
    FBkColor: Integer;
    procedure SetBkColor(const Value: Integer);
    procedure SetExMaxLength(const Value: Integer);
  public
    constructor Create(AParent: TWinControl; Text: String; WordWrap: Boolean = false);

    function CanUndo: Boolean;
    function CanRedo: Boolean;
    procedure Undo;
    procedure Redo;
    procedure ClearUndo;
    
    procedure LoadFromStream(Stream: TStream);

    property Color : Integer read FBkColor write SetBkColor;
    property MaxLength: Integer read FExMaxLength write SetExMaxLength default 0;
    property Text;
    property SelStart;
 end;

 { TTrackBar }

 TTrackBar = class(TWinControl)
  private
    function GetMax: DWord;
    function GetMin: DWord;
    function GetTBPosition: DWord;
    procedure SetMax(const Value: DWord);
    procedure SetMin(const Value: DWord);
    procedure SetTBPosition(const Value: DWord);
  public
    constructor Create(AParent : TWinControl);
    property Position:DWord read GetTBPosition write SetTBPosition;
    property Min:DWord read GetMin write SetMin;
    property Max:DWord read GetMax write SetMax;
 end;

 { TProgressBar }

 TProgressBar = class(TWinControl)
 private
    FPosition:Word;
    FMax: word;
    FStep: word;
    FMin: Word;
//    FSmooth: Boolean;
    procedure SetPBPosition(const Value: Word);
    procedure SetMin(const Value: word);
    procedure SetMax(const Value: word);
    procedure SetStep(const Value: word);
//    procedure SetSmooth(const Value: Boolean);
  public
    constructor Create(AParent : TWinControl);// override;
    property Max : word read FMax write SetMax;
    property Min : Word read FMin write SetMin;
    property Position:Word read FPosition write SetPBPosition;
//  property Smooth: Boolean read FSmooth write SetSmooth;
    property Step : word read FStep write SetStep;
 end;

 { TUpDown }

  TUpDownDirection = (updNone, updUp, updDown);

  NM_UPDOWN = packed record
    hdr: TNMHDR;
    iPos: Integer;
    iDelta: Integer;
  end;
  TNMUpDown = NM_UPDOWN;
  PNMUpDown = ^TNMUpDown;

  UDACCEL = packed record
    nSec: UINT;
    nInc: UINT;
  end;
  TUDAccel = UDACCEL;

  PUpDownData = ^TUpDownData;
  TUpDownData = packed record
//    FOrientation:TUpDownOrientation;
    FArrowKeys: Boolean;
    FHotTrack:Boolean;
    FAutoBuddy:Boolean;
    FThousands:Boolean;
    FWrap:Boolean;
//    FAlignButton: TUpDownAlignButton;
//    FOnChangingEx: TOnChangingEx;
    FMin : Integer;
    FMax : Integer;
  end;

 TUpDown = class(TWinControl)
  private
    FAssociate: TWinControl;
    function GetIncrement: Integer;
    function GetMax: Integer;
    function GetMin: Integer;
    procedure SetIncrement(const Value: Integer);
    procedure SetMax(const Value: Integer);
    procedure SetMin(const Value: Integer);
    procedure SetUpPosition(const Value: Integer);
    procedure SetAssociate(const Value: TWinControl);
    function GetUpPosition: Integer;
  public
    constructor Create(AParent : TWinControl);
    property Associate: TWinControl read FAssociate write SetAssociate;
    property Min:Integer read GetMin write SetMin;
    property Max:Integer read GetMax write SetMax;
    property Position:Integer read GetUpPosition write SetUpPosition;
    property Increment : Integer read GetIncrement write SetIncrement;
 end;

 TSpinEdit = class(TUpDown)
  private
  public
    EditBox: TEdit;
    constructor Create(AParent: TWinControl);
    procedure SetPosition(Left, Top:Integer);
    procedure SetBounds(Left, Top, Width, Height:Integer);
  end;

 { THotKey }

  THotKey = class(TWinControl)
  private
    FHotKey,
    FMod: Byte;
    procedure GetData;
    procedure SetData;
    function GetHotKey: byte;
    procedure SetHotKey(const Value: byte);
    function GetModifiers: TModifiers;
    procedure SetModifiers(const Value: TModifiers);
  public
    constructor Create(AParent : TWinControl);
    property HotKey: byte read GetHotKey write SetHotKey;
    property Modifiers: TModifiers read GetModifiers write SetModifiers;
  end;

 { TAnimate }

 TCommonAVI = (aviNone, aviFindFolder, aviFindFile, aviFindComputer, aviCopyFiles,
    aviCopyFile, aviRecycleFile, aviEmptyRecycle, aviDeleteFile);

 TAnimate = class(TWinControl)
  private
    FActive: Boolean;
    FFileName: String;
    FCommonAVI: TCommonAVI;
//    FFrameCount: Integer;
//    FFrameHeight: Integer;
//    FFrameWidth: Integer;
    FResHandle: THandle;
    FResName: string;
    FResId: Integer;
    FStartFrame: Smallint;
    FStopFrame: Smallint;
//    FStopCount: Integer;    
    FOpen: Boolean;
    procedure GetFrameInfo;
    function GetActualResHandle: THandle;
    function GetActualResId: Integer;
    procedure Open;
    procedure SetStartFrame(const Value: Smallint);
    procedure SetStopFrame(const Value: Smallint);
    procedure SetCommonAVI(const Value: TCommonAVI);
  public
    constructor Create(AParent : TWinControl);

    function OpenFile(hInst:Integer; res:pChar): Boolean;
    procedure LoadCommonAVI(id:Integer);

    procedure Play(FromFrame, ToFrame: Word; Count: Integer);
    procedure Seek(Frame: Smallint);    
    procedure Stop;

    property CommonAVI: TCommonAVI read FCommonAVI write SetCommonAVI default aviNone;
    property StartFrame: Smallint read FStartFrame write SetStartFrame default 1;
    property StopFrame: Smallint read FStopFrame write SetStopFrame default 0;
 end;  

 { TDateTimePicker }

 TDTDateMode = (dmComboBox, dmUpDown);
 TDateTimeKind = (dtkDate, dtkTime);
 TDTDateFormat = (dfShort, dfLong);

 TDateTimePicker = class(TWinControl)
  private
    FKind: TDateTimeKind;
    FDateFormat: TDTDateFormat;
//    FDateMode: TDTDateMode;
    function GetDateTime: TDateTime;
    procedure SetDateTime(const Value: TDateTime);
    procedure SetKind(const Value: TDateTimeKind);
    procedure SetDateFormat(const Value: TDTDateFormat);
//    procedure SetDateMode(const Value: TDTDateMode);
  public
    constructor Create(AParent : TWinControl; Kind: TDateTimeKind = dtkDate);
    property DateFormat: TDTDateFormat read FDateFormat write SetDateFormat;
//    property DateMode: TDTDateMode read FDateMode write SetDateMode;
    property DateTime:TDateTime read GetDateTime write SetDateTime;
    property Kind: TDateTimeKind read FKind write SetKind;
 end;

 { TMonthCalendar }

  TMonthCalendar = class(TWinControl)
   private
     function GetDateTime: TDateTime;
     procedure SetDateTime(const Value: TDateTime);
   public
     constructor Create(AParent : TWinControl);
     property BorderStyle;
     property DateTime:TDateTime read GetDateTime write SetDateTime;
  end;

 { TTreeView }

  PTVItemA = ^TTVItemA;
  PTVItemW = ^TTVItemW;
  PTVItem = PTVItemA;
  {$EXTERNALSYM tagTVITEMA}
  tagTVITEMA = packed record
    mask: UINT;
    hItem: HTreeItem;
    state: UINT;
    stateMask: UINT;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iImage: Integer;
    iSelectedImage: Integer;
    cChildren: Integer;
    lParam: LPARAM;
  end;
  {$EXTERNALSYM tagTVITEMW}
  tagTVITEMW = packed record
    mask: UINT;
    hItem: HTreeItem;
    state: UINT;
    stateMask: UINT;
    pszText: PWideChar;
    cchTextMax: Integer;
    iImage: Integer;
    iSelectedImage: Integer;
    cChildren: Integer;
    lParam: LPARAM;
  end;
  {$EXTERNALSYM tagTVITEM}
  tagTVITEM = tagTVITEMA;
  {$EXTERNALSYM _TV_ITEMA}
  _TV_ITEMA = tagTVITEMA;
  {$EXTERNALSYM _TV_ITEMW}
  _TV_ITEMW = tagTVITEMW;
  {$EXTERNALSYM _TV_ITEM}
  _TV_ITEM = _TV_ITEMA;
  TTVItemA = tagTVITEMA;
  TTVItemW = tagTVITEMW;
  TTVItem = TTVItemA;
  {$EXTERNALSYM TV_ITEMA}
  TV_ITEMA = tagTVITEMA;
  {$EXTERNALSYM TV_ITEMW}
  TV_ITEMW = tagTVITEMW;
  {$EXTERNALSYM TV_ITEM}
  TV_ITEM = TV_ITEMA;

  // only used for Get and Set messages.  no notifies
  {$EXTERNALSYM tagTVITEMEXA}
  tagTVITEMEXA = packed record
    mask: UINT;
    hItem: HTREEITEM;
    state: UINT;
    stateMask: UINT;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iImage: Integer;
    iSelectedImage: Integer;
    cChildren: Integer;
    lParam: LPARAM;
    iIntegral: Integer;
  end;
  {$EXTERNALSYM tagTVITEMEXW}
  tagTVITEMEXW = packed record
    mask: UINT;
    hItem: HTREEITEM;
    state: UINT;
    stateMask: UINT;
    pszText: PWideChar;
    cchTextMax: Integer;
    iImage: Integer;
    iSelectedImage: Integer;
    cChildren: Integer;
    lParam: LPARAM;
    iIntegral: Integer;
  end;
  {$EXTERNALSYM tagTVITEMEX}
  tagTVITEMEX = tagTVITEMEXA;
  PTVItemExA = ^TTVItemExA;
  PTVItemExW = ^TTVItemExW;
  PTVItemEx = PTVItemExA;
  TTVItemExA = tagTVITEMEXA;
  TTVItemExW = tagTVITEMEXW;
  TTVItemEx = TTVItemExA; 

  PTVInsertStructA = ^TTVInsertStructA;
  PTVInsertStructW = ^TTVInsertStructW;
  PTVInsertStruct = PTVInsertStructA;
  {$EXTERNALSYM tagTVINSERTSTRUCTA}
  tagTVINSERTSTRUCTA = packed record
    hParent: HTreeItem;
    hInsertAfter: HTreeItem;
    case Integer of
      0: (itemex: TTVItemExA);
      1: (item: TTVItemA);
  end;
  {$EXTERNALSYM tagTVINSERTSTRUCTW}
  tagTVINSERTSTRUCTW = packed record
    hParent: HTreeItem;
    hInsertAfter: HTreeItem;
    case Integer of
      0: (itemex: TTVItemExW);
      1: (item: TTVItemW);
  end;
  {$EXTERNALSYM tagTVINSERTSTRUCT}
  tagTVINSERTSTRUCT = tagTVINSERTSTRUCTA;
  {$EXTERNALSYM _TV_INSERTSTRUCTA}
  _TV_INSERTSTRUCTA = tagTVINSERTSTRUCTA;
  {$EXTERNALSYM _TV_INSERTSTRUCTW}
  _TV_INSERTSTRUCTW = tagTVINSERTSTRUCTW;
  {$EXTERNALSYM _TV_INSERTSTRUCT}
  _TV_INSERTSTRUCT = _TV_INSERTSTRUCTA;
  TTVInsertStructA = tagTVINSERTSTRUCTA;
  TTVInsertStructW = tagTVINSERTSTRUCTW;
  TTVInsertStruct = TTVInsertStructA;
  {$EXTERNALSYM TV_INSERTSTRUCTA}
  TV_INSERTSTRUCTA = tagTVINSERTSTRUCTA;
  {$EXTERNALSYM TV_INSERTSTRUCTW}
  TV_INSERTSTRUCTW = tagTVINSERTSTRUCTW;
  {$EXTERNALSYM TV_INSERTSTRUCT}
  TV_INSERTSTRUCT = TV_INSERTSTRUCTA;

 TTreeView = class(TWinControl)
 private
    FImages: TImageList;
    FStateImages: TImageList; 
    procedure SetStateImages(const Value: TImageList);
    procedure SetImages(const Value: TImageList);
 public
    constructor Create(AParent : TWinControl);

    function ItemInsert(Parent: Integer; Text: String): Integer;
//    function ItemCount: Integer;

    property Images: TImageList read FImages write SetImages;
    property StateImages: TImageList read FStateImages write SetStateImages;
 end;

 { TListView }

  PLVColumnA = ^TLVColumnA;
  PLVColumn = PLVColumnA;
  {$EXTERNALSYM tagLVCOLUMNA}
  tagLVCOLUMNA = packed record
    mask: UINT;
    fmt: Integer;
    cx: Integer;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iSubItem: Integer;
    iImage: Integer;
    iOrder: Integer;
  end;
  {$EXTERNALSYM tagLVCOLUMN}
  tagLVCOLUMN = tagLVCOLUMNA;
  {$EXTERNALSYM _LV_COLUMNA}
  _LV_COLUMNA = tagLVCOLUMNA;
  {$EXTERNALSYM _LV_COLUMN}
  _LV_COLUMN = _LV_COLUMNA;
  TLVColumnA = tagLVCOLUMNA;
  TLVColumn = TLVColumnA;
  {$EXTERNALSYM LV_COLUMNA}
  LV_COLUMNA = tagLVCOLUMNA;
  {$EXTERNALSYM LV_COLUMN}
  LV_COLUMN = LV_COLUMNA;

  PLVItemA = ^TLVItemA;
  PLVItemW = ^TLVItemW;
  PLVItem = PLVItemA;
  {$EXTERNALSYM tagLVITEMA}
  tagLVITEMA = packed record
    mask: UINT;
    iItem: Integer;
    iSubItem: Integer;
    state: UINT;
    stateMask: UINT;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iImage: Integer;
    lParam: LPARAM;
    iIndent: Integer;
  end;

  
  {$EXTERNALSYM tagLVITEMW}
  tagLVITEMW = packed record
    mask: UINT;
    iItem: Integer;
    iSubItem: Integer;
    state: UINT;
    stateMask: UINT;
    pszText: PWideChar;
    cchTextMax: Integer;
    iImage: Integer;
    lParam: LPARAM;
    iIndent: Integer;
  end;
  {$EXTERNALSYM tagLVITEM}
  tagLVITEM = tagLVITEMA;
  {$EXTERNALSYM _LV_ITEMA}
  _LV_ITEMA = tagLVITEMA;
  {$EXTERNALSYM _LV_ITEMW}
  _LV_ITEMW = tagLVITEMW;
  {$EXTERNALSYM _LV_ITEM}
  _LV_ITEM = _LV_ITEMA;
  TLVItemA = tagLVITEMA;
  TLVItemW = tagLVITEMW;
  TLVItem = TLVItemA;
  {$EXTERNALSYM LV_ITEMA}
  LV_ITEMA = tagLVITEMA;
  {$EXTERNALSYM LV_ITEMW}
  LV_ITEMW = tagLVITEMW;
  {$EXTERNALSYM LV_ITEM}
  LV_ITEM = LV_ITEMA;

const
  vsIcon      = LVS_ICON;
  vsList      = LVS_LIST;
  vsReport    = LVS_REPORT;
  vsSmallIcon = LVS_SMALLICON;

  lvRowSelect = LVS_EX_FULLROWSELECT;
  lvGridLines = LVS_EX_GRIDLINES;

type
  TListArrangement = (arAlignBottom, arAlignLeft, arAlignRight, arAlignTop, arDefault, arSnapToGrid);
  TSortType = (stNone, stData, stText, stBoth);

  TLVCompareEvent = procedure(Sender: TObject; Item1, Item2: Integer;
    Data: Integer; var Compare: Integer) of object;

  TListView = class(TWinControl)
  private
    FColumnCount: Integer;
    FViewStyle: Integer;
    FOptionsEx: Integer;
    FStateImages: TImageList;
    FLargeImages: TImageList;
    FSmallImages: TImageList;
    FFlatScrollBars: Boolean;
    FHotTrack: Boolean;
    FSortType: TSortType;
    FOnCompare: TLVCompareEvent;
//    FOnSelectItem: TOnEvent;
    procedure SetViewStyle(const Value: Integer);
    function GetItem(Row, Col: Integer): String;
    procedure SetItem(Row, Col: Integer; const Value: String);
    procedure SetOptionsEx(const Value: Integer);
    function GetSelCount: Integer;
    function GetSelectedCaption: String;
    function GetSelectedIndex: Integer;
    procedure SetSelectedCaption(const Value: String);
    procedure SetLargeImages(const Value: TImageList);
    procedure SetSmallImages(const Value: TImageList);
    procedure SetStateImages(const Value: TImageList);
    function GetItemImageIndex(Index: Integer): Integer;
    procedure SetItemImageIndex(Index: Integer; const Value: Integer);
    procedure SetFlatScrollBars(const Value: Boolean);
    procedure SetHotTrack(const Value: Boolean);
    function GetColumns(ColumnIndex: Integer): String;
    procedure SetColumns(ColumnIndex: Integer; const Value: String);
    procedure SetSortType(const Value: TSortType);
    procedure SetSelectedIndex(const Value: Integer);
  public
    constructor Create(AParent : TWinControl);

    function AlphaSort: Boolean;
    procedure Arrange(Code: TListArrangement);
    procedure Clear;

    procedure ColumnAdd(ACaption: String; Width: Integer);
    procedure ColumnAddEx(ACaption: String; Width: Integer; Align: TTextAlign);
    function  ColumnCount: Integer;
    procedure ColumnDelete(Index: Integer);
    procedure ColumnInsert(ACaption: String; Index, Width: Integer);
    procedure ColumnInsertEx(ACaption: String; Index, Width: Integer; Align: TTextAlign);    
    property  Columns[ColumnIndex: Integer]: String read GetColumns write SetColumns;

    property FlatScrollBars: Boolean read FFlatScrollBars write SetFlatScrollBars default False;
    property HotTrack: Boolean read FHotTrack write SetHotTrack default False;    

    function ItemAdd(Caption: String): Integer;
    function  ItemCount:Integer;
    procedure ItemDelete(Index: Integer);
    function ItemInsert(Caption: String; Index: Integer): Integer;
    property  ItemImageIndex[Index: Integer]: Integer read GetItemImageIndex write SetItemImageIndex;

    property SelectedIndex: Integer read GetSelectedIndex write SetSelectedIndex;
    property SelectedCaption: String read GetSelectedCaption write SetSelectedCaption;

    property Items[Row, Col: Integer]: String read GetItem write SetItem; default;
    property SelCount: Integer read GetSelCount;
    property OptionsEx: Integer read FOptionsEx write SetOptionsEx;
    property SortType: TSortType read FSortType write SetSortType default stNone;
    property ViewStyle:Integer read FViewStyle write SetViewStyle;
    property SmallImages: TImageList read FSmallImages write SetSmallImages;
    property LargeImages: TImageList read FLargeImages write SetLargeImages;
    property StateImages: TImageList read FStateImages write SetStateImages;

    //property OnSelectItem: TOnEvent read FOnSelectItem write FOnSelectItem;
    property OnCompare: TLVCompareEvent read FOnCompare write FOnCompare;
 end;

 { THeaderControl }

  _HD_ITEMA = packed record
    Mask: Cardinal;
    cxy: Integer;
    pszText: PAnsiChar;
    hbm: HBITMAP;
    cchTextMax: Integer;
    fmt: Integer;
    lParam: LPARAM;
    iImage: Integer;        // index of bitmap in ImageList
    iOrder: Integer;        // where to draw this item
  end;
  HD_ITEMA = _HD_ITEMA;
  HD_ITEM = HD_ITEMA;

  THeaderControl = class(TWinControl)
  private
  public
    constructor Create(AParent : TWinControl);
    function SectionAdd(Text: String; Width: Integer): Integer;
    function SectionCount: Integer;
    function SectionDelete(Index: Integer): Boolean;
    function SectionInsert(Index:Integer; Text: String; Width:Integer): Integer;
  end;

 { TStatusBar }

  TStatusBar = class(TWinControl)
   private
    FSimplePanel: Boolean;
     function GetSimpleText: String;
     procedure SetSimpleText(const Value: String);
    procedure SetSimplePanel(const Value: Boolean);
    procedure WMSIZE(Sender: TObject);
   public
     constructor Create(AParent : TWinControl; SimpleText:String);
     property SimpleText: String read GetSimpleText write SetSimpleText;
     property SimplePanel: Boolean read FSimplePanel write SetSimplePanel;
     function SetParts(PartsNum: Integer; const Coords: array of Integer): Boolean;
     function GetParts(var PartsNum: Integer; var Coords: array of Integer): Boolean;
     procedure SetPartText(PartNum: Byte; TextStyle: Word; const Text: string);
     function GetPartText(PartNum: Byte): string;
  end;

  { TToolBar }

  TToolBar = class(TWinControl)
   private
    FIndent: Integer;
    FImages: TImageList;
    FButtonCount: Integer;
    procedure SetIndent(const Value: Integer);
    procedure SetImages(const Value: TImageList);
    function GetButtonCheck(ButtonIndex: Integer): Boolean;
    procedure SetButtonCheck(ButtonIndex: Integer; const Value: Boolean);
    function GetButtonImageIndex(ButtonIndex: Integer): Integer;
    procedure SetButtonImageIndex(ButtonIndex: Integer;
      const Value: Integer);
    function GetButtonPressed(ButtonIndex: Integer): Boolean;
    procedure SetButtonPressed(ButtonIndex: Integer; const Value: Boolean);
   public
     constructor Create(AParent : TWinControl; Flat: Boolean);

     function ButtonAdd(Caption: String; ImageIndex: Integer): Integer;
     function ButtonCaption(Index: Integer): String;
     function ButtonCount: Integer;
     property ButtonCheck[ButtonIndex: Integer]: Boolean read GetButtonCheck write SetButtonCheck;
     property ButtonImageIndex[ButtonIndex: Integer]: Integer read GetButtonImageIndex write SetButtonImageIndex;
     property ButtonPressed[ButtonIndex: Integer]: Boolean read GetButtonPressed write SetButtonPressed;

     procedure StandartImages(LargeImages: Boolean);

     property Images: TImageList read FImages write SetImages;
     property Indent: Integer read FIndent write SetIndent;
  end;

//Misk
  TIPEdit = class(TWinControl)
   private
   public
     constructor Create(AParent : TWinControl; Text:String);
  end;

//System
  TTimer = class
  private
    FInterval: Cardinal;
    FWindowHandle: HWND;
    FOnTimer: TOnEvent;
    FEnabled: Boolean;
    procedure UpdateTimer;
    procedure SetEnabled(Value: Boolean);
    procedure SetInterval(Value: Cardinal);
    procedure SetOnTimer(Value: TOnEvent);
    procedure WndProc(var Msg: TMessage);
  protected
    procedure Timer; dynamic;
  public
    constructor Create;
    constructor CreateEx(Interval: Cardinal; Enabled: Boolean);
    destructor Destroy; override;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Interval: Cardinal read FInterval write SetInterval default 1000;
    property OnTimer: TOnEvent read FOnTimer write SetOnTimer;
  end;

//Win 3.1

  { TFileListBox }

  TFileListBox = class(TWinControl)
   private
     FDirectory: string;
     FMask: string;
     procedure SetDirectory(const Value: string);
     procedure SetMask(const Value: string);
   public
     constructor Create(AParent : TWinControl; Path: String);
     procedure Update;
     property Directory: string read FDirectory write SetDirectory;
     property Mask: string read FMask write SetMask;     
  end;

//Events
  TEvent = packed record
   Code: Pointer; // Pointer to method code.
   Data: Pointer; // Pointer to object, owning the method.
  end;
 
  function NewEvent({Data,} Func: Pointer): TEvent;
  procedure Close;
  procedure Run(Form:TForm);

var
  Application: TWinControl;
// DefaultPixelFormat: TPixelFormat = pf16bit;

 { ObjectInstance }

const
  InstanceCount = 313;

type
  TWndMethod = procedure(var Message: TMessage) of object;

  PObjectInstance = ^TObjectInstance;
  TObjectInstance = packed record
    Code: Byte;
    Offset: Integer;
    case Integer of
      0: (Next: PObjectInstance);
      1: (Method: TWndMethod);
  end;

  PInstanceBlock = ^TInstanceBlock;
  TInstanceBlock = packed record
    Next: PInstanceBlock;
    Code: array[1..2] of Byte;
    WndProcPtr: Pointer;
    Instances: array[0..InstanceCount] of TObjectInstance;
  end; 

 function AllocateHWnd(Method: TWndMethod): HWND;
 procedure DeallocateHWnd(Wnd: HWND);
 procedure FreeAndNil(var Obj);

 { TRegistry }

type
  TRegDataType = (rdUnknown, rdString, rdExpandString, rdInteger, rdBinary);

  TRegDataInfo = record
    RegData: TRegDataType;
    DataSize: Integer;
  end;

  TRegistry = class
  private
    FCurrentKey: HKEY;
    FRootKey: HKEY;
//    FLazyWrite: Boolean;
    FCurrentPath: string;
//    FCloseRootKey: Boolean;
    FAccess: LongWord;
{+}    procedure SetRootKey(Value: HKEY);
  protected
//    function GetBaseKey(Relative: Boolean): HKey;        
  public
{+}    constructor Create; {$IFDEF USE_OBJECT}{$ELSE} overload; {$ENDIF}
    constructor Create(AAccess: LongWord); overload;
{+}    destructor Destroy; {$IFDEF USE_OBJECT}{$ELSE} override; {$ENDIF}
{+}    procedure CloseKey;
{+}    function CreateKey(const Key: string): Boolean;
    function DeleteKey(const Key: string): Boolean;
    function DeleteValue(const Name: string): Boolean;
    function GetDataInfo(const ValueName: string; var Value: TRegDataInfo): Boolean;
    function GetDataSize(const ValueName: string): Integer;
//    function GetDataType(const ValueName: string): TRegDataType;
//    function GetKeyInfo(var Value: TRegKeyInfo): Boolean;
    procedure GetKeyNames(var Strings: String);
{+}    procedure GetValueNames(var Strings: String);
//    function HasSubKeys: Boolean;
    function KeyExists(const Key: string): Boolean;
//    function LoadKey(const Key, FileName: string): Boolean;
//    procedure MoveKey(const OldName, NewName: string; Delete: Boolean);
{+}    function OpenKey(const Key: string; CanCreate: Boolean): Boolean;
    function OpenKeyReadOnly(const Key: String): Boolean;
//    function ReadCurrency(const Name: string): Currency;
    function ReadBinaryData(const Name: string; var Buffer; BufSize: Integer): Integer;
    function ReadBool(const Name: string): Boolean;
//    function ReadDate(const Name: string): TDateTime;
    function ReadDateTime(const Name: string): TDateTime;
//    function ReadFloat(const Name: string): Double;
    function ReadInteger(const Name: string): Integer;
    function ReadString(const Name: string): string;
//    function ReadTime(const Name: string): TDateTime;
    function RegistryConnect(const UNCName: string): Boolean;
    procedure RenameValue(const OldName, NewName: string);
//    function ReplaceKey(const Key, FileName, BackUpFileName: string): Boolean;
//    function RestoreKey(const Key, FileName: string): Boolean;
//    function SaveKey(const Key, FileName: string): Boolean;
//    function UnLoadKey(const Key: string): Boolean;
    function ValueExists(const Name: string): Boolean;
//    procedure WriteCurrency(const Name: string; Value: Currency);
    procedure WriteBinaryData(const Name: string; var Buffer; BufSize: Integer);
    procedure WriteBool(const Name: string; Value: Boolean);
//    procedure WriteDate(const Name: string; Value: TDateTime);
    procedure WriteDateTime(const Name: string; Value: TDateTime);
//    procedure WriteFloat(const Name: string; Value: Double);
    procedure WriteInteger(const Name: string; Value: Integer);
    procedure WriteString(const Name, Value: string);
    procedure WriteExpandString(const Name, Value: string);
//    procedure WriteTime(const Name: string; Value: TDateTime);
    property CurrentKey: HKEY read FCurrentKey;
    property CurrentPath: string read FCurrentPath;
//    property LazyWrite: Boolean read FLazyWrite write FLazyWrite;
{+}    property RootKey: HKEY read FRootKey write SetRootKey;
    property Access: LongWord read FAccess write FAccess;
 end; 
//TOpenDialog
 type

  tagOFNA = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hInstance: HINST;
    lpstrFilter: PAnsiChar;
    lpstrCustomFilter: PAnsiChar;
    nMaxCustFilter: DWORD;
    nFilterIndex: DWORD;
    lpstrFile: PAnsiChar;
    nMaxFile: DWORD;
    lpstrFileTitle: PAnsiChar;
    nMaxFileTitle: DWORD;
    lpstrInitialDir: PAnsiChar;
    lpstrTitle: PAnsiChar;
    Flags: DWORD;
    nFileOffset: Word;
    nFileExtension: Word;
    lpstrDefExt: PAnsiChar;
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpTemplateName: PAnsiChar;
  end;
  TOpenFilenameA = tagOFNA;
//  TOpenFilenameW = tagOFNW;
  TOpenFilename = TOpenFilenameA;
  TOpenSaveOption = (ofReadOnly, ofHideReadOnly, ofPathMustExist,
                     ofFileMustExist);

  TOpenSaveOptions = set of TOpenSaveOption;

{$IFDEF USE_OBJECT}
 TOpenDialog = object
{$ELSE}
 TOpenDialog = class
{$ENDIF}
  private
   FFilter : String;
   FFilterIndex : Integer;
//   FOpenDialog : Boolean;
   FInitialDir : String;
   FDefExtension : String;
   FFilename : string;
   FTitle : string;
   FOptions : TOpenSaveOptions;
   FHandle: THandle;
  public
   constructor Create(AParent: TForm);
   property DefaultExt : String read FDefExtension write FDefExtension;
   function Execute: Boolean;
   property FileName : String read FFilename write FFileName;
   property Filter : String read FFilter write FFilter;
   property FilterIndex : Integer read FFilterIndex write FFilterIndex;
   property InitialDir : String read FInitialDir write FInitialDir;
   property Title : String read Ftitle write Ftitle;
   property Options : TOpenSaveOptions read FOptions write FOptions;
 end;

{$IFDEF USE_OBJECT}
 TSaveDialog = object
{$ELSE}
 TSaveDialog = class
{$ENDIF}
  public
  private
   FFilter : String;
   FFilterIndex : Integer;
//   FOpenDialog : Boolean;
   FInitialDir : String;
   FDefExtension : String;
   FFilename : string;
   FTitle : string;
   FOptions : TOpenSaveOptions;
   FHandle: THandle;
  public
   constructor Create(AParent: TForm);
   property DefaultExt : String read FDefExtension write FDefExtension;
   function Execute: Boolean;
   property FileName : String read FFilename write FFileName;
   property Filter : String read FFilter write FFilter;
   property FilterIndex : Integer read FFilterIndex write FFilterIndex;
   property InitialDir : String read FInitialDir write FInitialDir;
   property Title : String read Ftitle write Ftitle;
   property Options : TOpenSaveOptions read FOptions write FOptions;
 end;

 { TFontDialog }

    tagCHOOSEFONTA = packed record
    lStructSize: DWORD;
    hWndOwner: HWnd;            { caller's window handle }
    hDC: HDC;                   { printer DC/IC or nil }
    lpLogFont: PLogFontA;     { pointer to a LOGFONT struct }
    iPointSize: Integer;        { 10 * size in points of selected font }
    Flags: DWORD;               { dialog flags }
    rgbColors: COLORREF;        { returned text color }
    lCustData: LPARAM;          { data passed to hook function }
    lpfnHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
                                { pointer to hook function }
    lpTemplateName: PAnsiChar;    { custom template name }
    hInstance: HINST;       { instance handle of EXE that contains
                                  custom dialog template }
    lpszStyle: PAnsiChar;         { return the style field here
                                  must be lf_FaceSize or bigger }
    nFontType: Word;            { same value reported to the EnumFonts
                                  call back with the extra fonttype_
                                  bits added }
    wReserved: Word;
    nSizeMin: Integer;          { minimum point size allowed and }
    nSizeMax: Integer;          { maximum point size allowed if
                                  cf_LimitSize is used }
  end;
  TChooseFontA = tagCHOOSEFONTA;
  TChooseFont = TChooseFontA;

(* TFontDialogDevice = (fdBoth, fdScreen,fdPrinter);

 TFontDialog = class
  private
    FFont: TFont;
    FMinFontSize: Integer;
    FMaxFontSize: Integer;
    FDevice: TFontDialogDevice;
    FHandle: THandle;
  public
    constructor Create;
    function Execute: Boolean;

    property Device:TFontDialogDevice read FDevice write FDevice;
    property Font: TFont read FFont write FFont;
    property Handle: THandle read FHandle write FHandle;
    property MinFontSize:Integer read FMinFontSize write FMinFontSize;
    property MaxFontSize:Integer read FMaxFontSize write FMaxFontSize;
 end;

var
  FontDialogNow: TFontDialog;

const
  IDAPPLYBTN=$402;
  WM_CHOOSEFONT_GETLOGFONT = WM_USER + 1; *)

type

  { TColorDialog }

  TColorDialog = class
  private
    FHandle: THandle;
    FFullOpen,
    FPreventFullOpen: Boolean;
    FColors: array[0..16] of TColor;
    function GetCustomColors(ColorIndex: Integer): TColor;
    procedure SetCustomColors(ColorIndex: Integer; const Value: TColor);
  public
    constructor Create(AParent: TForm);
    function Execute: Boolean;

    property Color: TColor read FColors[0] write FColors[0] default clBlack;
    property CustomColors[ColorIndex: Integer]: TColor read GetCustomColors write SetCustomColors;
  end;

  { TPrintDialog }

  TPrintDialogOption = (pdPrinterSetup,pdCollate,pdPrintToFile,pdPageNums,pdSelection, pdWarning,pdDeviceDepend,pdHelp,pdReturnDC);
  TPrintDialogOptions = Set of TPrintDialogOption;

  TPrintDialog = class
  private
    fDevNames : PDevNames;
    fAdvanced : WORD;
    ftagPD    : tagPD;
    fOptions  : TPrintDialogOptions;
    PrinterInfo : TPrinterInfo;
    fAlwaysReset : Boolean;
    FPrintToFile: Boolean;
  protected
    function GetError : Integer;
    property AlwaysReset : Boolean read fAlwaysReset write fAlwaysReset;
    {* Currently PrintDialog by default  preserve last options selected by user, but
    if this property is TRUE - dialog is always reset to default printer and default options}
    property Error : Integer read GetError;
    property DC: hDC read ftagPD.hDC;
    function Info : TPrinterInfo;
    property tagPD    : tagPD read ftagPD write ftagPD;
    property Advanced : WORD read fAdvanced write fAdvanced;
    procedure FillOptions(DlgOptions : TPrintDialogOptions);
    procedure Prepare;
  public
    function Execute: Boolean;
  published
    constructor Create(Handle: THandle; Options: TPrintDialogOptions);
    destructor Destroy; override;

    property FromPage : WORD read ftagPD.nFromPage write ftagPD.nFromPage;
    property ToPage   : WORD read ftagPD.nToPage write ftagPD.nToPage;
    property MinPage  : WORD read ftagPD.nMinPage write ftagPD.nMinPage;
    property MaxPage  : WORD read ftagPD.nMaxPage write ftagPD.nMaxPage;
    property Copies   : WORD read ftagPD.nCopies write ftagPD.nCopies;
    property Options  : TPrintDialogOptions read fOptions write fOptions;
    property PrintToFile: Boolean read FPrintToFile write FPrintToFile default False;
  end;

  { TPageSetupDialog }

  TPageSetupOption = (psdMargins,psdOrientation,psdSamplePage,psdPaperControl,psdPrinterControl, psdHundredthsOfMillimeters,psdThousandthsOfInches,psdUseMargins,psdUseMinMargins,psdWarning,psdHelp,psdReturnDC);
  TPageSetupOptions = Set of TPageSetupOption;

  TPageSetupDialog = class
  private
    fhDC       : HDC;
    fAdvanced  : WORD;
    ftagPSD    : tagPSD;
    fOptions   : TPageSetupOptions;
    fDevNames : PDevNames;
    PrinterInfo : TPrinterInfo;
    fAlwaysReset : Boolean;
  protected
    function GetError: Integer;
    property Error: Integer read GetError;
    //property DC: hDC read fhDC;
    function Info: TPrinterInfo;
    //property tagPSD: tagPSD read ftagPSD write ftagPSD;
    //property Advanced: WORD read fAdvanced write fAdvanced;
    procedure FillOptions(DlgOptions: TPageSetupOptions);
    procedure Prepare;
    //property AlwaysReset : Boolean read fAlwaysReset write fAlwaysReset;    
  public
    function Execute : Boolean;
  published
    constructor Create(Handle: THandle; Options: TPageSetupOptions);
    destructor Destroy; override;
    
    function GetMargins: TRect;
    function GetMinMargins: TRect;
    function GetPaperSize:  TPoint;
    procedure SetMargins(Left,Top,Right,Bottom : Integer);
    procedure SetMinMargins(Left,Top,Right,Bottom: Integer);
    property Options  : TPageSetupOptions read fOptions write fOptions;
  end;



//Без исп. классов
procedure SLAdd(var List:TSList; S:String);
procedure SLClear(var List:TSList);
procedure SLSetText(var List:TSList; S:String);
procedure SLDelete(var List:TSList; Index: Integer);
function SLStrings(var List:TSList; Index:Integer):String;
function SLText(List:TSList):String;
function SLIndexOf(List:TSList;S:String):Integer;
//function SLInsert(List:TSList; Index: Integer; S:String): Integer;


  { Exceptions }

type
  Exception = class(TObject)
  private
    FMessage: string;
    FHelpContext: Integer;
  public
    constructor Create(const Msg: string);
    constructor CreateFmt(const Msg: string; const Args: array of const);    
    constructor CreateRes(Ident: Integer); overload;
    constructor CreateRes(ResStringRec: PResStringRec); overload;    
    constructor CreateResFmt(Ident: Integer; const Args: array of const); overload;
    constructor CreateResFmt(ResStringRec: PResStringRec; const Args: array of const); overload;
    constructor CreateHelp(const Msg: string; AHelpContext: Integer);    
    property HelpContext: Integer read FHelpContext write FHelpContext;
    property Message: string read FMessage write FMessage;        
  end;

  ExceptClass = class of Exception;

  EAbort = class(Exception);

  EHeapException = class(Exception)
  private
//    AllowFree: Boolean;
  public
//    procedure FreeInstance; override;
  end; 

  EOutOfMemory = class(EHeapException);

  EInOutError = class(Exception)
  public
    ErrorCode: Integer;
  end;

  EExternal = class(Exception)
  public
    ExceptionRecord: PExceptionRecord;
  end;

  EExternalException = class(EExternal);

  EIntError = class(EExternal);
  EDivByZero = class(EIntError);
  ERangeError = class(EIntError);
  EIntOverflow = class(EIntError);

  EMathError = class(EExternal);
  EInvalidOp = class(EMathError);
  EZeroDivide = class(EMathError);
  EOverflow = class(EMathError);
  EUnderflow = class(EMathError);

  EInvalidPointer = class(EHeapException);

  EInvalidCast = class(Exception);

  EConvertError = class(Exception);

  EAccessViolation = class(EExternal);
  EPrivilege = class(EExternal);
  EStackOverflow = class(EExternal);
  EControlC = class(EExternal);

  EVariantError = class(Exception);

  EPropReadOnly = class(Exception);
  EPropWriteOnly = class(Exception);

  EAssertionFailed = class(Exception);

  EAbstractError = class(Exception);

  EIntfCastError = class(Exception);

  EInvalidContainer = class(Exception);
  EInvalidInsert = class(Exception);

  EPackageError = class(Exception);

  EWin32Error = class(Exception)
  public
    ErrorCode: DWORD;
  end;

  ESafecallException = class(Exception);

{ Exception classes }

  EStreamError = class(Exception);
  EFCreateError = class(EStreamError);
  EFOpenError = class(EStreamError);
  EFilerError = class(EStreamError);
  EReadError = class(EFilerError);
  EWriteError = class(EFilerError);
  EClassNotFound = class(EFilerError);
  EMethodNotFound = class(EFilerError);
  EInvalidImage = class(EFilerError);
  EResNotFound = class(Exception);
  EListError = class(Exception);
  EBitsError = class(Exception);
  EStringListError = class(Exception);
  EComponentError = class(Exception);
  EParserError = class(Exception);
  EOutOfResources = class(EOutOfMemory);
  EInvalidOperation = class(Exception);

procedure ConvertErrorFmt(ResString: PResStringRec; const Args: array of const);
function ExceptObject: TObject;
function LoadStr(Ident: Integer): string; 
function SafeLoadLibrary(const Filename: string; ErrorMode: UINT = SEM_NOOPENFILEERRORBOX): HMODULE;
procedure RaiseLastWin32Error;
function Win32Check(RetVal: BOOL): BOOL;
procedure Abort;

  { Generic procedure pointer }

type  
  TProcedure = procedure;

  { TThread }

type 
  EThread = class(Exception);

  TThreadMethod = procedure of object;
  TThreadPriority = (tpIdle, tpLowest, tpLower, tpNormal, tpHigher, tpHighest,
    tpTimeCritical);

  TThread = class
  private
    FHandle: THandle;
    FThreadID: THandle;
    FTerminated: Boolean;
    FSuspended: Boolean;
    FFreeOnTerminate: Boolean;
    FFinished: Boolean;
    FReturnValue: Integer;
    FOnTerminate: TOnEvent;
    FMethod: TThreadMethod;
    FSynchronizeException: TObject;
    FOnExecute: TOnEvent;
    FOnSuspend: TOnEvent;
    procedure CallOnTerminate;
    function GetPriority: TThreadPriority;
    procedure SetPriority(Value: TThreadPriority);
    procedure SetSuspended(Value: Boolean);
  protected
    procedure DoTerminate; virtual;
    procedure Execute; virtual; abstract;
    procedure Synchronize(Method: TThreadMethod);
    property ReturnValue: Integer read FReturnValue write FReturnValue;
    property Terminated: Boolean read FTerminated;
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
    procedure Resume;
    procedure Suspend;
    procedure Terminate;
    function WaitFor: LongWord;
    property FreeOnTerminate: Boolean read FFreeOnTerminate write FFreeOnTerminate;
    property Handle: THandle read FHandle;
    property Priority: TThreadPriority read GetPriority write SetPriority;
    property Suspended: Boolean read FSuspended write SetSuspended;
    property ThreadID: THandle read FThreadID;
    property OnExecute: TOnEvent read FOnExecute write FOnExecute;
    property OnSuspend: TOnEvent read FOnSuspend write FOnSuspend;
    property OnTerminate: TOnEvent read FOnTerminate write FOnTerminate;
  end;

  TScreen = class
   private
    function GetHeight: Integer;
    function GetTwipsPerPixelX: Extended;
    function GetTwipsPerPixelY: Extended;
    function GetWidth: Integer;
   public
    property Height: Integer read GetHeight;
    property Width: Integer read GetWidth;
    property TwipsPerPixelX: Extended read GetTwipsPerPixelX;
    property TwipsPerPixelY: Extended read GetTwipsPerPixelY;
  end;

var
  Screen: TScreen;

  { TTrayIcon }

{const
  CM_BASE  = $B000;
  CM_TICON = CM_BASE + 84;}

{type
  TTrayIcon = class
    FHandle: THandle;
    ni : TNotifyIconData;
    procedure SetNIcon;
    procedure DelNIcon;   
  private
    fHint: String;
    FIcon: hIcon;
    procedure SetHint(const Value: String);
    procedure SetIcon(const Value: hIcon);
  public
    constructor Create;
    destructor Destroy; override;
    //procedure New(Handle:THandle);
    property Hint:String read fHint write SetHint;
    property Icon: hIcon read FIcon write SetIcon;
  end; }

//-misc-
function ExeName:String;

function NewForm(Parent:TForm; Caption: String):TForm;
function NewButton(AParent : TForm; Caption:String):TButton;

//--------------------------- Main ---------------------------//
procedure About;
procedure AboutBox(Handle: THandle;AppName, Desk: String);
procedure MsgBox(S:String);//vb
procedure MsgDlg(Text, Title:String);
procedure MsgOk(S: String); //30.03.04
procedure ShowMessage(S:String);
function InputQuery(AParent: THandle; const ACaption, APrompt: string; var Value: string): Boolean;
function SysErrorMessage(ErrorCode: Integer): string;
//System Flags
function TimeSeparator: Char;
//-------------------------- Windows -------------------------//
function IsFileTypeRegistered(FileType, Prog: String): Boolean; //09.12.03
procedure RegisterFileType(prefix, exepfad: String; IconIndex: Byte); //09.12.03
procedure UnregisterFileType(FileType: String); //09.12.03

function Execute(FileName:String;Param:String='';Dir:String='';ShowMode:Integer=1):Cardinal;
function ShellRun(FileName: String): Cardinal; //09.03.04
function ShellRunEx(FileName, Param: String): Cardinal; //09.03.04
procedure ExecConsoleApp(CommandLine: AnsiString; Output: TStringList; Errors:TStringList);
procedure GetWinVer;
function Win32CSDVersion: String; //18.02.04
function Win32Type:String; //20.10.03
function IsWinNT: Boolean;
function WinDir:String;
function SysDir:String;
function TempDir:String;
function StartDir: String;
function CompName : String;
function UserName : String;
function ScreenWidth:Integer;
function ScreenHeight:Integer;
function GetPriv(PrivilegieName: String):Boolean;

 { Process functions }

const
  TH32CS_SNAPPROCESS  = $00000002;

type
{$EXTERNALSYM tagPROCESSENTRY32}
  tagPROCESSENTRY32 = packed record
    dwSize: DWORD;
    cntUsage: DWORD;
    th32ProcessID: DWORD;       // this process
    th32DefaultHeapID: DWORD;
    th32ModuleID: DWORD;        // associated exe
    cntThreads: DWORD;
    th32ParentProcessID: DWORD; // this process's parent process
    pcPriClassBase: Longint;	// Base priority of process's threads
    dwFlags: DWORD;
    szExeFile: array[0..MAX_PATH - 1] of Char;// Path
  end;
{$EXTERNALSYM PROCESSENTRY32}
  PROCESSENTRY32 = tagPROCESSENTRY32;
{$EXTERNALSYM PPROCESSENTRY32}
  PPROCESSENTRY32 = ^tagPROCESSENTRY32;
{$EXTERNALSYM LPPROCESSENTRY32}
  LPPROCESSENTRY32 = ^tagPROCESSENTRY32;
  TProcessEntry32 = tagPROCESSENTRY32;

type
  TProcess32First = function (hSnapshot: THandle; var lppe: TProcessEntry32): BOOL stdcall;
  TProcess32Next = function (hSnapshot: THandle; var lppe: TProcessEntry32): BOOL stdcall;

function CreateToolhelp32Snapshot(dwFlags, th32ProcessID: DWORD): THandle;  
function Process32First(hSnapshot: THandle; var lppe: TProcessEntry32): BOOL;
function Process32Next(hSnapshot: THandle; var lppe: TProcessEntry32): BOOL;

//--
function KillProcess(ExeFileName: String): Integer;
function GetProcessCount(ProcName: String): Integer;
function GetProcessId(ProcName: String): Integer;
function StartProcessWithLogon(const  strUsername, strDomain, strPassword, strCommandLine: WideString): Boolean; //30.11.03

///////////////////////////////////////////////////////////////////////////////

function GetBiosDate:String;
function ProcessorSpeed: Extended;
//Memory
function AllocMem(Size: Cardinal): Pointer;
function MemTotalPhys : Integer;
function MemAvailPhys : Integer;
function MemTotalPageFile : Integer;
function MemAvailPageFile : Integer;
function MemMemoryLoad : Integer;
//ExitWin
function LogOff : Boolean;
function Reboot : Boolean;
function PowerOff : Boolean;
function ShutDwn : Boolean;
//ClipBoard
function GetClipboardText:String;
function SetClipboardText(const S:String): Boolean;
procedure ClipboardClear;
//Info
function RegisteredOwner : String;
function RegisteredCompany : String;
//---------------------------- Math --------------------------//
function Min(X, Y:Integer): Integer;
function Max(X, Y:Integer): Integer;
//-------------------------- Strings -------------------------//
function Code(x:String; y:Byte):String;
function DeCode(x:String; y:Byte):String;
//Преобразования
function StrLen(const Str: PChar): Cardinal; assembler;
function StrEnd(const Str: PChar): PChar; assembler;
function StrMove(Dest: PChar; const Source: PChar; Count: Cardinal): PChar; 
function StrCopy( Dest, Source: PChar ): PChar; assembler;
function StrLCopy(Dest: PChar; const Source: PChar; MaxLen: Cardinal): PChar;
function StrPCopy(Dest: PChar; const Source: string): PChar;
function StrPLCopy(Dest: PChar; const Source: string; MaxLen: Cardinal): PChar;
function StrCat(Dest: PChar; const Source: PChar): PChar; //22.02.04
function StrScan(const Str: PChar; Chr: Char): PChar;
function StrPos(const Str1, Str2: PChar): PChar;
function StrComp(const Str1, Str2: PChar): Integer;
function StrLComp(const Str1, Str2: PChar; MaxLen: Cardinal): Integer;
function StrLIComp(const Str1, Str2: PChar; MaxLen: Cardinal): Integer;

function AnsiStrScan(Str: PChar; Chr: Char): PChar;
function AnsiStrRScan(Str: PChar; Chr: Char): PChar;

function HexToInt(Value:String):Integer;     {!!! - регистр}
function IntToHex(Value, Digits:Integer):String;
function IntToBin(Value: integer; Digits: integer): string;
function IntToStr(Value:Integer):String;
function IntToStrEx(Value: Integer): string;
function Int64ToStr( Value : Int64 ) : String;
function StrToInt(Value: string): Integer;
function StrToIntEx(const S: string): Integer;
function StrToIntDef(s : string; Default: Integer) : integer;

function ByteToHex(Int: Byte): String;
function StrToHex(const Value: String): String;
function PassToHex(const Value: String): String; //18.10.03

type
{ FloatToText, FloatToTextFmt, TextToFloat, and FloatToDecimal type codes }

  TFloatValue = (fvExtended, fvCurrency);

{ FloatToText format codes }

  TFloatFormat = (ffGeneral, ffExponent, ffFixed, ffNumber, ffCurrency);

function FloatToStr(m: real): String;
function StrToFloat(s: String): real;


function StrUpper(Str: PChar): PChar; assembler; //01.04.04
function StrLower(Str: PChar): PChar; assembler; //01.04.04
function StrPas(const Str: PChar): string;
function StrAlloc(Size: Cardinal): PChar; //27.12.03
function StrNew(const Str: PChar): PChar; //27.12.03
procedure StrDispose(Str: PChar); //03.04.04
//строки
procedure Swap(var x1, x2:String);
function Left(Str:String; Count:Integer):String;        //vb
function Right(Str:String; Count:Integer):String;       //vb
function Mid(Str:String; Start, Count:Integer):String;  //vb
function Len(Str:String):Integer;                       //vb
function Trim(const S: string): string;
function TrimLeft(const S: string): string;
function TrimRight(const S: string): string;
function WordStrCount(Str:String; Sep:Char):Integer;
function WordStrItem(Str:String; Sep:Char;Index:Integer):String;
function UpperCase(const S: string): string;
function LowerCase(const S: string): string;
function AnsiLowerCase(const S: string): string;
function AnsiUpperCase(const S: string): string;
function AnsiCompareStr(const S1, S2: string): Integer; 
function AnsiCompareStrNoCase(const S1, S2: string): Integer;
function AnsiCompareText(const S1, S2: string): Integer;
function AnsiStrPos(Str, SubStr: PChar): PChar;
function AnsiPos(const Substr, S: string): Integer;
function StrEq(const S1, S2 : String): Boolean;

{ Point and rectangle constructors }

function Point(AX, AY: Integer): TPoint;
function SmallPoint(AX, AY: SmallInt): TSmallPoint;
function Rect(ALeft, ATop, ARight, ABottom: Integer): TRect;
function Bounds(ALeft, ATop, AWidth, AHeight: Integer): TRect;

{ MBCS functions }

type
{ MultiByte Character Set (MBCS) byte type }
  TMbcsByteType = (mbSingleByte, mbLeadByte, mbTrailByte);
  TReplaceFlags = set of (rfReplaceAll, rfIgnoreCase);

var
  LeadBytes: set of Char = [];

function ByteType(const S: string; Index: Integer): TMbcsByteType;
function StrByteType(Str: PChar; Index: Cardinal): TMbcsByteType; //15.02.03

function StringReplace(const S, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;
//Format
//procedure FormatVarToStr(var S: string; const V: Variant);
procedure FormatClearStr(var S: string);
procedure FmtStr(var Result: string; const Format: string; const Args: array of const); //09.10.03
function Format(const Format: string; const Args: array of const): string;
function NumToBytes(Value : Double): String;
function FormatFloat(const Format: string; Value: Extended): string;
//Сравнения
function CompareMem(P1, P2: Pointer; Length: Integer): Boolean; assembler;
function CompareText(const S1, S2: string): Integer; assembler;
function SameText(const S1, S2: string): Boolean; assembler;
//пути
function AnsiLastChar(const S: string): PChar;
function LastDelimiter(const Delimiters, S: string): Integer;

function ExtractFilePath(const FileName: shortstring): shortstring;
function ExtractFileDir(const FileName: shortstring): shortstring;
function ExtractFileDrive(const FileName: shortstring): shortstring;
function ExtractFileName(const FileName: string): shortstring;
function ExtractFileExt(const FileName: shortstring): shortstring;
function ExtractFileNoExt(const FileName: string): String; //11.12.04
function ExpandFileName(const FileName: string): string; //27.12.03
function ExtractShortPathName(const FileName: string): string;
//----------------------- Date & Time ------------------------//
type
  PDayTable = ^TDayTable;
  TDayTable = array[1..12] of Word;

  TDateFormat = ( dfShortDate, dfLongDate );
  {* Date formats available to use in formatting date/time to string. }
  TTimeFormatFlag = ( tffNoMinutes, tffNoSeconds, tffNoMarker, tffForce24 );
  {* Additional flags, used for formatting time. }
  TTimeFormatFlags = Set of TTimeFormatFlag;
  {* Set of flags, used for formatting time. }

{ Date and time record }

  TTimeStamp = record
    Time: Integer;      { Number of milliseconds since midnight }
    Date: Integer;      { One plus number of days since 1/1/0001 }
  end;  
  
const
  MonthDays: array [Boolean] of TDayTable =
    ((31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),
     (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31));

  { Seconds per day. }
  SecsPerDay = 24 * 60 * 60;

{ Milliseconds per day. }
  MSecsPerDay = SecsPerDay * 1000;

{ Days between 1/1/0001 and 12/31/1899 }
  DateDelta = 693594;

function DateTimeToSystemTime(const DateTime : TDateTime; var SystemTime : TSystemTime ) : Boolean;
function SystemTimeToDateTime(const SystemTime : TSystemTime; var DateTime : TDateTime ) : Boolean;
function Now:TDateTime;
procedure ReplaceTime(var DateTime: TDateTime; const NewTime: TDateTime); //18.03.04
function IsLeapYear(Year: Word): Boolean; //27.07.03
function DayOfWeek(Date: TDateTime): Integer;
function DateTimeToStr(D: TDateTime): String;
function FormatDateTime(const Format: string; DateTime: TDateTime): string; //27.07.03
function DateTimeToStrShort(D: TDateTime): String;
function TimeToStr(D: TDateTime): String;
function DateToStr(D: TDateTime): String; overload;
function DateToStr( const Fmt: String; D: TDateTime ): String; overload;
procedure Delay(mSec:Integer);  //vb
function EncodeTime(Hour, Min, Sec, MSec: Word): TDateTime;
procedure DecodeTime(Time: TDateTime; var Hour, Min, Sec, MSec: Word);
function EncodeDate(Year, Month, Day: Word): TDateTime; //27.07.03
procedure DecodeDate(Date: TDateTime; var Year, Month, Day: Word);
function StrToDateTime(const S: String): TDateTime; //02.04.04
function DateTimeToFileDate(DateTime: TDateTime): Integer; //02.04.04
//------------------------- Graphics -------------------------//
function IconCount(FileName:String):Integer;
function IconExtract(FileName:String;Index:Integer):hIcon;
function ExtractFileIcon(FileExt: String): hIcon; //13.12.04
function FileIconIndex(const Path: String; OpenIcon: Boolean): Integer; //09.03.03
function LoadSystemIcons: THandle; //13.12.04
procedure Frame3D(hDC, btn_hi, btn_lo, tx, ty, lx, ly, bdrWid:DWORD);
function ColorToRGB(Color: TColor): TColor;
//function ColorToString(Color: TColor): String;
procedure SetSysColor(Element: DWord; Color : TColor); //21.03.04
procedure GradientRect(FromRGB, ToRGB: TColor; Canvas: TCanvas);
function GetColorIndex : Integer;
function GetColorDesc : String;
procedure SetAlphaBlend(Handle, Value: Integer);
procedure CanvasCopyRect(SourceCanvas, DestCanvas: hDC; const Source, Dest: TRect);
//------------------------ Multimedia ------------------------//
procedure DivXConfig; stdcall; external 'divxdec.ax' name 'Config';
procedure OpenCd(const Open:Boolean);
procedure Beep;
//--------------------------- Files --------------------------//
function FileOpen(const FileName: string; Mode: LongWord): Integer;
function FileCreate(const FileName: string): Integer;
function FileRead(Handle: Integer; var Buffer; Count: Integer): Integer;
function FileWrite(Handle: Integer; const Buffer; Count: Integer): Integer;
function FileSeek(Handle, Offset, Origin: Integer): Integer;
procedure FileClose(Handle: Integer);
function FileGetSize(FileName:String):Integer;
function GetFileType(const Path: String): String;
function FileGetAttr(const FileName: string): Integer;
function FileSetAttr(const FileName: string; Attr: Integer): Integer;
function FileSetAttrib(Filename: String; A,H,R,S: Boolean): Boolean;
function FileLock(FileName: String): THandle; //30.12.03
procedure FileUnLock(Handle: THandle); //30.12.03
//----------------------------- Dialogs ----------------------------
//function GetFileNameFromBrowse(hOwner:LongInt;Var sFile:String;sInitDir,sDefExt,sFilter,sTitle :String): Boolean;
function OpenSaveDialog(Handle:THandle;OpenDialog:Boolean; Title, DefExtension, Filter, InitialDir:String; FilterIndex, Options:Integer; var FileName:String):Boolean;
function OpenSaveDialog2(Handle:THandle;OpenDialog:Boolean; Title, DefExtension, Filter, InitialDir:String; var FilterIndex: Integer; Options:Integer; var FileName:String):Boolean;
function OpenDirDialog(Handle: Integer; Title: String; AllowFolderCreate: Boolean; var Path: String): Boolean; //15.11.03 - call CoInitialize before using
function ColorDialog(Handle: THandle; FullOpen, PreventFullOpen: Boolean; var Colors: array of TColor): Boolean;
function ChangeIconDialog(Handle: THandle; FileName: String; var IconIndex: Integer): Boolean;
//function ChangeIconDialog(hOwner :THandle; var FileName: String; var IconIndex: Integer): Boolean;
//------------------------------- Ole ------------------------------
var
  OleInitCount: Integer;

function OleInit: Boolean;
procedure OleUnInit;
//------------------------------------------------------------------
type
{ Generic filename type }

  TFileName = type string;

{ Search record used by FindFirst, FindNext, and FindClose }

  TSearchRec = record
    Time: Integer;
    Size: Integer;
    Attr: Integer;
    Name: TFileName;
    ExcludeAttr: Integer;
    FindHandle: THandle;
    FindData: TWin32FindData;
  end;

{ Typed-file and untyped-file record }

  TFileRec = packed record (* must match the size the compiler generates: 332 bytes *)
    Handle: Integer;
    Mode: Integer;
    RecSize: Cardinal;
    _Private: array[1..28] of Byte;
    UserData: array[1..32] of Byte;
    Name: array[0..259] of Char;
  end;

{ Text file record structure used for Text files }

  PTextBuf = ^TTextBuf;
  TTextBuf = array[0..127] of Char;
  TTextRec = packed record (* must match the size the compiler generates: 460 bytes *)
    Handle: Integer;
    Mode: Integer;
    BufSize: Cardinal;
    BufPos: Cardinal;
    BufEnd: Cardinal;
    BufPtr: PChar;
    OpenFunc: Pointer;
    InOutFunc: Pointer;
    FlushFunc: Pointer;
    CloseFunc: Pointer;
    UserData: array[1..32] of Byte;
    Name: array[0..259] of Char;
    Buffer: TTextBuf;
  end;


function FindMatchingFile(var F: TSearchRec):Integer;
function FindFirst(const Path: string; Attr: Integer;var F: TSearchRec): Integer;
function FindNext(var F: TSearchRec): Integer;
procedure FindClose(var F: TSearchRec);

function DeleteFile(const FileName: string): Boolean;
function RenameFile(const OldName, NewName: string): Boolean;
function GetCurrentDir: string;
function SetCurrentDir(const Dir: string): Boolean;
function CreateDir(const Dir: string): Boolean;
function RemoveDir(const Dir: string): Boolean;
function DeleteDir(Dir: String): Boolean; //23.03.04
function FileExists(const FileName:String):Boolean;
function FileAge(const FileName: string): Integer;
function FileSetDate(Handle: Integer; Age: Integer): Integer; //02.04.04
function DirectoryExists(const Name: string): Boolean;
function ResourceToFile(Instance: THandle; ResName, ResType:pchar; FIleName: string):Boolean;
function DiskFree(Drive: Byte): Int64;
function DiskSize(Drive: Byte): Int64;
function FileDateToDateTime(FileDate: Integer): TDateTime;
//------------------------- Registry -------------------------//
function RegKeyOpenRead( Key: HKey; const SubKey: String ): HKey;
function RegKeyOpenWrite( Key: HKey; const SubKey: String ): HKey;
function RegKeyOpenCreate( Key: HKey; const SubKey: String ): HKey;
function RegKeyGetInt( Key: HKey; const ValueName: String ): DWORD;
function RegKeyGetStr( Key: HKey; const ValueName: String ): String;

function RegKeyGetStr_( Key: HKey; const ValueName: String ): String;
procedure RegKeyGetMulti(Key: HKey; const ValueName: String; var a: array of Char); //18.10.03
function RegKeyGetMultiKey(Key: hKey; ValueName: String): TStringList; //06.04.04

function RegKeyGetStrEx( Key: HKey; const ValueName: String ): String;
function RegKeySetInt( Key: HKey; const ValueName: String; Value: DWORD ): Boolean;
function RegKeySetStr( Key: HKey; const ValueName: String; const Value: String ): Boolean;
function RegKeySetStrEx( Key: HKey; const ValueName: string; const Value: string;expand: boolean): Boolean;
function RegKeyDelete( Key: HKey; const SubKey: String ): Boolean;
function RegKeyDeleteValue( Key: HKey; const SubKey: String ): Boolean;
function RegKeyExists( Key: HKey; const SubKey: String ): Boolean;
function RegKeyValExists( Key: HKey; const ValueName: String ): Boolean;
function RegKeyValueSize( Key: HKey; const ValueName: String ): Integer;
function RegKeyGetBin( Key: HKey; const ValueName: String; var Buffer; Count: Integer ): Integer;
function RegKeySetBin( Key: HKey; const ValueName: String; const Buffer; Count: Integer ): Boolean;
function RegKeyGetDateTime(Key: HKey; const ValueName: String): TDateTime;
function RegKeySetDateTime(Key: HKey; const ValueName: String; DateTime: TDateTime): Boolean;
function RegKeyGetValueTyp (const Key:HKEY; const ValueName: String) : DWORD;

function RegKeyGetKeyNames(const Key: HKEY; var List: TStringList) : Boolean; //23.03.04
function RegKeyGetKeyNamesStr(const Key: HKEY; var List: String) : Boolean;
function RegKeyGetKeyNamesSL(const Key: HKEY; var List: TSList) : Boolean;

function RegKeyGetValueNamesStr(const Key: HKEY; var List: String): Boolean;
function RegKeyGetValueNames(const Key: HKEY; var List: TStringList): Boolean;
function RegKeyGetValueNamesSL(const Key: HKEY; var List: TSList): Boolean;

procedure RegKeyConnect(MachineName: String; RootKey: HKEY; var RemoteKey: HKEY);
procedure RegKeyDisconnect(RemoteKey: HKEY);
procedure RegKeyClose(Key: HKey);
procedure RegKeyRenVal(Key:hKey; OldName, NewName: string);

procedure SaveSetting(Appname, Section, Key, Value: String);  //vb
function GetSetting(Appname, Section, Key, DefValue: String): String; //vb
procedure DeleteSetting(Appname, Section: String);  //vb

{ IniFlies }

type
  TIniFile = class
  private
    FFileName: string;
  public
    constructor Create(const FileName: String);
    function SectionExists(const Section: String): Boolean;
    function ReadBool(const Section, Ident: string; Default: Boolean): Boolean;
    function ReadInteger(const Section, Ident: String; Default: Longint): Longint;
    function ReadString(const Section, Ident, Default: String): String;
    function ReadFloat(const Section, Ident: String; Default: Single): Single;
    procedure ReadSection(const Section: String; Strings: TStringList);
    procedure ReadSections(Strings: TStringList);
    procedure ReadSectionValues(const Section: String; Strings: TStringList);
    procedure WriteBool(const Section, Ident: string; Value: Boolean);
    procedure WriteInteger(const Section, Ident: String; Value: Longint);
    procedure WriteString(const Section, Ident, Value: String);
    procedure WriteFloat(const Section, Ident: String; Value: Single);
    procedure EraseSection(const Section: String);
    procedure DeleteKey(const Section, Ident: String);
    procedure UpdateFile;    
  end;

procedure IniUpdateFile(FileName: String);
procedure IniEraseSection(FileName, Section: String);
procedure IniDeleteKey(FileName, Section, KeyName: String);
function IniSectionExists(FileName, Section: String): Boolean;
function IniValueExists(FileName, Section, Ident: string): Boolean;
procedure IniSetStr(FileName, Section, Key, Value:String);
function IniGetStr(FileName, Section, Key, DefaultValue:String):String;
procedure IniSetInt(FileName, Section, Key:String; Value:Integer);
function IniGetInt(FileName, Section, Key:String; DefaultValue:Integer):Integer;
procedure IniGetSection(FileName, Section: String; var Strings: TStringList);
procedure IniGetSectionNames(FileName:String; var Sections: TStringList);
procedure IniGetSectionNamesSL(FileName:String; var Sections: TSList);
procedure IniGetSectionValues(FileName, Section: String; var Values: TStringList);
procedure IniGetSectionValuesSL(FileName, Section: String; var Values: TSList);

{ Импортируемые функции }

{ From CommCtrl.pas }

const
  ILD_NORMAL              = $0000;
  ILD_TRANSPARENT         = $0001;
  ILD_MASK                = $0010;
  ILD_IMAGE               = $0020;
  ILD_BLEND25             = $0002;
  ILD_BLEND50             = $0004;
  ILD_OVERLAYMASK         = $0F00;

function ImageList_Create(CX, CY: Integer; Flags: UINT; Initial, Grow: Integer): HIMAGELIST; stdcall; external 'comctl32.dll' name 'ImageList_Create';
function ImageList_Destroy(ImageList: HIMAGELIST): Bool; stdcall; external 'comctl32.dll' name 'ImageList_Destroy';
function ImageList_Draw(ImageList: HImageList; Index: Integer; Dest: HDC; X, Y: Integer; Style: UINT): Bool; stdcall; external 'comctl32.dll' name 'ImageList_Draw';
function ImageList_DrawEx(ImageList: HImageList; Index: Integer; Dest: HDC; X, Y, DX, DY: Integer; Bk, Fg: TColorRef; Style: Cardinal): Bool; stdcall; external 'comctl32.dll' name 'ImageList_DrawEx';
function ImageList_GetImageCount(ImageList: HIMAGELIST): Integer; stdcall; external 'comctl32.dll' name 'ImageList_GetImageCount';
function ImageList_SetImageCount(himl: HIMAGELIST; uNewCount: UINT): Integer; stdcall; external 'comctl32.dll' name 'ImageList_SetImageCount';
function ImageList_Add(ImageList: HIMAGELIST; Image, Mask: HBitmap): Integer; stdcall; external 'comctl32.dll' name 'ImageList_Add';
function ImageList_AddMasked(ImageList: HImageList; Image: HBitmap; Mask: TColorRef): Integer; stdcall; external 'comctl32.dll' name 'ImageList_AddMasked';
function ImageList_ReplaceIcon(ImageList: HIMAGELIST; Index: Integer; Icon: HIcon): Integer; stdcall; external 'comctl32.dll' name 'ImageList_ReplaceIcon';
function ImageList_SetBkColor(ImageList: HIMAGELIST; ClrBk: TColorRef): TColorRef; stdcall; external 'comctl32.dll' name 'ImageList_SetBkColor';
function ImageList_GetBkColor(ImageList: HIMAGELIST): TColorRef; stdcall; external 'comctl32.dll' name 'ImageList_GetBkColor';
function ImageList_SetOverlayImage(ImageList: HIMAGELIST; Image: Integer; Overlay: Integer): Bool; stdcall; external 'comctl32.dll' name 'ImageList_SetOverlayImage';

{ From ShellApi.pas }

const
  SHGFI_LARGEICON         = $000000000;     { get large icon }
  SHGFI_SMALLICON         = $000000001;     { get small icon }
  SHGFI_OPENICON          = $000000002;     { get open icon }
  SHGFI_USEFILEATTRIBUTES = $000000010;     { use passed dwFileAttribute }  
  SHGFI_ICON              = $000000100;     { get icon }
  SHGFI_TYPENAME          = $000000400;     { get type name }  
  SHGFI_SYSICONINDEX      = $000004000;     { get system icon index }


type
  _SHFILEINFOA = record
    hIcon: HICON;                      { out: icon }
    iIcon: Integer;                    { out: icon index }
    dwAttributes: DWORD;               { out: SFGAO_ flags }
    szDisplayName: array [0..MAX_PATH-1] of  AnsiChar; { out: display name (or path) }
    szTypeName: array [0..79] of AnsiChar;             { out: type name }
  end;
  TSHFileInfoA = _SHFILEINFOA;
  TSHFileInfo = TSHFileInfoA;


function ShellExecute(hWnd:HWND;Operation,FileName,Parameters,Directory:PChar; ShowCmd: Integer):HINST;stdcall;external 'shell32.dll' name 'ShellExecuteA';
function ShellAbout(Wnd: HWND; szApp, szOtherStuff: PChar; Icon: HICON): Integer; stdcall; external 'shell32.dll' name 'ShellAboutA';
function ExtractIcon(hInst: HINST; lpszExeFileName: PChar; nIconIndex: UINT): HICON; stdcall;external 'shell32.dll' name 'ExtractIconA';
function ExtractIconExA(lpszFile: PAnsiChar; nIconIndex: Integer; var phiconLarge, phiconSmall: HICON; nIcons: UINT): UINT; stdcall; external 'shell32.dll' name 'ExtractIconExA';
//function Shell_NotifyIcon(dwMessage: DWORD; lpData: PNotifyIconData): BOOL; stdcall;external 'shell32.dll' name 'Shell_NotifyIconA';

function SHChangeIconDialog(hOwner:LongInt;sFilename: LPWSTR;nBuf:LongInt;var nIconIndex:LongInt):LongInt; stdcall; external 'Shell32.dll' index 62;
function SHGetFileInfo(pszPath: PAnsiChar; dwFileAttributes: DWORD; var psfi: TSHFileInfo; cbFileInfo, uFlags: UINT): DWORD; stdcall; external 'Shell32.dll' name 'SHGetFileInfoA';
function SHGetFileNameFromBrowse(hOwner:LongInt;sFile:LPWSTR; nMaxFile:LongInt;sInitDir:LPWSTR;sDefExt,sFilter,sTitle :LPWSTR): Boolean;stdCall;External 'Shell32.dll' index 63;
function SHGetSpecialFolderPath(hwndOwner: HWND; lpszPath: PChar; nFolder: Integer; fCreate: BOOL): BOOL; stdcall; external 'shell32.dll' name 'SHGetSpecialFolderPathA'

{ From ActiveX.pas }

function CoTaskMemAlloc(cb: Longint): Pointer; stdcall; external 'ole32.dll' name 'CoTaskMemAlloc';
procedure CoTaskMemFree(pv: Pointer); stdcall; external 'ole32.dll' name 'CoTaskMemFree';

function OleInitialize(pwReserved: Pointer): HResult; stdcall; external 'ole32.dll' name 'OleInitialize';
procedure OleUninitialize; stdcall; external 'ole32.dll' name 'OleUninitialize';

{ From CommDlg.pas }

const
  DN_DEFAULTPRN = $0001; {default printer }
  HELPMSGSTRING = 'commdlg_help';

//******************************************************************************
//   PrintDlg options
//******************************************************************************

  PD_ALLPAGES = $00000000;
  PD_SELECTION = $00000001;
  PD_PAGENUMS = $00000002;
  PD_NOSELECTION = $00000004;
  PD_NOPAGENUMS = $00000008;
  PD_COLLATE = $00000010;
  PD_PRINTTOFILE = $00000020;
  PD_PRINTSETUP = $00000040;
  PD_NOWARNING = $00000080;
  PD_RETURNDC = $00000100;
  PD_RETURNIC = $00000200;
  PD_RETURNDEFAULT = $00000400;
  PD_SHOWHELP = $00000800;
  PD_ENABLEPRINTHOOK = $00001000;
  PD_ENABLESETUPHOOK = $00002000;
  PD_ENABLEPRINTTEMPLATE = $00004000;
  PD_ENABLESETUPTEMPLATE = $00008000;
  PD_ENABLEPRINTTEMPLATEHANDLE = $00010000;
  PD_ENABLESETUPTEMPLATEHANDLE = $00020000;
  PD_USEDEVMODECOPIES = $00040000;
  PD_USEDEVMODECOPIESANDCOLLATE = $00040000;
  PD_DISABLEPRINTTOFILE = $00080000;
  PD_HIDEPRINTTOFILE = $00100000;
  PD_NONETWORKBUTTON = $00200000;

//******************************************************************************
//  PageSetupDlg options
//******************************************************************************

   PSD_DEFAULTMINMARGINS             = $00000000;
   PSD_INWININIINTLMEASURE           = $00000000;
   PSD_MINMARGINS                    = $00000001;
   PSD_MARGINS                       = $00000002;
   PSD_INTHOUSANDTHSOFINCHES         = $00000004;
   PSD_INHUNDREDTHSOFMILLIMETERS     = $00000008;
   PSD_DISABLEMARGINS                = $00000010;
   PSD_DISABLEPRINTER                = $00000020;
   PSD_NOWARNING                     = $00000080;
   PSD_DISABLEORIENTATION            = $00000100;
   PSD_RETURNDEFAULT                 = $00000400;
   PSD_DISABLEPAPER                  = $00000200;
   PSD_SHOWHELP                      = $00000800;
   PSD_ENABLEPAGESETUPHOOK           = $00002000;
   PSD_ENABLEPAGESETUPTEMPLATE       = $00008000;
   PSD_ENABLEPAGESETUPTEMPLATEHANDLE = $00020000;
   PSD_ENABLEPAGEPAINTHOOK           = $00040000;
   PSD_DISABLEPAGEPAINTING           = $00080000;
   PSD_NONETWORKBUTTON               = $00200000;  

//******************************************************************************
//  Error constants
//******************************************************************************

  CDERR_DIALOGFAILURE    = $FFFF;
  CDERR_GENERALCODES     = $0000;
  CDERR_STRUCTSIZE       = $0001;
  CDERR_INITIALIZATION   = $0002;
  CDERR_NOTEMPLATE       = $0003;
  CDERR_NOHINSTANCE      = $0004;
  CDERR_LOADSTRFAILURE   = $0005;
  CDERR_FINDRESFAILURE   = $0006;
  CDERR_LOADRESFAILURE   = $0007;
  CDERR_LOCKRESFAILURE   = $0008;
  CDERR_MEMALLOCFAILURE  = $0009;
  CDERR_MEMLOCKFAILURE   = $000A;
  CDERR_NOHOOK           = $000B;
  CDERR_REGISTERMSGFAIL  = $000C;
  PDERR_PRINTERCODES     = $1000;
  PDERR_SETUPFAILURE     = $1001;
  PDERR_PARSEFAILURE     = $1002;
  PDERR_RETDEFFAILURE    = $1003;
  PDERR_LOADDRVFAILURE   = $1004;
  PDERR_GETDEVMODEFAIL   = $1005;
  PDERR_INITFAILURE      = $1006;
  PDERR_NODEVICES        = $1007;
  PDERR_NODEFAULTPRN     = $1008;
  PDERR_DNDMMISMATCH     = $1009;
  PDERR_CREATEICFAILURE  = $100A;
  PDERR_PRINTERNOTFOUND  = $100B;
  PDERR_DEFAULTDIFFERENT = $100C;

function GetOpenFileName(var OpenFile: TOpenFilename): Bool; stdcall; external 'comdlg32.dll'  name 'GetOpenFileNameA';
function GetSaveFileName(var OpenFile: TOpenFilename): Bool; stdcall; external 'comdlg32.dll'  name 'GetSaveFileNameA';
function PrintDlg(var PrintDlg: tagPD): BOOL; stdcall; external 'comdlg32.dll' name 'PrintDlgA';
function PageSetupDlg(var PgSetupDialog: tagPSD): BOOL; stdcall; external 'comdlg32.dll'  name 'PageSetupDlgA';
function CommDlgExtendedError():DWORD;stdcall; external 'comdlg32.dll'  name 'CommDlgExtendedError';

{ From MMSystem.pas }

const
  MAXPNAMELEN      =  32;    { max product name length (including nil) }
  WAVECAPS_VOLUME  = $0004;  { supports volume control }

type
  MMVERSION = UINT;          { major (high byte), minor (low byte) }
  MMRESULT = UINT;           { error return code, 0 means no error }

  PWaveOutCapsA = ^TWaveOutCapsA;
  PWaveOutCaps = PWaveOutCapsA;

  tagWAVEOUTCAPSA = record
    wMid: Word;                                    { manufacturer ID }
    wPid: Word;                                    { product ID }
    vDriverVersion: MMVERSION;                     { version of the driver }
    szPname: array[0..MAXPNAMELEN-1] of AnsiChar;  { product name (NULL terminated string) }
    dwFormats: DWORD;                              { formats supported }
    wChannels: Word;                               { number of sources supported }
    dwSupport: DWORD;                              { functionality supported by driver }
  end;

  tagWAVEOUTCAPSW = record
    wMid: Word;                                    { manufacturer ID }
    wPid: Word;                                    { product ID }
    vDriverVersion: MMVERSION;                     { version of the driver }
    szPname: array[0..MAXPNAMELEN-1] of WideChar;  { product name (NULL terminated string) }
    dwFormats: DWORD;                              { formats supported }
    wChannels: Word;                               { number of sources supported }
    dwSupport: DWORD;                              { functionality supported by driver }
  end;

  tagWAVEOUTCAPS = tagWAVEOUTCAPSA;
  TWaveOutCapsA = tagWAVEOUTCAPSA;
  TWaveOutCaps = TWaveOutCapsA;

  HWAVEOUT = Integer;

function mciSendString(lpstrCommand,lpstrReturnString:PChar;uReturnLength:UINT;hWndCallback:HWND):DWORD;stdcall;external 'winmm.dll' name 'mciSendStringA';
function waveOutGetNumDevs: UINT; stdcall; external 'winmm.dll' name 'waveOutGetNumDevs';
function waveOutGetDevCaps(uDeviceID: UINT; lpCaps: PWaveOutCaps; uSize: UINT): MMRESULT; stdcall;external 'winmm.dll' name 'waveOutGetDevCapsA';
function waveOutSetVolume(hwo: HWAVEOUT; dwVolume: DWORD): MMRESULT; stdcall;external 'winmm.dll' name 'waveOutSetVolume';

{ Thread synchronization }

{ TMultiReadExclusiveWriteSynchronizer minimizes thread serialization to gain
  read access to a resource shared among threads while still providing complete
  exclusivity to callers needing write access to the shared resource.
  (multithread shared reads, single thread exclusive write)
  Reading is allowed while owning a write lock.
  Read locks can be promoted to write locks.}

type
  TActiveThreadRecord = record
    ThreadID: Integer;
    RecursionCount: Integer;
  end;
  TActiveThreadArray = array of TActiveThreadRecord;

  TMultiReadExclusiveWriteSynchronizer = class
  private
    FLock: TRTLCriticalSection;
    FReadExit: THandle;
    FCount: Integer;
    FSaveReadCount: Integer;
    FActiveThreads: TActiveThreadArray;
    FWriteRequestorID: Integer;
    FReallocFlag: Integer;
    FWriting: Boolean;
    function WriterIsOnlyReader: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeginRead;
    procedure EndRead;
    procedure BeginWrite;
    procedure EndWrite;
  end;

///////////////////////////////////////////////////////////////////////////////

{ From commctrl.h }

type
  {$EXTERNALSYM tagINITCOMMONCONTROLSEX}
  tagINITCOMMONCONTROLSEX = packed record
    dwSize: DWORD;             // size of this structure
    dwICC: DWORD;              // flags indicating which classes to be initialized
  end;
  PInitCommonControlsEx = ^TInitCommonControlsEx;
  TInitCommonControlsEx = tagINITCOMMONCONTROLSEX;
  
const
  {$EXTERNALSYM ICC_LISTVIEW_CLASSES}
  ICC_LISTVIEW_CLASSES   = $00000001; // listview, header
  {$EXTERNALSYM ICC_TREEVIEW_CLASSES}
  ICC_TREEVIEW_CLASSES   = $00000002; // treeview, tooltips
  {$EXTERNALSYM ICC_BAR_CLASSES}
  ICC_BAR_CLASSES        = $00000004; // toolbar, statusbar, trackbar, tooltips
  {$EXTERNALSYM ICC_TAB_CLASSES}
  ICC_TAB_CLASSES        = $00000008; // tab, tooltips
  {$EXTERNALSYM ICC_UPDOWN_CLASS}
  ICC_UPDOWN_CLASS       = $00000010; // updown
  {$EXTERNALSYM ICC_PROGRESS_CLASS}
  ICC_PROGRESS_CLASS     = $00000020; // progress
  {$EXTERNALSYM ICC_HOTKEY_CLASS}
  ICC_HOTKEY_CLASS       = $00000040; // hotkey
  {$EXTERNALSYM ICC_ANIMATE_CLASS}
  ICC_ANIMATE_CLASS      = $00000080; // animate
  {$EXTERNALSYM ICC_WIN95_CLASSES}
  ICC_WIN95_CLASSES      = $000000FF;
  {$EXTERNALSYM ICC_DATE_CLASSES}
  ICC_DATE_CLASSES       = $00000100; // month picker, date picker, time picker, updown
  {$EXTERNALSYM ICC_USEREX_CLASSES}
  ICC_USEREX_CLASSES     = $00000200; // comboex
  {$EXTERNALSYM ICC_COOL_CLASSES}
  ICC_COOL_CLASSES       = $00000400; // rebar (coolbar) control
  {$EXTERNALSYM ICC_INTERNET_CLASSES}
  ICC_INTERNET_CLASSES   = $00000800;
  {$EXTERNALSYM ICC_PAGESCROLLER_CLASS}
  ICC_PAGESCROLLER_CLASS = $00001000; // page scroller
  {$EXTERNALSYM ICC_NATIVEFNTCTL_CLASS}
  ICC_NATIVEFNTCTL_CLASS = $00002000; // native font control

procedure InitCommonControls; external 'comctl32.dll' name 'InitCommonControls';
function InitCommonControlsEx(var ICC: TInitCommonControlsEx): Bool; { Re-defined below }

implementation

const
  App_Id = 's_';

//ShellApi


{ ====== TOOLTIPS CONTROL ========================== }

const
  {$EXTERNALSYM TOOLTIPS_CLASS}
  TOOLTIPS_CLASS = 'tooltips_class32';

type
  PToolInfoA = ^TToolInfoA;
  PToolInfoW = ^TToolInfoW;
  PToolInfo = PToolInfoA;
  {$EXTERNALSYM tagTOOLINFOA}
  tagTOOLINFOA = packed record
    cbSize: UINT;
    uFlags: UINT;
    hwnd: HWND;
    uId: UINT;
    Rect: TRect;
    hInst: THandle;
    lpszText: PAnsiChar;
    lParam: LPARAM;
  end;
  {$EXTERNALSYM tagTOOLINFOW}
  tagTOOLINFOW = packed record
    cbSize: UINT;
    uFlags: UINT;
    hwnd: HWND;
    uId: UINT;
    Rect: TRect;
    hInst: THandle;
    lpszText: PWideChar;
    lParam: LPARAM;
  end;
  {$EXTERNALSYM tagTOOLINFO}
  tagTOOLINFO = tagTOOLINFOA;
  TToolInfoA = tagTOOLINFOA;
  TToolInfoW = tagTOOLINFOW;
  TToolInfo = TToolInfoA;
  {$EXTERNALSYM TOOLINFOA}
  TOOLINFOA = tagTOOLINFOA;
  {$EXTERNALSYM TOOLINFOW}
  TOOLINFOW = tagTOOLINFOW;
  {$EXTERNALSYM TOOLINFO}
  TOOLINFO = TOOLINFOA;

const
  {$EXTERNALSYM TTS_ALWAYSTIP}
  TTS_ALWAYSTIP           = $01;
  {$EXTERNALSYM TTS_NOPREFIX}
  TTS_NOPREFIX            = $02;

  {$EXTERNALSYM TTF_IDISHWND}
  TTF_IDISHWND            = $0001;

  // Use this to center around trackpoint in trackmode
  // -OR- to center around tool in normal mode.
  // Use TTF_ABSOLUTE to place the tip exactly at the track coords when
  // in tracking mode.  TTF_ABSOLUTE can be used in conjunction with TTF_CENTERTIP
  // to center the tip absolutely about the track point.

  {$EXTERNALSYM TTF_CENTERTIP}
  TTF_CENTERTIP           = $0002;
  {$EXTERNALSYM TTF_RTLREADING}
  TTF_RTLREADING          = $0004;
  {$EXTERNALSYM TTF_SUBCLASS}
  TTF_SUBCLASS            = $0010;
  {$EXTERNALSYM TTF_TRACK}
  TTF_TRACK               = $0020;
  {$EXTERNALSYM TTF_ABSOLUTE}
  TTF_ABSOLUTE            = $0080;
  {$EXTERNALSYM TTF_TRANSPARENT}
  TTF_TRANSPARENT         = $0100;
  {$EXTERNALSYM TTF_DI_SETITEM}
  TTF_DI_SETITEM          = $8000;       // valid only on the TTN_NEEDTEXT callback

  {$EXTERNALSYM TTDT_AUTOMATIC}
  TTDT_AUTOMATIC          = 0;
  {$EXTERNALSYM TTDT_RESHOW}
  TTDT_RESHOW             = 1;
  {$EXTERNALSYM TTDT_AUTOPOP}
  TTDT_AUTOPOP            = 2;
  {$EXTERNALSYM TTDT_INITIAL}
  TTDT_INITIAL            = 3;

  {$EXTERNALSYM TTM_ACTIVATE}
  TTM_ACTIVATE            = WM_USER + 1;
  {$EXTERNALSYM TTM_SETDELAYTIME}
  TTM_SETDELAYTIME        = WM_USER + 3;

  {$EXTERNALSYM TTM_ADDTOOLA}
  TTM_ADDTOOLA             = WM_USER + 4;
  {$EXTERNALSYM TTM_DELTOOLA}
  TTM_DELTOOLA             = WM_USER + 5;
  {$EXTERNALSYM TTM_NEWTOOLRECTA}
  TTM_NEWTOOLRECTA         = WM_USER + 6;
  {$EXTERNALSYM TTM_GETTOOLINFOA}
  TTM_GETTOOLINFOA         = WM_USER + 8;
  {$EXTERNALSYM TTM_SETTOOLINFOA}
  TTM_SETTOOLINFOA         = WM_USER + 9;
  {$EXTERNALSYM TTM_HITTESTA}
  TTM_HITTESTA             = WM_USER + 10;
  {$EXTERNALSYM TTM_GETTEXTA}
  TTM_GETTEXTA             = WM_USER + 11;
  {$EXTERNALSYM TTM_UPDATETIPTEXTA}
  TTM_UPDATETIPTEXTA       = WM_USER + 12;
  {$EXTERNALSYM TTM_ENUMTOOLSA}
  TTM_ENUMTOOLSA           = WM_USER + 14;
  {$EXTERNALSYM TTM_GETCURRENTTOOLA}
  TTM_GETCURRENTTOOLA      = WM_USER + 15;

  {$EXTERNALSYM TTM_ADDTOOLW}
  TTM_ADDTOOLW             = WM_USER + 50;
  {$EXTERNALSYM TTM_DELTOOLW}
  TTM_DELTOOLW             = WM_USER + 51;
  {$EXTERNALSYM TTM_NEWTOOLRECTW}
  TTM_NEWTOOLRECTW         = WM_USER + 52;
  {$EXTERNALSYM TTM_GETTOOLINFOW}
  TTM_GETTOOLINFOW         = WM_USER + 53;
  {$EXTERNALSYM TTM_SETTOOLINFOW}
  TTM_SETTOOLINFOW         = WM_USER + 54;
  {$EXTERNALSYM TTM_HITTESTW}
  TTM_HITTESTW             = WM_USER + 55;
  {$EXTERNALSYM TTM_GETTEXTW}
  TTM_GETTEXTW             = WM_USER + 56;
  {$EXTERNALSYM TTM_UPDATETIPTEXTW}
  TTM_UPDATETIPTEXTW       = WM_USER + 57;
  {$EXTERNALSYM TTM_ENUMTOOLSW}
  TTM_ENUMTOOLSW           = WM_USER + 58;
  {$EXTERNALSYM TTM_GETCURRENTTOOLW}
  TTM_GETCURRENTTOOLW      = WM_USER + 59;
  {$EXTERNALSYM TTM_WINDOWFROMPOINT}
  TTM_WINDOWFROMPOINT      = WM_USER + 16;
  {$EXTERNALSYM TTM_TRACKACTIVATE}
  TTM_TRACKACTIVATE        = WM_USER + 17;  // wParam = TRUE/FALSE start end  lparam = LPTOOLINFO
  {$EXTERNALSYM TTM_TRACKPOSITION}
  TTM_TRACKPOSITION        = WM_USER + 18;  // lParam = dwPos
  {$EXTERNALSYM TTM_SETTIPBKCOLOR}
  TTM_SETTIPBKCOLOR        = WM_USER + 19;
  {$EXTERNALSYM TTM_SETTIPTEXTCOLOR}
  TTM_SETTIPTEXTCOLOR      = WM_USER + 20;
  {$EXTERNALSYM TTM_GETDELAYTIME}
  TTM_GETDELAYTIME         = WM_USER + 21;
  {$EXTERNALSYM TTM_GETTIPBKCOLOR}
  TTM_GETTIPBKCOLOR        = WM_USER + 22;
  {$EXTERNALSYM TTM_GETTIPTEXTCOLOR}
  TTM_GETTIPTEXTCOLOR      = WM_USER + 23;
  {$EXTERNALSYM TTM_SETMAXTIPWIDTH}
  TTM_SETMAXTIPWIDTH       = WM_USER + 24;
  {$EXTERNALSYM TTM_GETMAXTIPWIDTH}
  TTM_GETMAXTIPWIDTH       = WM_USER + 25;
  {$EXTERNALSYM TTM_SETMARGIN}
  TTM_SETMARGIN            = WM_USER + 26;  // lParam = lprc
  {$EXTERNALSYM TTM_GETMARGIN}
  TTM_GETMARGIN            = WM_USER + 27;  // lParam = lprc
  {$EXTERNALSYM TTM_POP}
  TTM_POP                  = WM_USER + 28;
  {$EXTERNALSYM TTM_UPDATE}
  TTM_UPDATE               = WM_USER + 29;

 {$EXTERNALSYM TTM_ADDTOOL}
  TTM_ADDTOOL             = TTM_ADDTOOLA;
  {$EXTERNALSYM TTM_DELTOOL}
  TTM_DELTOOL             = TTM_DELTOOLA;
  {$EXTERNALSYM TTM_NEWTOOLRECT}
  TTM_NEWTOOLRECT         = TTM_NEWTOOLRECTA;
  {$EXTERNALSYM TTM_GETTOOLINFO}
  TTM_GETTOOLINFO         = TTM_GETTOOLINFOA;
  {$EXTERNALSYM TTM_SETTOOLINFO}
  TTM_SETTOOLINFO         = TTM_SETTOOLINFOA;
  {$EXTERNALSYM TTM_HITTEST}
  TTM_HITTEST             = TTM_HITTESTA;
  {$EXTERNALSYM TTM_GETTEXT}
  TTM_GETTEXT             = TTM_GETTEXTA;
  {$EXTERNALSYM TTM_UPDATETIPTEXT}
  TTM_UPDATETIPTEXT       = TTM_UPDATETIPTEXTA;
  {$EXTERNALSYM TTM_ENUMTOOLS}
  TTM_ENUMTOOLS           = TTM_ENUMTOOLSA;
  {$EXTERNALSYM TTM_GETCURRENTTOOL}
  TTM_GETCURRENTTOOL      = TTM_GETCURRENTTOOLA;


  {$EXTERNALSYM TTM_RELAYEVENT}
  TTM_RELAYEVENT          = WM_USER + 7;
  {$EXTERNALSYM TTM_GETTOOLCOUNT}
  TTM_GETTOOLCOUNT        = WM_USER +13;

  { TabControl }

type
  PTCItemA = ^TTCItemA;
  PTCItemW = ^TTCItemW;
  PTCItem = PTCItemA;
  {$EXTERNALSYM tagTCITEMA}
  tagTCITEMA = packed record
    mask: UINT;
    dwState: UINT;
    dwStateMask: UINT;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iImage: Integer;
    lParam: LPARAM;
  end;
  {$EXTERNALSYM tagTCITEMW}
  tagTCITEMW = packed record
    mask: UINT;
    dwState: UINT;
    dwStateMask: UINT;
    pszText: PWideChar;
    cchTextMax: Integer;
    iImage: Integer;
    lParam: LPARAM;
  end;
  {$EXTERNALSYM tagTCITEM}
  tagTCITEM = tagTCITEMA;
  {$EXTERNALSYM _TC_ITEMA}
  _TC_ITEMA = tagTCITEMA;
  {$EXTERNALSYM _TC_ITEMW}
  _TC_ITEMW = tagTCITEMW;
  {$EXTERNALSYM _TC_ITEM}
  _TC_ITEM = _TC_ITEMA;
  TTCItemA = tagTCITEMA;
  TTCItemW = tagTCITEMW;
  TTCItem = TTCItemA;
  {$EXTERNALSYM TC_ITEMA}
  TC_ITEMA = tagTCITEMA;
  {$EXTERNALSYM TC_ITEMW}
  TC_ITEMW = tagTCITEMW;
  {$EXTERNALSYM TC_ITEM}
  TC_ITEM = TC_ITEMA;

var
  ComCtl32DLL: THandle;
  _InitCommonControlsEx: function(var ICC: TInitCommonControlsEx): Bool stdcall;

procedure InitComCtl;
begin
  if ComCtl32DLL = 0 then
  begin
    ComCtl32DLL := GetModuleHandle('comctl32.dll');
    if ComCtl32DLL <> 0 then
      @_InitCommonControlsEx := GetProcAddress(ComCtl32DLL, 'InitCommonControlsEx');
  end;
end;

function InitCommonControlsEx(var ICC: TInitCommonControlsEx): Bool;
begin
  if ComCtl32DLL = 0 then InitComCtl;
  Result := Assigned(_InitCommonControlsEx) and _InitCommonControlsEx(ICC);
end;

function InitCommonControl(CC: Integer): Boolean;
var
  ICC: TInitCommonControlsEx;
begin
  ICC.dwSize := SizeOf(TInitCommonControlsEx);
  ICC.dwICC := CC;
  Result := InitCommonControlsEx(ICC);
  if not Result then InitCommonControls;
end;

//Envents
function NewEvent(Func: Pointer): TEvent;
begin
  Result.Code := Func;
end;

procedure Close;
begin
  if MsgDefHandle <> 0 then
    PostMessage(MsgDefHandle, WM_CLOSE, 0, 0)
  else
    ExitProcess(0);
end;

procedure Run(Form:TForm);
begin
  Form.Run ;
end;

{ ObjectInstance }

var
  InstBlockList: PInstanceBlock;
  InstFreeList: PObjectInstance;

  UtilWindowClass: TWndClass = (
    style: 0;
    lpfnWndProc: @DefWindowProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: 'TPUtilWindow');

{ Free an object instance }

procedure FreeObjectInstance(ObjectInstance: Pointer);
begin
  if ObjectInstance <> nil then
  begin
    PObjectInstance(ObjectInstance)^.Next := InstFreeList;
    InstFreeList := ObjectInstance;
  end;
end;    

function StdWndProc(Window: HWND; Message, WParam: Longint; LParam: Longint): Longint; stdcall; assembler;
asm
        XOR     EAX,EAX
        PUSH    EAX
        PUSH    LParam
        PUSH    WParam
        PUSH    Message
        MOV     EDX,ESP
        MOV     EAX,[ECX].Longint[4]
        CALL    [ECX].Pointer
        ADD     ESP,12
        POP     EAX
end;    

function CalcJmpOffset(Src, Dest: Pointer): Longint;
begin
  Result := Longint(Dest) - (Longint(Src) + 5);
end;    

function MakeObjectInstance(Method: TWndMethod): Pointer;
const
  BlockCode: array[1..2] of Byte = (
    $59,       { POP ECX }
    $E9);      { JMP StdWndProc }
  PageSize = 4096;
var
  Block: PInstanceBlock;
  Instance: PObjectInstance;
begin
  if InstFreeList = nil then
  begin
    Block := VirtualAlloc(nil, PageSize, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    Block^.Next := InstBlockList;
    Move(BlockCode, Block^.Code, SizeOf(BlockCode));
    Block^.WndProcPtr := Pointer(CalcJmpOffset(@Block^.Code[2], @StdWndProc));
    Instance := @Block^.Instances;
    repeat
      Instance^.Code := $E8;  { CALL NEAR PTR Offset }
      Instance^.Offset := CalcJmpOffset(Instance, @Block^.Code);
      Instance^.Next := InstFreeList;
      InstFreeList := Instance;
      Inc(Longint(Instance), SizeOf(TObjectInstance));
    until Longint(Instance) - Longint(Block) >= SizeOf(TInstanceBlock);
    InstBlockList := Block;
  end;
  Result := InstFreeList;
  Instance := InstFreeList;
  InstFreeList := Instance^.Next;
  Instance^.Method := Method;
end;    
    
function AllocateHWnd(Method: TWndMethod): HWND;
var
  TempClass: TWndClass;
  ClassRegistered: Boolean;
begin
  UtilWindowClass.hInstance := HInstance;
  ClassRegistered := GetClassInfo(HInstance, UtilWindowClass.lpszClassName, TempClass);
  if not ClassRegistered or (TempClass.lpfnWndProc <> @DefWindowProc) then
  begin
    if ClassRegistered then Windows.UnregisterClass(UtilWindowClass.lpszClassName, HInstance);
    Windows.RegisterClass(UtilWindowClass);
  end;
  Result := CreateWindowEx(WS_EX_TOOLWINDOW, UtilWindowClass.lpszClassName, '', WS_POPUP{!0}, 0, 0, 0, 0, 0, 0, HInstance, nil);
  if Assigned(Method) then SetWindowLong(Result, GWL_WNDPROC, Longint(MakeObjectInstance(Method)));
end;

procedure DeallocateHWnd(Wnd: HWND);
var
  Instance: Pointer;
begin
  Instance := Pointer(GetWindowLong(Wnd, GWL_WNDPROC));
  DestroyWindow(Wnd);
  if Instance <> @DefWindowProc then FreeObjectInstance(Instance);
end;

{ TMultiReadExclusiveWriteSynchronizer }

constructor TMultiReadExclusiveWriteSynchronizer.Create;
begin
  inherited Create;
  InitializeCriticalSection(FLock);
  FReadExit := CreateEvent(nil, True, True, nil);  // manual reset, start signaled
  SetLength(FActiveThreads, 4);
end;

destructor TMultiReadExclusiveWriteSynchronizer.Destroy;
begin
  BeginWrite;
  inherited Destroy;
  CloseHandle(FReadExit);
  DeleteCriticalSection(FLock);
end;

function TMultiReadExclusiveWriteSynchronizer.WriterIsOnlyReader: Boolean;
var
  I, Len: Integer;
begin
  Result := False;
  if FWriteRequestorID = 0 then Exit;
  // We know a writer is waiting for entry with the FLock locked,
  // so FActiveThreads is stable - no BeginRead could be resizing it now
  I := 0;
  Len := High(FActiveThreads);
  while (I < Len) and
    ((FActiveThreads[I].ThreadID = 0) or (FActiveThreads[I].ThreadID = FWriteRequestorID)) do
    Inc(I);
  Result := I >= Len;
end;

procedure TMultiReadExclusiveWriteSynchronizer.BeginWrite;
begin
  EnterCriticalSection(FLock);  // Block new read or write ops from starting
  if not FWriting then
  begin
    FWriteRequestorID := GetCurrentThreadID;   // Indicate that writer is waiting for entry
    if not WriterIsOnlyReader then              // See if any other thread is reading
      WaitForSingleObject(FReadExit, INFINITE); // Wait for current readers to finish
    FSaveReadCount := FCount;  // record prior read recursions for this thread
    FCount := 0;
    FWriteRequestorID := 0;
    FWriting := True;
  end;
  Inc(FCount);  // allow read recursions during write without signalling FReadExit event
end;

procedure TMultiReadExclusiveWriteSynchronizer.EndWrite;
begin
  Dec(FCount);
  if FCount = 0 then
  begin
    FCount := FSaveReadCount;  // restore read recursion count
    FSaveReadCount := 0;
    FWriting := False;
  end;
  LeaveCriticalSection(FLock);
end;

procedure TMultiReadExclusiveWriteSynchronizer.BeginRead;
var
  I: Integer;
  ThreadID: Integer;
  ZeroSlot: Integer;
  AlreadyInRead: Boolean;
begin
  ThreadID := GetCurrentThreadID;
  // First, do a lightweight check to see if this thread already has a read lock
  while InterlockedExchange(FReallocFlag, ThreadID) <> 0 do  Sleep(0);
  try    // FActiveThreads array is now stable
    I := 0;
    while (I < High(FActiveThreads)) and (FActiveThreads[I].ThreadID <> ThreadID) do
      Inc(I);
    AlreadyInRead := I < High(FActiveThreads);
    if AlreadyInRead then  // This thread already has a read lock
    begin                   // Don't grab FLock, since that could deadlock with
      if not FWriting then  // a waiting BeginWrite
      begin                 // Bump up ref counts and exit
        InterlockedIncrement(FCount);
        Inc(FActiveThreads[I].RecursionCount); // thread safe = unique to threadid
      end;
    end
  finally
    FReallocFlag := 0;
  end;
  if not AlreadyInRead then
  begin   // Ok, we don't already have a lock, so do the hard work of making one
    EnterCriticalSection(FLock);
    try
      if not FWriting then
      begin
        // This will call ResetEvent more than necessary on win95, but still work
        if InterlockedIncrement(FCount) = 1 then
          ResetEvent(FReadExit); // Make writer wait until all readers are finished.
        I := 0;  // scan for empty slot in activethreads list
        ZeroSlot := -1;
        while (I < High(FActiveThreads)) and (FActiveThreads[I].ThreadID <> ThreadID) do
        begin
          if (FActiveThreads[I].ThreadID = 0) and (ZeroSlot < 0) then ZeroSlot := I;
          Inc(I);
        end;
        if I >= High(FActiveThreads) then  // didn't find our threadid slot
        begin
          if ZeroSlot < 0 then  // no slots available.  Grow array to make room
          begin   // spin loop.  wait for EndRead to put zero back into FReallocFlag
            while InterlockedExchange(FReallocFlag, ThreadID) <> 0 do  Sleep(0);
            try
              SetLength(FActiveThreads, High(FActiveThreads) + 3);
            finally
              FReallocFlag := 0;
            end;
          end
          else  // use an empty slot
            I := ZeroSlot;
          // no concurrency issue here.  We're the only thread interested in this record.
          FActiveThreads[I].ThreadID := ThreadID;
          FActiveThreads[I].RecursionCount := 1;
        end
        else  // found our threadid slot.
          Inc(FActiveThreads[I].RecursionCount); // thread safe = unique to threadid
      end;
    finally
      LeaveCriticalSection(FLock);
    end;
  end;
end;

procedure TMultiReadExclusiveWriteSynchronizer.EndRead;
var
  I, ThreadID, Len: Integer;
begin
  if not FWriting then
  begin
    // Remove our threadid from the list of active threads
    I := 0;
    ThreadID := GetCurrentThreadID;
    // wait for BeginRead to finish any pending realloc of FActiveThreads
    while InterlockedExchange(FReallocFlag, ThreadID) <> 0 do  Sleep(0);
    try
      Len := High(FActiveThreads);
      while (I < Len) and (FActiveThreads[I].ThreadID <> ThreadID) do Inc(I);
      assert(I < Len);
      // no concurrency issues here.  We're the only thread interested in this record.
      Dec(FActiveThreads[I].RecursionCount); // threadsafe = unique to threadid
      if FActiveThreads[I].RecursionCount = 0 then
        FActiveThreads[I].ThreadID := 0; // must do this last!
    finally
      FReallocFlag := 0;
    end;
    if (InterlockedDecrement(FCount) = 0) or WriterIsOnlyReader then
      SetEvent(FReadExit);     // release next writer
  end;
end;

procedure FreeAndNil(var Obj);
var
  P: TObject;
begin
  P := TObject(Obj);
  TObject(Obj) := nil;  // clear the reference before destroying the object
  P.Free;
end;

{ System Flags }

function SysLocaleFarEast: Boolean;
begin
  Result := GetSystemMetrics(SM_DBCSENABLED) <> 0;
end;

function GetLocaleChar(Locale, LocaleType: Integer; Default: Char): Char;
var
  Buffer: array[0..1] of Char;
begin
  if GetLocaleInfo(Locale, LocaleType, Buffer, 2) > 0 then
    Result := Buffer[0] else
    Result := Default;
end;

function DefaultLCID: LCID;
begin
  Result := GetThreadLocale;
end;

function TimeSeparator: Char;
begin
  Result := GetLocaleChar(DefaultLCID, LOCALE_STIME, ':');
end;

{ TFont }

constructor TFont.Create; //08.03.03
begin
  FName := DefaultFont;
  FColor := clBlack;
  FHeight := -11;
  FCharset := 1;
//  FStyle:= [];
//  FSize := 8;
end;

constructor TFont.Create(Canvas: TCanvas);
begin
  FCanvas := Canvas;
  Create;
  UpdateFont;
end;

procedure TFont.SetColor(const Value: TColor);
begin
  FColor := Value;
  if FControl<>nil then FControl.FTextColor := Value;
end;

//{$ifdef asm_ver}
{procedure TFont.SetControl(const Value: TWinControl);
asm
  mov  [EAX].FControl, Value
  call [EAX].UpdateFont
end;
{$else}
procedure TFont.SetControl(const Value: TWinControl);
begin
  FControl := Value;
  UpdateFont ;
end;
//{$endif}

procedure TFont.SetHeight(const Value: Integer);
begin
  FHeight := Value;
  UpdateFont ;
end;

procedure TFont.SetName(const Value: String);
begin
  FName := Value;
  UpdateFont;
end;

function TFont.GetPitch: TFontPitch; //08.03.03
begin
  Result := fpDefault;
  case FPitch of
   FIXED_PITCH    : Result := fpFixed;
   VARIABLE_PITCH : Result := fpVariable;
  end;
end;

procedure TFont.SetPitch(const Value: TFontPitch); //08.03.03
begin
  case Value of
   fpDefault  : FPitch := DEFAULT_PITCH;
   fpFixed    : FPitch := FIXED_PITCH;
   fpVariable : FPitch := VARIABLE_PITCH;
  end;
  UpdateFont;
end;

procedure TFont.SetSize(const Value: Integer);
begin
  FSize := Value;
  FHeight := -MulDiv(Value, GetDeviceCaps(GetDc(0), LOGPIXELSY){FPixelsPerInch}, 72);
  UpdateFont;
  if FControl<>nil then FControl.Invalidate ;  
end;

procedure TFont.SetStyle(Value: TFontStyles);
begin
 if fsbold in value then FBold := FW_BOLD else FBold := FW_NORMAL;
 if fsItalic in value then FItalic := 1 else FItalic := 0;
 if fsUnderline in value then FUnderline := 1 else FUnderline := 0;
 if fsStrikeOut in value then FStrikeOut := 1 else FStrikeOut := 0;
 UpdateFont;
end;

procedure TFont.SetWidth(const Value: Integer);
begin
  FWidth := Value;
  UpdateFont;
end;

procedure TFont.SetCharset(const Value: Byte); //08.03.03
begin
  if FCharset <> Value then
   begin
    FCharset := Value;
    UpdateFont;
   end;
end;

(*{$ifdef asm_ver}
procedure TFont.UpdateFont;
begin
asm  //Ставим шрифт
  push 0//FName
  push DEFAULT_PITCH or FF_DONTCARE
  push DEFAULT_QUALITY
  push CLIP_DEFAULT_PRECIS
  push OUT_DEFAULT_PRECIS
  push DEFAULT_CHARSET
  push FStrikeOut
  push FUnderline
  push FItalic
  push FBold
  push 0
  push 0
  push FWidth
  push FHeight
  call CreateFont
  mov [EBX].FHandle, EAX

  push 0
  push [EBX].FHandle
  push WM_SETFONT
  push [EBX].FControl.FHandle
  call SendMessage
end;
{$else}  *)
procedure TFont.UpdateFont; //08.03.03
begin  //Ставим шрифт
  FHandle := CreateFont(FHeight, FWidth, 0, 0, FBold , FItalic, FUnderline, FStrikeOut,
    {DEFAULT_CHARSET}FCharset, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,
      FPitch or FF_DONTCARE, PChar(FName));

  if FControl<>nil then
    SendMessage(FControl.Handle , WM_SETFONT, FHandle, 0)
  else if FCtrlHandle <> 0 then
    SendMessage(FCtrlHandle , WM_SETFONT, FHandle, 0);
  if FCanvas <> nil then
  begin
    SelectObject(FCanvas.Handle, FHandle);
    SetTextColor(FCanvas.Handle, ColorToRGB(FColor));
  end;
end;
//{$endif}

{ TForm }

constructor TForm.Create(Parent:TWinControl; Caption: String);
begin
  inherited Create(Parent);
  FCaption := PChar(Caption);

  FClassName := ClassName;
  FParent := Parent;
  FParentHandle := 0;
  FLeft := 200;//cw_UseDefault;
  FTop := 100;//cw_UseDefault;
  FWidth := 300;//cw_UseDefault;
  FHeight := 250;//cw_UseDefault;
  FId := 1;
  FVisible := True;
  FColor := clBtnFace ;
  FBorderStyle := bsSizeable;
  FAlphaBlend := False;
  FAlphaBlendValue := 255;
  FTransparentColor := False;
  FTransparentColorValue := clBlack;

// CreateWindow ;
 with wClass do
  begin
//   Style:=CS_PARENTDC;
//   hIcon:=LoadIcon(hInstance,'MAINICON');
   lpfnWndProc := GetWndProc;
   hInstance := hInstance;
   hbrBackground := COLOR_BTNFACE+1;
   lpszClassName := PChar(FClassName);
   hCursor := LoadCursor(0, IDC_ARROW);
  end;
  RegisterClass(wClass);
  FHandle:=CreateWindowEx(0, PChar(FClassName),PChar(FCaption), WS_THICKFRAME or
         WS_SYSMENU  or WS_MINIMIZEBOX or WS_MAXIMIZEBOX, FLeft,
                    FTop, FWidth, FHeight, GetParentHandle, 0, hInstance, nil);
  SetProp(FHandle, App_Id, THandle(Self));

{$ifdef CanvasAutoCreate}
  FCanvas := TCanvas.Create(FHandle);
  FCanvas.FPen := TPen.Create(FCanvas);
  FCanvas.FBrush := TBrush.Create(FCanvas);
{$endif}

//Ставим иконку
  FIcon := LoadIcon(Hinstance, 'MAINICON');
  Perform(WM_SETICON, ICON_BIG, FIcon);
//Параметры Show
//  if Application = nil then
  if Parent = nil then
   MsgDefHandle := FHandle;
end;

procedure TWinControl.Click;
begin
  if Assigned(FOnClick) then FOnClick(Self);
end;

procedure TWinControl.DblClick;
begin
  if Assigned(FOnDblClick) then FOnDblClick(Self);
end;

constructor TWinControl.Create(AParent: TWinControl);
begin
  inherited Create;
  FParent := AParent;
  if Assigned(FParent) then
  begin
    FNext := FParent.FNext;
    FParent.FNext := Self;
  end
    else FNext := nil;
  FEnabled := True;
  FShowHint := True;
  FCtl3D := True;
end;

destructor TWinControl.Destroy;
begin
  while Assigned(FNext) and (FNext.FParent = Self) do
    FNext.Free;
  while Assigned(FParent) and (FParent.FNext <> Self) do
    FParent := FParent.FNext;
  if Assigned(FParent) then
    FParent.FNext := FNext;
  DestroyWindow(FHandle);
  FFont.Free;
  FCanvas.Free;
  inherited Destroy;
end;

procedure TWinControl.Dispatch(var AMsg);
begin
 inherited Dispatch(AMsg); //!!!
 with TMessage(AMsg) do
  begin
   if TMessage(AMsg).Result <> 0 then Exit;
   if FDefWndProc <> 0 then
    Result := CallWindowProc(Ptr(FDefWndProc), FHandle, Msg, WParam, LParam)
   else
    Result := DefWindowProc(FHandle,Msg,WParam,LParam);
  end;
end;

function TWinControl.GetParentHandle: HWnd;
begin
  if FParent <> nil then
    Result := FParent.FHandle
  else
    Result := FParentHandle;
end;

{$ifdef asm_ver}
function TWinControl.GetText: String;
asm
        XCHG      EAX, EDX
        MOV       ECX, [EDX].fHandle

        PUSH      EBX
        PUSH      ESI
        XCHG      EBX, EAX

        MOV       ESI, ECX
        PUSH      ESI
        CALL      GetWindowTextLength
        MOV       EDX, EAX
        INC       EAX
        PUSH      EAX // MaxLen

        MOV       EAX, EBX
        CALL      System.@LStrSetLength

        POP       EDX
        MOV       ECX, [EBX]
        JECXZ     @@exit
        PUSH      EDX // MaxLen = Length(Result) + 1

        PUSH      ECX //@Result[1]
        PUSH      ESI // fHandle
        CALL      GetWindowText

@@exit:
        POP       ESI
        POP       EBX
end;
{$else}
function TWinControl.GetText: String;
var
 Buf: PChar;
 Sz : Integer;
begin
 Sz := GetWindowTextLength(FHandle);
 if Sz = 0 then
  Buf := nil
 else
  begin
   GetMem(Buf, Sz + 1);
   GetWindowText(FHandle, Buf, Sz + 1);
  end;
 Result := Buf;
 if Buf <> nil then FreeMem(Buf);

{ FCaption[0] := chr(SendMessage(FHandle,WM_GETTEXTLENGTH,0,0)+1);
 SendMessage(FHandle,WM_GETTEXT,ord(FCaption[0]),Longint(@FCaption[1]));
 Result := FCaption; }
end;
{$endif}

function TWinControl.GetWndProc: Pointer; assembler;
asm
  MOV EAX, [EAX]
  MOV EAX, [EAX]
end;

procedure TWinControl.ProcessMessage(var AMsg: TMessage); //17.03.03
begin
 case AMsg.Msg  of
  WM_DESTROY:                         WMDestroy(TWMDestroy(AMsg));
  {$ifdef Close}WM_CLOSE:             WMClose(TWMClose(AMsg));{$endif}
  {$ifdef Paint}WM_PAINT:             WMPaint(TWMPaint(AMsg));{$endif}
  {$ifdef Command}WM_COMMAND:         WMCommand(TWMCommand(AMsg));{$endif}
  {$ifdef CtlColor}$0132..$0138:      WMCtlColor(AMsg);{$endif}
  {$ifdef EraseBkgnd}WM_ERASEBKGND:   WMEraseBkgnd(TWMEraseBkgnd(AMsg));{$endif}
  {$ifdef KeyDown}WM_KEYDOWN:         WMKeyDown(TWMKey(AMsg));{$endif}
  {$ifdef KeyUp}WM_KEYUP:             WMKeyUp(TWMKey(AMsg));{$endif}
  {$ifdef LButtonDown}WM_LBUTTONDOWN: WMLButtonDown(TWMLButtonDown(AMsg));{$endif}
  {$ifdef LButtonUp}WM_LBUTTONUP:     WMLButtonUp(TWMLButtonUp(AMsg));{$endif}
  {$ifdef LButtonDblClk}WM_LBUTTONDBLCLK: DblClick;{$endif}
  {$ifdef RButtonDown}WM_RBUTTONDOWN: WMRButtonDown(TWMRButtonDown(AMsg));{$endif}
  {$ifdef RButtonUp}WM_RBUTTONUP:     WMRButtonUp(TWMRButtonUp(AMsg));{$endif}
  {$ifdef MButtonDown}WM_MBUTTONDOWN: WMMButtonDown(TWMMButtonDown(AMsg));{$endif}
  {$ifdef MButtonUp}WM_MBUTTONUP:     WMMButtonUp(TWMMButtonUp(AMsg));{$endif}
  {$ifdef MouseMove}WM_MOUSEMOVE:     WMMouseMove(TWMMouseMove(AMsg));{$endif}
  {$ifdef SetFocus}WM_SETFOCUS :      WMSetFocus(TWMSetFocus(AMsg));{$endif}
  {$ifdef KillFocus}WM_KILLFOCUS:     WMKillFocus(TWMKillFocus(AMsg));{$endif}
  {$ifdef Size}WM_SIZE:
   begin
    if Assigned(FOnResize) then FOnResize(Self);
    Dispatch(AMsg);
   end;{$endif}
  {$ifdef SysCommand}WM_SYSCOMMAND:   WMSysCommand(TWMSysCommand(AMsg));{$endif}
  {$ifdef SetCursor}WM_SETCURSOR:     WMSetCursor(TWMSetCursor(AMsg));{$endif}
 else
   Dispatch(AMsg);
 end;
end;

(*{$ifdef asm_ver}
procedure TWinControl.Run;
{const
 size_TMsg = sizeof( TMsg );  }
var
 msg : TMsg;
begin
 if Assigned(FOnCreate) then FOnCreate(Self);
 if FVisible then ShowWindow(FHandle, SW_SHOW); 
{ asm
  push 5
  push [ebx].FHandle
  call ShowWindow

  mov ecx, size_TMsg
  jmp @@1
@@m:
  push ecx
  push ecx
  call TranslateMessage
  call DispatchMessage
@@1:
  call WaitMessage
  push 0
  push 0
  push [ebx].FHandle
  call GetMessage
  mov edx, eax

  cmp edx,0
  jz  @@m     
 end;}
  while True do
   begin
    WaitMessage;
    Self.ProcessMessages;
   end;
end;     *)

(*{$ifdef asm_ver}
procedure TWinControl.Run;
begin
asm
  mov   Application, EAX //Application := Self;
end;
{  mov   ECX, FOnCreate
  jecxz @@ret_EBX
  cmp   ECX, EAX
  je    @@ret_EBX
  push  eax
  call  [eax].FOnCreate
@@ret_EBX:
//  ret
  xor eax, eax   }
  if Assigned(Self.FOnCreate) then Self.FOnCreate(Self);  
asm
  push SW_SHOW
  push [EBX].FHandle //ShowWindow(Self.FHandle, SW_SHOW);
  call ShowWindow
//  xor eax, eax
end;

  while True do
   begin
    WaitMessage;
    Self.ProcessMessages;
   end;
end;
{$else}     *)
procedure TWinControl.Run;
begin
  AppTerminated := False;
  Application := Self;
  MsgDefHandle := FHandle;
  if Assigned(Self.FOnCreate) then Self.FOnCreate(Self);
  if Assigned(Self.FOnShow) then Self.FOnShow(Self);  
  if FVisible then ShowWindow(Self.FHandle, SW_SHOW);
  while {True} not AppTerminated do
   begin
    WaitMessage;
    Self.ProcessMessages;
   end;
end;
//{$endif}

procedure TWinControl.SetHeight(const Value: integer);
begin
 if FHeight=Value then Exit; //Если не изм. то выходим
 FHeight := Value;
 SetBounds(FLeft, FTop, Width, FHeight);
end;

procedure TWinControl.SetLeft(const Value: integer);
begin
 if FLeft=Value then Exit; //Если не изм. то выходим
 FLeft := Value;
 SetBounds(FLeft, FTop, Width, Height);
end;

procedure TWinControl.SetTop(const Value: integer);
begin
  if FTop=Value then Exit; //Если не изм. то выходим
  FTop := Value;
  SetBounds(FLeft, FTop, Width, Height);
end;

procedure TWinControl.SetWidth(const Value: integer);
begin
  if FWidth=Value then Exit; //Если не изм. то выходим
  FWidth := Value;
  SetBounds(FLeft, FTop, FWidth, Height);
end;

procedure TWinControl.SetBounds(Left, Top, Width, Height: Integer); //08.03.03
begin
 FLeft := Left;
 FTop := Top;
 FWidth := Width;
 FHeight := Height;

 SetWindowPos(FHandle, 0, Left, Top, Width, Height, SWP_NOZORDER or SWP_NOACTIVATE);
end;

procedure TWinControl.SetParentHandle(const Value: HWnd);
begin
  if FParent = nil then
    FParentHandle := Value
  else
    FParentHandle := FParent.FHandle;
end;

procedure TWinControl.SetText(const Value: String);
begin
  FCaption := PChar(Value);
  Perform(WM_SETTEXT, 0, Longint(PChar(FCaption)));
end;

procedure TWinControl.WMClose(var AMsg: TWMClose);
begin
  if not Assigned(FOnClose) or FOnClose(Self) then
   begin
    if Application = Self then
      DefWindowProc(FHandle, TMessage(AMsg).Msg, TMessage(AMsg).WParam, TMessage(AMsg).LParam)
    else
     begin
      if Application.FId = 0 then Application.Perform(WM_CLOSE, 0, 0);
      {if FParent<>nil then }EnableWindow(ParentHandle, True);
      ShowWindow(FHandle, SW_HIDE);
     end;
   end;
  AMsg.Result := 0;
end;

procedure TWinControl.WMCommand(var AMsg: TWMCommand);
var
  ctrl : TWinControl;
begin
  Dispatch(AMsg);
  with AMsg do
   begin
    ctrl := TWinControl(GetProp(ctl, App_Id));
    if ctrl=nil then exit;

    case NotifyCode of
      BN_CLICKED : if Ctrl.FEnabled then ctrl.Click;
      LBN_DBLCLK : if Ctrl.FEnabled then ctrl.DblClick;
    end;

    case NotifyCode of
      EN_CHANGE,
      LBN_SELCHANGE : if Ctrl.FEnabled then ctrl.Change;
    end;
(*
     case NotifyCode of
       CBN_DROPDOWN :
        begin
          SetWindowPos(Amsg.Ctl, 0, 0, 0, Ctrl.Width, 25 * (1 + 1) + 2, SWP_NOMOVE + SWP_NOZORDER + SWP_NOACTIVATE {+ SWP_NOREDRAW + SWP_HIDEWINDOW});
          SetWindowPos(Ctrl.Handle, 0, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_NOZORDER + SWP_NOACTIVATE + SWP_NOREDRAW + SWP_SHOWWINDOW);
        end;
     end;   *)
  end;
end;

procedure TWinControl.WMDestroy(var AMsg: TWMDestroy);
begin
  if Assigned(FOnDestroy) then FOnDestroy(Self);
  if Application = Self then
                        PostQuitMessage(0);
    //Perform(WM_QUIT, 0, 0);
    //AppTerminated := True;
    ///PostQuitMessage(0);
    //ExitProcess(0);
end;

function TWinControl.WndProc(AMessage, WParam, LParam: Integer): Longint;
var
  self_   : pointer;
  window_ : hWnd;
  AMsg    : TMessage;
begin
  window_ := HWND(Self);
  self_ := Ptr(GetProp(window_, App_Id));

  if self_ <> nil then
   begin
    AMsg.Msg := AMessage;
    AMsg.WParam := WParam;
    AMsg.LParam := LParam;
    AMsg.Result := 0;
    TWinControl(self_).ProcessMessage(AMsg);
   end
  else
   begin
    //if Assigned(FOnMessage) then FOnMessage(AMsg); 
    AMsg.Result := DefWindowProc(window_, AMessage, WParam, LParam);
    end;
  Result := AMsg.Result;
end;

procedure TWinControl.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
  if Value then Show else Hide;
end;

procedure TWinControl.Hide;
begin
  if Assigned(FOnHide) then FOnHide(Self);
  EnableWindow(ParentHandle, True);
  ShowWindow(FHandle, SW_HIDE);
end;

procedure TWinControl.Show;
begin
// if FHandle=0 then CreateWindow ;
  if Assigned(FOnShow) then FOnShow(Self);   
  ShowWindow(FHandle, SW_SHOW);
  SetForegroundWindow(FHandle);
end;
      
procedure TWinControl.CreateWnd;
begin
  FStyle := FStyle or WS_CLIPSIBLINGS or WS_CLIPCHILDREN;
  FHandle := CreateWindowEx(FExStyle, PChar(FClassName), PChar(FCaption),
      FStyle, FLeft, FTop, FWidth, FHeight, ParentHandle, 0, hInstance, nil);

  SetProp(FHandle, App_Id, THandle(Self));
  FDefWndProc := GetWindowLong(FHandle, GWL_WNDPROC);
  SetWindowLong(FHandle, GWL_WNDPROC, Longint(GetWndProc));

{$ifdef FontAutoCreate}
  FFont := TFont.Create;
  FFont.Control := Self;
{$endif}
{$ifdef CanvasAutoCreate}
  FCanvas := TCanvas.Create(FHandle);
  FCanvas.FPen := TPen.Create(FCanvas);
  FCanvas.FBrush := TBrush.Create(FCanvas);
{$endif}
end;

procedure TWinControl.SetPosition(Left, Top: Integer);
begin
  if (Left=FLeft) and (Top=FTop) then Exit;
  FLeft := Left;
  FTop := Top;
  SetBounds(FLeft, FTop, FWidth, FHeight);
end;

procedure TWinControl.SetSize(Width, Height: Integer);
begin
  if (Width=FWidth) and (Height=FHeight) then Exit;
  FWidth := Width;
  FHeight := Height;
  SetBounds(FLeft, FTop, FWidth, FHeight);
end;

{ TEdit }

constructor TEdit.Create(AParent: TWinControl; Text: String);
begin
 if AParent = nil then ExitProcess(0);
 inherited Create(AParent);
 FWidth := 121;
 FHeight := 21;
 FClassName := 'edit';
 FCaption := PChar(Text);
 FColor := GetSysColor(COLOR_WINDOW) ;
 FExStyle := WS_EX_CLIENTEDGE;
// FBkMode := bk_Transparent  ;
 FId := 3;
 FStyle := WS_CHILD or WS_VISIBLE or ES_AUTOHSCROLL;
 CreateWnd;
end;

procedure TEdit.Clear;
begin
  SetWindowText(FHandle, '');
end;

procedure TEdit.ClearUndo; //02.02.04
begin
  SendMessage(Handle, EM_EMPTYUNDOBUFFER, 0, 0);
end;

procedure TEdit.ClearSelection; //02.02.04
begin
  SendMessage(Handle, WM_CLEAR, 0, 0);
end;

procedure TEdit.CopyToClipboard; //02.02.04
begin
  SendMessage(Handle, WM_COPY, 0, 0);
end;

procedure TEdit.CutToClipboard; //02.02.04
begin
  SendMessage(Handle, WM_CUT, 0, 0);
end;

procedure TEdit.SetModified(const Value: Boolean); //02.02.04
begin
  SendMessage(Handle, EM_SETMODIFY, Byte(Value), 0);
end;

procedure TEdit.Undo; //02.02.04
begin
  SendMessage(Handle, WM_UNDO, 0, 0);
end;

function TEdit.GetCanUndo: Boolean; //02.02.04
begin
  Result := SendMessage(Handle, EM_CANUNDO, 0, 0) <> 0;
end;

function TEdit.GetModified: Boolean; //02.02.04
begin
  Result := SendMessage(Handle, EM_GETMODIFY, 0, 0) <> 0;
end;

procedure TEdit.PasteFromClipboard; //02.02.04
begin
  SendMessage(Handle, WM_PASTE, 0, 0);
end;

procedure TEdit.SelectAll; //02.02.04
begin
  SendMessage(Handle, EM_SETSEL, 0, -1);
end;

procedure TEdit.SetEditFlat(const Value: Boolean); //17.10.03
begin
  if FFlat <> Value then
   begin
    FFlat := Value;
    if Value then
     begin
      ExStyle := (ExStyle and not WS_EX_CLIENTEDGE) or WS_EX_STATICEDGE;
      if Height = 21 then Height := 16; //Если высоту не меняли, то меняем ;)
     end
    else
     begin
      ExStyle := (ExStyle and not WS_EX_STATICEDGE) or WS_EX_CLIENTEDGE;
      if Height = 16 then Height := 21; //Если высоту мы меняли, то меняем ;)      
     end;
   end;
end;

//TForm

{$ifdef asm_ver}
procedure TForm.SetMainMenu(const Value: hMenu);
asm
  mov [EAX].FMenu, Value //FMenu := Value;
  push Value
  push [EAX].FHandle
  call SetMenu           //SetMenu(FHandle, Value);
end;
{$else}
procedure TForm.SetMainMenu(const Value: hMenu);
begin
  FMenu := Value;
  SetMenu(FHandle, Value);
end;
{$endif}

function TForm.GetWindowState: Integer;
var
  WP: TWindowPlacement;
begin
  WP.length := SizeOf(WP);
  GetWindowPlacement(FHandle, @WP);
  Result := WP.showCmd;
end;

procedure TForm.SetWindowState(const Value: Integer);
begin
  ShowWindow(FHandle, Value);
end;

procedure TForm.SetAlphaBlend(const Value: Boolean);
begin
  if FAlphaBlend <> Value then
   begin
    FAlphaBlend := Value;
    SetLayeredAttribs;
   end;
end;

procedure TForm.SetAlphaBlendValue(const Value: Byte);
begin
  if FAlphaBlendValue <> Value then
   begin
    FAlphaBlendValue := Value;
    SetLayeredAttribs;
   end;
end;

procedure TForm.SetLayeredAttribs;
type
  TSetLayeredWindowAttributes = function(hwnd: Integer; crKey: TColor; bAlpha: Byte; dwFlags: DWORD): Boolean; stdcall;
const
  LWA_ALPHA=$00000002;
  LWA_COLORKEY=$00000001;
  WS_EX_LAYERED=$00080000; //Эти константы появились только в Delphi 6

  cUseAlpha: array [Boolean] of Integer = (0, LWA_ALPHA);
  cUseColorKey: array [Boolean] of Integer = (0, LWA_COLORKEY);
var
  SetLayeredWindowAttributes: TSetLayeredWindowAttributes;
  AStyle: Integer;
begin
  AStyle := GetWindowLong(Handle, GWL_EXSTYLE);
  if FAlphaBlend or FTransparentColor then
   begin
    SetLayeredWindowAttributes := GetProcAddress(GetModuleHandle('User32'), 'SetLayeredWindowAttributes');
    SetWindowLong(FHandle, GWL_EXSTYLE, AStyle or WS_EX_LAYERED);
    SetLayeredWindowAttributes(FHandle, ColorToRGB(FTransparentColorValue), FAlphaBlendValue, cUseAlpha[FAlphaBlend] or cUseColorKey[FTransparentColor]);
   end
  else
   SetWindowLong(FHandle, GWL_EXSTYLE, AStyle and not WS_EX_LAYERED);
end;

procedure TForm.SetTransparentColor(const Value: Boolean);
begin
  if FTransparentColor <> Value then
   begin
    FTransparentColor := Value;
    SetLayeredAttribs;
   end;
end;

procedure TForm.SetTransparentColorValue(const Value: TColor);
begin
  if FTransparentColorValue <> Value then
   begin
    FTransparentColorValue := Value;
    SetLayeredAttribs;
   end;
end;

procedure TForm.CreateWindow;
begin
  if Assigned(FOnCreate) then FOnCreate(Self);
end;

{ TLabel }

constructor TLabel.Create(AParent: TWinControl; Caption: String);
begin
 if AParent = nil then ExitProcess(0);
 inherited Create(AParent);
 FWidth := 32;
 FHeight := 14;
 FClassName := 'static';
 FCaption := PChar(Caption);
 FExStyle :=WS_EX_TRANSPARENT ;
 FStyle := WS_CHILD or WS_VISIBLE or SS_NOTIFY ;
 FColor := GetSysColor(COLOR_BTNFACE) ;
// FBkMode := bk_Opaque ;

 CreateWnd;
end;

procedure TWinControl.SetIcon(Value: HIcon);
var
  OldIco: HIcon;
begin
  if FIcon = Value then Exit;
  FIcon := Value;
  if Value = THandle(-1) then Value := 0;
  OldIco := Perform(WM_SETICON, 1 {ICON_BIG}, Value);
  if OldIco <> 0 then DestroyIcon( OldIco );
end;

{$ifdef asm_ver}
function TWinControl.Perform(MsgCode: DWORD; wParam, lParam: Integer): Integer;
asm
  push lParam
  push wParam
  push MsgCode
  mov  EAX, [EBP+8]
  push [EAX].FHandle
  call SendMessage
end;
{$else}
function TWinControl.Perform(MsgCode: DWORD; wParam, lParam: Integer): Integer;
begin
  Result := SendMessage(FHandle, MsgCode, wParam, lParam );
end;
{$endif}

procedure TWinControl.ProcessMessages;
var
  Msg: TMsg;
begin
  while ProcessMsg(Msg) do begin end;
end;

function TWinControl.ProcessMsg(var Msg: TMsg): Boolean;
begin
  Result := False;
  if PeekMessage(Msg, 0, 0, 0, PM_REMOVE) then
  begin
    Result := True;
    if Msg.Message = WM_QUIT then
      AppTerminated := True
    else if not Assigned(FOnProcessMsg) or not FOnProcessMsg(Msg) then
    begin
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end
   end;
end;

{procedure TWinControl.SetTextColor(Value: Integer);
begin
//  Windows.SetTextColor(FDC,Value);
  FTextColor := Value;
end;    }

procedure TWinControl.SetColor(const Value: Integer);
var
  tb,ob : HBrush;
begin
  if FColor <> Value then
   begin
    FColor := Value;
{ if FHandle > 0 then
  begin}
    tb := CreateSolidBrush(ColorToRGB(FColor));
    ob := SelectObject(FDC,tb);
    DeleteObject(ob);
    FBrush := tb;
{  end
 else
  begin
   if FBrush > 0 then DeleteObject(FBrush);
   FBrush := CreateSolidBrush(FColor);
  end;  }

    Invalidate ;
   end; 
end;

procedure TWinControl.WMEraseBkgnd(var AMsg: TWMEraseBkgnd);
var
  R : TRect;
  hd : HDC;
begin
  GetClientRect(FHandle, R);
  hd := AMsg.DC;
{ if Assigned(FOnErase) then
  begin
    FOnErase(Self, hd, R);
    AMsg.Result := 1;
  end
 else }

 if (FBkMode = bk_OPaque) or (FParent = nil) then
  if FBrush = 0 then
    Dispatch(TMessage(AMsg)) 
  else
   begin
    FillRect(hd, R, FBrush);
    AMsg.Result := 1;
   end
 else
  if FBkMode = bk_Transparent then
   begin
    FillRect(hd, R, FParent.FBrush);
    AMsg.Result := 1;
   end
  else AMsg.Result := 1;
  Dispatch(AMsg);
end;

(*{$ifdef asm_ver}
procedure TWinControl.SetEnabled(Value: Boolean);
asm
  mov  [eax].FEnabled, Value //FEnabled := Value;
  push edx
  push [eax].FHandle
  call EnableWindow
end;
{$else} *)
procedure TWinControl.SetEnabled(Value: Boolean);
begin
  FEnabled := Value;
  EnableWindow(FHandle, Value);
end;
//{$endif}   

procedure TLabel.SetAlignment(const Value: Integer);
begin
  FAlignment := Value;
  SetStyle(FStyle or FAlignment);
end;

{ TMemo }
{procedure TMemo.SetLines;
begin
  Text := FLines.Text; 
end; }

procedure TMemo.LineAdd(S: String);
//var ss : array [1..256] of char;
begin
  if Text = '' then
   Text := s
  else
   Text := Text + CrLf + S;
 // SLAdd(sl, S);

//  Move(s[1],ss[1],Ord(s[0]));
//  ss[Ord(s[0])+1] := #0;
//  {Result := }SendMessage(FHandle, LB_ADDSTRING, 0, Longint(@ss));
//  if Result < 0 then Result := -1;
//  if Count = 1 then Focused := 0;
end;

function TMemo.GetLineText: String;
begin
  Result := Text;//SLText(sl);
end;

procedure TMemo.SetLineText(const Value: String); //11.07.03
begin
  if LineText <> Value then
   Text := Value;   //SLSetText(sl, Value);
end;

function TMemo.GetLineStrings(Index: Integer): String; //11.07.03
var
  sl: TStringList;
begin
  sl := TStringList.Create ;
  sl.Text := LineText;
  Result := sl.Strings[Index]; 
  LineText := sl.Text ;
  sl.Free ;
end;

procedure TMemo.SetLineStrings(Index: Integer; const Value: String); //11.07.03
var
  sl: TStringList;
begin
  sl := TStringList.Create ;
  sl.Text := LineText;
  sl.Strings[Index] := Value; 
  LineText := sl.Text ;
  sl.Free ;
end;

procedure TMemo.Clear;
begin
  SetWindowText(FHandle, '');
end;

constructor TMemo.Create(AParent: TWinControl; Text: String); //08.03.03
begin
  if AParent = nil then ExitProcess(0);
  inherited Create(AParent);
  FColor := clWhite;
  FWidth := 185;
  FHeight := 89;
  FClassName := 'edit';
  FCaption := PChar(Text);
  FExStyle := WS_EX_CLIENTEDGE;
  FStyle := WS_CHILD or WS_VISIBLE or ES_AUTOHSCROLL or ES_MULTILINE or ES_AUTOVSCROLL;
  FColor := GetSysColor(COLOR_WINDOW);
//Lines
// FLines := TStringList.Create ;
// FLines.OnChange := SetLines;

  //slClear(sl);

  CreateWnd;
end;

procedure TWinControl.BringToFront;
begin
  SetWindowPos(FHandle, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_SHOWWINDOW);
end;

procedure TWinControl.SendToBack;
begin
  SetWindowPos(FHandle, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOOWNERZORDER);
end;

{$ifdef asm_ver}
procedure TWinControl.SetExStyle(const Value: longint);
const SWP_FLAGS = SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or
                 SWP_NOZORDER or SWP_FRAMECHANGED;
asm
        CMP      EDX, [EAX].fExStyle
        JZ       @@exit
        MOV      [EAX].fExStyle, EDX
        MOV      ECX, [EAX].fHandle
        JECXZ    @@exit

        PUSH     EAX

        PUSH     SWP_FLAGS
        XOR      EAX, EAX
        PUSH     EAX
        PUSH     EAX
        PUSH     EAX
        PUSH     EAX
        PUSH     EAX
        PUSH     ECX

        PUSH     EDX
        PUSH     GWL_EXSTYLE
        PUSH     ECX
        CALL     SetWindowLong
        CALL     SetWindowPos  
        POP      EAX
//        CALL     Invalidate
@@exit:
end;
{$else}
procedure TWinControl.SetExStyle(const Value: longint);
begin
  if FExStyle = Value then Exit;
  FExStyle := Value;
  if fHandle = 0 then Exit;
  SetWindowLong(fHandle, GWL_EXSTYLE, Value);
  SetWindowPos(fHandle, 0, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);
// Invalidate;
end;
{$endif}

{$ifdef asm_ver}
procedure TWinControl.SetStyle(const Value: longint);
const
  SWP_FLAGS = SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED;
asm
        CMP      EDX, [EAX].fStyle
        JZ       @@exit
        MOV      [EAX].fStyle, EDX
        MOV      ECX, [EAX].fHandle
        JECXZ    @@exit

        PUSH     EAX

        PUSH     SWP_FLAGS
        XOR      EAX, EAX
        PUSH     EAX
        PUSH     EAX
        PUSH     EAX
        PUSH     EAX
        PUSH     EAX
        PUSH     ECX

        PUSH     EDX
        PUSH     GWL_STYLE
        PUSH     ECX
        CALL     SetWindowLong
        CALL     SetWindowPos
        POP      EAX
//        CALL     Invalidate
@@exit:
end;
{$else}
procedure TWinControl.SetStyle(const Value: longint);
begin
  if FStyle = Value then Exit;
  FStyle := Value;
  if fHandle = 0 then Exit;
  SetWindowLong(fHandle, GWL_STYLE, Value);
  SetWindowPos(fHandle, 0, 0, 0, 0, 0,
                 SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or
                 SWP_NOZORDER or SWP_FRAMECHANGED);
// Invalidate;
end;
{$endif}

procedure TForm.SetBorderStyle(const Value: TFormBorderStyle);
var
  s,es:DWord;
begin
 if FBorderStyle = Value then Exit;
 s:=0; es:=0;
 case Value of
  bsDialog:
   begin
    s  := WS_POPUP or WS_SYSMENU or WS_CAPTION    ;
    es :=  WS_EX_DLGMODALFRAME
   end;
  bsNone:
   begin
    s  := WS_POPUP;
   end;
  bsSingle:
   begin
    s  := WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX or WS_MAXIMIZEBOX;
   end;
  bsSizeable:
   begin
    s  := WS_THICKFRAME or WS_SYSMENU  or WS_MINIMIZEBOX or WS_MAXIMIZEBOX;
   end;
  bsSizeToolWin:
   begin
    es := WS_EX_TOOLWINDOW;  ;
   end;
  bsToolWindow:
   begin
    s  := WS_OVERLAPPED or WS_SYSMENU or WS_CAPTION;
    es := WS_EX_TOOLWINDOW;
   end;
 end;
 if s<>0 then SetStyle(s);
 if es<>0 then SetExStyle(es);

{
 FStyle := Value;
 if fHandle = 0 then Exit;
 SetWindowLong(fHandle, GWL_STYLE, Value);
 SetWindowPos(fHandle, 0, 0, 0, 0, 0,
                 SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or
                 SWP_NOZORDER or SWP_FRAMECHANGED);   }
// Invalidate;
end;

procedure TForm.SetFormPosition(const Value: Byte);
begin
  FPosition := Value;
  case Value of
   //По центру экрана
   1: begin
       Left := (GetSystemMetrics(SM_CXSCREEN)-Width) div 2;
       Top := (GetSystemMetrics(SM_CYSCREEN)-Height) div 2;
       //SetPosition(Left, Top);
      end;
  end;
end;

procedure TForm.SetBorderIcons(const Value: TBorderIcons); //!!! Стиль окна не сохраняется в переменной!
var                                                        //Гонит если ост тока меню
  Icons:Integer;
begin
  FBorderIcons := Value;
// if biSystemMenu in Value then Icons := Icons or WS_SYSMENU else Icons := Icons or not WS_SYSMENU;
  if biMinimize in Value then Icons := WS_MINIMIZEBOX else Icons := not WS_MINIMIZEBOX;
  if not (biMaximize in Value) and (biMinimize in Value) then Icons:=FStyle;
  if biMaximize in Value then Icons := Icons or WS_MAXIMIZEBOX else Icons := Icons and not WS_MAXIMIZEBOX;
  if (biMaximize in Value) and (biMinimize in Value) then Icons:=FStyle;

  SetStyle(FStyle and Icons);
end;

(*{$ifdef asm_ver}
procedure TForm.Close;
asm
  xor eax, eax
  push eax
  push eax
  push WM_CLOSE
  push MsgDefHandle
  call PostMessage
end;
{$else}*)
procedure TForm.Close;
begin
  if (Application<>Self) and Assigned(FOnClose) and not FOnClose(Self) then Exit;
  if Application = Self then
   PostMessage(MsgDefHandle, WM_CLOSE, 0, 0)
  else
   Hide;
end;
//{$endif}

procedure TLabel.SetTransparent(const Value: Boolean);
begin
  FTransparent := Value;
  if Value then FBkMode := bk_Transparent else FBkMode := bk_Opaque ;
end;

{ TButton }

procedure TButton.Click;
begin
  inherited
end;

constructor TButton.Create(AParent: TWinControl; Caption:String);
begin
  if AParent = nil then ExitProcess(0);
  inherited Create(AParent);
  FWidth := 75;
  FHeight := 25;
  FClassName := 'button';
  FCaption := PChar(Caption);
  FId := 2;
//  FExStyle := WS_EX_CLIENTEDGE ;
  FStyle := WS_VISIBLE or WS_CHILD or BS_PUSHLIKE or WS_TABSTOP ;
  FColor := clBtnFace ;
  CreateWnd;
end;

function KeysToShiftState(Keys: Word): TShiftState;
begin
  Result := [];
  if Keys and MK_SHIFT <> 0 then Include(Result, ssShift);
  if Keys and MK_CONTROL <> 0 then Include(Result, ssCtrl);
  if Keys and MK_LBUTTON <> 0 then Include(Result, ssLeft);
  if Keys and MK_RBUTTON <> 0 then Include(Result, ssRight);
  if Keys and MK_MBUTTON <> 0 then Include(Result, ssMiddle);
  if GetKeyState(VK_MENU) < 0 then Include(Result, ssAlt);
end; 

procedure TWinControl.WMLButtonDown(var AMsg: TWMLButtonDown);
begin
  DoMouseDown(AMsg, mbLeft, []);
end;

procedure TWinControl.WMSetFocus(var AMsg: TWMSetFocus);
begin
  Dispatch(AMsg);
  if FId=2 then SetButtonStyle(True);
end;

procedure TWinControl.WMKillFocus(var AMsg: TWMKillFocus);
begin
  Dispatch(AMsg);
  if FId=2 then SetButtonStyle(False);
end;

//-------------------------- Constructors ------------------------//
function NewForm(Parent:TForm; Caption: String):TForm;
begin
  Result := TForm.Create(Parent, Caption);
end;

function NewButton(AParent : TForm; Caption:String):TButton;
begin
  Result := TButton.Create(AParent, Caption);
end;
//------------------------------- Main ---------------------------//
procedure About;
begin
  MessageBox(0, '.::AvL Module:.'+#13#10+'  Version: 0.2'+#13#10+' Avenger 2002', 'About...', 0);
end;

{$ifdef asm_ver}
procedure AboutBox(Handle: THandle; AppName, Desk: String);
asm
  push 0
  push Desk
  push AppName
  push Handle
  call ShellAbout
end;
{$else}
procedure AboutBox(Handle: THandle; AppName, Desk: String);
begin
  ShellAbout(Handle, PChar(AppName), PChar(Desk), 0);
end;
{$endif}

procedure MsgBox(S:String); //vb  //26.02.03
var
  s_: String;
begin
  if Application <> nil then s_ := Application.Caption else s_ := 'Info';
  MessageBox(MsgDefHandle, PChar(s), PChar(S_), MB_OK);
end;

{$ifdef asm_ver}
procedure MsgDlg(Text, Title: String); //20.03.03
asm
  push MB_OK
  push Title
  push Text
  push 0
  call MessageBox
end;
{$else}
procedure MsgDlg(Text, Title:String); //26.02.03
begin
  MessageBox(MsgDefHandle, PChar(Text), PChar(Title), MB_OK);
end;
{$endif}

{$ifdef asm_ver}
procedure MsgOk(S: String); //30.03.04
asm
  xor edx, edx
  push edx
  push edx                      
  push eax
  push edx
  call MessageBox
end;
{$else}
procedure MsgOk(S: String); //30.03.04
begin
  MessageBox(0, PChar(S), 0, MB_OK);
end;
{$endif}

(*{$ifdef asm_ver}
procedure ShowMessage(S: String); //20.03.03
const
  defCaption: array[0..4] of Char = ('I', 'n', 'f', 'o', #0);
asm
  mov ebx, s
  mov eax, offset[defCaption]
  mov ecx, [Application]
  //xor eax, eax   
  jecxz @@1
  mov eax, [ecx].TApplication.FCaption
@@1:
  push MB_OK
  push eax
  push ebx   
  push MsgDefHandle
  call MessageBox
end;
{$else}  *)
procedure ShowMessage(S: String);
var
  s_: String;
begin
  if Application <> nil then s_ := Application.Caption else s_ := 'Info';
  MessageBox(MsgDefHandle, PChar(s), PChar(S_), MB_OK);
end;
//{$endif}

function InputQuery(AParent: THandle; const ACaption, APrompt: string; var Value: string): Boolean;
type
  TParams = record
    Caption, Prompt, Result: string;
  end;
  PParams = ^TParams;
const
  ID_PROMPT = $1000;
  ID_EDIT = $1001;
  ID_BTNOK = $1002;
  ID_BTNCANCEL = $1003;

  function HookProc(hWnd: THandle; Msg: UINT; wParam, lParam: Longint): Longint; stdcall;
  begin
    if (Msg = WM_KEYUP) and (wParam in [VK_RETURN, VK_ESCAPE]) then
      SendMessage(GetWindowLong(hWnd, GWL_HWNDPARENT), Msg, wParam, lParam);
    Result := CallWindowProc(Pointer(GetWindowLong(hWnd, GWL_USERDATA)), hWnd, Msg, wParam, lParam);
  end;

  procedure SetHook(hWnd: THandle);
  begin
    SetWindowLong(hWnd, GWL_USERDATA, SetWindowLong(hWnd, GWL_WNDPROC, Longint(@HookProc)));
  end;

  function DlgProc(hWnd: THandle; Msg: UINT; wParam, lParam: Longint): Longbool; stdcall;
  var
    Edit: THandle;
  begin
    Result := true;
    case Msg of
      WM_INITDIALOG: begin
        SetWindowLong(hWnd, GWL_USERDATA, lParam);
        SetWindowText(hWnd, PChar(PParams(lParam).Caption));
        SetWindowText(GetDlgItem(hWnd, ID_PROMPT), PChar(PParams(lParam).Prompt));
        Edit := GetDlgItem(hWnd, ID_EDIT);
        SetWindowText(Edit, PChar(PParams(lParam).Result));
        SendMessage(Edit, EM_SETSEL, 0, -1);
        SetFocus(Edit);
        SetHook(Edit);
        SetHook(GetDlgItem(hWnd, ID_PROMPT));
        SetHook(GetDlgItem(hWnd, ID_BTNOK));
        SetHook(GetDlgItem(hWnd, ID_BTNCANCEL));
        Result :=false;
      end;
      WM_KEYUP:
        if wParam = VK_ESCAPE then
          SendMessage(hWnd, WM_COMMAND, ID_BTNCANCEL, 0);
      WM_COMMAND: case LoWord(wParam) of
        ID_BTNOK: begin
          Edit := GetDlgItem(hWnd, ID_EDIT);
          with PParams(GetWindowLong(hWnd, GWL_USERDATA))^ do
          begin
            SetLength(Result, GetWindowTextLength(Edit));
            GetWindowText(Edit, PChar(Result), Length(Result) + 1); 
          end;
          EndDialog(hWnd, ID_OK);
        end;
        ID_BTNCANCEL: EndDialog(hWnd, ID_CANCEL);
      end;
      WM_CLOSE: SendMessage(hWnd, WM_COMMAND, ID_BTNCANCEL, 0);
      else Result := false;
    end;
  end;

const
  DlgTemplate: record
    Dlg: TDlgTemplate;
    DlgVLA: array[0..2] of Word;
    DlgFont: array[0..15] of WideChar;
    Prompt: TDlgItemTemplate;
    PromptVLA: array[0..2] of Word;
    PromptCD: Integer;
    Edit: TDlgItemTemplate;
    EditVLA: array[0..2] of Word;
    EditCD: Integer;
    OK: TDlgItemTemplate;
    OKClass: array[0..1] of Word;
    OKTitle: array[0..2] of WideChar;
    OKCD: Integer;
    Cancel: TDlgItemTemplate;
    CancelClass: array[0..1] of Word;
    CancelTitle: array[0..6] of WideChar;
    CancelCD: Integer;
  end = (
    Dlg: (
      style: DS_3DLOOK or DS_CENTER or DS_SETFONT or DS_MODALFRAME or WS_SYSMENU;
      dwExtendedStyle: 0;
      cdit: 4;
      x: 0;
      y: 0;
      cx: 140;
      cy: 58);
    DlgVLA: (0, 0, 0);
    DlgFont: (#10, 'M', 'S', ' ', 'S', 'a', 'n', 's', ' ', 'S', 'e', 'r', 'i', 'f', #0, #0); 
    Prompt: (
      style: WS_CHILD or WS_VISIBLE;
      dwExtendedStyle: WS_EX_TRANSPARENT;
      x: 5;
      y: 5;
      cx: 130;
      cy: 8;
      id: ID_PROMPT);
    PromptVLA: ($FFFF, $0082, 0);
    PromptCD: 0;
    Edit: (
      style: WS_CHILD or WS_VISIBLE or ES_AUTOHSCROLL or WS_TABSTOP;
      dwExtendedStyle: WS_EX_CLIENTEDGE;
      x: 5;
      y: 15;
      cx: 130;
      cy: 11;
      id: ID_EDIT);
    EditVLA: ($FFFF, $0081, 0);
    EditCD: 0;
    OK: (
      style: WS_VISIBLE or WS_CHILD or BS_PUSHBUTTON or BS_DEFPUSHBUTTON or WS_TABSTOP;
      dwExtendedStyle: 0;
      x: 50;
      y: 30;
      cx: 40;
      cy: 12;
      id: ID_BTNOK);
    OKClass: ($FFFF, $0080);
    OKTitle: ('O', 'K', #0);
    OKCD: 0;
    Cancel: (
      style: WS_VISIBLE or WS_CHILD or BS_PUSHBUTTON or WS_TABSTOP;
      dwExtendedStyle: 0;
      x: 95;
      y: 30;
      cx: 40;
      cy: 12;
      id: ID_BTNCANCEL);
    CancelClass: ($FFFF, $0080);
    CancelTitle: ('C', 'a', 'n', 'c', 'e', 'l', #0);
    CancelCD: 0
  );
var
  Params: TParams;
begin
  with Params do
  begin
    Caption := ACaption;
    Prompt := APrompt;
    Result := Value;
  end;
  Result := DialogBoxIndirectParam(hInstance, DlgTemplate.Dlg, AParent, @DlgProc, Longint(@Params)) = ID_OK;
  if Result then
    Value := Params.Result;
end;

function SysErrorMessage(ErrorCode: Integer): string;
var
  Len: Integer;
  Buffer: array[0..255] of Char;
begin
  Len := FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_ARGUMENT_ARRAY, nil, ErrorCode, 0, Buffer, SizeOf(Buffer), nil);
  while (Len > 0) and (Buffer[Len - 1] in [#0..#32]) do Dec(Len);
  SetString(Result, Buffer, Len);
end;

//-------------------------- Windows -------------------------//

function IsFileTypeRegistered(FileType, Prog: String): Boolean; //09.12.03
var
  Key: hKey;
begin
  Key := RegKeyOpenRead(HKEY_CLASSES_ROOT, FileType+'file\shell\open\command');
  Result := LowerCase(RegKeyGetStr(Key, '')) = LowerCase(Prog+' "%1"');
  RegCloseKey(Key);
end;

procedure RegisterFileType(prefix, exepfad: String; IconIndex: Byte); //09.12.03
var
 reg:TRegistry;
begin
  reg:=TRegistry.Create;
  try
    reg.RootKey:= HKEY_CLASSES_ROOT;
    //create a new key >> .ext
    reg.OpenKey('.'+prefix,True);
    //create a new value for this key >> extfile
    reg.WriteString('',prefix+'file');
    reg.CloseKey;

    //create a new key >> extfile
    reg.CreateKey(prefix+'file');
    //create a new key extfile\DefaultIcon
    reg.OpenKey(prefix+'file\DefaultIcon',True);
    //and create a value where the icon is stored >> c:\project1.exe,0
    reg.WriteString('',exepfad+','+IntToStr(IconIndex));
    reg.CloseKey;

    reg.OpenKey(prefix+'file\shell\open\command',True);
    //create value where exefile is stored --> c:\project1.exe "%1"
    reg.WriteString('',exepfad+' "%1"');
    reg.CloseKey;
  finally
    reg.Free;
  end;
end;

procedure UnregisterFileType(FileType: String); //09.12.03
var
  Key: hKey;
begin
  Key := RegKeyOpenWrite(HKEY_CLASSES_ROOT, '');
  RegKeyDeleteValue(Key, '.'+FileType);
  RegCloseKey(Key);
end;

function Execute(FileName:String;Param:String='';Dir:String='';ShowMode:Integer=1):Cardinal;
begin
  Result := ShellExecute(0, 'open', PChar(FileName), PChar(Param), PChar(Dir), ShowMode);
end;

function ShellRun(FileName: String): Cardinal; //09.03.04
begin
  Result := ShellExecute(0, 'open', PChar(FileName), '', '', 1);
end;

function ShellRunEx(FileName, Param: String): Cardinal; //09.03.04
begin
  Result := ShellExecute(0, 'open', PChar(FileName), PChar(Param), '', 1);
end;

procedure ExecConsoleApp(CommandLine: AnsiString; Output: TStringList; Errors:TStringList);
var
 sa : TSECURITYATTRIBUTES;
 si : TSTARTUPINFO;
 pi : TPROCESSINFORMATION;
 hPipeOutputRead : THANDLE;
 hPipeOutputWrite : THANDLE;
 hPipeErrorsRead : THANDLE;
 hPipeErrorsWrite : THANDLE;
 Res, bTest : Boolean;
 env : array[0..100] of Char;
 szBuffer : array[0..256] of Char;
 dwNumberOfBytesRead: DWORD;
 Stream : TMemoryStream;
begin
 sa.nLength := sizeof(sa);
 sa.bInheritHandle := true;
 sa.lpSecurityDescriptor := nil;
 CreatePipe(hPipeOutputRead, hPipeOutputWrite, @sa, 0);
 CreatePipe(hPipeErrorsRead, hPipeErrorsWrite, @sa, 0);
 ZeroMemory(@env, SizeOf(env));
 ZeroMemory(@si, SizeOf(si));
 ZeroMemory(@pi, SizeOf(pi));
 si.cb := SizeOf(si);
 si.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
 si.wShowWindow := SW_HIDE;
 si.hStdInput := 0;
 si.hStdOutput := hPipeOutputWrite;
 si.hStdError := hPipeErrorsWrite;

 { Если вы хотите запустить процесс без параметров, заnil`те второй параметр
   и используйте первый
 }
 Res := CreateProcess(nil, pchar(CommandLine), nil, nil, true,
               CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, @env, nil, si, pi);

 // Если не получилось - то выходим
 if not Res then
 begin
   CloseHandle(hPipeOutputRead);
   CloseHandle(hPipeOutputWrite);
   CloseHandle(hPipeErrorsRead);
   CloseHandle(hPipeErrorsWrite);
   Exit;
 end;
 CloseHandle(hPipeOutputWrite);
 CloseHandle(hPipeErrorsWrite);
//     GetCurrentProcess
//     SetPriorityClass()
 //Читаем вывод
 Stream := TMemoryStream.Create;
 try
  while true do
  begin
   bTest := ReadFile(hPipeOutputRead, szBuffer, 256, dwNumberOfBytesRead, nil);
   if not bTest then
   begin
    break;
   end;
   Stream.Write(szBuffer, dwNumberOfBytesRead);
  end;
  Stream.Position := 0;
  Output.LoadFromStream(Stream);
 finally
  Stream.Free;
 end;

 //Вывод о ошибках
 Stream := TMemoryStream.Create;
 try
  while true do
  begin
   bTest := ReadFile(hPipeErrorsRead, szBuffer, 256, dwNumberOfBytesRead, nil);
   if not bTest then
   begin
    break;
   end;
   Stream.Write(szBuffer, dwNumberOfBytesRead);
  end;
  Stream.Position := 0;
  Errors.LoadFromStream(Stream);
 finally
  Stream.Free;
 end;

 WaitForSingleObject(pi.hProcess, INFINITE);
 CloseHandle(pi.hProcess);
 CloseHandle(hPipeOutputRead);
 CloseHandle(hPipeErrorsRead);
end;

function WinDir:String;
var
 Buf:array[0..MAX_PATH] of Char;
begin
 GetWindowsDirectory(@buf, MAX_PATH+1);
 Result := buf;
end;

function SysDir:String;
var
 Buf:array[0..MAX_PATH] of Char;
begin
 GetSystemDirectory(@buf, MAX_PATH+1);
 Result := buf;
end;

function TempDir:String;
var
 Buf:array[0..MAX_PATH] of Char;
begin
 GetTempPath(MAX_PATH+1, @buf);
 Result := buf;
end;

{$ifdef asm_ver}
function StartDir : String;
asm
  PUSH     EBX
  MOV      EBX, EAX

  XOR      EAX, EAX
  MOV      AH, 2
  SUB      ESP, EAX
  MOV      EDX, ESP
  PUSH     EAX
  PUSH     EDX
  PUSH     0
  CALL     GetModuleFileName

  LEA      EDX, [ESP + EAX]
@@1:
  DEC      EDX
  CMP      byte ptr [EDX], '\'
  JNZ      @@1

  INC      EDX
  MOV      byte ptr [EDX], 0

  MOV      EAX, EBX
  MOV      EDX, ESP
  CALL     System.@LStrFromPChar

  ADD      ESP, 200h
  POP      EBX
end;
{$else}
function StartDir : String;
var
  Buffer:array[0..260] of Char;
  I : Integer;
begin
  I := GetModuleFileName(0, Buffer, SizeOf(Buffer));
  for I := I downto 0 do
   if Buffer[ I ] = '\' then
    begin
     Buffer[ I + 1 ] := #0;
     break;
    end;
  Result := Buffer;
end;
{$endif}

function CompName : String;
var
 Size         : cardinal;
 PRes         : PChar;
begin
 Size := MAX_COMPUTERNAME_LENGTH + 1;
 GetMem(PRes, Size);
 GetComputerName(PRes, Size);
 Result := PRes;
end;

function UserName : String;
var
 Size         : cardinal;
 PRes         : PChar;
begin
 Size := MAX_COMPUTERNAME_LENGTH + 1;
 GetMem(PRes, Size);
 GetUserName(PRes, Size);
 Result := PRes;
end;

function Win32CSDVersion: String; //18.02.04
var
  OSVersionInfo: TOSVersionInfo;
begin
  OSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVersionInfo);
  if GetVersionEx(OSVersionInfo) then Result := OSVersionInfo.szCSDVersion;
end;

procedure GetWinVer; //06.09.03
var
 OSVersionInfo: TOSVersionInfo;
begin
 OSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVersionInfo);
 if GetVersionEx(OSVersionInfo) then
  with OSVersionInfo do
   begin
    Win32Platform := dwPlatformId;
    Win32MajorVersion := dwMajorVersion;
    Win32MinorVersion := dwMinorVersion;
    Win32BuildNumber := dwBuildNumber and $0000FFFF;
//    Win32CSDVersion := szCSDVersion;
   end;
end;

function Win32Type: String; //28.07.03
const                      //20.10.03
 WinName = 'Microsoft Windows';
{ Win32Types : array[1..7] of String = ('95', '95 OSR2',
  '98 SE', 'ME', 'NT', '2000', 'XP');}
begin
  if Win32Platform = 1 then
  begin  //Win9x
   Result := WinName;
   if (Win32MajorVersion = 4) and (Win32MinorVersion = 0) and (Win32BuildNumber = 1111)
    then Result := WinName + ' 95 OSR2'
    else Result := WinName + ' 95';
   if (Win32MajorVersion = 4) and (Win32MinorVersion =10) and (Win32BuildNumber <= 1998)
    then Result := WinName + ' 98';
   if (Win32MajorVersion = 4) and (Win32MinorVersion =10) and (Win32BuildNumber = 2222)
    then Result := WinName + ' 98 SE';
   if (Win32MajorVersion = 4) and (Win32MinorVersion =90)
    then Result := WinName + ' ME';
  end
 else
  begin  //WinNT
   Result := Result + ' NT';
   if (Win32MajorVersion = 5) and (Win32MinorVersion = 0)
    then Result := WinName + ' 2000';
   if (Win32MajorVersion = 5) and (Win32MinorVersion = 1)
    then Result := WinName + ' XP';
   if (Win32MajorVersion = 6) and (Win32MinorVersion = 0)
    then Result := WinName + ' Vista';
   if (Win32MajorVersion = 6) and (Win32MinorVersion = 1)
    then Result := WinName + ' 7';
   if (Win32MajorVersion = 6) and (Win32MinorVersion = 2)
    then Result := WinName + ' 8';
   if (Win32MajorVersion = 6) and (Win32MinorVersion = 3)
    then Result := WinName + ' 8.1';
  end;
  if Win32CSDVersion <> '' then Result := Result + ' ' + Win32CSDVersion ;
end;

function IsWinNT: Boolean;
begin
  GetWinVer;
  if Win32Platform = VER_PLATFORM_WIN32_NT then Result := True else Result := False;
end;

function ScreenWidth:Integer;
begin
  Result := GetSystemMetrics(SM_CXSCREEN);
end;

function ScreenHeight:Integer;
begin
  Result := GetSystemMetrics(SM_CYSCREEN);
end;

function GetPriv(PrivilegieName: String):Boolean; //01.07.03
var
  hToken: THandle;
  tkp, tkp_prev: TTokenPrivileges;
  ReturnLength: Cardinal;
begin
 result:=False;
 if OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
  begin
   LookupPrivilegeValue(nil, PChar(PrivilegieName), tkp.Privileges[0].Luid);
   tkp_prev:=tkp;   
   tkp.PrivilegeCount := 1;
   tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
   if AdjustTokenPrivileges(hToken, False, tkp, SizeOf(tkp), tkp_prev, ReturnLength) then result:=True;
  end
end;

 { Process Functions }

type
  TCreateToolhelp32Snapshot = function (dwFlags, th32ProcessID: DWORD): THandle stdcall; 

var
  KernelHandle: THandle;
  _CreateToolhelp32Snapshot: TCreateToolhelp32Snapshot;
  _Process32First: TProcess32First;
  _Process32Next: TProcess32Next;    

function InitToolHelp: Boolean;
begin
  if KernelHandle = 0 then
  begin
    KernelHandle := GetModuleHandle(kernel32);
    if KernelHandle <> 0 then
    begin
      @_CreateToolhelp32Snapshot := GetProcAddress(KernelHandle, 'CreateToolhelp32Snapshot');
{      @_Heap32ListFirst := GetProcAddress(KernelHandle, 'Heap32ListFirst');
      @_Heap32ListNext := GetProcAddress(KernelHandle, 'Heap32ListNext');
      @_Heap32First := GetProcAddress(KernelHandle, 'Heap32First');
      @_Heap32Next := GetProcAddress(KernelHandle, 'Heap32Next');
      @_Toolhelp32ReadProcessMemory := GetProcAddress(KernelHandle, 'Toolhelp32ReadProcessMemory');}
      @_Process32First := GetProcAddress(KernelHandle, 'Process32First');
      @_Process32Next := GetProcAddress(KernelHandle, 'Process32Next');
{      @_Process32FirstW := GetProcAddress(KernelHandle, 'Process32FirstW');
      @_Process32NextW := GetProcAddress(KernelHandle, 'Process32NextW');
      @_Thread32First := GetProcAddress(KernelHandle, 'Thread32First');
      @_Thread32Next := GetProcAddress(KernelHandle, 'Thread32Next');
      @_Module32First := GetProcAddress(KernelHandle, 'Module32First');
      @_Module32Next := GetProcAddress(KernelHandle, 'Module32Next');
      @_Module32FirstW := GetProcAddress(KernelHandle, 'Module32FirstW');
      @_Module32NextW := GetProcAddress(KernelHandle, 'Module32NextW'); }
    end;
  end;
  Result := (KernelHandle <> 0) and Assigned(_CreateToolhelp32Snapshot);
end;

function Process32First;
begin
  if InitToolHelp then
    Result := _Process32First(hSnapshot, lppe)
  else Result := False;
end;

function Process32Next;
begin
  if InitToolHelp then
    Result := _Process32Next(hSnapshot, lppe)
  else Result := False;
end;

function CreateToolhelp32Snapshot(dwFlags, th32ProcessID: DWORD): THandle;
begin
  if InitToolHelp then
    Result := _CreateToolhelp32Snapshot(dwFlags, th32ProcessID)
  else Result := 0;
end;

function KillProcess(ExeFileName: string):integer;
const
  PROCESS_TERMINATE=$0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while integer(ContinueLoop) <> 0 do
   begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ExeFileName))
     or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0),
                        FProcessEntry32.th32ProcessID), 0));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
   end;
  CloseHandle(FSnapshotHandle);
end;

function GetProcessCount(ProcName: String): Integer;
const
  PROCESS_TERMINATE=$0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while integer(ContinueLoop) <> 0 do
   begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ProcName))
     or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ProcName))) then
      Inc(Result);
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
   end;
  CloseHandle(FSnapshotHandle);
end;

function GetProcessId(ProcName: String): Integer;
const
  PROCESS_TERMINATE=$0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while integer(ContinueLoop) <> 0 do
   begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ProcName))
        or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ProcName))) then
     begin
      Result := FProcessEntry32.th32ProcessID;
      Exit;
     end
    else
     ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
   end;
  CloseHandle(FSnapshotHandle);
end;

const
  LOGON_WITH_PROFILE         = $1;
  LOGON_NETCREDENTIALS_ONLY  = $2;

function CreateProcessWithLogonW(UserName, Domain, Password: PWideChar; dwLogonFlags: DWORD; lpApplicationName, lpCommandLine: PWideChar; dwCreationFlags: DWORD; lpEnvironment: Pointer; lpCurrentDirectory: PWideChar; const lpStartupInfo: TStartupInfo; var lpProcessInformation: TProcessInformation): BOOL; stdcall; external advapi32 name 'CreateProcessWithLogonW';
function StartProcessWithLogon(const  strUsername, strDomain, strPassword, strCommandLine: WideString): Boolean; //30.11.03
var
  pi: TProcessInformation;
  si:TStartupInfo;
//  St: string;
begin
//  Result := False;

  ZeroMemory(@si,sizeof(TSTARTUPINFO));
  si.cb:= sizeof(TSTARTUPINFO);
  si.lpDesktop:=nil;

  Result := CreateProcessWithLogonW(PWideChar(strUsername), PWideChar(strDomain), PWideChar(strPassword), LOGON_WITH_PROFILE, PWideChar(strCommandLine), nil, 0, nil, nil, si, pi);
  if not Result then
   begin
//    St := SysErrorMessage(Windows.GetLastError);
//    MessageBox(0, PAnsiChar(St), 'Ошибка!', MB_OK or MB_ICONERROR)
   end
  else
   begin
    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
   end;
end;

function GetBiosDate:String;
var
  Key:hKey;
  s : string[255];
  p : pointer;
begin
  GetWinVer ;
  if Win32Platform = 2 then
   begin
    key:=RegKeyOpenRead(HKEY_LOCAL_MACHINE,'HARDWARE\DESCRIPTION\System');
    Result := RegKeyGetStr(key,'SystemBiosDate')
   end
  else
   try
    s[0] := #8;
    p := Pointer($0FFFF5);
    Move(p^,s[1],8);
    Result := copy(s,1,2) + '/' + copy(s,4,2) + '/' +copy (s,7,2);
   except
    Result := 'XX.XX.XXXX';
   end;
end;

function GetCPUFreq:Integer;
const
  DelayTime = 50;
  NT = 4;
var
  i,j : integer;
  x,dx, TimerHi, TimerLo: DWORD;
  PriorityClass, Priority: Integer;
  t : array [1..NT] of DWORD;
begin
 j:=0;
  PriorityClass := GetPriorityClass(GetCurrentProcess);
  Priority := GetThreadPriority(GetCurrentThread);

  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);

  Sleep(10);
  for i := 1 to NT do
  begin
    asm
      dw  310Fh // rdtsc
      mov TimerLo, eax
      mov TimerHi, edx
    end;
    Sleep(DelayTime);
    asm
      dw  310Fh // rdtsc
      sub eax, TimerLo
      sbb edx, TimerHi
      mov TimerLo, eax
      mov TimerHi, edx
    end;
    t[i] := TimerLo;
  end;
  SetThreadPriority(GetCurrentThread, Priority);
  SetPriorityClass(GetCurrentProcess, PriorityClass);

  TimerLo := 0;
  for i := 1 to NT do TimerLo := TimerLo + t[i];
    TimerLo := Round(TimerLo / 4);

  dx := $FFFFFFFF;
  for i := 1 to NT do
  begin
    x := (t[i] - TimerLo)*(t[i] - TimerLo);
    if x < dx then
    begin
      dx := x;
      j := i;
    end;
  end;

  Result := Trunc(t[j] / (1000 * DelayTime));
end;

function ProcessorSpeed: Extended;
var
  key:hKey;
begin
  result:=-1;
  try
   if Win32Platform = 2 then
    begin
     key:=RegKeyOpenRead(HKEY_LOCAL_MACHINE,'HARDWARE\DESCRIPTION\System\CentralProcessor\0');
     Result := RegKeyGetInt(key, '~MHz');
     RegCloseKey(key);
    end
   else Result := GetCPUFreq;
  except
  end;
end;

//Memory

function AllocMem(Size: Cardinal): Pointer;
begin
  GetMem(Result, Size);
  FillChar(Result^, Size, 0);
end;

function MemTotalPhys : Integer;
var
  lpMemoryStatus:TMemoryStatus;
begin
  lpMemoryStatus.dwLength := SizeOf(lpMemoryStatus);
  GlobalMemoryStatus(lpMemoryStatus);
  Result := lpMemoryStatus.dwTotalPhys;
end;

function MemAvailPhys : Integer;
var
  lpMemoryStatus:TMemoryStatus;
begin
  lpMemoryStatus.dwLength := SizeOf(lpMemoryStatus);
  GlobalMemoryStatus(lpMemoryStatus);
  Result := lpMemoryStatus.dwAvailPhys;
end;

function MemTotalPageFile : Integer;
var
  lpMemoryStatus:TMemoryStatus;
begin
  lpMemoryStatus.dwLength := SizeOf(lpMemoryStatus);
  GlobalMemoryStatus(lpMemoryStatus);
  Result := lpMemoryStatus.dwTotalPageFile;
end;

function MemAvailPageFile : Integer;
var
  lpMemoryStatus:TMemoryStatus;
begin
  lpMemoryStatus.dwLength := SizeOf(lpMemoryStatus);
  GlobalMemoryStatus(lpMemoryStatus);
  Result := lpMemoryStatus.dwAvailPageFile ;
end;

function MemMemoryLoad : Integer;
var
  lpMemoryStatus:TMemoryStatus;
begin
  lpMemoryStatus.dwLength := SizeOf(lpMemoryStatus);
  GlobalMemoryStatus(lpMemoryStatus);
  Result := lpMemoryStatus.dwMemoryLoad;
end;

//ExitWindows
function LogOff : Boolean;
begin
  Result := ExitWindowsEx(EWX_LOGOFF+EWX_FORCE, 0);
end;

function PowerOff : Boolean;
begin
  Result := ExitWindowsEx(EWX_POWEROFF+EWX_FORCE, 0);
end;

function Reboot : Boolean;
begin
  Result := ExitWindowsEx(EWX_REBOOT+EWX_FORCE, 0);
end;

function ShutDwn : Boolean;
begin
  Result := ExitWindowsEx(EWX_SHUTDOWN+EWX_FORCE, 0);
end;

//ClipBoard
function GetClipboardText: String;
var
  gbl: THandle;
  str: PChar;
begin
  Result := '';
  if OpenClipboard(0) then
   begin
    if IsClipboardFormatAvailable(CF_TEXT) then
     begin
      gbl := GetClipboardData(CF_TEXT);
      if gbl <> 0 then
       begin
        str := GlobalLock(gbl);
        if str <> nil then
         begin
          Result := str;
          GlobalUnlock(gbl);
         end;
       end;
     end;
    CloseClipboard;
   end;
end;

function SetClipboardText(const S:String): Boolean;
var
  gbl: THandle;
  str: PChar;
begin
  Result := False;
  if not OpenClipboard(0) then Exit;
  EmptyClipboard;
  if S <> '' then
   begin
    gbl := GlobalAlloc(GMEM_DDESHARE, Length(S) + 1);
    if gbl <> 0 then
     begin
      str := GlobalLock(gbl);
      Move(S[1], str^, Length(S) + 1);
      GlobalUnlock( gbl );
      Result := SetClipboardData(CF_TEXT, gbl) <> 0;
     end;
   end
  else
   Result := True;
  CloseClipboard;
end;

procedure ClipboardClear; //18.03.03
begin
  SetClipboardText('');
end;

function RegisteredOwner: String; //18.03.03
var
  key:hKey;
begin
  GetWinVer ;
  if Win32Platform = 1 then
    key:=RegKeyOpenRead(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion')
  else
    key:=RegKeyOpenRead(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows NT\CurrentVersion');
  Result := RegKeyGetStr(key,'RegisteredOwner');
  RegCloseKey(key);
end;

function RegisteredCompany: String; //18.03.03
var
  key : hKey;
begin
  GetWinVer ;
  if Win32Platform = 1 then
    key:=RegKeyOpenRead(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion')
  else
    key:=RegKeyOpenRead(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows NT\CurrentVersion');
  Result := RegKeyGetStr(key,'RegisteredOrganization');
  RegCloseKey(key);
end;

//---------------------------- Math --------------------------//

function Min(X, Y:Integer): Integer;
asm
  CMP EAX, EDX
  JLE @@exit
  MOV EAX, EDX
@@exit:
end;

function Max(X, Y: Integer): Integer;
asm
  CMP EAX, EDX
  JGE @@exit
  MOV EAX, EDX
@@exit:
end;

//-------------------------- Strings -------------------------//

function Code(x:String; y:Byte):String;
var
  j:Integer;
begin
  Result := '';
  for j:=1 to Length(x) do
    Result := Result + IntToHex(Ord(x[j]) xor y, 2);
end;

function DeCode(x:String; y:Byte):String;
var
  j:Integer;
begin
  Result := '';
  for j:=1 to Length(x) do
   if j mod 2<>0 then
     Result := Result + Chr(HexToInt(Copy(x,j,2)) xor y);
end;

function AnsiLastChar(const S: string): PChar;
var
  LastByte: Integer;
begin
  LastByte := Length(S);
  if LastByte <> 0 then
  begin
    Result := @S[LastByte];
    if ByteType(S, LastByte) = mbTrailByte then Dec(Result);
  end
  else
    Result := nil;
end;

function LastDelimiter(const Delimiters, S: String): Integer; //07.10.03
var
  n: LongWord;
begin
  Result := Length(S);
  for n := Result downto 1 do
   if S[n] = Delimiters then
    begin
     Result := n;
     Exit;
    end;
end;

{function LastDelimiter(const Delimiters, S: string): Integer;
var
  P: PChar;
begin
  Result := Length(S);
  P := PChar(Delimiters);
  while Result > 0 do
  begin
    if (S[Result] <> #0) and (StrScan(P, S[Result]) <> nil) then
      if (ByteType(S, Result) = mbTrailByte) then
        Dec(Result)
      else
        Exit;
    Dec(Result);
  end;
end;}
      
function ExtractFilePath(const FileName: shortstring): shortstring;
var
  I: Integer;
begin
  I := Length(FileName);
  while (I > 1) and not (FileName[I] in ['\', '/', ':']) do Dec(I);
  if FileName[I] in ['\', '/', ':']
    then Result := Copy(FileName, 1, I)
    else Result:='';
  if Result[0] > #0 then
    if Result[Ord(Result[0])] = #0 then Dec(Result[0]);
end;

function ExtractFileDir(const FileName: shortstring): shortstring;
var
  I: Integer;
begin
  I := Length(FileName);
  while (I > 2) and not (FileName[I] in ['\', '/', ':']) do Dec(I);
  if (I > 2) and (FileName[I] in ['\', '/']) and
    not (FileName[I - 1] in ['\', '/', ':']) then Dec(I);
  Result := Copy(FileName, 1, I);
  if Result[0] > #0 then
    if Result[Ord(Result[0])] = #0 then Dec(Result[0]);
end;

function ExtractFileDrive(const FileName: shortstring): shortstring;
var
 I: Integer;
begin
 for i:=1 to Length(FileName) do
  if FileName[i]=':' then Result:=Copy(FileName,1, i);
end;

function ExtractFileName(const FileName: String): shortstring;
var
  I: Integer;
begin
  I := Length(FileName);
  while (I >= 1) and not (FileName[I] in ['\', '/', ':']) do Dec(I);
  Result := Copy(FileName, I + 1, 255);
  if Result[0] > #0 then
    if Result[Ord(Result[0])] = #0 then Dec(Result[0]);
end;

function ExtractFileExt(const FileName: shortstring): shortstring;
var
  I: Integer;
begin
  I := Length(FileName);
  while (I > 1) and not (FileName[I] in ['.', '\', '/', ':']) do Dec(I);
  if (I > 1) and (FileName[I] = '.') then
    Result := Copy(FileName, I, 255) else
    Result := '';
  if Result[0] > #0 then
    if Result[Ord(Result[0])] = #0 then Dec(Result[0]);
end;

function ExtractFileNoExt(const FileName: string): String; //11.12.04
begin
  Result := Copy(FileName, 1, Length(FileName) -
     Length(ExtractFileExt(FileName)));
end;

function ExpandFileName(const FileName: string): string; //27.12.03
var
  FName: PChar;
  Buffer: array[0..MAX_PATH - 1] of Char;
begin
  SetString(Result, Buffer, GetFullPathName(PChar(FileName), SizeOf(Buffer),
    Buffer, FName));
end;

function ExtractShortPathName(const FileName: string): string;
var
  Buffer: array[0..MAX_PATH - 1] of Char;
begin
  SetString(Result, Buffer,
    GetShortPathName(PChar(FileName), Buffer, SizeOf(Buffer)));
end;

{ PChar routines }

function StrLen(const Str: PChar): Cardinal; assembler;
asm
        MOV     EDX,EDI
        MOV     EDI,EAX
        MOV     ECX,0FFFFFFFFH
        XOR     AL,AL
        REPNE   SCASB
        MOV     EAX,0FFFFFFFEH
        SUB     EAX,ECX
        MOV     EDI,EDX
end;

function StrEnd(const Str: PChar): PChar; assembler;
asm
        MOV     EDX,EDI
        MOV     EDI,EAX
        MOV     ECX,0FFFFFFFFH
        XOR     AL,AL
        REPNE   SCASB
        LEA     EAX,[EDI-1]
        MOV     EDI,EDX
end;

function StrMove(Dest: PChar; const Source: PChar; Count: Cardinal): PChar; assembler;
asm
        PUSH    ESI
        PUSH    EDI
        MOV     ESI,EDX
        MOV     EDI,EAX
        MOV     EDX,ECX
        CMP     EDI,ESI
        JA      @@1
        JE      @@2
        SHR     ECX,2
        REP     MOVSD
        MOV     ECX,EDX
        AND     ECX,3
        REP     MOVSB
        JMP     @@2
@@1:    LEA     ESI,[ESI+ECX-1]
        LEA     EDI,[EDI+ECX-1]
        AND     ECX,3
        STD
        REP     MOVSB
        SUB     ESI,3
        SUB     EDI,3
        MOV     ECX,EDX
        SHR     ECX,2
        REP     MOVSD
        CLD
@@2:    POP     EDI
        POP     ESI
end;

function StrCopy( Dest, Source: PChar ): PChar; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        MOV     ESI,EAX
        MOV     EDI,EDX
        OR      ECX, -1
        XOR     AL,AL
        REPNE   SCASB
        NOT     ECX
        MOV     EDI,ESI
        MOV     ESI,EDX
        MOV     EDX,ECX
        MOV     EAX,EDI
        SHR     ECX,2
        REP     MOVSD
        MOV     ECX,EDX
        AND     ECX,3
        REP     MOVSB
        POP     ESI
        POP     EDI
end;

function StrLCopy(Dest: PChar; const Source: PChar; MaxLen: Cardinal): PChar; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EBX,ECX
        XOR     AL,AL
        TEST    ECX,ECX
        JZ      @@1
        REPNE   SCASB
        JNE     @@1
        INC     ECX
@@1:    SUB     EBX,ECX
        MOV     EDI,ESI
        MOV     ESI,EDX
        MOV     EDX,EDI
        MOV     ECX,EBX
        SHR     ECX,2
        REP     MOVSD
        MOV     ECX,EBX
        AND     ECX,3
        REP     MOVSB
        STOSB
        MOV     EAX,EDX
        POP     EBX
        POP     ESI
        POP     EDI
end;

function StrPCopy(Dest: PChar; const Source: string): PChar;
begin
  Result := StrLCopy(Dest, PChar(Source), Length(Source));
end;

function StrPLCopy(Dest: PChar; const Source: string; MaxLen: Cardinal): PChar;
begin
  Result := StrLCopy(Dest, PChar(Source), MaxLen);
end;

function StrCat(Dest: PChar; const Source: PChar): PChar; //22.02.04
begin
  StrCopy(StrEnd(Dest), Source);
  Result := Dest;
end;

function StrScan(const Str: PChar; Chr: Char): PChar; assembler; //05.04.03
asm
        PUSH    EDI
        PUSH    EAX
        MOV     EDI,Str
        MOV     ECX,0FFFFFFFFH
        XOR     AL,AL
        REPNE   SCASB
        NOT     ECX
        POP     EDI
        MOV     AL,Chr
        REPNE   SCASB
        MOV     EAX,0
        JNE     @@1
        MOV     EAX,EDI
        DEC     EAX
@@1:    POP     EDI
end;

function StrPos(const Str1, Str2: PChar): PChar; assembler; //15.02.03
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        OR      EAX,EAX
        JE      @@2
        OR      EDX,EDX
        JE      @@2
        MOV     EBX,EAX
        MOV     EDI,EDX
        XOR     AL,AL
        MOV     ECX,0FFFFFFFFH
        REPNE   SCASB
        NOT     ECX
        DEC     ECX
        JE      @@2
        MOV     ESI,ECX
        MOV     EDI,EBX
        MOV     ECX,0FFFFFFFFH
        REPNE   SCASB
        NOT     ECX
        SUB     ECX,ESI
        JBE     @@2
        MOV     EDI,EBX
        LEA     EBX,[ESI-1]
@@1:    MOV     ESI,EDX
        LODSB
        REPNE   SCASB
        JNE     @@2
        MOV     EAX,ECX
        PUSH    EDI
        MOV     ECX,EBX
        REPE    CMPSB
        POP     EDI
        MOV     ECX,EAX
        JNE     @@1
        LEA     EAX,[EDI-1]
        JMP     @@3
@@2:    XOR     EAX,EAX
@@3:    POP     EBX
        POP     ESI
        POP     EDI
end;

function StrComp(const Str1, Str2: PChar): Integer; //01.04.03
asm
        PUSH    EDI
        PUSH    ESI
        MOV     EDI,EDX
        MOV     ESI,EAX
        MOV     ECX,0FFFFFFFFH
        XOR     EAX,EAX
        REPNE   SCASB
        NOT     ECX
        MOV     EDI,EDX
        XOR     EDX,EDX
        REPE    CMPSB
        MOV     AL,[ESI-1]
        MOV     DL,[EDI-1]
        SUB     EAX,EDX
        POP     ESI
        POP     EDI
end;

function StrLComp(const Str1, Str2: PChar; MaxLen: Cardinal): Integer; //01.04.03
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        MOV     EDI,EDX
        MOV     ESI,EAX
        MOV     EBX,ECX
        XOR     EAX,EAX
        OR      ECX,ECX
        JE      @@1
        REPNE   SCASB
        SUB     EBX,ECX
        MOV     ECX,EBX
        MOV     EDI,EDX
        XOR     EDX,EDX
        REPE    CMPSB
        MOV     AL,[ESI-1]
        MOV     DL,[EDI-1]
        SUB     EAX,EDX
@@1:    POP     EBX
        POP     ESI
        POP     EDI
end;

function StrLIComp(const Str1, Str2: PChar; MaxLen: Cardinal): Integer; //06.04.03
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        MOV     EDI,EDX
        MOV     ESI,EAX
        MOV     EBX,ECX
        XOR     EAX,EAX
        OR      ECX,ECX
        JE      @@4
        REPNE   SCASB
        SUB     EBX,ECX
        MOV     ECX,EBX
        MOV     EDI,EDX
        XOR     EDX,EDX
@@1:    REPE    CMPSB
        JE      @@4
        MOV     AL,[ESI-1]
        CMP     AL,'a'
        JB      @@2
        CMP     AL,'z'
        JA      @@2
        SUB     AL,20H
@@2:    MOV     DL,[EDI-1]
        CMP     DL,'a'
        JB      @@3
        CMP     DL,'z'
        JA      @@3
        SUB     DL,20H
@@3:    SUB     EAX,EDX
        JE      @@1
@@4:    POP     EBX
        POP     ESI
        POP     EDI
end;

//---------

function AnsiStrScan(Str: PChar; Chr: Char): PChar;
begin
  Result := StrScan(Str, Chr);
  while Result <> nil do
  begin
    case StrByteType(Str, Integer(Result-Str)) of
      mbSingleByte: Exit;
      mbLeadByte: Inc(Result);
    end;
    Inc(Result);
    Result := StrScan(Result, Chr);
  end;
end;

function AnsiStrRScan(Str: PChar; Chr: Char): PChar;
begin
  Str := AnsiStrScan(Str, Chr);
  Result := Str;
  if Chr <> #$0 then
  begin
    while Str <> nil do
    begin
      Result := Str;
      Inc(Str);
      Str := AnsiStrScan(Str, Chr);
    end;
  end
end;

//convert

function HexToInt(Value:String):Integer;
var
 I : Integer;
begin
  Result := 0;
  i := 1;
  if Value = '' then Exit;
  if Value[1] = '$' then Inc(I);
  while i <= Length( Value ) do
  begin
    if Value[i] in ['0'..'9'] then
     Result := (Result shl 4) or (Ord(Value[I]) - Ord('0'))
    else
     if Value[i] in ['A'..'F'] then
      Result := (Result shl 4) or (Ord(Value[I]) - Ord('A') + 10)
     else
      if Value[i] in ['a'..'f'] then
       Result := (Result shl 4) or (Ord(Value[I]) - Ord('a') + 10)
      else
       Break;
    Inc(i);
  end;
end;

function IntToHex(Value, Digits:Integer):String;
var Buf: array[ 0..8 ] of Char;
    Dest : PChar;

function HexDigit( B : Byte ) : Char;
asm
 CMP  AL,9
 JA   @@1
 ADD  AL,30h-41h+0Ah
@@1:
 ADD  AL,41h-0Ah
end;

begin
  Dest := @Buf[8];
  Dest^ := #0;
  repeat
    Dec(Dest);
    Dest^ := '0';
    if Value <> 0 then
    begin
      Dest^ := HexDigit(Value and $F);
      Value := Value shr 4;
    end;
    Dec(Digits);
  until (Value = 0) and (Digits <= 0);
  Result := Dest;
end;

function IntToBin(Value: integer; Digits: integer): string;
var
 i: integer;
begin
 result := '';
 for i := 0 to Digits - 1 do
  if Value and (1 shl i) > 0 then
   result := '1' + result
  else
   result := '0' + result;     
end;

function StrUpper(Str: PChar): PChar; assembler; //01.04.04
asm
        PUSH    ESI
        MOV     ESI,Str
        MOV     EDX,Str
@@1:    LODSB
        OR      AL,AL
        JE      @@2
        CMP     AL,'a'
        JB      @@1
        CMP     AL,'z'
        JA      @@1
        SUB     AL,20H
        MOV     [ESI-1],AL
        JMP     @@1
@@2:    XCHG    EAX,EDX
        POP     ESI
end;

function StrLower(Str: PChar): PChar; assembler; //01.04.04
asm
        PUSH    ESI
        MOV     ESI,Str
        MOV     EDX,Str
@@1:    LODSB
        OR      AL,AL
        JE      @@2
        CMP     AL,'A'
        JB      @@1
        CMP     AL,'Z'
        JA      @@1
        ADD     AL,20H
        MOV     [ESI-1],AL
        JMP     @@1
@@2:    XCHG    EAX,EDX
        POP     ESI
end;

function StrPas(const Str: PChar): string;
begin
  Result := Str;
end;

function StrAlloc(Size: Cardinal): PChar; //27.12.03
begin
  Inc(Size, SizeOf(Cardinal));
  GetMem(Result, Size);
  Cardinal(Pointer(Result)^) := Size;
  Inc(Result, SizeOf(Cardinal));
end;

function StrNew(const Str: PChar): PChar; //27.12.03
var
  Size: Cardinal;
begin
  if Str = nil then Result := nil else
  begin
    Size := StrLen(Str) + 1;
    Result := StrMove(StrAlloc(Size), Str, Size);
  end;
end;

procedure StrDispose(Str: PChar); //03.04.04
begin
  if Str <> nil then
  begin
    Dec(Str, SizeOf(Cardinal));
    FreeMem(Str, Cardinal(Pointer(Str)^));
  end;
end;

{$ifdef asm_ver}
function IntToStr(Value: Integer): String;
asm
        XOR       ECX, ECX
        PUSH      ECX
        ADD       ESP, -0Ch

        PUSH      EBX
        LEA       EBX, [ESP + 15 + 4]
        PUSH      EDX
        CMP       EAX, ECX
        PUSHFD
        JGE       @@1
        NEG       EAX
@@1:
        MOV       CL, 10

@@2:
        DEC       EBX
        CDQ
        IDIV      ECX
        ADD       DL, 30h
        MOV       [EBX], DL
        TEST      EAX, EAX
        JNZ       @@2

        POPFD
        JGE       @@3

        DEC       EBX
        MOV       byte ptr [EBX], '-'
@@3:
        POP       EAX
        MOV       EDX, EBX
        CALL      System.@LStrFromPChar

        POP       EBX
        ADD       ESP, 10h
end;
{$else}
function IntToStr(Value: Integer): String;
var
  Buf : array[0..15] of Char;
  Dst : PChar;
  Minus : Boolean;
begin
  Dst := @Buf[15];
  Dst^ := #0;
  Minus := False;
  if Value < 0 then
   begin
    Value := -Value;
    Minus := True;
   end;
  repeat
    Dec(Dst);
    Dst^ := Char( Value mod 10 + Byte('0') );
    Value := Value div 10;
  until Value = 0;
  if Minus then
   begin
    Dec(Dst);
    Dst^ := '-';
   end;
  Result := Dst;
end;
{$endif}

function IntToStrEx(Value: Integer): string; //29.11.03
begin
  FmtStr(Result, '%d', [Value]);
end;

(*{$ifdef asm_ver}
function Int64ToStr(Value : Int64): String; //20.03.03
asm
        XOR       ECX, ECX
        PUSH      ECX
        ADD       ESP, -0Ch

        PUSH      EBX
        LEA       EBX, [ESP + 15 + 4]
        PUSH      EDX
        CMP       EAX, ECX
        PUSHFD
        JGE       @@1
        NEG       EAX
@@1:
        MOV       CL, 10

@@2:
        DEC       EBX
        CDQ
        IDIV      ECX
        ADD       DL, 30h
        MOV       [EBX], DL
        TEST      EAX, EAX
        JNZ       @@2

        POPFD
        JGE       @@3

        DEC       EBX
        MOV       byte ptr [EBX], '-'
@@3:
        POP       EAX
        MOV       EDX, EBX
        CALL      System.@LStrFromPChar

        POP       EBX
        ADD       ESP, 10h
end;
{$else} *)
function Int64ToStr(Value : Int64): String;
var Buf : array[0..15] of Char;
    Dst : PChar;
    Minus : Boolean;
begin
  Dst := @Buf[15];
  Dst^ := #0;
  Minus := False;
  if Value < 0 then
  begin
    Value := -Value;
    Minus := True;
  end;
  repeat
    Dec(Dst);
    Dst^ := Char(Value mod 10 + Byte('0'));
    Value := Value div 10;
  until Value = 0;
  if Minus then
  begin
    Dec(Dst);
    Dst^ := '-';
  end;
  Result := Dst;
end;
//{$endif}

(*{$ifdef asm_ver}
function StrToInt(Value: string): Integer; //20.03.03
asm
        XCHG     EDX, EAX
        XOR      EAX, EAX
        TEST     EDX, EDX
        JZ       @@exit

        XOR      ECX, ECX
        MOV      CL, [EDX]
        INC      EDX
        CMP      CL, '-'
        PUSHFD
        JE       @@0
@@1:    CMP      CL, '+'
        JNE      @@2
@@0:    MOV      CL, [EDX]
        INC      EDX
@@2:    SUB      CL, '0'
        CMP      CL, '9'-'0'
        JA       @@fin
        LEA      EAX, [EAX+EAX*4] //
        LEA      EAX, [ECX+EAX*2] //
        JMP      @@0
@@fin:  POPFD
        JNE      @@exit
        NEG      EAX
@@exit:
end;
{$else} *)
function StrToInt(Value: string): Integer;
var
  Res: Integer;
 {M: Integer;
 s: PChar; }
begin
 Val(Value, Result, Res);
 {s:=PChar(Value);
 Result := 0;
 if S = '' then Exit;
 M := 1;
 if S^ = '-' then
  begin
   M := -1;
   Inc( S );
  end
 else
  if S^ = '+' then Inc(S);
 while S^ in ['0'..'9'] do
  begin
   Result := Result * 10 + Integer(S^) - Integer('0');
   Inc(S);
  end;
 if M < 0 then Result := -Result;}
end;
//{$endif}

function StrToIntEx(const S: string): Integer;
var
  E: Integer;
begin
  Val(S, Result, E);
end;

function StrToIntDef(s : string; Default: Integer) : integer;
var j : integer;
begin
  Val(s,Result,j);
  if j > 0 then Result := Default;
end;

function ByteToHex(Int: Byte): String; //22.09.03
const
  HexChars: array[0..$F] of Char = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
begin
  Result := HexChars[(Int shr 4) and $F] + HexChars[Int and $F];
end;

function StrToHex(const Value: String): String; //22.09.03
var
  i: Word;
begin
  Result := '';
  for i := 1 to Length(Value) do
    Result := Result + ByteToHex(Ord(Value[i])) + ' ';
  if Length(Result) > 0 then Delete(Result, Length(Result), 1);
end;

{function StrToHex(const Value: String): String;
var
  i: Word;
begin
  Result := '';
  for i := 1 to Length(Value) do
    Result := Result + ' ' + ByteToHex(Ord(Value[i]));
end;}

function PassToHex(const Value: String): String; //18.10.03
begin
  if Value <> '' then
   Result := Value + ' (in hex: ' + StrToHex(Value) + ')';
end;

function FloatToStr(m: Real):string;
begin
  Str(m{:4:1}, Result);
end;

Function StrToFloat(s:String):real;
var
   code:integer;
begin
  Val(S, Result, Code);
  if code>0 then Result:=0;
end;

{$ifdef asm_ver}
procedure Swap(var x1, x2:String);
asm
  MOV  ECX, [EDX]
  XCHG ECX, [EAX]
  MOV  [EDX], ECX
end;
{$else}
procedure Swap(var x1, x2:String);
var
  tmp:String;
begin
  tmp:=x2;
  x2:=x1;
  x1:=tmp;
end;
{$endif}

{ Point and rectangle constructors }

{$ifdef asm_ver}
function Point(AX, AY: Integer): TPoint; //20.03.03
asm
  MOV ECX, @Result
  MOV [ECX].TPoint.x, EAX
  MOV [ECX].TPoint.y, EDX
end;
{$else}
function Point(AX, AY: Integer): TPoint; //20.03.03
begin
  with Result do
  begin
    X := AX;
    Y := AY;
  end;
end;
{$endif}

{$ifdef asm_ver}
function SmallPoint(AX, AY: SmallInt): TSmallPoint; //20.03.03
asm
  MOV ECX, @Result
  MOV [ECX].TPoint.x, EAX
  MOV [ECX].TPoint.y, EDX
end;
{$else}
function SmallPoint(AX, AY: SmallInt): TSmallPoint; //20.03.03
begin
  with Result do
  begin
    X := AX;
    Y := AY;
  end;
end;
{$endif}

(*{$ifdef asm_ver}
function Rect(ALeft, ATop, ARight, ABottom: Integer): TRect; //20.03.03
asm
  PUSH ESI
  PUSH EDI

  MOV EDI, @Result
  LEA ESI, [Left]

  MOVSD
  MOVSD
  MOVSD
  MOVSD

  POP EDI
  POP ESI
end;
{$else} *)
function Rect(ALeft, ATop, ARight, ABottom: Integer): TRect; //20.03.03
begin
  with Result do
  begin
    Left := ALeft;
    Top := ATop;
    Right := ARight;
    Bottom := ABottom;
  end;
end;
//{$endif}

function Bounds(ALeft, ATop, AWidth, AHeight: Integer): TRect; //20.03.03
begin
  with Result do
  begin
    Left := ALeft;
    Top := ATop;
    Right := ALeft + AWidth;
    Bottom :=  ATop + AHeight;
  end;
end;

function Left(Str: String; Count: Integer): String;
begin
  Result := Copy(Str, 1, Count);
end;

function Right(Str: String; Count: Integer): String;
begin
  Result := Copy(Str, Length(Str)-Count+1, Length(Str));
end;

function Mid(Str: String; Start, Count: Integer): String;
begin
  Result := Copy(Str, Start, Count);
end;

function Len(Str: String): Integer;
begin
  Result := Length(Str);
end;

function Trim(const S: string): string;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do Inc(I);
  if I > L then Result := '' else
  begin
    while S[L] <= ' ' do Dec(L);
    Result := Copy(S, I, L - I + 1);
  end;
end;

function TrimLeft(const S: string): string;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do Inc(I);
  Result := Copy(S, I, Maxint);
end;

function TrimRight(const S: string): string;
var
  I: Integer;
begin
  I := Length(S);
  while (I > 0) and (S[I] <= ' ') do Dec(I);
  Result := Copy(S, 1, I);
end;

function WordStrCount(Str:String; Sep:Char):Integer;
var
 i:Integer;
begin
 Result := 0;
 for i:=1 to Length(str) do
  if ((str[i]<>Sep) and (str[i]<>' ')) and
    ((str[i-1]=Sep) or (str[i-1]=' ') or (i=1)) then Inc(Result);
end;

function WordStrItem(Str:String; Sep:Char;Index:Integer):String;
var
 i,j,jj:Integer;
begin
 Result := '';
 j:=0;
 jj:=0;
 for i:=1 to Length(str) do
   if ((str[i]<>Sep) and (str[i]<>' ')) and
     ((str[i-1]=Sep) or (str[i-1]=' ') or (i=1)) then
    begin
     Inc(j);
     if j=Index then jj:=i;
     if j=Index+1 then
      begin
       Result := Copy(str, jj, i-jj);
       while Pos(' ', Result)<>0 do Delete(Result, Pos(' ', Result), 1);
       while Pos(Sep, Result)<>0 do Delete(Result, Pos(Sep, Result), 1);
       Exit;
      end;
    end;
end;

function UpperCase(const s:string):string;
var
 i: integer;
begin
 result := s;
 for i := 1 to length(result) do
  if (result[i] in ['a'..'z', 'а'..'я']) then Dec(Result[i],32);
end;  

function LowerCase(const S:String):String;
var
 i:Integer;
begin
 Result := S;
 for i := 1 to Length(S) do
  if (Result[i] in ['A'..'Z', 'А'..'Я']) then Inc(Result[i],32);
end;

function AnsiLowerCase(const S: string): string;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then CharLowerBuff(Pointer(Result), Len);
end;

function AnsiUpperCase(const S: string): string;  //15.02.03
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then CharUpperBuff(Pointer(Result), Len);
end;

function AnsiCompareStr(const S1, S2: string): Integer; //19.03.03
begin
  Result := CompareString(LOCALE_USER_DEFAULT, 0, PChar(S1), -1, PChar(S2), -1) - 2;
end;

function AnsiCompareStrNoCase(const S1, S2: string): Integer; //10.03.03
begin
  Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar(S1), -1, PChar(S2), -1) - 2;
end;

function AnsiCompareText(const S1, S2: string): Integer; //15.02.03
begin
  Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar(S1), Length(S1), PChar(S2), Length(S2)) - 2;
end;

{ MBCS functions }

function ByteTypeTest(P: PChar; Index: Integer): TMbcsByteType; //15.02.03
var
  I: Integer;
begin
  Result := mbSingleByte;
  if (P = nil) or (P[Index] = #$0) then Exit;
  if (Index = 0) then
  begin
    if P[0] in LeadBytes then Result := mbLeadByte;
  end
  else
  begin
    I := Index - 1;
    while (I >= 0) and (P[I] in LeadBytes) do Dec(I);
    if ((Index - I) mod 2) = 0 then Result := mbTrailByte
    else if P[Index] in LeadBytes then Result := mbLeadByte;
  end;
end;

function ByteType(const S: string; Index: Integer): TMbcsByteType; //05.04.03
begin
  Result := mbSingleByte;
  if SysLocaleFarEast then
    Result := ByteTypeTest(PChar(S), Index-1);
end;

function StrByteType(Str: PChar; Index: Cardinal): TMbcsByteType; //15.02.03
begin
  Result := mbSingleByte;         
  if SysLocaleFarEast then
    Result := ByteTypeTest(Str, Index);
end;

function AnsiStrPos(Str, SubStr: PChar): PChar; //15.02.03
var
  L1, L2: Cardinal;
  ByteType : TMbcsByteType;
begin
  Result := nil;
  if (Str = nil) or (Str^ = #0) or (SubStr = nil) or (SubStr^ = #0) then Exit;
  L1 := StrLen(Str);
  L2 := StrLen(SubStr);
  Result := StrPos(Str, SubStr);
  while (Result <> nil) and ((L1 - Cardinal(Result - Str)) >= L2) do
  begin
    ByteType := StrByteType(Str, Integer(Result-Str));
    if (ByteType <> mbTrailByte) and
      (CompareString(LOCALE_USER_DEFAULT, 0, Result, L2, SubStr, L2) = 2) then Exit;
    if (ByteType = mbLeadByte) then Inc(Result);
    Inc(Result);
    Result := StrPos(Result, SubStr);
  end;
  Result := nil;
end;

function AnsiPos(const Substr, S: string): Integer; //15.02.03
var
  P: PChar;
begin
  Result := 0;
  P := AnsiStrPos(PChar(S), PChar(SubStr));
  if P <> nil then
    Result := Integer(P) - Integer(PChar(S)) + 1;
end;

function StrEq(const S1, S2 : String): Boolean;
begin
  Result := (Length(S1) = Length(S2)) and (LowerCase(S1) = LowerCase(S2));
end;

function StringReplace(const S, OldPattern, NewPattern: string; Flags: TReplaceFlags): string; //15.02.03
var
  SearchStr, Patt, NewStr: string;
  Offset: Integer;
begin
  if rfIgnoreCase in Flags then
  begin
    SearchStr := AnsiUpperCase(S);
    Patt := AnsiUpperCase(OldPattern);
  end else
  begin
    SearchStr := S;
    Patt := OldPattern;
  end;
  NewStr := S;
  Result := '';
  while SearchStr <> '' do
  begin
    Offset := AnsiPos(Patt, SearchStr);
    if Offset = 0 then
    begin
      Result := Result + NewStr;
      Break;
    end;
    Result := Result + Copy(NewStr, 1, Offset - 1) + NewPattern;
    NewStr := Copy(NewStr, Offset + Length(OldPattern), MaxInt);
    if not (rfReplaceAll in Flags) then
    begin
      Result := Result + NewStr;
      Break;
    end;
    SearchStr := Copy(SearchStr, Offset + Length(Patt), MaxInt);
  end;
end;

{ String formatting routines }

{procedure FormatVarToStr(var S: string; const V: Variant);
begin
  S := V;
end;}

procedure FormatClearStr(var S: string);
begin
  S := '';
end;

procedure FmtStr(var Result: string; const Format: string; const Args: array of const); //09.10.03
begin
  Result := Avl.Format(Format, Args);
end;

{$ifdef asm_ver}
function Format(const Format: string; const Args: array of const): string; //21.03.03
asm
  PUSH    ESI
  PUSH    EDI
  PUSH    EBX
  MOV     EBX, ESP
  ADD     ESP, -2048
  MOV     ESI, ESP

  INC     ECX
  JZ      @@2
@@1:
  MOV     EDI, [EDX + ECX*8 - 8]
  PUSH    EDI
  LOOP    @@1
@@2:
  PUSH    ESP
  PUSH    EAX
  PUSH    ESI

  CALL    wvsprintf

  MOV     EDX, ESI
  MOV     EAX, @Result
  CALL    System.@LStrFromPChar

  MOV     ESP, EBX
  POP     EBX
  POP     EDI
  POP     ESI
end;        
{$else}
function Format(const Format: string; const Args: array of const): string;
var
  Buffer: array[0..2047] of Char;
  ElsArray, El: PDWORD;
  I : Integer;
  P : PDWORD;
begin
  ElsArray := nil;
  if High(Args) >= 0 then GetMem(ElsArray, (High(Args)+1) * SizeOf(Pointer));
  El := ElsArray;
  for I := 0 to High(Args) do
   begin
    P := @Args[I];
    P := Pointer(P^);
    El^ := DWORD(P);
    Inc( El );
   end;
  wvsprintf(@Buffer[0], PChar(Format), PChar(ElsArray));
  Result := Buffer;
  if ElsArray <> nil then FreeMem(ElsArray);
end;
{$endif}

function NumToBytes(Value : Double): String;
const
  Suffix = ' KbMbGbTb';
var
  V, I: Integer;
begin
  Result := '';
  I := 0;
  while (Value >= 1024) and (I < 4) do
   begin
    Inc(I, 2);
    Value := Value / 1024.0;
   end;
  Result := IntToStr(Trunc(Value));
  V := Trunc((Value - Trunc(Value)) * 100);
  if V <> 0 then
   begin
    if (V mod 10) = 0 then V := V div 10;
    Result := Result + ',' + IntToStr(V);
   end;
  if I > 0 then Result := Result +  Suffix[1] + Suffix[I]+ Suffix[I+1];
end;

function FormatFloat(const Format: string; Value: Extended): string;
//var
//  Buffer: array[0..255] of Char;
begin
  //ShowMessage(Avl.Format(Format, [Value])) ;
  Result := 'Error!';

{  if Length(Format) > SizeOf(Buffer) - 32 then ConvertError(SFormatTooLong);
  SetString(Result, Buffer, FloatToTextFmt(Buffer, Value, fvExtended,
    PChar(Format)));  }
end;

//Сравнения

function CompareMem(P1, P2: Pointer; Length: Integer): Boolean; assembler;
asm
        PUSH    ESI
        PUSH    EDI
        MOV     ESI,P1
        MOV     EDI,P2
        MOV     EDX,ECX
        XOR     EAX,EAX
        AND     EDX,3
        SHR     ECX,1
        SHR     ECX,1
        REPE    CMPSD
        JNE     @@2
        MOV     ECX,EDX
        REPE    CMPSB
        JNE     @@2
@@1:    INC     EAX
@@2:    POP     EDI
        POP     ESI
end;

function CompareText(const S1, S2: string): Integer; //assembler;
begin
  Result := lstrcmpi(PChar(S1), PChar(S2));
{asm
        PUSH    ESI
        PUSH    EDI
        PUSH    EBX
        MOV     ESI,EAX
        MOV     EDI,EDX
        OR      EAX,EAX
        JE      @@0
        MOV     EAX,[EAX-4]
@@0:    OR      EDX,EDX
        JE      @@1
        MOV     EDX,[EDX-4]
@@1:    MOV     ECX,EAX
        CMP     ECX,EDX
        JBE     @@2
        MOV     ECX,EDX
@@2:    CMP     ECX,ECX
@@3:    REPE    CMPSB
        JE      @@6
        MOV     BL,BYTE PTR [ESI-1]
        CMP     BL,'a'
        JB      @@4
        CMP     BL,'z'
        JA      @@4
        SUB     BL,20H
@@4:    MOV     BH,BYTE PTR [EDI-1]
        CMP     BH,'a'
        JB      @@5
        CMP     BH,'z'
        JA      @@5
        SUB     BH,20H
@@5:    CMP     BL,BH
        JE      @@3
        MOVZX   EAX,BL
        MOVZX   EDX,BH
@@6:    SUB     EAX,EDX
        POP     EBX
        POP     EDI
        POP     ESI}
end;

function SameText(const S1, S2: string): Boolean; assembler;
asm
        CMP     EAX,EDX
        JZ      @1
        OR      EAX,EAX
        JZ      @2
        OR      EDX,EDX
        JZ      @3
        MOV     ECX,[EAX-4]
        CMP     ECX,[EDX-4]
        JNE     @3
        CALL    CompareText
        TEST    EAX,EAX
        JNZ     @3
@1:     MOV     AL,1
@2:     RET
@3:     XOR     EAX,EAX
end;

//----------------------- Date & Time ------------------------//

procedure DivMod(Dividend: Integer; Divisor: Word;
  var Result, Remainder: Word);
asm
        PUSH    EBX
        MOV     EBX,EDX
        MOV     EDX,EAX
        SHR     EDX,16
        DIV     BX
        MOV     EBX,Remainder
        MOV     [ECX],AX
        MOV     [EBX],DX
        POP     EBX
end;

procedure ConvertError(const Ident: string);
begin
  raise EConvertError.Create(Ident);
end;

function DayOfWeek(Date: TDateTime): Integer;
begin
  Result := (Trunc(Date) + 6) mod 7 + 1;
end;

function DateTimeToSystemTime(const DateTime : TDateTime; var SystemTime : TSystemTime ) : Boolean;
const
  D1 = 365;
  D4 = D1 * 4 + 1;
  D100 = D4 * 25 - 1;
  D400 = D100 * 4 + 1;
var Days : Integer;
    Y, M, D, I: Word;
    MSec : Integer;
    DayTable: PDayTable;
    MinCount, MSecCount: Word;
begin
  Days := Trunc( DateTime );
  MSec := Round((DateTime - Days) * MSecsPerDay);
  Result := False;
  with SystemTime do
  if Days > 0 then
  begin
    Dec(Days);
    Y := 1;
    while Days >= D400 do
    begin
      Dec(Days, D400);
      Inc(Y, 400);
    end;
    DivMod(Days, D100, I, D);
    if I = 4 then
    begin
      Dec(I);
      Inc(D, D100);
    end;
    Inc(Y, I * 100);
    DivMod(D, D4, I, D);
    Inc(Y, I * 4);
    DivMod(D, D1, I, D);
    if I = 4 then
    begin
      Dec(I);
      Inc(D, D1);
    end;
    Inc(Y, I);
    DayTable := @MonthDays[IsLeapYear(Y)];
    M := 1;
    while True do
     begin
      I := DayTable^[M];
      if D < I then Break;
      Dec(D, I);
      Inc(M);
     end;
    wYear := Y;
    wMonth := M;
    wDay := D + 1;
    wDayOfWeek := DayOfWeek( DateTime );
    DivMod(MSec, 60000, MinCount, MSecCount);
    DivMod(MinCount, 60, wHour, wMinute);
    DivMod(MSecCount, 1000, wSecond, wMilliSeconds);
    Result := True;
  end;
end;

function SystemDateToStr(const SystemTime : TSystemTime; const LocaleID : DWORD;
                         const DfltDateFormat : TDateFormat; const DateFormat : PChar ) : String;
var Buf : PChar;
    Sz : Integer;
    Flags : DWORD;
begin
   Sz := 100;
   Buf := nil;
   Result := '';
   Flags := 0;
   if DateFormat = nil then
   if DfltDateFormat = dfShortDate then
      Flags := DATE_SHORTDATE
   else
      Flags := DATE_LONGDATE;
   while True do
   begin
      if Buf <> nil then
         FreeMem( Buf );
      GetMem( Buf, Sz );
      if Buf = nil then Exit;
      if GetDateFormat( LocaleID, Flags, @SystemTime, DateFormat, Buf, Sz )
         = 0 then
      begin
         if GetLastError = ERROR_INSUFFICIENT_BUFFER then
            Sz := Sz * 2
         else
            break;
      end
         else
      begin
         Result := Buf;
         break;
      end;
   end;
   if Buf <> nil then
      FreeMem( Buf );
end;

function SystemTimeToStr(const SystemTime : TSystemTime; const LocaleID : DWORD;
                         const Flags : TTimeFormatFlags; const TimeFormat : PChar) : String; //10.03.03
var
  Buf : PChar;
  Sz : Integer;
  Flg : DWORD;
begin
  Sz := 100;
  Buf := nil;
  Result := '';
  Flg := 0;
  if tffNoMinutes in Flags then
   Flg := TIME_NOMINUTESORSECONDS
  else
   if tffNoSeconds in Flags then Flg := TIME_NOSECONDS;
  if tffNoMarker in Flags then Flg := Flg or TIME_NOTIMEMARKER;
  if tffForce24 in Flags then Flg := Flg or TIME_FORCE24HOURFORMAT;
  while True do
    begin
      if Buf <> nil then
         FreeMem( Buf );
      GetMem( Buf, Sz );
      if Buf = nil then Exit;
      if GetTimeFormat(LocaleID, Flg, @SystemTime, TimeFormat, Buf, Sz)
         = 0 then
      begin
         if GetLastError = ERROR_INSUFFICIENT_BUFFER then
            Sz := Sz * 2
         else
            break;
      end
         else
      begin
         Result := Buf;
         break;
      end;
    end;
   if Buf <> nil then FreeMem(Buf);
end;

function DateTimeToStr(D: TDateTime): String;
var
  ST: TSystemTime;
begin
  DateTimeToSystemTime(D, ST);
  Result := SystemDateToStr(ST, LOCALE_USER_DEFAULT, dfShortDate, nil)+' '+SystemTimeToStr(ST, LOCALE_USER_DEFAULT, [], nil);
end;

function FormatDateTime(const Format: string; DateTime: TDateTime): string; //27.07.03
begin
  //DateTimeToString(Result, Format, DateTime);
  Result := DateTimeToStr(DateTime);
end;

function DateTimeToStrShort(D: TDateTime): String; //10.03.03
var
  ST: TSystemTime;
begin
  DateTimeToSystemTime(D, ST);
  Result := SystemDateToStr(ST, LOCALE_USER_DEFAULT {GetUserDefaultLCID}, dfShortDate, nil) + ' ' + SystemTimeToStr(ST, LOCALE_USER_DEFAULT {GetUserDefaultLCID}, [], nil);
end;

function TimeToStr(D: TDateTime): String;
var
  ST: TSystemTime;
begin
  DateTimeToSystemTime(D, ST);
  Result := SystemTimeToStr(ST, LOCALE_USER_DEFAULT, [], nil);
end;

function SystemTimeToDateTime(const SystemTime : TSystemTime; var DateTime : TDateTime ) : Boolean;
var I : Integer;
    Day : Integer;
    DayTable: PDayTable;
begin
  Result := False;
  DateTime := 0.0;
  DayTable := @MonthDays[IsLeapYear(SystemTime.wYear)];
  with SystemTime do
  if (wYear >= 1) and (wYear <= 9999) and (wMonth >= 1) and (wMonth <= 12) and
    (wDay >= 1) and (wDay <= DayTable^[wMonth]) and
    (wHour < 24) and (wMinute < 60) and (wSecond < 60) and (wMilliSeconds < 1000) then
  begin
    Day := wDay;
    for I := 1 to wMonth - 1 do
        Inc(Day, DayTable^[I]);
    I := wYear - 1;
    DateTime := I * 365 + I div 4 - I div 100 + I div 400 + Day
             + (wHour * 3600000 + wMinute * 60000 + wSecond * 1000 + wMilliSeconds) / MSecsPerDay;
    Result := True;
  end;
end;

function Now : TDateTime;
var
  SystemTime : TSystemTime;
begin
  GetLocalTime( SystemTime );
  SystemTimeToDateTime( SystemTime, Result );
end;

procedure ReplaceTime(var DateTime: TDateTime; const NewTime: TDateTime); //18.03.04
begin
  DateTime := Trunc(DateTime);
  if DateTime >= 0 then
    DateTime := DateTime + Abs(Frac(NewTime))
  else
    DateTime := DateTime - Abs(Frac(NewTime));
end;

function DateToStr(D: TDateTime): String;
var
  ST: TSystemTime;
begin
  DateTimeToSystemTime(D, ST);
  Result := SystemDateToStr(ST, LOCALE_USER_DEFAULT, dfShortDate, nil);
end;

function DateToStr(const Fmt: String; D: TDateTime): String;
var
  ST: TSystemTime;
begin
  DateTimeToSystemTime(D, ST);
  Result := SystemDateToStr(ST, LOCALE_USER_DEFAULT, dfShortDate, PChar(Fmt) );
end;

{$ifdef asm_ver}
procedure Delay(mSec: Integer); //vb //10.10.03
asm
  push eax
  call Sleep
end;
{$else}
procedure Delay(mSec: Integer); //vb
begin
  Sleep(mSec);
end;
{$endif}

{ Date/time support routines }

const
  FMSecsPerDay: Single = MSecsPerDay;
  IMSecsPerDay: Integer = MSecsPerDay;

function DateTimeToTimeStamp(DateTime: TDateTime): TTimeStamp;
asm
        MOV     ECX,EAX
        FLD     DateTime
        FMUL    FMSecsPerDay
        SUB     ESP,8
        FISTP   QWORD PTR [ESP]
        FWAIT
        POP     EAX
        POP     EDX
        OR      EDX,EDX
        JNS     @@1
        NEG     EDX
        NEG     EAX
        SBB     EDX,0
        DIV     IMSecsPerDay
        NEG     EAX
        JMP     @@2
@@1:    DIV     IMSecsPerDay
@@2:    ADD     EAX,DateDelta
        MOV     [ECX].TTimeStamp.Time,EDX
        MOV     [ECX].TTimeStamp.Date,EAX
end;

{ Time encoding and decoding }

function DoEncodeTime(Hour, Min, Sec, MSec: Word; var Time: TDateTime): Boolean;
begin
  Result := False;
  if (Hour < 24) and (Min < 60) and (Sec < 60) and (MSec < 1000) then
  begin
    Time := (Hour * 3600000 + Min * 60000 + Sec * 1000 + MSec) / MSecsPerDay;
    Result := True;
  end;
end;

function EncodeTime(Hour, Min, Sec, MSec: Word): TDateTime;
begin
  if not DoEncodeTime(Hour, Min, Sec, MSec, Result) then
    ConvertError(STimeEncodeError);
end;

procedure DecodeTime(Time: TDateTime; var Hour, Min, Sec, MSec: Word);
var
  MinCount, MSecCount: Word;
begin
  DivMod(DateTimeToTimeStamp(Time).Time, 60000, MinCount, MSecCount);
  DivMod(MinCount, 60, Hour, Min);
  DivMod(MSecCount, 1000, Sec, MSec);
end;

{ Date encoding and decoding }

function IsLeapYear(Year: Word): Boolean; //27.07.03
begin
  Result := (Year mod 4 = 0) and ((Year mod 100 <> 0) or (Year mod 400 = 0));
end;

function DoEncodeDate(Year, Month, Day: Word; var Date: TDateTime): Boolean; //27.07.03
var
  I: Integer;
  DayTable: PDayTable;
begin
  Result := False;
  DayTable := @MonthDays[IsLeapYear(Year)];
  if (Year >= 1) and (Year <= 9999) and (Month >= 1) and (Month <= 12) and
    (Day >= 1) and (Day <= DayTable^[Month]) then
  begin
    for I := 1 to Month - 1 do Inc(Day, DayTable^[I]);
    I := Year - 1;
    Date := I * 365 + I div 4 - I div 100 + I div 400 + Day{ - DateDelta};
    Result := True;
  end;
end;

function EncodeDate(Year, Month, Day: Word): TDateTime; //27.07.03
begin
  if not DoEncodeDate(Year, Month, Day, Result) then
    ConvertError(SDateEncodeError);
end;

procedure InternalDecodeDate(Date: TDateTime; var Year, Month, Day, DOW: Word); //27.07.03
const
  D1 = 365;
  D4 = D1 * 4 + 1;
  D100 = D4 * 25 - 1;
  D400 = D100 * 4 + 1;
var
  Y, M, D, I: Word;
  T: Integer;
  DayTable: PDayTable;
begin
  T := DateTimeToTimeStamp(Date).Date;
  if T <= 0 then
  begin
    Year := 0;
    Month := 0;
    Day := 0;
    DOW := 0;
  end else
  begin
    DOW := T mod 7;
    Dec(T);
    Y := 1;
    while T >= D400 do
    begin
      Dec(T, D400);
      Inc(Y, 400);
    end;
    DivMod(T, D100, I, D);
    if I = 4 then
    begin
      Dec(I);
      Inc(D, D100);
    end;
    Inc(Y, I * 100);
    DivMod(D, D4, I, D);
    Inc(Y, I * 4);
    DivMod(D, D1, I, D);
    if I = 4 then
    begin
      Dec(I);
      Inc(D, D1);
    end;
    Inc(Y, I);
    DayTable := @MonthDays[IsLeapYear(Y)];
    M := 1;
    while True do
    begin
      I := DayTable^[M];
      if D < I then Break;
      Dec(D, I);
      Inc(M);
    end;
    Year := Y;
    Month := M;
    Day := D + 1;
  end;
end;

procedure DecodeDate(Date: TDateTime; var Year, Month, Day: Word); //27.07.03
var
  Dummy: Word;
begin
  InternalDecodeDate(Date, Year, Month, Day, Dummy);
end;

function StrIsStartingFrom( Str, Pattern: PChar ): Boolean;
asm
  {$IFDEF F_P}
        MOV     EAX, [Str]
        MOV     EDX, [Pattern]
  {$ENDIF F_P}
        XOR     ECX, ECX
      @@1:
        MOV     CL, [EDX]   // pattern[ i ]
        INC     EDX
        MOV     CH, [EAX]   // str[ i ]
        INC     EAX
        JECXZ   @@2         // str = pattern; CL = #0, CH = #0
        CMP     CL, CH
        JE      @@1
      @@2:
        TEST    CL, CL
        SETZ    AL
end {$IFDEF F_P} [ 'EAX', 'EDX', 'ECX' ] {$ENDIF};

function StrToDateTimeFmt( const sFmtStr, sS: String ): TDateTime;
var h12, hAM: Boolean;
    FmtStr, S: PChar;

  function GetNum( var S: PChar; NChars: Integer ): Integer;
  begin
    Result := 0;
    while (S^ <> #0) and (NChars <> 0) do
    begin
      Dec( NChars );
      if S^ in ['0'..'9'] then
      begin
        Result := Result * 10 + Ord(S^) - Ord('0');
        Inc( S );
      end
      else
        break;
    end;
  end;

  function GetYear( var S: PChar; NChars: Integer ): Integer;
  var STNow: TSystemTime;
      OldDate: Boolean;
  begin
    Result := GetNum( S, NChars );
    GetSystemTime( STNow );
    OldDate := Result < 50;
    Result := Result + STNow.wYear - STNow.wYear mod 100;
    if OldDate then Dec( Result, 100 );
  end;

  function GetMonth( const fmt: String; var S: PChar ): Integer;
  var SD: TSystemTime;
      M: Integer;
      C, MonthStr: String;
  begin
    GetSystemTime( SD );
    for M := 1 to 12 do
    begin
      SD.wMonth := M;
      C := SystemDateToStr( SD, LOCALE_USER_DEFAULT, dfLongDate, PChar( fmt + '/dd/yyyy/' ) );
//X      MonthStr := Parse( C, '/' );
      if AnsiCompareStrNoCase( MonthStr, Copy( S, 1, Length( MonthStr ) ) ) = 0 then
      begin
        Result := M;
        Inc( S, Length( MonthStr ) );
        Exit;
      end;
    end;
    Result := 1;
  end;

  procedure SkipDayOfWeek( const fmt: String; var S: PChar );
  var SD: TSystemTime;
      Dt: TDateTime;
      D: Integer;
      C, DayWeekStr: String;
  begin
    GetSystemTime( SD );
    SystemTimeToDateTime( SD, Dt );
    Dt := Dt - SD.wDayOfWeek;
    for D := 0 to 6 do
    begin
      DateTimeToSystemTime( Dt, SD );
      C := SystemDateToStr( SD, LOCALE_USER_DEFAULT, dfLongDate, PChar( fmt + '/MM/yyyy/' ) );
//X      DayWeekStr := Parse( C, '/' );
      if AnsiCompareStrNoCase( DayWeekStr, Copy( S, 1, Length( DayWeekStr ) ) ) = 0 then
      begin
        Inc( S, Length( DayWeekStr ) );
        Exit;
      end;
      Dt := Dt + 1.0;
    end;
  end;

  procedure GetTimeMark( const fmt: String; var S: PChar );
  var SD: TSystemTime;
      AM: Boolean;
      C, TimeMarkStr: String;
  begin
    GetSystemTime( SD );
    SD.wHour := 0;
    for AM := FALSE to TRUE do
    begin
      C := SystemDateToStr( SD, LOCALE_USER_DEFAULT, dfLongDate, PChar( fmt + '/HH/mm' ) );
//X      TimeMarkStr := Parse( C, '/' );
      if AnsiCompareStrNoCase( TimeMarkStr, Copy( S, 1, Length( TimeMarkStr ) ) ) = 0 then
      begin
        Inc( S, Length( TimeMarkStr ) );
        hAM := AM;
        Exit;
      end;
      SD.wHour := 13;
    end;
    Result := 1;
  end;

  function FmtIs1( S: PChar ): Boolean;
  begin
    if StrIsStartingFrom( FmtStr, S ) then
    begin
      Inc( FmtStr, StrLen( S ) );
      Result := TRUE;
    end
      else
      Result := FALSE;
  end;

  function FmtIs( S1, S2: PChar ): Boolean;
  begin
    Result := FmtIs1( S1 ) or FmtIs1( S2 );
  end;

var ST: TSystemTime;
begin
  FmtStr := PChar( sFmtStr);
  S := PChar( sS );
  FillChar( ST, Sizeof( ST ), 0 );
  h12 := FALSE;
  hAM := FALSE;
  while (FmtStr^ <> #0) and (S^ <> #0) do
  begin
    if (FmtStr^ in ['a'..'z','A'..'Z']) and (S^ in ['0'..'9']) then
    begin
      if      FmtIs1( 'yyyy'   ) then ST.wYear := GetNum( S, 4 )
      else if FmtIs1( 'yy' )     then ST.wYear := GetYear( S, 2 )
      else if FmtIs1( 'y' )      then ST.wYear := GetYear( S, -1 )
      else if FmtIs( 'dd', 'd' ) then ST.wDay := GetNum( S, 2 )
      else if FmtIs( 'MM', 'M' ) then ST.wMonth := GetNum( S, 2 )
      else if FmtIs( 'HH', 'H' ) then ST.wHour := GetNum( S, 2 )
      else if FmtIs( 'hh', 'h' ) then begin ST.wHour := GetNum( S, 2 ); h12 := TRUE end
      else if FmtIs( 'mm', 'm' ) then ST.wMinute := GetNum( S, 2 )
      else if FmtIs( 'ss', 's' ) then ST.wSecond := GetNum( S, 2 );
    end
      else
    if (FmtStr^ in [ 'M', 'd', 'g' ]) then
    begin
      if      FmtIs1( 'MMMM' ) then ST.wMonth := GetMonth( 'MMMM', S )
      else if FmtIs1( 'MMM'  ) then ST.wMonth := GetMonth( 'MMM', S )
      else if FmtIs1( 'dddd' ) then SkipDayOfWeek( 'dddd', S )
      else if FmtIs1( 'ddd'  ) then SkipDayOfWeek( 'ddd', S )
      else if FmtIs1( 'tt'   ) then GetTimeMark( 'tt', S )
      else if FmtIs1( 't'    ) then GetTimeMark( 't', S );
    end
      else
    begin
      if FmtStr^ = S^ then
        Inc( FmtStr );
      Inc( S );
    end;
  end;

  if h12 then
  if hAM then
    Inc( ST.wHour, 12 );

  SystemTimeToDateTime( ST, Result );
end;

var FmtBuf: PChar;

function StrToDateTime(const S: String): TDateTime; //02.04.04
var FmtStr, FmtStr2: String;

  function EnumDateFmt( lpstrFmt: PChar ): Boolean; stdcall;
  begin
    GetMem( FmtBuf, StrLen( lpstrFmt ) + 1 );
    StrCopy( FmtBuf, lpstrFmt );
    Result := FALSE;
  end;

begin
  FmtStr := 'dd.MM.yyyy';
  FmtBuf := nil;
  EnumDateFormats( @ EnumDateFmt, LOCALE_USER_DEFAULT, DATE_SHORTDATE );
  if FmtBuf <> nil then
  begin
    FmtStr := FmtBuf;
    FreeMem( FmtBuf );
  end;

  FmtStr2 := 'H:mm:ss';
  FmtBuf := nil;
  EnumTimeFormats( @ EnumDateFmt, LOCALE_USER_DEFAULT, 0 );
  if FmtBuf <> nil then
  begin
    FmtStr2 := FmtBuf;
    FreeMem( FmtBuf );
  end;

  Result := StrToDateTimeFmt( FmtStr + ' ' + FmtStr2, S );
end;

function DateTimeToFileDate(DateTime: TDateTime): Integer; //02.04.04
var
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin
  DecodeDate(DateTime, Year, Month, Day);
  if (Year < 1980) or (Year > 2099) then Result := 0 else
  begin
    DecodeTime(DateTime, Hour, Min, Sec, MSec);
    LongRec(Result).Lo := (Sec shr 1) or (Min shl 5) or (Hour shl 11);
    LongRec(Result).Hi := Day or (Month shl 5) or ((Year - 1980) shl 9);
  end;
end;

//------------------------- Graphics -------------------------//
function IconCount(FileName:String):Integer;
begin
  Result := ExtractIcon(Hinstance, PChar(FileName), UInt(-1));
end;

function IconExtract(FileName:String;Index:Integer):hIcon;
begin
  Result := ExtractIcon(Hinstance, PChar(FileName), Index);
end;

function ExtractFileIcon(FileExt: String): hIcon; //13.12.04
var
  Key: hKey;
  FilePath, s: String;
  IconIndex, i: Integer;
  li: hIcon;
begin
  if FileExt = '..' then s := 'Folder' else begin
    Key := RegKeyOpenRead(HKEY_CLASSES_ROOT, FileExt);
    s := RegKeyGetStr(Key, '');
    RegKeyClose(Key);
  end;

  Key := RegKeyOpenRead(HKEY_CLASSES_ROOT, s + '\DefaultIcon');
  s := RegKeyGetStr_(Key, '');
  RegKeyClose(Key);

  for i := Length(s) downto 1 do
    if s[i] = ',' then begin
      FilePath := Copy(s, 1, i - 1);
      Break;
    end;
  IconIndex := StrToIntDef(Copy(s, i+1, Length(s)), 0);

  if FilePath = '' then FilePath := '%SystemRoot%\System32\shell32.dll';
  if (FileExt = '.exe') then IconIndex := 2;

  ExtractIconExA(PChar(FilePath), IconIndex, li, result, 1);
end;

function FileIconIndex(const Path: String; OpenIcon: Boolean): Integer; //09.03.03
var
  SFI: TShFileInfo;
  Flags: Integer;
begin
  if OpenIcon then Flags := SHGFI_OPENICON else Flags := 0;
  ShGetFileInfo(PChar(Path), FILE_ATTRIBUTE_NORMAL, SFI, SizeOf(SFI), Flags or SHGFI_USEFILEATTRIBUTES or SHGFI_ICON or SHGFI_SMALLICON or SHGFI_SYSICONINDEX);
  Result := SFI.iIcon;
end;

function LoadSystemIcons: THandle; //13.12.04
var
  FileInfo : TSHFileInfo;
begin
  Result := SHGetFileInfo('', 0, FileInfo, Sizeof(FileInfo), SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
end;

procedure Frame3D(hDC, btn_hi, btn_lo, tx, ty, lx, ly, bdrWid:DWORD);
var
  hPen     :DWORD;
  hPen2    :DWORD;
  hpenOld  :DWORD;
  tx_, ty_, lx_, ly_, bdrWid_:DWORD;
begin
  hPen := CreatePen(0,1,btn_hi);
  hpenOld := SelectObject(hDC,hPen);

  tx_ := tx;
  ty_ := ty;
  lx_ := lx;
  ly_ := ly;
  bdrWid_ := bdrWid;


 while bdrWid<>0 do
  begin
   MoveToEx(hDC,tx,ty, nil);
   LineTo(hDC,lx,ty);

   MoveToEx(hDC,tx,ty, nil);
   LineTo(hDC,tx,ly);

   dec(tx);
   dec(ty);
   inc(lx);
   inc(ly);
   dec(bdrWid);
  end;

 hPen2 := CreatePen(0,1,btn_lo);
 hPen := SelectObject(hDC,hPen2);
 DeleteObject(hPen);

 bdrWid := bdrWid_ ;
 ly := ly_;
 lx := lx_;
 ty := ty_;
 tx := tx_;

 while bdrWid<>0 do
  begin
   MoveToEx(hDC,tx,ly, nil);
   LineTo(hDC,lx,ly);

   MoveToEx(hDC,lx,ty, nil);
   inc(ly);
   LineTo(hDC,lx,ly);
   dec(ly);

   dec(tx);
   dec(ty);
   inc(lx);
   inc(ly);

   dec(bdrWid);
  end;

 SelectObject(hDC,hpenOld);
 DeleteObject(hPen2);
end;

{$ifdef asm_ver}
function ColorToRGB(Color: TColor): TColor;
begin
  if Color < 0 then
    Result := GetSysColor(Color and $FF)
  else
    Result := Color;
end;
{$else}
function ColorToRGB(Color: TColor): TColor;
begin
  if Color < 0 then
    Result := GetSysColor(Color and $FF)
  else
    Result := Color;
end;
{$endif}

{function ColorToString(Color: TColor): String; //03.04.03
type
  TIdentMapEntry = record
    Value: Integer;
    Name: String;
  end;

const
  Colors: array[0..41] of TIdentMapEntry = (
    (Value: clBlack; Name: 'clBlack'),
    (Value: clMaroon; Name: 'clMaroon'),
    (Value: clGreen; Name: 'clGreen'),
    (Value: clOlive; Name: 'clOlive'),
    (Value: clNavy; Name: 'clNavy'),
    (Value: clPurple; Name: 'clPurple'),
    (Value: clTeal; Name: 'clTeal'),
    (Value: clGray; Name: 'clGray'),
    (Value: clSilver; Name: 'clSilver'),
    (Value: clRed; Name: 'clRed'),
    (Value: clLime; Name: 'clLime'),
    (Value: clYellow; Name: 'clYellow'),
    (Value: clBlue; Name: 'clBlue'),
    (Value: clFuchsia; Name: 'clFuchsia'),
    (Value: clAqua; Name: 'clAqua'),
    (Value: clWhite; Name: 'clWhite'),
    (Value: clScrollBar; Name: 'clScrollBar'),
    (Value: clBackground; Name: 'clBackground'),
    (Value: clActiveCaption; Name: 'clActiveCaption'),
    (Value: clInactiveCaption; Name: 'clInactiveCaption'),
    (Value: clMenu; Name: 'clMenu'),
    (Value: clWindow; Name: 'clWindow'),
    (Value: clWindowFrame; Name: 'clWindowFrame'),
    (Value: clMenuText; Name: 'clMenuText'),
    (Value: clWindowText; Name: 'clWindowText'),
    (Value: clCaptionText; Name: 'clCaptionText'),
    (Value: clActiveBorder; Name: 'clActiveBorder'),
    (Value: clInactiveBorder; Name: 'clInactiveBorder'),
    (Value: clAppWorkSpace; Name: 'clAppWorkSpace'),
    (Value: clHighlight; Name: 'clHighlight'),
    (Value: clHighlightText; Name: 'clHighlightText'),
    (Value: clBtnFace; Name: 'clBtnFace'),
    (Value: clBtnShadow; Name: 'clBtnShadow'),
    (Value: clGrayText; Name: 'clGrayText'),
    (Value: clBtnText; Name: 'clBtnText'),
    (Value: clInactiveCaptionText; Name: 'clInactiveCaptionText'),
    (Value: clBtnHighlight; Name: 'clBtnHighlight'),
    (Value: cl3DDkShadow; Name: 'cl3DDkShadow'),
    (Value: cl3DLight; Name: 'cl3DLight'),
    (Value: clInfoText; Name: 'clInfoText'),
    (Value: clInfoBk; Name: 'clInfoBk'),
    (Value: clNone; Name: 'clNone'));
var
  i: Byte;
begin
  Result := '$' + IntToHex(Color, 8);
  for i := 0 to 41 do
   if Colors[i].Value = Color then Result := Colors[i].Name;
end; }

procedure SetSysColor(Element: DWord; Color : TColor); //21.03.04
begin
  SetSysColors(1, Element, Color);
end;

procedure GradientRect(FromRGB, ToRGB: TColor;Canvas:tcanvas);
var
  RGBFrom : array[0..2] of Byte;
  RGBDiff : array[0..2] of integer;
  ColorBand : TRect;
  I : Integer;
  R : Byte;
  G : Byte;
  B : Byte;
begin
 RGBFrom[0] := GetRValue (ColorToRGB (FromRGB));
 RGBFrom[1] := GetGValue (ColorToRGB (FromRGB));
 RGBFrom[2] := GetBValue (ColorToRGB (FromRGB));
 RGBDiff[0] := GetRValue (ColorToRGB (ToRGB)) - RGBFrom[0];
 RGBDiff[1] := GetGValue (ColorToRGB (ToRGB)) - RGBFrom[1];
 RGBDiff[2] := GetBValue (ColorToRGB (ToRGB)) - RGBFrom[2];
 Canvas.Pen.Style := psSolid;
 Canvas.Pen.Mode := pmCopy;
 ColorBand.Left := 0;
 ColorBand.Right := canvas.ClipRect.Right-Canvas.ClipRect.Left;
 for I := 0 to $ff do
  begin
   ColorBand.Top := MulDiv (I , canvas.ClipRect.Bottom-Canvas.ClipRect.Top, $100);
   ColorBand.Bottom := MulDiv (I + 1,canvas.ClipRect.Bottom-Canvas.ClipRect.Top, $100);
   R := RGBFrom[0] + MulDiv (I, RGBDiff[0], $ff);
   G := RGBFrom[1] + MulDiv (I, RGBDiff[1], $ff);
   B := RGBFrom[2] + MulDiv (I, RGBDiff[2], $ff);
   Canvas.Brush.Color := RGB (R, G, B);
   Canvas.FillRect (ColorBand);
 end;
end;

function GetColorIndex: Integer;
var
  DC : Hdc;
begin
  DC := CreateDC('DISPLAY', nil, nil, nil);
  Result := GetDeviceCaps(DC, BITSPIXEL);
  DeleteDC(DC);
end;

function GetColorDesc: String;
const
  Col = ' Color';
begin
  case GetColorIndex of
    1  : Result := '16'+col;
    8  : Result := '256'+col;
    15..16 : Result := 'High'+col; // 32768 - 65536 цветов
    24..32 : Result := 'True'+col; // 16 млн - 32 млн цветов
  end;
end;

procedure SetAlphaBlend(Handle, Value: Integer);
const
 LWA_COLORKEY=$00000001;
 LWA_ALPHA=$00000002;
 ULW_COLORKEY=$00000001;
 ULW_ALPHA=$00000002;
 ULW_OPAQUE=$00000004;
 WS_EX_LAYERED=$00080000;
type
 TSetLayeredWindowAttributes=function( hwnd: Integer; crKey: TColor; bAlpha: Byte; dwFlags: DWORD):Boolean;stdcall;
var
 SetLayeredWindowAttributes: TSetLayeredWindowAttributes;
 User32: THandle;
 dw: DWORD;
begin
 User32 := GetModuleHandle('User32.dll');
 SetLayeredWindowAttributes := GetProcAddress(User32, 'SetLayeredWindowAttributes');
 if Assigned( SetLayeredWindowAttributes ) then
  begin
   dw := GetWindowLong(Handle, GWL_EXSTYLE);
   if Byte(Value) < 255 then
    begin
     SetWindowLong(Handle, GWL_EXSTYLE, dw or WS_EX_LAYERED);
     SetLayeredWindowAttributes(Handle, 0, Value and $FF, LWA_ALPHA);
    end
   else
    SetWindowLong(Handle, GWL_EXSTYLE, dw and not WS_EX_LAYERED);
  end;
end;

procedure CanvasCopyRect(SourceCanvas, DestCanvas: hDC; const Source, Dest: TRect);
begin
  StretchBlt(SourceCanvas, Dest.Left, Dest.Top, Dest.Right - Dest.Left,
    Dest.Bottom - Dest.Top, DestCanvas, Source.Left, Source.Top,
    Source.Right - Source.Left, Source.Bottom - Source.Top, SRCCOPY);
end;

{ Multimedia }

procedure OpenCd(const Open:Boolean); //08.03.03
const
  a = 'Set cdaudio Door ';
  b = 'Open';
  c = 'Closed';
  d = ' Wait';
begin
  if Open then //Вытащить
    mciSendString(PChar(a+b+d), nil, 0, 1)
  else         //Засунуть
    mciSendString(PChar(a+c+d), nil, 0, 0);
end;

{$ifdef asm_ver}
procedure Beep; //10.10.03
asm
  push 0
  call MessageBeep
end;
{$else}
procedure Beep; //32.08.03
begin
  MessageBeep(0);
end;
{$endif}

{ File management routines }

function FileOpen(const FileName: string; Mode: LongWord): Integer;
const
  AccessMode: array[0..2] of LongWord = (
    GENERIC_READ,
    GENERIC_WRITE,
    GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of LongWord = (
    0,
    0,
    FILE_SHARE_READ,
    FILE_SHARE_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE);
  OpenMode : array[0..1] of LongWord = (
    OPEN_EXISTING,
    TRUNCATE_EXISTING);
begin
  Result := CreateFile(PChar(FileName),
                       AccessMode[Mode and 3],
                       ShareMode[(Mode and $F0) shr 4],
                       nil,
                       OpenMode[(Mode and 4) shr 2],
                       FILE_ATTRIBUTE_NORMAL,
                       0);
end;

function FileCreate(const FileName: string): Integer;
begin
  Result := CreateFile(PChar(FileName),
                       GENERIC_READ or GENERIC_WRITE,
                       0,
                       nil,
                       CREATE_ALWAYS,
                       FILE_ATTRIBUTE_NORMAL,
                       0);
end;

{$ifdef asm_ver}
function FileRead(Handle: Integer; var Buffer; Count: Integer): Integer; //20.03.03
asm
  PUSH     EBP
  PUSH     0
  MOV      EBP, ESP
  PUSH     0
  PUSH     EBP
  PUSH     ECX
  PUSH     EDX
  PUSH     EAX
  CALL     ReadFile
  TEST     EAX, EAX
  POP      EAX
  JNZ      @@exit
  XOR      EAX, EAX
@@exit:
  POP      EBP
end;
{$else}
function FileRead(Handle: Integer; var Buffer; Count: Integer): Integer;
begin
  if not ReadFile(Handle, Buffer, Count, LongWord(Result), nil) then Result := -1;
end;
{$endif}

{$ifdef asm_ver}
function FileWrite(Handle: Integer; const Buffer; Count: Integer): Integer; //20.03.03
asm
  PUSH     EBP
  PUSH     EBP
  MOV      EBP, ESP
  PUSH     0
  PUSH     EBP
  PUSH     ECX
  PUSH     EDX
  PUSH     EAX
  CALL     WriteFile
  TEST     EAX, EAX
  POP      EAX
  JNZ      @@exit
  XOR      EAX, EAX
@@exit:
  POP      EBP
end;
{$else}
function FileWrite(Handle: Integer; const Buffer; Count: Integer): Integer;
begin
  if not WriteFile(Handle, Buffer, Count, LongWord(Result), nil) then Result := -1;
end;
{$endif}

{$ifdef asm_ver}
function FileSeek(Handle, Offset, Origin: Integer): Integer; //20.03.03
asm
  MOVZX    ECX, CL
  PUSH     ECX
  PUSH     0
  PUSH     EDX
  PUSH     EAX
  CALL     SetFilePointer
end;
{$else}
function FileSeek(Handle, Offset, Origin: Integer): Integer;
begin
  Result := SetFilePointer(THandle(Handle), Offset, nil, Origin);
end;
{$endif}

{$ifdef asm_ver}
procedure FileClose(Handle: Integer); //20.03.03
asm
  PUSH     EAX
  CALL     CloseHandle
end;
{$else}
procedure FileClose(Handle: Integer);
begin
  CloseHandle(THandle(Handle));
end;
{$endif}

(*{$ifdef asm_ver}
function FileGetSize(FileName: String): Integer;
asm
  push 0
  push eax
  call FileOpen
  push 0
  push eax
  call GetFileSize
  push eax
  push eax
  call CloseHandle
  pop eax
end;
{$else}   *)
function FileGetSize(FileName: String): Integer;
var
  h:THandle;
begin               
  h:=FileOpen(FileName, fmOpenRead);
  Result := GetFileSize(h, nil);
  CloseHandle(h);
end;
//{$endif}

function GetFileType(const Path: String): String;
var
  SFI: TShFileInfo;
begin
  FillChar(SFI, sizeof(SFI), 0);
  ShGetFileInfo(PChar(Path), 0, SFI, SizeOf(SFI), SHGFI_TYPENAME);
  Result := SFI.szTypeName;
end;

function FileGetAttr(const FileName: string): Integer;
begin
  Result := GetFileAttributes(PChar(FileName));
end;

function FileSetAttr(const FileName: string; Attr: Integer): Integer;
begin
  Result := 0;
  if not SetFileAttributes(PChar(FileName), Attr) then
    Result := GetLastError;
end;

function FileSetAttrib(Filename: String; A,H,R,S: Boolean): Boolean;
var
   Attrbs: DWord;
begin
   Attrbs:= 0;
   if A then Attrbs:= Attrbs and FILE_ATTRIBUTE_ARCHIVE;
   if H then Attrbs:= Attrbs and FILE_ATTRIBUTE_HIDDEN;
   if R then Attrbs:= Attrbs and FILE_ATTRIBUTE_READONLY;
   if S then Attrbs:= Attrbs and FILE_ATTRIBUTE_SYSTEM;
   result:= SetFileAttributes(PChar(Filename), Attrbs);
end;

function FileLock(FileName: String): THandle; //30.12.03
begin
  Result := FileOpen(FileName, fmOpenWrite or fmShareExclusive);
end;

procedure FileUnLock(Handle: THandle); //30.12.03
begin
  FileClose(Handle);
end;

{function GetFileNameFromBrowse(hOwner:LongInt;Var sFile:String;sInitDir,sDefExt,sFilter,sTitle :String): Boolean;
var sFileW,sInitDirW,sDefExtW,sFilterW,sTitleW:PWideChar;
    sInitDirL,sDefExtL,sFilterL,sTitleL:Integer;
begin
 sFileW := CoTaskMemAlloc(255 * sizeof(WideChar));
 StringToWideChar(SFile, SFileW, 255);
 SInitDirL:=Length(sInitDir)+1;sInitDirW := CoTaskMemAlloc(SInitDirL * sizeof(WideChar));
 StringToWideChar(SInitDir, SInitDirW, sInitDirL);
 SDefExtL:=Length(sDefExt)+1;sDefExtW := CoTaskMemAlloc(SDefExtL * sizeof(WideChar));
 StringToWideChar(SDefExt, SDefExtW, sDefExtL);
 SFilterL:=Length(sFilter)+1;sFilterW := CoTaskMemAlloc(SFilterL * sizeof(WideChar));
 StringToWideChar(SFilter, SFilterW, sFilterL);
 STitleL:=Length(sTitle)+1;sTitleW := CoTaskMemAlloc(STitleL * sizeof(WideChar));
 StringToWideChar(STitle, STitleW, sTitleL);
 Result:=SHGetFileNameFromBrowse(hOwner,sFileW,Integer(sFileW),sInitDirW,
                                                         sDefExtW,sFilterW,sTitleW);
 SFile:=sFileW; 
 CoTaskMemFree(sFileW);CoTaskMemFree(sInitDirW);
 CoTaskMemFree(sDefExtW);CoTaskMemFree(sFilterW);
 CoTaskMemFree(sTitleW);
end; }

function OpenSaveDialog(Handle:THandle;OpenDialog:Boolean; Title, DefExtension, Filter, InitialDir:String; FilterIndex, Options:Integer; var FileName:String):Boolean;
var
  Ofn : TOpenFilename;
  Fltr : String;
  TempFilename : String;

  Function MakeFilter(s : string) : String;
  {
  format of filter for API call is following:
    'text files'#0'*.txt'#0
    'bitmap files'#0'*.bmp'#0#0
  }
  var Str: PChar;
  begin
    Result := s;
    if Result='' then exit;
    Result:=Result+#0; {Delphi string always end on #0 is this is #0#0}
    Str := PChar( Result );
    while Str^ <> #0 do
    begin
     if Str^ in ['|'] then Str^ := #0;
     Inc( Str );
    end;
    {
    while pos('|', Result)>0 do begin
      Result[pos('|', Result)]:=#0;
    end;
    }
  end;

  function GetName: string;
  begin
    Result := Copy(TempFileName, 1, Pos(#0, TempFileName) - 1);
    Delete(TempFileName, 1, Length(Result) + 1);
  end;

begin
  Fillchar(ofn, sizeof(ofn), 0);   
  ofn.lStructSize:= 76;
//  if Handle <> 0 then
  ofn.hWndOwner := Handle ;
  ofn.hInstance:=HInstance;
  ofn.nFilterIndex:=FilterIndex;
  ofn.nMaxFile:=MAX_PATH+2;
  if Options and OFN_ALLOWMULTISELECT <> 0 then ofn.nMaxFile := ofn.nMaxFile * 32;

  Fltr:=MakeFilter(Filter);
  if Fltr <> '' then ofn.lpstrFilter:=pchar(Fltr);

  Setlength(TempFileName, ofn.nMaxFile);
  ofn.lpstrFile:=StrLCopy(pchar(TempFileName), pchar(FileName), Min(ofn.nMaxFile,Length(FileName)));

  ofn.lpstrInitialDir:=Pointer(InitialDir);
  ofn.lpstrTitle:=Pointer(Title);

  ofn.Flags:=OFN_EXPLORER or OFN_LONGNAMES or Options or OFN_HIDEREADONLY;

  ofn.lpstrDefExt:=PChar(DefExtension);
  if OpenDialog then result:=GetOpenFileName(ofn) else result:=GetSaveFileName(ofn);
  if result then
  begin
    FileName:=GetName;
    Fltr := '';
    while (Options and OFN_ALLOWMULTISELECT <> 0) and (Length(TempFileName) > 0) and (TempFileName[1] <> #0) do
      Fltr := Fltr + FileName + '\' + GetName + #$0D;
    if Fltr <> '' then FileName := Copy(Fltr, 1, Length(Fltr) - 1);
  end;
end;

function OpenSaveDialog2(Handle:THandle;OpenDialog:Boolean; Title, DefExtension, Filter, InitialDir:String; var FilterIndex: Integer; Options:Integer; var FileName:String):Boolean;
var
  Ofn : TOpenFilename;
  Fltr : String;
  TempFilename : String;

  Function MakeFilter(s : string) : String;
  {
  format of filter for API call is following:
    'text files'#0'*.txt'#0
    'bitmap files'#0'*.bmp'#0#0
  }
  var Str: PChar;
  begin
    Result := s;
    if Result='' then exit;
    Result:=Result+#0; {Delphi string always end on #0 is this is #0#0}
    Str := PChar( Result );
    while Str^ <> #0 do
    begin
     if Str^ in ['|'] then Str^ := #0;
     Inc( Str );
    end;
    {
    while pos('|', Result)>0 do begin
      Result[pos('|', Result)]:=#0;
    end;
    }
  end;

begin
  Fillchar(ofn, sizeof(ofn), 0);   
  ofn.lStructSize:= 76;
//  if Handle <> 0 then
  ofn.hWndOwner := Handle ;
  ofn.hInstance:=HInstance;
  ofn.nFilterIndex := FilterIndex;
  ofn.nMaxFile:=MAX_PATH+2;

  Fltr:=MakeFilter(Filter);
  if Fltr <> '' then ofn.lpstrFilter:=pchar(Fltr);

  Setlength(TempFileName, ofn.nMaxFile);
  ofn.lpstrFile:=StrLCopy(pchar(TempFileName), pchar(FileName), Min(ofn.nMaxFile,Length(FileName)));

  ofn.lpstrInitialDir:=Pointer(InitialDir);
  ofn.lpstrTitle:=Pointer(Title);

  ofn.Flags:=OFN_EXPLORER or OFN_LONGNAMES or Options or OFN_HIDEREADONLY;

  ofn.lpstrDefExt:=PChar(DefExtension);
  if OpenDialog then result:=GetOpenFileName(ofn) else result:=GetSaveFileName(ofn);
  if result then
   begin
    FileName:=copy(tempFileName, 1, pos(#0, TempFilename)-1);
    FilterIndex := ofn.nFilterIndex ;
   end;
end;

{ OpenDir Dialog }

type
  PSHItemID = ^TSHItemID;
  TSHItemID = packed record
   cb: Word;                         { Size of the ID (including cb itself) }
   abID: array[0..0] of Byte;        { The item ID (variable length) }
  end;

  PItemIDList = ^TItemIDList;
  TItemIDList = record
   mkid: TSHItemID;
  end;

  BFFCALLBACK = function(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
  TFNBFFCallBack = type BFFCALLBACK;

  PBrowseInfo = ^TBrowseInfo;
  TBrowseInfo = record
   hwndOwner: HWND;
   pidlRoot: PItemIDList;
   pszDisplayName: PAnsiChar;  { Return display name of item selected. }
   lpszTitle: PAnsiChar;      { text to go in the banner over the tree. }
   ulFlags: UINT;           { Flags that control the return stuff }
   lpfn: TFNBFFCallBack;   //pointer
   lParam: LPARAM;          { extra info that's passed back in callbacks }
   iImage: Integer;         { output var: where to return the Image index. }
  end;

function SHBrowseForFolder(var lpbi: TBrowseInfo): PItemIDList; stdcall; external 'shell32.dll' name 'SHBrowseForFolderA';
function SHGetPathFromIDList(pidl: PItemIDList; pszPath: PChar): BOOL; stdcall; external 'shell32.dll' name 'SHGetPathFromIDListA';

const
  BIF_RETURNONLYFSDIRS   = $0001;  { For finding a folder to start document searching }
  BIF_DONTGOBELOWDOMAIN  = $0002;  { For starting the Find Computer }
  BIF_STATUSTEXT         = $0004;
  BIF_RETURNFSANCESTORS  = $0008;
  BIF_EDITBOX            = $0010;
  BIF_VALIDATE           = $0020;  { insist on valid result (or CANCEL) }
  BIF_BROWSEFORCOMPUTER  = $1000;  { Browsing for Computers. }
  BIF_BROWSEFORPRINTER   = $2000;  { Browsing for Printers }
  BIF_BROWSEINCLUDEFILES = $4000;  { Browsing for Everything }

  BFFM_INITIALIZED       = 1;
  BFFM_SELCHANGED        = 2;

  BFFM_SETSTATUSTEXT     = WM_USER + 100;
  BFFM_ENABLEOK          = WM_USER + 101;
  BFFM_SETSELECTION      = WM_USER + 102;

function SelectDirCB(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
begin
  if (uMsg = BFFM_INITIALIZED) and (lpData <> 0) then
    SendMessage(Wnd, BFFM_SETSELECTION, Integer(True), lpdata);
  result := 0;
end;

function OpenDirDialog(Handle: Integer; Title: String; AllowFolderCreate: Boolean; var Path: String): Boolean; //15.11.03
var
  BI        : TBrowseInfo;
  Browse    : PItemIdList;
  FBuf      : array[0..MAX_PATH] of Char;
begin
  Result := False;
  BI.hwndOwner := Handle;
  BI.pidlRoot  := nil;
  BI.pszDisplayName := @FBuf[0];
  BI.lpszTitle := PChar(Title);
  if AllowFolderCreate then BI.ulFlags := 0 else BI.ulFlags := BIF_RETURNONLYFSDIRS;
  BI.lpfn := SelectDirCB;
  BI.lParam := Integer(PChar(Path));
  Browse := SHBrowseForFolder(BI);
  if Browse <> nil then
   begin
    SHGetPathFromIDList(Browse, @FBuf[0]);
    Path := FBuf;
    CoTaskMemFree(Browse);
    Result := True;
   end;
end;

type
  tagCHOOSECOLORA = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hInstance: HWND;
    rgbResult: COLORREF;
    lpCustColors: ^COLORREF;
    Flags: DWORD;
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpTemplateName: PAnsiChar;
  end;
  TChooseColorA = tagCHOOSECOLORA;
  TChooseColor = TChooseColorA;

const
  {$EXTERNALSYM CC_RGBINIT}
  CC_RGBINIT = $00000001;
  {$EXTERNALSYM CC_FULLOPEN}
  CC_FULLOPEN = $00000002;
  {$EXTERNALSYM CC_PREVENTFULLOPEN}
  CC_PREVENTFULLOPEN = $00000004;
  {$EXTERNALSYM CC_SHOWHELP}
  CC_SHOWHELP = $00000008;
  {$EXTERNALSYM CC_ENABLEHOOK}
  CC_ENABLEHOOK = $00000010;
  {$EXTERNALSYM CC_ENABLETEMPLATE}
  CC_ENABLETEMPLATE = $00000020;
  {$EXTERNALSYM CC_ENABLETEMPLATEHANDLE}
  CC_ENABLETEMPLATEHANDLE = $00000040;
  {$EXTERNALSYM CC_SOLIDCOLOR}
  CC_SOLIDCOLOR = $00000080;
  {$EXTERNALSYM CC_ANYCOLOR}
  CC_ANYCOLOR = $00000100;

function ChooseColor(var CC: TChooseColor): Bool; stdcall; external 'comdlg32.dll'  name 'ChooseColorA';  

function ColorDialog(Handle: THandle; FullOpen, PreventFullOpen: Boolean; var Colors: array of TColor): Boolean;
var
  clr: TChooseColor;
  Flags: Integer;
begin
  Result := False;
  Flags := 0;
//  RtlZeroMemory(clr, SizeOf(clr))
  clr.lStructSize := SizeOf(clr);
  clr.hwndOwner := Handle;
  clr.hInstance := hInstance;
  clr.rgbResult := ColorToRGB(Colors[0]);
  clr.lpCustColors := @Colors[1];
  if FullOpen then Flags := CC_FULLOPEN;
  if not PreventFullOpen then Flags := Flags or CC_PREVENTFULLOPEN;
  clr.Flags := {CC_ANYCOLOR or }CC_RGBINIT or Flags;
  if ChooseColor(clr) then
   begin
    Colors[0] := clr.rgbResult;
    Result := True
   end;
end;

function ChangeIconDialog(Handle: THandle; FileName: String; var IconIndex: Integer): Boolean; //07.03.03
var
  nFileName: PWideChar;
  FNLen:Integer;
begin
  FNLen:=Length(FileName)+1;
  nFileName := CoTaskMemAlloc(FnLen * SizeOf(WideChar));
  StringToWideChar(FileName, nFileName, FNLen);
  Result := (SHChangeIconDialog(Handle, nFileName, 0, IconIndex) = 1);     
  //ShowMessage(WideCharToString(nFileName));
  CoTaskMemFree(nFileName);
end;

{function ChangeIconDialog(hOwner :THandle; var FileName: String; var IconIndex: Integer): Boolean; //29.07.03
type
  SHChangeIconProc = function(Wnd: HWND; szFileName: PChar; Reserved: Integer;
    var lpIconIndex: Integer): DWORD; stdcall;
  SHChangeIconProcW = function(Wnd: HWND; szFileName: PWideChar;
    Reserved: Integer; var lpIconIndex: Integer): DWORD; stdcall;
const
  Shell32 = 'shell32.dll';
var
  ShellHandle: THandle;
  SHChangeIcon: SHChangeIconProc;
  SHChangeIconW: SHChangeIconProcW;
  Buf: array [0..MAX_PATH] of Char;
  BufW: array [0..MAX_PATH] of WideChar;
begin
  Result:= False;
  SHChangeIcon:= nil;
  SHChangeIconW:= nil;
  ShellHandle:= Windows.LoadLibrary(PChar(Shell32));
  try
    if ShellHandle <> 0 then begin
      if Win32Platform = VER_PLATFORM_WIN32_NT then
        SHChangeIconW:= GetProcAddress(ShellHandle, PChar(62))
      else
        SHChangeIcon:= GetProcAddress(ShellHandle, PChar(62));
    end;

    if Assigned(SHChangeIconW) then begin
      StringToWideChar(FileName, BufW, SizeOf(BufW));
      Result:= SHChangeIconW(hOwner, BufW, SizeOf(BufW), IconIndex) = 1;
      if Result then
        FileName:= BufW;
    end
    else if Assigned(SHChangeIcon) then begin
      StrPCopy(Buf, FileName);
      Result:= SHChangeIcon(hOwner, Buf, SizeOf(Buf), IconIndex) = 1;
      if Result then FileName:= Buf;
    end
    else
      raise Exception.Create(SNotSupported);
  finally
    if ShellHandle <> 0 then FreeLibrary(ShellHandle);
  end;
end;      }

  { Ole }

{$DEFINE ASM_VER}
function OleInit: Boolean;
asm
  MOV      ECX, [OleInitCount]
  INC      ECX
  LOOP     @@init1
  PUSH     ECX
  CALL     OleInitialize
  TEST     EAX, EAX
  MOV      AL, 0
  JNZ      @@exit
@@init1:
  INC      [OleInitCount]
  MOV      AL, 1
@@exit:
end;
//{$else}
{function OleInit: Boolean;
begin
  if OleInitCount = 0 then
   begin
    Result := False;
    if OleInitialize(nil) <> 0 then Exit;
   end;
  Inc(OleInitCount);
  Result := True;
end; }
//{$endif}

{$define asm_ver}
procedure OleUnInit;
asm
  MOV      ECX, [OleInitCount]
  JECXZ    @@exit
  DEC      [OleInitCount]
  JNZ      @@exit
  CALL     OleUninitialize
@@exit:
end;
//{$else}
{procedure OleUnInit;
begin
  if OleInitCount > 0 then
   begin
    Dec(OleInitCount);
    if OleInitCount = 0 then OleUninitialize;
   end;
end; }
//{$endif}

  { Files }

function FindMatchingFile(var F: TSearchRec):Integer;
var
  LocalFileTime: TFileTime;
begin
  with F do
  begin
    while FindData.dwFileAttributes and ExcludeAttr <> 0 do
      if not FindNextFile(FindHandle, FindData) then
      begin
        Result := GetLastError;
        Exit;
      end;
    FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
    FileTimeToDosDateTime(LocalFileTime, LongRec(Time).Hi,
      LongRec(Time).Lo);
    Size := FindData.nFileSizeLow;
    Attr := FindData.dwFileAttributes;
    Name := FindData.cFileName;
  end;
  Result := 0;
end;

function FindFirst(const Path: string; Attr: Integer;var F: TSearchRec): Integer;
const
  faSpecial = faHidden or faSysFile or faVolumeID or faDirectory;
begin
  F.ExcludeAttr := not Attr and faSpecial;
  F.FindHandle := FindFirstFile(PChar(Path), F.FindData);
  if F.FindHandle <> INVALID_HANDLE_VALUE then
   begin
    Result := FindMatchingFile(F);
    if Result <> 0 then FindClose(F);
   end
  else
   Result := GetLastError;
end;

function FindNext(var F: TSearchRec): Integer;
begin
 if FindNextFile(F.FindHandle, F.FindData) then
  Result := FindMatchingFile(F)
 else
  Result := GetLastError;
end;

procedure FindClose(var F: TSearchRec);
begin
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(F.FindHandle);
    F.FindHandle := INVALID_HANDLE_VALUE;
  end;
end;

function DeleteFile(const FileName: string): Boolean; //05.04.03
begin
  Result := Windows.DeleteFile(PChar(FileName));
end;

function RenameFile(const OldName, NewName: string): Boolean;
begin
  Result := MoveFile(PChar(OldName), PChar(NewName));
end;

function GetCurrentDir: string;
var
  Buffer: array[0..MAX_PATH - 1] of Char;
begin
  SetString(Result, Buffer, GetCurrentDirectory(SizeOf(Buffer), Buffer));
end;

function SetCurrentDir(const Dir: string): Boolean;
begin
  Result := SetCurrentDirectory(PChar(Dir));
end;

function CreateDir(const Dir: string): Boolean;
begin
  Result := CreateDirectory(PChar(Dir), nil);
end;

function RemoveDir(const Dir: string): Boolean;
begin
  Result := RemoveDirectory(PChar(Dir));
end;

(*function DeleteDir(Dir:string):Boolean;
var
  Found  : integer;
  SearchRec : TSearchRec;
begin
  Result := False;
  ChDir(Dir);
  if IOResult<>0 then begin
//   ShowMessage('Не могу войти в каталог: '+Dir);
   Exit;
  end;
 Found := FindFirst('*', faAnyFile, SearchRec);
 while Found = 0 do
  begin
   if (SearchRec.Name<>'.')and(SearchRec.Name<>'..') then
    if (SearchRec.Attr and faDirectory)<>0 then
     begin
     if not DeleteDir(SearchRec.Name) then exit;
     end else
     if not DeleteFile(SearchRec.Name) then begin
//      ShowMessage('Не могу удалить файл: '+SearchRec.Name);
      exit;
     end;
    Found := FindNext(SearchRec);
  end;
  FindClose(SearchRec);
  ChDir('..'); RmDir(Dir);
  Result := IOResult = 0;
end;  *)

function DeleteDir(Dir: String): Boolean; //23.03.04
var
  Found: Boolean;
  SearchRec: TWIN32FindData;
  fh: THandle;
begin
  Result := False;
  Found := True;

  if not SetCurrentDirectory(PChar(Dir)) then begin
//   ShowMessage('Не могу войти в каталог: '+Dir);
   Exit;
  end;

  fh := FindFirstFile('*', SearchRec);
  while Found  do
   begin
    if SearchRec.cFileName[0]<>'.' then
     if (SearchRec.dwFileAttributes and faDirectory) <> 0 then
      begin
       if not DeleteDir(SearchRec.cFileName) then exit;
      end
     else
      if not DeleteFile(SearchRec.cFileName) then begin
//      ShowMessage('Не могу удалить файл: '+SearchRec.Name);
       exit;
      end;
    Found := FindNextFile(fh, SearchRec);
   end;
  Windows.FindClose(fh);
  if (SetCurrentDirectory('..')) and (RemoveDirectory(PChar(Dir))) then
    Result := True;
end; 

{$ifdef asm_ver}
function FileExists(const FileName: String): Boolean; //20.03.03
const
  size_TWin32FindData = SizeOf(TWin32FindData);
asm
  test     eax,eax
  jz       @@exit
  PUSH     EAX
  CALL     GetFileAttributes
  INC      EAX
  JZ       @@exit
  DEC      EAX
  AND      AL, FILE_ATTRIBUTE_DIRECTORY
  SETZ     AL
@@exit:
end;
{$else}
function FileExists(const FileName:String): Boolean;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(FileName));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code = 0);
end;
{$endif}

function FileAge(const FileName: string): Integer; //27.07.03
var
  Handle: THandle;
  FindData: TWin32FindData;
  LocalFileTime: TFileTime;
begin
  Handle := FindFirstFile(PChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
    begin
      FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
      if FileTimeToDosDateTime(LocalFileTime, LongRec(Result).Hi,
        LongRec(Result).Lo) then Exit;
    end;
  end;
  Result := -1;
end;

function FileSetDate(Handle: Integer; Age: Integer): Integer; //02.04.04
var
  LocalFileTime, FileTime: TFileTime;
begin
  Result := 0;
  if DosDateTimeToFileTime(LongRec(Age).Hi, LongRec(Age).Lo, LocalFileTime) and
    LocalFileTimeToFileTime(LocalFileTime, FileTime) and
    SetFileTime(Handle, nil, nil, @FileTime) then Exit;
  Result := GetLastError;
end;

{$ifdef asm_ver}
function DirectoryExists(const Name: string): Boolean; //20.03.03
asm
  PUSH     EAX
  CALL     GetFileAttributes
  INC      EAX
  JZ       @@exit
  DEC      EAX
  AND      AL, FILE_ATTRIBUTE_DIRECTORY
  SETNZ    AL
@@exit:
end;
{$else}
function DirectoryExists(const Name: string): Boolean;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(Name));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;
{$endif}

function ResourceToFile(Instance: THandle; ResName, ResType:pchar; FIleName: string):Boolean;
var
  h:THandle;
  HResInfo: HRSRC;
  HGlobal: THandle;
  ptr:Pointer;
begin
  Result := False;
  HResInfo := FindResource(Instance, PChar(ResName), PChar(ResType));
  if HResInfo = 0 then Exit;
  HGlobal := LoadResource(Instance, HResInfo);
  if HGlobal = 0 then Exit;
  ptr:=LockResource(HGlobal);
  if ptr=nil then Exit;

  h:=FileCreate(FileName);
  FileWrite(h, ptr^, SizeOfResource(Instance, HResInfo));
  FileClose(h);
  Result := True;
end;

var
  GetDiskFreeSpaceEx: function (Directory: PChar; var FreeAvailable,
    TotalSpace: TLargeInteger; TotalFree: PLargeInteger): Bool stdcall = nil;

procedure InitDriveSpacePtr;
var
  Kernel: THandle;
begin
  Kernel := GetModuleHandle(Windows.Kernel32);
  if Kernel <> 0 then
    @GetDiskFreeSpaceEx := GetProcAddress(Kernel, 'GetDiskFreeSpaceExA');
//  if not Assigned(GetDiskFreeSpaceEx) then
//    GetDiskFreeSpaceEx := @BackfillGetDiskFreeSpaceEx;
end;

function InternalGetDiskSpace(Drive: Byte; var TotalSpace, FreeSpaceAvailable: Int64): Bool;
var
  RootPath: array[0..4] of Char;
  RootPtr: PChar;
begin
  InitDriveSpacePtr;

  RootPtr := nil;
  if Drive > 0 then
  begin
    RootPath[0] := Char(Drive + $40);
    RootPath[1] := ':';
    RootPath[2] := '\';
    RootPath[3] := #0;
    RootPtr := RootPath;
  end;
  Result := GetDiskFreeSpaceEx(RootPtr, FreeSpaceAvailable, TotalSpace, nil);
end;

function DiskFree(Drive: Byte): Int64;
var
  TotalSpace: Int64;
begin
  if not InternalGetDiskSpace(Drive, TotalSpace, Result) then Result := -1;
end;

function DiskSize(Drive: Byte): Int64;
var
  FreeSpace: Int64;
begin
  if not InternalGetDiskSpace(Drive, Result, FreeSpace) then Result := -1;
end;

function FileDateToDateTime(FileDate: Integer): TDateTime; //27.07.03
begin
  Result :=
    EncodeDate(
      LongRec(FileDate).Hi shr 9 + 1980,
      LongRec(FileDate).Hi shr 5 and 15,
      LongRec(FileDate).Hi and 31) +
    EncodeTime(
      LongRec(FileDate).Lo shr 11,
      LongRec(FileDate).Lo shr 5 and 63,
      LongRec(FileDate).Lo and 31 shl 1, 0);
end;

{ Registry }

function RegKeyOpenRead( Key: HKey; const SubKey: String ): HKey;
begin
  if RegOpenKeyEx(Key, PChar(SubKey), 0, KEY_READ, Result) <> ERROR_SUCCESS then Result := 0;
end;

function RegKeyOpenWrite( Key: HKey; const SubKey: String ): HKey;
begin
  if RegOpenKeyEx(Key, PChar(SubKey), 0, KEY_READ or KEY_WRITE, Result) <> ERROR_SUCCESS then Result := 0;
end;

function RegKeyOpenCreate( Key: HKey; const SubKey: String ): HKey;
var
  dwDisp: DWORD;
begin
  if RegCreateKeyEx(Key, PChar(SubKey), 0, nil, 0, KEY_ALL_ACCESS, nil, Result, @dwDisp) <> ERROR_SUCCESS then Result := 0;
end;

function RegKeyGetInt( Key: HKey; const ValueName: String ): DWORD;
var
  dwType, dwSize: DWORD;
begin
  dwSize := sizeof( DWORD );
  Result := 0;
  if (Key = 0) or
     (RegQueryValueEx(Key, PChar(ValueName), nil, @dwType, PByte(@Result), @dwSize) <> ERROR_SUCCESS) or
     (dwType <> REG_DWORD) then Result := 0;
end;

function RegKeyGetStr( Key: HKey; const ValueName: String ): String;
var
  dwType, dwSize: DWORD;
  Buffer: PChar;

  function Query: Boolean;
  begin
    Result := RegQueryValueEx(Key, PChar(ValueName), nil, @dwType, Pointer(Buffer), @dwSize) = ERROR_SUCCESS;
  end;
begin
  Result := '';
  if Key = 0 then Exit;
  dwSize := 0;
  Buffer := nil;
  if not Query or (dwType <> REG_SZ){ or (dwType <> REG_MULTI_SZ)} then Exit;
  GetMem(Buffer, dwSize);
  if Query then
    Result := Buffer;
  FreeMem(Buffer);
end;

function RegKeyGetStr_(Key: HKey; const ValueName: String): String; //22.08.03
var
  StrBuffer: array[0..2047] of Char;
  DataType, BufSize: Integer;
begin
//  DataType := REG_SZ ;
  BufSize := SizeOf(StrBuffer) - 1;
  RegQueryValueEx(Key, PChar(ValueName), nil, @DataType, PByte(@StrBuffer), @BufSize);
  Result := StrBuffer;
end;

procedure RegKeyGetMulti(Key: HKey; const ValueName: String; var a: array of Char); //18.10.03
var
  DataType, BufSize: Integer;
begin
  RegQueryValueEx(Key, PChar(ValueName), nil, @DataType, PByte(@a), @BufSize);
end;

function RegKeyGetMultiKey(Key: hKey; ValueName: String): TStringList; //06.04.04
const
  bufsize = 100;
var
  i: integer;
  s1: string;
  Buffer: array[1..bufsize] of char;
begin
  Result := TStringList.Create;
  FillChar(Buffer, bufsize, #0);
  RegKeyGetbin(Key, ValueName, Buffer, BufSize);
  i := 1;
  s1 := '';
  while i < BufSize do
   begin
    if Ord(Buffer[i]) >= 32 then
      s1 := s1 + Buffer[i]
    else
     begin
      if Length(s1) > 0 then
       begin
        Result.Add(s1);
        s1 := '';
       end;
     end;
    Inc(i);
   end;
end;

function RegKeyGetStrEx(Key: HKey; const ValueName: String): String;
var dwType, dwSize: DWORD;
    Buffer: PChar;
    Sz: Integer;
    function Query: Boolean;
    begin
      Result := RegQueryValueEx( Key, PChar( ValueName ), nil, @dwType,
                Pointer( Buffer ), @dwSize ) = ERROR_SUCCESS;
    end;
begin
  Result := '';
  if Key = 0 then Exit;
  dwSize := 0;
  Buffer := nil;
  if not Query or ((dwType <> REG_SZ) and (dwtype <> REG_EXPAND_SZ)) then Exit;
  GetMem( Buffer, dwSize );
  if Query then
   begin
    if dwtype = REG_EXPAND_SZ then
     begin
      Sz := ExpandEnvironmentStrings(Buffer,nil,0);
      SetLength( Result, Sz );
      ExpandEnvironmentStrings(Buffer, PChar(Result), Sz);
     end
    else
     Result := Buffer;
   end;
  FreeMem( Buffer );
end;

function RegKeySetInt( Key: HKey; const ValueName: String; Value: DWORD ): Boolean;
begin
  Result := (Key <> 0) and (RegSetValueEx( Key, PChar( ValueName ), 0, REG_DWORD, @Value, sizeof(DWORD)) = ERROR_SUCCESS);
end;

function RegKeySetStr( Key: HKey; const ValueName: String; const Value: String ): Boolean;
begin
  Result := (Key <> 0) and (RegSetValueEx( Key, PChar( ValueName ), 0, REG_SZ, PChar(Value),
             Length( Value ) + 1 ) = ERROR_SUCCESS);
end;

function RegKeySetStrEx( Key: HKey; const ValueName: string; const Value: string;
                         expand: boolean): Boolean;
var dwType: DWORD;
begin
  dwType := REG_SZ;
  if expand then
    dwType := REG_EXPAND_SZ;
  Result := (Key <> 0) and (RegSetValueEx(Key, PChar(ValueName), 0, dwType,
            PChar(Value), Length(Value) + 1) = ERROR_SUCCESS);
end;

procedure RegKeyClose(Key: HKey);
begin
  RegCloseKey(Key);
end;

function RegKeyDelete( Key: HKey; const SubKey: String ): Boolean;
begin
  Result := FALSE;
  if Key <> 0 then
    Result := RegDeleteKey( Key, PChar( SubKey ) ) = ERROR_SUCCESS;
end;

function RegKeyDeleteValue( Key: HKey; const SubKey: String ): Boolean;
begin
  Result := FALSE;
  if Key <> 0 then
    Result := RegDeleteValue( Key, PChar( SubKey ) ) = ERROR_SUCCESS;
end;

function RegKeyExists( Key: HKey; const SubKey: String ): Boolean;
var K: Integer;
begin
  if Key = 0 then
  begin
    Result := FALSE;
    Exit;
  end;
  K := RegKeyOpenRead( Key, SubKey );
  Result := K <> 0;
  if K <> 0 then
    RegKeyClose( K );
end;

function RegKeyValExists( Key: HKey; const ValueName: String ): Boolean;
var dwType, dwSize: DWORD;
begin
  Result := (Key <> 0) and
            (RegQueryValueEx( Key, PChar( ValueName ), nil,
            @dwType, nil, @dwSize ) = ERROR_SUCCESS);
end;

function RegKeyValueSize( Key: HKey; const ValueName: String ): Integer;
begin
  Result := 0;
  if Key = 0 then Exit;
  RegQueryValueEx( Key, PChar( ValueName ), nil, nil, nil, @ DWORD( Result ) );
end;

function RegKeyGetBin( Key: HKey; const ValueName: String; var Buffer; Count: Integer ): Integer;
begin
  Result := 0;
  if Key = 0 then Exit;
  Result := Count;
  RegQueryValueEx( Key, PChar( ValueName ), nil, nil, @ Buffer, @ Result );
end;

function RegKeySetBin( Key: HKey; const ValueName: String; const Buffer; Count: Integer ): Boolean;
begin
  Result := (Key <> 0) and (RegSetValueEx( Key, PChar( ValueName ), 0,
                    REG_BINARY, @ Buffer, Count ) = ERROR_SUCCESS);
end;

function RegKeyGetDateTime(Key: HKey; const ValueName: String): TDateTime;
begin
  RegKeyGetBin( Key, ValueName, Result, Sizeof( Result ) );
end;

function RegKeySetDateTime(Key: HKey; const ValueName: String; DateTime: TDateTime): Boolean;
begin
  Result := RegKeySetBin( Key, ValueName, DateTime, Sizeof( DateTime ) );
end;

function RegKeyGetKeyNames(const Key: HKEY; var List: TStringList) : Boolean; //23.03.04
var
  I, Size, NumSubKeys, MaxSubKeyLen : DWORD;
  KeyName: String;
begin
  Result := False;
  List.Clear ;
  if RegQueryInfoKey(Key, nil, nil, nil, @NumSubKeys, @MaxSubKeyLen, nil, nil, nil, nil,
nil, nil) = ERROR_SUCCESS then
    begin
      if NumSubKeys > 0 then begin
        for I := 0 to NumSubKeys-1 do
        begin
          Size := MaxSubKeyLen+1;
          SetLength(KeyName, Size);
          //FillChar(KeyName[1],Size,#0);
          RegEnumKeyEx(Key, I, @KeyName[1], Size, nil, nil, nil, nil);
          SetLength(KeyName, lstrlen(@KeyName[1]));
          List.Add(KeyName);
        end;
      end;
      Result:= True;
  end;
end;

function RegKeyGetKeyNamesStr(const Key: HKEY; var List: String) : Boolean;
var
  I, Size, NumSubKeys, MaxSubKeyLen : DWORD;
  KeyName: String;
begin
  Result := False;
  List := '';
  if RegQueryInfoKey(Key, nil, nil, nil, @NumSubKeys, @MaxSubKeyLen, nil, nil, nil, nil,
nil, nil) = ERROR_SUCCESS then
    begin
      if NumSubKeys > 0 then begin
        for I := 0 to NumSubKeys-1 do
        begin
          Size := MaxSubKeyLen+1;
          SetLength(KeyName, Size);
          //FillChar(KeyName[1],Size,#0);
          RegEnumKeyEx(Key, I, @KeyName[1], Size, nil, nil, nil, nil);
          SetLength(KeyName, lstrlen(@KeyName[1]));
          if List='' then List:= KeyName else List := List+#13#10+KeyName;
        end;
      end;
      Result:= True;
  end;
end;

function RegKeyGetKeyNamesSL(const Key: HKEY; var List: TSList) : Boolean;
var
  I, Size, NumSubKeys, MaxSubKeyLen : DWORD;
  KeyName: String;
begin
  Result := False;
  List.Count :=  0;
  if RegQueryInfoKey(Key, nil, nil, nil, @NumSubKeys, @MaxSubKeyLen, nil, nil, nil, nil,
nil, nil) = ERROR_SUCCESS then
    begin
      if NumSubKeys > 0 then begin
        for I := 0 to NumSubKeys-1 do
        begin
          Size := MaxSubKeyLen+1;
          SetLength(KeyName, Size);
          //FillChar(KeyName[1],Size,#0);
          RegEnumKeyEx(Key, I, @KeyName[1], Size, nil, nil, nil, nil);
          SetLength(KeyName, lstrlen(@KeyName[1]));
          SLAdd(List, KeyName);
        end;
      end;
      Result:= True;
  end;
end;

function RegKeyGetValueNamesStr(const Key: HKEY; var List: String): Boolean;
var
  I, Size, NumSubKeys, NumValueNames, MaxValueNameLen: DWORD;
  ValueName: String;
begin
 List := '';
 Result:=False;
 if RegQueryInfoKey(Key, nil, nil, nil, @NumSubKeys, nil, nil, @NumValueNames, @MaxValueNameLen, nil, nil, nil) = ERROR_SUCCESS then
  begin
   if NumValueNames > 0 then
    for I := 0 to NumValueNames - 1 do
     begin
      Size := MaxValueNameLen + 1;
      SetLength(ValueName, Size);
      //FillChar(ValueName[1],Size,#0);
      RegEnumValue(Key, I, @ValueName[1], Size, nil, nil, nil, nil);
      SetLength(ValueName, lstrlen(@ValueName[1]));
      if List='' then List:= ValueName else List := List+#13#10+ValueName;
     end;
    Result := True;
  end ;
end;

function RegKeyGetValueNames(const Key: HKEY; var List: TStringList): Boolean;
var
  I, Size, NumSubKeys, NumValueNames, MaxValueNameLen: DWORD;
  ValueName: String;
begin
//  List := '';
  List.Clear ;
  Result:=False;
  if RegQueryInfoKey(Key, nil, nil, nil, @NumSubKeys, nil, nil, @NumValueNames, @MaxValueNameLen, nil, nil, nil) = ERROR_SUCCESS then
   begin
    if NumValueNames > 0 then
     for I := 0 to NumValueNames - 1 do
      begin
       Size := MaxValueNameLen + 1;
       SetLength(ValueName, Size);
       //FillChar(ValueName[1],Size,#0);
       RegEnumValue(Key, I, @ValueName[1], Size, nil, nil, nil, nil);
       SetLength(ValueName, lstrlen(@ValueName[1]));
       List.Add(ValueName);
      end;
    Result := True;
   end ;
end;

function RegKeyGetValueNamesSL(const Key: HKEY; var List: TSList): Boolean;
var
  I, Size, NumSubKeys, NumValueNames, MaxValueNameLen: DWORD;
  ValueName: String;
begin
 List.Count := 0;
 Result:=False;
 if RegQueryInfoKey(Key, nil, nil, nil, @NumSubKeys, nil, nil, @NumValueNames, @MaxValueNameLen, nil, nil, nil) = ERROR_SUCCESS then
  begin
   if NumValueNames > 0 then
    for I := 0 to NumValueNames - 1 do
     begin
      Size := MaxValueNameLen + 1;
      SetLength(ValueName, Size);
      //FillChar(ValueName[1],Size,#0);
      RegEnumValue(Key, I, @ValueName[1], Size, nil, nil, nil, nil);
      SetLength(ValueName, lstrlen(@ValueName[1]));
      SLAdd(List, ValueName);
     end;
    Result := True;
  end;
end;

function RegKeyGetValueTyp (const Key:HKEY; const ValueName: String) : DWORD;
begin
 Result:= Key ;
 if Key <> 0 then RegQueryValueEx(Key, @ValueName[1], nil, @Result, nil, nil);
end;

procedure RegKeyConnect(MachineName: String; RootKey: HKEY; var RemoteKey: HKEY);
begin
 RegConnectRegistry(PChar(MachineName), RootKey, RemoteKey);
end;

procedure RegKeyDisconnect(RemoteKey: HKEY);
begin
 RegCloseKey(RemoteKey);
end;

procedure RegKeyRenVal(Key:hKey; OldName, NewName: string);
var
 Len:Integer;
 Buffer: PChar;
 DataType: Integer; 
begin
 if RegKeyValExists(Key, OldName) and not RegKeyValExists(Key, NewName) then
  begin
   Len := RegKeyValueSize(Key, OldName);
   if Len > 0 then
    begin
     Buffer := AllocMem(Len);
     try
      RegQueryValueEx(Key, PChar(OldName), nil, @DataType, PByte(Buffer), @Len);
      RegDeleteValue(Key, PChar(OldName));
      RegSetValueEx(Key, PChar(NewName), 0, DataType, PByte(Buffer), Len);
     finally
      FreeMem(Buffer);
     end;
    end;
  end;
end;

procedure SaveSetting(AppName, Section, Key, Value: String);  //vb
var
  reg: hKey;
begin
  reg := RegKeyOpenCreate(HKEY_CURRENT_USER, 'Software\Avl Programs\'+AppName+Section);
  RegKeySetStr(reg, Key, Value);
end;

function GetSetting(Appname, Section, Key, DefValue: String): String;
var
  reg: hKey;
begin
  reg := RegKeyOpenRead(HKEY_CURRENT_USER, 'Software\Avl Programs\'+AppName+Section);
  if RegKeyValExists(reg, Key) then
   Result := RegKeyGetStr(reg, Key)
  else
   Result := DefValue;
end;

procedure DeleteSetting(Appname, Section: String);  //vb
var
  reg: hKey;
begin
  reg := RegKeyOpenWrite(HKEY_CURRENT_USER, 'Software\Avl Programs\'+AppName+Section);
  RegKeyDelete(reg, Section); 
end;

{ IniFiles }

procedure IniUpdateFile(FileName: String);
begin
  WritePrivateProfileString(nil, nil, nil, PChar(FileName));
end;

procedure IniEraseSection(FileName, Section: String);
begin
  WritePrivateProfileString(PChar(Section), nil, nil, PChar(FileName));
end;

procedure IniDeleteKey(FileName, Section, KeyName: String);
begin
  WritePrivateProfileString(PChar(Section), PChar(KeyName), nil, PChar(FileName));
end;

function IniSectionExists(FileName, Section: String): Boolean;
var
  S: TStringList;
begin
  S := TStringList.Create;
  try
    IniGetSectionValues(FileName, Section, S);
    Result := S.Count > 0;
  finally
    S.Free;
  end;
end;

function IniValueExists(FileName, Section, Ident: string): Boolean;
var
  S: TStringList;
begin
  S := TStringList.Create;
  try
    IniGetSection(FileName, Section, S);
    Result := S.IndexOf(Ident) > -1;
  finally
    S.Free;
  end;
end;

procedure IniSetStr(FileName, Section, Key, Value:String);
begin
  WritePrivateProfileString(PChar(Section), PChar(Key), PChar(Value), PChar(FileName));
end;

function IniGetStr(FileName, Section, Key, DefaultValue:String):String;
var
  Buffer: array[0..2047] of Char;
begin
  GetPrivateProfileString(PChar(Section), PChar(Key), PChar(DefaultValue),  Buffer, SizeOf(Buffer), PChar(FileName));
  Result := Buffer;
end;

procedure IniSetInt(FileName, Section, Key:String; Value:Integer);
begin
  WritePrivateProfileString(PChar(Section), PChar(Key), PChar(IntToStr(Value)), PChar(FileName));
end;

function IniGetInt(FileName, Section, Key:String;DefaultValue:Integer):Integer;
begin
  Result := GetPrivateProfileInt(PChar(Section), PChar(Key), DefaultValue, PChar(FileName));
end;

const
 IniBufferSize = 32767;

procedure IniGetSection(FileName, Section: String; var Strings: TStringList);
const
  BufSize = 16384;
var
  Buffer: array[0..2047] of Char ;
  P: PChar;
begin
  Strings.Clear;
  if GetPrivateProfileString(PChar(Section), nil, nil, Buffer, BufSize, PChar(FileName)) <> 0 then
   begin
    P := Buffer;
    while P^ <> #0 do
     begin
      Strings.Add(P);
      Inc(P, StrLen(P) + 1);
     end;
   end;
end; 

procedure IniGetSectionNames(FileName:String; var Sections: TStringList);
var
  i:integer;
  Pc:PChar;
  PcEnd:PChar;
  Buffer:Pointer;
begin
  Sections.Clear ;
  GetMem(Buffer,IniBufferSize);
  Pc:=Buffer;
  i := GetPrivateProfileSectionNames(Buffer, IniBufferSize, PChar(FileName));
  if i=0 then Exit;  
  PcEnd:=Pc+i;
  repeat
    Sections.Add(Pc);
    Pc:=PC+Length(PC)+1;
  until PC>=PcEnd;
  FreeMem(Buffer);
end;

procedure IniGetSectionNamesSL(FileName:String; var Sections: TSList);
var
  i:integer;
  Pc:PChar;
  PcEnd:PChar;
  Buffer:Pointer;
begin
  SLClear(Sections) ;
  GetMem(Buffer,IniBufferSize);
  Pc:=Buffer;
  i := GetPrivateProfileSectionNames(Buffer, IniBufferSize, PChar(FileName));
  if i=0 then Exit;
  PcEnd:=Pc+i;
  repeat
    SLAdd(Sections, Pc);
    Pc:=PC+Length(PC)+1;
  until PC>=PcEnd;
  FreeMem(Buffer);
end;

procedure IniGetSectionValues(FileName, Section: String; var Values: TStringList);
var
  i:integer;
  Pc:PChar;
  PcEnd:PChar;
  Buffer:Pointer;
begin
  Values.Clear ;
  GetMem(Buffer, IniBufferSize);
  try
    Pc:=Buffer;
    i:=GetPrivateProfileSection(PChar(Section), Buffer, IniBufferSize, PChar(FileName));
    if i=0 then Exit;
    PcEnd:=Pc+i;
    repeat
      Values.Add(Pc);
      Pc:=PC + Length(PC) + 1;
    until PC >= PcEnd;
  finally
    FreeMem(Buffer);
  end;
end;

procedure IniGetSectionValuesSL(FileName, Section: String; var Values: TSList);
var
  i:integer;
  Pc:PChar;
  PcEnd:PChar;
  Buffer:Pointer;
begin
  Values.Count := 0;
  GetMem(Buffer, IniBufferSize);
  Pc:=Buffer;
  i:=GetPrivateProfileSection(PChar(Section), Buffer, IniBufferSize, PChar(FileName));
  if i=0 then Exit;   
  PcEnd:=Pc+i;
  repeat
    SLAdd(Values, Pc);
    Pc:=PC + Length(PC) + 1;
  until PC >= PcEnd;
  FreeMem(Buffer);
end;

{ TWinControl }
(*
procedure TWinControl.SetStyle(Style: Integer);
begin
 if Style<>-1 then SetWindowLong(FHandle, GWL_STYLE, Style);
end;

procedure TWinControl.SetStyleEx(ExStyle: Integer);
begin
 if ExStyle<>-1 then  SetWindowLong(FHandle, GWL_EXSTYLE, ExStyle);
end;

function TWinControl.GetText: String;
var
 buf:PChar;
 Length:Integer;
begin
 length := GetWindowTextLength(FHandle);
 GetMem(buf, Length+1);
 GetWindowText(FHandle, buf, Length+1);
 result:=buf;
end;

procedure TWinControl.SetText(const Value: String);
begin
 SetWindowText(FHandle, PChar(Value));
end;

procedure TWinControl.Clear;
begin
 SetText(''); 
end;

*)

{ TApplication :) }

function ExeName: String;
begin
  Result := ParamStr(0);
end;

procedure TWinControl.SetButtonStyle(ADefault: Boolean);
const
 BS_MASK = $000F;
var
  Style: Word;
begin
 if ADefault then Style := BS_DEFPUSHBUTTON else Style := BS_PUSHBUTTON;
 if GetWindowLong(FHandle, GWL_STYLE) and BS_MASK <> Style then Perform(BM_SETSTYLE, Style, 1);
end;

procedure TButton.SetDefault(const Value: Boolean);
begin
  FDefault := Value;
  SetFocus ;
end;

procedure TButton.SetFlat(const Value: Boolean);
begin
  FFlat := Value;
  if Value then
   begin
    SetStyle(FStyle or BS_FLAT);
    FId := 11;
   end
  else
   begin
    SetStyle(FStyle and not BS_FLAT);
    FId := 2;
   end; 
end;

{ TRegistry }

function DataTypeToRegData(Value: Integer): TRegDataType;
begin
  if Value = REG_SZ then Result := rdString
  else if Value = REG_EXPAND_SZ then Result := rdExpandString
  else if Value = REG_DWORD then Result := rdInteger
  else if Value = REG_BINARY then Result := rdBinary
  else Result := rdUnknown;
end;

function IsRelative(const Value: string): Boolean;
begin
  Result := not ((Value <> '') and (Value[1] = '\'));
end;

procedure TRegistry.CloseKey;
begin
 if CurrentKey <> 0 then
  begin
   RegKeyClose(CurrentKey);
   FCurrentKey := 0;
   FCurrentPath := '';
  end;
end;

constructor TRegistry.Create;
begin
  RootKey := HKEY_CURRENT_USER;
  FAccess := KEY_ALL_ACCESS;
end;

constructor TRegistry.Create(AAccess: LongWord);
begin
  Create;
  FAccess := AAccess;
end;

function TRegistry.CreateKey(const Key: string): Boolean;
var
 k:hKey;
begin
 k := RegKeyOpenCreate(RootKey, Key);
 Result := k<>0;
 if Result then RegKeyClose(k);
end;

function TRegistry.DeleteKey(const Key: string): Boolean;
begin
 Result := RegKeyDelete(RootKey, Key);
end;

function TRegistry.DeleteValue(const Name: string): Boolean;
begin
 Result := RegDeleteValue(CurrentKey, PChar(Name)) = ERROR_SUCCESS;
end;

destructor TRegistry.Destroy;
begin
 CloseKey;
 inherited;
end;

{function TRegistry.GetBaseKey(Relative: Boolean): HKey;
begin
 if (CurrentKey = 0) or not Relative then Result := RootKey else Result := CurrentKey;
end;  }

function TRegistry.GetDataInfo(const ValueName: string; var Value: TRegDataInfo): Boolean;
var
  DataType: Integer;
begin
  FillChar(Value, SizeOf(TRegDataInfo), 0);
  Result := RegQueryValueEx(CurrentKey, PChar(ValueName), nil, @DataType, nil,
    @Value.DataSize) = ERROR_SUCCESS;
  Value.RegData := DataTypeToRegData(DataType);
end;

function TRegistry.GetDataSize(const ValueName: string): Integer;
begin
  Result := RegKeyValueSize(FCurrentKEy, ValueName);
end;

procedure TRegistry.GetKeyNames(var Strings: String);
begin
  RegKeyGetKeyNamesStr(FCurrentKey, Strings);
end;

procedure TRegistry.GetValueNames(var Strings: String);
begin
  RegKeyGetValueNamesStr(FCurrentKey, Strings);
end;

{function TRegistry.HasSubKeys: Boolean;
begin

end; }

function TRegistry.KeyExists(const Key: string): Boolean;
begin
 Result := RegKeyExists(FCurrentKey, Key);
end;

{function TRegistry.LoadKey(const Key, FileName: string): Boolean;
begin

end;

procedure TRegistry.MoveKey(const OldName, NewName: string; Delete: Boolean);
begin

end; }

function TRegistry.OpenKey(const Key: string; CanCreate: Boolean): Boolean; //01.04.03
begin
  Result := False;
  if CanCreate then
    FCurrentKey := RegKeyOpenCreate(RootKey, Key)
  else
   if FAccess = KEY_READ then
     FCurrentKey := RegKeyOpenRead(RootKey, Key)
   else
     FCurrentKey := RegKeyOpenWrite(RootKey, Key);

  if FCurrentKey <> 0 then
   begin
    FCurrentPath := Key;
    Result := True;
   end;
end;

function TRegistry.OpenKeyReadOnly(const Key: String): Boolean;
begin
  Result := False;
  FCurrentKey := RegKeyOpenRead(RootKey, Key);
  if FCurrentKey<>0 then
   begin
    FCurrentPath := Key;
    Result := True;
   end;
end;

function TRegistry.ReadBinaryData(const Name: string; var Buffer;BufSize: Integer): Integer;
begin
 result := RegKeyGetBin(FCurrentKey, Name, Buffer, BufSize);
end;

function TRegistry.ReadBool(const Name: string): Boolean;
begin
 Result := RegKeyGetInt(FCurrentKey, Name) <> 0; 
end;

{function TRegistry.ReadCurrency(const Name: string): Currency;
begin

end;

function TRegistry.ReadDate(const Name: string): TDateTime;
begin

end;}

function TRegistry.ReadDateTime(const Name: string): TDateTime;
begin
 Result := RegKeyGetDateTime(FCurrentKey, Name); 
end;

{function TRegistry.ReadFloat(const Name: string): Double;
begin

end;}

function TRegistry.ReadInteger(const Name: string): Integer;
begin
 Result := RegKeyGetInt(FCurrentKey, Name);
end;

function TRegistry.ReadString(const Name: string): string;
begin
 Result := RegKeyGetStr(FCurrentKey, Name);  
end;

{function TRegistry.ReadTime(const Name: string): TDateTime;
begin

end;  }

function TRegistry.RegistryConnect(const UNCName: string): Boolean;
begin
 RegKeyConnect(UNCName, RootKey, FCurrentKey);
 if FCurrentKey<>0 then Result := True else Result := False;
end;

procedure TRegistry.RenameValue(const OldName, NewName: string);
begin
 RegKeyRenVal(FCurrentKey, OldName, NewName); 
end;

{function TRegistry.ReplaceKey(const Key, FileName,
  BackUpFileName: string): Boolean;
begin

end;

function TRegistry.RestoreKey(const Key, FileName: string): Boolean;
begin

end;

function TRegistry.SaveKey(const Key, FileName: string): Boolean;
begin

end; }

procedure TRegistry.SetRootKey(Value: HKEY);
begin
  if RootKey <> Value then
  begin
//    if FCloseRootKey then
//    begin
//      RegCloseKey(RootKey);
//      FCloseRootKey := False;
//    end;
    FRootKey := Value;
    CloseKey;
  end;
end;

{function TRegistry.UnLoadKey(const Key: string): Boolean;
begin

end;}

function TRegistry.ValueExists(const Name: string): Boolean;
begin
 Result := RegKeyValExists(FCurrentKey, Name); 
end;

procedure TRegistry.WriteBinaryData(const Name: string; var Buffer;
  BufSize: Integer);
begin
  RegKeySetBin(FCurrentKey, Name, Buffer, BufSize);
end;

procedure TRegistry.WriteBool(const Name: string; Value: Boolean);
begin
  RegKeySetInt(FCurrentKey, Name, Ord(Value));
end;

{procedure TRegistry.WriteCurrency(const Name: string; Value: Currency);
begin

end;

procedure TRegistry.WriteDate(const Name: string; Value: TDateTime);
begin

end; }

procedure TRegistry.WriteDateTime(const Name: string; Value: TDateTime);
begin
 RegKeySetDateTime(FCurrentKey, Name, Value); 
end;

procedure TRegistry.WriteExpandString(const Name, Value: string);
begin
 RegKeySetStrEx(FCurrentKey, Name, Value, True);
end;

{procedure TRegistry.WriteFloat(const Name: string; Value: Double);
begin

end; }

procedure TRegistry.WriteInteger(const Name: string; Value: Integer);
begin
 RegKeySetInt(FCurrentKey, Name, Value); 
end;

procedure TRegistry.WriteString(const Name, Value: string);
begin
 RegKeySetStr(FCurrentKey, Name, Value);   
end;

{procedure TRegistry.WriteTime(const Name: string; Value: TDateTime);
begin

end;}

{ TOpenDialog }

constructor TOpenDialog.Create(AParent: TForm); //07.03.03
begin
  if AParent <> nil then
    FHandle := AParent.Handle;
end;

function TOpenDialog.Execute: Boolean; //07.03.03
var
 opt:Integer;
begin
 opt:=0;
 if ofReadOnly in foptions then opt:=OFN_READONLY;
 if ofHideReadOnly in foptions then opt:=opt or OFN_HIDEREADONLY;
 if ofFileMustExist in foptions then opt:=opt or OFN_FILEMUSTEXIST;
 if ofPathMustExist in foptions then opt:=opt or OFN_PATHMUSTEXIST;
 Result := OpenSaveDialog(FHandle, True, FTitle, FDefExtension,
   FFilter, FInitialDir, FFilterIndex, opt, FFileName);
end;

{ TSaveDialog }

constructor TSaveDialog.Create(AParent: TForm); //07.03.03
begin
  if AParent <> nil then
    FHandle := AParent.Handle;
end;

function TSaveDialog.Execute: Boolean; //07.03.03
var
 opt:Integer;
begin
 opt:=0;
 if ofReadOnly in foptions then opt:=OFN_READONLY;
 if ofHideReadOnly in foptions then opt:=opt or OFN_HIDEREADONLY;
 if ofFileMustExist in foptions then opt:=opt or OFN_FILEMUSTEXIST;
 if ofPathMustExist in foptions then opt:=opt or OFN_PATHMUSTEXIST;
 Result := OpenSaveDialog(FHandle, False, FTitle, FDefExtension,
   FFilter, FInitialDir, FFilterIndex, opt, FFileName);
end;    

{ TStringList }

function TStringList.Add(const S: string): Integer;
begin
//  Changing;
  if FCount = FCapacity then Grow;
//  if Index < FCount then
//    System.Move(FList^[Index], FList^[Index + 1],
//      (FCount - Index) * SizeOf(TStringItem));
  with FList^[FCount] do
  begin
    Pointer(FString) := nil;
    FObject := nil;
    FString := S;
  end;
  Result := FCount;
  Inc(FCount);
  Changed;
end;

function TStringList.AddObject(const S: string; Obj: TObject): Integer;
begin
  Result := Add(S);
  PutObject(Result, Obj);
end;

procedure TStringList.Clear;
begin
  if FCount <> 0 then
   begin
//    Changing;
    Finalize(FList^[0], FCount);
    FCount := 0;
    SetCapacity(0);
    Changed;
   end;
end;

constructor TStringList.Create;
begin
 FCount:=0;
end;

destructor TStringList.Destroy;
begin
  Clear;
  FreeMem(FList, FCapacity);
end;

function TStringList.Get(Index: Integer): string;
begin
  if (Index < 0) or (Index >= FCount) then Exit;
  Result := FList^[Index].FString;
end;

function TStringList.GetCapacity: Integer;
begin
 Result := FCapacity;
end;

function TStringList.GetCount: Integer;
begin
 Result := FCount;
end;

function TStringList.GetTextStr: string;
var
  I, L, Size, sCount: Integer;
  P: PChar;
  S: string;
begin
  sCount := GetCount;
  Size := 0;
  for I := 0 to sCount - 1 do Inc(Size, Length(Get(I)) + 2);
  SetString(Result, nil, Size);
  P := Pointer(Result);
  for I := 0 to sCount - 1 do
  begin
    S := Get(I);
    L := Length(S);
    if L <> 0 then
    begin
      System.Move(Pointer(S)^, P^, L);
      Inc(P, L);
    end;
    P^ := #13;
    Inc(P);
    P^ := #10;
    Inc(P);
  end;
end;

procedure TStringList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4 else
    if FCapacity > 8 then Delta := 16 else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TStringList.GetObject(Index: Integer): TObject; //13.07.03
begin
  if (Index < 0) or (Index >= FCount) then
    Result := nil
  else
    Result := FList^[Index].FObject;
end;

procedure TStringList.InsertObject(Index: Integer; const S: string; //13.07.03
  AObject: TObject);
begin
  Insert(Index, S);
  PutObject(Index, AObject);
end;

procedure TStringList.PutObject(Index: Integer; AObject: TObject); //13.07.03
begin
  if (Index < 0) or (Index >= FCount) then Exit;
  FList^[Index].FObject := AObject;
end;

procedure TStringList.Put(Index: Integer; const Value: string); //13.07.03
var
  TempObject: TObject;
begin
  TempObject := GetObject(Index);
  Delete(Index);
  InsertObject(Index, Value, TempObject);
end;

procedure TStringList.SetCapacity(NewCapacity: Integer);
begin
  ReallocMem(FList, NewCapacity * SizeOf(TStringItem));
  FCapacity := NewCapacity;
end;

procedure TStringList.SetTextStr(const Value: string); //11.07.03
var
  P, Start: PChar;
  S: string;
begin
//  BeginUpdate;
  try
    Clear;
    P := Pointer(Value);
    if P <> nil then
      while P^ <> #0 do
      begin
        Start := P;
        while not (P^ in [#0, #10, #13]) do Inc(P);
        SetString(S, Start, P - Start);
        Add(S);
        if P^ = #13 then Inc(P);
        if P^ = #10 then Inc(P);
      end;
  finally
//    EndUpdate;
  end;
end;

procedure TStringList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then Exit;//Error('List index error', Index);
//  Changing;
  Finalize(FList^[Index]);
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(TStringItem));
//  Changed;
end;

procedure TStringList.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

{ Simple TStringList - TSList }

{$ifdef asm_ver}
procedure SLAdd(var List:TSList; S:String);
begin
 List.Strings[List.Count]:=S;
 Inc(List.Count);
(*asm
{
        MOV      EAX, [EAX].fList
        MOV      EAX, [EAX].TList.fItems
        MOV      EAX, [EAX+EDX*4]
}
 mov [List].Strings[1], [s]
 inc [List].Count  *)
end;
{$else}
procedure SLAdd(var List:TSList; S:String);
begin
 List.Strings[List.Count]:=S;
 Inc(List.Count);
end;
{$endif}

function SLText(List:TSList):String;
var
 i:Integer;
begin
 for i:=0 to List.Count-1 do Result:=Result+List.Strings[i]+#13#10
end;

(*{$ifdef asm_ver}
procedure SLClear(var List:TSList);
asm
 mov [List].Count, 0
end;
{$else}*)
procedure SLClear(var List:TSList);
begin
 List.Count:=0;
end;
//{$endif}

function SLStrings(var List:TSList; Index:Integer):String;
begin
 Result := '';
 if (Index>List.Count-1) or (Index<0) then Exit;
 Result := List.Strings[Index];
end;

procedure SLSetText(var List:TSList; S:String);
var
 i,j:Integer;
begin
 List.Count:=0;
 j:=1;
 for i:=1 to Length(s) do
  if s[i]=#13 then
   begin
    //SLAdd(List, Copy(s,j,i-j));
     List.Strings[List.Count]:=Copy(s,j,i-j);
     Inc(List.Count);
    //---------------------------
    if s[i+1]=#10 then j:=i+2 else j:=i+1;
   end;
// SLAdd(List, Copy(s,j,i-j));
 List.Strings[List.Count]:=Copy(s,j,Length(s)-j+1);
 Inc(List.Count);
end;

procedure SLDelete(var List:TSList; Index: Integer);
begin
  if (Index < 0) or (Index >= List.Count) then Exit;//Error('List index error', Index);
//  Changing;
  Finalize(List.Strings[Index]);
  Dec(List.Count);
  if Index < List.Count then
    System.Move(List.Strings[Index + 1], List.Strings[Index],
      (List.Count - Index) * SizeOf(TStringItem));
//  Changed;
end;

function SLIndexOf(List:TSList;S:String):Integer;
var
 i:Integer;
begin
 Result := -1;
 for i:=0 to List.Count do
  if LowerCase(List.Strings[i])=LowerCase(s) then
   begin
    Result := i;
    Exit;
   end; 
end;

(*function SLInsert(List:TSList; Index: Integer; S:String): Integer;
var
  i: Integer;
begin
{  if Item > SL.Count then Exit;
  for i:=0 to Item-1 do
   begin

   end; }
end;  *)                

procedure TStringList.Assign(Strings: TStringList);
begin
  SetTextStr(Strings.Text); 
end;

procedure TStringList.SetSorted(const Value: Boolean);
begin
  if FSorted <> Value then
  begin
    if Value then Sort;
    FSorted := Value;
  end;
end;

procedure TStringList.ExchangeItems(Index1, Index2: Integer);
var
  Temp: Integer;
  Item1, Item2: PStringItem;
begin
  Item1 := @FList^[Index1];
  Item2 := @FList^[Index2];
  Temp := Integer(Item1^.FString);
  Integer(Item1^.FString) := Integer(Item2^.FString);
  Integer(Item2^.FString) := Temp;
{  Temp := Integer(Item1^.FObject);
  Integer(Item1^.FObject) := Integer(Item2^.FObject);
  Integer(Item2^.FObject) := Temp;  }
end;

procedure TStringList.QuickSort(L, R: Integer; SCompare: TStringListSortCompare);
var
  I, J, P: Integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while SCompare(Self, I, P) < 0 do Inc(I);
      while SCompare(Self, J, P) > 0 do Dec(J);
      if I <= J then
      begin
        ExchangeItems(I, J);
        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSort(L, J, SCompare);
    L := I;
  until I >= R;
end;

procedure TStringList.Insert(Index: Integer; const S: string); //27.06.03
begin
  if Sorted then Exit;//Error(@SSortedListError, 0);
  if (Index < 0) or (Index > FCount) then Exit;//Error(@SListIndexError, Index);
  InsertItem(Index, S);
end;

procedure TStringList.InsertItem(Index: Integer; const S: string); //27.06.03
begin
  //Changing;
  if FCount = FCapacity then Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(TStringItem));
  with FList^[Index] do
  begin
    Pointer(FString) := nil;
    //FObject := nil;
    FString := S;
  end;
  Inc(FCount);
  //Changed;
end;

function StringListAnsiCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := AnsiCompareText(List.FList^[Index1].FString,
                            List.FList^[Index2].FString);
end;

procedure TStringList.Sort;
begin
  CustomSort(StringListAnsiCompare);
end;

procedure TStringList.CustomSort(Compare: TStringListSortCompare);
begin
  if not Sorted and (FCount > 1) then
  begin
//    Changing;
    QuickSort(0, FCount - 1, Compare);
    Changed;
  end;
end;

procedure TStringList.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TStringList.LoadFromStream(Stream: TStream);
var
  Size: Integer;
  S: string;
begin
//  BeginUpdate;
  try
    Size := Stream.Size - Stream.Position;
    SetString(S, nil, Size);
    Stream.Read(Pointer(S)^, Size);
    SetTextStr(S);
  finally
//    EndUpdate;
  end;
end;

function TStringList.IndexOf(const S: string): Integer;
begin
  for Result := 0 to GetCount - 1 do
    if AnsiCompareText(Get(Result), S) = 0 then Exit;
  Result := -1;
end;

function TStringList.GetValue(const Name: string): string;
var
  I: Integer;
begin
  I := IndexOfName(Name);
  if I >= 0 then
    Result := Copy(Get(I), Length(Name) + 2, MaxInt) else
    Result := '';
end;

procedure TStringList.SetValue(const Name, Value: string);
var
  I: Integer;
begin
  I := IndexOfName(Name);
  if Value <> '' then
  begin
    if I < 0 then I := Add('');
    Put(I, Name + '=' + Value);
  end else
  begin
    if I >= 0 then Delete(I);
  end;
end;

function TStringList.IndexOfName(const Name: string): Integer;
var
  P: Integer;
  S: string;
begin
  for Result := 0 to GetCount - 1 do
  begin
    S := Get(Result);
    P := AnsiPos('=', S);
    if (P <> 0) and (AnsiCompareText(Copy(S, 1, P - 1), Name) = 0) then Exit;
  end;
  Result := -1;
end;

procedure TStringList.SaveToFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TStringList.SaveToStream(Stream: TStream);
var
  S: string;
begin
  S := GetTextStr;
  Stream.WriteBuffer(Pointer(S)^, Length(S));
end;

{ TIniFile }

constructor TIniFile.Create(const FileName: String);
begin
  FFileName := FileName;
end;

procedure TIniFile.DeleteKey(const Section, Ident: String);
begin
  IniDeleteKey(FFileName, Section, Ident);
end;

procedure TIniFile.EraseSection(const Section: String);
begin
  IniEraseSection(FFileName, Section);
end;

function TIniFile.ReadBool(const Section, Ident: string; Default: Boolean): Boolean;
begin
  Result := ReadInteger(Section, Ident, Ord(Default)) <> 0;
end;

function TIniFile.ReadInteger(const Section, Ident: String; Default: Integer): Longint;
begin
  Result := IniGetInt(FFileName, Section, Ident, Default);
end;

procedure TIniFile.ReadSection(const Section: String; Strings: TStringList);
begin
  IniGetSection(FFilename, Section, Strings);
end;

procedure TIniFile.ReadSections(Strings: TStringList);
begin
  IniGetSectionNames(FFileName, Strings);
end;

procedure TIniFile.ReadSectionValues(const Section: String; Strings: TStringList);
begin
  IniGetSectionValues(FFileName, Section, Strings);
end;

function TIniFile.ReadString(const Section, Ident, Default: string): string;
begin
  Result := IniGetStr(FFileName, Section, Ident, Default);
end;

function TIniFile.ReadFloat(const Section, Ident: String; Default: Single): Single;
begin
  Result := StrToFloat(IniGetStr(FFileName, Section, Ident, FloatToStr(Default)));
end;

function TIniFile.SectionExists(const Section: String): Boolean;
begin
  Result := IniSectionExists(FFileName, Section);
end;

procedure TIniFile.UpdateFile;
begin
  IniUpdateFile(FFileName);
end;

procedure TIniFile.WriteBool(const Section, Ident: string; Value: Boolean);
//const
//  Values: array[Boolean] of string = ('0', '1');
begin
//  WriteString(Section, Ident, Values[Value]);
  WriteInteger(Section, Ident, Ord(Value));
end;

procedure TIniFile.WriteInteger(const Section, Ident: string; Value: Integer);
begin
  IniSetInt(FFileName, Section, Ident, Value);
end;

procedure TIniFile.WriteString(const Section, Ident, Value: String);
begin
  IniSetStr(FFileName, Section, Ident, Value);
end;

procedure TIniFile.WriteFloat(const Section, Ident: String; Value: Single);
begin
  IniSetStr(FFileName, Section, Ident, FloatToStr(Value));
end;

{ TFileStream }

constructor TFileStream.Create(const FileName: string; Mode: Word);
begin
  if Mode = fmCreate then
   FHandle := FileCreate(FileName)
  else
   FHandle := FileOpen(FileName, Mode);
end;

destructor TFileStream.Destroy;
begin
  if FHandle >= 0 then FileClose(FHandle);
end;

function TFileStream.Seek(Offset: Integer; Origin: Word): Longint;
begin
  Result := FileSeek(FHandle, Offset, Origin);
end;

procedure TFileStream.SetSize(NewSize: Longint);
var
  Pos: Longint;
begin
  Pos := Position;
  Position := NewSize;
  SetEndOfFile(FHandle);
  Position := Pos;
end;

{ TStream }

function TStream.CopyFrom(Source: TStream; Count: Integer): Longint;
const
  MaxBufSize = $10000;//$100000;
var
  BufSize, N: Integer;
  Buffer: PChar;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end;
  Result := Count;
  if Count > MaxBufSize then BufSize := MaxBufSize else BufSize := Count;
  GetMem(Buffer, BufSize);
  while Count <> 0 do
  begin
    if Count > BufSize then N := BufSize else N := Count;
    Source.ReadBuffer(Buffer^, N);
    WriteBuffer(Buffer^, N);
    Dec(Count, N);
  end;
  FreeMem(Buffer, BufSize);
end;

function TStream.GetPosition: Longint;
begin
  Result := Seek(0, 1);
end;

function TStream.GetSize: Longint;
var
  Pos: Longint;
begin
  Pos := Seek(0, 1);
  Result := Seek(0, 2);
  Seek(Pos, 0);
end;

procedure TStream.ReadBuffer(var Buffer; Count: Integer);
begin
  if (Count = 0) or (Read(Buffer, Count) = Count) then Exit;
end;

procedure TStream.SetPosition(const Value: Longint);
begin
  Seek(Value, 0);
end;

procedure TStream.SetSize(NewSize: Longint);
begin
  // default = do nothing  (read-only streams, etc)
end;

procedure TStream.WriteBuffer(const Buffer; Count: Integer);
begin
  if (Count = 0) or (Write(Buffer, Count) = Count) then Exit;
end;

{ THandleStream }

constructor THandleStream.Create(AHandle: Integer);
begin
 FHandle := AHandle;
end;

function THandleStream.Read(var Buffer; Count: Integer): Longint;
begin
  Result := FileRead(FHandle, Buffer, Count);
  if Result = -1 then Result := 0;
end;

function THandleStream.Seek(Offset: Integer; Origin: Word): Longint;
begin
  Result := FileSeek(FHandle, Offset, Origin);
end;

function THandleStream.Write(const Buffer; Count: Integer): Longint;
begin
  Result := FileWrite(FHandle, Buffer, Count);
  if Result = -1 then Result := 0;      
end;

{ TTrayIcon }
(*
//var
//  WM_TASKBARCREATED: DWORD; // Обновление(крах) Explorer'а

constructor TTrayIcon.Create;
begin
//  WM_TASKBARCREATED := RegisterWindowMessage('TaskbarCreated');
//  FHandle := AllocateHWnd(WndProcTray);
end;

procedure TTrayIcon.DelNIcon;
begin
  Shell_NotifyIcon(nim_delete, @NI);
end;

destructor TTrayIcon.Destroy;
begin
  inherited;
  DelNIcon;
end;

{procedure TTrayIcon.New;
begin
  FHandle := Handle;
  SetNIcon;
end;}

procedure TTrayIcon.SetHint(const Value: String);
begin
  FHint := Value;
end;

procedure TTrayIcon.SetIcon(const Value:hIcon);
begin
  FIcon := Value;
end;

procedure TTrayIcon.SetNIcon;
begin
 NI.uFlags := nif_icon or nif_tip or nif_message;
 NI.cbSize := SizeOf(NI);
 NI.Wnd := FHandle;
// StrLCopy(ni.szTip, PChar(fHint), Length(fHint));
// for i:=0 to Length(fHint)-1 do ni.szTip[i] := fHint[i+1];
 NI.hIcon := fIcon;  //LoadIcon(HInstance, 'MAINICON');
// NI.uCallBackMessage := CM_TICON;
 Shell_NotifyIcon(nim_add, @NI);
end; *)

{ TResourceStream }

constructor TResourceStream.Create(Instance: THandle; const ResName: string; ResType: PChar);
begin
  inherited Create;
  Initialize(Instance, PChar(ResName), ResType);
end;

constructor TResourceStream.CreateFromID(Instance: THandle; ResID: Integer; ResType: PChar);
begin
  inherited Create;
  Initialize(Instance, PChar(ResID), ResType);
end;

procedure TResourceStream.Initialize(Instance: THandle; Name, ResType: PChar);
begin
  HResInfo := FindResource(Instance, Name, ResType);
  if HResInfo = 0 then Exit;
  HGlobal := LoadResource(Instance, HResInfo);
  if HGlobal = 0 then Exit;
  SetPointer(LockResource(HGlobal), SizeOfResource(Instance, HResInfo));
end;

destructor TResourceStream.Destroy;
begin
  UnlockResource(HGlobal);
  FreeResource(HGlobal);
  inherited Destroy;
end;

{ TCustomMemoryStream }

procedure TCustomMemoryStream.SaveToFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TCustomMemoryStream.SaveToStream(Stream: TStream);
begin
  if FSize <> 0 then
   Stream.WriteBuffer(FMemory^, FSize);
end;

{$ifdef asm_ver}
procedure TCustomMemoryStream.SetPointer(Ptr: Pointer; Size: Integer);
asm
 mov [eax].FMemory, edx
 mov [eax].FSize, Size
end;
{$else}
procedure TCustomMemoryStream.SetPointer(Ptr: Pointer; Size: Integer);
begin
  FMemory := Ptr;
  FSize := Size;
end;
{$endif}

function TCustomMemoryStream.Seek(Offset: Integer; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: Inc(FPosition, Offset);
    soFromEnd: FPosition := FSize + Offset;
  end;
  Result := FPosition;
end;

function TCustomMemoryStream.Read(var Buffer; Count: Integer): Longint;
begin
  if (FPosition >= 0) and (Count >= 0) then
  begin
    Result := FSize - FPosition;
    if Result > 0 then
    begin
      if Result > Count then Result := Count;
      Move(Pointer(Longint(FMemory) + FPosition)^, Buffer, Result);
      Inc(FPosition, Result);
      Exit;
    end;
  end;
  Result := 0;
end;

{ TTimer }

constructor TTimer.Create{(AOwner: TComponent)};
begin
  FInterval := 1000;
  FEnabled := True;
  FWindowHandle := AllocateHWnd(WndProc);
end;

constructor TTimer.CreateEx(Interval: Cardinal; Enabled: Boolean); //26.02.03
begin
  FInterval := Interval;
  FOnTimer := OnTimer;
  FEnabled := Enabled;
  FWindowHandle := AllocateHWnd(WndProc);
end;

destructor TTimer.Destroy;
begin
  FEnabled := False;
  UpdateTimer;
//  DeallocateHWnd(FWindowHandle);
//  inherited Destroy;
end;

procedure TTimer.WndProc(var Msg: TMessage);
begin
  with Msg do
   begin
    if Msg = WM_TIMER then
     if Assigned(FOnTimer) then FOnTimer(Self);
    Result := DefWindowProc(FWindowHandle, Msg, wParam, lParam);
   end; 
end;

procedure TTimer.UpdateTimer;   
begin
  KillTimer(FWindowHandle, 1);
  if (FInterval <> 0) and FEnabled and Assigned(FOnTimer) then
    {if }SetTimer(FWindowHandle, 1, FInterval, nil)// = 0 then
//      raise EOutOfResources.Create(SNoTimers);
end;

procedure TTimer.SetEnabled(Value: Boolean);
begin
  if Value <> FEnabled then
   begin
    FEnabled := Value;
    UpdateTimer;
   end;
end;

procedure TTimer.SetInterval(Value: Cardinal);
begin
  if Value <> FInterval then
  begin
    FInterval := Value;
    UpdateTimer;
  end;
end;

procedure TTimer.SetOnTimer(Value: TOnEvent);
begin
  FOnTimer := Value;
  UpdateTimer;
end;

procedure TTimer.Timer;
begin
  if Assigned(FOnTimer) then FOnTimer(Self);
end;

{ TListBox }

constructor TListBox.Create(AParent: TWinControl; Style: TListBoxStyle);
const
  Styles: array[TListBoxStyle] of DWORD = (0, LBS_OWNERDRAWFIXED, LBS_OWNERDRAWVARIABLE, LBS_MULTIPLESEL or LBS_EXTENDEDSEL, LBS_SORT);
begin
  inherited Create(AParent);
  FWidth := 121;
  FHeight := 97;
  FClassName := 'listbox';
  FExStyle := WS_EX_CLIENTEDGE;
  FStyle :=  WS_CHILD or LBS_NOTIFY or LBS_NOINTEGRALHEIGHT or LBS_HASSTRINGS or
       WS_VISIBLE or WS_VSCROLL or Styles[Style];
  if Style=lbSorted then Sorted:=true;
  FColor := GetSysColor(COLOR_WINDOW);
  CreateWnd;
end;

{procedure TListBox.SetItems(Sender: TObject);
begin
 Text := FItems.Text ;
end;  }

function TListBox.GetItemIndex: Integer; //03.07.03
begin
  Result := Perform(LB_GETCURSEL{LB_GETCARETINDEX}, 0, 0);
end;

procedure TListBox.SetItemIndex(const Value: Integer);
begin
  Perform(LB_SETCARETINDEX, Value, MAKELPARAM(word(false),0));
  Perform(LB_SETCURSEL, Value, 0);
end;

procedure TListBox.Clear;
begin
  Perform(LB_RESETCONTENT, 0, 0);
end;

function TListBox.GetItem(Index: Integer): String;
begin
  SetLength(Result, Perform(LB_GETTEXTLEN, Index, 0));
  SetLength(Result, Perform(LB_GETTEXT, Index, Longint(PChar(Result))));
end;

function TListBox.ItemAdd(s: String): Integer;
begin
  Result := Perform(LB_ADDSTRING, 0, Longint(PChar(s)));
  if Result < 0 then Result := -1;
end;

function TListBox.ItemCount: Integer;
begin
  Result := Perform(LB_GETCOUNT, 0, 0);
end;

function TListBox.ItemInsert(Index: Integer; s: String): Integer; //11.03.03
begin
  Result := Perform(LB_INSERTSTRING, Index, Longint(PChar(s)));
  if Result < 0 then Result := -1;
end;

procedure TListBox.SetLBSorted(const Value: Boolean); //11.03.03
begin
  if FSorted <> Value then
   begin
    FSorted := Value;
    if FSorted then Style := Style or LBS_SORT else Style := Style and not LBS_SORT;
   end;
end;

function TListBox.GetLBObject(ItemIndex: Integer): TObject; //11.03.03
begin
  //Result := nil;
  //if (Index < 0) or (Index >= Count) then Exit;
  Result := TObject(Perform(LB_GETITEMDATA, ItemIndex, 0));
  //if Longint(Result) = LB_ERR then FError := -1;
end;

procedure TListBox.SetLBObject(ItemIndex: Integer; const Value: TObject); //11.03.03
begin
  Perform(LB_SETITEMDATA, ItemIndex, Longint(Value));
end;

function TListBox.GetLBItemText: String; //11.03.03
var
  i: Integer;
begin
  for i:=0 to ItemCount-1 do
   begin
    if Result = '' then
     Result := Items[i]
    else
     Result := Result + #13#10 + Items[i];
   end;
end;

{procedure TListBox.SetLBItemText(const Value: String);
begin
  Clear;
end; }

procedure TListBox.SetItem(ItemIndex: Integer; const Value: String); //11.03.03
begin
  if (ItemIndex < 0) or (ItemIndex >= ItemCount) then Exit;
  ItemDelete(ItemIndex);
  ItemInsert(ItemIndex, Value);
end;

procedure TListBox.ItemDelete(Index: Integer); //11.03.03
begin
  Perform(LB_DELETESTRING, Index, 0);
end;

{ TCheckBox }

procedure TCheckBox.Click;
begin 
  Checked := not Checked;
  inherited Click;
end;

constructor TCheckBox.Create(AParent: TWinControl; Caption: String);
begin
 inherited Create(AParent);
 FWidth := 145;
 FHeight := 21;
 FBkMode := bk_Transparent;
 FClassName := 'BUTTON';
 FCaption := PChar(Caption);
 FChecked := false;
 FExStyle := ws_Ex_ControlParent;
 FStyle := ws_child or bs_Checkbox or bs_Notify  or ws_Visible;
 FColor := clBtnFace;

 CreateWnd ;
end;

procedure TCheckBox.SetChecked(const Value: Boolean);
//var code : longint;
begin
  FChecked := Value;
  if Value then
   PostMessage(FHandle, BM_SETCHECK, BST_CHECKED,0)
  else
   PostMessage(FHandle, BM_SETCHECK, BST_UNCHECKED,0);
{  if FHandle <> INVALID_HANDLE_VALUE then
  begin   }
{  code := BST_UNCHECKED;
   if FChecked then code := BST_CHECKED;
   PostMessage(FHandle,BM_SETCHECK,code,0);    }
{   Invalidate;
  end; }
end;

{ TProgressBar }

constructor TProgressBar.Create(AParent: TWinControl);
begin
 inherited Create(AParent);
 InitCommonControls ; 
 FWidth := 150;
 FHeight := 16;
 FClassName := 'msctls_progress32';

// FExStyle := ws_Ex_ClientEdge;
 FStyle := WS_CHILD or WS_VISIBLE;
 FColor := clBtnFace;

 CreateWnd;

 FMax := 100;
 FStep := 1;
 FPosition := 0; 
end;

procedure TProgressBar.SetMin(const Value: word);
begin
 if FMin <> Value then
  begin
   FMin := Value;
   Perform(PBM_SETRANGE, 0, MAKELPARAM(FMin,FMax));
  end;
end;

procedure TProgressBar.SetMax(const Value: word);
begin
 if FMax <> Value then
  begin
   FMax := Value;
//   Perform(PBM_SETRANGE, 0, MAKELPARAM(0,Value));
    Perform(PBM_SETRANGE, 0, MAKELPARAM(FMin,FMax));
  end;
end;

procedure TProgressBar.SetPBPosition(const Value: Word);
begin
 if FPosition <> Value then
  begin
   FPosition := Value;
   Perform(PBM_SETPOS, Value, 0);
  end;
end;

{procedure TProgressBar.SetSmooth(const Value: Boolean);
begin
 FSmooth := Value;
 if Value then
  FStyle := FStyle or 1
 else
  FStyle := FStyle or not PBS_SMOOTh;
 SetStyle(FStyle);
end; }

procedure TProgressBar.SetStep(const Value: word);
begin
  FStep := Value;
  Perform(PBM_SETSTEP, Value, 0);
end;

procedure TWinControl.SetFocus;
begin
 windows.SetFocus(FHandle); 
end;

procedure TWinControl.WMCtlColor(var AMsg: TMessage);
var
  ctl : TWinControl;
begin
  Dispatch(AMsg);

//  if FBrush<>0 then
  with AMsg do
  begin
   ctl := TWinControl(GetProp(HWND(LParam), App_Id));
   if ctl = nil then Exit;
   SetBkColor(HDC(WParam), ctl.FColor);
   SetTextColor(HDC(WParam), ctl.FTextColor);
   case ctl.FBkMode of
     bk_Opaque:
       begin
         Windows.SetBkMode(HDC(WParam), OPAQUE);
         if ctl.FBrush<>0 then Result := ctl.FBrush;
       end;
     bk_Transparent,bk_Slide:
       begin
         Windows.SetBkMode(HDC(WParam),TRANSPARENT);
         repeat
           ctl := ctl.FParent;
         until (ctl<>nil) or (ctl.FBrush > 0);
         if ctl.FBrush<>0 then Result := ctl.FBrush;  
       end;
   end;    
  end;

{  if FBrush<>0 then
  with AMsg do
  begin
   ctl := TWinControl(GetProp(HWND(LParam), ID_SELF));
   if ctl = nil then Exit;
   SetBkColor(HDC(WParam), ctl.FColor);
   SetTextColor(HDC(WParam), ctl.FTextColor);
   case ctl.FBkMode of
     bk_Opaque:
       begin
         Windows.SetBkMode(HDC(WParam), OPAQUE);
         Result := ctl.FBrush;
       end;
     bk_Transparent,bk_Slide:
       begin
         Windows.SetBkMode(HDC(WParam),TRANSPARENT);
         repeat
           ctl := ctl.FParent;
         until ctl.FBrush > 0;
         Result := ctl.FBrush;
       end;
   end;
  end;}
end;

function TWinControl.GetClientHeight: integer;
var
  R : TRect;
begin
  Windows.GetClientRect(FHandle, R);
  Result := R.Bottom - R.Top;
end;

{procedure TWinControl.SetClientHeight(const Value: integer);
var
  R : TRect;
begin
  Windows.Setwindowcl (FHandle, R);
  Result := R.Bottom - R.Top;
end;}

function TWinControl.GetClientWidth: integer;
var
  R : TRect;
begin
  Windows.GetClientRect(FHandle, R);
  Result := R.Right - R.Left;    
end;

{ TList }

destructor TList.Destroy;
begin
  FreeMem(FItems);
  inherited Destroy;
end;

{$ifdef asm_ver}
procedure TList.Insert(Index: Integer; Value: Pointer);
asm
        PUSH      ECX
        PUSH      EAX
          PUSH      EDX
          CALL      TList.Add   // don't matter what to add
          POP       EDX         // EDX = Idx, Eax = Count-1
        SUB       EAX, EDX

        SAL       EAX, 2
        MOV       ECX, EAX      // ECX = (Count - Idx - 1) * 4
        POP       EAX
        MOV       EAX, [EAX].fItems
        LEA       EAX, [EAX + EDX*4]
        JL        @@1
          PUSH      EAX
          LEA       EDX, [EAX + 4]
          CALL      System.Move

          POP       EAX          // EAX = @fItems[ Idx ]
@@1:
        POP       ECX            // ECX = Value
        MOV       [EAX], ECX
end;
{$else}
procedure TList.Insert(Index: Integer; Value: Pointer);
begin
   Assert((Index >= 0) and (Index <= Count), 'List index out of bounds');
   Add(nil);
   if fCount > Index then
     Move(FItems[Index], FItems[Index + 1], (fCount - Index - 1) * Sizeof(Pointer));
   FItems[Index] := Value;
end;
{$endif}

(*{$ifdef asm_ver}
procedure TList.Add( Value: Pointer );
asm
        PUSH      EDX
        LEA       ECX, [EAX].fCount
        MOV       EDX, [ECX]
        INC       dword ptr [ECX]
          PUSH      EDX
          CMP       EDX, [EAX].fCapacity
            PUSH      EAX
            JL        @@ok

            ADD       EDX, [EAX].fAddBy
            CALL      TList.SetCapacity
@@ok:
            POP       ECX  // ECX = @Self
          POP       EAX    // EAX = fCount -> Result (for TList.Insert)
        POP       EDX      // EDX = Value

        MOV       ECX, [ECX].fItems
        MOV       [ECX + EAX*4], EDX
end;
{$else} *)
function TList.Add(Value: Pointer): Integer; //29.03.03
begin
  Result := Count;
   if fCapacity <= Result then
      Capacity := Result + {fAddBy}16;
   fItems[ fCount ] := Value;
   Inc( fCount );
end;
//{$endif}

function TList.Remove(Item: Pointer): Integer;
begin
  Result := IndexOf(Item);
  if Result >= 0 then
    Delete(Result);
end;

procedure TList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

procedure TList.Delete(Idx: Integer);
begin
  Assert((Idx >= 0) and (Idx < fCount), 'TList.Delete: index out of bounds');
  Move(fItems[ Idx + 1 ], fItems[Idx], Sizeof(Pointer) * (Count - Idx - 1));
  Dec(fCount);
end;

function TList.Get(Idx: Integer): Pointer;
begin
   Result := nil;
   if Idx < 0 then Exit;
   if Idx >= fCount then Exit;
   //Assert( (Idx >= 0) and (Idx < fCount), 'TList.Get: index out of bounds' );
   Result := fItems[ Idx ];
end;

{$ifdef asm_ver}
function TList.IndexOf(Value: Pointer): Integer;
asm
        PUSH      EDI

        MOV       EDI, [EAX].fItems
        MOV       ECX, [EAX].fCount
          PUSH      EDI
          DEC       EAX            // make "NZ" - EAX always <> 1
          MOV       EAX, EDX
          REPNZ     SCASD
          POP       EDX
        JZ        @@succ
        MOV       EDI, EDX
@@succ:
        MOV       EAX, EDI
        STC
        SBB       EAX, EDX
        SAR       EAX, 2

        POP       EDI
end;
{$else}
function TList.IndexOf(Value: Pointer): Integer;
var I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
   begin
    if fItems[I] = Value then
     begin
      Result := I;
      break;
     end;
   end;
end;
{$endif}

procedure TList.Put(Idx: Integer; const Value: Pointer);
begin
   if Idx < 0 then Exit;
   if Idx >= Count then Exit;
   //Assert( (Idx >= 0) and (Idx < fCount), 'TList.Put: index out of bounds' );
   fItems[ Idx ] := Value;
end;

{$ifdef asm_ver}
procedure TList.SetCapacity(Value: Integer);
asm
        CMP       EDX, [EAX].fCount
        JGE       @@1
        MOV       EDX, [EAX].fCount
@@1:
        CMP       EDX, [EAX].fCapacity
        JE        @@exit

        MOV       [EAX].fCapacity, EDX
        SAL       EDX, 2
        LEA       EAX, [EAX].fItems
        CALL      System.@ReallocMem
@@exit:
end;
{$else}

procedure TList.SetCapacity(Value: Integer);
begin
   if Value < Count then Value := Count;
   if Value = FCapacity then Exit;
   {
   if fItems = nil then
     GetMem( fItems, Value * Sizeof( Pointer ) )
   else}
   ReallocMem(FItems, Value * SizeOf(Pointer));
   FCapacity := Value;
end;
{$endif}

procedure TList.SetCount(const Value: Integer);
begin
  if Value >= Count then exit;
  FCount := Value;
end;

function TList.First: Pointer;
begin
  Result := Get(0);
end;

procedure TList.Pack;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do
    if Items[I] = nil then
      Delete(I);
end;

{ TThreadList }

procedure TThreadList.Add(Item: Pointer);
begin
  LockList;
  try
    if (Duplicates = dupAccept) or
       (FList.IndexOf(Item) = -1) then
      FList.Add(Item)
    else if Duplicates = dupError then
      Exit;//FList.Error(@SDuplicateItem, Integer(Item));
  finally
    UnlockList;
  end;
end;

procedure TThreadList.Clear;
begin
  LockList;
  try
    FList.Clear;
  finally
    UnlockList;
  end;
end;

constructor TThreadList.Create;
begin
  inherited Create;
  InitializeCriticalSection(FLock);
  FList := TList.Create;
  FDuplicates := dupIgnore;
end;

destructor TThreadList.Destroy;
begin
  LockList;    // Make sure nobody else is inside the list.
  try
    FList.Free;
    inherited Destroy;
  finally
    UnlockList;
    DeleteCriticalSection(FLock);
  end;
end;

function TThreadList.LockList: TList;
begin
  EnterCriticalSection(FLock);
  Result := FList;
end;

procedure TThreadList.Remove(Item: Pointer);
begin
  LockList;
  try
    FList.Remove(Item);
  finally
    UnlockList;
  end;
end;

procedure TThreadList.UnlockList;
begin
  LeaveCriticalSection(FLock);
end;

{ TPanel }

constructor TPanel.Create(AParent: TWinControl; Caption: String);
begin
  if AParent = nil then ExitProcess(0);
  inherited Create(AParent);
  FWidth := 185;
  FHeight := 41;
  FClassName := 'static';
  FCaption := PChar(Caption);
// FExStyle := WS_EX_STATICEDGE ;//}WS_EX_CLIENTEDGE     ;
  FStyle :=  {WS_DLGFRAME or{ SS_SUNKEN or}  SS_CENTER or WS_VISIBLE or WS_CHILD or SS_NOTIFY{ or
                         SS_LEFTNOWORDWRAP or SS_NOPREFIX};
  FColor := GetSysColor(COLOR_BTNFACE) ;

  CreateWnd;

  Canvas := TCanvas.Create(Handle);
  Canvas.Pen := TPen.Create(Canvas);
  Canvas.Brush := TBrush.Create(Canvas);

//  Border := 2;
  FBevel := bvRaised ;
end;

procedure TPanel.Paint(DC: HDC);
var
  Rect: TRect;
  Flags: Integer;
  col1, col2: TColor;
begin
  case Bevel of
   bvLowered :
    begin
     col1 := GetSysColor(COLOR_BTNSHADOW);
     col2 := clWhite;
    end;
   bvRaised, bvSpace :
    begin
     col1 := clWhite;
     col2 := GetSysColor(COLOR_BTNSHADOW);
    end;
   else
    begin
     col1 := GetSysColor(COLOR_BTNFACE);
     col2 := GetSysColor(COLOR_BTNFACE);
    end;
  end;
  Canvas.Pen.Color := col1 ;

  Canvas.MoveTo(0, 0);
  Canvas.LineTo(Width,0);
  
  Canvas.MoveTo(0, 0);
  Canvas.LineTo(0,Height);

  Canvas.Pen.Color := {}col2  ;

  Canvas.MoveTo(Width-1, 0);
  Canvas.LineTo(Width-1,Height);

  Canvas.MoveTo(0, Height-1);
  Canvas.LineTo(Width-1,Height-1);

//  Canvas.TextOut(10,10, Caption);

  Rect.Left := 0;
  Rect.Top := 0;
  Rect.Right := Width;
  Rect.Bottom := Height;

//       Canvas.Brush.Style := bsSolid;
//       Canvas.Brush.Color := GetSysColor(COLOR_BTNFACE);
//       Canvas.FillRect(Rect);

  Canvas.Brush.Style := bsClear ;
  Flags := DT_EXPANDTABS or DT_SINGLELINE or DT_VCENTER or DT_CENTER { or VAlignments[fVerticalAlign] or Alignments[fTextAlign]};
//  SetBkColor(Canvas.Handle, Color);
  SetBkMode(Canvas.Handle, TRANSPARENT); 
  DrawText(Canvas.Handle, PChar(Caption), Length(Caption), Rect, Flags);
//  Canvas.Brush.Style := bsSolid ;
end;

procedure TPanel.RealPaint(var Msg: TMessage);
var
  PaintStruct: TPaintStruct;
  DC: HDC;
begin
  if Msg.wParam = 0 then DC:= BeginPaint(Handle, PaintStruct) else DC := Msg.wParam;
  Paint(DC);
  if Msg.wParam = 0 then EndPaint(Handle, PaintStruct);
end;

procedure TPanel.SetBevel(const Value: TBevelType);
begin
  FBevel := Value;
  Invalidate ;
end;

procedure TPanel.WMNCPAINT_(var Msg: TMessage);
begin
  RealPaint(Msg);
end;

procedure TPanel.WMPAINT_(var Msg: TMessage);
begin
  RealPaint(Msg);
end;

{ TSimplePanel }

constructor TSimplePanel.Create(AParent: TWinControl; Caption: String);
begin
 if AParent = nil then ExitProcess(0);
 inherited Create(AParent);
 FWidth := 185;
 FHeight := 41;
 FClassName := 'static';
 FCaption := PChar(Caption);
 FExStyle := WS_EX_STATICEDGE ;//}WS_EX_CLIENTEDGE     ;
 FStyle := SS_SUNKEN or SS_CENTER or SS_CENTERIMAGE or WS_VISIBLE
             or WS_CHILD or SS_NOTIFY;

 FColor := GetSysColor(COLOR_BTNFACE);

 CreateWnd;
end;

procedure TSimplePanel.SetBorder(const Value: Integer);
begin
  FBorder := Value;
  if Value = 1 then SetStyle(FStyle or WS_DLGFRAME);
  if Value = 2 then SetStyle(FStyle and not WS_DLGFRAME and not SS_SUNKEN);
  if Value = 3 then SetStyle(FStyle or not WS_DLGFRAME and SS_SUNKEN);
end;

{ TGroupBox }

constructor TGroupBox.Create(AParent: TWinControl; Caption: String);
begin
 if AParent = nil then ExitProcess(0);
 inherited Create(AParent);
 FWidth := 185;
 FHeight := 105;
 FClassName := 'button';
 FCaption := PChar(Caption);
// FExStyle :={WS_EX_CLIENTEDGE}WS_EX_CONTROLPARENT     ;
 FStyle :=  WS_CHILD or {WS_TABSTOP or}
            WS_VISIBLE {or BS_NOTIFY} or BS_GROUPBOX or WS_GROUP;

 FColor := GetSysColor(COLOR_BTNFACE) ;
// FBkMode := bk_Opaque   ;

 CreateWnd;
end;

function TWinControl.GetMarginWidth: word;
begin
  Result := Lo(Perform(EM_GETMARGINS, 0, 0));
end;

procedure TWinControl.SetMarginWidth(const Value: word);
begin
  Perform(EM_SETMARGINS, EC_LEFTMARGIN or EC_RIGHTMARGIN, MakeLong(Value, Value));
end;

procedure TWinControl.SetMaxLength(const Value: Integer);
begin
 if FMaxLength <> Value then
  begin
    FMaxLength := Value;
    Perform(EM_LIMITTEXT, Value, 0);
  end;
end;

procedure TWinControl.SetPasswordChar(const Value: Char);
begin
  FPasswordChar := Value;
  Perform(EM_SETPASSWORDCHAR, Ord(Value), 0);
end;

procedure TWinControl.SetReadOnly(const Value: Boolean);
begin
 if FReadOnly <> Value then
  begin
    FReadOnly := Value;
    Perform(EM_SETREADONLY, Ord(Value), 0);
  end;
end;

{ TRadioButton }

procedure TRadioButton.Click;
begin
  inherited;
  Checked := true;//not Checked;
  CheckRadioButton(FHandle, 1, 0, 1);
end;

constructor TRadioButton.Create(AParent: TWinControl; Caption: String);
begin
 inherited Create(AParent);
 FWidth := 113;
 FHeight := 17;
 FClassName := 'BUTTON';
 FCaption := PChar(Caption);
 FChecked := False;
// FExStyle := ws_Ex_ControlParent;

 FStyle := WS_VISIBLE or WS_CHILD or BS_RADIOBUTTON or
   WS_TABSTOP or WS_GROUP{ or BS_NOTIFY};

 FBkMode := bk_Transparent ;
 FColor := GetSysColor(COLOR_BTNFACE)  ;
 FId := 4;

 CreateWnd ;
end;

function TRadioButton.GetChecked: Boolean;
begin
  Result := LongBool(Perform(BM_GETCHECK, 0, 0));
end;

procedure TRadioButton.SetChecked(const Value: Boolean);
begin
  FChecked := Value;
  if Value then
   begin
    PostMessage(FHwnd,BM_SETCHECK,BST_UNCHECKED,0);
    PostMessage(FHandle,BM_SETCHECK,BST_CHECKED,0);
    FHwnd := FHandle;
   end
  else
   PostMessage(FHandle,BM_SETCHECK,BST_UNCHECKED,0);
end;

procedure CloseForm(Form:TForm;Angle:boolean;Close:boolean);
var i,j:integer;
begin
if angle then begin
for j:=0 to form.Width div 20 do
 begin
  sleep(5);
  Form.Width:=Form.Width-20;
 end;
form.Caption:='';
for i:=0 to form.Height div 20 do
 begin
  Form.Height:=Form.Height-20;
  sleep(5);
 end;
end else
begin
for i:=0 to form.Height div 20 do
 begin
  Form.Height:=Form.Height-20;
  sleep(5);
 end;
form.Caption:='';
for j:=0 to form.Width div 20 do
 begin
  sleep(5);
  Form.Width:=Form.Width-20;
 end;
end;
if close then form.Close;
end;

function TWinControl.GetHeight: integer;
var
 r:TRect;
begin
 GetWindowRect(FHandle, r);
 Result := r.Bottom-r.Top   ;
//  Result := FHeight;
end;

function TWinControl.GetLeft: integer;
var
  r:TRect;
begin
  GetWindowRect(FHandle, r);
  if Assigned(FParent) then ScreenToClient(FParent.Handle, r.TopLeft);
  Result := r.Left ;
end;

function TWinControl.GetTop: integer;
var
 r:TRect;
begin
 GetWindowRect(FHandle, r);
 if Assigned(FParent) then ScreenToClient(FParent.Handle, r.TopLeft);
 Result := r.Top  ;
// Result := FTop;
end;

function TWinControl.GetWidth: integer;
var
 r:TRect;
begin
 GetWindowRect(FHandle, r);
 Result := r.Right-r.Left ;
 //Result := FWidth;
end;

procedure TWinControl.Invalidate;
begin
  Windows.InvalidateRect(FHandle, nil, True);
end;

procedure TWinControl.WMSysCommand(var AMsg: TWMSysCommand);
var
 dsp: Boolean;
begin
 dsp := True;
 if (AMsg.CmdType = SC_MINIMIZE) and Assigned(FOnMinimize) then dsp := FOnMinimize(Self);
 if dsp then Dispatch(AMsg);
end;

procedure TWinControl.WMPaint(var AMsg: TWMPaint);
begin
  if Assigned(FOnPaint) then FOnPaint(Self);
  Dispatch(AMsg);
end;

{ TTabControl }



(*function WndProcTabControl(hWnd,Msg,wParam,lParam:Longint):Longint; stdcall;// Self_: TWinControl; var Msg: TMsg; var Rslt: Integer ):Boolean;
//var Hdr: PNMHdr;
//    Page: PControl;
//    I, A: Integer;
//    R: TRect;
//    Form: PControl;
//    WasActive: Boolean;
begin
 Result:=DefWindowProc(hWnd,Msg,wParam,lParam);

{  case Msg of
    WM_NOTIFY:
      begin

       //ShowMessage('ok');
      end;
  end;}
end;        *)

(*var
  OldWndProc: TFarProc;

function NewWndProc(hWndAppl: HWnd; Msg, wParam: Word; lParam: Longint): Longint; export; stdcall;
begin
Result := CallWindowProc(OldWndProc, hWndAppl, Msg, wParam, lParam);
  { default WndProc return value }
//  Result := 0;
  if msg=wm_notify then  ShowMessage('ok');
  { handle messages here; the message number is in Msg }
end;   *)

(*{$ifdef asm_ver}
constructor TTabControl.Create(AParent: TWinControl);
begin
asm
 call InitCommonControls ;
end;
 if AParent = nil then ExitProcess(0);
 inherited Create(AParent);
asm
// push AParent
// call TWinControl.Create

 mov [EAX].FWidth,  180
 mov [EAX].FHeight, 150
 mov [EAX].FClassName, 'SysTabControl32';
 mov [EAX].FStyle, WS_CHILD or WS_VISIBLE
// mov [EAX].FColor, clRed;

 call CreateWnd
end;
end;
{$else}  *)

{procedure TTabControl.WndProc(var AMsg: TMessage);
var
  Hdr: PNMHdr;
  a: Integer;
begin
  Hdr := Pointer(AMsg.lParam );
  if Hdr.code = TCN_SELCHANGE then
   begin
    A := Perform( TCM_GETCURSEL, 0, 0 );
    ShowMessage(IntToStr(a));
   end;
end;   }
constructor TTabControl.Create(AParent: TWinControl);
begin
  InitCommonControls ;
  if AParent = nil then ExitProcess(0);
  inherited Create(AParent);
  FWidth := 180;
  FHeight := 150;
  FClassName := 'SysTabControl32';
  FStyle := WS_CHILD or WS_VISIBLE or WS_TABStop;
// FColor := clRed ;
  CreateWnd;
end;
//{$endif}

function TTabControl.TabInsert(Caption: String; Index:Integer): Integer;
var
  tcItem:TC_Item;
begin
  tcItem.mask := TCIF_TEXT or TCIF_IMAGE;
  tcItem.pszText := PChar(Caption);
  tcItem.iImage := 0;
  Result := Perform(TCM_INSERTITEM, Index, LPARAM(@tcItem));
end;

function TTabControl.TabAdd(Caption: String): Integer;
begin
  Result := TabInsert(Caption, TabCount);
end;

function TTabControl.TabCount: Integer;
begin
  Result := Perform(TCM_GETITEMCOUNT, 0, 0);
end;

function TTabControl.TabDelete(Index: Integer): Boolean;
begin
  Result := Bool(Perform(TCM_DELETEITEM, Index, 0));
end;

procedure TTabControl.TabImageIndex(TabIndex, ImageIndex: Integer);
var
  tcItem:TC_Item;
begin
  tcItem.mask := TCIF_IMAGE;
//  tcItem.iImage :=
  tcItem.dwStateMask  := ImageIndex;
  tcItem.iImage  := ImageIndex;
  Perform(TCM_SETITEM, TabIndex, LPARAM(@tcItem));  
end;

{ TComboBox }

constructor TComboBox.Create(AParent: TWinControl; Style: TComboBoxStyle);
begin
 inherited Create(AParent);
 FWidth := 121;
 FHeight := 21 * 2;
 FClassName := 'combobox';
 FExStyle := WS_EX_CLIENTEDGE;

 FStyle := WS_CHILD{ or WS_BORDER} or WS_VISIBLE or
      CBS_HASSTRINGS or WS_VSCROLL or WS_TABSTOP or CBS_AUTOHSCROLL;

// if Style = csSimple then Dec(FStyle);
 if Style = csDropDown then FStyle := FStyle or CBS_DROPDOWN;
 if Style = csDropDownList then FStyle := FStyle or CBS_DROPDOWNLIST;
 if Style = csOwnerDrawFixed then FStyle := FStyle or CBS_DROPDOWN or CBS_OWNERDRAWFIXED;
 if Style = csOwnerDrawVariable then FStyle := FStyle or CBS_DROPDOWNLIST or CBS_OWNERDRAWVARIABLE;
  // FStyle := FStyle or CBS_DROPDOWNLIST or CBS_OWNERDRAWFIXED;
 FColor := GetSysColor(COLOR_WINDOW);

//Lines
// FItems := TStringList.Create ;
// FItems.OnChange := SetItems;

 CreateWnd;
end;

{procedure TComboBox.DoMouseDown(var AMsg: TWMMouse; Button: TMouseButton; Shift: TShiftState);
begin
  if (Button=mbLeft) and (SendMessage(FHandle,CB_GETDROPPEDSTATE,0,0) = 0) then
  begin
    SendMessage(FHandle,CB_SHOWDROPDOWN,WParam(true),0);
    SendMessage(FHandle,CB_SETEXTENDEDUI,WParam(false),0);
  end;
//  inherited DoMouseDown(AMsg, Button, Shift);   
end;}

function TComboBox.GetDroppedDown: Boolean;
begin
  Result := LongBool(Perform(CB_GETDROPPEDSTATE, 0, 0));
end;

procedure TComboBox.SetDroppedDown(const Value: Boolean);
begin
  Perform(CB_SHOWDROPDOWN, Longint(Value), 0);
end;

function TComboBox.ItemAdd(const S: shortstring): Integer;
var
  ss : array [1..256] of Char;
begin
  Move(s[1], ss[1], Ord(s[0]));
  ss[Ord(s[0])+1] := #0;
  Result := Perform(CB_ADDSTRING, 0, Longint(@ss));
  UpdateHeight;
end;

function TComboBox.ItemCount: Integer;
begin
  Result := Perform(CB_GETCOUNT, 0, 0);
end;

procedure TComboBox.UpdateHeight;
var
  NewHeight: Integer;
begin
  NewHeight := ItemCount;
  if NewHeight>7 then NewHeight := 6;
  SetWindowPos(FHandle, 0, 0, 0, Width, 21 * (NewHeight+1), SWP_NOZORDER or SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOREDRAW);
end;

procedure TComboBox.ItemDelete(ItemIndex: Integer);
begin
  Perform(CB_DELETESTRING, ItemIndex, 0);
end;

function TComboBox.GetItemIndex: Integer;
begin
  Result := Perform(CB_GETCURSEL, 0, 0);
end;

procedure TComboBox.SetItemIndex(const Value: Integer);
begin
  Perform(CB_SETCURSEL, Value, 0);
//  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TComboBox.Clear;
begin
  Perform(CB_RESETCONTENT, 0, 0);
end;

function TComboBox.GetItem(ItemIndex: Integer): String;
var
  Text: ShortString;
begin
  Text[0] := Chr(Perform(CB_GETLBTEXT, ItemIndex, Longint(@Text[1])));
  Result := Text;
end;

procedure TComboBox.SetItem(ItemIndex: Integer; const Value: String);
begin

end;

(*procedure TComboBox.WMDRAWITEM(var AMsg: TWmDrawItem);
var
  cbRect: TRect;
begin
//  ShowMessage('ok');
  cbRect := AMsg.DrawItemStruct.rcItem;
  cbRect.Left := 20;
  
  DrawText(amsg.DrawItemStruct.hDC, PChar(Items[AMsg.DrawItemStruct.itemID]), Length(Items[AMsg.DrawItemStruct.itemID]), cbRect, DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
end; *)

{ TComboBoxEx }

function TComboBoxEx.GetObject(Index: Integer): TObject;
begin
  if (Index >= 0) and (Index < ItemCount) then
    Result := TObject(Perform(CB_GETITEMDATA, Index, 0));
end;

procedure TComboBoxEx.SetObject(Index: Integer; Value: TObject);
begin
  if (Index >= 0) and (Index < ItemCount) then
    Perform(CB_SETITEMDATA, Index, Integer(Value));
end;

{ TCanvas }

constructor TCanvas.Create(Handle: Integer);
begin
  if Handle <> -1 then FHandle := GetDc(Handle);
  FCopyMode := cmSrcCopy;
end;

destructor TCanvas.Destroy;
begin
  FPen.Free;
  FBrush.Free;
  inherited Destroy;
end;

procedure TCanvas.Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
begin
  Windows.Arc(FHandle, X1, Y1, X2, Y2, X3, Y3, X4, Y4);
end;

procedure TCanvas.Ellipse(X1, Y1, X2, Y2: Integer);
begin
  Windows.Ellipse(FHandle, x1, y1, x2, y2);
end;

function TCanvas.GetPixel(X, Y: Integer): Integer;
begin
 Result := Windows.GetPixel(FHandle, x, y);
end;

procedure TCanvas.SetPixel(X, Y: Integer; const Value: Integer);
begin
 Windows.SetPixel(FHandle, x, y, Value);
end;

procedure TCanvas.LineTo(X, Y: Integer);
begin
 Windows.LineTo(FHandle, x, y);
end;

procedure TCanvas.MoveTo(X, Y: Integer);
begin
  Windows.MoveToEx(FHandle, x, y, nil);
end;

procedure TCanvas.Rectangle(X1, Y1, X2, Y2: Integer);
begin
 Windows.Rectangle(FHandle, x1, y1, x2, y2); 
end;

procedure TCanvas.TextOut(X, Y: Integer; const Text: string);
begin
 Windows.TextOut(FHandle, x, y, PChar(Text), Length(Text));
end;

type
  PPoints = ^TPoints;
  TPoints = array[0..0] of TPoint;
    
procedure TCanvas.Polyline(const Points: array of TPoint);
begin
  Windows.Polyline(FHandle, PPoints(@Points)^, High(Points) + 1);
end;

procedure TCanvas.FillRect(const Rect: TRect);
begin
  Windows.FillRect(FHandle, Rect, Brush.Handle); 
end;

function TCanvas.GetClipRect: TRect;
begin
  GetClipBox(FHandle, Result); 
end;

procedure TCanvas.FloodFill(X, Y: Integer; Color: TColor; FillStyle: TFillStyle);
const
  FillStyles: array[TFillStyle] of Word = (FLOODFILLSURFACE, FLOODFILLBORDER);
begin
  Windows.ExtFloodFill(FHandle, X, Y, Color, FillStyles[FillStyle]);
end;

constructor TCanvas.CreateFromDC(DC: hDC);
begin
  FHandle := DC;
  
  FBrush := TBrush.Create(Self);
  FPen := TPen.Create(Self);
end;

function TCanvas.TextExtent(const Text: string): TSize;
begin
  Result.cX := 0;
  Result.cY := 0;
  Windows.GetTextExtentPoint32(FHandle, PChar(Text), Length(Text), Result);
end;

function TCanvas.TextWidth(const Text: string): Integer;
begin
  Result := TextExtent(Text).cX;
end;

procedure TCanvas.Lock;
begin
{  EnterCriticalSection(CounterLock);
  Inc(FLockCount);
  LeaveCriticalSection(CounterLock);
  EnterCriticalSection(FLock);}
end;

procedure TCanvas.Unlock;
begin
{  LeaveCriticalSection(FLock);
  EnterCriticalSection(CounterLock);
  Dec(FLockCount);
  LeaveCriticalSection(CounterLock);}
end;

procedure TCanvas.CreateHandle;
begin
end;

procedure TCanvas.CreateFont;
begin
  if Assigned(Font) then
  begin
    SelectObject(FHandle, Font.Handle);
    SetTextColor(FHandle, ColorToRGB(Font.Color));
  end;
end;

procedure TCanvas.CreatePen;
const
  PenModes: array[TPenMode] of Word =
    (R2_BLACK, R2_WHITE, R2_NOP, R2_NOT, R2_COPYPEN, R2_NOTCOPYPEN, R2_MERGEPENNOT,
     R2_MASKPENNOT, R2_MERGENOTPEN, R2_MASKNOTPEN, R2_MERGEPEN, R2_NOTMERGEPEN,
     R2_MASKPEN, R2_NOTMASKPEN, R2_XORPEN, R2_NOTXORPEN);
begin
  SelectObject(FHandle, Pen.Handle);
  SetROP2(FHandle, PenModes[Pen.Mode]);
end;

procedure TCanvas.CreateBrush;
begin
  UnrealizeObject(Brush.Handle);
  SelectObject(FHandle, Brush.Handle);
  if Brush.Style = bsSolid then
  begin
    SetBkColor(FHandle, ColorToRGB(Brush.Color));
    SetBkMode(FHandle, OPAQUE);
  end
  else
  begin
    { Win95 doesn't draw brush hatches if bkcolor = brush color }
    { Since bkmode is transparent, nothing should use bkcolor anyway }
    SetBkColor(FHandle, not ColorToRGB(Brush.Color));
    SetBkMode(FHandle, TRANSPARENT);
  end;
end;

procedure TCanvas.RequiredState(ReqState: TCanvasState);
var
  NeededState: TCanvasState;
begin
  NeededState := ReqState - State;
  if NeededState <> [] then
  begin
    if csHandleValid in NeededState then
    begin
      CreateHandle;
      if FHandle = 0 then Exit;
        //raise EInvalidOperation.CreateRes(@SNoCanvasHandle);
    end;
    if csFontValid in NeededState then CreateFont;
    if csPenValid in NeededState then CreatePen;
    if csBrushValid in NeededState then CreateBrush;
    State := State + NeededState;
  end;
end;

procedure TCanvas.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TCanvas.CopyRect(const Dest: TRect; Canvas: TCanvas; const Source: TRect);
begin
  RequiredState([csHandleValid, csFontValid, csBrushValid]);
  Canvas.RequiredState([csHandleValid, csBrushValid]);
  StretchBlt(FHandle, Dest.Left, Dest.Top, Dest.Right - Dest.Left,
    Dest.Bottom - Dest.Top, Canvas.FHandle, Source.Left, Source.Top,
    Source.Right - Source.Left, Source.Bottom - Source.Top, CopyMode);
end;

procedure TCanvas.Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
begin
  Windows.Pie(FHandle, X1, Y1, X2, Y2, X3, Y3, X4, Y4);
end;

{ TPen }

constructor TPen.Create(Canvas: TCanvas);
begin
  DC := Canvas.Handle ;
end;

procedure TPen.SetColor(const Value: Integer);
begin
  FColor := ColorToRGB(Value);
  UpdatePen ;
end;

procedure TPen.SetMode(const Value: TPenMode);
begin
  FMode := Value;
  UpdatePen ;  
end;

procedure TPen.SetStyle(const Value: TPenStyle);
begin
  FStyle := Value;
  UpdatePen ;
end;

procedure TPen.SetWidth(const Value: Integer);
begin
  FWidth := Value;
  UpdatePen ;
end;

procedure TPen.UpdatePen;
var
 FHandle2, FStyle2:Integer;
begin
 FStyle2 := 0;
 Case FStyle of
  psSolid: FStyle2:=PS_SOLID ;
  psDot: FStyle2:=PS_DOT ;
  psDash: FStyle2:=PS_DASH ;
  psDashDot: FStyle2:=PS_DASHDOT ;
  psDashDotDot: FStyle2:=PS_DASHDOTDOT ;
  psClear: FStyle2:=PS_NULL ;
  psInsideFrame: FStyle2:=PS_INSIDEFRAME ;
 end;

 FHandle := CreatePen(FStyle2, FWidth,  FColor);
 FHandle2:= SelectObject(DC, FHandle);
 DeleteObject(FHandle2);
end;

{ TBrush }

constructor TBrush.Create(Canvas: TCanvas);
begin
 FDC := Canvas.Handle ;
end;

procedure TBrush.SetColor(const Value: TColor);
begin
  FColor := ColorToRGB(Value);
  Update;
end;

procedure TBrush.SetStyle(const Value: TBrushStyle);
begin
  FStyle := Value;
  Update;
end;

procedure TBrush.Update;
var
  hbs:tagLOGBRUSH;
begin         
  hbs.lbColor := FColor;
  hbs.lbStyle := BS_HATCHED;

  if FStyle = bsSolid then hbs.lbStyle := BS_SOLID;
  if FStyle = bsClear then hbs.lbStyle := BS_NULL;
  if FStyle = bsHorizontal then hbs.lbHatch := HS_HORIZONTAL;
  if FStyle = bsVertical then hbs.lbHatch := HS_VERTICAL;
  if FStyle = bsFDiagonal then hbs.lbHatch := HS_FDIAGONAL;
  if FStyle = bsBDiagonal then hbs.lbHatch := HS_BDIAGONAL;
  if FStyle = bsCross then hbs.lbHatch := HS_CROSS;
  if FStyle = bsDiagCross then hbs.lbHatch := HS_DIAGCROSS; 

  FHandle := CreateBrushIndirect(hbs);
  DeleteObject(SelectObject(FDC, FHandle));
end;

{ TImage }

constructor TImage.Create(AParent: TWinControl);
begin
 if AParent = nil then ExitProcess(0);
 inherited Create(AParent);
 FWidth := 105;
 FHeight := 105;
 FClassName := 'static';
// FCaption := @Caption[1];
// FExStyle :=WS_EX_CLIENTEDGE  ;
 FStyle := WS_CHILD or WS_VISIBLE or SS_BITMAP{ or SS_ICON} ;
 FColor := clBtnFace ;
// FBkMode := bk_Opaque ;

 CreateWnd;
end;

function TImage.GetBitmap: TBitmap;
begin
  Result := TBitmap.Create ;
  Result.Handle := FHandle ; 
end;

procedure TImage.SetBitmap(const Value: TBitmap);
begin
  SetBitmapHandle(Value.Handle); 
end;

procedure TImage.LoadFromFile(FileName: String);
begin
  FBitmap := LoadImage(0, PChar(FileName), IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE or LR_LOADFROMFILE);
  Perform(STM_SETIMAGE, IMAGE_BITMAP, FBitmap);
end;

procedure TImage.SetBitmapRes(const Value: String);
begin
  FBitmapRes := Value;     
  FBitmap := LoadBitmap(Hinstance, PChar(Value));

  if (Style and SS_BITMAP)<>SS_BITMAP then Style := Style or SS_BITMAP;
  if (Style and SS_ICON)=SS_ICON then Style := Style and not SS_ICON;

  Perform(STM_SETIMAGE, IMAGE_BITMAP, FBitmap);
end;

procedure TImage.SetBitmapHandle(const Value: hBitmap);
begin
  FBitmap := Value;

  if (Style and SS_BITMAP)<>SS_BITMAP then Style := Style or SS_BITMAP;
  if (Style and SS_ICON)=SS_ICON then Style := Style and not SS_ICON;

  Perform(STM_SETIMAGE, IMAGE_BITMAP, FBitmap);
end;

procedure TImage.SetIconHandle(const Value: THandle);
begin
  FIconHandle := Value;

  if (Style and SS_BITMAP)=SS_BITMAP then Style := Style and not  SS_BITMAP;
  if (Style and SS_ICON)<>SS_ICON then Style := Style or SS_ICON;

  Perform(STM_SETIMAGE, IMAGE_ICON, FIconHandle);
end;

{ TStringStream }

constructor TStringStream.Create(const AString: string);
begin
  inherited Create;
  FDataString := AString;
end;

function TStringStream.Read(var Buffer; Count: Integer): Longint;
begin
  Result := Length(FDataString) - FPosition;
  if Result > Count then Result := Count;
  Move(PChar(@FDataString[FPosition + 1])^, Buffer, Result);
  Inc(FPosition, Result);
end;

function TStringStream.ReadString(Count: Integer): string;
var
  Len: Integer;
begin
  Len := Length(FDataString) - FPosition;
  if Len > Count then Len := Count;
  SetString(Result, PChar(@FDataString[FPosition + 1]), Len);
  Inc(FPosition, Len);
end;

function TStringStream.Seek(Offset: Integer; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: FPosition := FPosition + Offset;
    soFromEnd: FPosition := Length(FDataString) - Offset;
  end;
  if FPosition > Length(FDataString) then
    FPosition := Length(FDataString)
  else if FPosition < 0 then FPosition := 0;
  Result := FPosition;
end;

procedure TStringStream.SetSize(NewSize: Integer);
begin
  SetLength(FDataString, NewSize);
  if FPosition > NewSize then FPosition := NewSize;
end;

function TStringStream.Write(const Buffer; Count: Integer): Longint;
begin
  Result := Count;
  SetLength(FDataString, (FPosition + Result));
  Move(Buffer, PChar(@FDataString[FPosition + 1])^, Result);
  Inc(FPosition, Result);
end;

procedure TStringStream.WriteString(const AString: string);
begin
  Write(PChar(AString)^, Length(AString));
end;

//

procedure TWinControl.ShowModal;
begin
  EnableWindow(FParent.FHandle, False);
  Show;
end;

procedure TWinControl.SetHint(const Value: String);
//var
//  PrevShowHint: Boolean;
begin
  FHint := Value;
  if FShowHint then SetShowHint(True);
//  PrevShowHint := FShowHint;
//  SetShowHint(True);
//  SetShowHint(PrevShowHint);
end;

procedure TWinControl.SetShowHint(const Value: Boolean);
var
  ti:ToolInfo;
begin
  FShowHint := Value;

  if FShowHint then
   begin
    InitCommonControls ;
    hwndTooltip := CreateWindowEx(0, 'Tooltips_class32', nil, TTS_ALWAYSTIP,
      CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, 0, 0, hInstance, nil);

    ti.cbSize := SizeOf(ti);
    ti.uFlags := TTF_IDISHWND{ or TTF_CENTERTIP }or TTF_SUBCLASS  ;
    ti.uId := FHandle;
    ti.lpszText := PChar(FHint);
    
    SendMessage(hwndTooltip, TTM_ADDTOOL, 0, Integer(@ti));
   end
  else
   begin
    //SendMessage(hwndTooltip, TTM_DELTOOL, 0, Integer(@ti));
    SendMessage(hwndTooltip, WM_CLOSE, 0, 0);
   end;
end;

{ TMenu }

function NewPopupMenu(MenuItems: array of PChar):hMenu;
var
  i, mnuType: Integer;
begin
  i:=0;
  Result := CreatePopupMenu ;
  while i<=High(MenuItems) do
   begin
    if MenuItems[i]='-' then mnuType := MFT_SEPARATOR else mnuType := MF_STRING;
    AppendMenu(Result, mnuType, 1, MenuItems[i]);
    Inc(i)
   end;
end;

procedure AddPopupMenuToMenu(var Menu:hMenu; PopupMenu: hMenu; Caption:String);
var
  mii: menuiteminfo;
begin
  FillChar( MII, Sizeof( MII ), 0 );
  MII.cbSize := 44; //Sizeof( MII );
  MII.fMask := MIIM_DATA or MIIM_ID or MIIM_STATE or MIIM_SUBMENU or MIIM_TYPE;
  mii.hSubMenu := PopupMenu;
  mii.fType :=  MF_STRING;
  mii.wID := 2 ;
  mii.dwTypeData := PChar(Caption);
  InsertMenuItem(menu, 1, True, MII );
end;

{constructor TMenu.Create(MainMenu: Boolean; const Template: array of PChar);
var
 i: Integer;
 MnuType:Integer;
 hwnd:Integer;
begin
//  if Parent = nil then Exit;
//  FControlHandle := Parent.FHandle ;

  if MainMenu then
   FHandle := CreateMenu
  else
   FHandle := CreatePopupMenu;

  i:=0;
  while i<=High(Template) do
   begin
    if Template[i]='-' then mnuType := MFT_SEPARATOR else mnuType := MF_STRING;
    if Template[i+1]='(' then
     begin

     end
    else
     if Template[i]<>')' then AppendMenu(FHandle, mnuType, 1, Template[i]);
    Inc(i)
   end;

//  SetMenu(FControlHandle, FHandle);
end;

procedure TMenu.Popup(X, Y: Integer);
begin
 TrackPopupMenu(FHandle, 0, x, y, 0, FParentHandle, nil);
end;   }

constructor TMenu.Create(AParent: TWinControl; MainMenu: Boolean; const Template: array of PChar);
var
 i: Integer;
 MnuType:Integer;
 hwnd:Integer;
begin
//  if FParent = nil then Exit;
//  FControlHandle := FParentHandle;
  FParentHandle:=AParent.Handle;

  if MainMenu then
   FHandle := CreateMenu
  else
   FHandle := CreatePopupMenu;
  Adder:=StrToInt(Template[0])-1;
  i:=1;
  while i<=High(Template) do
   begin
    if Template[i]='-' then mnuType := MFT_SEPARATOR else mnuType := MF_STRING;
    AppendMenu(FHandle, mnuType, i+Adder, Template[i]);
    Inc(i)
   end;

  //if MainMenu then SetMenu(FParentHandle, FHandle);
end;

procedure TMenu.AddItem(S: String; I: Integer);
var MnuType:Integer;
begin
if S='-' then mnuType := MFT_SEPARATOR else mnuType := MF_STRING;
AppendMenu(FHandle, mnuType, i+Adder, PChar(S));
end;

procedure TMenu.Popup(X, Y: Integer);
var B: Cardinal;
begin
 TrackPopupMenu(FHandle, 0, x, y, 0, FParentHandle, nil);
end;

destructor TMenu.Destroy;
begin
  DestroyMenu(FHandle);
  inherited;
end;

{ TUpDown }

constructor TUpDown.Create(AParent: TWinControl);
begin
 if AParent = nil then ExitProcess(0);
 InitCommonControls;
 inherited Create(AParent);
 FWidth := 16;
 FHeight := 24;
 FClassName := 'msctls_updown32';
 FStyle := WS_CHILD or WS_VISIBLE or UDS_SETBUDDYINT {or WS_CLIPSIBLINGS or WS_CLIPCHILDREN};
 FColor := clBtnFace ;

 CreateWnd;
end;

{function TUpDown.GetAssociate: THandle;
begin
  Result := Perform(UDM_GETBUDDY, 0, 0);
end;    }

function TUpDown.GetIncrement: Integer;
var
  tmp : LongInt;
  acc   : TUDAccel;
begin
  Perform(UDM_GETACCEL,LongInt(@tmp),LongInt(@acc));
  Result := acc.nInc;
end;

function TUpDown.GetMax: Integer;
begin
  Perform(UDM_GETRANGE32, 0, DWord(@Result));
end;

function TUpDown.GetMin: Integer;
begin
  Perform(UDM_GETRANGE, DWord(@Result), 0);
end;

function TUpDown.GetUpPosition: Integer;
begin
  Result:=Perform(UDM_GETPOS32, 0, 0);
end;

procedure TUpDown.SetAssociate(const Value: TWinControl);
begin
  if not Assigned(Value) then Exit;
  FAssociate := Value;
  SetBounds(Value.FLeft+Value.FWidth, Value.FTop, Width, Value.FHeight);
  Perform(UDM_SETBUDDY, Value.Handle, 0);
end;

procedure TUpDown.SetIncrement(const Value: Integer);
var
  acc : TUDAccel;
begin
  acc.nSec := REFRESH_PERIOD;
  acc.nInc := Cardinal(Value);
  Perform(UDM_SETACCEL,1,LongInt(@acc));
end;

procedure TUpDown.SetMax(const Value: Integer);
var
  i:Integer;
begin
  Perform(UDM_GETRANGE32, DWord(@i), 0);
  Perform(UDM_SETRANGE32, i, Value);
end;

procedure TUpDown.SetMin(const Value: Integer);
var
  i:Integer;
begin
  Perform(UDM_GETRANGE32, 0, DWord(@i));
  Perform(UDM_SETRANGE32, Value, i);
end;

procedure TUpDown.SetUpPosition(const Value: Integer);
begin
  Perform(UDM_SETPOS32, 0, Value);
end;

procedure TWinControl.SetCursor(const Value: TCursor);
begin
  if Value = FCursor then Exit;
  FCursor := Value;
  Windows.SetCursor(FCursor);   
end;

{ TSpinEdit }

function CreateUpDownControl(dwStyle: Longint; X, Y, CX, CY: Integer;
  hParent: HWND;  nID: Integer; hInst: THandle; hBuddy: HWND;
  nUpper, nLower, nPos: Integer): HWND; stdcall; external 'comctl32.dll';

constructor TSpinEdit.Create(AParent: TWinControl);
begin
 if AParent = nil then ExitProcess(0);
 TWinControl(Self).Create(Parent);
 InitCommonControls;
 EditBox:=TEdit.Create(AParent, '');
 FColor := clBtnFace;
 FWidth := 16;
 FHeight := 16;
 FStyle := WS_CHILD or WS_VISIBLE or UDS_SETBUDDYINT {or WS_CLIPSIBLINGS or WS_CLIPCHILDREN};
 FHandle:=CreateUpDownControl(FStyle, FLeft, FTop, FWidth, FHeight, AParent.Handle, 0, hInstance, EditBox.Handle, 255, 0, 0);
 SetProp(FHandle, App_Id, THandle(Self));
 FDefWndProc := GetWindowLong(FHandle, GWL_WNDPROC);
 SetWindowLong(FHandle, GWL_WNDPROC, Longint(GetWndProc));
{$ifdef FontAutoCreate}
  FFont := TFont.Create;
  FFont.Control := Self;
{$endif}
{$ifdef CanvasAutoCreate}
  FCanvas := TCanvas.Create(FHandle);
  FCanvas.FPen := TPen.Create(FCanvas);
  FCanvas.FBrush := TBrush.Create(FCanvas);
{$endif}
  Editbox.SetBounds(0, 0, 30, 16);
end;

procedure TSpinEdit.SetPosition(Left, Top: Integer);
begin
inherited;
EditBox.SetPosition(Left-EditBox.Width, Top);
end;

procedure TSpinEdit.SetBounds(Left, Top, Width, Height: Integer);
begin
EditBox.SetBounds(Left-EditBox.Width, Top, Width, Height);
Width:=15;
inherited;
end;

{ TIPEdit }

constructor TIPEdit.Create(AParent: TWinControl; Text: String);
begin
  if AParent = nil then ExitProcess(0);
//  InitCommonControls;
  InitCommonControl(ICC_INTERNET_CLASSES);
  inherited Create(AParent);
  FWidth := 121;
  FHeight := 21;
  FClassName := 'SysIPAddress32';
  FStyle := WS_CHILD or WS_VISIBLE or UDS_SETBUDDYINT {or WS_CLIPSIBLINGS or WS_CLIPCHILDREN};
  FColor := clBtnFace ;
  CreateWnd;
end;

{ TDateTimePicker }

constructor TDateTimePicker.Create(AParent: TWinControl; Kind: TDateTimeKind); //07.04.04
begin
  if AParent = nil then ExitProcess(0);
//  InitCommonControls;
  InitCommonControl(ICC_DATE_CLASSES);
  inherited Create(AParent);
  FWidth := 186;
  FHeight := 21;
  FClassName := 'SysDateTimePick32';
  FStyle := WS_CHILD or WS_VISIBLE {or WS_CLIPSIBLINGS or WS_CLIPCHILDREN};
  FColor := clBtnFace ;

  if Kind = dtkTime then
   begin
    FStyle := FStyle or DTS_TIMEFORMAT ;
    FKind := dtkTime;
   end;

  CreateWnd;
end;

function TDateTimePicker.GetDateTime: TDateTime;
var
  st: TSystemTime;
begin
  Perform(DTM_GETSYSTEMTIME, 0, Longint(@st));
  SystemTimeToDateTime(st, Result);
end;

procedure TDateTimePicker.SetDateFormat(const Value: TDTDateFormat);
const
  Formats: array[TDTDateFormat] of Integer = (DTS_SHORTDATEFORMAT, DTS_LONGDATEFORMAT);
begin
  if FDateFormat <> Value then
   begin
    Style := Style or Formats[Value] and not Formats[FDateFormat];
    FDateFormat := Value;
   end;
end;

{procedure TDateTimePicker.SetDateMode(const Value: TDTDateMode);
begin
  if FDateMode <> Value then
   begin
    FDateMode := Value;
    if FDateMode = dmUpDown then
      Style := Style or DTS_UPDOWN
    else
      Style := Style and not DTS_UPDOWN;
   end;
end;}

procedure TDateTimePicker.SetDateTime(const Value: TDateTime);
var
  st: TSystemTime;
begin
  DateTimeToSystemTime(Value, st);
  Perform(DTM_SETSYSTEMTIME, GDT_VALID, Longint(@st));
end;

procedure TDateTimePicker.SetKind(const Value: TDateTimeKind);
begin
  if FKind <> Value then
   begin
    FKind := Value;
    if Value = dtkTime then
     Style := Style or DTS_TIMEFORMAT
    else
     Style := Style and not DTS_TIMEFORMAT;
   end;
end;

{ TTrackBar }

constructor TTrackBar.Create(AParent: TWinControl);
begin
 if AParent = nil then ExitProcess(0);
 InitCommonControls;
 inherited Create(AParent);
 FWidth := 150;
 FHeight := 30;
 FClassName := 'msctls_trackbar32';
 FStyle := WS_CHILD or WS_VISIBLE or TBS_TOP {or TBS_FIXEDLENGTH} or TBS_AUTOTICKS;
 FColor := clBtnFace ;

 Max := 10;

 CreateWnd;
end;

function TTrackBar.GetMax: DWord;
begin
  Result:=Perform(TBM_GETRANGEMAX, 0, 0);
end;

function TTrackBar.GetMin: DWord;
begin
  Result:=Perform(TBM_GETRANGEMIN, 0, 0);
end;

function TTrackBar.GetTBPosition: DWord;
begin
  Result:=Perform(TBM_GETPOS, 0, 0);
end;

procedure TTrackBar.SetMax(const Value: DWord);
begin
  Perform(TBM_SETRANGEMAX, 1,Value);
end;

procedure TTrackBar.SetMin(const Value: DWord);
begin
  Perform(TBM_SETRANGEMIN, 1, Value);
end;

procedure TTrackBar.SetTBPosition(const Value: DWord);
begin
  Perform(TBM_SETPOS, 1, Value);
end;

{ TStatusBar }

function CreateStatusWindow(Style: Longint; lpszText: PChar;
  hwndParent: HWND; wID: UINT): HWND; stdcall; external 'comctl32.dll' name 'CreateStatusWindowA';

constructor TStatusBar.Create(AParent: TWinControl; SimpleText: String);
const
  SBARS_SIZEGRIP          = $0100;
  CCS_TOP                 = $00000001;
begin
 if AParent = nil then ExitProcess(0);
 InitCommonControls;
 inherited Create(AParent);
// FWidth := 150;
 FWidth := 0;
 FHeight := 0;
 FLeft := 0;
 FTop := 0;
// FHeight := 45;
 FClassName := 'msctls_statusbar32';
 FCaption := PChar(SimpleText);
// FExStyle := WS_EX_CLIENTEDGE ;
 FStyle := WS_CHILD{ or 3} or WS_VISIBLE;
 FColor := clBtnFace ;

 Aparent.OnResize := WMSIZE;

 CreateWnd;
end;

function TStatusBar.GetSimpleText: String;
begin
  Result := Text;
end;

procedure TStatusBar.SetSimplePanel(const Value: Boolean);
begin
//  if FSimplePanel <> Value then
//   begin 
    FSimplePanel := Value;
    Perform(SB_SIMPLE, Ord(not Value), 0);
//   end;
end;

procedure TStatusBar.SetSimpleText(const Value: String);
begin
  Text := Value;
end;

procedure TStatusBar.WMSIZE(Sender: TObject);
begin
  Perform(WM_SIZE, 0, 0);
end;

function TStatusBar.SetParts(PartsNum: Integer; const Coords: array of Integer): Boolean;
begin
  Result:=Perform(SB_SETPARTS, PartsNum, Integer(@Coords))<>0;
end;

function TStatusBar.GetParts(var PartsNum: Integer; var Coords: array of Integer): Boolean;
begin
  PartsNum:=Perform(SB_GETPARTS, Length(Coords), Integer(@Coords));
  Result:=PartsNum<>0;
end;

procedure TStatusBar.SetPartText(PartNum: Byte; TextStyle: Word; const Text: string);
begin
  Perform(SB_SETTEXT, TextStyle or PartNum, Integer(PChar(Text)));
end;

function TStatusBar.GetPartText(PartNum: Byte): string;
var
  P: PChar;
begin
  Perform(SB_GETTEXT, PartNum, Integer(P));
  Result:=string(P);
end;

{ Exception }

procedure ConvertErrorFmt(ResString: PResStringRec; const Args: array of const);
begin
  raise EConvertError.CreateFmt(LoadResString(ResString), Args);
end;

type
  PRaiseFrame = ^TRaiseFrame;
  TRaiseFrame = record
    NextRaise: PRaiseFrame;
    ExceptAddr: Pointer;
    ExceptObject: TObject;
    ExceptionRecord: PExceptionRecord;
  end;

{ Return current exception object }

function ExceptObject: TObject;
begin
  if RaiseList <> nil then
    Result := PRaiseFrame(RaiseList)^.ExceptObject else
    Result := nil;
end;

function GetExceptionObject(P: PExceptionRecord): TObject;
begin
  Result := Exception.Create('Exception code: $'+IntToHex(P.ExceptionCode, 8));
end;

function GetExceptionClass(P: PExceptionRecord): ExceptClass;
begin
  Result := Exception;
end;

procedure ErrorHandler(ErrorCode: Byte; ErrorAddr: Pointer); export;
begin
  raise Exception.Create('Error code: '+IntToStr(ErrorCode)) at ErrorAddr;
end;

procedure AssertErrorHandler(const Message, FileName: string; LineNumber: Integer; ErrorAddr: Pointer);
begin
  raise EAssertionFailed.CreateFmt('Assertion "%s" failed in file "%s" at line %d', [Message, FileName, LineNumber]) at ErrorAddr;
end;

procedure ExceptHandler(ExceptObject: Exception; ExceptAddr: Pointer); far;
begin
  ShowMessage('Exception "'+ExceptObject.ClassName+'" at '+IntToHex(Cardinal(ExceptAddr), 8)+' with message "'+ExceptObject.Message+'"');
  Halt(1);
end;

type
  PStrData = ^TStrData;
  TStrData = record
    Ident: Integer;
    Buffer: PChar;
    BufSize: Integer;
    nChars: Integer;
  end;

function EnumStringModules(Instance: Longint; Data: Pointer): Boolean;
begin
  with PStrData(Data)^ do
  begin
    nChars := LoadString(Instance, Ident, Buffer, BufSize);
    Result := nChars = 0;
  end;
end;

function FindStringResource(Ident: Integer; Buffer: PChar; BufSize: Integer): Integer;
var
  StrData: TStrData;
begin
  StrData.Ident := Ident;
  StrData.Buffer := Buffer;
  StrData.BufSize := BufSize;
  StrData.nChars := 0;
  EnumResourceModules(EnumStringModules, @StrData);
  Result := StrData.nChars;
end;

function LoadStr(Ident: Integer): string;
var
  Buffer: array[0..1023] of Char;
begin
  SetString(Result, Buffer, FindStringResource(Ident, Buffer, SizeOf(Buffer)));
end;

function SafeLoadLibrary(const Filename: string; ErrorMode: UINT): HMODULE;
var
  OldMode: UINT;
  FPUControlWord: Word;
begin
  OldMode := SetErrorMode(ErrorMode);
  try
    asm
      FNSTCW  FPUControlWord
    end;
    try
      Result := LoadLibrary(PChar(Filename));
    finally
      asm
        FNCLEX
        FLDCW FPUControlWord
      end;
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

procedure RaiseLastWin32Error;
var
  LastError: DWORD;
  Error: EWin32Error;
begin
  LastError := GetLastError;
  if LastError <> ERROR_SUCCESS then
    Error := EWin32Error.CreateResFmt(@SWin32Error, [LastError,
      SysErrorMessage(LastError)])
  else
    Error := EWin32Error.CreateRes(@SUnkWin32Error);
  Error.ErrorCode := LastError;
  raise Error;
end;

function Win32Check(RetVal: BOOL): BOOL;
begin
  if not RetVal then RaiseLastWin32Error;
  Result := RetVal;
end;

procedure Abort;

  function ReturnAddr: Pointer;
  asm
//          MOV     EAX,[ESP + 4] !!! codegen dependant
          MOV     EAX,[EBP - 4]
  end;

begin
  raise EAbort.Create(SOperationAborted) at ReturnAddr;
end;

constructor Exception.Create(const Msg: string);
begin
  FMessage := Msg;
end;

constructor Exception.CreateResFmt(Ident: Integer; const Args: array of const);
begin
  FMessage := Format(LoadStr(Ident), Args);
end;

constructor Exception.CreateRes(Ident: Integer);
begin
  FMessage := LoadStr(Ident);
end;

constructor Exception.CreateRes(ResStringRec: PResStringRec);
begin
  FMessage := LoadResString(ResStringRec);
end;

constructor Exception.CreateResFmt(ResStringRec: PResStringRec; const Args: array of const);
begin
  FMessage := Format(LoadResString(ResStringRec), Args);
end;

constructor Exception.CreateFmt(const Msg: string; const Args: array of const);
begin
  FMessage := Format(Msg, Args);
end;

constructor Exception.CreateHelp(const Msg: string; AHelpContext: Integer);
begin
  FMessage := Msg;
  FHelpContext := AHelpContext;
end;

{ TThread }

const
  CM_EXECPROC = $8FFF;
  CM_DESTROYWINDOW = $8FFE;

{type
  PRaiseFrame = ^TRaiseFrame;
  TRaiseFrame = record
    NextRaise: PRaiseFrame;
    ExceptAddr: Pointer;
    ExceptObject: TObject;
    ExceptionRecord: PExceptionRecord;
  end; }

var
  ThreadLock: TRTLCriticalSection;
  ThreadWindow: HWND;
  ThreadCount: Integer;

procedure FreeThreadWindow;
begin
  if ThreadWindow <> 0 then
  begin
    DestroyWindow(ThreadWindow);
    ThreadWindow := 0;
  end;
end;  

function ThreadWndProc(Window: HWND; Message, wParam, lParam: Longint): Longint; stdcall;
begin
  case Message of
    CM_EXECPROC:
      with TThread(lParam) do
      begin
        Result := 0;
        try
          FSynchronizeException := nil;
          FMethod;
        except
          if RaiseList <> nil then
          begin
            FSynchronizeException := PRaiseFrame(RaiseList)^.ExceptObject;
            PRaiseFrame(RaiseList)^.ExceptObject := nil;
          end;
        end;
      end;
    CM_DESTROYWINDOW:
      begin
        EnterCriticalSection(ThreadLock);
        try
          Dec(ThreadCount);
          if ThreadCount = 0 then
            FreeThreadWindow;
        finally
          LeaveCriticalSection(ThreadLock);
        end;
        Result := 0;
      end;
  else
    Result := DefWindowProc(Window, Message, wParam, lParam);
  end;
end;

var
  ThreadWindowClass: TWndClass = (
    style: 0;
    lpfnWndProc: @ThreadWndProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: 'TThreadWindow');

procedure AddThread;

  function AllocateWindow: HWND;
  var
    TempClass: TWndClass;
    ClassRegistered: Boolean;
  begin
    ThreadWindowClass.hInstance := HInstance;
    ClassRegistered := GetClassInfo(HInstance, ThreadWindowClass.lpszClassName,
      TempClass);
    if not ClassRegistered or (TempClass.lpfnWndProc <> @ThreadWndProc) then
    begin
      if ClassRegistered then
        Windows.UnregisterClass(ThreadWindowClass.lpszClassName, HInstance);
      Windows.RegisterClass(ThreadWindowClass);
    end;
    Result := CreateWindow(ThreadWindowClass.lpszClassName, '', 0,
      0, 0, 0, 0, 0, 0, HInstance, nil);
  end;

begin
  EnterCriticalSection(ThreadLock);
  try
    if ThreadCount = 0 then
      ThreadWindow := AllocateWindow;
    Inc(ThreadCount);
  finally
    LeaveCriticalSection(ThreadLock);
  end;
end;

procedure RemoveThread;
begin
  EnterCriticalSection(ThreadLock);
  try
    if ThreadCount = 1 then
      PostMessage(ThreadWindow, CM_DESTROYWINDOW, 0, 0);
  finally
    LeaveCriticalSection(ThreadLock);
  end;
end;

//-----------------

function ThreadProc(Thread: TThread): Integer;
var
  FreeThread: Boolean;
begin
  try
    Thread.Execute;
  finally
    FreeThread := Thread.FFreeOnTerminate;
    Result := Thread.FReturnValue;
    Thread.FFinished := True;
    Thread.DoTerminate;
    if FreeThread then Thread.Free;
    EndThread(Result);
  end;
end;

procedure TThread.CallOnTerminate;
begin
  if Assigned(FOnTerminate) then FOnTerminate(Self);
end;

constructor TThread.Create(CreateSuspended: Boolean);
var
  Flags: DWORD;
begin
  inherited Create;
////////////////////////////////////////
  InitializeCriticalSection(ThreadLock);
////////////////////////////////////////
  AddThread;
  FSuspended := CreateSuspended;
  Flags := 0;
  if CreateSuspended then Flags := CREATE_SUSPENDED;
  FHandle := BeginThread(nil, 0, @ThreadProc, Pointer(Self), Flags, FThreadID);
end;

destructor TThread.Destroy;
begin
  if not FFinished and not Suspended then
  begin
    Terminate;
    WaitFor;
  end;
  if FHandle <> 0 then CloseHandle(FHandle);
  inherited Destroy;
  RemoveThread;
//////////////////////////////////////////
//  DeleteCriticalSection(ThreadLock);  //
//////////////////////////////////////////
end;

procedure TThread.DoTerminate;
begin
  if Assigned(FOnTerminate) then Synchronize(CallOnTerminate);
end;

procedure TThread.Resume; //01.05.03
begin
  if ResumeThread(FHandle) = 1 then
   begin
    FSuspended := False;
    if Assigned(FOnExecute) then FOnExecute(Self);
   end;
end;

procedure TThread.Suspend;
begin
  FSuspended := True;
  SuspendThread(FHandle);
  if Assigned(FOnSuspend) then FOnSuspend(Self);
end;

procedure TThread.SetSuspended(Value: Boolean);
begin
  if Value <> FSuspended then
    if Value then
      Suspend else
      Resume;
end;

procedure TThread.Synchronize(Method: TThreadMethod);
begin
  FSynchronizeException := nil;
  FMethod := Method;
  SendMessage(ThreadWindow, CM_EXECPROC, 0, Longint(Self));
  if Assigned(FSynchronizeException) then raise FSynchronizeException;
end;

procedure TThread.Terminate;
begin
  FTerminated := True;
end;

function TThread.WaitFor: LongWord;
var
  Msg: TMsg;
  H: THandle;
begin
  H := FHandle;
  if GetCurrentThreadID = MainThreadID then
    while MsgWaitForMultipleObjects(1, H, False, INFINITE,
      QS_SENDMESSAGE) = WAIT_OBJECT_0 + 1 do PeekMessage(Msg, 0, 0, 0, PM_NOREMOVE)
  else WaitForSingleObject(H, INFINITE);
  GetExitCodeThread(H, Result);
end;

const
  Priorities: array [TThreadPriority] of Integer =
   (THREAD_PRIORITY_IDLE, THREAD_PRIORITY_LOWEST, THREAD_PRIORITY_BELOW_NORMAL,
    THREAD_PRIORITY_NORMAL, THREAD_PRIORITY_ABOVE_NORMAL,
    THREAD_PRIORITY_HIGHEST, THREAD_PRIORITY_TIME_CRITICAL);

function TThread.GetPriority: TThreadPriority;
var
  P: Integer;
  I: TThreadPriority;
begin
  P := GetThreadPriority(FHandle);
  Result := tpNormal;
  for I := Low(TThreadPriority) to High(TThreadPriority) do
    if Priorities[I] = P then Result := I;
end;

procedure TThread.SetPriority(Value: TThreadPriority);
begin
  SetThreadPriority(FHandle, Priorities[Value]);
end;

function TList.Last: Pointer;
begin
  Result := Get(FCount - 1);
end;

{ THotKey }

constructor THotKey.Create(AParent: TWinControl);
begin
 if AParent = nil then ExitProcess(0);
 InitCommonControls;
 inherited Create(AParent);
 FWidth := 121;
 FHeight := 19;
 FClassName := 'msctls_hotkey32';
 FStyle := WS_CHILD or WS_VISIBLE {or WS_CLIPSIBLINGS or WS_CLIPCHILDREN};
// FColor := clBtnFace ;

 CreateWnd;
end;

procedure THotKey.GetData;
var
  AHotKey:Word;
begin
  AHotKey:=Perform(HKM_GETHOTKEY, 0, 0);
  FHotKey:=Lo(AHotKey);
  FMod:=Hi(AHotKey);
end;

procedure THotKey.SetData;
begin
  Perform(HKM_SETHOTKEY, MakeWord(FHotKey, FMod),0);
end;

function THotKey.GetHotKey: byte;
begin
  GetData;
  Result:=FHotKey;
end;

procedure THotKey.SetHotKey(const Value: byte);
begin
  FHotKey:=Value;
  SetData;
end;

function THotKey.GetModifiers: TModifiers;
begin
  GetData;
  if (FMod and $01)<>0
    then Result:=[mShift]
    else Result:=[];
  if (FMod and $02)<>0 then Result:=Result+[mCtrl];
  if (FMod and $04)<>0 then Result:=Result+[mAlt];
  if (FMod and $08)<>0 then Result:=Result+[mExt];
end;

procedure THotKey.SetModifiers(const Value: TModifiers);
begin
  if mShift in Value
    then FMod:=$01
    else FMod:=0;
  if mCtrl in Value then FMod:=FMod or $02;
  if mAlt in Value then FMod:=FMod or $04;
  if mExt in Value then FMod:=FMod or $08;
  SetData;
end;

function TMemo.LineCurIndex: Integer;
begin
  Result := Perform(EM_LINEFROMCHAR, word(-1),0);
end;  

function TMemo.LineCount: Integer;
begin
  Result := Perform(EM_GETLINECOUNT, word(-1),0);
end;

procedure TMemo.LineInsert(Index: Integer; S: String);
var
  sl: TStringList;
begin
  sl := TStringList.Create ;
  sl.Text := LineText;
  sl.Insert(Index, S);
  //ShowMessage(sl.Text);
  LineText := sl.Text ;
  sl.Free ;
end;

function TMemo.Undo: Boolean;
begin
  Result := LongBool(Perform(EM_UNDO, 0, 0));
end;

function TWinControl.GetVisible: Boolean;
begin
  Result := IsWindowVisible(FHandle); 
end;

{ TMonthCalendar }

constructor TMonthCalendar.Create(AParent: TWinControl); //07.04.04
begin
  if AParent = nil then ExitProcess(0);
//  InitCommonControls;
  InitCommonControl(ICC_DATE_CLASSES);
  inherited Create(AParent);
  FWidth := 191;
  FHeight := 154;
  FClassName := 'SysMonthCal32';
  FStyle := WS_CHILD or WS_VISIBLE {or WS_CLIPSIBLINGS or WS_CLIPCHILDREN};
  FColor := clBtnFace ;

  CreateWnd;
end;

function TMonthCalendar.GetDateTime: TDateTime;
var
  st: TSystemTime;
begin
  Perform(DTM_GETSYSTEMTIME, 0, Longint(@st));
  SystemTimeToDateTime(st, Result);
end;

procedure TMonthCalendar.SetDateTime(const Value: TDateTime);
var
  st: TSystemTime;
begin
  DateTimeToSystemTime(Value, st);
  Perform(DTM_SETSYSTEMTIME, GDT_VALID, Longint(@st));
end;

{ TListView }

constructor TListView.Create(AParent: TWinControl);
begin
 if AParent = nil then ExitProcess(0);
 InitCommonControls;
 inherited Create(AParent);
 FWidth := 250;
 FHeight := 150;
 FClassName := 'SysListView32';
 FExStyle := WS_EX_CLIENTEDGE ;
 FStyle := WS_CHILD or WS_VISIBLE or LVS_SINGLESEL;
 //FColor := clBtnFace ;

 CreateWnd;
end;

procedure TListView.SetViewStyle(const Value: Integer);
begin
  if FViewStyle <> Value then
   begin
    Style := Style and not FViewStyle;
    Style := Style or Value;
    FViewStyle := Value;
   end;
end;

procedure TListView.ColumnAdd(ACaption: String; Width: Integer);
begin
  ColumnInsert(ACaption, FColumnCount, Width);
end;

procedure TListView.ColumnAddEx(ACaption: String; Width: Integer; Align: TTextAlign);
begin
  ColumnInsertEx(ACaption, FColumnCount, Width, Align);
end;

procedure TListView.ColumnInsert(ACaption: String; Index, Width: Integer);
var
  col: TLVColumn;
begin
  col.pszText := PChar(ACaption);
  col.cx := Width;
  col.mask := LVCF_TEXT	or LVCF_WIDTH;
  if Perform(LVM_INSERTCOLUMN, Index, Longint(@col)) >= 0 then Inc(FColumnCount);
end;

procedure TListView.ColumnDelete(Index: Integer);
begin
  if Perform(LVM_DELETECOLUMN, Index, 0) >= 0 then Dec(FColumnCount);;
end;

function TListView.ItemInsert(Caption: String; Index: Integer): Integer;
var
  Item: TLVItem;
begin
//  ZeroMemory(@Item, 44);
  Item.mask := LVIF_TEXT or LVIF_IMAGE;
  Item.iItem := Index;
  Item.iSubItem := 0;
  Item.iImage := 0;
  Item.pszText := PChar(Caption);
  Result := Perform(LVM_INSERTITEM, 0, LongInt(@Item));
end;

function TListView.ItemAdd(Caption: String): Integer;
begin
  Result := ItemInsert(Caption, ItemCount);
end;

function TListView.ItemCount: Integer;
begin
  Result := Perform(LVM_GETITEMCOUNT, 0, 0);
end;

function TListView.GetItem(Row, Col: Integer): String;
var
  Item: TLVItem;
  Cnt: Integer;
begin
  Result := '';
  Item.iSubItem := Col;
  repeat
    SetLength(Result, Max(2 * Length(Result), 256));
    Item.pszText := PChar(Result);
    Item.cchTextMax := Length(Result) + 1;
    Cnt := Perform(LVM_GETITEMTEXT, Row, Longint(@Item));
  until Cnt < (Item.cchTextMax - 1);
  SetLength(Result, Cnt);
end;

procedure TListView.SetItem(Row, Col: Integer; const Value: String);
var
  Item: TLVItem;
begin
  Item.iSubItem := Col;
  Item.pszText := PChar(Value);
  Perform(LVM_SETITEMTEXT, Row, Integer(@Item));
end;

procedure TListView.Clear;
begin
  Perform(LVM_DELETEALLITEMS, 0, 0);
end;

procedure TListView.SetOptionsEx(const Value: Integer);
begin
  if FOptionsEx <> Value then
   begin
    FOptionsEx := Value;
    Perform(LVM_SETEXTENDEDLISTVIEWSTYLE, 0, Value);
   end; 
end;

procedure TListView.ItemDelete(Index: Integer);
begin
  Perform(LVM_DELETEITEM, Index, 0);
end;

procedure TListView.Arrange(Code: TListArrangement);
const
  Codes: array[TListArrangement] of Longint = (LVA_ALIGNBOTTOM, LVA_ALIGNLEFT,
    LVA_ALIGNRIGHT, LVA_ALIGNTOP, LVA_DEFAULT, LVA_SNAPTOGRID);
begin
  Perform(LVM_ARRANGE, Codes[Code], 0);
end;  

function TListView.ColumnCount: Integer;
begin
  Result := FColumnCount;
end;

function TListView.GetSelCount: Integer;
begin
  Result := Perform(LVM_GETSELECTEDCOUNT, 0, 0);
end;

function TListView.GetSelectedCaption: String;
var
  i: Integer;
begin
  i := GetSelectedIndex;
  if i<>-1 then Result := GetItem(i, 0);
end;

procedure TListView.SetSelectedCaption(const Value: String);
var
  i: Integer;
begin
  i := GetSelectedIndex;
  if i<>-1 then SetItem(i, 0, Value);
end;

function TListView.GetSelectedIndex: Integer;
begin
  Result := Perform(LVM_GETNEXTITEM, -1, LVNI_SELECTED);
end;

procedure TListView.SetSelectedIndex(const Value: Integer); //02.09.03
var
  Item: TLVItem;
begin
  Item.mask := LVIF_STATE;
  Item.iItem := Value;
  Item.iSubItem := 0;
  Item.StateMask := $FFFF;
  Item.State :=  LVIS_SELECTED;
  Perform(LVM_SETITEM, 0, Longint(@Item));
end;

procedure TListView.SetLargeImages(const Value: TImageList);
begin
  FLargeImages := Value;
  Perform(LVM_SETIMAGELIST, LVSIL_NORMAL, Value.FHandle);
end;

procedure TListView.SetSmallImages(const Value: TImageList);
begin
  FSmallImages := Value;
  Perform(LVM_SETIMAGELIST, LVSIL_SMALL, Value.FHandle);
end;

procedure TListView.SetStateImages(const Value: TImageList);
begin
  FStateImages := Value;
  Perform(LVM_SETIMAGELIST, LVSIL_STATE, Value.FHandle);
end;

function TListView.GetItemImageIndex(Index: Integer): Integer;
var
  Item: TLVItem;
begin
  Result := -1;
  Item.mask := LVIF_IMAGE;
  Item.iItem := Index;
  Item.iSubItem := 0;
  if Perform(LVM_GETITEM, 0, Longint(@Item)) <> 0  then  Result := Item.iImage ;
end;

procedure TListView.SetItemImageIndex(Index: Integer; const Value: Integer);
var
  Item: TLVItem;
begin
  Item.mask := LVIF_IMAGE;
  Item.iItem := Index;
  Item.iSubItem := 0;
  Item.iImage := Value ;
  Perform(LVM_SETITEM, 0, Longint(@Item));
end;

{procedure TListView.WMNOTIFY(var AMsg: TMessage);
var
  Hdr: PNMHdr;
begin
  Hdr := Pointer(AMsg.lParam);
  if Hdr.code = LVN_ITEMCHANGED then
   begin
    ShowMessage('1') ;
    Dispatch(amsg);
   end;
end; }

procedure TListView.SetFlatScrollBars(const Value: Boolean);
begin
  if FFlatScrollBars <> Value then
   begin
    FFlatScrollBars := Value;
    if FFlatScrollBars then
     OptionsEx := OptionsEx or LVS_EX_FLATSB
    else
     OptionsEx := OptionsEx and not LVS_EX_FLATSB;
   end;
end;

procedure TListView.SetHotTrack(const Value: Boolean);
begin
  if FHotTrack <> Value then
   begin
    FHotTrack := Value;
    if FFlatScrollBars then
     OptionsEx := OptionsEx or LVS_EX_TRACKSELECT
    else
     OptionsEx := OptionsEx and not LVS_EX_TRACKSELECT;
   end;
end;

function TListView.GetColumns(ColumnIndex: Integer): String; //17.03.03
var
  Buf: array[0..4095] of Char;
  LC: TLVColumn;
begin
  LC.mask := LVCF_TEXT;
  LC.pszText := @Buf[0];
  LC.cchTextMax := SizeOf(Buf);
  Buf[0] := #0;
  Perform(LVM_GETCOLUMN, ColumnIndex, Integer(@LC)); //Получаем инфу о колонке
  Result := Buf;
end;

procedure TListView.SetColumns(ColumnIndex: Integer; const Value: String); //17.03.03
var
  LC: TLVColumn;
begin
  FillChar(LC, SizeOf(LC), 0);
  LC.mask := LVCF_TEXT;
  LC.pszText := '';
  if Value <> '' then LC.pszText := @Value[1];
  Perform(LVM_SETCOLUMN, ColumnIndex, Integer(@LC));  //Устанавливаем текст колонки 
end;

procedure TListView.ColumnInsertEx(ACaption: String; Index, Width: Integer; Align: TTextAlign);
var
  col: TLVColumn;
begin
  col.pszText := PChar(ACaption);
  col.cx := Width;
  col.fmt := Ord(Align);
  col.mask := LVCF_TEXT	or LVCF_WIDTH or LVCF_FMT;
  if Perform(LVM_INSERTCOLUMN, Index, Longint(@col)) >= 0 then Inc(FColumnCount);
end;

var
  ListView: TListView;

function DefaultListViewSort(Item1, Item2, lParam: Integer): Integer; stdcall;
begin
  //with Item1 do
    if Assigned(ListView.OnCompare) then
      ListView.OnCompare(ListView, Item1, Item2, lParam, Result)
    else
      Result := lstrcmpi(PChar(ListView.Items[Item1, 0]), PChar(ListView.Items[Item2, 0]));
end;

type
  PFNLVCOMPARE = function(lParam1, lParam2, lParamSort: Integer): Integer stdcall;
  TLVCompare = PFNLVCOMPARE;

function ListView_SortItems(hwndLV: HWND; pfnCompare: TLVCompare;
  lPrm: Longint): Bool;
begin
  Result := Bool(SendMessage(hwndLV, LVM_SORTITEMS, lPrm,
    Longint(@pfnCompare)));
end;

function TListView.AlphaSort: Boolean;
begin
  ListView := Self;
  //if HandleAllocated then
    Result := ListView_SortItems(FHandle, @DefaultListViewSort, 0)
  //else Result := False;
end;

procedure TListView.SetSortType(const Value: TSortType);
begin
  if SortType <> Value then
  begin
    FSortType := Value;
    if ((SortType in [stData, stBoth]) and Assigned(OnCompare)) or
      (SortType in [stText, stBoth]) then
      AlphaSort;
  end;
end;

{ TScreen }

function TScreen.GetHeight: Integer;
begin
  Result := ScreenHeight;
end;

function TScreen.GetTwipsPerPixelX: Extended;
begin
  Result := 1440 / GetDeviceCaps(GetDc(0), LOGPIXELSX);
end;

function TScreen.GetTwipsPerPixelY: Extended;
begin
  Result := 1440 / GetDeviceCaps(GetDc(0), LOGPIXELSY);
end;

function TScreen.GetWidth: Integer;
begin
  Result := ScreenWidth;
end;

procedure TWinControl.BeginUpdate;
begin
  Inc(FUpdateCounter);
  if FUpdateCounter = 1 then Perform(WM_SETREDRAW, 0, 0);
end;

procedure TWinControl.EndUpdate;
begin
  FUpdateCounter := Max(0, FUpdateCounter - 1);
  if FUpdateCounter = 0 then
    Perform(WM_SETREDRAW, 1, 0);
end;

function TWinControl.GetSelLength: Integer;
var
  StartPos, EndPos: Integer;
begin
  Perform(EM_GETSEL, Longint(@StartPos), Longint(@EndPos));
  Result := EndPos - StartPos;
end;

function TWinControl.GetSelStart: Integer;
begin
  Perform(EM_GETSEL, Longint(@Result), 0);
end;

function TWinControl.GetSelText: string;
begin
  Result := Copy(Text, SelStart+1, SelLength);
end;

procedure TWinControl.SetSelLength(const Value: Integer);
var
  StartPos, EndPos: Integer;
begin
  Perform(EM_GETSEL, Longint(@StartPos), Longint(@EndPos));
  EndPos := StartPos + Value;
  Perform(EM_SETSEL, StartPos, EndPos);
  Perform(EM_SCROLLCARET, 0,0);
end;

procedure TWinControl.SetSelStart(const Value: Integer);
begin
  Perform(EM_SETSEL, Value, Value);
end;

procedure TWinControl.SetSelText(const Value: string);
begin
  Perform(EM_REPLACESEL, 0, Longint(PChar(Value)));
end;

function TWinControl.GetWindowHandle: HWnd;
begin
  Result := FHandle;
end;

procedure TMemo.LoadFromFile(FileName: String);
var
  fs: TFileStream;
  Size: Integer;
  s: String;
begin
  fs := TFileStream.Create(FileName, fmOpenRead);

  Size := fs.Size - fs.Position;
  SetString(S, nil, Size);
  fs.Read(Pointer(S)^, Size);
  Text := S;

  fs.Free ;
end;

procedure TMemo.SaveToFile(FileName: String);
var
  fs: TFileStream;
begin
  if FileExists(FileName) then
   fs := TFileStream.Create(FileName, fmOpenWrite)
  else
   fs := TFileStream.Create(FileName, fmCreate);

  fs.WriteBuffer(Pointer(Text)^, Length(Text));
  fs.Free ;
end;

{ TScrollBox }

(*constructor TScrollBox.Create(AParent: TWinControl; Text: String);
begin
 if AParent = nil then ExitProcess(0);
 inherited Create(AParent);
 FWidth := 250;
 FHeight := 150;
 FClassName := 'SCROLLBAR';
 FExStyle := WS_EX_CLIENTEDGE ;
 FStyle := WS_CHILD or WS_VISIBLE or SBS_HORZ or SBS_VERT
  or WS_VSCROLL or WS_HSCROLL {or WS_CLIPSIBLINGS or WS_CLIPCHILDREN};
 FColor := clWhite ;

 CreateWnd;
end;  *)

{ TImageList }

function ImageList_AddIcon(ImageList: HImageList; Icon: HIcon): Integer;
begin
  Result := ImageList_ReplaceIcon(ImageList, -1, Icon);
end;

//------------------------------------------------------------------------------

constructor TImageList.Create;
begin
  FAllocBy := 4;
  FBkColor := clNone;
  FMasked := True;
  FWidth := 16;
  FHeight := 16;
end;

destructor TImageList.Destroy;
begin
  if FHandle<>0 then ImageList_Destroy(FHandle);
end;

function TImageList.AddIcon(Image: hIcon): Integer;
begin
  if FHandle = 0 then CreateList;
  Result := ImageList_AddIcon(FHandle, Image);
end;   

procedure TImageList.SetHeight(const Value: Integer);
begin
  if FHandle <> 0 then Exit;
  FHeight := Value;
end;

procedure TImageList.SetWidth(const Value: Integer);
begin
  if FHandle <> 0 then Exit;
  FWidth := Value;
end;

procedure TImageList.CreateList;
var
  Flags : DWord;
begin
  if FHandle <>0 then Exit;
  if FWidth  = 0 then Exit;
  if FHeight = 0 then Exit;
//  FWidth:=3604544;
//  FHeight:=0;
  Flags := {ILC_COLOR16;//}ILC_COLOR32;//ILC_COLORDDB;
  if FMasked then Flags := Flags or ILC_MASK;
  FHandle := ImageList_Create(FWidth, FHeight, Flags, 0, FAllocBy);
  if FBkColor <> clNone then SetBkColor(FBkColor);
end;

procedure TImageList.SetAllocBy(const Value: Integer);
begin
  if FHandle <> 0 then Exit;
  FAllocBy := Value;
end;

procedure TImageList.SetMasked(const Value: Boolean);
begin
  if FHandle <> 0 then Exit;
  FMasked := Value;
end;

function TImageList.GetBkColor: TColor;
begin
  Result := FBkColor;
  if FHandle = 0 then Exit;
  Result := ImageList_GetBkColor(FHandle);
end;

procedure TImageList.SetBkColor(const Value: TColor);
begin
  if FHandle = 0 then Exit;
  ImageList_SetBkColor(FHandle, Value); 
end;

function TImageList.AddBitmap(Bmp, Msk: HBitmap): Integer;
begin
  if FHandle = 0 then CreateList ;
  Result := ImageList_Add(FHandle, Bmp, Msk);
end;

function TImageList.AddMasked(Bmp: HBitmap; TransparentColor: TColor): Integer;
begin
  if FHandle = 0 then CreateList ;  
  Result := ImageList_AddMasked(FHandle, Bmp, ColorToRGB(TransparentColor));
end;

function TImageList.LoadSystemIcons(SmallIcons: Boolean): Boolean;
var
  NewHandle : THandle;
  FileInfo : TSHFileInfo;
  Flags : DWord;
begin
  Flags := SHGFI_SYSICONINDEX;
  if SmallIcons then
     Flags := Flags or SHGFI_SMALLICON;
  NewHandle := SHGetFileInfo( '', 0, FileInfo, Sizeof( FileInfo ), Flags );
  Result := NewHandle <> 0;
  if Result then
  begin
     Handle := NewHandle;
//     FShareImages := True;
  end;  
end;

procedure TImageList.Draw(DC: hDC; X, Y, Index: Integer);
begin
  if FHandle = 0 then Exit;
  ImageList_Draw(FHandle, Index, DC, X, Y, GetDrawStyle);
end;

procedure TImageList.DrawStretch(DC: hDC; Index: Integer; const Rect: TRect);
begin
  if FHandle = 0 then Exit;
  ImageList_DrawEx(FHandle, Index, DC, Rect.Left, Rect.Top,Rect.Right-Rect.Left, Rect.Bottom-Rect.Top, BkColor, FBlendColor, GetDrawStyle);
end;

function TImageList.GetDrawStyle: DWord;
begin
  Result := 0;
  if dsBlend25 in DrawingStyle then
     Result := Result or ILD_BLEND25;
  if dsBlend50 in DrawingStyle then
     Result := Result or ILD_BLEND50;
  if dsTransparent in DrawingStyle then
     Result := Result or ILD_TRANSPARENT
  else
  if dsMask in DrawingStyle then
     Result := Result or ILD_MASK
end;

{ TApplication }

constructor TApplication.Create(Caption: String);
//var
//  m:hMenu;
begin
 inherited Create(nil);
 FCaption := PChar(Caption);

 FClassName := 'TForm';
// FParent := Parent;
 FParentHandle := 0;
 FLeft := -100;//cw_UseDefault;
 FTop := -100;//cw_UseDefault;
 FWidth := 1;//cw_UseDefault;
 FHeight := 1;//cw_UseDefault;
 FId := 0;
 FVisible := True;
 FColor := clBtnFace ;

// CreateWindow ;
 with wClass do
  begin
//   Style:=CS_PARENTDC;
//   hIcon:=LoadIcon(hInstance,'MAINICON');
   lpfnWndProc:=GetWndProc;
   hInstance:= hInstance;
   hbrBackground:=COLOR_BTNFACE+1;
   lpszClassName:=PChar(FClassName);//@FClassName[1];
   hCursor:=LoadCursor(0,IDC_ARROW);
  end;
 RegisterClass(wClass);
 FHandle:=CreateWindowEx(0, PChar(FClassName),PChar(FCaption), WS_THICKFRAME or
   WS_SYSMENU  or WS_MINIMIZEBOX or WS_MAXIMIZEBOX or WS_VISIBLE, FLeft,
                    FTop, FWidth, FHeight, GetParentHandle, 0, hInstance, nil);

 SetProp(FHandle, App_Id, THandle(Self));

{$ifdef CanvasAutoCreate}
 FCanvas := TCanvas.Create(FHandle);
 FCanvas.FPen := TPen.Create(FCanvas);
 FCanvas.FBrush := TBrush.Create(FCanvas);
{$endif}

//Ставим иконку
 FIcon := LoadIcon(Hinstance, 'MAINICON');
 Perform(WM_SETICON, ICON_BIG, FIcon);
//Параметры Show
 if Application=nil then MsgDefHandle := FHandle;
// MsgDefCaption := FCaption;

{  M:=GetSystemMenu(handle, false);
  DeleteMenu(M, SC_MAXIMIZE, MF_BYCOMMAND);
  DeleteMenu(M, SC_MOVE, MF_BYCOMMAND);
  DeleteMenu(M, SC_SIZE, MF_BYCOMMAND);
  EnableMenuItem(M, SC_RESTORE, MF_GRAYED or MF_BYCOMMAND);}

end;

procedure TApplication.SetTitle(const Value: String);
begin
  FCaption := PChar(Value);
  Perform(WM_SETTEXT, 0, Longint(PChar(FCaption)));
end;

{ TTreeView }

constructor TTreeView.Create(AParent: TWinControl);
begin
 if AParent = nil then ExitProcess(0);
 InitCommonControls;
 inherited Create(AParent);
 FWidth := 121;
 FHeight := 97;
 FClassName := 'SysTreeView32';
 FExStyle := WS_EX_CLIENTEDGE ;
 FStyle := WS_CHILD or WS_VISIBLE or TVS_HASBUTTONS or TVS_HASLINES or TVS_LINESATROOT{or WS_CLIPSIBLINGS or WS_CLIPCHILDREN};
 FColor := clBtnFace ;

 CreateWnd;
end;

function TTreeView.ItemInsert(Parent: Integer; Text: String): Integer;
type
  TTVInsertStruct = packed Record
    hParent: THandle;
    hAfter : THandle;
    item: TTVItem;
  end;
  TTVInsertStructEx = packed Record
    hParent: THandle;
    hAfter : THandle;
    item: TTVItemEx;
  end;
var TVIns: TTVInsertStruct;
begin
  TVIns.hParent := Parent;
  TVIns.hAfter := 0;
  TVIns.item.mask := TVIF_TEXT{ or TVIF_IMAGE}or TVIF_SELECTEDIMAGE  ;
//  TVIns.item.iImage := 0;
  TVIns.item.iSelectedImage  := 1;
  TVIns.item.pszText := PChar(Text);
  Result := Perform(TVM_INSERTITEM, 0, Integer(@TVIns));
{var
  tvinsert: TTVInsertStruct;
begin
  tvinsert.hParent  := a;
  tvinsert.hInsertAfter := TVI_ROOT;
  tvinsert.item.mask := TVIF_TEXT+TVIF_IMAGE+TVIF_SELECTEDIMAGE;
  tvinsert.item.pszText := PChar(Text);
  tvinsert.item.iImage := 0;
  tvinsert.item.iSelectedImage := 1;
  Perform(TVM_INSERTITEM, 0 ,Longint(@tvinsert));   }
end;

procedure TTreeView.SetImages(const Value: TImageList);
begin
  FImages := Value;
  Perform(TVM_SETIMAGELIST, TVSIL_NORMAL, Value.FHandle);
end;

procedure TTreeView.SetStateImages(const Value: TImageList);
begin
  FStateImages := Value;
  Perform(TVM_SETIMAGELIST, TVSIL_NORMAL, Value.FHandle);
end;

{ TRichEdit }   

constructor TRichEdit.Create(AParent: TWinControl; Text: String; WordWrap: Boolean);
const
  EM_SETEVENTMASK                     = WM_USER + 69;
  ENM_CHANGE                          = $00000001;
  ENM_SELCHANGE                       = $00080000;
begin
 if AParent = nil then ExitProcess(0);
 InitCommonControls;

 RichEditDLL := LoadLibrary('RichEd20.dll');
 if RichEditDLL=0 then ExitProcess(0);

 inherited Create(AParent);
 FWidth := 185;
 FHeight := 89;
 FClassName := 'RichEdit20A';
 FCaption := PChar(Text);
 FExStyle := WS_EX_CLIENTEDGE ;
 FStyle := WS_CHILD or WS_VISIBLE or ES_MULTILINE or WS_VSCROLL or
           ES_NOHIDESEL;
 if not WordWrap then FStyle := FStyle or WS_HSCROLL;
 FColor := clBtnFace ;

 CreateWnd;

 Perform(EM_SETEVENTMASK, 0, ENM_CHANGE or ENM_SELCHANGE);
// Perform(EM_LIMITTEXT, -1, 0); //Убираем ограничение на длину текста
end;

procedure TRichEdit.SetBkColor(const Value: Integer);
begin
  FColor := Value;
  Perform(EM_SETBKGNDCOLOR, 0, Value);
end;

procedure TRichEdit.Undo;
begin
  Perform(EM_UNDO, 0, 0);
end;

procedure TRichEdit.ClearUndo;
begin
  Perform(EM_EMPTYUNDOBUFFER, 0, 0);
end;

function TRichEdit.CanRedo: Boolean;
begin
  Result := Boolean(Perform(EM_CANREDO, 0, 0));
end;

function TRichEdit.CanUndo: Boolean;
begin
  Result := Boolean(Perform(EM_CANUNDO, 0, 0));
end;

procedure TRichEdit.Redo;
begin
  Perform(EM_REDO, 0, 0);
end;

procedure TRichEdit.SetExMaxLength(const Value: Integer);
begin
  FMaxLength := Value;
  Perform(EM_EXLIMITTEXT, 0, Value);  
end;

procedure TRichEdit.LoadFromStream(Stream: TStream);
var
  Size: Integer;
  S: string;
begin
  BeginUpdate;
  try
    Size := Stream.Size - Stream.Position;
    SetString(S, nil, Size);
    Stream.Read(Pointer(S)^, Size);
    SetText(S);
  finally
    EndUpdate;
  end;
end;

{ THeaderControl }

constructor THeaderControl.Create(AParent: TWinControl);
begin
 if AParent = nil then ExitProcess(0);
 InitCommonControls;

 inherited Create(AParent);
 FWidth := 185;
 FHeight := 17;
 FClassName := 'SysHeader32';
 FCaption := PChar(Text);
// FExStyle := WS_EX_CLIENTEDGE ;
 FStyle := WS_CHILD or WS_VISIBLE or HDS_BUTTONS;
 FColor := clBtnFace ;

 CreateWnd;
end;

function THeaderControl.SectionAdd(Text: String; Width: Integer): Integer;
begin
  Result := SectionInsert(SectionCount, Text, Width); 
end;

function THeaderControl.SectionCount: Integer;
begin
  Result := Perform(HDM_GETITEMCOUNT, 0, 0);
end;

function THeaderControl.SectionDelete(Index: Integer): Boolean;
begin
  Result := Bool(Perform(HDM_DELETEITEM, Index, 0));
end;

function THeaderControl.SectionInsert(Index: Integer; Text: String; Width: Integer): Integer;
var
  item: HD_ITEM;
begin
  item.Mask := HDI_TEXT or HDI_WIDTH or HDI_FORMAT;
  item.pszText := PChar(Text);
//  item.cchTextMax := 6;
  item.cxy := Width;
  item.fmt := HDF_Left  ;

  Result := Perform(HDM_INSERTITEM, Index, Longint(@Item));
end;

{ TAnimate }

constructor TAnimate.Create(AParent: TWinControl);
begin
 if AParent = nil then ExitProcess(0);
 InitCommonControls;

 inherited Create(AParent);
 FWidth := 185;
 FHeight := 17;
 FClassName := 'SysAnimate32';
 FCaption := PChar(Text);
// FExStyle := WS_EX_CLIENTEDGE ;
 FStyle := WS_CHILD or WS_VISIBLE;
 FColor := clBtnFace ;

 CreateWnd;
end;

function TAnimate.GetActualResHandle: THandle;
begin
  if FCommonAVI <> aviNone then
   Result := LoadLibrary('shell32.dll')
  else if FResHandle <> 0 then Result := FResHandle
  else if MainInstance <> 0 then Result := MainInstance
  else Result := HInstance;
end;

function TAnimate.GetActualResId: Integer;
const
  CommonAVIId: array[TCommonAVI] of Integer = (0, 150, 151, 152, 160, 161, 162,
    163, 164);
begin
  if FCommonAVI <> aviNone then Result := CommonAVIId[FCommonAVI]
  else if FFileName <> '' then Result := Integer(FFileName)
  else if FResName <> '' then Result := Integer(FResName)
  else Result := FResId;
end;

procedure TAnimate.GetFrameInfo;

(*  function CreateResStream: TStream;
  const
    ResType = 'AVI';
  var
    Instance: THandle;
  begin
    { AVI is from a file }
    if FFileName <> '' then
      Result := TFileStream.Create(FFileName, fmShareDenyNone)
    else
    begin
      { AVI is from a resource }
      Instance := GetActualResHandle;
      if FResName <> '' then
        Result := TResourceStream.Create(Instance, FResName, ResType)
      else
        Result := TResourceStream.CreateFromID(Instance, GetActualResId, ResType);
    end;
  end;    *)

{const
  CountOffset = 48;
  WidthOffset = 64;
  HeightOffset = 68;
  ResType = 'AVI';
var
  Instance: THandle;
  fs: TFileStream;
  res: TResourceStream;    }
begin
{  if FFileName <> '' then
   begin
//    fs := TFileStream.Create(FFileName, fmShareDenyNone);
   end
  else
   begin
    Instance := GetActualResHandle;
    if FResName <> '' then
      res := TResourceStream.Create(Instance, FResName, ResType)
    else
      res := TResourceStream.CreateFromID(Instance, GetActualResId, ResType);

    if res.Seek(CountOffset, soFromBeginning) = CountOffset then
      res.ReadBuffer(FFrameCount, SizeOf(FFrameCount));

   end;  }
  
{  with CreateResStream do
  try
    if Seek(CountOffset, soFromBeginning) = CountOffset then
      ReadBuffer(FFrameCount, SizeOf(FFrameCount));
    if Seek(WidthOffset, soFromBeginning) = WidthOffset then
      ReadBuffer(FFrameWidth, SizeOf(FFrameWidth));
    if Seek(HeightOffset, soFromBeginning) = HeightOffset then
      ReadBuffer(FFrameHeight, SizeOf(FFrameHeight));
  finally
    Free;
  end;   }
end;

procedure TAnimate.LoadCommonAVI(id: Integer);
//var
//  hInst: Integer;
begin
//  FCommonAVI := aviFindFolder ;
  FResName := IntToStr(id);

//  hInst := LoadLibrary('shell32.dll');

  Perform(ACM_OPEN, GetActualResHandle, GetActualResId);
end;

procedure TAnimate.Open;
begin
  if Perform(ACM_OPEN, GetActualResHandle, GetActualResId)>=1 then FOpen := True;
//  GetFrameInfo;
  FStartFrame := 1;
  FStopFrame := 100;
end;

function TAnimate.OpenFile(hInst: Integer; res: pChar): Boolean;
begin
  Result := Bool(Perform(ACM_OPEN, hInst, LPARAM(res)));
  GetFrameInfo;
end;

{procedure TAnimate.Play;
begin
  Open;
  Perform(ACM_PLAY, -1, MAKELONG(FStartFrame, FStopFrame));
end;  }

procedure TAnimate.Play(FromFrame, ToFrame: Word; Count: Integer);
begin
  Open;
  FActive := True;
  { ACM_PLAY excpects -1 for repeated animations }
  if Count = 0 then Count := -1;
  if Perform(ACM_PLAY, Count, MakeLong(FromFrame - 1, ToFrame - 1)) <> 1 then FActive := False;
end;

procedure TAnimate.Seek(Frame: Smallint);
begin
  Open;
  Perform(ACM_PLAY, 1, MakeLong(Frame - 1, Frame - 1));
end;

procedure TAnimate.SetCommonAVI(const Value: TCommonAVI);
begin
  FCommonAVI := Value;
  Open;
end;

procedure TAnimate.SetStartFrame(const Value: Smallint);
begin
  if FStartFrame <> Value then
   begin
    FStartFrame := Value;
    Stop;
    Seek(Value);
   end;
end;

procedure TAnimate.SetStopFrame(const Value: Smallint);
begin
  if FStopFrame <> Value then
  begin
    FStopFrame := Value;
    Stop;
  end;
end;

procedure TAnimate.Stop;
begin
  { Seek to first frame }
  Perform(ACM_PLAY, 1, MakeLong(FStartFrame - 1, FStartFrame - 1));
  FActive := False;
end;

function TTabControl.GetTabIndex: Integer;
begin
  Result := Perform(TCM_GETCURSEL, 0, 0);
end;

procedure TTabControl.SetTabIndex(const Value: Integer);
begin
  Perform(TCM_SETCURSEL, Value, 0);
end;

procedure TTabControl.SetTabStyle(const Value: TTabStyle);
begin
  FTabStyle := Value;
  if FTabStyle = tsTabs then
   begin
    SetStyle(FStyle or TCS_TABS);
    SetStyle(FStyle and not TCS_FLATBUTTONS and not TCS_BUTTONS);
   end;
  if FTabStyle = tsButtons then
   begin
    SetStyle(FStyle or TCS_BUTTONS);
    SetStyle(FStyle and not TCS_FLATBUTTONS and not TCS_TABS);
   end;
  if FTabStyle = tsFlatButtons then
   begin
    SetStyle(FStyle or TCS_BUTTONS or TCS_FLATBUTTONS);
    SetStyle(FStyle and not TCS_TABS);
   end; 
end;

procedure TTabControl.SetImages(const Value: TImageList);
begin
  FImages := Value;
  Perform(TCM_SETIMAGELIST, 0, Value.FHandle);
end;

{ TFontDialog }

(*constructor TFontDialog.Create;
begin
  FFont := TFont.Create ;
end;

function FontDialogHook(Wnd: HWnd; Msg: UINT; WParam: WPARAM; LParam: LPARAM): UINT; stdcall;
const
  IDCOLORCMB = $473;
var
  TMPLogFont:TLogFont;
  i:Integer;
begin
  Result:=0;
  case Msg of
    WM_INITDIALOG: FontDialogNow.Handle:=Wnd;

    WM_COMMAND:
    begin
      if (HiWord(wParam)=BN_CLICKED) and (LoWord(wParam)=IDAPPLYBTN) then
      begin

        SendMessage(Wnd, WM_CHOOSEFONT_GETLOGFONT, 0, LongInt(@TMPLogFont));
        //FontDialogNow.Font.LogFontStruct:=TMPLogFont;
        I := SendDlgItemMessage(Wnd, IDCOLORCMB, CB_GETCURSEL, 0, 0);

        if I <> CB_ERR then
          FontDialogNow.Font.Color:=SendDlgItemMessage(Wnd, IDCOLORCMB, CB_GETITEMDATA, I, 0);

//        if Assigned( FontDialogNow.FOnApply ) then
//          FontDialogNow.FOnApply( @MHFontDialogNow);
        Result:=1;
      end;
    end;
  end; //case
end;

function ChooseFont(var ChooseFont: TChooseFont): Bool; stdcall;external 'comdlg32.dll'  name 'ChooseFontA';

function TFontDialog.Execute: Boolean;
var
  TMPCF:TChooseFont;
  TMPLogFont:TLogFont;
//  i:Integer;
begin
  TMPCF.lStructSize := Sizeof(TMPCF);
  if assigned(Application) then
    TMPCF.hWndOwner:=Application.Handle
  else
    TMPCF.hWndOwner:=0;
    
  TMPCF.hInstance:=0;
  TMPCF.Flags:=CF_ENABLEHOOK;

//  TMPLogFont:=InitFont.LogFontStruct;
  TMPCF.lpLogFont:=@TMPLogFont;

  TMPCF.hDC:=0; // None Full Correct

  TMPCF.nSizeMin:=MinFontSize;
  TMPCF.nSizeMax:=MaxFontSize;

//  TMPCF.rgbColors:=InitFont.Color;
{    if UseInitFont then
      TMPCF.Flags:=TMPCF.Flags or CF_INITTOLOGFONTSTRUCT;
    if ShowEffects then
      TMPCF.Flags:=TMPCF.Flags or CF_EFFECTS;
    if UseMinMaxSize then
      TMPCF.Flags:=TMPCF.Flags or CF_LIMITSIZE;
    if Assigned(OnApply) then
      TMPCF.Flags:=TMPCF.Flags or CF_APPLY;
    if (fiiName in IgnoreInits) then
      TMPCF.Flags:=TMPCF.Flags or CF_NOFACESEL;
    if (fiiSize in IgnoreInits) then
      TMPCF.Flags:=TMPCF.Flags or CF_NOSIZESEL;
    if (fiiStyle in IgnoreInits) then
      TMPCF.Flags:=TMPCF.Flags or CF_NOSTYLESEL;
    if ForceFontExist then
      TMPCF.Flags:=TMPCF.Flags or CF_FORCEFONTEXIST;
    if Assigned(FOnHelp) then
      TMPCF.Flags:=TMPCF.Flags or CF_SHOWHELP;}
    case Device of
      fdBoth: TMPCF.Flags:=TMPCF.Flags or CF_BOTH;
      fdScreen: TMPCF.Flags:=TMPCF.Flags or CF_SCREENFONTS;
      fdPrinter: TMPCF.Flags:=TMPCF.Flags or CF_PRINTERFONTS;
    end;// case
    TMPCF.lpfnHook:=FontDialogHook;

//    LastMHFontDialog:=MHFontDialogNow;
    FontDialogNow:=@Self;

    Result:=ChooseFont(TMPCF);

    if Result then
    begin
//      FontDialogNow.Font.LogFontStruct:=TMPLogFont;
      FontDialogNow.Font.Color:=TMPCF.rgbColors;
    end;
//  FontDialogNow:=LastMHFontDialog;
//  LastMHFontDialog:=nil;
end;     *)

procedure TWinControl.SetBorderStyle(const Value: TBorderStyle);
begin
  FBorderStyle := Value;
  if Value=bsSingle then
   SetExStyle(FExStyle or WS_EX_CLIENTEDGE)
  else
   SetExStyle(FExStyle and not WS_EX_CLIENTEDGE);
end;


procedure TWinControl.WMSetCursor(var AMsg: TWMSetCursor);
begin
  if (FCursor <> crDefault) and (aMsg.HitTest  = HTCLIENT) then
   begin
    Windows.SetCursor({AMsg.CursorWnd}FCursor);
    AMsg.Result := 1;
   end
  else
   Dispatch(AMsg);
end;

procedure TWinControl.CanvasInit;
begin
  if FCanvas = nil then
  begin
    FCanvas := TCanvas.Create(FHandle);
    FCanvas.Pen := TPen.Create(FCanvas);
    FCanvas.Brush := TBrush.Create(FCanvas);
    if not Assigned(FFont) then
    begin
      FCanvas.Font := TFont.Create;
      FCanvas.Font.FCtrlHandle := FCanvas.Handle;
    end;
  end;
end;

procedure TTabControl.SetTabPosition(const Value: TTabPosition);
const
  TabPos: array[TTabPosition] of Integer = (0, TCS_BOTTOM, TCS_VERTICAL, TCS_VERTICAL or TCS_RIGHT);
begin
  if FTabPosition <> Value then
   begin
    SetStyle(FStyle and not TabPos[FTabPosition]);
    SetStyle(FStyle or TabPos[Value]);
    FTabPosition := Value;
   end; 
end;

{ TScrollBar }

procedure TScrollBar.CNHScroll(var Message: TWMHScroll);
begin
//  ShowMessage('1');
end;

procedure TScrollBar.CNVScroll(var Message: TWMVScroll);
begin
//  ShowMessage('2');
end;

constructor TScrollBar.Create(AParent: TWinControl; Horizontal: Boolean);
const
  O: array[Boolean] of Integer = (SBS_VERT, SBS_HORZ);
begin
 if AParent = nil then ExitProcess(0);

 inherited Create(AParent);
 FWidth := 121;
 FHeight := 16;
 FClassName := 'ScrollBar';
// FExStyle := WS_EX_CLIENTEDGE ;
 FStyle := WS_CHILD or WS_VISIBLE or O[Horizontal] {SBS_HORZ} or SBS_BOTTOMALIGN;
 FColor := clBtnFace ;

 CreateWnd;
end;

procedure TScrollBar.SetMax(const Value: Integer);
begin
  if FMax <> Value then
   begin
    FMax := Value;
    SetScrollRange(FHandle, SB_CTL, FMin, FMax, True);
   end; 
end;

procedure TScrollBar.SetMin(const Value: Integer);
begin
  if FMin <> Value then
   begin
    FMin := Value;
    SetScrollRange(FHandle, SB_CTL, FMin, FMax, True);
   end;
end;

procedure TScrollBar.SetSBPosition(const Value: Integer);
begin
  if FPosition <> Value then
   begin
    FPosition := Value;
    SetScrollPos(FHandle, SB_CTL, FPosition, True); 
   end;
end;

{ TFileListBox }

constructor TFileListBox.Create(AParent: TWinControl; Path: String);
begin
  inherited Create(AParent);
  if AParent = nil then ExitProcess(0);
  FWidth := 145;
  FHeight := 97;
  FClassName := 'ListBox';
  FExStyle := ws_Ex_ClientEdge;
  FStyle :=  WS_CHILD{ or lbs_Notify} or lbs_Sort or
            {lbs_NoIntegralHeight or} ws_Visible or WS_VSCROLL ;

  FColor := GetSysColor(COLOR_WINDOW)  ;
  CreateWnd;

  FDirectory := Path;
  FMask := '*.*';
  Update;
end;

procedure TFileListBox.SetDirectory(const Value: string);
begin
  if FDirectory <> Value then
   begin
    FDirectory := Value;
    Update;
   end; 
end;

procedure TFileListBox.SetMask(const Value: string);
begin
  if FMask <> Value then
   begin
    FMask := Value;
    Update;
   end; 
end;

procedure TFileListBox.Update;
var
  sr: TSearchRec;
begin
  Perform(LB_RESETCONTENT, 0, 0);
  FindFirst(FDirectory+FMask, faAnyFile, sr);
  repeat
   if (sr.Attr and faDirectory)<>faDirectory then
    Perform(LB_ADDSTRING, 0, Longint(PChar(sr.Name)));
  until FindNext(sr)<>0;
  FindClose(sr);
end;

{ TMemoryStream }

const
  MemoryDelta = $2000; { Must be a power of 2 }

procedure TMemoryStream.Clear;
begin
  SetCapacity(0);
  FSize := 0;
  FPosition := 0;
end;

destructor TMemoryStream.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TMemoryStream.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TMemoryStream.LoadFromStream(Stream: TStream);
var
  Count: Longint;
begin
  Stream.Position := 0;
  Count := Stream.Size;
  SetSize(Count);
  if Count <> 0 then Stream.ReadBuffer(FMemory^, Count);
end;

function TMemoryStream.Realloc(var NewCapacity: Integer): Pointer;
begin
  if NewCapacity > 0 then
    NewCapacity := (NewCapacity + (MemoryDelta - 1)) and not (MemoryDelta - 1);
  Result := Memory;
  if NewCapacity <> FCapacity then
  begin
    if NewCapacity = 0 then
    begin
      GlobalFreePtr(Memory);
      Result := nil;
    end else
    begin
      if Capacity = 0 then
        Result := GlobalAllocPtr(HeapAllocFlags, NewCapacity)
      else
        Result := GlobalReallocPtr(Memory, NewCapacity, HeapAllocFlags);
      //if Result = nil then raise EStreamError.CreateRes(@SMemoryStreamError);
    end;
  end;
end;

procedure TMemoryStream.SetCapacity(NewCapacity: Integer);
begin
  SetPointer(Realloc(NewCapacity), FSize);
  FCapacity := NewCapacity;
end;

procedure TMemoryStream.SetSize(NewSize: Integer);
var
  OldPosition: Longint;
begin
  OldPosition := FPosition;
  SetCapacity(NewSize);
  FSize := NewSize;
  if OldPosition > NewSize then Seek(0, soFromEnd);
end;

function TMemoryStream.Write(const Buffer; Count: Integer): Longint;
var
  Pos: Longint;
begin
  if (FPosition >= 0) and (Count >= 0) then
   begin
    Pos := FPosition + Count;
    if Pos > 0 then
    begin
      if Pos > FSize then
      begin
        if Pos > FCapacity then
          SetCapacity(Pos);
        FSize := Pos;
      end;
      System.Move(Buffer, Pointer(Longint(FMemory) + FPosition)^, Count);
      FPosition := Pos;
      Result := Count;
      Exit;
    end;
  end;
  Result := 0;
end;

procedure TWinControl.SetCtl3D(const Value: Boolean);
begin
  if FCtl3D <> Value then
   begin
    FCtl3D := Value;
    if FCtl3D then
     begin
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
      Style := Style and not WS_BORDER ;
     end
    else
     begin
      ExStyle := ExStyle and not WS_EX_CLIENTEDGE;
      Style := Style or WS_BORDER ;      
     end;
   end; 
end;

procedure TWinControl.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
  Invalidate; //!!!
end;

{function TWinControl.GetWCCanvas: TCanvas;
begin
  ShowMessage('ok');
end;

procedure TWinControl.SetWCCanvas(const Value: TCanvas);
begin
  if FCanvas = nil then
   begin
     CanvasInit ;
   end;
  FCanvas := Value;
end;}

{ TLabeledEdit }

constructor TLabeledEdit.Create(AParent: TWinControl; LabelCaption, Text: String);
begin
 if AParent = nil then ExitProcess(0);
 inherited Create(AParent, Text);

 FLabelEd := TLabel.Create(AParent, LabelCaption);
 FLabelEd.SetBounds(Left, Top-15, Width, 15);

 Top := 18;
end;

procedure TLabeledEdit.WMMove(var AMsg: TMessage);
begin
  FLabelEd.SetPosition(Left, Top-15);  
end;

procedure TWinControl.WMKeyDown(var AMsg: TWMKeyDown);
begin
  if Assigned(FOnKeyDown) then FOnKeyDown(Self, AMsg.CharCode, GetShiftState);
  Dispatch(AMsg);
end;

procedure TWinControl.WMKeyUp(var AMsg: TWMKeyUp);
begin
  if Assigned(FOnKeyUp) then FOnKeyUp(Self, AMsg.CharCode, GetShiftState);
  Dispatch(AMsg);
end;

procedure TWinControl.WMRButtonDown(var AMsg: TWMRButtonDown);
begin
  DoMouseDown(AMsg, mbRight, []);
end;

procedure TWinControl.WMMButtonDown(var AMsg: TWMMButtonDown);
begin
  DoMouseDown(AMsg, mbMiddle, []);
end;

procedure TWinControl.WMMouseMove(var AMsg: TWMMouseMove);
begin
  Dispatch(AMsg);
  if Assigned(FOnMouseMove) then FOnMouseMove(Self, KeysToShiftState(AMsg.Keys){[]}, AMsg.XPos, AMsg.YPos);
end;

procedure TWinControl.DoMouseDown(var AMsg: TWMMouse; Button: TMouseButton; Shift: TShiftState);
begin
  Dispatch(AMsg);
  with AMsg do
   if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, Button, KeysToShiftState(Keys) + Shift, XPos, YPos);
end;

procedure TWinControl.DoMouseUp(var AMsg: TWMMouse; Button: TMouseButton; Shift: TShiftState);
begin
  Dispatch(AMsg);
  with AMsg do
   if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, Button, KeysToShiftState(Keys) + Shift, XPos, YPos);
end;

function TWinControl.GetShiftState: TShiftState;
begin
  Result := [];
  if GetKeyState(VK_SHIFT) and $80 = $80 then Include(Result, ssShift);
  if GetKeyState(VK_CONTROL) and $80 = $80 then Include(Result, ssCtrl);
  if GetKeyState(VK_MENU) and $80 = $80 then Include(Result, ssAlt);
end;

procedure TWinControl.WMLButtonUp(var AMsg: TWMLButtonUp);
begin
  DoMouseUp(AMsg, mbLeft, []);
end;

procedure TWinControl.WMRButtonUp(var AMsg: TWMRButtonUp);
begin
  DoMouseUp(AMsg, mbRight, []);
end;

procedure TWinControl.WMMButtonUp(var AMsg: TWMMButtonUp);
begin
  DoMouseUp(AMsg, mbMiddle, []);
end;

{ TSpeedButton }

procedure TSpeedButton.Click;
begin
  inherited;
end;

constructor TSpeedButton.Create(AParent: TWinControl; Caption: String);
begin
 if AParent = nil then ExitProcess(0);
 inherited Create(AParent);
 FWidth := 25;
 FHeight := 25;
 FClassName := 'button';
 FCaption := PChar(Caption);
 FId := 5;
// FExStyle := WS_EX_CLIENTEDGE ;
 FStyle := WS_VISIBLE or WS_CHILD{ or BS_PUSHLIKE{ or WS_TABSTOP} ;
 FColor := clBtnFace ;
 CreateWnd;
end;

procedure TSpeedButton.SetGlyph(const Value: hBitmap);
begin
  if fGlyph <> Value then
   begin
    fGlyph := Value;
    if fGlyph = 0 then
     Style := Style and not BS_BITMAP
    else
     begin
      Style := Style or BS_BITMAP;
      Perform(BM_SETIMAGE, IMAGE_BITMAP, fGlyph);
     end; 
   end;
end;

{ Graphics }

var
  StockIcon: HICON;
//  BitmapImageLock: TRTLCriticalSection;  

const
  rc3_StockIcon = 0;
  rc3_Icon = 1;
  rc3_Cursor = 2;

type
  TCursorOrIcon = packed record
    Reserved: Word;
    wType: Word;
    Count: Word;
  end;

  TIconRec = packed record
    Width: Byte;
    Height: Byte;
    Colors: Word;
    Reserved1: Word;
    Reserved2: Word;
    DIBSize: Longint;
    DIBOffset: Longint;
  end;

type
  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array [Byte] of TRGBTriple;
  PRGBQuadArray = ^TRGBQuadArray;
  TRGBQuadArray = array [Byte] of TRGBQuad;

{ RGBTripleToQuad performs in-place conversion of an OS2 color
  table into a DIB color table.   }
procedure RGBTripleToQuad(var ColorTable);
var
  I: Integer;
  P3: PRGBTripleArray;
  P4: PRGBQuadArray;
begin
  P3 := PRGBTripleArray(@ColorTable);
  P4 := Pointer(P3);
  for I := 255 downto 1 do  // don't move zeroth item
    with P4^[I], P3^[I] do
    begin                     // order is significant for last item moved
      rgbRed := rgbtRed;
      rgbGreen := rgbtGreen;
      rgbBlue := rgbtBlue;
      rgbReserved := 0;
    end;
  P4^[0].rgbReserved := 0;
end;

function GetDInColors(BitCount: Word): Integer;
begin
  case BitCount of
    1, 4, 8: Result := 1 shl BitCount;
  else
    Result := 0;
  end;
end;

function BytesPerScanline(PixelsPerScanline, BitsPerPixel, Alignment: Longint): Longint;
begin
  Dec(Alignment);
  Result := ((PixelsPerScanline * BitsPerPixel) + Alignment) and not Alignment;
  Result := Result div 8;
end;

function DupBits(Src: HBITMAP; Size: TPoint; Mono: Boolean): HBITMAP;
var
  DC, Mem1, Mem2: HDC;
  Old1, Old2: HBITMAP;
  Bitmap: Windows.TBitmap;
begin
{X}Result := 0;
  Mem1 := CreateCompatibleDC(0);
  Mem2 := CreateCompatibleDC(0);

  try
    GetObject(Src, SizeOf(Bitmap), @Bitmap);
    if Mono then
      Result := CreateBitmap(Size.X, Size.Y, 1, 1, nil)
    else
    begin
      DC := GetDC(0);
{X}   if DC = 0 then Exit;// GDIError;
      try
        Result := CreateCompatibleBitmap(DC, Size.X, Size.Y);
{X}     if Result = 0 then Exit;//GDIError;
      finally
        ReleaseDC(0, DC);
      end;
    end;

    if Result <> 0 then
    begin
      Old1 := SelectObject(Mem1, Src);
      Old2 := SelectObject(Mem2, Result);

      StretchBlt(Mem2, 0, 0, Size.X, Size.Y, Mem1, 0, 0, Bitmap.bmWidth,
        Bitmap.bmHeight, SrcCopy);
      if Old1 <> 0 then SelectObject(Mem1, Old1);
      if Old2 <> 0 then SelectObject(Mem2, Old2);
    end;
  finally
    DeleteDC(Mem1);
    DeleteDC(Mem2);
  end;
end;

procedure TwoBitsFromDIB(var BI: TBitmapInfoHeader; var XorBits, AndBits: HBITMAP;
  const IconSize: TPoint);
type
  PLongArray = ^TLongArray;
  TLongArray = array[0..1] of Longint;
var
  Temp: HBITMAP;
  NumColors: Integer;
  DC: HDC;
  Bits: Pointer;
  Colors: PLongArray;
begin
  with BI do
  begin
    biHeight := biHeight shr 1; { Size in record is doubled }
    biSizeImage := BytesPerScanline(biWidth, biBitCount, 32) * biHeight;
    NumColors := GetDInColors(biBitCount);
  end;
  DC := GetDC(0);
{X}  if DC = 0 then Exit;//OutOfResources;
  try
    Bits := Pointer(Longint(@BI) + SizeOf(BI) + NumColors * SizeOf(TRGBQuad));
    Temp := {GDICheck(}CreateDIBitmap(DC, BI, CBM_INIT, Bits, PBitmapInfo(@BI)^, DIB_RGB_COLORS){)};
    try
      XorBits := DupBits(Temp, IconSize, False);
    finally
      DeleteObject(Temp);
    end;
    with BI do
    begin
      Inc(Longint(Bits), biSizeImage);
      biBitCount := 1;
      biSizeImage := BytesPerScanline(biWidth, biBitCount, 32) * biHeight;
      biClrUsed := 2;
      biClrImportant := 2;
    end;
    Colors := Pointer(Longint(@BI) + SizeOf(BI));
    Colors^[0] := 0;
    Colors^[1] := $FFFFFF;
    Temp := {GDICheck(}CreateDIBitmap(DC, BI, CBM_INIT, Bits, PBitmapInfo(@BI)^, DIB_RGB_COLORS){)};
    try
      AndBits := DupBits(Temp, IconSize, True);
    finally
      DeleteObject(Temp);
    end;
  finally
    ReleaseDC(0, DC);
  end;
end;

procedure InitializeBitmapInfoHeader(Bitmap: HBITMAP; var BI: TBitmapInfoHeader;
  Colors: Integer);
var
  DS: TDIBSection;
  Bytes: Integer;
begin
  DS.dsbmih.biSize := 0;
  Bytes := GetObject(Bitmap, SizeOf(DS), @DS);
{X}if Bytes = 0 then Exit//InvalidBitmap
  else if (Bytes >= (sizeof(DS.dsbm) + sizeof(DS.dsbmih))) and
    (DS.dsbmih.biSize >= DWORD(sizeof(DS.dsbmih))) then
    BI := DS.dsbmih
  else
  begin
    FillChar(BI, sizeof(BI), 0);
    with BI, DS.dsbm do
    begin
      biSize := SizeOf(BI);
      biWidth := bmWidth;
      biHeight := bmHeight;
    end;
  end;
  case Colors of
    2: BI.biBitCount := 1;
    3..16:
      begin
        BI.biBitCount := 4;
        BI.biClrUsed := Colors;
      end;
    17..256:
      begin
        BI.biBitCount := 8;
        BI.biClrUsed := Colors;
      end;
  else
    BI.biBitCount := DS.dsbm.bmBitsPixel * DS.dsbm.bmPlanes;
  end;
  BI.biPlanes := 1;
  if BI.biClrImportant > BI.biClrUsed then
    BI.biClrImportant := BI.biClrUsed;
  if BI.biSizeImage = 0 then
    BI.biSizeImage := BytesPerScanLine(BI.biWidth, BI.biBitCount, 32) * Abs(BI.biHeight);
end;

procedure InternalGetDIBSizes(Bitmap: HBITMAP; var InfoHeaderSize: DWORD;
  var ImageSize: DWORD; Colors: Integer);
var
  BI: TBitmapInfoHeader;
begin
  InitializeBitmapInfoHeader(Bitmap, BI, Colors);
  if BI.biBitCount > 8 then
  begin
    InfoHeaderSize := SizeOf(TBitmapInfoHeader);
    if (BI.biCompression and BI_BITFIELDS) <> 0 then
      Inc(InfoHeaderSize, 12);
  end
  else
    if BI.biClrUsed = 0 then
      InfoHeaderSize := SizeOf(TBitmapInfoHeader) +
        SizeOf(TRGBQuad) * (1 shl BI.biBitCount)
    else
      InfoHeaderSize := SizeOf(TBitmapInfoHeader) +
        SizeOf(TRGBQuad) * BI.biClrUsed;
  ImageSize := BI.biSizeImage;
end;

function InternalGetDIB(Bitmap: HBITMAP; Palette: HPALETTE;
  var BitmapInfo; var Bits; Colors: Integer): Boolean;
var
  OldPal: HPALETTE;
  DC: HDC;
begin
  InitializeBitmapInfoHeader(Bitmap, TBitmapInfoHeader(BitmapInfo), Colors);
  OldPal := 0;
  DC := CreateCompatibleDC(0);
  try
    if Palette <> 0 then
    begin
      OldPal := SelectPalette(DC, Palette, False);
      RealizePalette(DC);
    end;
    Result := GetDIBits(DC, Bitmap, 0, TBitmapInfoHeader(BitmapInfo).biHeight, @Bits,
      TBitmapInfo(BitmapInfo), DIB_RGB_COLORS) <> 0;
  finally
    if OldPal <> 0 then SelectPalette(DC, OldPal, False);
    DeleteDC(DC);
  end;
end;

procedure ReadIcon(Stream: TStream; var Icon: HICON; ImageCount: Integer;
  StartOffset: Integer; const RequestedSize: TPoint; var IconSize: TPoint);
type
  PIconRecArray = ^TIconRecArray;
  TIconRecArray = array[0..300] of TIconRec;
var
  List: PIconRecArray;
  HeaderLen, Length: Integer;
  BitsPerPixel: Word;
  Colors, BestColor, C1, N, Index: Integer;
  DC: HDC;
  BI: PBitmapInfoHeader;
  ResData: Pointer;
  XorBits, AndBits: HBITMAP;
  XorInfo, AndInfo: Windows.TBitmap;
  XorMem, AndMem: Pointer;
  XorLen, AndLen: Integer;
(*
var
  P: PChar;
begin
  P := Pointer(Integer((Stream as TCustomMemoryStream).Memory) + Stream.Position);
//  N := LookupIconIdFromDirectoryEx(Pointer(P), True, 0, 0, LR_DEFAULTCOLOR);
  Icon := GDICheck(CreateIconFromResourceEx(
    Pointer(P + PIconRec(P)^.DIBOffset - StartOffset),
    PIconRec(P)^.DIBSize, True, $00030000, 0, 0, LR_DEFAULTCOLOR));
end;
*)

  function AdjustColor(I: Integer): Integer;
  begin
    if I = 0 then
      Result := MaxInt
    else
      Result := I;
  end;

  function BetterSize(const Old, New: TIconRec): Boolean;
  var
    NewX, NewY, OldX, OldY: Integer;
  begin
    NewX := New.Width - IconSize.X;
    NewY := New.Height - IconSize.Y;
    OldX := Old.Width - IconSize.X;
    OldY := Old.Height - IconSize.Y;
    Result := (Abs(NewX) <= Abs(OldX)) and ((NewX <= 0) or (NewX <= OldX)) and
       (Abs(NewY) <= Abs(OldY)) and ((NewY <= 0) or (NewY <= OldY));
  end;

begin
  HeaderLen := SizeOf(TIconRec) * ImageCount;
  List := AllocMem(HeaderLen);
  try
    Stream.Read(List^, HeaderLen);
    if (RequestedSize.X or RequestedSize.Y) = 0 then
    begin
      IconSize.X := GetSystemMetrics(SM_CXICON);
      IconSize.Y := GetSystemMetrics(SM_CYICON);
    end
    else
      IconSize := RequestedSize;
    DC := GetDC(0);
{X} if DC = 0 then Exit; //OutOfResources;
    try
      BitsPerPixel := GetDeviceCaps(DC, PLANES) * GetDeviceCaps(DC, BITSPIXEL);
      if BitsPerPixel > 8 then
        Colors := MaxInt
      else
        Colors := 1 shl BitsPerPixel;
    finally
      ReleaseDC(0, DC);
    end;

    { Find the image that most closely matches (<=) the current screen color
      depth and the requested image size.  }
    Index := 0;
    BestColor := AdjustColor(List^[0].Colors);
    for N := 1 to ImageCount-1 do
    begin
      C1 := AdjustColor(List^[N].Colors);
      if (C1 <= Colors) and (C1 >= BestColor) and
        BetterSize(List^[Index], List^[N]) then
      begin
        Index := N;
        BestColor := C1;
      end;
    end;

    { the following code determines which image most closely matches the
      current device. It is not meant to absolutely match Windows
      (known broken) algorithm }
(*    C2 := 0;
    for N := 0 to ImageCount - 1 do
    begin
      C1 := List^[N].Colors;
      if C1 = Colors then
      begin
        Index := N;
        if (IconSize.X = List^[N].Width) and (IconSize.Y = List^[N].Height) then
          Break;  // exact match on size and color
      end
      else if Index = -1 then
      begin            // take the first icon with fewer colors than screen
        if C1 <= Colors then
        begin
          Index := N;
          C2 := C1;
        end;
      end
      else if C1 > C2 then  // take icon with more colors than first match
        Index := N;
    end;
    if Index = -1 then Index := 0;
*)
    with List^[Index] do
    begin
      IconSize.X := Width;
      IconSize.Y := Height;
      BI := AllocMem(DIBSize);
      try
        Stream.Seek(DIBOffset  - (HeaderLen + StartOffset), 1);
        Stream.Read(BI^, DIBSize);
        TwoBitsFromDIB(BI^, XorBits, AndBits, IconSize);
        GetObject(AndBits, SizeOf(Windows.TBitmap), @AndInfo);
        GetObject(XorBits, SizeOf(Windows.TBitmap), @XorInfo);
        with AndInfo do
          AndLen := bmWidthBytes * bmHeight * bmPlanes;
        with XorInfo do
          XorLen :=  bmWidthBytes * bmHeight * bmPlanes;
        Length := AndLen + XorLen;
        ResData := AllocMem(Length);
        try
          AndMem := ResData;
          with AndInfo do
            XorMem := Pointer(Longint(ResData) + AndLen);
          GetBitmapBits(AndBits, AndLen, AndMem);
          GetBitmapBits(XorBits, XorLen, XorMem);
          DeleteObject(XorBits);
          DeleteObject(AndBits);
          Icon := CreateIcon(HInstance, IconSize.X, IconSize.Y,
            XorInfo.bmPlanes, XorInfo.bmBitsPixel, AndMem, XorMem);
{X}       if Icon = 0 then Exit;//GDIError;
        finally
          FreeMem(ResData, Length);
        end;
      finally
        FreeMem(BI, DIBSize);
      end;
    end;
  finally
    FreeMem(List, HeaderLen);
  end;
end;

procedure WriteIcon(Stream: TStream; Icon: HICON; WriteLength: Boolean);
var
  IconInfo: TIconInfo;
  MonoInfoSize, ColorInfoSize: DWORD;
  MonoBitsSize, ColorBitsSize: DWORD;
  MonoInfo, MonoBits, ColorInfo, ColorBits: Pointer;
  CI: TCursorOrIcon;
  List: TIconRec;
  Length: Longint;
begin
  FillChar(CI, SizeOf(CI), 0);
  FillChar(List, SizeOf(List), 0);
  {CheckBool(}GetIconInfo(Icon, IconInfo){)};
  try
    InternalGetDIBSizes(IconInfo.hbmMask, MonoInfoSize, MonoBitsSize, 2);
    InternalGetDIBSizes(IconInfo.hbmColor, ColorInfoSize, ColorBitsSize, 16);
    MonoInfo := nil;
    MonoBits := nil;
    ColorInfo := nil;
    ColorBits := nil;
    try
      MonoInfo := AllocMem(MonoInfoSize);
      MonoBits := AllocMem(MonoBitsSize);
      ColorInfo := AllocMem(ColorInfoSize);
      ColorBits := AllocMem(ColorBitsSize);
      InternalGetDIB(IconInfo.hbmMask, 0, MonoInfo^, MonoBits^, 2);
      InternalGetDIB(IconInfo.hbmColor, 0, ColorInfo^, ColorBits^, 16);
      if WriteLength then
      begin
        Length := SizeOf(CI) + SizeOf(List) + ColorInfoSize +
          ColorBitsSize + MonoBitsSize;
        Stream.Write(Length, SizeOf(Length));
      end;
      with CI do
      begin
        CI.wType := RC3_ICON;
        CI.Count := 1;
      end;
      Stream.Write(CI, SizeOf(CI));
      with List, PBitmapInfoHeader(ColorInfo)^ do
      begin
        Width := biWidth;
        Height := biHeight;
        Colors := biPlanes * biBitCount;
        DIBSize := ColorInfoSize + ColorBitsSize + MonoBitsSize;
        DIBOffset := SizeOf(CI) + SizeOf(List);
      end;
      Stream.Write(List, SizeOf(List));
      with PBitmapInfoHeader(ColorInfo)^ do
        Inc(biHeight, biHeight); { color height includes mono bits }
      Stream.Write(ColorInfo^, ColorInfoSize);
      Stream.Write(ColorBits^, ColorBitsSize);
      Stream.Write(MonoBits^, MonoBitsSize);
    finally
      FreeMem(ColorInfo, ColorInfoSize);
      FreeMem(ColorBits, ColorBitsSize);
      FreeMem(MonoInfo, MonoInfoSize);
      FreeMem(MonoBits, MonoBitsSize);
    end;
  finally
    DeleteObject(IconInfo.hbmColor);
    DeleteObject(IconInfo.hbmMask);
  end;
end;

{ TIcon }

{procedure TIcon.Clear;
begin
  if fHandle <> 0 then
   begin
    DestroyIcon(FHandle); //Освобождаем память занятую иконкой
    FHandle := 0;
   end;
end;

procedure TIcon.Draw(DC: HDC; const Rect: TRect);
begin
  with Rect.TopLeft do  //Рисуем иконку
   DrawIconEx(DC, X, Y, FHandle, 0, 0, 0, 0, DI_NORMAL);
end; }

constructor TIcon.Create;
begin
//  FImage := TIconImage.Create;
end;

procedure TIcon.HandleNeeded;
var
  CI: TCursorOrIcon;
  NewHandle: HICON;
begin
//  with FImage do
//  begin
    if FHandle <> 0 then Exit;
    if FMemoryImage = nil then Exit;
    FMemoryImage.Position := 0;
    FMemoryImage.ReadBuffer(CI, SizeOf(CI));
    case CI.wType of
      RC3_STOCKICON: NewHandle := StockIcon;
      RC3_ICON: ReadIcon(FMemoryImage, NewHandle, CI.Count, SizeOf(CI),
        FRequestedSize, FSize);
    else
{X}    Exit;//InvalidIcon;
    end;
    FHandle := NewHandle;
//  end;
end;

procedure TIcon.ImageNeeded;
var
  Image: TMemoryStream;
  CI: TCursorOrIcon;
begin
//  with FImage do
//  begin
    if FMemoryImage <> nil then Exit;
{X} if FHandle = 0 then Exit;//InvalidIcon;
    Image := TMemoryStream.Create;
    try
      if GetHandle = StockIcon then
      begin
        FillChar(CI, SizeOf(CI), 0);
        Image.WriteBuffer(CI, SizeOf(CI));
      end
     else
        WriteIcon(Image, Handle, False);
    except
      Image.Free;
      raise;
    end;
    FMemoryImage := Image;
//  end;
end;

function TIcon.GetHandle: HICON;
begin
  HandleNeeded;
  Result := {FImage.}FHandle;
end;

procedure TIcon.SetHandle(const Value: HICON);
begin
  if Value <> FHandle then
   begin
    NewImage(Value, nil);
//    Changed(Self);
   end;
end;

procedure TIcon.NewImage(NewHandle: HICON; NewImage: TMemoryStream);
var
//  Image: TIconImage;
  NewImgHandle: hIcon;
  NewMemoryImage: TCustomMemoryStream;
begin
{  Image := TIconImage.Create;
  try
    Image.FHandle := NewHandle;
    Image.FMemoryImage := NewImage;
  except
    Image.Free;
    raise;
  end;
//  Image.Reference;
//  FImage.Release;
  FImage := Image; }

  try
    NewImgHandle := NewHandle;
    NewMemoryImage := NewImage;
  except
    raise;
  end;
  FHandle := NewImgHandle;
  FMemoryImage := NewMemoryImage;
end;

procedure TIcon.SaveToFile(const Filename: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(Filename, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TIcon.SaveToStream(Stream: TStream);
begin
  ImageNeeded;
  if {FImage.}FMemoryImage <> nil then
   with {FImage.}FMemoryImage do
    Stream.WriteBuffer(Memory^, Size);
end;  

procedure TIcon.LoadFromFile(const Filename: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TIcon.LoadFromStream(Stream: TStream);
var
  Image: TMemoryStream;
  CI: TCursorOrIcon;
begin
  Image := TMemoryStream.Create;
  try
    Image.SetSize(Stream.Size - Stream.Position);
    Stream.ReadBuffer(Image.Memory^, Image.Size);
    Image.ReadBuffer(CI, SizeOf(CI));
{X} if not (CI.wType in [RC3_STOCKICON, RC3_ICON]) then Exit;//InvalidIcon;
    NewImage(0, Image);
  except
    Image.Free;
    raise;
  end;
//  Changed(Self);
end;

{ TToolBar }

constructor TToolBar.Create(AParent: TWinControl; Flat: Boolean); //16.03.03
begin
  if AParent = nil then ExitProcess(0);
  InitCommonControls ;
  inherited Create(AParent);
  //FWidth := 25;
  //FHeight := 25;
  FClassName := 'ToolbarWindow32';

//  FExStyle := WS_EX_CLIENTEDGE ;
  FStyle := WS_VISIBLE or WS_CHILD {or TBSTYLE_LIST{ or TBSTYLE_FLAT};
  if Flat then FStyle := FStyle or TBSTYLE_FLAT else FStyle := FStyle or TBSTYLE_LIST;
  //FColor := clBtnFace ;
  CreateWnd;

  Perform(TB_BUTTONSTRUCTSIZE, SizeOf(TTBButton), 0);
end;

function TToolBar.ButtonCount: Integer; //16.03.03
begin
  Result := Perform(TB_BUTTONCOUNT, 0, 0);
end;

function TToolBar.ButtonAdd(Caption: String; ImageIndex: Integer): Integer; //17.03.03
var
  Item: TTBButton;
begin
  if Caption = '-' then
   begin
    Item.iBitmap := -1;
//    Item.idCommand := -1//FButtonCount;
    Item.fsState := 0;
    Item.fsStyle := TBSTYLE_SEP;
    Item.iString := -1;
    Result := -1;    
   end
  else
   begin
    Item.iBitmap := ImageIndex;
    Item.idCommand := FButtonCount;
    Item.fsState := TBSTATE_ENABLED;
    Item.fsStyle := TBSTYLE_BUTTON or TBSTYLE_AUTOSIZE;
    Item.iString := Perform(TB_ADDSTRING, 0, Integer(PChar(Caption + #0)));
    Result := FButtonCount;
    Inc(FButtonCount);
   end;       
  Perform(TB_ADDBUTTONS, 1, Integer(@Item));
//    Perform(TB_ADDBUTTONS, 1, Integer(@Item));
//    Perform(TB_AUTOSIZE,0,0 );
end;

procedure TToolBar.SetIndent(const Value: Integer); //16.03.03
begin
  if FIndent <> Value then
   begin
    FIndent := Value;
    Perform(TB_SETINDENT, Value, 0);
   end; 
end;

procedure TToolBar.SetImages(const Value: TImageList); //16.03.03
begin
  FImages := Value;
  Perform(TB_SETIMAGELIST, 0, Value.Handle);
end;

function TToolBar.ButtonCaption(Index: Integer): String; //16.03.03
var
  Buffer: array[0..1023] of Char;
begin
  Result := '';
  //BtnID := GetTBBtnGoodID( @Self, BtnID );
  if Perform(TB_GETBUTTONTEXT, Index, Integer(@Buffer[0])) <> 0 then Result := Buffer;
end;

procedure TToolBar.StandartImages(LargeImages: Boolean); //16.03.03
var
  AB: TTBAddBitmap;
begin
  AB.hInst := THandle(-1);
  if LargeImages then AB.nID := 1 else AB.nID :=  0;
  Perform(TB_ADDBITMAP, 0, Integer(@AB));
  Perform(WM_SIZE, 0, 0); //Устанавливаем новый размер ToolBar'a
end;

function TToolBar.GetButtonCheck(ButtonIndex: Integer): Boolean; //17.03.03
begin
  Result := Perform(TB_ISBUTTONCHECKED, ButtonIndex, 0) <> 0;
end;

procedure TToolBar.SetButtonCheck(ButtonIndex: Integer; const Value: Boolean); //17.03.03
begin
  Perform(TB_CHECKBUTTON, ButtonIndex, Integer(Value));
end;

function TToolBar.GetButtonImageIndex(ButtonIndex: Integer): Integer; //18.03.03
var
  B: TTBButton;
begin
  Perform(TB_GETBUTTON, ButtonIndex, Integer(@B));
  Result := B.iBitmap;
end;

procedure TToolBar.SetButtonImageIndex(ButtonIndex: Integer; //18.03.03
  const Value: Integer);
begin
  Perform(TB_CHANGEBITMAP, ButtonIndex, Value );
end;

function TToolBar.GetButtonPressed(ButtonIndex: Integer): Boolean;
begin
  Result:=Perform(TB_ISBUTTONPRESSED, ButtonIndex, 0)<>0;
end;

procedure TToolBar.SetButtonPressed(ButtonIndex: Integer; const Value: Boolean);
begin
  Perform(TB_PRESSBUTTON, ButtonIndex, Integer(Value));
end;

{ TBitmap }

function PrepareBitmapHeader(W, H, BitsPerPixel: Integer): PBitmapInfo;
begin
  Assert( W > 0, 'Width must be >0' );
  Assert( H > 0, 'Height must be >0' );

  Result := AllocMem( 256*Sizeof(TRGBQuad)+Sizeof(TBitmapInfoHeader) );
  Assert( Result <> nil, 'No memory' );

  Result.bmiHeader.biSize := Sizeof( TBitmapInfoHeader );
  Result.bmiHeader.biWidth := W;
  Result.bmiHeader.biHeight := H; // may be, -H ?
  Result.bmiHeader.biPlanes := 1;
  Result.bmiHeader.biBitCount := BitsPerPixel;
  //Result.bmiHeader.biCompression := BI_RGB; // BI_RGB = 0
end;

const InitColors: array[ 0..17 ] of DWORD = ( $F800, $7E0, $1F, 0, $800000, $8000,
      $808000, $80, $800080, $8080, $808080, $C0C0C0, $FF0000, $FF00, $FFFF00, $FF,
      $FF00FF, $FFFF );

procedure PreparePF16bit( DIBHeader: PBitmapInfo );
begin
  DIBHeader.bmiHeader.biCompression := BI_BITFIELDS;
  Move(InitColors[0], DIBHeader.bmiColors[0], 19*Sizeof(TRGBQUAD));
end;

function CalcScanLineSize( Header: PBitmapInfoHeader ): Integer;
begin
  //Result := ((Header.biBitCount * Header.biWidth + 31)
  //          shr 5) * 4;
  Result := ((Header.biBitCount * Header.biWidth + 31) shr 3) and $FFFFFFFC;
end;

procedure DummyDetachCanvas( Sender: TBitmap );
begin
end;

procedure ApplyBitmapBkColor2Canvas(Sender: TBitmap);
begin
  if Sender.FCanvas = nil then Exit;
  Sender.FCanvas.Brush.Color := Sender.BkColor;
end;

procedure DetachBitmapFromCanvas(Sender: TBitmap);
begin
  if Sender.FCanvasAttached = 0 then Exit;
{X - FHandle }  SelectObject(Sender.FCanvas.Handle, Sender.FCanvasAttached);
  Sender.FCanvasAttached := 0;
end;

procedure FillBmpWithBkColor(Bmp: TBitmap; DC2: HDC; oldWidth, oldHeight: Integer );
var oldBmp: HBitmap;
    R: TRect;
    Br: HBrush;
begin
  with Bmp do
  if ColorToRGB( fBkColor ) <> 0 then
  if (oldWidth < fWidth) or (oldHeight < fHeight) then
    if GetHandle <> 0 then
    begin
      oldBmp := SelectObject( DC2, fHandle );
      ASSERT( oldBmp <> 0, 'Can not select bitmap to DC' );
      Br := CreateSolidBrush( ColorToRGB( fBkColor ) );
      R := Rect( oldWidth, oldHeight, fWidth, fHeight );
      if oldWidth = fWidth then
         R.Left := 0;
      if oldHeight = fHeight then
         R.Top := 0;
      Windows.FillRect( DC2, R, Br );
      DeleteObject( Br );
      SelectObject( DC2, oldBmp );
    end;
end;

const
  BitsPerPixel_By_PixelFormat: array[ TPixelFormat ] of Byte =
                               ( 0, 1, 4, 8, 16, 16, 24, 32, 0 );

function Bits2PixelFormat( BitsPerPixel: Integer ): TPixelFormat;
var I: TPixelFormat;
begin
  for I := Low(I) to High(I) do
    if BitsPerPixel = BitsPerPixel_By_PixelFormat[ I ] then
    begin
      Result := I;
      Exit;
    end;
  Result := pfDevice;
end;

constructor TBitmap.Create;
begin
  FHandleType := bmDDB;
  FDetachCanvas := DummyDetachCanvas;
end;

constructor TBitmap.CreateNew(Width, Height: Integer);
var
  DC: HDC;
begin
  FHandleType := bmDDB;
  FDetachCanvas := DummyDetachCanvas;
  FWidth := Width;
  FHeight := Height;
  if (Width <> 0) and (Height <> 0) then
  begin
    DC := CreateCompatibleDC(0);
    FHandle := CreateCompatibleBitmap(DC, Width, Height);
    Assert(FHandle <> 0, 'Can not create bitmap handle');
    DeleteDC(DC );

    PixelFormat := pf32bit ;
    Canvas.Brush.Color := clWhite;
    Canvas.FillRect(Rect(0, 0, Width, Height));
  end;
end;

function TBitmap.GetEmpty: Boolean;
begin
  Result := (fWidth = 0) or (fHeight = 0);
  ASSERT( (fWidth >= 0) and (fHeight >= 0), 'Bitmap dimensions can be negative' );
end;

procedure TBitmap.SetHandleType(const Value: TBitmapHandleType);
begin
  if fHandleType = Value then Exit;
  fHandleType := Value;
  FormatChanged;
end;

procedure TBitmap.LoadFromFile(const Filename: String);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  LoadFromStream(Stream);
  Stream.Free;
end;

procedure TBitmap.SaveToFile(const FileName: String);
var
  Stream: TStream;
begin
  //if Empty then Exit;
  Stream := TFileStream.Create(FileName, fmCreate);
  SaveToStream(Stream);
  Stream.Free;
end;

procedure TBitmap.SaveToStream(Stream: TStream);
var
  BFH : TBitmapFileHeader;
  Pos : Integer;
  
   function WriteBitmap : Boolean;
   var ColorsSize, BitsSize, Size : Integer;
   begin
      Result := False;
      if Empty then Exit;
      HandleType := bmDIB; // convert to DIB if DDB
      FillChar( BFH, Sizeof( BFH ), 0 );
      ColorsSize := 0;
      with fDIBHeader.bmiHeader do
           if biBitCount <= 8 then
              ColorsSize := (1 shl biBitCount) * Sizeof( TRGBQuad )
           {else
           if biCompression <> 0 then
              ColorsSize := 12};
      BFH.bfOffBits := Sizeof( BFH ) + Sizeof( TBitmapInfoHeader ) + ColorsSize;
      BitsSize := fDIBSize; //ScanLineSize * fHeight;
      BFH.bfSize := BFH.bfOffBits + DWord( BitsSize );
      BFH.bfType := $4D42; // 'BM';
      if fDIBHeader.bmiHeader.biCompression <> 0 then
      begin
         ColorsSize := 12 + 16*sizeof(TRGBQuad);
         Inc( BFH.bfOffBits, ColorsSize );
      end;
      if Stream.Write( BFH, Sizeof( BFH ) ) <> Sizeof( BFH ) then Exit;
      Size := Sizeof( TBitmapInfoHeader ) + ColorsSize;
      if Stream.Write(fDIBHeader^, Size) <> {DWORD}Integer(Size) then Exit;
      if Stream.Write(fDIBBits^, BitsSize) <> Integer( BitsSize ) then Exit;
      Result := True;
   end;
begin
  Pos := Stream.Position;
  if not WriteBitmap then Stream.Seek(Pos, soFromBeginning);
end;

const
  BitCounts: array[ TPixelFormat ] of Byte = ( 0, 1, 4, 8, 16, 16, 24, 32, 0 );

procedure TBitmap.FormatChanged;
var B: tagBitmap;
    oldBmp, NewHandle: HBitmap;
    DC0, DC2: HDC;
    NewHeader: PBitmapInfo;
    NewBits: Pointer;
    oldHeight, oldWidth, sizeBits, bitsPixel: Integer;
    Br: HBrush;
    N: Integer;
    NewDIBAutoFree: Boolean;
    Hndl: THandle;
begin
  if Empty then Exit;
  NewDIBAutoFree := FALSE;
  fDetachCanvas(Self);
  fScanLineSize := 0;
  fGetDIBPixels := nil;
  fSetDIBPixels := nil;

    oldWidth := fWidth;
    oldHeight := fHeight;
    if fDIBBits <> nil then
    begin
      oldWidth := fDIBHeader.bmiHeader.biWidth;
      oldHeight := Abs(fDIBHeader.bmiHeader.biHeight);
    end
      else
    if fHandle <> 0 then
    begin
      if GetObject( fHandle, Sizeof( B ), @ B ) <> 0 then
      begin
        oldWidth := B.bmWidth;
        oldHeight := B.bmHeight;
      end;
    end;

  DC2 := CreateCompatibleDC( 0 );

  if fHandleType = bmDDB then
  begin
    // New HandleType is bmDDB: old bitmap can be copied using Draw method
    DC0 := GetDC( 0 );
    NewHandle := CreateCompatibleBitmap( DC0, fWidth, fHeight );
    ASSERT( NewHandle <> 0, 'Can not create DDB' );
    ReleaseDC( 0, DC0 );

    oldBmp := SelectObject( DC2, NewHandle );
    ASSERT( oldBmp <> 0, 'Can not select bitmap to DC' );

    Br := CreateSolidBrush( ColorToRGB( fBkColor ) );
    Windows.FillRect( DC2, Rect( 0, 0, fWidth, fHeight ), Br );
    DeleteObject( Br );

    if fDIBBits <> nil then
    begin
      SelectObject( DC2, oldBmp );
      SetDIBits( DC2, NewHandle, 0, fHeight, fDIBBits, fDIBHeader^, DIB_RGB_COLORS );
    end
       else
    begin
      Draw( DC2, 0, 0 );
      SelectObject( DC2, oldBmp );
    end;

    ClearData; // Image is cleared but fWidth and fHeight are preserved
    fHandle := NewHandle;
  end
     else
  begin
    // New format is DIB. GetDIBits applied to transform old data to new one.
    bitsPixel := BitCounts[ fNewPixelFormat ];
    if bitsPixel = 0 then
    begin
      //bitsPixel := BitCounts[DefaultPixelFormat];
      bitsPixel := BitCounts[pf16bit];
    end;

    NewHandle := 0;
    NewHeader := PrepareBitmapHeader( fWidth, fHeight, bitsPixel );
    if fNewPixelFormat = pf16bit then
      PreparePF16bit( NewHeader );

    sizeBits := CalcScanLineSize(@NewHeader.bmiHeader) * fHeight;

      GetMem( NewBits, sizeBits );
      ASSERT( NewBits <> nil, 'No memory' );

      Hndl := GetHandle;
      if Hndl = 0 then Exit;
      N :=
      GetDIBits( DC2, Hndl, 0, Min( fHeight, oldHeight ),
                 NewBits, NewHeader^, DIB_RGB_COLORS );
      //Assert( N = Min( fHeight, oldHeight ), 'Can not get all DIB bits' );
      if N <> Min( fHeight, oldHeight ) then
      begin
        FreeMem( NewBits );
        NewBits := nil;
        NewHandle := CreateDIBSection( DC2, NewHeader^, DIB_RGB_COLORS, NewBits, 0, 0 );
        NewDIBAutoFree := TRUE;
        ASSERT( NewHandle <> 0, 'Can not create DIB secion for pf16bit bitmap' );
        oldBmp := SelectObject( DC2, NewHandle );
        ASSERT( oldBmp <> 0, 'Can not select pf16bit to DC' );
        Draw( DC2, 0, 0 );
        SelectObject( DC2, oldBmp );
      end;

    ClearData;
    fDIBSize := sizeBits;
    fDIBBits := NewBits;
    fDIBHeader := NewHeader;
    fHandle := NewHandle;
    fDIBAutoFree := NewDIBAutoFree;

  end;

  if Assigned( fFillWithBkColor ) then
     fFillWithBkColor( Self, DC2, oldWidth, oldHeight );

  DeleteDC( DC2 );
end;

procedure TBitmap.Draw(DC: HDC; X, Y: Integer);
var
    DCfrom, DC0: HDC;
    oldBmp: HBitmap;
    oldHeight: Integer;
    B: tagBitmap;
label
    TRYAgain;
begin
TRYAgain:
  if Empty then Exit;
  if fHandle <> 0 then
  begin
    fDetachCanvas(Self );
    oldHeight := fHeight;
    if GetObject( fHandle, sizeof( B ), @B ) <> 0 then
       oldHeight := B.bmHeight;
    ASSERT( oldHeight > 0, 'oldHeight must be > 0' );

    DC0 := GetDC( 0 );
    DCfrom := CreateCompatibleDC( DC0 );
    ReleaseDC( 0, DC0 );

    oldBmp := SelectObject( DCfrom, fHandle );
    ASSERT( oldBmp <> 0, 'Can not select bitmap to DC' );

    BitBlt( DC, X, Y, fWidth, oldHeight, DCfrom, 0, 0, SRCCOPY );
    {$IFDEF CHK_BITBLT} Chk_BitBlt; {$ENDIF}

    SelectObject( DCfrom, oldBmp );
    DeleteDC( DCfrom );
  end
     else
  if fDIBBits <> nil then
  begin
    oldHeight := Abs(fDIBHeader.bmiHeader.biHeight);
    ASSERT( oldHeight > 0, 'oldHeight must be > 0' );
    ASSERT( fWidth > 0, 'Width must be > 0' );
    if StretchDIBits( DC, X, Y, fWidth, oldHeight, 0, 0, fWidth, oldHeight,
                   fDIBBits, fDIBHeader^, DIB_RGB_COLORS, SRCCOPY ) = 0 then
    begin
      if GetHandle <> 0 then
        goto TRYAgain;
    end;
  end;
end;

procedure TBitmap.ClearData;
begin
  fDetachCanvas(Self );
  if fHandle <> 0 then
  begin
    DeleteObject( fHandle );
    fHandle := 0;
    fDIBBits := nil;
    //fDIBHeader := nil;
  end;
  if fDIBBits <> nil then
  begin
    FreeMem( fDIBBits );
    fDIBBits := nil;
  end;
  if fDIBHeader <> nil then
  begin
    FreeMem( fDIBHeader );
    fDIBHeader := nil;
  end;
  fScanLineSize := 0;
  fGetDIBPixels := nil;
  fSetDIBPixels := nil;
  ClearTransImage;
end;

procedure TBitmap.ClearTransImage;
begin
  FTransColor := clNone;
  FTransMaskBmp.Free;
  FTransMaskBmp := nil;
end;

function TBitmap.GetHandle: HBitmap;
var OldBits: Pointer;
    DC0: HDC;
begin
  Result := 0;
  if Empty then Exit;
  if fHandle = 0 then
  begin
    if fDIBBits <> nil then
    begin
      OldBits := fDIBBits;
      DC0 := GetDC( 0 );

      fDIBBits := nil;
      //fDIBHeader.bmiHeader.biCompression := 0;
      fHandle := CreateDIBSection( DC0, fDIBHeader^, DIB_RGB_COLORS,
                    fDIBBits, 0, 0 );
      {$IFDEF DEBUG}
      if fHandle = 0 then
        ShowMessage( 'Can not create DIB section, error: ' + IntToStr( GetLastError ) +
        ', ' + SysErrorMessage( GetLastError ) );
      {$ELSE}
      ASSERT( fHandle <> 0, 'Can not create DIB section, error: ' + IntToStr( GetLastError ) +
      ', ' + SysErrorMessage( GetLastError ) );
      {$ENDIF}
      ReleaseDC( 0, DC0 );
      if fHandle <> 0 then
      begin
        Move( OldBits^, fDIBBits^, fDIBSize );
        if not fDIBAutoFree then
          FreeMem( OldBits );
        fDIBAutoFree := TRUE;

        fGetDIBPixels := nil;
        fSetDIBPixels := nil;
      end
        else
        fDIBBits := OldBits;
    end;
  end;
  Result := fHandle;
end;

procedure TBitmap.SetHeight(const Value: Integer);
begin
  if FHeight = Value then Exit;

  HandleType := bmDDB;
  // Not too good, but provides correct changing of height
  // preserving previous image

  FHeight := Value;
  FormatChanged;
end;

procedure TBitmap.SetWidth(const Value: Integer);
begin
  if FWidth = Value then Exit;
  FWidth := Value;
  FormatChanged;
end;

function TBitmap.GetCanvas: TCanvas;
var
  DC: HDC;
begin
  Result := nil;
  if Empty then Exit;
  if GetHandle = 0 then Exit;
  if fCanvas = nil then
  begin
    fApplyBkColor2Canvas := ApplyBitmapBkColor2Canvas;
    DC := CreateCompatibleDC( 0 );
    fCanvas := TCanvas.CreateFromDC(DC);  //NewCanvas( DC );
{X}    //fCanvas.fIsPaintDC := FALSE;
    fCanvas.OnChange := CanvasChanged;
    fCanvas.Brush.Color := FBkColor;
  end;
  Result := fCanvas;
  if fCanvasAttached = 0 then
  begin
    fCanvasAttached := SelectObject( fCanvas.Handle, fHandle );
    ASSERT( fCanvasAttached <> 0, 'Can not select bitmap to DC of Canvas' );
  end;
  fDetachCanvas := DetachBitmapFromCanvas;
end;

procedure TBitmap.SetBkColor(const Value: TColor);
begin
  if FBkColor = Value then Exit;
  FBkColor := Value;
  FFillWithBkColor := FillBmpWithBkColor;
  if Assigned(FApplyBkColor2Canvas) then
   FApplyBkColor2Canvas(Self);
end;

procedure TBitmap.CanvasChanged(Sender: TObject);
begin
  FBkColor := TCanvas(Sender).Brush.Color;
  ClearTransImage;
end;

procedure TBitmap.RemoveCanvas;
begin
  fDetachCanvas(Self);
  fCanvas.Free;
  fCanvas := nil;
end;

procedure TBitmap.Clear;
begin
  RemoveCanvas;
  ClearData;
  fWidth := 0;
  fHeight := 0;
  fDIBAutoFree := FALSE;
end;

procedure TBitmap.LoadFromStream(Stream: TStream);
type
  TColorsArray = array[ 0..15 ] of TColor;
  PColorsArray = ^TColorsArray;
  PColor = ^TColor;
var Pos : Integer;
    BFH : TBitmapFileHeader;

    function ReadBitmap : Boolean;
    var Size, Size1: Integer;
        BCH: TBitmapCoreHeader;
        RGBSize: DWORD;
        C: PColor;
        Off, HdSz, ColorCount: Integer;//DWORD;
    begin
      fHandleType := bmDIB;
      Result := False;
      if Stream.Read( BFH, Sizeof( BFH ) ) <> Sizeof( BFH ) then Exit;
      Off := 0; Size := 0;
      if BFH.bfType <> $4D42 then
         Stream.Seek( Pos, soFromBeginning)
      else
      begin
         Off := BFH.bfOffBits - Sizeof( BFH );
         Size := BFH.bfSize; // don't matter, just <> 0 is good
         //Size := Min( BFH.bfSize, Strm.Size - Strm.Position );
      end;
      RGBSize := 4;
      HdSz := Sizeof( TBitmapInfoHeader );
      fDIBHeader := AllocMem( 256*sizeof(TRGBQuad) + HdSz );
      if Stream.Read( fDIBHeader.bmiHeader.biSize, Sizeof( DWORD ) ) <> Sizeof( DWORD ) then
         Exit;
      if fDIBHeader.bmiHeader.biSize = HdSz then
      begin
        if Stream.Read(fDIBHeader.bmiHeader.biWidth, HdSz - Sizeof( DWORD ) ) <>
           HdSz - Sizeof(DWORD) then
           Exit;
      end
        else
      if fDIBHeader.bmiHeader.biSize = Sizeof( TBitmapCoreHeader ) then
      begin
        RGBSize := 3;
        HdSz := Sizeof( TBitmapCoreHeader );
        if Stream.Read( BCH.bcWidth, HdSz - Sizeof( DWORD ) ) <>
           HdSz - Sizeof( DWORD ) then
           Exit;
        fDIBHeader.bmiHeader.biSize := Sizeof( TBitmapInfoHeader );
        fDIBHeader.bmiHeader.biWidth := BCH.bcWidth;
        fDIBHeader.bmiHeader.biHeight := BCH.bcHeight;
        fDIBHeader.bmiHeader.biPlanes := BCH.bcPlanes;
        fDIBHeader.bmiHeader.biBitCount := BCH.bcBitCount;
      end
        else Exit;
      fNewPixelFormat := Bits2PixelFormat( fDIBHeader.bmiHeader.biBitCount
                         * fDIBHeader.bmiHeader.biPlanes );
      if (fNewPixelFormat = pf15bit) and (fDIBHeader.bmiHeader.biCompression <> BI_RGB) then
      begin
        ASSERT( fDIBHeader.bmiHeader.biCompression = BI_BITFIELDS, 'Unsupported bitmap format' );
        //fNewPixelFormat := pf16bit;
      end;
      fWidth := fDIBHeader.bmiHeader.biWidth;
      ASSERT( fWidth > 0, 'Bitmap width must be > 0' );
      fHeight := Abs(fDIBHeader.bmiHeader.biHeight);
      ASSERT( fHeight > 0, 'Bitmap height must be > 0' );

      fDIBSize := ScanLineSize * fHeight;
      fDIBBits := AllocMem( fDIBSize );
      ASSERT( fDIBBits <> nil, 'No memory' );

      ColorCount := 0;
      if fDIBHeader.bmiHeader.biBitCount <= 8 then
        ColorCount := (1 shl fDIBHeader.bmiHeader.biBitCount) * RGBSize
      else if fNewPixelFormat in [pf15bit,pf16bit] then
        ColorCount := 12;

      if Off > 0 then
      begin
         Off := Off - HdSz;
         if Off <> ColorCount then
         if not(fNewPixelFormat in [pf15bit,pf16bit]) then
            ColorCount := Off;
      end;
      if ColorCount <> 0 then
      begin
         if Off >= ColorCount then
           Off := Off - ColorCount;
         if RGBSize = 4 then
         begin
           if Stream.Read(fDIBheader.bmiColors[0], ColorCount)
              <> DWORD(ColorCount) then Exit;
         end
           else
         begin
           C := @ fDIBHeader.bmiColors[ 0 ];
           while ColorCount > 0 do
           begin
             if Stream.Read( C^, RGBSize ) <> RGBSize then Exit;
             Dec( ColorCount, RGBSize );
             Inc( C );
           end;
         end;
      end;
      if Off > 0 then
        Stream.Seek( Off, soFromCurrent);

      if Size = 0 then
         Size := fDIBSize //ScanLineSize * fHeight
      else
         Size := Min( {Size - Sizeof( TBitmapFileHeader ) - Sizeof( TBitmapInfoHeader )
              - ColorCount} fDIBSize, Stream.Size - Stream.Position );

      Size1 := Min( Size, fDIBSize );
      if Stream.Read( fDIBBits^, Size1 ) <> DWORD( Size1 ) then Exit;
      if Size > Size1 then
        Stream.Seek( Size - Size1, soFromCurrent);

      Result := True;
    end;
{var ColorsArray: PColorsArray;
    DC: HDC;
    Old: HBitmap;}
begin
  Clear;
  Pos := Stream.Position;
  if not ReadBitmap then
  begin
     Stream.Seek( Pos, soFromBeginning);
     Clear;
  end;
    {else
  begin
    if (fDIBBits <> nil) and (fDIBHeader.bmiHeader.biBitCount >= 4) then
    begin
        ColorsArray := @ fDIBHeader.bmiColors[ 0 ];
        if ColorsArray[ 7 ] = $C0C0C0 then
        if ColorsArray[ 8 ] = $808080 then
        if GetHandle <> 0 then
        begin
          DC := CreateCompatibleDC( 0 );
          Old := SelectObject( DC, fHandle );
          SetDIBColorTable( DC, 0, 16, fDIBHeader.bmiColors[ 0 ] );
          SelectObject( DC, Old );
          DeleteDC( DC );
        end;
    end;
  end;}
end;

function TBitmap.GetScanLineSize: Integer;
begin
  Result := 0;
  if fDIBHeader = nil then Exit;
  FScanLineSize := CalcScanLineSize(@fDIBHeader.bmiHeader );
  Result := FScanLineSize;
end;

function TBitmap.GetPixelFormat: TPixelFormat;
begin
  if (HandleType = bmDDB) or (fDIBBits = nil) then
    Result := pfDevice
  else
  begin
    Result := Bits2PixelFormat( fDIBHeader.bmiHeader.biBitCount );
    if (Result = pf15bit) and (fDIBHeader.bmiHeader.biCompression <> 0) then
    begin
      Assert( fDIBHeader.bmiHeader.biCompression = BI_BITFIELDS, 'Unsupported bitmap format' );
      Result := pf16bit;
    end;
  end;
end;

procedure TBitmap.SetPixelFormat(const Value: TPixelFormat);
begin
  if PixelFormat = Value then Exit;
  if Empty then Exit;
  if Value = pfDevice then
    HandleType := bmDDB
  else
  begin
    fNewPixelFormat := Value;
    //if Value = pf16bit then Value := pf15bit;
    HandleType := bmDIB;
    if Value <> Bits2PixelFormat( fDIBHeader.bmiHeader.biBitCount ) then
      FormatChanged;
  end;
end;

function TBitmap.Assign(Bitmap: TBitmap): Boolean;
begin
  Clear;
  Result := False;
  if Bitmap = nil then Exit;
  if Bitmap.Empty then Exit;
  fWidth := Bitmap.fWidth;
  fHeight := Bitmap.fHeight;
  fHandleType := Bitmap.fHandleType;
  if Bitmap.fHandleType = bmDDB then
  begin
    fHandle := CopyImage( Bitmap.fHandle, IMAGE_BITMAP, 0, 0, 0 {LR_COPYRETURNORG} );
    ASSERT( fHandle <> 0, 'Can not copy bitmap image' );
    Result := fHandle <> 0;
    if not Result then Clear;
  end
     else
  begin
    GetMem( fDIBHeader, Sizeof(TBitmapInfoHeader) + 256*sizeof(TRGBQuad) );
    ASSERT( fDIBHeader <> nil, 'No memory' );
    Move( Bitmap.fDIBHeader^, fDIBHeader^, Sizeof(TBitmapInfoHeader) + 256*sizeof(TRGBQuad) );
    fDIBSize := Bitmap.fDIBSize;
    GetMem( fDIBBits, fDIBSize );
    ASSERT( fDIBBits <> nil, 'No memory' );
    Move( Bitmap.fDIBBits^, fDIBBits^, fDIBSize );
    //fDIBAutoFree := TRUE;
    Result := True;
  end;
end;

function TBitmap.GetScanLine(Y: Integer): Pointer;
begin
  ASSERT( (Y >= 0) {and (Y < fHeight)}, 'ScanLine index out of bounds' );
  ASSERT( fDIBBits <> nil, 'No bits available' );
  Result := nil;
  if fDIBHeader = nil then Exit;

  if fDIBHeader.bmiHeader.biHeight > 0 then
     Y := fHeight - 1 - Y;
  if fScanLineSize = 0 then
     ScanLineSize;

  Result := Pointer( Integer( fDIBBits ) + fScanLineSize * Y );
end;

function TBitmap.GetDIBPalEntries(Idx: Integer): TColor;
begin
  Result := TColor(-1);
  if fDIBBits = nil then Exit;
  ASSERT( PixelFormat in [pf1bit..pf8bit], 'Format has no DIB palette entries available' );
  ASSERT( (Idx >= 0) and (Idx < (1 shl fDIBHeader.bmiHeader.biBitCount)),
          'DIB palette index out of bounds' );
  Result := PDWORD( Integer( @fDIBHeader.bmiColors[ 0 ] )
          + Idx * Sizeof( TRGBQuad ) )^;
end;

procedure TBitmap.SetDIBPalEntries(Idx: Integer; const Value: TColor);
begin
  if fDIBBits = nil then Exit;
  Dormant;
  PDWORD( Integer( @fDIBHeader.bmiColors[ 0 ] )
                    + Idx * Sizeof( TRGBQuad ) )^ := ColorToRGB( Value );
end;

procedure TBitmap.Dormant;
begin
  RemoveCanvas;
  if fHandle <> 0 then
    DeleteObject( ReleaseHandle );
end;

function TBitmap.ReleaseHandle: HBitmap;
var OldBits: Pointer;
begin
  HandleType := bmDIB;
  Result := GetHandle;
  if Result = 0 then Exit; // only when bitmap is empty
  if fDIBAutoFree then
  begin
    OldBits := fDIBBits;
    GetMem( fDIBBits, fDIBSize );
    Move( OldBits^, fDIBBits^, fDIBSize );
    fDIBAutoFree := FALSE;
  end;
  fHandle := 0;
end;

constructor TBitmap.CreateNewDIB(Width, Height: Integer; PixelFormat: TPixelFormat);
const BitsPerPixel: array[ TPixelFormat ] of Byte = ( 0, 1, 4, 8, 16, 16, 24, 32, 0 );
var BitsPixel: Integer;
    //AField: PDWORD;
    //DC0 : HDC;
begin
  fDetachCanvas := DummyDetachCanvas;
  fWidth := Width;
  fHeight := Height;
  if (Width <> 0) and (Height <> 0) then
  begin
    BitsPixel := BitsPerPixel[ PixelFormat ];
    if BitsPixel = 0 then
    begin
       //fNewPixelFormat := DefaultPixelFormat;
       //BitsPixel := BitsPerPixel[DefaultPixelFormat];
       fNewPixelFormat := pf16bit;
       BitsPixel := BitsPerPixel[pf16bit];
    end
       else
       fNewPixelFormat := PixelFormat;
    ASSERT( fNewPixelFormat in [ pf1bit..pf32bit ], 'Strange pixel format' );
    fDIBHeader := PrepareBitmapHeader( Width, Height, BitsPixel );
    if PixelFormat = pf16bit then
    begin
      PreparePF16bit( fDIBHeader );
      {
      Result.fDIBHeader.bmiHeader.biCompression := BI_BITFIELDS;
      AField := @Result.fDIBHeader.bmiColors[ 0 ];
      AField^ := $F800; Inc( AField );
      AField^ := $07E0; Inc( AField );
      AField^ := $001F; Inc( AField );
      DC0 := CreateCompatibleDC( 0 );
      GetSystemPaletteEntries( DC0, 0, 16, AField^ );
      DeleteDC( DC0 );
      }
    end;

    fDIBSize := ScanLineSize * Height;
    fDIBBits := AllocMem( fDIBSize );
    ASSERT( fDIBBits <> nil, 'No memory' );
  end;
end;

destructor TBitmap.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TBitmap.DrawStretch(DC: HDC; const Rect: TRect);
var DCfrom: HDC;
    oldBmp: HBitmap;
label DrawHandle;
begin
  if Empty then Exit;
DrawHandle:
  if fHandle <> 0 then
  begin
    fDetachCanvas(Self);
    DCfrom := CreateCompatibleDC( 0 );
    oldBmp := SelectObject( DCfrom, fHandle );
    ASSERT( oldBmp <> 0, 'Can not select bitmap to DC' );
    StretchBlt( DC, Rect.Left, Rect.Top, Rect.Right - Rect.Left,
                Rect.Bottom - Rect.Top, DCfrom, 0, 0, fWidth, fHeight,
                SRCCOPY );
    SelectObject( DCfrom, oldBmp );
    DeleteDC( DCfrom );
  end
     else
  if fDIBBits <> nil then
  begin
    if StretchDIBits( DC, Rect.Left, Rect.Top, Rect.Right - Rect.Left,
                Rect.Bottom - Rect.Top, 0, 0, fWidth, fHeight,
                fDIBBits, fDIBHeader^, DIB_RGB_COLORS, SRCCOPY )<=0 then
    begin
      if GetHandle <> 0 then
        goto DrawHandle;
    end;
  end;
end;

procedure TBitmap.SetHandle(const Value: HBitmap);
var
  B: tagBitmap;
begin
  Clear;
  if Value = 0 then Exit;
  if GetObject( Value, Sizeof( B ), @B ) = 0 then Exit;
  fHandle := Value;
  fWidth := B.bmWidth;
  fHeight := B.bmHeight;
  fHandleType := bmDDB;
end;

function TBitmap.GetDIBPalEntryCount: Integer;
begin
  Result := 0;
  if Empty then Exit;
  case PixelFormat of
  pf1bit: Result := 2;
  pf4bit: Result := 16;
  pf8bit: Result := 256;
  else;
  end;
end;

{ TGraphicControl }

constructor TGraphicControl.Create(AOwner: TWinControl);
begin
 if AOwner = nil then ExitProcess(0);
 inherited Create(AOwner);
// FWidth := 32;
// FHeight := 14;
 FClassName := 'static';
// FCaption := PChar(Caption);
// FExStyle :=WS_EX_TRANSPARENT ;
 FStyle := WS_CHILD or WS_VISIBLE;
// FColor := GetSysColor(COLOR_BTNFACE) ;
// FBkMode := bk_Transparent   ;

 CreateWnd;
end;

procedure TGraphicControl.Paint;
begin
end;
{
procedure TGraphicControl.WMNCPAINT(var Msg: TWMNcPaint);
begin
  Paint;
end;}

procedure TGraphicControl.WMPaint_(var Message: TWMPaint);
var
  PaintStruct: TPaintStruct;
//  DC: HDC;
begin
  if Message.DC = 0 then {DC:= }BeginPaint(FHandle, PaintStruct){ else DC := Message.DC} ;
  Paint;
  if Message.DC = 0 then EndPaint(FHandle, PaintStruct); 
end;

(*function TBitmap.GetScanLine(Y: Integer): Pointer;
begin
  ASSERT((Y >= 0) {and (Y < fHeight)}, 'ScanLine index out of bounds' );
  ASSERT(fDIBBits <> nil, 'No bits available' );
  Result := nil;
  if fDIBHeader.bmiHeader.biWidth   = 0 then Exit;

  if fDIBHeader.bmiHeader.biHeight > 0 then Y := fHeight - 1 - Y;
  if fScanLineSize = 0 then ScanLineSize;

  Result := Pointer( Integer( fDIBBits ) + fScanLineSize * Y );
end;

function TBitmap.GetDIBPalEntries(Index: Integer): TColor;
begin
  Result := TColor(-1);
  if fDIBBits = nil then Exit;
  ASSERT(PixelFormat in [pf1bit..pf8bit], 'Format has no DIB palette entries available' );
  ASSERT((Index >= 0) and (Index < (1 shl fDIBHeader.bmiHeader.biBitCount)),
          'DIB palette index out of bounds' );
  Result := PDWORD( Integer( @fDIBHeader.bmiColors[ 0 ] )
          + Index * Sizeof( TRGBQuad ) )^;
end;

procedure TBitmap.SetDIBPalEntries(Index: Integer; const Value: TColor);
begin
  if fDIBBits = nil then Exit;
  Dormant;
  PDWORD(Integer(@fDIBHeader.bmiColors[0])
                    + Index * Sizeof(TRGBQuad))^ := ColorToRGB(Value);
end;

function TBitmap.GetPixelFormat: TPixelFormat;
begin
  if (HandleType = bmDDB) or (fDIBBits = nil) then
    Result := pfDevice
  else
  begin
    Result := Bits2PixelFormat( fDIBHeader.bmiHeader.biBitCount );
    if (Result = pf15bit) and (fDIBHeader.bmiHeader.biCompression <> 0) then
    begin
      Assert( fDIBHeader.bmiHeader.biCompression = BI_BITFIELDS, 'Unsupported bitmap format' );
      Result := pf16bit;
    end;
  end;
end;

procedure TBitmap.SetPixelFormat(const Value: TPixelFormat);
begin
  if PixelFormat = Value then Exit;
  if Empty then Exit;
  if Value = pfDevice then
    HandleType := bmDDB
  else
  begin
    fNewPixelFormat := Value;
    //if Value = pf16bit then Value := pf15bit;
    HandleType := bmDIB;
    if Value <> Bits2PixelFormat( fDIBHeader.bmiHeader.biBitCount ) then
      FormatChanged;
  end;
end;

procedure TBitmap.Dormant;
begin
  RemoveCanvas;
  if fHandle <> 0 then DeleteObject({Release}GetHandle);
end;

function TBitmap.GetDIBPalEntryCount: Integer;
begin
  Result := 0;
  if Empty then Exit;
  case PixelFormat of
   pf1bit: Result := 2;
   pf4bit: Result := 16;
   pf8bit: Result := 256;
  end;
end;

procedure TBitmap.DrawStretch(DC: HDC; const Rect: TRect);
var DCfrom: HDC;
    oldBmp: HBitmap;
label DrawHandle;
begin
  if Empty then Exit;
DrawHandle:
  if fHandle <> 0 then
  begin
    fDetachCanvas( @Self );
    DCfrom := CreateCompatibleDC( 0 );
    oldBmp := SelectObject( DCfrom, fHandle );
    ASSERT( oldBmp <> 0, 'Can not select bitmap to DC' );
    StretchBlt( DC, Rect.Left, Rect.Top, Rect.Right - Rect.Left,
                Rect.Bottom - Rect.Top, DCfrom, 0, 0, fWidth, fHeight,
                SRCCOPY );
    SelectObject( DCfrom, oldBmp );
    DeleteDC( DCfrom );
  end
     else
  if fDIBBits <> nil then
  begin
    if StretchDIBits( DC, Rect.Left, Rect.Top, Rect.Right - Rect.Left,
                Rect.Bottom - Rect.Top, 0, 0, fWidth, fHeight,
                fDIBBits, fDIBHeader, DIB_RGB_COLORS, SRCCOPY )<=0 then
    begin
      if GetHandle <> 0 then
        goto DrawHandle;
    end;
  end;
end;

function TBitmap.Assign(SrcBmp: TBitmap): Boolean;
begin
  Clear;
  Result := False;
  if SrcBmp = nil then Exit;
  if SrcBmp.Empty then Exit;
  fWidth := SrcBmp.fWidth;
  fHeight := SrcBmp.fHeight;
  fHandleType := SrcBmp.fHandleType;
  if SrcBmp.fHandleType = bmDDB then
  begin
    fHandle := CopyImage( SrcBmp.fHandle, IMAGE_BITMAP, 0, 0, 0 {LR_COPYRETURNORG} );
    ASSERT( fHandle <> 0, 'Can not copy bitmap image' );
    Result := fHandle <> 0;
    if not Result then Clear;
  end
     else
  begin
    //GetMem( fDIBHeader, Sizeof(TBitmapInfoHeader) + 256*sizeof(TRGBQuad) );
    //ASSERT( fDIBHeader <> nil, 'No memory' );
    Move( SrcBmp.fDIBHeader, fDIBHeader, Sizeof(TBitmapInfoHeader) + 256*sizeof(TRGBQuad) );
    fDIBSize := SrcBmp.fDIBSize;
    GetMem( fDIBBits, fDIBSize );
    ASSERT( fDIBBits <> nil, 'No memory' );
    Move( SrcBmp.fDIBBits^, fDIBBits^, fDIBSize );
    //fDIBAutoFree := TRUE;
    Result := True;
  end;
end;  *)

{ TColorDialog }

constructor TColorDialog.Create(AParent: TForm);
begin
  if AParent <> nil then
   FHandle := AParent.Handle;

  FPreventFullOpen := True;
end;

function TColorDialog.Execute: Boolean;
begin
  Result := ColorDialog(FHandle, FFullOpen, FPreventFullOpen, FColors);
end;

function TColorDialog.GetCustomColors(ColorIndex: Integer): TColor;
begin
  Result := -1;
  if (ColorIndex > 0) and (ColorIndex < 17) then Result := FColors[ColorIndex];
end;

procedure TColorDialog.SetCustomColors(ColorIndex: Integer; const Value: TColor);
begin
  if (ColorIndex > 0) and (ColorIndex < 17) then FColors[ColorIndex] := Value;
end;

{ TPrintDialog }

constructor TPrintDialog.Create(Handle: THandle; Options: TPrintDialogOptions);
begin
  FillChar(ftagPD, Sizeof(tagPD),0);
  ftagPD.hWndOwner := Handle;
  ftagPD.hInstance := hInstance;
  fOptions := Options;
  fAlwaysReset := false;
  fAdvanced := 0;
end;

destructor TPrintDialog.Destroy;
begin
  Prepare;
  if (ftagPD.hDevMode <>0) then GlobalFree(ftagPD.hDevMode);
  if (ftagPD.hDevNames<>0) then GlobalFree(ftagPD.hDevNames);
end;

procedure TPrintDialog.Prepare;
begin
  if (ftagPD.hDevMode <> 0) and fAlwaysReset then
   begin
    GlobalFree(ftagPD.hDevMode);
    ftagPD.hDevMode :=0;
   end;
  if ftagPD.hDevNames <> 0 then
   begin
    GlobalUnlock(ftagPD.hDevNames);
    if fAlwaysReset then
     begin
      GlobalFree(ftagPD.hDevNames);
      ftagPD.hDevNames :=0;
     end;
   end;
  if ftagPD.hDC <> 0 then
   begin
    DeleteDC(ftagPD.hDC);
    ftagPD.hDC :=0;
   end;
end;

procedure TPrintDialog.FillOptions(DlgOptions : TPrintDialogOptions);
begin
  ftagPD.Flags := PD_ALLPAGES;
  { Return HDC if required}
  if pdReturnDC in DlgOptions then Inc(ftagPD.Flags,PD_RETURNDC);
  { Show printer setup dialog }
  if pdPrinterSetup in DlgOptions then Inc(ftagPD.Flags,PD_PRINTSETUP);
  { Process HELPMSGSTRING message. Note : AOwner control must register and
  process this message.}
  if pdHelp in DlgOptions then Inc(ftagPD.Flags, PD_SHOWHELP);
  { This flag indicates on return that printer driver does not support collation.
  You must eigther provide collation or set pdDeviceDepend (and user won't see
  collate checkbox if is not supported) }
  if pdCollate in DlgOptions then Inc(ftagPD.Flags,PD_COLLATE);
  { Disable some parts of PrintDlg window }
  if not (pdPrintToFile in DlgOptions) then Inc(ftagPD.Flags, PD_HIDEPRINTTOFILE);
  if not (pdPageNums in DlgOptions) then Inc(ftagPD.Flags, PD_NOPAGENUMS);
  if not (pdSelection in DlgOptions) then Inc(ftagPD.Flags, PD_NOSELECTION);
  { Disable warning if there is no default printer }
  if not (pdWarning in DlgOptions) then Inc(ftagPD.Flags, PD_NOWARNING);
  if pdDeviceDepend in DlgOptions then Inc(ftagPD.Flags,PD_USEDEVMODECOPIESANDCOLLATE);
  if FPrintToFile then Inc(ftagPD.Flags, PD_PRINTTOFILE);
end;

function TPrintDialog.GetError : Integer;
begin
  Result := CommDlgExtendedError();
end;

function TPrintDialog.Execute : Boolean;
var
  ExitCode : Boolean;
begin
  case fAdvanced of
   0 : //Not in advanced mode
     begin
      Prepare;
      FillOptions(fOptions);
     end;
   1:Prepare; //Advanced mode . User must assign properties and/or hook procedures
  end;
  ftagPD.lStructSize := sizeof(tagPD);
  ExitCode := PrintDlg(ftagPD);
  fDevNames := PDevNames(GlobalLock(ftagPD.hDevNames));

  if (ftagPD.Flags and PD_PRINTTOFILE) <> 0 then fOptions := fOptions + [pdPrintToFile] else fOptions := fOptions - [pdPrintToFile];
  if (ftagPD.Flags and PD_COLLATE) <> 0 then fOptions := fOptions + [pdCollate] else fOptions := fOptions - [pdCollate];
  if (ftagPD.Flags and PD_SELECTION) <> 0 then fOptions := fOptions + [pdSelection] else fOptions := fOptions - [pdSelection];
  if (ftagPD.Flags and PD_PAGENUMS) <> 0 then fOptions := fOptions + [pdPageNums] else fOptions := fOptions - [pdPageNums];
  Result := ExitCode;
end;

function TPrintDialog.Info : TPrinterInfo;
begin
  try
   FillChar(PrinterInfo,sizeof(PrinterInfo),0);
   with PrinterInfo do
    begin
     ADriver  := PChar(fDevNames) + fDevNames^.wDriverOffset;
     ADevice  := PChar(fDevNames) + fDevNames^.wDeviceOffset;
     APort    := PChar(fDevNames) + fDevNames^.wOutputOffset;
     ADevMode := ftagPD.hDevMode ;
    end;
  finally //support situation when fDevNames=0 (user pressed Cancel)
   Result := PrinterInfo;
  end;
end;

{ TPageSetupDialog }

constructor TPageSetupDialog.Create(Handle: THandle; Options: TPageSetupOptions);
begin
   FillChar(ftagPSD, sizeof(tagPSD),0);
   ftagPSD.hWndOwner := Handle;
   ftagPSD.hInstance := hInstance;
   fOptions := Options;
   fAdvanced :=0;
   fAlwaysReset := false;
   fhDC := 0;
end;

destructor TPageSetupDialog.Destroy;
begin
    Prepare;
    if (ftagPSD.hDevMode<>0) then  GlobalFree(ftagPSD.hDevMode);
    if (ftagPSD.hDevNames<>0) then GlobalFree(ftagPSD.hDevNames);
    inherited;
end;

procedure TPageSetupDialog.Prepare;
begin
    if ftagPSD.hDevMode <> 0 then
    begin
    GlobalUnlock(ftagPSD.hDevMode);
    if fAlwaysReset then
      begin
        GlobalFree(ftagPSD.hDevMode);
        ftagPSD.hDevMode :=0;
      end;
    end;
    if ftagPSD.hDevNames <> 0 then
    begin
    GlobalUnlock(ftagPSD.hDevNames);
    if fAlwaysReset then
      begin
        GlobalFree(ftagPSD.hDevNames);
        ftagPSD.hDevNames :=0;
      end;
    end;
    if fhDC <> 0 then
    	begin
    	DeleteDC(fhDC);
    	fhDC :=0;
    	end;
end;

procedure TPageSetupDialog.FillOptions(DlgOptions : TPageSetupOptions);
begin
  ftagPSD.Flags := PSD_DEFAULTMINMARGINS;
  { Disable some parts of PageSetup window }
  if not (psdMargins in DlgOptions) then Inc(ftagPSD.Flags, PSD_DISABLEMARGINS);
  if not (psdOrientation in DlgOptions) then Inc(ftagPSD.Flags, PSD_DISABLEORIENTATION);
  if not (psdSamplePage in DlgOptions) then Inc(ftagPSD.Flags, PSD_DISABLEPAGEPAINTING);
  if not (psdPaperControl in DlgOptions) then Inc(ftagPSD.Flags,PSD_DISABLEPAPER);
  if not (psdPrinterControl in DlgOptions) then inc(ftagPSD.Flags,PSD_DISABLEPRINTER);
  { Process HELPMSGSTRING message. Note : AOwner control must register and
  process this message.}
  if psdHelp in DlgOptions then Inc(ftagPSD.Flags, PSD_SHOWHELP);
  { Disable warning if there is no default printer }
  if not (psdWarning in DlgOptions) then Inc(ftagPSD.Flags, PSD_NOWARNING);
  if psdHundredthsOfMillimeters in DlgOptions then Inc(ftagPSD.Flags,PSD_INHUNDREDTHSOFMILLIMETERS);
  if psdThousandthsOfInches in DlgOptions then Inc(ftagPSD.Flags,PSD_INTHOUSANDTHSOFINCHES);
  if psdUseMargins in Dlgoptions then Inc(ftagPSD.Flags,PSD_MARGINS);
  if psdUseMinMargins in DlgOptions then Inc(ftagPSD.Flags,PSD_MINMARGINS);

end;

function TPageSetupDialog.GetError : Integer;
begin
    Result := CommDlgExtendedError();
end;

function TPageSetupDialog.Execute : Boolean;
var
  ExitCode : Boolean;
  Device, Driver, Output : PChar;
  fDevMode  : PDevMode;
begin
  case fAdvanced of
   0: //Not in advanced mode
    begin
     Prepare;
     FillOptions(fOptions);
    end;
   1: Prepare; //Advanced mode . User must assign properties and/or hook procedures
  end;         //If Advanced > 1 then You are expert ! (better use pure API ;-))
  ftagPSD.lStructSize := sizeof(tagPSD);
  ExitCode := PageSetupDlg(ftagPSD);
  fDevNames := PDevNames(GlobalLock(ftagPSD.hDevNames));
  fDevMode := PDevMode(GlobalLock(ftagPSD.hDevMode));
  if fDevNames <> nil then //support situation when user pressed cancel button
   begin
    Driver := PChar(fDevNames) + fDevNames^.wDriverOffset;
    Device := PChar(fDevNames) + fDevNames^.wDeviceOffset;
    Output := PChar(fDevNames) + fDevNames^.wOutputOffset;
    if psdReturnDC in fOptions then fhDC := CreateDC(Driver,Device,Output,fDevMode);
   end;
  Result := ExitCode;
end;

function TPageSetupDialog.Info: TPrinterInfo;
begin
  try
   FillChar(PrinterInfo, sizeof(PrinterInfo),0);
   with PrinterInfo do
    begin
     ADriver := PChar(fDevNames) + fDevNames^.wDriverOffset;
     ADevice := PChar(fDevNames) + fDevNames^.wDeviceOffset;
     APort := PChar(fDevNames) + fDevNames^.wOutputOffset;
     ADevMode := ftagPSD.hDevMode;
    end;
  finally 
   Result := PrinterInfo;
  end;
end; 

function TPageSetupDialog.GetPaperSize :  TPoint;
begin
  Result := ftagPSD.ptPaperSize;
end;

procedure TPageSetupDialog.SetMinMargins(Left,Top,Right,Bottom: Integer);
begin
  ftagPSD.rtMinMargin.Left := Left;
  ftagPSD.rtMinMargin.Top := Top;
  ftagPSD.rtMinMargin.Right := Right;
  ftagPSD.rtMinMargin.Bottom := Bottom;
end;

function TPageSetupDialog.GetMinMargins : TRect;
begin
  Result := ftagPSD.rtMinMargin;
end;

procedure TPageSetupDialog.SetMargins(Left,Top,Right,Bottom : Integer);
begin
  ftagPSD.rtMargin.Left := Left;
  ftagPSD.rtMargin.Top := Top;
  ftagPSD.rtMargin.Right := Right;
  ftagPSD.rtMargin.Bottom := Bottom;
end;

function TPageSetupDialog.GetMargins : TRect;
begin
  Result := ftagPSD.rtMargin;
end;

{procedure TBitmap.SetHandle(const Value: HBitmap);
var
  B: tagBitmap;
begin
  Clear;
  if Value = 0 then Exit;
  if GetObject(Value, SizeOf(B), @B) = 0 then Exit;
  fHandle := Value;
  fWidth := B.bmWidth;
  fHeight := B.bmHeight;
  fHandleType := bmDDB;
end;

constructor TBitmap.CreateNew(Width, Height: Integer);
var
  DC: HDC;
begin
  fHandleType := bmDDB;
  fDetachCanvas := DummyDetachCanvas;
  fWidth := Width;
  fHeight := Height;
  if (Width <> 0) and (Height <> 0) then
   begin
    DC := CreateCompatibleDC( 0 );
    fHandle := CreateCompatibleBitmap( DC, Width, Height );
    Assert( fHandle <> 0, 'Can not create bitmap handle' );
    DeleteDC( DC );
   end;
end;  }
         


{ TMDIForm }

constructor TMDIForm.Create(Parent: TWinControl; Caption: String);
var
  ClientStruct: TClientCreateStruct ;
begin
  inherited ;
  SetSize(600, 450) ;
  
  ClientStruct.hWindowMenu := 0;
  ClientStruct.idFirstChild := 100;
  FClientHandle := CreateWindowEx(0, 'MDICLIENT', '', WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN,CW_USEDEFAULT,
          CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,Handle, 0, hInstance, @ClientStruct);
end;

procedure TMDIForm.Dispatch(var AMsg);
begin
// inherited Dispatch(AMsg); //!!!
 with TMessage(AMsg) do
  begin
   if TMessage(AMsg).Result <> 0 then Exit;
   if FDefWndProc <> 0 then
    Result := CallWindowProc(Ptr(FDefWndProc), FHandle, Msg, WParam, LParam)
   else
    Result := DefFrameProc(FHandle, FClientHandle, Msg, wParam, lParam);
  end;
end;

{ TMDIChildForm }

function ChildProc(hChild:DWORD;uMsg:DWORD;wParam:DWORD;lParam:DWORD):Longint; stdcall;
begin
{  if uMsg = WM_CLOSE then
   begin
    if MessageBox(hChild, 'Are you sure you want to close this window?', 'Question', MB_YESNO) = IDYES then
             SendMessage(cli , WM_MDIDESTROY, hChild, 0);
   end
  else} Result := DefMDIChildProc(hChild,uMsg,wParam,lParam);
end;

constructor TMDIChildForm.Create(Parent: TMDIForm; Caption: String);
//var
//  mdicreate: TMDICreateStruct ;
begin
  TWinControl(Self).Create(Parent);
  FCaption := PChar(Caption);

  FClassName := 'TMDIChild';
  FParent := Parent;
  FParentHandle := 0;
  FLeft := 200;//cw_UseDefault;
  FTop := 100;//cw_UseDefault;
  FWidth := 300;//cw_UseDefault;
  FHeight := 250;//cw_UseDefault;
  FId := 1;
  FVisible := True;
  FColor := clBtnFace ;
  FBorderStyle := bsSizeable;
  FAlphaBlend := False;
  FAlphaBlendValue := 255;
  FTransparentColor := False;
  FTransparentColorValue := clBlack;

// CreateWindow ;
 with wClass do
  begin
//   Style:=CS_PARENTDC;
//   hIcon:=LoadIcon(hInstance,'MAINICON');
//   lpfnWndProc := GetWndProc;
   hInstance := hInstance;
   hbrBackground := COLOR_BTNFACE+1;
   lpszClassName := PChar(FClassName);
   hCursor := LoadCursor(0, IDC_ARROW);
   lpfnWndProc := @ChildProc;
  end;
  RegisterClass(wClass);
(*  FHandle:=CreateWindowEx(0, PChar(FClassName),PChar(FCaption), WS_THICKFRAME or
         WS_SYSMENU  or WS_MINIMIZEBOX or WS_MAXIMIZEBOX, FLeft,
                    FTop, FWidth, FHeight, GetParentHandle, 0, hInstance, nil);
  SetProp(FHandle, App_Id, THandle(Self));

{$ifdef CanvasAutoCreate}
  FCanvas := TCanvas.Create(FHandle);
  FCanvas.FPen := TPen.Create(FCanvas);
  FCanvas.FBrush := TBrush.Create(FCanvas);
{$endif}

//Ставим иконку
  FIcon := LoadIcon(Hinstance, 'MAINICON');
  Perform(WM_SETICON, ICON_BIG, FIcon);
//Параметры Show
//  if Application = nil then
  if Parent = nil then
   MsgDefHandle := FHandle;    *)

{  mdicreate.szClass := PChar(FClassName) ;
  mdicreate.szTitle := FCaption ;
  mdicreate.hOwner := hInstance ;
  mdicreate.x := 50 ;
  mdicreate.y := 50 ;
  mdicreate.cx := 300 ;
  mdicreate.cy := 250;
  SendMessage(Parent.FClientHandle, WM_MDICREATE, 0, Integer(@mdicreate)); }
  FHandle := CreateMDIWindow(PChar(FClassName), FCaption, 0, 50, 50, 300, 250, Parent.FClientHandle, hInstance, 0); 
end;

{ TComponent }

constructor TComponent.Create(AOwner: TComponent);
begin

end;

initialization
  ErrorProc:=ErrorHandler;
  ExceptProc:=@ExceptHandler;
  ExceptionClass:=Exception;
  ExceptClsProc:=@GetExceptionClass;
  ExceptObjProc:=@GetExceptionObject;
  AssertErrorProc:=@AssertErrorHandler;

end.



