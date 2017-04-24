unit uTHramosCriptografia;

interface

Type THramosCriptografia = class
  private
    Fsemente: string;
    procedure Setsemente(const Value: string);
    function paresEImpares(str:string):string;
    function novoTamanho(str:string;novotam:integer):string;
  public
    property semente:string write Setsemente;
    function criptografa(strOriginal:string):string;
    function descriptografa(strCriptografada:string):string;
    constructor create(semente:string);
end;

implementation

{ THramosCriptografia }

constructor THramosCriptografia.create(semente: string);
begin
  Setsemente(semente);
end;

function THramosCriptografia.criptografa(strOriginal: string): string;
var aux,ret:string;
var i:integer;
begin
  aux := novoTamanho(Fsemente,length(strOriginal));
  ret := '';
  for i := 1 to length(strOriginal) do
  begin
    ret := ret+chr(integer(strOriginal[i])+integer(aux[i]));
  end;
  result := ret;
end;

function THramosCriptografia.descriptografa(strCriptografada: string): string;
var aux,ret:string;
var i:integer;
begin
  aux := novoTamanho(Fsemente,length(strCriptografada));
  ret := '';
  for i := 1 to length(strCriptografada) do
  begin
    ret := ret+chr(integer(strCriptografada[i])-integer(aux[i]));
  end;
  result := ret;

end;

function THramosCriptografia.novoTamanho(str: string;novotam:integer): string;
var aux:string;
var i, posLeitura:integer;
begin
  aux := '';
  for i := 1 to novotam do
  begin
    posLeitura := i;
    if posLeitura > length(str) then
      posLeitura := posLeitura-length(str);
    aux:=aux+str[posLeitura];
  end;
  result := aux;
end;

function THramosCriptografia.paresEImpares(str: string): string;
var aux:string;
var i:integer;
begin
  aux := '';
  i:=2;
  while i <= length(str) do
  begin
    aux := aux+str[i];
    i := i+2;
  end;

  i:=1;
  while i <= length(str) do
  begin
    aux := aux+str[i];
    i:=i+2;
  end;
  result := aux;
end;

procedure THramosCriptografia.Setsemente(const Value: string);
var aux:string;
begin
  Fsemente := paresEImpares(value);
end;

end.
