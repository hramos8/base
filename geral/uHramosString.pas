unit uHramosString;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, Dialogs,
  StdCtrls;

function hramosSplit(strOriginal:String; corteEm:char):TStringList;

implementation
function hramosSplit(strOriginal:String; corteEm:char):TStringList;
var strlRetorno:TStringList;
var aux:string;
var i:integer;
begin
  aux := '';
  strlRetorno := TStringList.Create;
  for i:=1 to length(strOriginal) do
  begin
    if strOriginal[i] = corteEm then
    begin
      strlRetorno.Add(aux);
      aux:='';
    end
    else
    begin
      aux := aux+strOriginal[i];
    end;
  end;
  strlRetorno.Add(aux);
  result := strlretorno;
end;
end.
 