// ***************************************************************************
// ****************** Portions for file loading by DIGIBEN *******************
// ********************** T3DModel Class for 3DS Files ***********************
// **********************   Juan José Montero  *******************************
// ******************* juanjo.montero@telefonica.net *************************
// *********************** Release 19/11/2003 ********************************
// ***************************************************************************


unit avlUnit3DS;


interface


uses Windows, avlVectors;


const
// Root Node
  M3DMAGIC     = $4D4D;

// Primary Blocks
  M3D_VERSION  = $0002; // File version
  MDATA        = $3D3D; // All the Object information
  KFDATA       = $B000; // Animation frames

// Definitions for MDATA
  MAT_ENTRY    = $AFFF; // Material information
  NAMED_OBJECT = $4000; // Object data (vertices, faces ...)

// Definitions for MAT_ENTRY
  MAT_NAME         = $A000; // Material name
  MAT_AMBIENT      = $A010; // Ambient
  MAT_DIFFUSE      = $A020; // Diffuse
  MAT_SPECULAR     = $A030; // Specular
  MAT_SHININESS    = $A040; // Shininess
  MAT_TRANSPARENCY = $A050; // Transparency
  MAT_TEXMAP       = $A200; // Texture information
  MAT_MAPNAME      = $A300; // Texture file name
  N_TRI_OBJECT     = $4100; // For each object  ...

// Definitions for N_TRI_OBJECT
  POINT_ARRAY  = $4110; // Vertices
  FACE_ARRAY   = $4120; // Faces
  MSH_MAT_GROUP= $4130; // Material for the object
  TEX_VERTS    = $4140; // Texture coordinates

  SUPPORTEDVERSION = $03; // Vserión máxima de 3DS soportada


// -----------------------------------------------------------------------------


type
  TMaterialType = (mtAmbient, mtDiffuse, mtSpecular);

type
  TVertexIndex = array [0..2] of Integer;


type
  TFace = record
    VertIndex :TVertexIndex;
    CoordIndex:TVertexIndex;
end;


type
   TRenderMode = (rmTriangles, rmLines, rmPoints);

type TColor = -$7FFFFFFF-1..$7FFFFFFF;

type
   TTransformType = (ttRotate, ttTranslate, ttScale);



// This Class is used to apply one transformation to 3ds object. The instance
// is stored in TTransformList class
type
  TTransformation = class(TObject)
  private
    FX: Single;
    FY: Single;
    FAngle: Single;
    FZ: Single;
    FTransformType: TTransformType;
    FEnabled: Boolean;

  public
    constructor Create;
    procedure Apply;
    procedure Restore;
    property Angle:Single read FAngle write FAngle;
    property TransformType:TTransformType read FTransformType write FTransformType;
    property X:Single read FX write FX;
    property Y:Single read FY write FY;
    property Z:Single read FZ write FZ;
    property Enabled:Boolean read FEnabled write FEnabled;
end;



// Class to store the material properties. Ambient, diffuse, specular
// and emission are classes of TMaterialProperties
type
  TMaterialProperties = class(TObject)
  private
    FVector:TVector4f;
    FglDefFace, FglDefType:Cardinal;
    function GetColor: TColor;
    procedure SetColor(const Value: TColor);

  public
    constructor Create(glDefFace, glDefType:Cardinal);
    destructor Destroy;override;
    function ToString:string;
    procedure SetRGBA(const R, G, B, Alpha:Single);
    procedure Apply;
    property Vector:TVector4f read FVector write FVector;
    property Color:TColor read GetColor write SetColor;
    property Alpha:Single read FVector.Alpha write FVector.Alpha;
end;


// List of TTransformation class
{type
  TTransformList = class(TList)
  private
    FEnabled: Boolean;

  public
    constructor Create;
    destructor Destroy;override;
    procedure Push;
    procedure Pop;
    property Enabled:Boolean read FEnabled write FEnabled;
    function AddTransform:TTransformation;
    function AddTransformEx(const _TransformType:TTransformType; const _Angle, _X, _Y, _Z:Single):TTransformation;
end;}



type

  T3DModel = class;

// TChunk only used for loading the 3ds file. This class is destroyed after
// loading
  TChunk = class(TObject)
  private
    FId:Word;
    FLength:Integer;
    FBytesReaded:Integer;
    FModel:T3DModel;
    FFileHandle:Integer;
    function GetBytesRemaining: Integer;
  public
    constructor Create(Model:T3DModel);
    destructor Destroy;override;
    function Read:Integer;
    function ReadBuffer(var Buffer; Count:Integer):Integer;
    function ReadRemainingBuffer(var Buffer):Integer;
    procedure ProcessNextChunk(PreviousChunk:TChunk);
    procedure NexFilePosition;
    function ReadObjectString:string;
    function WaitForLength:Boolean;
    procedure UpdateByteCounter(Value:Integer);
    property Id:Word read FId;
    property Length:Integer read FLength;
    property BytesReaded:Integer read FBytesReaded;
    property BytesRemaining:Integer read GetBytesRemaining;
    property FileHandle:Integer read FFileHandle write FFileHandle;
