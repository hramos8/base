unit uHramosMatematica;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Db, DBTables, DBClient, Provider, IBCustomDataSet, IBStoredProc,
  IBDatabase, IBQuery, MemTableEh, EhLibMTE, ImgList, IBDatabaseInfo, Winsock, RichEdit,
  comctrls;

//RETORNA O VALOR EM PORCENTAGEM DO vlrProporcial SOBRE O vlr100Porc
function hramosRegraTresPorc(vlrProporcional,vlr100Porc:double):double;

implementation

function hramosRegraTresPorc(vlrProporcional,vlr100Porc:double):double;
begin
  result := (vlrProporcional*100)/vlr100Porc;
end;

end.
 