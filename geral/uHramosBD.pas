unit uHramosBD;

interface
uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Db, DBTables, DBClient, Provider, IBCustomDataSet, IBStoredProc,
  IBDatabase, IBQuery, MemTableEh, EhLibMTE, ImgList, IBDatabaseInfo, SqlExpr;

//RETORNA UM CLIENTDATASET COM O RESULTADO DA SQL PASSADA COMO PARAMETRO
function hramosGetClient(SQL:String; banco:TIBDataBase):TClientDataSet;overload;
function hramosGetClient(SQL:String; banco:TSQLConnection):TClientDataSet;overload;

//FAZ A EXECUÇÃO E O COMMIT DA SQL PASSADA COMO PARAMETRO
function hramosExecutaSQL(SQL:String; banco:TIBDataBase):boolean;overload;
function hramosExecutaSQL(SQL:String; banco:TSQLConnection):boolean;overload;

//RETORNA O PRÓXIMO INDICE DA CHAVE PRIMÁRIA DA TABELA
function hramosProxIndice(tabela:String; banco:TIBDataBase):integer;

//FUNÇÃO QUE CRIA UM CAMPO NA TABELA, RETORNA TRUE SE O CAMPO FOI CRIADO
function hramosCriaCampo(tabela:string; campo:string; tipo:string; banco:TIBDataBase):boolean;

//FUNÇÃO QUE CRIA UMA TABELA NO BANCO, RETORNA TRUE SE A TABELA FOI CRIADA FOI CRIADO
//O PARAMETRO CAMPOS DEVE SER PASSADO DA SEGUINTE MANEIRA:
{ 'campo1 CHAR(10) NOT NULL PRIMARY KEY, campo2 CHAR(15), campo3 BLOB(50)' }
function hramosCriaTabela(tabela:string; campos:string; banco:TIBDataBase):boolean;

//RETORNA A EXISTENCIA OU NÃO DA TABELA
function hramosExisteTabela(tabela:string;banco:TIBDataBase):boolean;

//FUNÇÃO QUE RETORNA O NOME DA PRINCIPAL TABELA DA CONSULTA SQL
function hramosGetTabela(sql:string):string;

//FUNÇÃO QUE INFORMA SE O USUARIO TEM PERMISSÕES EM UMA DETERMINADA TABELA, AS PERMISSÕES SÃO:
// 'S' - SELECT
// 'U' - UPDATE
// 'D' - DELETE
// 'I' - INSERT
// 'R' - REFERENCE
function hramosUserTemPermissao(tabela, usuario, permissao:string; banco:TIBDataBase):boolean;

//RETORNA A REGRA DO BANCO DE DADOS À QUAL O USUARIO PERTENCE
function hramosRegraDoUsuario(usuario:string; banco:TIBDataBase):string;

//RETORNA OS USUARIOS DO BANCO DE DADOS QUE PERTENCER A REGRA PASSADA COMO PARAMETRO
function hramosUsuariosDaRegra(regra:string; banco:TIBDataBase):TStringlist;

//FAZ A INSERÇÃO DA CHAVE PRIMÁRIA
function hramosCriaChavePrimaria(tabela, campos:string; banco:TIBDataBase):Boolean;

//FAZ A INSERÇÃO DE UMA CHAVE EXTRANGEIRA
function hramosCriaChaveEstrangeira(tabela, campo, tabelaRef, campoRef:string; banco:TIBDataBase):boolean;

implementation

uses uHramosString;

function hramosProxIndice(tabela:String; banco:TIBDataBase):integer;
var cdsAux:TClientDataSet;
begin
  cdsAux := hramosGetClient('SELECT CAST(GEN_ID('+tabela+',1) AS INTEGER) AS ID FROM RDB$DATABASE',banco);
  result := cdsAux.fieldbyname('ID').AsInteger;
  FreeAndNil(cdsAux);
end;

function hramosExecutaSQL(SQL:String; banco:TIBDataBase):boolean;overload;
var ibQuery:TIBQuery;
begin
  try
    ibQuery := TIBQuery.Create(banco);
    ibquery.Database := banco;
    //ibQuery.Transaction := frmDM.TranGeral;

    ibquery.SQL.Clear;
    ibquery.SQL.Text := SQL;
    ibquery.Prepare;
    ibquery.Open;
    result := true;
  except
    result := false;
  end;
  freeandnil(ibquery);
end;