end;


// Store the complete material properties for each 3ds object
  TMaterial = class(TObject)
  private
    FMaterialName:string;
    FMaterialFile:string;
    FHasTexture:Boolean;
    FGenTexture:Cardinal;
    FDisableTexture:Boolean;
    FEnviromentMap: Boolean;
    FSphericalMap: Boolean;
    FAmbient: TMaterialProperties;
    FEmission: TMaterialProperties;
    FSpecular: TMaterialProperties;
    FDiffuse: TMaterialProperties;
    // uTile: Single;
    // vTile: Single;
    // uOffset: Single;
    // vOffset: Single;
    procedure SetMaterial;
    procedure EnviromentApply;
    procedure SphericalApply;
    function TextureActive:Boolean;
  public
    Shininess, Transparency:Single;
    constructor Create;
    destructor Destroy;override;
    procedure ProcessNextMaterialChunk(PreviousChunk:TChunk);
    procedure ReadColorChunk(PreviousChunk:TChunk; var Buffer);
    procedure CopyFrom(Source:TMaterial);
    procedure SetMaterialColor(const MaterialType: TMaterialType; const R, G, B, Alpha:Single);
    property HasTexture:Boolean read FHasTexture;
    property DisableTexture:Boolean read FDisableTexture write FDisableTexture;
    property EnviromentMap:Boolean read  FEnviromentMap write FEnviromentMap;
    property SphericalMap:Boolean read  FSphericalMap write FSphericalMap;
    property GenTexture:Cardinal read FGenTexture write FGenTexture;
    property MaterialName:string read FMaterialName;
    property MaterialFile:string read FMaterialFile;
    property Ambient:TMaterialProperties read FAmbient;
    property Diffuse:TMaterialProperties read FDiffuse;
    property Specular:TMaterialProperties read FSpecular;
    property Emission:TMaterialProperties read FEmission;
end;


// This class stores the complete definition for each 3ds object. Is used to
// draw it in the scene also.
  T3DObject = class(TObject)
  private
    FVisible:Boolean;
    FObjectName:string;
    FMaterial:TMaterial;
    FVertexCount, FTexVertexCount,
    FFaceCount, FNormalCount:Integer;
    FObjectIndex:Integer;
    FMaxVector, FMinVector, FMidVector:TVector3D;
    FSelected:Boolean;
    FRMode:Cardinal;
    FRenderMode: TRenderMode;
//    FTransformList: TTransformList;
    procedure SetRenderMode(const Value: TRenderMode);
    procedure DrawBox;
  public
    Verts:array of TVector3D;
    Normals:array of TVector3D;
    TexVerts:array of TVector2D;
    Faces:array of TFace;
    constructor Create;
    destructor Destroy;override;
    procedure Draw;
    procedure ProcessNextObjectChunk(PreviousChunk:TChunk);
    procedure ReadVertices(PreviousChunk:TChunk);
    procedure ReadVertexIndices(PreviousChunk:TChunk);
    procedure ReadObjectMaterial(PreviousChunk:TChunk);
    procedure ReadUVCoordinates(PreviousChunk:TChunk);
    procedure AdjustNormals;
    // procedure Transform(const Transformation:TTransformObject; const T, X, Y, Z:Single);
    property Visible:Boolean read FVisible write FVisible;
    property ObjectName:string read FObjectName write FObjectName;
    property Material:TMaterial read FMaterial;
    property VertexCount:Integer read FVertexCount;
    property TexVertexCount:Integer read FTexVertexCount;
    property FaceCount:Integer read FFaceCount;
    property NormalCount:Integer read FNormalCount;
    property ObjectIndex:Integer read FObjectIndex;
    property RenderMode:TRenderMode read FRenderMode write SetRenderMode;
//    property TransformList:TTransformList read FTransformList;
    property Selected:Boolean read FSelected write FSelected;
end;


