unit uHramosGeral;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Db, DBTables, DBClient, Provider, IBCustomDataSet, IBStoredProc,
  IBDatabase, IBQuery, MemTableEh, EhLibMTE, ImgList, IBDatabaseInfo, Winsock, RichEdit,
  comctrls;

//PROCEDIMENTO PARA EXIBIÇÃO DE UM DETERMINADO FORMULÁRIO NA TELA, RECEBE COMO
//PARAMETRO APENAS A CLASSE DO FORMULÁRIO
procedure hramosCarregaForm(FORMULARIO:TFORMCLASS);

//FAZ A DUPLICAÇÃO DE UM CLIENTDATASET, COM A MESMA ESTRUTURA E OS MESMOS CAMPOS
//PORÉM VAZIO
function hramosDuplicaClient(clientOrigem:TclientDataSet):TclientDataSet;

//COPIA O CONTEÚDO DE UM CLIENTDATASET PARA OUTRO, LEMBRANDO QUE OS NOMES DOS
//CAMPOS DEVEM SER IDENTICOS NOS DOIS CLIENTS
function hramosClientDuplicaDadosGemeos(clientOrigem:TclientDataset; var clientDestino:TclientDataSet):boolean;

//RETORNA UMA STRING COM O IP DO COMPUTADOR - USA A UNIT WINSOCK
function HramosGetIP:string;

//FAZ A COLORAÇÃO DE LINHAS/PALAVRAS DE UM RICHEDIT OS PARAMETROS DE MARCA PODEM SER:
//SCF_ALL / SCF_SELECTION / SCF_WORD  - USA A UNIT RICHEDIT
procedure hramosRichEditColor(RichEdit:TRichEdit; fgColor, bkColor :TColor; MarkMode :Integer);

//INSERE O VALOR NA STRINGLIST PORÉM APENAS SE O MESMO NÃO EXISIIR NA MESMA
procedure hramosInsereSemDuplicar(slOriginal:TStringList;valor:string);

implementation

procedure hramosInsereSemDuplicar(slOriginal:TStringList;valor:string);
var i:integer;
var existe:boolean;
begin
  existe := false;
  for i:=0 to slOriginal.Count-1 do
  begin
    if slOriginal[i] = valor then
      existe := true;
  end;
  if not(existe) then
    slOriginal.Add(valor);
end;

procedure hramosRichEditColor(RichEdit :TRichEdit; fgColor, bkColor :TColor; MarkMode :Integer);
var
  CharFormat :TCharFormat2;
begin
 // na marcação de palavra, na chamada a EM_SETCHARFORMAT deve ser
 // concatenado SCF_SELECTION ao parâmetro SCF_WORD
  if MarkMode = SCF_WORD then
    MarkMode := MarkMode or SCF_SELECTION;
  CharFormat.cbSize := SizeOf(CharFormat);
  CharFormat.dwMask := CFM_BACKCOLOR or CFM_COLOR;
  CharFormat.crBackColor := ColorToRGB(bkColor);
  CharFormat.crTextColor := ColorToRGB(fgColor);
  SendMessage(RichEdit.handle, EM_SETCHARFORMAT, MarkMode, LongInt(@CharFormat));
end;

function HramosGetIP:string;
var
    WSAData: TWSAData;
    HostEnt: PHostEnt;
    Name:string;
begin
  WSAStartup(2, WSAData);
  SetLength(Name, 255);
  Gethostname(PChar(Name), 255);
  SetLength(Name, StrLen(PChar(Name)));
  HostEnt := gethostbyname(PChar(Name));
  with HostEnt^ do
  begin
    Result := Format('%d.%d.%d.%d',
    [Byte(h_addr^[0]),Byte(h_addr^[1]),
    Byte(h_addr^[2]),Byte(h_addr^[3])]);
  end;
    WSACleanup;
end;

function hramosClientDuplicaDadosGemeos(clientOrigem:TclientDataset; var clientDestino:TclientDataSet):boolean;
var i:integer;
var campoAtual:String;
var novoValor:Variant;
begin
  try
    if clientOrigem.Active = false then
      clientOrigem.Open;
    if clientDestino.Active = false then
      clientDestino.Open();
    clientOrigem.First;
    while not(clientOrigem.Eof) do
    begin
      clientDestino.Insert;
      for i:=0 to clientOrigem.Fields.Count-1 do
      begin
        campoAtual := clientOrigem.Fields[i].FieldName;
        novoValor :=clientOrigem.Fields[i].Value;
        clientDestino.FieldByName(campoAtual).AsVariant :=novoValor;
      end;
      clientDestino.Post;
      clientOrigem.Next;
    end;
    result := true
  except
    result := false;
  end;
end;

procedure hramosCarregaForm(FORMULARIO:TFORMCLASS);
var FRMNOVO:TFORM;
begin
  Application.CreateForm(FORMULARIO,FRMNOVO);
  Screen.Cursor:=crHourGlass;
  FRMNOVO.ShowModal;
  freeandnil(frmnovo);
  Screen.Cursor:=crDefault;
end;

function hramosDuplicaClient(clientOrigem:TclientDataSet):TclientDataSet;
var clientRetorno:TclientDataSet;
var i:integer;
var fieldAtual :TField;
begin
  clientRetorno := TClientDataSet.Create(application);
  if clientOrigem.Active = false then
    clientOrigem.Open;
  for i:=0 to clientOrigem.Fields.Count-1 do
  begin
    clientretorno.FieldDefs.Add(clientOrigem.Fields[i].FieldName,
                                clientOrigem.Fields[i].DataType,
                                clientOrigem.Fields[i].Size,
                                clientOrigem.Fields[i].Required);
    //clientRetorno.Fields.FindField(clientOrigem.Fields[i].FieldName).DisplayLabel := clientOrigem.Fields[i].DisplayLabel;
  end;
  clientRetorno.CreateDataSet;
  result := clientRetorno;
end;

end.
