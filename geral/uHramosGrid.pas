unit uHramosGrid;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, DBClient, cxGridLevel, cxClasses,
  cxControls, cxGridCustomView, cxGrid, StdCtrls, Buttons;

//SALVA A FORMATA플O DE UM GRID, LEVA EM CONSIDERA플O O NOME DO GRID, DO FORM E DO USUARIO
procedure hramosSalvaGridFormata(grid:TDBgrid; form:Tform; user:String);overload;
//CARREGA A FORMATA플O DO GRID SALVO,LEVA EM CONSIDERA플O O NOME DO GRID, DO FORM E DO USUARIO
procedure hramosCarregaGridFormata(grid:TDBgrid; form:Tform; user:String);overload;

procedure hramosCarregaGridFormata(grid:TDBgrid; form:string; user:String);overload;

//DEVOLVE A FORMATA플O DEFAULT DO GRID, REMOVENDO O QUE EXISTE
procedure hramosGridFormataDefault(grid:TDBgrid; form:Tform; user:String);overload;

//SALVA A FORMATA플O DE UM TcxGridDBTableView, LEVA EM CONSIDERA플O O NOME DO GRID, DO FORM E DO USUARIO
procedure hramosSalvaGridFormata(grid:TcxGridDBTableView; form:Tform; user:String);overload;
//CARREGA A FORMATA플O DE UM TcxGridDBTableView, LEVA EM CONSIDERA플O O NOME DO GRID, DO FORM E DO USUARIO
procedure hramosCarregaGridFormata(grid:TcxGridDBTableView; form:Tform; user:String);overload;

procedure hramosCarregaGridFormata(grid:TcxGridDBTableView; form:String; user:String);overload;

//DEVOLVE A FORMATA플O DEFAULT DO GRID, REMOVENDO O QUE EXISTE
procedure hramosGridFormataDefault(grid:TcxGridDBTableView; form:Tform; user:String);overload;

implementation

uses uHramosString;

procedure hramosSalvaGridFormata(grid:TDBgrid; form:Tform; user:String);overload;
var local:string;
begin
  local := ExtractFilePath(application.ExeName)+'formatTab\';
  if not(DirectoryExists(PAnsiChar(AnsiString(pchar(local))))) then
    CreateDir(local);
  local := local+form.Name+grid.Name+user;

  grid.Columns.SaveToFile(PAnsiChar(AnsiString(pchar(local))));
end;

procedure hramosCarregaGridFormata(grid:TDBgrid; form:string; user:String);overload;
var local:string;
begin
  local := ExtractFilePath(application.ExeName);
  local := local+'formatTab\';
  local := local+form;
  local := local+grid.Name;
  local := local+user;
  if FileExists(local) then
    grid.Columns.LoadFromFile(local);
end;

procedure hramosCarregaGridFormata(grid:TDBgrid; form:Tform; user:String);overload;
var local:string;
begin
  local := ExtractFilePath(application.ExeName);
  local := local+'formatTab\';
  local := local+String(form.Name);
  local := local+grid.Name;
  local := local+user;
  if FileExists(local) then
    grid.Columns.LoadFromFile(local);
end;

procedure hramosGridFormataDefault(grid:TDBgrid; form:Tform; user:String);overload;
var local:string;
var data:Tdatasource;
var i:integer;
begin
  local := ExtractFilePath(application.ExeName)+'formatTab\'+form.Name+grid.Name+user;
  if FileExists(local) then
  begin
    DeleteFile(local);
  end;
END;

procedure hramosSalvaGridFormata(grid:TcxGridDBTableView; form:Tform; user:String);overload;
var local:string;
var sl:Tstringlist;
var i:integer;
begin
  local := ExtractFilePath(application.ExeName)+'formatTab\';
  if not(DirectoryExists(PAnsiChar(AnsiString(pchar(local))))) then
    CreateDir(local);
  local := local+form.Name+grid.Name+user;

  sl := TStringList.Create;
  for i:=0 to grid.ColumnCount-1 do
  begin
    sl.Add(inttostr(grid.Columns[i].ID)+'|'+
           inttostr(grid.Columns[i].Index)+'|'+
           inttostr(grid.Columns[i].Width)+'|'+
           BoolToStr(grid.Columns[i].Visible));
  end;
  sl.SaveToFile(PAnsiChar(AnsiString(pchar(local))));
end;

procedure hramosCarregaGridFormata(grid:TcxGridDBTableView; form:String; user:String);overload;
var local:string;
var sl,slaux:TStringList;
var i,j:integer;
begin
  local := ExtractFilePath(application.ExeName)+'formatTab\'+form+grid.Name+user;
  if FileExists(local) then
  begin
    sl := TStringList.Create;
    slaux:=tStringList.Create;
    sl.LoadFromFile(local);
    for i:=0 to sl.Count-1 do
    begin
      slaux.Clear;
      slaux := hramosSplit(sl[i],'|');
      for j:=0 to grid.ColumnCount-1 do
      begin
        if grid.Columns[j].ID = strtoint(slaux[0]) then
        begin
          grid.Columns[j].Width := strtoint(slaux[2]);
          grid.Columns[j].visible := StrToBool(slaux[3]);
          grid.Columns[j].Index := strtoint(slaux[1]);
          break;
        end;
      end;
    end;
  end;
end;

procedure hramosCarregaGridFormata(grid:TcxGridDBTableView; form:Tform; user:String);overload;
var local:string;
var sl,slaux:TStringList;
var i,j:integer;
begin
  local := ExtractFilePath(application.ExeName)+'formatTab\'+form.Name+grid.Name+user;
  if FileExists(local) then
  begin
    sl := TStringList.Create;
    slaux:=tStringList.Create;
    sl.LoadFromFile(local);
    for i:=0 to sl.Count-1 do
    begin
      slaux.Clear;
      slaux := hramosSplit(sl[i],'|');
      for j:=0 to grid.ColumnCount-1 do
      begin
        if grid.Columns[j].ID = strtoint(slaux[0]) then
        begin
          grid.Columns[j].Width := strtoint(slaux[2]);
          grid.Columns[j].visible := StrToBool(slaux[3]);
          grid.Columns[j].Index := strtoint(slaux[1]);
          break;
        end;
      end;
    end;
  end;
end;

procedure hramosGridFormataDefault(grid:TcxGridDBTableView; form:Tform; user:String);overload;
var local:string;
begin
  local := ExtractFilePath(application.ExeName)+'formatTab\'+form.Name+grid.Name+user;
  if FileExists(local)then
    DeleteFile(local);
end;

end.