// This class is the core of this unit. It is used to load, draw all and more
  T3DModel = class(TObject)
  private
    FMaterials:array of TMaterial;
    FFileHandle:Integer;
    FRootChunk:TChunk;
    function GetMaterialCount: Integer;
    function GetObjectCount: Integer;
    procedure CleanUp;
    procedure ComputeNormals;
  public
    Objects:array of T3DObject;
    constructor Create;
    destructor Destroy;override;
    function AddMaterial:TMaterial;
    function AddObject:T3DObject;
    procedure Clear;
    procedure VisibleAll;
    function LoadFromFile(const FileName:string):Boolean;
    function FindObject(const aName:string):T3DObject;
    function Select(const Index:Integer):T3DObject;
    procedure Draw;
    property ObjectCount:Integer read GetObjectCount;
    property MaterialCount:Integer read GetMaterialCount;
end;

implementation

uses AvL, avlUtils, OpenGL, {$ifndef NoTextures}avlTextures,{$endif} avlMath;


//procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;

// Convert TColor to RGBA
function ColorToVector4f(const aColor: TColor; Alpha:Single): TVector4f;
begin
  Result.Red:=(aColor and $FF)/255;
  Result.Green:=((aColor shr 8) and $FF)/255;
  Result.Blue:=((aColor shr 16) and $FF)/255;
  Result.Alpha:=Alpha;
end;

// Convert RGBA to TColor
function Vector4fToColor(const aVector: TVector4f): TColor;
var C:TByteColor;
begin
  C:=Color4fToByte(aVector);
  Result:=Rgb(C.Red, C.Green, C.Blue);
end;

function RGBToColor(const R, G, B:Byte):TColor;
begin
  Result:=R;
  Result:=Result or (G shl 8);
  Result:=Result or (B shl 16);
end;


{ TChunk }

constructor TChunk.Create(Model:T3DModel);
begin
  inherited Create;
  FId:=0;
  FLength:=0;
  FBytesReaded:=0;
  FModel:=Model;
  FFileHandle:=FModel.FFileHandle;
end;

destructor TChunk.Destroy;
begin
  inherited;
end;

function TChunk.GetBytesRemaining: Integer;
begin
  Result:=FLength - BytesReaded;
end;

function TChunk.WaitForLength: Boolean;
begin
  Result:=FBytesReaded < FLength;
end;

procedure TChunk.NexFilePosition;
var NewPosition:Integer;
begin
  NewPosition:=BytesRemaining;
  FileSeek(FFileHandle, NewPosition, 1);
  UpdateByteCounter(NewPosition);
end;

procedure TChunk.ProcessNextChunk(PreviousChunk: TChunk);
var NewChunk, TempChunk:TChunk;
    FileVersion, MeshVersion:Cardinal;
begin
  NewChunk:=TChunk.Create(PreviousChunk.FModel);
  while PreviousChunk.WaitForLength do
   begin
     NewChunk.Read;
     case NewChunk.Id of

      M3D_VERSION:
       begin
         NewChunk.ReadRemainingBuffer(FileVersion);
          if (FileVersion > SUPPORTEDVERSION) then
           MessageBox(0, 'Unsupported file version.', 'Warning', MB_OK);
       end;


       MDATA:
         begin
           TempChunk:=TChunk.Create(PreviousChunk.FModel);
           TempChunk.Read;
           TempChunk.ReadRemainingBuffer(MeshVersion);
           NewChunk.UpdateByteCounter(TempChunk.BytesReaded);
           TempChunk.Free;
	   ProcessNextChunk(NewChunk);
	 end;

       MAT_ENTRY:
         with FModel.AddMaterial do
	  ProcessNextMaterialChunk(NewChunk);


       // This holds the name of the object being read
       NAMED_OBJECT:
         with FModel.AddObject do
          begin
            ObjectName:=NewChunk.ReadObjectString;
            ProcessNextObjectChunk(NewChunk);
          end;

       KFDATA: NewChunk.NexFilePosition;

     else
       NewChunk.NexFilePosition;
     end;
     PreviousChunk.UpdateByteCounter(NewChunk.BytesReaded);
   end;
  NewChunk.Free;
end;

function TChunk.Read: Integer;
begin
  FBytesReaded:=FileRead(FFileHandle, FId, 2);
  FBytesReaded:=FBytesReaded + FileRead(FFileHandle, FLength, 4);
  Result:=FBytesReaded;
end;

function TChunk.ReadBuffer(var Buffer; Count: Integer): Integer;
begin
  Result:=FileRead(FFileHandle, Buffer, Count);
  FBytesReaded:=FBytesReaded + Result;
end;


function TChunk.ReadObjectString:string;
var I:Integer;
    C:Char;
    S:ShortString;
begin
  I:=0;
  C:=#255; // Initialization for "while"
  while C<>#0 do
   begin
     FileRead(FFileHandle, C, 1);
     S[I+1]:=C;
     Inc(I);
   end;

  SetLength(Result, I-1);
  Move(S[1], Result[1], I-1);
  UpdateByteCounter(I);
