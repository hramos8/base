unit uHramosStringBD;

interface

USES SysUtils, Variants, StdCtrls, ComCtrls, ExtCtrls;

//FAZ A CONVERSÃO DE UM TIPO EXTENDED PARA STRING JÁ FORMATADO NOS MOLDES DO BANCO DE DADOS
function hramosBDFloatToStr(valor:extended):string;
//FAZ A CONVERSÃO DO TIPO DATE PARA UMA STRING JÁ CONFIGURADA NO PADRÃO SQL (31.01.2011), INCLUSIVE COM AS ASPAS
function hramosBDDateToStr(data:Tdatetime):string;
//FORMATA A STRING PARA OS PADRÕES SQL
function hramosBDFormataStr(str:String):String;


implementation
function hramosBDFloatToStr(valor:extended):string;
var retorno:string;
begin
    retorno := floattostr(valor);
    retorno := stringreplace(retorno,',','.',[rfReplaceAll]);
    result:=retorno;
end;

function hramosBDDateToStr(data:Tdatetime):string;
var retorno : string;
begin
    retorno := datetostr(data);
    retorno := ''''+stringreplace(retorno,'/','.',[rfReplaceAll])+'''';
    result := retorno;
end;

function hramosBDFormataStr(str:String):String;
begin
  if str = '' then
    result := 'null'
  else 
    result := ''''+str+'''';
end;

end.
