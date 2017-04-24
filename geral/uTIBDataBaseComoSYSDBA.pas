unit uTIBDataBaseComoSYSDBA;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Db, DBTables, DBClient, Provider, IBCustomDataSet, IBStoredProc,
  IBDatabase, IBQuery, MemTableEh, EhLibMTE, ImgList, IBDatabaseInfo, SqlExpr;

TYPE TIBDataBaseComoSYSDBA = Class
  private
    parametrosAntigos:String;
    alterouOsParametros:Boolean;
    bancoSysdba:TIBDataBase;
  public
    //CONSTRUTOR DA CLASSE QUE RECEBE COMO PARAMETOR O BANCO QUE SERÁ TRANSFORMADO EM SYSDBA E A SUA SENHA
    constructor create(banco:TIBDataBase;senhaSysdba:string);
    //FUNÇÃO QUE DEVE SER CHAMADA APÓS A UTILIZAÇÃO DO BANCO EM MODO SYSDBA
    //PARA RETORNAR AO MODO USUARIO ANTIGO
    function voltaAntigo():boolean;
end;

implementation

{ TIBDataBaseComoSYSDBA }

constructor TIBDataBaseComoSYSDBA.create(banco:TIBDataBase;senhaSysdba:string);
begin
  bancoSysdba := banco;
  if Pos('sysdba',banco.Params.Text)<=0 then //ESTA CONEXÃO NÃO É COM SYSDBA
  begin
    alterouOsParametros := true;
    parametrosAntigos := bancoSysdba.Params.Text;
    if bancoSysdba.Connected then
      bancoSysdba.close;
    bancoSysdba.Params.Clear;
    bancoSysdba.Params.Add('user_name=SYSDBA');
    bancoSysdba.Params.Add('password='+senhaSysdba+'');
    bancoSysdba.Params.Add('sql_role_name=TESTEROLE');
    bancoSysdba.Open;
  end
  else
    alterouOsParametros := false;
end;

function TIBDataBaseComoSYSDBA.voltaAntigo: boolean;
begin
  try
    if alterouOsParametros then
    begin
      if bancoSysdba.Connected then
        bancoSysdba.close;
      bancoSysdba.Params.Clear;
      bancoSysdba.Params.Add(parametrosAntigos);
      bancoSysdba.Open;
    end;
    result := true;
  except
    result := false;
  end;
end;

end.
