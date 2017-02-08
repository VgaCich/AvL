{*******************************************************}
{               RichEdit Syntax HighLight               }
{                     version 2.0                       }
{ Author:                                               }
{ Serhiy Perevoznyk                                     }
{ serge_perevoznyk@hotmail.com                          }
{                                                       }
{*******************************************************}

{The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: psvSyntax.pas, released 2002-30-04
Initial Author of these files is Serhiy Perevoznyk.
All Rights Reserved.}

unit psvSyntax;

Interface
uses
  Windows, {SysUtils, Classes, Graphics} Avl;

type
  TpsvRTFSyntax = class
  private
    FHeader : string;
    FFont : string;
    FColorTable : string;
  protected
    property Header : string read FHeader write FHeader;
    property Font : string read FFont write FFont;
    property ColorTable : string read FColorTable write FColorTable;
    procedure  PrepareToken(var AToken : string); virtual;
    function PrepareOutput(Attr : integer; AToken : string) : string; virtual;
    procedure Next; virtual;
    function GetEOL : boolean; virtual;
    function GetToken : string; virtual;
    function GetTokenAttribute : integer; virtual;
    function  ColorToStr(AColor: TColor): String; virtual;
    procedure SetLine(NewValue: string; LineNumber:Integer); virtual; 
  public
    constructor Create;
    procedure SetText(Atext : string); virtual;
    procedure CreateFontTable(const AFonts : array of TFont);
    procedure CreateColorTable(const AColors : array of TColor);
    procedure ConvertToRTFStream(AStream : TStream); virtual;
    function  ConvertToRTFString : string; virtual;
  end;

implementation

{ TpsvRTFSyntax }

function TpsvRTFSyntax.ColorToStr(AColor: TColor): String;
begin
 Result:='\red'+IntToStr(GetRValue(ColorToRGB(AColor)))+
          '\green'+IntToStr(GetGValue(ColorToRGB(AColor)))+
          '\blue'+IntToStr(GetBValue(ColorToRGB(AColor)))+';';

end;

procedure TpsvRTFSyntax.ConvertToRTFStream(AStream: TStream);
var
  Attr : integer;
  St : string;
  OutSt : string;
begin
  AStream.Write(FHeader[1],Length(FHeader));
  AStream.Write(FColorTable[1],Length(FColorTable));
  AStream.Write(FFont[1],Length(FFont));
  AStream.Write('\f2 ',4);
  While not GetEol do
   begin
     St := GetToken;
     Attr := GetTokenAttribute;
     PrepareToken(St);
     OutSt := PrepareOutput(Attr,St);
     if St = #13#10 then
      AStream.Write('\par ',4);
     AStream.Write(OutSt[1],Length(OutSt));
     Next;
   end;
  AStream.Write('\par }',6);
end;

function TpsvRTFSyntax.ConvertToRTFString: string;
var St : TStringStream;
begin
  St := TStringStream.Create('');
  ConvertToRTFStream(St);
  Result := St.DataString;
  St.Free;
end;

constructor TpsvRTFSyntax.Create;
begin
  inherited Create;
  FHeader := '{\rtf1\ansi\deff0\deftab720{\fonttbl{\f0\fswiss MS SansSerif;}{\f1\froman\fcharset2 Symbol;}{\f2\fmodern Courier New;}}'+#13+#10;
  FFont := '\deflang1033\pard\plain\f0\fs20';
  FColorTable := '';
end;

procedure TpsvRTFSyntax.CreateColorTable(const AColors: array of TColor);
var I : integer ;
begin
  FColorTable := '{\colortbl\red0\green0\blue0;';
  for I := 0 to Length(AColors) - 1 do
   FColorTable := FColorTable + ColorToStr(AColors[i]);
  FColorTable := FColorTable + '}'+ #13#10;
end;

procedure TpsvRTFSyntax.CreateFontTable(const AFonts: array of TFont);
begin
 //
end;

function TpsvRTFSyntax.GetEOL: boolean;
begin
 result := true;
end;

function TpsvRTFSyntax.GetToken: string;
begin
  result := '';
end;

function TpsvRTFSyntax.GetTokenAttribute: integer;
begin
  result := 0;
end;

function TpsvRTFSyntax.PrepareOutput(Attr: integer; AToken : string): string;
begin
  Result := Format('\cf%d %s',[Attr,AToken]);
end;

procedure TpsvRTFSyntax.PrepareToken(var AToken: string);
begin
  //
end;

procedure TpsvRTFSyntax.Next;
begin
 //
end;

procedure TpsvRTFSyntax.SetLine(NewValue: string; LineNumber:Integer); 
begin
 //
end;

procedure TpsvRTFSyntax.SetText(AText : string);
begin
  SetLine(AText,1);
end;

end.