end;


function TChunk.ReadRemainingBuffer(var Buffer): Integer;
var I:Integer;
begin
  I:=BytesRemaining;
  Result:=FileRead(FFileHandle, Buffer, I);
  FBytesReaded:=FBytesReaded + Result;
end;


procedure TChunk.UpdateByteCounter(Value: Integer);
begin
  FBytesReaded:=FBytesReaded + Value;
end;


// ************************** END TCHUNK **************************************



// ************************** TMATERIAL **************************************


{ TMaterial }

constructor TMaterial.Create;
begin
  inherited;
  FAmbient:=TMaterialProperties.Create(GL_FRONT, GL_AMBIENT);
  FDiffuse:=TMaterialProperties.Create(GL_FRONT, GL_DIFFUSE);
  FSpecular:=TMaterialProperties.Create(GL_FRONT, GL_SPECULAR);
  FEmission:=TMaterialProperties.Create(GL_FRONT, GL_EMISSION);
end;



destructor TMaterial.Destroy;
begin
  FEmission.Free;
  FSpecular.Free;
  FDiffuse.Free;
  FAmbient.Free;
  inherited;
end;


procedure TMaterial.ReadColorChunk(PreviousChunk:TChunk; var Buffer);
var TempChunk:TChunk;
begin
  TempChunk:=TChunk.Create(PreviousChunk.FModel);
  TempChunk.Read;
  TempChunk.ReadRemainingBuffer(Buffer);
  PreviousChunk.UpdateByteCounter(TempChunk.BytesReaded);
  TempChunk.Free;
end;

procedure TMaterial.ProcessNextMaterialChunk(PreviousChunk: TChunk);
var NewChunk:TChunk;
    I:Integer;
    Buffer:TByteColor;
    __Shininess, __Transparency:Word;
begin
  NewChunk:=TChunk.Create(PreviousChunk.FModel);
  while PreviousChunk.WaitForLength do
   begin
     NewChunk.Read;

     case NewChunk.Id of

       MAT_NAME:
         begin
           I:=NewChunk.BytesRemaining;
       	   SetLength(FMaterialName, I);
           NewChunk.ReadBuffer(FMaterialName[1], I);
           SetLength(FMaterialName, Length(FMaterialName) - 1);
         end;


       MAT_AMBIENT:
         begin
           ReadColorChunk(NewChunk, Buffer);
           Ambient.Vector:=ByteColorTo4f(Buffer);
         end;

       MAT_DIFFUSE:
         begin
           ReadColorChunk(NewChunk, Buffer);
           Diffuse.Vector:=ByteColorTo4f(Buffer);
         end;

       MAT_SPECULAR:
         begin
           ReadColorChunk(NewChunk, Buffer);
           Specular.Vector:=ByteColorTo4f(Buffer);
         end;


       MAT_SHININESS:
         begin
           ReadColorChunk(NewChunk, __Shininess);
           Shininess:=128 - (__Shininess * 1.28);
         end;

       MAT_TRANSPARENCY:
         begin
           ReadColorChunk(NewChunk, __Transparency);
           Transparency:=1 - (__Transparency / 100);
           Diffuse.Alpha:=Transparency;
         end;

       MAT_TEXMAP:ProcessNextMaterialChunk(NewChunk);

       MAT_MAPNAME:
         begin
           I:=NewChunk.BytesRemaining;
           SetLength(FMaterialFile, I);
           NewChunk.ReadBuffer(FMaterialFile[1], I);
           SetLength(FMaterialFile, Length(FMaterialFile) - 1);
           {$ifndef NoTextures}FHasTexture:=LoadTexture(FMaterialFile, FGenTexture, False, 0, 0);{$endif}
         end;

     else
       NewChunk.NexFilePosition;
     end;
     PreviousChunk.UpdateByteCounter(NewChunk.BytesReaded);
   end;
  NewChunk.Free;
end;


procedure TMaterial.CopyFrom(Source: TMaterial);
begin
  FMaterialName:=Source.MaterialName;
  FMaterialFile:=Source.MaterialFile;
  Ambient.Vector:=Source.Ambient.Vector;
  Diffuse.Vector:=Source.Diffuse.Vector;
  Specular.Vector:=Source.Specular.Vector;
  Shininess:=Source.Shininess;
  FHasTexture:=Source.HasTexture;
  FGenTexture:=Source.GenTexture;
end;


procedure TMaterial.SetMaterialColor(const MaterialType: TMaterialType; const R, G,
  B, Alpha: Single);
