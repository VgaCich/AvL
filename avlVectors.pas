// ***************************************************************************
// ************************** VECTORS UNIT ***********************************
// **********************   Juan José Montero  *******************************
// ******************* juanjo.montero@telefonica.net *************************
// *********************** Release 19/11/2003 ********************************
// ***************************************************************************

unit avlVectors;

interface

uses
  Windows;

type
  PVector2D = ^TVector2D;
  TVector2D = record
    X, Y: Single;
  end;
  PVector3D = ^TVector3D;
  TVector3D = record
    X, Y, Z: Single;
  end;
  PByteColor = ^TByteColor;
  TByteColor = record
    Red, Green, Blue: Byte;
  end;
  PVector4D = ^TVector4D;
  TVector4D = record
    X, Y, Z, W: Single;
  end;
  PMatrix4D = ^TMatrix4D;
  TMatrix4D = array[0..3, 0..3] of Single;

function Vector2D(Value: Single): TVector2D; overload;
function Vector2D(X, Y: Single): TVector2D; overload;
function Vector3D(Value: Single): TVector3D; overload;
function Vector3D(X, Y, Z: Single): TVector3D; overload;
function Vector3D(const V: TVector4D): TVector3D; overload;
function Vector4D(Value: Single): TVector4D; overload;
function Vector4D(X, Y, Z, W: Single): TVector4D; overload;
procedure VectorClear(var Vector: TVector2D); overload;
procedure VectorClear(var Vector: TVector3D); overload;
procedure VectorClear(var Vector: TVector4D); overload;
procedure VectorInvert(var Vector: TVector3D);
function VectorSize(const Vector: TVector2D): Single; overload;
function VectorSize(const Vector: TVector3D): Single; overload;
function VectorNormalize(var Vector: TVector2D): Single; overload;
function VectorNormalize(var Vector: TVector3D): Single; overload;
function VectorSquareNorm(const Vector: TVector3D): Single;
function VectorAdd(const Vector1, Vector2: TVector3D): TVector3D; overload;
procedure VectorAdd(var Vector: TVector3D; Value: Single); overload;
function VectorSub(const Vector1, Vector2: TVector3D): TVector3D; overload;
procedure VectorSub(var Vector: TVector3D; Value: Single); overload;
function VectorDivide(const Vector1, Vector2: TVector3D): TVector3D; overload;
function VectorDivide(const Vector: TVector3D; Value: Single): TVector3D; overload;
function VectorMultiply(const Vector1, Vector2: TVector3D): TVector3D; overload;
function VectorMultiply(const Vector: TVector3D; Value: Single): TVector3D; overload;
function VectorMultiply(const Vector: TVector3D; const Matrix: TMatrix4D): TVector3D; overload;
procedure VectorScale(var Vector: TVector2D; Value: Single); overload;
procedure VectorScale(var Vector: TVector3D; Value: Single); overload;
procedure VectorScale(var Vector: TVector4D; Value: Single); overload;
function VectorCrossProduct(const Vector1, Vector2: TVector3D): TVector3D;
function VectorDotProduct(const Vector1, Vector2: TVector3D): Single;
procedure VectorRotateX(Angle: Single; var Vector: TVector3D);
procedure VectorRotateY(Angle: Single; var Vector: TVector3D);
procedure VectorRotateZ(Angle: Single; var Vector: TVector3D);
function VectorIsEqual(const Vector1, Vector2: TVector3D): Boolean;
function VectorIsGreater(const Vector1, Vector2: TVector3D): Boolean;
function VectorIsGreaterEqual(const Vector1, Vector2: TVector3D): Boolean;
function VectorIsLess(const Vector1, Vector2: TVector3D): Boolean;
function VectorIsLessEqual(const Vector1, Vector2: TVector3D): Boolean;
function ByteColorTo4f(const BytesToWrap: TByteColor): TVector4D;
function Color4fToByte(const BytesToWrap: TVector4D): TByteColor;
function TriangleNormal(const Vert1: TVector3D; Vert2, Vert3: TVector3D): TVector3D;
function TriangleAngle(const Vert1: TVector3D; Vert2, Vert3: TVector3D): Single;

implementation

uses
  avlMath;

function Vector2D(Value: Single): TVector2D;
begin
  Result.X := Value;
  Result.Y := Value;
end;

function Vector2D(X, Y: Single): TVector2D;
begin
  Result.X := X;
  Result.Y := Y;
end;

function Vector3D(Value: Single): TVector3D;
begin
  Result.X := Value;
  Result.Y := Value;
  Result.Z := Value;
end;

function Vector3D(X, Y, Z: Single): TVector3D;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;

function Vector3D(const V: TVector4D): TVector3D;
begin
  Move(V, Result, SizeOf(Result));
end;

function Vector4D(Value: Single): TVector4D; overload;
begin
  Result.X := Value;
  Result.Y := Value;
  Result.Z := Value;
  Result.W := Value;
end;

function Vector4D(X, Y, Z, W: Single): TVector4D; overload;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
  Result.W := W;
end;