function hramosExecutaSQL(SQL:String; banco:TSQLConnection):boolean;overload;
var sqlquery:TSQLQuery;
begin
  sqlquery := TSQLQuery.Create(banco);
  sqlquery.SQLConnection := banco;

  sqlquery.SQL.Clear;
  sqlquery.SQL.Add(SQL);
  sqlquery.PrepareStatement;
  sqlquery.ExecSQL;
  result := true;
  freeandnil(sqlquery);

end;


function hramosGetClient(SQL:String; banco:TIBDataBase):TClientDataSet;overload;
var ibTransaction:Tibtransaction;
var ibDataset:TibDataset;
var datasetProvider:TDatasetProvider;
var clientDataSet:TclientDataSet;
var clientRet:TclientDataSet;
begin
  ibTransaction := TIBTransaction.Create(banco);
  ibTransaction.DefaultDatabase := banco;
  ibTransaction.AutoStopAction := saCommit;

  ibDataset := TIBDataSet.Create(banco);
  ibDataset.Database := banco;
  ibDataset.Transaction := ibTransaction;
  ibDataset.UniDirectional := true;

  datasetProvider := TDataSetProvider.Create(banco);
  datasetProvider.DataSet := ibDataset;
  datasetprovider.Name := 'datasetProvider';

  clientDataSet := TClientDataSet.Create(banco);
  clientDataset.ProviderName := 'datasetprovider';
  clientDataSet.StoreDefs := true;

  ibDataset.SelectSQL.Clear;
  ibDataset.SelectSQL.Text := SQL;

  //ibdataset.Prepare;

  clientDataSet.Open;

  clientRet := TClientDataSet.Create(nil);
  clientRet.Data := clientDataSet.Data;

  result := clientRet;

  clientDataSet.Close;
  freeandnil(clientDataSet);
  freeandnil(datasetProvider);
  freeandnil(ibdataset);
  freeandnil(ibtransaction);

end;

function hramosGetClient(SQL:String; banco:TSQLConnection):TClientDataSet;overload;
var sqlQuery:TSQLQuery;
var datasetprovider:TDataSetProvider;
var cds:TClientDataSet;
var cdsRet:TClientDataSet;
begin
  sqlQuery := TSQLQuery.Create(banco);
  sqlQuery.SQLConnection := banco;

  datasetprovider := TDataSetProvider.Create(banco);
  datasetprovider.DataSet := sqlQuery;
  datasetprovider.Name := 'datasetprovider';

  cds := TClientDataSet.Create(banco);
  cds.ProviderName := 'datasetprovider';
  cds.StoreDefs := true;

  sqlQuery.SQL.Clear;
  sqlQuery.SQL.Add(SQL);

  cds.Open;

  cdsRet := TClientDataSet.Create(nil);
  cdsRet.Data := cds.Data;

  result := cdsRet;

  cds.Close;
  FreeAndNil(cds);
  freeandNil(datasetprovider);
  FreeAndNil(sqlQuery);  
end;