begin
  case MaterialType of
    mtAmbient : Ambient.SetRGBA(R, G, B, Alpha);
    mtDiffuse : Diffuse.SetRGBA(R, G, B, Alpha);
    mtSpecular: Specular.SetRGBA(R, G, B, Alpha);
  end;
end;

procedure TMaterial.EnviromentApply;
begin
  if FEnviromentMap then
   begin
     glTexGenf(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
     glEnable(GL_TEXTURE_GEN_T);
   end
    else
     glDisable(GL_TEXTURE_GEN_T);

end;

procedure TMaterial.SphericalApply;
begin
  if FSphericalMap then
   begin
     glTexGenf(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
     glEnable(GL_TEXTURE_GEN_S);
   end
    else
     glDisable(GL_TEXTURE_GEN_S);
end;


function TMaterial.TextureActive: Boolean;
begin
  Result:=FHasTexture and (not FDisableTexture);
end;


procedure TMaterial.SetMaterial;
begin
  Ambient.Apply;
  Diffuse.Apply;
  Specular.Apply;
  Emission.Apply;
  glMaterialfv(GL_FRONT, GL_SHININESS, @Shininess);
{  EnviromentApply;
  SphericalApply; //}
{$ifndef NoTextures}
  if TextureActive then
   begin
     glEnable(GL_TEXTURE_2D);
     glBindTexture(GL_TEXTURE_2D, FGenTexture);
   end
    else
//     glDisable(GL_TEXTURE_2D); // big BUG here - we have not to disable this cool feature ;)
{$endif}
end;



// ************************** END TMATERIAL ***********************************

// ************************** T3DOBJECT **************************************




{ T3DObject }


constructor T3DObject.Create;
begin
  inherited;
  Verts:=nil;
  Normals:=nil;
  TexVerts:=nil;
  Faces:=nil;
  RenderMode:=rmTriangles;
  FMaterial:=TMaterial.Create;
//  FTransformList:=TTransformList.Create;
  FVisible:=True;
end;

destructor T3DObject.Destroy;
begin
  Finalize(Verts);
  Finalize(Normals);
  Finalize(TexVerts);
  Finalize(Faces);
//  glDeleteTextures(1, FMaterial.FGenTexture);
  FMaterial.Free;
//  FTransformList.Free;
  inherited;
end;

procedure T3DObject.ProcessNextObjectChunk(PreviousChunk:TChunk);
var NewChunk:TChunk;
begin
  NewChunk:=TChunk.Create(PreviousChunk.FModel);
  while PreviousChunk.WaitForLength do
   begin
     NewChunk.Read;
     case NewChunk.Id of
       N_TRI_OBJECT:ProcessNextObjectChunk(NewChunk);
       POINT_ARRAY:ReadVertices(NewChunk);
       FACE_ARRAY:ReadVertexIndices(NewChunk);
       MSH_MAT_GROUP:ReadObjectMaterial(NewChunk);
       TEX_VERTS:ReadUVCoordinates(NewChunk);
     else
       NewChunk.NexFilePosition;
     end;
     PreviousChunk.UpdateByteCounter(NewChunk.BytesReaded);
   end;
  NewChunk.Free;
end;



procedure T3DObject.ReadObjectMaterial(PreviousChunk: TChunk);
var I:Integer;
    SourceMaterial:TMaterial;
begin
  FMaterial.FMaterialName:=PreviousChunk.ReadObjectString;
  for I:=0 to PreviousChunk.FModel.MaterialCount-1 do
   begin
     SourceMaterial:=PreviousChunk.FModel.FMaterials[I];
     if CompareStr(FMaterial.MaterialName, SourceMaterial.MaterialName) = 0 then
      begin
        FMaterial.CopyFrom(SourceMaterial);
        Break;
      end;  
   end;
  PreviousChunk.NexFilePosition;
end;


procedure T3DObject.ReadUVCoordinates(PreviousChunk: TChunk);
begin
  PreviousChunk.ReadBuffer(FTexVertexCount, 2);
  SetLength(TexVerts, FTexVertexCount);
  PreviousChunk.ReadRemainingBuffer(TexVerts[0]);
end;


procedure T3DObject.ReadVertexIndices(PreviousChunk: TChunk);
var I, J:Integer;
    Index:Word;
begin
  PreviousChunk.ReadBuffer(FFaceCount, 2);
  SetLength(Faces, FFaceCount);

  for I:=0 to FFaceCount-1 do
   for J:=0 to 3 do
    begin
      PreviousChunk.ReadBuffer(Index, SizeOf(Index));
      if J < 3 then
       Faces[I].VertIndex[J] := Index;
    end;
end;


procedure T3DObject.ReadVertices(PreviousChunk: TChunk);
var I:Integer;
    TempY:Single;
    FirstVertice:Boolean;
begin
  FirstVertice:=False;
  PreviousChunk.ReadBuffer(FVertexCount, 2);
  SetLength(Verts, FVertexCount);
  PreviousChunk.ReadRemainingBuffer(Verts[0]);
  for I:=0 to FVertexCount-1 do
   begin
     TempY:=Verts[I].Y;
     Verts[I].Y:=Verts[I].Z;
     Verts[I].Z:=-TempY;
     if not FirstVertice then
      begin
        FMaxVector:=Verts[I];
        FMinVector:=FMaxVector;
        FirstVertice:=True;
      end;
     FMaxVector.X:=Max(FMaxVector.X, Verts[I].X);
     FMaxVector.Y:=Max(FMaxVector.Y, Verts[I].Y);
     FMaxVector.Z:=Max(FMaxVector.Z, Verts[I].Z);
     FMinVector.X:=Min(FMinVector.X, Verts[I].X);
     FMinVector.Y:=Min(FMinVector.Y, Verts[I].Y);
     FMinVector.Z:=Min(FMinVector.Z, Verts[I].Z);
   end;
  FMidVector:=VectorSub(FMaxVector, FMinVector);
  //VectorAdd(FMaxVector, 0.0);
  //VectorAdd(FMinVector, -0.0);
end;


procedure T3DObject.AdjustNormals;
var V1, V2, Normal :TVector3D;
    TempNormals:array of TVector3D;
    VPoly:array[0..2] of TVector3D;
    I, Shared, J:Integer;
    VSum, VZero:TVector3D;
begin
  SetLength(TempNormals, FaceCount);
  SetLength(Normals, VertexCount);

  for I:=0 to FaceCount-1 do
   begin
     vPoly[0]:=Verts[Faces[I].VertIndex[0]];
     vPoly[1]:=Verts[Faces[I].VertIndex[1]];
     vPoly[2]:=Verts[Faces[I].VertIndex[2]];

     V1 := VectorSub(vPoly[0], vPoly[2]);
     V2 := VectorSub(vPoly[2], vPoly[1]);

     Normal:=VectorCrossProduct(V1, V2);
     TempNormals[I]:=Normal;
     // VectorNormalize(Normal);
   end;

  VectorClear(vSum);
  VectorClear(VZero);
  Shared:=0;

  for I:=0 to VertexCount-1 do
   begin
     for J:=0 to FaceCount-1 do
      if (Faces[J].VertIndex[0] = I) or (Faces[J].VertIndex[1] = I) or
         (Faces[J].VertIndex[2] = I) then
       begin
         VSum:=VectorAdd(VSum, TempNormals[J]);
         Inc(Shared);
       end;

     Normals[I]:=VectorDivide(vSum, -Shared);
     VectorNormalize(Normals[I]);
     vSum:=vZero;
     Shared:=0;
   end;

  Finalize(TempNormals);
end;


procedure T3DObject.Draw;
var F, iVertex, PointIndex:Integer;
begin
//  FTransformList.Push;
  if FSelected then
   DrawBox;
  Material.SetMaterial;
  glPushName(FObjectIndex);
  glBegin(FRMode);
  if not Material.HasTexture then glColor(Material.Diffuse.Vector.Red, Material.Diffuse.Vector.Green, Material.Diffuse.Vector.Blue, Material.Diffuse.Vector.Alpha);
    for F:=0 to FaceCount-1 do
     for iVertex:=0 to 2 do
      begin
        PointIndex:=Faces[F].VertIndex[iVertex];
        glNormal3f(Normals[PointIndex].X, Normals[PointIndex].Y, Normals[PointIndex].Z);
//        if Material.HasTexture then glTexCoord2f(TexVerts[PointIndex].X, TexVerts[PointIndex].Y);
        glVertex3f(Verts[PointIndex].X, Verts[PointIndex].Y, Verts[PointIndex].Z);
      end;
  glEnd;
  glPopName;
//  FTransformList.Pop;
end;


procedure T3DObject.DrawBox;
//var OldLineWidth:Single;
begin
  //glGetFloatv(GL_LINE_WIDTH, @OldLineWidth);
  glDisable(GL_TEXTURE_2D);
  glDisable(GL_LIGHTING);
  glColor3ub(0, 255, 0);
  //glLineWidth(1);

  glBegin(GL_LINE_STRIP);
    glVertex3f(FMaxVector.X, FMaxVector.Y, FMaxVector.Z);
    glVertex3f(FMaxVector.X-FMidVector.X, FMaxVector.Y, FMaxVector.Z);
    glVertex3f(FMaxVector.X-FMidVector.X, FMaxVector.Y, FMaxVector.Z-FMidVector.Z);
    glVertex3f(FMaxVector.X, FMaxVector.Y, FMaxVector.Z-FMidVector.Z);
    glVertex3f(FMaxVector.X, FMaxVector.Y, FMaxVector.Z);
  glEnd;

  glBegin(GL_LINE_STRIP);
    glVertex3f(FMaxVector.X, FMaxVector.Y, FMaxVector.Z);
    glVertex3f(FMaxVector.X, FMaxVector.Y-FMidVector.Y, FMaxVector.Z);
    glVertex3f(FMaxVector.X, FMaxVector.Y-FMidVector.Y, FMaxVector.Z-FMidVector.Z);
    glVertex3f(FMaxVector.X, FMaxVector.Y, FMaxVector.Z-FMidVector.Z);
    glVertex3f(FMaxVector.X, FMaxVector.Y, FMaxVector.Z);
  glEnd;

  glBegin(GL_LINE_STRIP);
    glVertex3f(FMaxVector.X, FMinVector.Y, FMaxVector.Z);
    glVertex3f(FMaxVector.X-FMidVector.X, FMinVector.Y, FMaxVector.Z);
    glVertex3f(FMaxVector.X-FMidVector.X, FMinVector.Y, FMaxVector.Z-FMidVector.Z);
    glVertex3f(FMaxVector.X, FMinVector.Y, FMaxVector.Z-FMidVector.Z);
    glVertex3f(FMaxVector.X, FMinVector.Y, FMaxVector.Z);
  glEnd;

  glBegin(GL_LINE_STRIP);
    glVertex3f(FMaxVector.X-FMidVector.X, FMaxVector.Y, FMaxVector.Z);
    glVertex3f(FMaxVector.X-FMidVector.X, FMaxVector.Y-FMidVector.Y, FMaxVector.Z);
    glVertex3f(FMaxVector.X-FMidVector.X, FMaxVector.Y-FMidVector.Y, FMaxVector.Z-FMidVector.Z);
    glVertex3f(FMaxVector.X-FMidVector.X, FMaxVector.Y, FMaxVector.Z-FMidVector.Z);
    glVertex3f(FMaxVector.X-FMidVector.X, FMaxVector.Y, FMaxVector.Z);
  glEnd;

  glEnable(GL_LIGHTING);
  //glLineWidth(OldLineWidth);
end;



procedure T3DObject.SetRenderMode(const Value: TRenderMode);
begin
  FRenderMode := Value;
  case FRenderMode of
    rmTriangles:FRMode:=GL_TRIANGLES;
    rmLines:FRMode:=GL_LINES;
    rmPoints:FRMode:=GL_POINTS;
  end;
end;



// ************************** END T3DOBJECT **********************************

// ************************** T3DMODEL ***************************************



{ T3DModel }


constructor T3DModel.Create;
begin
  inherited;
end;


destructor T3DModel.Destroy;
begin
  Clear;
  inherited;
end;


procedure T3DModel.Clear;
var I:Integer;
begin
  for I:=0 to ObjectCount-1 do
   Objects[I].Free;
  Finalize(Objects);
  Finalize(FMaterials);
end;

function T3DModel.AddMaterial: TMaterial;
var C:Integer;
begin
  Result:=TMaterial.Create;
  C:=MaterialCount;
  SetLength(FMaterials, C + 1);
  FMaterials[C]:=Result;
end;

function T3DModel.AddObject: T3DObject;
var C, I:Integer;
begin
  Result:=T3DObject.Create;
  C:=ObjectCount;
  I:=C + 1;
  Result.FObjectIndex:=I;
  SetLength(Objects, I);
  Objects[C]:=Result;
end;


function T3DModel.GetMaterialCount: Integer;
begin
  Result:=Length(FMaterials);
end;

function T3DModel.GetObjectCount: Integer;
begin
  Result:=Length(Objects);
end;

function T3DModel.LoadFromFile(const FileName:string): Boolean;
begin
  Clear;
  FRootChunk:=TChunk.Create(Self);
  FFileHandle:=FileOpen(FileName, fmOpenRead);
  if FFileHandle < 0 then
   begin
     Result:=False;
     CleanUp;
     Exit;
   end;

  FRootChunk.FileHandle:=FFileHandle;
  FRootChunk.Read;
  if FRootChunk.Id <> M3DMAGIC then
   begin
     Result:=False;
     CleanUp;
     Exit;
   end;

  FRootChunk.ProcessNextChunk(FRootChunk);
  ComputeNormals;
  CleanUp;
  Result:=True;
end;

procedure T3DModel.CleanUp;
var I:Integer;
begin
  for I:=0 to MaterialCount-1 do
   FMaterials[I].Free;
  Finalize(FMaterials);
  FRootChunk.Free;
  FRootChunk:=nil;
  FileClose(FFileHandle);
end;

procedure T3DModel.ComputeNormals;
var I:Integer;
begin
  for I:=0 to ObjectCount-1 do
   Objects[I].AdjustNormals;
end;

procedure T3DModel.Draw;
var I:Integer;
begin
  for I:=0 to ObjectCount-1 do
   if Objects[I].Visible then
    Objects[I].Draw;
end;


function T3DModel.FindObject(const aName: string): T3DObject;
var I:Integer;
begin
  Result:=nil;
  for I:=0 to ObjectCount-1 do
   if SameText(aName, Objects[I].ObjectName) then
    begin
      Result:=Objects[I];
      Break;
    end;
end;



function T3DModel.Select(const Index: Integer): T3DObject;
var I:Integer;
begin
  for I:=0 to ObjectCount-1 do
   Objects[I].Selected:=False;
  if Index > 0 then
   begin
     Result:=Objects[Index - 1];
     Result.Selected:=True;
   end
    else
     Result:=nil;
end;


procedure T3DModel.VisibleAll;
var I:Integer;
begin
  for I:=0 to ObjectCount-1 do
   Objects[I].Visible:=True;
end;

{ TTransformation }

constructor TTransformation.Create;
begin
  inherited;
  FEnabled:=True;
end;


procedure TTransformation.Apply;
begin
  if FEnabled then
   case FTransformType of
     ttRotate    : glRotate(FAngle, FX, FY, FZ);
     ttTranslate : glTranslate(FX, FY, FZ);
     ttScale     : glScale(FX, FY, FZ);
   end;
end;


procedure TTransformation.Restore;
begin
  if FEnabled then
   glPopMatrix;
end;

{ TTransformList }


{constructor TTransformList.Create;
begin
  inherited;
  FEnabled:=True;
end;


destructor TTransformList.Destroy;
var I:Integer;
begin
  for I:=0 to Count-1 do
   TTransformation(Items[I]).Free;
  Clear;
  inherited;
end;



function TTransformList.AddTransform: TTransformation;
begin
  Result:=TTransformation.Create;
  Add(Result);
end;

function TTransformList.AddTransformEx(const _TransformType: TTransformType;
  const _Angle, _X, _Y, _Z: Single): TTransformation;
begin
  Result:=TTransformation.Create;
  with Result do
   begin
     TransformType:=_TransformType;
     Angle:=_Angle;
     X:=_X;
     Y:=_Y;
     Z:=_Z;
   end;
  Add(Result);
end;


procedure TTransformList.Push;
var I:Integer;
begin
  if FEnabled then
   for I:=0 to Count-1 do
    begin
      if I=0 then
       glPushMatrix;
      TTransformation(Items[I]).Apply;
    end;
end;


procedure TTransformList.Pop;
var I:Integer;
begin
  if FEnabled then
   for I:=Count-1 downto 0 do
    begin
      TTransformation(Items[I]).Restore;
      if I=0 then
       glPopMatrix;
    end;
end;}




{ TMaterialProperties }

constructor TMaterialProperties.Create(glDefFace, glDefType:Cardinal);
begin
  inherited Create;
  ZeroMemory(@FVector, SizeOf(TVector4f));
  FglDefFace:=glDefFace;
  FglDefType:=glDefType;
end;

destructor TMaterialProperties.Destroy;
begin
  inherited;
end;


procedure TMaterialProperties.SetRGBA(const R, G, B, Alpha: Single);
begin
  FVector.Red:=R;
  FVector.Green:=G;
  FVector.Blue:=B;
  FVector.Alpha:=Alpha;
end;


function TMaterialProperties.ToString: string;
begin
  with FVector do
   Result:=Format('R%.1f - G%.1f - B%.1f - A%.1f', [Red, Green, Blue, Alpha]);
end;


procedure TMaterialProperties.Apply;
begin
  glMaterialfv(FglDefFace, FglDefType, @FVector);
end;


function TMaterialProperties.GetColor: TColor;
begin
  Result:=Vector4fToColor(FVector);
end;


procedure TMaterialProperties.SetColor(const Value: TColor);
var CurAlpha:Single;
begin
  CurAlpha:=FVector.Alpha;
  FVector:=ColorToVector4f(Value, CurAlpha);
end;


end.