procedure VectorClear(var Vector: TVector2D);
begin
  ZeroMemory(@Vector, SizeOf(TVector2D));
end;

procedure VectorClear(var Vector: TVector3D);
begin
  ZeroMemory(@Vector, SizeOf(TVector3D));
end;

procedure VectorClear(var Vector: TVector4D);
begin
  ZeroMemory(@Vector, SizeOf(TVector4D));
end;

procedure VectorInvert(var Vector: TVector3D);
begin
  Vector.X := -Vector.X;
  Vector.Y := -Vector.Y;
  Vector.Z := -Vector.Z;
end;

function VectorSize(const Vector: TVector2D): Single;
begin
  Result := Sqrt((Vector.X * Vector.X) + (Vector.Y * Vector.Y));
end;

function VectorSize(const Vector: TVector3D): Single;
begin
  Result := Sqrt((Vector.X * Vector.X) + (Vector.Y * Vector.Y) + (Vector.Z * Vector.Z));
end;


{function VectorNormalize(var Vector:TVector3D):Single;
var ScaleFactor:Single;
begin
  Result:=VectorSize(Vector);
  if (Result=0.0) then
   Exit;
  ScaleFactor:=1.0/Result;

  Vector.X := Vector.X * ScaleFactor;
  Vector.Y := Vector.Y * ScaleFactor;
  Vector.Z := Vector.Z * ScaleFactor;
end;}

function VectorNormalize(var Vector: TVector2D): Single;
begin
  Result := VectorSize(Vector);
  if (Result = 0.0) then
    Exit;
  Vector.X := Vector.X / Result;
  Vector.Y := Vector.Y / Result;
end;

function VectorNormalize(var Vector: TVector3D): Single;
begin
  Result := VectorSize(Vector);
  if (Result = 0.0) then
    Exit;
  Vector.X := Vector.X / Result;
  Vector.Y := Vector.Y / Result;
  Vector.Z := Vector.Z / Result;
end;

function VectorSquareNorm(const Vector: TVector3D): Single;
begin
  Result := Vector.X * Vector.X;
  Result := Result + (Vector.Y * Vector.Y);
  Result := Result + (Vector.Z * Vector.Z);
end;

function VectorAdd(const Vector1, Vector2: TVector3D): TVector3D; overload;
begin
  Result.X := Vector1.X + Vector2.X;
  Result.Y := Vector1.Y + Vector2.Y;
  Result.Z := Vector1.Z + Vector2.Z;
end;

procedure VectorAdd(var Vector: TVector3D; Value: Single); overload;
begin
  Vector.X := Vector.X + Value;
  Vector.Y := Vector.Y + Value;
  Vector.Z := Vector.Z + Value;
end;

function VectorSub(const Vector1, Vector2: TVector3D): TVector3D; overload;
begin
  Result.X := Vector1.X - Vector2.X;
  Result.Y := Vector1.Y - Vector2.Y;
  Result.Z := Vector1.Z - Vector2.Z;
end;

procedure VectorSub(var Vector: TVector3D; Value: Single); overload;
begin
  Vector.X := Vector.X - Value;
  Vector.Y := Vector.Y - Value;
  Vector.Z := Vector.Z - Value;
end;

function VectorDivide(const Vector1, Vector2: TVector3D): TVector3D; overload
begin
  Result.X := Vector1.X / Vector2.X;
  Result.Y := Vector1.Y / Vector2.Y;
  Result.Z := Vector1.Z / Vector2.Z;
end;

function VectorDivide(const Vector: TVector3D; Value: Single): TVector3D; overload;
begin
  Result.X := Vector.X / Value;
  Result.Y := Vector.Y / Value;
  Result.Z := Vector.Z / Value;
end;

function VectorMultiply(const Vector1, Vector2: TVector3D): TVector3D;// overload;
begin
  Result.X := Vector1.X * Vector2.X;
  Result.Y := Vector1.Y * Vector2.Y;
  Result.Z := Vector1.Z * Vector2.Z;
end;

function VectorMultiply(const Vector: TVector3D; Value: Single): TVector3D;
begin
  Result.X := Vector.X * Value;
  Result.Y := Vector.Y * Value;
  Result.Z := Vector.Z * Value;
end;

function VectorMultiply(const Vector: TVector3D; const Matrix: TMatrix4D): TVector3D;
begin
  Result.X := Matrix[0, 0] * Vector.X + Matrix[1, 0] * Vector.Y + Matrix[2, 0] * Vector.Z + Matrix[3, 0];
  Result.Y := Matrix[0, 1] * Vector.X + Matrix[1, 1] * Vector.Y + Matrix[2, 1] * Vector.Z + Matrix[3, 1];
  Result.Z := Matrix[0, 2] * Vector.X + Matrix[1, 2] * Vector.Y + Matrix[2, 2] * Vector.Z + Matrix[3, 2];
end;

procedure VectorScale(var Vector: TVector2D; Value: Single);
begin
  Vector.X := Vector.X * Value;
  Vector.Y := Vector.Y * Value;
end;