function hramosCriaCampo(tabela:string; campo:string; tipo:string; banco:TIBDataBase):boolean;
var cdstemp:TClientDataSet;
BEGIN
  cdsTemp := hramosGetClient('SELECT * FROM RDB$RELATION_FIELDS'+
                           ' WHERE UPPER(RDB$RELATION_NAME) = UPPER('''+tabela+''')'+
                           ' and UPPER(rdb$field_nAME) = UPPER('''+CAMPO+''')',banco);
  if cdstemp.RecordCount = 0 then
  begin
    hramosExecutaSQL('ALTER TABLE '+TABELA+' ADD '+CAMPO+' '+TIPO,BANCO);
    result := true;
  end
  else
    result := false;
  FreeAndNil(cdstemp);
END;

function hramosGetTabela(sql:string):string;
var sl:TstringList;
var i:integer;
var encontroFrom:boolean;
begin
  encontroFrom := false;
  result := '';
  sl := hramosSplit(sql,' ');
  for i:= 0 to sl.Count-1 do
  begin
    if encontroFrom then
    begin
      result := StringReplace(trim(sl[i]), #$D#$A, '', [rfReplaceAll]) ;
      Break;
    end;
    if UpperCase(sl[i]) = 'FROM' then
      encontroFrom := true;
  end;
end;

function hramosUserTemPermissao(tabela, usuario, permissao:string; banco:TIBDataBase):boolean;
var cdsTemp:TClientDataSet;
var regraOuUsuario:string;
begin
  cdsTemp := hramosGetClient('select rdb$user_privileges.rdb$relation_name from rdb$user_privileges'+
                           ' where upper(rdb$user_privileges.rdb$user) = upper('''+usuario+''')',banco);
  if cdsTemp.RecordCount > 0 then //ESTE É UM USUÁRIO OU UMA REGRA VÁLIDA
  begin
    if cdsTemp.RecordCount = 1 then //FOI PASSADO UM USUÁRIO, DEVEMOS UTILIZAR NA BUSCA A SUA REGRA
      regraOuUsuario := cdsTemp.fieldbyname('rdb$relation_name').AsString
    else //FOI PASSADA A PRÓPRIA REGRA
      regraOuUsuario := usuario;
    cdsTemp := hramosGetClient('select rdb$user_privileges.rdb$privilege from rdb$user_privileges'+
                             ' where upper(rdb$user_privileges.rdb$user) = upper('''+regraOuUsuario+''')'+
                             ' and upper(rdb$user_privileges.rdb$relation_name) = upper('''+tabela+''')'+
                             ' and upper(rdb$user_privileges.rdb$privilege) = upper('''+permissao+''')',banco);
    if cdsTemp.RecordCount = 0 then
      result := false
    else
      result := true;
  end
  else //FOI PASSADO UM USUARIO/REGRA INVÁLIDA
    result := false;
  freeandNil(cdsTemp);
end;

function hramosCriaTabela(tabela:string; campos:string; banco:TIBDataBase):boolean;
BEGIN
  if not(hramosExisteTabela(tabela, banco)) then
  begin
    if hramosExecutaSQL('CREATE TABLE '+TABELA+' ('+campos+')',BANCO) then
      result := true
    else
      result := false;
  end
  else
    result := false;
//  FreeAndNil(cdstemp);
END;

function hramosRegraDoUsuario(usuario:string; banco:TIBDataBase):string;
var cdsTemp:TclientDataSet;
begin
  cdsTemp := hramosGetClient('select distinct rdb$user_privileges.rdb$user, rdb$roles.rdb$role_name'+
                           ' from RDB$user_privileges'+
                           ' inner join rdb$roles on (rdb$roles.rdb$role_name = rdb$user_privileges.rdb$relation_name)'+
                           ' where upper(rdb$user_privileges.rdb$user) = upper('''+usuario+''')',banco);
  result := cdsTemp.fieldbyname('rdb$role_name').AsString;
  freeandnil(cdstemp);
end;

function hramosUsuariosDaRegra(regra:string; banco:TIBDataBase):TStringlist;
var cdsTemp:TclientDataSet;
var sl:TStringList;
begin
  sl := TstringList.Create;
  cdsTemp := hramosGetClient('select distinct rdb$user_privileges.rdb$user, rdb$roles.rdb$role_name'+
                           ' from RDB$user_privileges'+
                           ' inner join rdb$roles on (rdb$roles.rdb$role_name = rdb$user_privileges.rdb$relation_name)'+
                           ' where upper(rdb$roles.rdb$role_name) = upper('''+regra+''')',banco);
  sl.Clear;
  cdsTemp.First;
  while not(cdsTemp.Eof) do
  begin
    sl.Add(cdsTemp.fieldByName('rdb$user').AsString);
    cdsTemp.Next;
  end;
end;

function hramosCriaChavePrimaria(tabela, campos:string; banco:TIBDataBase):Boolean;
begin
  if hramosExisteTabela(tabela,banco) then
    result := hramosExecutaSQL('alter table '+tabela+
                             ' add constraint PK_'+tabela+
                             ' primary key ('+campos+')', banco)
  else
    result := false;
end;

function hramosExisteTabela(tabela:string;banco:TIBDataBase):boolean;
var cdstemp:TClientDataSet;
BEGIN
  cdsTemp := hramosGetClient('SELECT * FROM RDB$RELATION_FIELDS'+
                           ' WHERE UPPER(RDB$RELATION_NAME) = UPPER('''+tabela+''')',banco);
  if cdsTemp.RecordCount = 0 then
    result := false
  else
    result := true;
  freeandNil(cdstemp);
end;

function hramosCriaChaveEstrangeira(tabela, campo, tabelaRef, campoRef:string; banco:TIBDataBase):boolean;
begin
  if hramosExisteTabela(tabela,banco) and hramosExisteTabela(tabelaRef,banco) then
    result := hramosExecutaSQL('alter table '+tabela+
                             ' add constraint FK_'+tabela+
                             ' foreign key ('+campo+')'+
                             ' references '+tabelaRef+'('+campoRef+')', banco)
  else
    result := false;
end;

end.
