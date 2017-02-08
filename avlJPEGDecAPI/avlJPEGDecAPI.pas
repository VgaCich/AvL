unit avlJPEGDecAPI;

interface

uses
  Windows, AvL{, avlUtils};

const
  JPEG_SUSPENDED              = 0; { Suspended due to lack of input data }
  JPEG_HEADER_OK              = 1; { Found valid image datastream }
  JPEG_HEADER_TABLES_ONLY     = 2; { Found valid table-specs-only datastream }
{ If you pass require_image = TRUE (normal case), you need not check for
  a TABLES_ONLY return code; an abbreviated file will cause an error exit.
  JPEG_SUSPENDED is only possible if you use a data source module that can
  give a suspension return (the stdio source module doesn't). }


{ function jpeg_consume_input (cinfo : j_decompress_ptr) : Integer;
  Return value is one of: }

  JPEG_REACHED_SOS            = 1; { Reached start of new scan }
  JPEG_REACHED_EOI            = 2; { Reached end of image }
  JPEG_ROW_COMPLETED          = 3; { Completed one iMCU row }
  JPEG_SCAN_COMPLETED         = 4; { Completed last iMCU row of a scan }


  CSTATE_START        = 100;    { after create_compress }
  CSTATE_SCANNING     = 101;    { start_compress done, write_scanlines OK }
  CSTATE_RAW_OK       = 102;    { start_compress done, write_raw_data OK }
  CSTATE_WRCOEFS      = 103;    { jpeg_write_coefficients done }

  JPEG_LIB_VERSION = 61;        { Version 6a }

  JPEG_RST0     = $D0;  { RST0 marker code }
  JPEG_EOI      = $D9;  { EOI marker code }
  JPEG_APP0     = $E0;  { APP0 marker code }
  JPEG_COM      = $FE;  { COM marker code }

  DCTSIZE             = 8;      { The basic DCT block is 8x8 samples }
  DCTSIZE2            = 64;     { DCTSIZE squared; # of elements in a block }
  NUM_QUANT_TBLS      = 4;      { Quantization tables are numbered 0..3 }
  NUM_HUFF_TBLS       = 4;      { Huffman tables are numbered 0..3 }
  NUM_ARITH_TBLS      = 16;     { Arith-coding tables are numbered 0..15 }
  MAX_COMPS_IN_SCAN   = 4;      { JPEG limit on # of components in one scan }
  MAX_SAMP_FACTOR     = 4;      { JPEG limit on sampling factors }
  C_MAX_BLOCKS_IN_MCU = 10;     { compressor's limit on blocks per MCU }
  D_MAX_BLOCKS_IN_MCU = 10;     { decompressor's limit on blocks per MCU }
  MAX_COMPONENTS = 10;          { maximum number of image components (color channels) }

  MAXJSAMPLE = 255;
  CENTERJSAMPLE = 128;

  DSTATE_START        = 200;    { after create_decompress }
  DSTATE_INHEADER     = 201;    { reading header markers, no SOS yet }
  DSTATE_READY        = 202;    { found SOS, ready for start_decompress }
  DSTATE_PRELOAD      = 203;    { reading multiscan file in start_decompress}
  DSTATE_PRESCAN      = 204;    { performing dummy pass for 2-pass quant }
  DSTATE_SCANNING     = 205;    { start_decompress done, read_scanlines OK }
  DSTATE_RAW_OK       = 206;    { start_decompress done, read_raw_data OK }
  DSTATE_BUFIMAGE     = 207;    { expecting jpeg_start_output }
  DSTATE_BUFPOST      = 208;    { looking for SOS/EOI in jpeg_finish_output }
  DSTATE_RDCOEFS      = 209;    { reading file in jpeg_read_coefficients }
  DSTATE_STOPPING     = 210;    { looking for EOI in jpeg_finish_decompress }

{ Error handler }
  JMSG_LENGTH_MAX  = 200;  { recommended size of format_message buffer }
  JMSG_STR_PARM_MAX = 80;

  JPOOL_PERMANENT = 0;  // lasts until master record is destroyed
  JPOOL_IMAGE	    = 1;	 // lasts until done with image/datastream

type
  JSAMPLE = byte;
  GETJSAMPLE = integer;
  JCOEF = integer;
  JCOEF_PTR = ^JCOEF;
  UINT8 = byte;
  UINT16 = Word;
  UINT32 = Cardinal;
  INT16 = SmallInt;
  INT32 = Integer;
  INT32PTR = ^INT32;
  JDIMENSION = Cardinal;

  JOCTET = Byte;
  jTOctet = 0..(MaxInt div SizeOf(JOCTET))-1;
  JOCTET_FIELD = array[jTOctet] of JOCTET;
  JOCTET_FIELD_PTR = ^JOCTET_FIELD;
  JOCTETPTR = ^JOCTET;

  JSAMPLE_PTR = ^JSAMPLE;
  JSAMPROW_PTR = ^JSAMPROW;

  jTSample = 0..(MaxInt div SIZEOF(JSAMPLE))-1;
  JSAMPLE_ARRAY = Array[jTSample] of JSAMPLE;  {far}
  JSAMPROW = ^JSAMPLE_ARRAY;  { ptr to one image row of pixel samples. }

  jTRow = 0..(MaxInt div SIZEOF(JSAMPROW))-1;
  JSAMPROW_ARRAY = Array[jTRow] of JSAMPROW;
  JSAMPARRAY = ^JSAMPROW_ARRAY;  { ptr to some rows (a 2-D sample array) }

  jTArray = 0..(MaxInt div SIZEOF(JSAMPARRAY))-1;
  JSAMP_ARRAY = Array[jTArray] of JSAMPARRAY;
  JSAMPIMAGE = ^JSAMP_ARRAY;  { a 3-D sample array: top index is color }

{ Known color spaces. }

  J_COLOR_SPACE = (
	JCS_UNKNOWN,            { error/unspecified }
	JCS_GRAYSCALE,          { monochrome }
	JCS_RGB,                { red/green/blue }
	JCS_YCbCr,              { Y/Cb/Cr (also known as YUV) }
	JCS_CMYK,               { C/M/Y/K }
	JCS_YCCK                { Y/Cb/Cr/K }
                  );

{ DCT/IDCT algorithm options. }
  J_DCT_METHOD = (
	JDCT_ISLOW,		{ slow but accurate integer algorithm }
	JDCT_IFAST,		{ faster, less accurate integer method }
	JDCT_FLOAT		{ floating-point: accurate, fast on fast HW (Pentium)}
                 );

{ Dithering options for decompression. }
  J_DITHER_MODE = (
    JDITHER_NONE,               { no dithering }
    JDITHER_ORDERED,            { simple ordered dither }
    JDITHER_FS                  { Floyd-Steinberg error diffusion dither }
                  );

  // DCT coefficient quantization tables.

  JQUANT_TBL_ptr = ^JQUANT_TBL;
  JQUANT_TBL = record
    // This array gives the coefficient quantizers in natural array order
    // (not the zigzag order in which they are stored in a JPEG DQT marker).
    // CAUTION: IJG versions prior to v6a kept this array in zigzag order.
    quantval: array[0..DCTSIZE2 - 1] of Word; // quantization step for each coefficient 
    // This field is used only during compression.  It's initialized FALSE when
    // the table is created, and set TRUE when it's been output to the file.
    // You could suppress output of a table by setting this to TRUE.
    // (See jpeg_suppress_tables for an example.)
    sent_table: LongBool; // TRUE when table has been output 
  end;

  // Basic info about one component (color channel).
  jpeg_component_info_ptr = ^jpeg_component_info; 
  jpeg_component_info = record
    // These values are fixed over the whole image.
    // For compression, they must be supplied by parameter setup;
    // for decompression, they are read from the SOF marker.
    component_id,          // identifier for this component (0..255)
    component_index,       // its index in SOF or cinfo->comp_info[]
    h_samp_factor,         // horizontal sampling factor (1..4) */
    v_samp_factor,         // vertical sampling factor (1..4) */
    quant_tbl_no: Integer; // quantization table selector (0..3) */
    // These values may vary between scans.
    // For compression, they must be supplied by parameter setup;
    // for decompression, they are read from the SOS marker.
    // The decompressor output side may not use these variables.
    dc_tbl_no,             // DC entropy table selector (0..3)
    ac_tbl_no: Integer;    // AC entropy table selector (0..3)
    
    // Remaining fields should be treated as private by applications.

    // These values are computed during compression or decompression startup:
    // Component's size in DCT blocks.
    // Any dummy blocks added to complete an MCU are not counted; therefore
    // these values do not depend on whether a scan is interleaved or not.
    width_in_blocks,
    height_in_blocks: JDIMENSION;
    // Size of a DCT block in samples.  Always DCTSIZE for compression.
    // For decompression this is the size of the output from one DCT block,
    // reflecting any scaling we choose to apply during the IDCT step.
    // Values of 1,2,4,8 are likely to be supported.  Note that different
    // components may receive different IDCT scalings.
     
    DCT_scaled_size: Integer;
    // The downsampled dimensions are the component's actual, unpadded number
    // of samples at the main buffer (preprocessing/compression interface), thus
    // downsampled_width = ceil(image_width * Hi/Hmax)
    // and similarly for height.  For decompression, IDCT scaling is included, so
    // downsampled_width = ceil(image_width * Hi/Hmax * DCT_scaled_size/DCTSIZE)
    downsampled_width,              // actual width in samples 
    downsampled_height: JDIMENSION; // actual height in samples
    // This flag is used only for decompression.  In cases where some of the
    // components will be ignored (eg grayscale output from YCbCr image),
    // we can skip most computations for the unused components.
    component_needed: LongBool; // do we need the value of this component? 

    // These values are computed before starting a scan of the component.
    // The decompressor output side may not use these variables. 
    MCU_width,                // number of blocks per MCU, horizontally
    MCU_height,               // number of blocks per MCU, vertically
    MCU_blocks,               // MCU_width * MCU_height
    MCU_sample_width,         // MCU width in samples, MCU_width*DCT_scaled_size
    last_col_width,           // # of non-dummy blocks across in last MCU
    last_row_height: Integer; // # of non-dummy blocks down in last MCU 

    // Saved quantization table for component; NULL if none yet saved.
    // See jdinput.c comments about the need for this information.
    // This field is currently used only for decompression.
    quant_table: JQUANT_TBL_ptr;

    // Private per-component storage for DCT or IDCT subsystem.
    dct_table: Pointer;
  end;

  jpeg_error_mgr_ptr = ^jpeg_error_mgr;
  jpeg_progress_mgr_ptr = ^jpeg_progress_mgr;

  j_common_ptr = ^jpeg_common_struct;

  j_decompress_ptr = ^jpeg_decompress_struct;

{ Routine signature for application-supplied marker processing methods.
  Need not pass marker code since it is stored in cinfo^.unread_marker. }

  jpeg_marker_parser_method = function(cinfo : j_decompress_ptr) : LongBool;

{ Marker reading & parsing }
  jpeg_marker_reader_ptr = ^jpeg_marker_reader;
  jpeg_marker_reader = record
    reset_marker_reader : procedure(cinfo : j_decompress_ptr);
    { Read markers until SOS or EOI.
      Returns same codes as are defined for jpeg_consume_input:
      JPEG_SUSPENDED, JPEG_REACHED_SOS, or JPEG_REACHED_EOI. }

    read_markers : function (cinfo : j_decompress_ptr) : Integer;
    { Read a restart marker --- exported for use by entropy decoder only }
    read_restart_marker : jpeg_marker_parser_method;
    { Application-overridable marker processing methods }
    process_COM : jpeg_marker_parser_method;
    process_APPn : Array[0..16-1] of jpeg_marker_parser_method;

    { State of marker reader --- nominally internal, but applications
      supplying COM or APPn handlers might like to know the state. }

    saw_SOI : LongBool;            { found SOI? }
    saw_SOF : LongBool;            { found SOF? }
    next_restart_num : Integer;    { next restart number expected (0-7) }
    discarded_bytes : UINT32;        { # of bytes skipped looking for a marker }
  end;

  {int8array = Array[0..8-1] of int;}
  int8array = Array[0..8-1] of Integer;

  jpeg_error_mgr = record
    { Error exit handler: does not return to caller }
    error_exit : procedure  (cinfo : j_common_ptr);
    { Conditionally emit a trace or warning message }
    emit_message : procedure (cinfo : j_common_ptr; msg_level : Integer);
    { Routine that actually outputs a trace or error message }
    output_message : procedure (cinfo : j_common_ptr);
    { Format a message string for the most recent JPEG error or message }
    format_message : procedure  (cinfo : j_common_ptr; buffer: PChar);
    { Reset error state variables at start of a new image }
    reset_error_mgr : procedure (cinfo : j_common_ptr);

    { The message ID code and any parameters are saved here.
      A message can have one string parameter or up to 8 int parameters. }

    msg_code : Integer;

    msg_parm : record
      case byte of
      0:(i : int8array);
      1:(s : string[JMSG_STR_PARM_MAX]);
    end;
    trace_level : Integer;     { max msg_level that will be displayed }
    num_warnings : Integer;    { number of corrupt-data warnings }
  end;


{ Data source object for decompression }

  jpeg_source_mgr_ptr = ^jpeg_source_mgr;
  jpeg_source_mgr = record
    next_input_byte : JOCTETptr;      { => next byte to read from buffer }
    bytes_in_buffer : Longint;       { # of bytes remaining in buffer }

    init_source : procedure  (cinfo : j_decompress_ptr);
    fill_input_buffer : function (cinfo : j_decompress_ptr) : LongBool;
    skip_input_data : procedure (cinfo : j_decompress_ptr; num_bytes : Longint);
    resync_to_restart : function (cinfo : j_decompress_ptr;
                                  desired : Integer) : LongBool;
    term_source : procedure (cinfo : j_decompress_ptr);
  end;

{ JPEG library memory manger routines }
  jpeg_memory_mgr_ptr = ^jpeg_memory_mgr;
  jpeg_memory_mgr = record
    { Method pointers }
    alloc_small : function (cinfo : j_common_ptr;
                            pool_id, sizeofobject: Integer): pointer;
    alloc_large : function (cinfo : j_common_ptr;
                            pool_id, sizeofobject: Integer): pointer;
    alloc_sarray : function (cinfo : j_common_ptr; pool_id : Integer;
                             samplesperrow : JDIMENSION;
                             numrows : JDIMENSION) : JSAMPARRAY;
    alloc_barray : pointer;
    request_virt_sarray : pointer;
    request_virt_barray : pointer;
    realize_virt_arrays : pointer;
    access_virt_sarray : pointer;
    access_virt_barray : pointer;
    free_pool : pointer;
    self_destruct : pointer;
    max_memory_to_use : Longint;
  end;

    { Fields shared with jpeg_decompress_struct }
  jpeg_common_struct = packed record
    err : jpeg_error_mgr_ptr;        { Error handler module }
    mem : jpeg_memory_mgr_ptr;          { Memory manager module }
    progress : jpeg_progress_mgr_ptr;   { Progress monitor, or NIL if none }
    is_decompressor : LongBool;      { so common code can tell which is which }
    global_state : Integer;          { for checking call sequence validity }
  end;

{ Progress monitor object }

  jpeg_progress_mgr = record
    progress_monitor : procedure(const cinfo : jpeg_common_struct);
    pass_counter : Integer;     { work units completed in this pass }
    pass_limit : Integer;       { total number of work units in this pass }
    completed_passes : Integer;	{ passes completed so far }
    total_passes : Integer;     { total number of passes expected }
    // extra Delphi info, kann je nach Nutzer ein TJPGDecoder oder eine TJPGGraphic sein
    instance: TPersistent;       // zum Reinzwiebeln des Objekts bei Callbacks
    last_pass: Integer;
    last_pct: Integer;
    last_time: Integer;
    last_scanline: Integer;
  end;


{ Master record for a decompression instance }

  jpeg_decompress_struct = packed record
    common: jpeg_common_struct;

    { Source of compressed data }
    src : jpeg_source_mgr_ptr;

    { Basic description of image --- filled in by jpeg_read_header(). }
    { Application may inspect these values to decide how to process image. }

    image_width : JDIMENSION;      { nominal image width (from SOF marker) }
    image_height : JDIMENSION;     { nominal image height }
    num_components : Integer;          { # of color components in JPEG image }
    jpeg_color_space : J_COLOR_SPACE; { colorspace of JPEG image }

    { Decompression processing parameters }
    out_color_space : J_COLOR_SPACE; { colorspace for output }
    scale_num, scale_denom : UINT32 ;  { fraction by which to scale image }
    output_gamma : double;           { image gamma wanted in output }
    buffered_image : LongBool;        { TRUE=multiple output passes }
    raw_data_out : LongBool;          { TRUE=downsampled data wanted }
    dct_method : J_DCT_METHOD;       { IDCT algorithm selector }
    do_fancy_upsampling : LongBool;   { TRUE=apply fancy upsampling }
    do_block_smoothing : LongBool;    { TRUE=apply interblock smoothing }
    quantize_colors : LongBool;       { TRUE=colormapped output wanted }
    { the following are ignored if not quantize_colors: }
    dither_mode : J_DITHER_MODE;     { type of color dithering to use }
    two_pass_quantize : LongBool;     { TRUE=use two-pass color quantization }
    desired_number_of_colors : Integer;  { max # colors to use in created colormap }
    { these are significant only in buffered-image mode: }
    enable_1pass_quant : LongBool;    { enable future use of 1-pass quantizer }
    enable_external_quant : LongBool; { enable future use of external colormap }
    enable_2pass_quant : LongBool;    { enable future use of 2-pass quantizer }

    { Description of actual output image that will be returned to application.
      These fields are computed by jpeg_start_decompress().
      You can also use jpeg_calc_output_dimensions() to determine these values
      in advance of calling jpeg_start_decompress(). }

    output_width : JDIMENSION;       { scaled image width }
    output_height: JDIMENSION;       { scaled image height }
    out_color_components : Integer;  { # of color components in out_color_space }
    output_components : Integer;     { # of color components returned }
    { output_components is 1 (a colormap index) when quantizing colors;
      otherwise it equals out_color_components. }

    rec_outbuf_height : Integer;     { min recommended height of scanline buffer }
    { If the buffer passed to jpeg_read_scanlines() is less than this many
      rows high, space and time will be wasted due to unnecessary data
      copying. Usually rec_outbuf_height will be 1 or 2, at most 4. }

    { When quantizing colors, the output colormap is described by these
      fields. The application can supply a colormap by setting colormap
      non-NIL before calling jpeg_start_decompress; otherwise a colormap
      is created during jpeg_start_decompress or jpeg_start_output. The map
      has out_color_components rows and actual_number_of_colors columns. }

    actual_number_of_colors : Integer;      { number of entries in use }
    colormap : JSAMPARRAY;              { The color map as a 2-D pixel array }

    { State variables: these variables indicate the progress of decompression.
      The application may examine these but must not modify them. }

    { Row index of next scanline to be read from jpeg_read_scanlines().
      Application may use this to control its processing loop, e.g.,
      "while (output_scanline < output_height)". }

    output_scanline : JDIMENSION; { 0 .. output_height-1  }

    { Current input scan number and number of iMCU rows completed in scan.
      These indicate the progress of the decompressor input side. }

    input_scan_number : Integer;      { Number of SOS markers seen so far }
    input_iMCU_row : JDIMENSION;  { Number of iMCU rows completed }

    { The "output scan number" is the notional scan being displayed by the
      output side.  The decompressor will not allow output scan/row number
      to get ahead of input scan/row, but it can fall arbitrarily far behind.}

    output_scan_number : Integer;     { Nominal scan number being displayed }
    output_iMCU_row : Integer;        { Number of iMCU rows read }

    coef_bits : Pointer;

    { Internal JPEG parameters --- the application usually need not look at
      these fields.  Note that the decompressor output side may not use
      any parameters that can change between scans. }

    { Quantization and Huffman tables are carried forward across input
      datastreams when processing abbreviated JPEG datastreams. }

    quant_tbl_ptrs : Array[0..NUM_QUANT_TBLS-1] of Pointer;
    dc_huff_tbl_ptrs : Array[0..NUM_HUFF_TBLS-1] of Pointer;
    ac_huff_tbl_ptrs : Array[0..NUM_HUFF_TBLS-1] of Pointer;

    { These parameters are never carried across datastreams, since they
      are given in SOF/SOS markers or defined to be reset by SOI. }
    data_precision : Integer;          { bits of precision in image data }
    comp_info: jpeg_component_info_ptr;
    progressive_mode : LongBool;    { TRUE if SOFn specifies progressive mode }
    arith_code : LongBool;          { TRUE=arithmetic coding, FALSE=Huffman }
    arith_dc_L : Array[0..NUM_ARITH_TBLS-1] of UINT8; { L values for DC arith-coding tables }
    arith_dc_U : Array[0..NUM_ARITH_TBLS-1] of UINT8; { U values for DC arith-coding tables }
    arith_ac_K : Array[0..NUM_ARITH_TBLS-1] of UINT8; { Kx values for AC arith-coding tables }

    restart_interval : UINT32; { MCUs per restart interval, or 0 for no restart }

    { These fields record data obtained from optional markers recognized by
      the JPEG library. }
    saw_JFIF_marker : LongBool;  { TRUE iff a JFIF APP0 marker was found }
    { Data copied from JFIF marker: }
    density_unit : UINT8;       { JFIF code for pixel size units }
    X_density : UINT16;         { Horizontal pixel density }
    Y_density : UINT16;         { Vertical pixel density }
    saw_Adobe_marker : LongBool; { TRUE iff an Adobe APP14 marker was found }
    Adobe_transform : UINT8;    { Color transform code from Adobe marker }

    CCIR601_sampling : LongBool; { TRUE=first samples are cosited }

    { Remaining fields are known throughout decompressor, but generally
      should not be touched by a surrounding application. }
    max_h_samp_factor : Integer;    { largest h_samp_factor }
    max_v_samp_factor : Integer;    { largest v_samp_factor }
    min_DCT_scaled_size : Integer;  { smallest DCT_scaled_size of any component }
    total_iMCU_rows : JDIMENSION; { # of iMCU rows in image }
    sample_range_limit : Pointer;   { table for fast range-limiting }

    { These fields are valid during any one scan.
      They describe the components and MCUs actually appearing in the scan.
      Note that the decompressor output side must not use these fields. }
    comps_in_scan : Integer;           { # of JPEG components in this scan }
    cur_comp_info : Array[0..MAX_COMPS_IN_SCAN - 1] of Pointer;
    MCUs_per_row : JDIMENSION;     { # of MCUs across the image }
    MCU_rows_in_scan : JDIMENSION; { # of MCU rows in the image }
    blocks_in_MCU : JDIMENSION;    { # of DCT blocks per MCU }
    MCU_membership : Array[0..D_MAX_BLOCKS_IN_MCU - 1] of Integer;
    Ss, Se, Ah, Al : Integer;          { progressive JPEG parameters for scan }

    { This field is shared between entropy decoder and marker parser.
      It is either zero or the code of a JPEG marker that has been
      read from the data source, but has not yet been processed. }
    unread_marker : Integer;

    { Links to decompression subobjects
      (methods, private variables of modules) }
    master : Pointer;
    main : Pointer;
    coef : Pointer;
    post : Pointer;
    inputctl : Pointer;
    marker : Pointer;
    entropy : Pointer;
    idct : Pointer;
    upsample : Pointer;
    cconvert : Pointer;
    cquantize : Pointer;
  end;

  TJPEGContext = record
    err: jpeg_error_mgr;
    progress: jpeg_progress_mgr;
    FinalDCT: J_DCT_METHOD;
    FinalTwoPassQuant: Boolean;
    FinalDitherMode: J_DITHER_MODE;
    case byte of
      0: (common: jpeg_common_struct);
      1: (d: jpeg_decompress_struct);
//      2: (c: jpeg_compress_struct);
  end;

procedure GetJPEGInfo(Stream: TStream; var Width, Height: Cardinal);

procedure jpeg_CreateDecompress(cinfo: j_decompress_ptr; version : integer; structsize : integer);
procedure jpeg_stdio_src(cinfo: j_decompress_ptr; input_file: TStream);
function jpeg_read_header(cinfo: j_decompress_ptr; RequireImage: LongBool): Integer;
procedure jpeg_calc_output_dimensions(cinfo: j_decompress_ptr);
function jpeg_start_decompress(cinfo: j_decompress_ptr): Longbool;
function jpeg_read_scanlines(cinfo: j_decompress_ptr; scanlines: JSAMPARRAY; max_lines: JDIMENSION): JDIMENSION;
function jpeg_read_raw_data(cinfo: j_decompress_ptr; data: JSAMPIMAGE; max_lines: JDIMENSION): JDIMENSION;
function jpeg_finish_decompress(cinfo: j_decompress_ptr): Longbool;
procedure jpeg_destroy_decompress(cinfo: j_decompress_ptr);
function jpeg_has_multiple_scans(cinfo: j_decompress_ptr): Longbool;
function jpeg_consume_input(cinfo: j_decompress_ptr): Integer;
function jpeg_start_output(cinfo: j_decompress_ptr; scan_number: Integer): Longbool;
function jpeg_finish_output(cinfo: j_decompress_ptr): LongBool;
procedure jpeg_abort(cinfo: j_decompress_ptr);
procedure jpeg_destroy(cinfo: j_decompress_ptr);
function jpeg_resync_to_restart(cinfo: j_decompress_ptr; desired: Integer): LongBool; external;

var
  // default routines for error manager (filled on unit initialization time)
  jpeg_std_error: jpeg_error_mgr = (
    error_exit: nil;
    emit_message: nil;
    output_message: nil;
    format_message: nil;
    reset_error_mgr: nil);

implementation

const
  sJPEGError = 'JPEG error #%d';

function _malloc(size: Integer): Pointer; cdecl;
begin
  GetMem(Result, size);
end;

procedure _free(P: Pointer); cdecl;
begin
  FreeMem(P);
end;

procedure _memset(P: Pointer; B: Byte; count: Integer);cdecl;
begin
  FillChar(P^, count, B);
end;

procedure _memcpy(dest, source: Pointer; count: Integer);cdecl;
begin
  Move(source^, dest^, count);
end;

function _fread(var buf; recsize, reccount: Integer; S: TStream): Integer; cdecl;
begin
  Result := S.Read(buf, recsize * reccount);
end;

function _fwrite(const buf; recsize, reccount: Integer; S: TStream): Integer; cdecl;
begin
  Result := S.Write(buf, recsize * reccount);
end;

function _fflush(S: TStream): Integer; cdecl;
begin
  Result := 0;
end;

function __ftol: Integer;
var
  f: double;
begin
  asm
    lea    eax, f             //  BC++ passes floats on the FPU stack
    fstp  qword ptr [eax]     //  Delphi passes floats on the CPU stack
  end;
  Result := Trunc(f);
end;

var
  __turboFloat: LongBool = False;

procedure JpegError(cinfo: j_common_ptr);
begin
  raise Exception.CreateFmt(sJPEGError,[cinfo^.err^.msg_code]);
end;

procedure EmitMessage(cinfo: j_common_ptr; msg_level: Integer);
begin
  //!!
end;

procedure OutputMessage(cinfo: j_common_ptr);
begin
  //!!
end;

procedure FormatMessage(cinfo: j_common_ptr; buffer: PChar);
begin
  //!!
end;

procedure ResetErrorMgr(cinfo: j_common_ptr);
begin
  cinfo^.err^.num_warnings := 0;
  cinfo^.err^.msg_code := 0;
end;

{$L jdapimin.obj}
{$L jmemmgr.obj}
{$L jmemnobs.obj}
{$L jdinput.obj}
{$L jdatasrc.obj}
{$L jdapistd.obj}
{$L jdmaster.obj}
{$L jdphuff.obj}
{$L jdhuff.obj}
{$L jdmerge.obj}
{$L jdcolor.obj}
{$L jquant1.obj}
{$L jquant2.obj}
{$L jdmainct.obj}
{$L jdcoefct.obj}
{$L jdpostct.obj}
{$L jddctmgr.obj}
{$L jdsample.obj}
{$L jidctflt.obj}
{$L jidctfst.obj}
{$L jidctint.obj}
{$L jidctred.obj}
{$L jdmarker.obj}
{$L jutils.obj}
{$L jcomapi.obj}

procedure jpeg_CreateDecompress(cinfo: j_decompress_ptr; version: integer; structsize : integer); external;
procedure jpeg_stdio_src(cinfo: j_decompress_ptr; input_file: TStream); external;
function jpeg_read_header(cinfo: j_decompress_ptr; RequireImage: LongBool): Integer; external;
procedure jpeg_calc_output_dimensions(cinfo: j_decompress_ptr); external;
function jpeg_start_decompress(cinfo: j_decompress_ptr): Longbool; external;
function jpeg_read_scanlines(cinfo: j_decompress_ptr; scanlines: JSAMPARRAY; max_lines: JDIMENSION): JDIMENSION; external;
// replaces jpeg_read_scanlines when reading raw downsampled data
function jpeg_read_raw_data(cinfo: j_decompress_ptr; data: JSAMPIMAGE; max_lines: JDIMENSION): JDIMENSION; external;
  
function jpeg_finish_decompress(cinfo: j_decompress_ptr): Longbool; external;
procedure jpeg_destroy_decompress (cinfo: j_decompress_ptr); external;
function jpeg_has_multiple_scans(cinfo: j_decompress_ptr): Longbool; external;
function jpeg_consume_input(cinfo: j_decompress_ptr): Integer; external;
function jpeg_start_output(cinfo: j_decompress_ptr; scan_number: Integer): Longbool; external;
function jpeg_finish_output(cinfo: j_decompress_ptr): LongBool; external;
procedure jpeg_abort(cinfo: j_decompress_ptr); external;
procedure jpeg_destroy(cinfo: j_decompress_ptr); external;

procedure GetJPEGInfo(Stream: TStream; var Width, Height: Cardinal);
var
  jc: TJPEGContext;
begin
  FillChar(jc, SizeOf(jc), 0);
  jc.err := jpeg_std_error;
  jc.common.err := @jc.err;
  jpeg_CreateDecompress(@jc.d, JPEG_LIB_VERSION, SizeOf(jc.d));
  try
    jpeg_stdio_src(@jc.d, Stream);
    jpeg_read_header(@jc.d, False);
    Width := jc.d.image_width;
    Height := jc.d.image_height;
  finally
    jpeg_destroy(@jc.common);
  end;
end;

initialization
  with jpeg_std_error do
  begin
    error_exit := @JpegError;
    emit_message := @EmitMessage;
    output_message := @OutputMessage;
    format_message := @FormatMessage;
    reset_error_mgr := @ResetErrorMgr;
  end;

end.