procedure VectorScale(var Vector: TVector3D; Value: Single);
begin
  Vector.X := Vector.X * Value;
  Vector.Y := Vector.Y * Value;
  Vector.Z := Vector.Z * Value;
end;

procedure VectorScale(var Vector: TVector4D; Value: Single);
begin
  Vector.X := Vector.X * Value;
  Vector.Y := Vector.Y * Value;
  Vector.Z := Vector.Z * Value;
  Vector.W := Vector.W * Value;
end;

function VectorCrossProduct(const Vector1, Vector2: TVector3D): TVector3D;
begin
  Result.X := (Vector1.Y * Vector2.Z) - (Vector1.Z * Vector2.Y);
  Result.Y := (Vector1.Z * Vector2.X) - (Vector1.X * Vector2.Z);
  Result.Z := (Vector1.X * Vector2.Y) - (Vector1.Y * Vector2.X);
end;

function VectorDotProduct(const Vector1, Vector2: TVector3D): Single;
begin
  Result := (Vector1.X * Vector2.X) + (Vector1.Y * Vector2.Y) + (Vector1.Z * Vector2.Z);
end;

procedure VectorRotateX(Angle: Single; var Vector: TVector3D);
var
  Y0, Z0: Single;
  Radians: Single;
begin
  Y0 := Vector.Y;
  Z0 := Vector.Z;
  Radians := DegToRad(Angle);
  Vector.Y := (Y0 * Cos(Radians)) - (Z0 * Sin(Radians));
  Vector.Z := (Y0 * Sin(Radians)) + (Z0 * Cos(Radians));
end;

procedure VectorRotateY(Angle: Single; var Vector: TVector3D);
var
  X0, Z0: Single;
  Radians: Single;
begin
  X0 := Vector.X;
  Z0 := Vector.Z;
  Radians := DegToRad(Angle);
  Vector.X := (X0 * Cos(Radians)) - (Z0 * Sin(Radians));
  Vector.Z := (X0 * Sin(Radians)) + (Z0 * Cos(Radians));
end;

procedure VectorRotateZ(Angle: Single; var Vector: TVector3D);
var
  X0, Y0: Single;
  Radians: Single;
begin
  X0 := Vector.X;
  Y0 := Vector.Y;
  Radians := DegToRad(Angle);
  Vector.X := (X0 * Cos(Radians)) - (Y0 * Sin(Radians));
  Vector.Y := (X0 * Sin(Radians)) + (Y0 * Cos(Radians));
end;

function VectorIsEqual(const Vector1, Vector2: TVector3D): Boolean;
begin
  Result := (Vector1.X = Vector2.X) and (Vector1.Y = Vector2.Y) and (Vector1.Z = Vector2.Z);
end;

function VectorIsGreater(const Vector1, Vector2: TVector3D): Boolean;
begin
  Result := (Vector1.X > Vector2.X) and (Vector1.Y > Vector2.Y) and (Vector1.Z > Vector2.Z);
end;

function VectorIsGreaterEqual(const Vector1, Vector2: TVector3D): Boolean;
begin
  Result := (Vector1.X >= Vector2.X) and (Vector1.Y >= Vector2.Y) and (Vector1.Z >= Vector2.Z);
end;

function VectorIsLess(const Vector1, Vector2: TVector3D): Boolean;
begin
  Result := (Vector1.X < Vector2.X) and (Vector1.Y < Vector2.Y) and (Vector1.Z < Vector2.Z);
end;

function VectorIsLessEqual(const Vector1, Vector2: TVector3D): Boolean;
begin
  Result := (Vector1.X <= Vector2.X) and (Vector1.Y <= Vector2.Y) and (Vector1.Z <= Vector2.Z);
end;

function ByteColorTo4f(const BytesToWrap: TByteColor): TVector4D;
const
  Scaler: Single = 1.0 / 255.0;
begin
  Result.X := BytesToWrap.Red * Scaler;
  Result.Y := BytesToWrap.Green * Scaler;
  Result.Z := BytesToWrap.Blue * Scaler;
  Result.W := 1.0;
end;

function Color4fToByte(const BytesToWrap: TVector4D): TByteColor;
begin
  Result.Red := Trunc(BytesToWrap.X * 255);
  Result.Green := Trunc(BytesToWrap.Y * 255);
  Result.Blue := Trunc(BytesToWrap.Z * 255);
end;

function TriangleNormal(const Vert1: TVector3D; Vert2, Vert3: TVector3D): TVector3D;
begin
  Vert2 := VectorSub(Vert1, Vert2);
  Vert3 := VectorSub(Vert1, Vert3);
  Result := VectorCrossProduct(Vert2, Vert3);
  VectorNormalize(Result);
end;

function TriangleAngle(const Vert1: TVector3D; Vert2, Vert3: TVector3D): Single;
begin
  Vert2 := VectorSub(Vert1, Vert2);
  Vert3 := VectorSub(Vert1, Vert3);
  Result := arccos(VectorDotProduct(Vert2, Vert3) / (VectorSize(Vert2) * VectorSize(Vert3)));
end;

end.

