unit AvlFMOD;

{ 
        (c) coban2k
        http://www.cobans.net
}

interface

function SongLoadFromFile(FileName: PChar): Integer; cdecl; external 'minifmod.dll';
function SongLoadFromResource(FileName: PChar): Integer; cdecl; external 'minifmod.dll';
procedure SongPlay(hMod: Integer); cdecl; external 'minifmod.dll';
procedure SongStop(hMod: Integer); cdecl; external 'minifmod.dll';
procedure SongFree(hMod: Integer); cdecl; external 'minifmod.dll';
function SongGetOrder(hMod: Integer): Integer; cdecl; external 'minifmod.dll';
function SongGetRow(hMod: Integer): Integer; cdecl; external 'minifmod.dll';
function SongGetTime(hMod: Integer): Integer; cdecl; external 'minifmod.dll';

implementation

end.
