unit UFrmFormaPag;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Buttons, Vcl.StdCtrls,
  RzPanel, RzTabs, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.Mask, Vcl.DBCtrls, Vcl.Imaging.pngimage, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, RxToolEdit, RxCurrEdit, System.ImageList,
  Vcl.ImgList;

type
  TFrmFormaPag = class(TForm)
    pnlContainer: TPanel;
    PageControl1: TRzPageControl;
    pnlBotoes: TPanel;
    pnlTitulo: TPanel;
    ShapeTitulo: TShape;
    lblTitulo: TLabel;
    TabListagem: TRzTabSheet;
    TabDados: TRzTabSheet;
    GroupBoxPesquisa: TRzGroupBox;
    EdtLocalizar: TEdit;
    btnFechar: TSpeedButton;
    btnAlterar: TSpeedButton;
    btnNovo: TSpeedButton;
    DBGrid1: TDBGrid;
    btnGravar: TSpeedButton;
    Label1: TLabel;
    DBEdit1: TDBEdit;
    Label2: TLabel;
    DBEdit2: TDBEdit;
    Label4: TLabel;
    DBEdit4: TDBEdit;
    Label5: TLabel;
    DBEdit5: TDBEdit;
    Label6: TLabel;
    DBEdit6: TDBEdit;
    RzGroupBox1: TRzGroupBox;
    CBPix: TCheckBox;
    CBBaixa: TCheckBox;
    CBCheque: TCheckBox;
    CBCartao: TCheckBox;
    CBParcela: TCheckBox;
    RGStatus: TRadioGroup;
    TabTxCartao: TRzTabSheet;
    DBGrid2: TDBGrid;
    Panel2: TPanel;
    Label9: TLabel;
    DBEdit8: TDBEdit;
    DBEdit9: TDBEdit;
    Image1: TImage;
    SqlTaxasCartao: TFDQuery;
    DsTxCartao: TDataSource;
    SqlTaxasCartaoID_TAXA_CARTAO: TIntegerField;
    SqlTaxasCartaoID_PAGAMENTO: TIntegerField;
    SqlTaxasCartaoPARCELA_MINIMA: TIntegerField;
    SqlTaxasCartaoPARCELA_MAXIMA: TIntegerField;
    SqlTaxasCartaoTAXA: TBCDField;
    SqlTaxasCartaoDATA_CADASTRO: TSQLTimeStampField;
    Label3: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Image2: TImage;
    EdtTaxa: TCurrencyEdit;
    EdtParcMaxima: TCurrencyEdit;
    EdtParcMinima: TCurrencyEdit;
    ImageList1: TImageList;
    RGTipoCartao: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure EdtLocalizarChange(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PageControl1Change(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnAlterarClick(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure btnNovoClick(Sender: TObject);
    procedure CBCartaoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DBGrid2DblClick(Sender: TObject);
  private
    procedure CarregaDados;
    procedure GravarTaxaCartao(AIDTaxaCartao: Integer; AIDPagamento: Integer;
      AParcelaMinima: Integer; AParcelaMaxima: Integer; ATaxa: Double);
    procedure AtualizarTaxaCartao(AIDTaxaCartao: Integer; AIDPagamento: Integer;
      AParcelaMinima: Integer; AParcelaMaxima: Integer; ATaxa: Double);
  public
    ProxID : Integer;
    Inserir, Editar, AlterarTaxa : Boolean;
  end;

var
  FrmFormaPag: TFrmFormaPag;

implementation

uses
  UDM, UFuncoes, UEnumsPermissoes;

{$R *.dfm}

procedure TFrmFormaPag.btnAlterarClick(Sender: TObject);
begin
  TabDados.Show;
  TabDados.Enabled := True;
  DM.SqlFormas.Edit;
  if DM.SqlFormasCARTAO.AsString = 'S' then
  begin
    with SqlTaxasCartao do
    begin
      Close;
      ParamByName('ID_PAGTO').AsInteger := DM.SqlFormasID_PAGAMENTO.AsInteger;
      Open;
      Edit;
    end;
  end;
  CarregaDados;
end;

procedure TFrmFormaPag.btnFecharClick(Sender: TObject);
begin
  if DM.SqlFormas.State in [dsEdit, dsInsert] then
    DM.SqlFormas.Cancel;

  Application.Terminate;
end;

procedure TFrmFormaPag.btnNovoClick(Sender: TObject);
begin
  if TabDados.Showing then
  Exit;

  if TabListagem.Showing then
  begin
    ProxID := GetNextGeneratorValue('GEN_FORMA_PAGAMENTOS_ID', DM.FDConnection1);
    if not DM.SqlFormas.Active then
      DM.SqlFormas.Open;
    DM.SqlFormas.Append;
    TabDados.Show;
    TabDados.Enabled := True;
    Inserir := True;
    Editar := False;
  end;
end;

procedure TFrmFormaPag.CarregaDados;
begin
  with DM.SqlFormas do
  begin
    if FieldByName('PIX').AsString = 'S' then
      CBPix.Checked := True;

    if FieldByName('BAIXA_AUTOMATICA').AsString = 'S' then
      CBBaixa.Checked := True;

    if FieldByName('CARTAO').AsString = 'S' then
      CBCartao.Checked := True;

    if FieldByName('CHEQUE').AsString = 'S' then
      CBCheque.Checked := True;

    if FieldByName('PARCELA').AsString = 'S' then
      CBParcela.Checked := True;

    if FieldByName('STATUS').AsString = 'A' then
      RGStatus.ItemIndex := 0
    else
      RGStatus.ItemIndex := 1;

    if FieldByName('TIPO_CARTAO').AsString = 'C' then
      RGTipoCartao.ItemIndex := 0
    else if FieldByName('TIPO_CARTAO').AsString = 'D' then
      RGTipoCartao.ItemIndex := 1
    else
      RGTipoCartao.ItemIndex := -1;
  end;
end;

procedure TFrmFormaPag.CBCartaoClick(Sender: TObject);
begin
  if CBCartao.Checked then
  begin
    TabTxCartao.TabVisible := True;
    DM.SqlFormasCARTAO.AsString :=  'S';
    RGTipoCartao.Visible := True;
  end
  else
  begin
    TabTxCartao.TabVisible := False;
    DM.SqlFormasCARTAO.AsString :=  'N';
    RGTipoCartao.Visible := False;
  end;
end;

procedure TFrmFormaPag.DBGrid1CellClick(Column: TColumn);
begin
  //CarregaDados;
  if DM.SqlFormas.IsEmpty then
    Exit;
  if DM.SqlFormasCARTAO.AsString = 'S' then
    TabTxCartao.TabVisible := True
  else
    TabTxCartao.TabVisible := False;
end;

procedure TFrmFormaPag.DBGrid1DblClick(Sender: TObject);
begin
  btnAlterar.Click;
end;

procedure TFrmFormaPag.DBGrid2DblClick(Sender: TObject);
begin
  if SqlTaxasCartao.IsEmpty then
  begin  Exit;
  end;


  AlterarTaxa := True;
  EdtParcMinima.Text := IntToStr(SqlTaxasCartaoPARCELA_MINIMA.AsInteger);
  EdtParcMaxima.Text := IntToStr(SqlTaxasCartaoPARCELA_MAXIMA.AsInteger);
  EdtTaxa.Value := SqlTaxasCartaoTAXA.AsCurrency;

end;

procedure TFrmFormaPag.EdtLocalizarChange(Sender: TObject);
begin
  with DM.SqlFormas do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT * FROM FORMA_PAGAMENTOS ');
    SQL.Add('WHERE DESCRICAO CONTAINING  :DESCRICAO');
    ParamByName('DESCRICAO').AsString := EdtLocalizar.Text;
    Open;
  end;
end;

procedure TFrmFormaPag.FormCreate(Sender: TObject);
begin
  Self.Caption := 'Formas de Pagamento   |   v.25.03.03.01';
  DM.SqlFormas.Close;
  DM.SqlFormas.Open;
  TabDados.Enabled := False;
  PageControl1.TabIndex := 0;
  CarregaDados;
end;

procedure TFrmFormaPag.FormKeyDown(Sender: TObject; var Key: Word;
Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
      begin
        if DM.SqlFormas.State in [dsEdit, dsInsert] then
          DM.SqlFormas.Cancel;
        Application.Terminate;
      end;
    VK_F2:
      btnNovo.Click;
    VK_F3:
      btnAlterar.Click;
    VK_F6:
      btnGravar.Click;
    VK_SPACE:
      btnFechar.Click;
  end;
end;

procedure TFrmFormaPag.FormShow(Sender: TObject);
begin
  TabTxCartao.TabVisible := False;
  RGTipoCartao.Visible := False;
end;

procedure TFrmFormaPag.AtualizarTaxaCartao(
  AIDTaxaCartao: Integer;
  AIDPagamento: Integer;
  AParcelaMinima: Integer;
  AParcelaMaxima: Integer;
  ATaxa: Double
);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
  try
    Query.Connection := DM.FDConnection1;  // Conexão configurada com o banco de dados
    Query.SQL.Text :=
      'UPDATE TAXA_CARTAO ' +
      'SET ID_PAGAMENTO = :ID_PAGAMENTO, ' +
      '    PARCELA_MINIMA = :PARCELA_MINIMA, ' +
      '    PARCELA_MAXIMA = :PARCELA_MAXIMA, ' +
      '    TAXA = :TAXA ' +
      'WHERE ID_TAXA_CARTAO = :ID_TAXA_CARTAO';

    // Passa os valores para os parâmetros
    Query.ParamByName('ID_TAXA_CARTAO').AsInteger := AIDTaxaCartao;
    Query.ParamByName('ID_PAGAMENTO').AsInteger := AIDPagamento;
    Query.ParamByName('PARCELA_MINIMA').AsInteger := AParcelaMinima;
    Query.ParamByName('PARCELA_MAXIMA').AsInteger := AParcelaMaxima;
    Query.ParamByName('TAXA').AsFloat := ATaxa;

    // Executa o comando
    Query.ExecSQL;

    //ShowMessage('Taxa de cartão atualizada com sucesso!');
  except
    on E: Exception do
      ShowMessage('Erro ao atualizar taxa de cartão: ' + E.Message);
  end;
  finally
    Query.Free;
  end;
end;


procedure TFrmFormaPag.Image1Click(Sender: TObject);
var
  ProximoValor, id_forma: Integer;
begin
  try
    if not AlterarTaxa then
    begin
      try
        ProximoValor := GetNextGeneratorValue('GEN_TAXA_CARTAO_ID', DM.FDConnection1);
        id_forma := DM.SqlFormasID_PAGAMENTO.AsInteger;
        GravarTaxaCartao(ProximoValor, id_forma, StrToInt(EdtParcMinima.Text),
          StrToInt(EdtParcMaxima.Text), EdtTaxa.Value);
        EdtParcMinima.Text := '';
        EdtParcMaxima.Text := '';
        EdtTaxa.Value := 0;
      except
        on E: Exception do
          raise Exception.Create('Erro ao Gravar Taxas' + e.Message);
      end;
    end
    else if AlterarTaxa then
    begin
      id_forma := DM.SqlFormasID_PAGAMENTO.AsInteger;

      AtualizarTaxaCartao(SqlTaxasCartaoID_TAXA_CARTAO.AsInteger, id_forma,
        StrToInt(EdtParcMinima.Text), StrToInt(EdtParcMaxima.Text), EdtTaxa.Value);
    end;
  finally
    MessageDlg('Taxas Atualizadas com Sucesso!', mtInformation, [mbOK], 0);
    AlterarTaxa := False;
    SqlTaxasCartao.Refresh;
  end;
end;

procedure TFrmFormaPag.GravarTaxaCartao(
  AIDTaxaCartao: Integer;
  AIDPagamento: Integer;
  AParcelaMinima: Integer;
  AParcelaMaxima: Integer;
  ATaxa: Double
);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    try
      Query.Connection := DM.FDConnection1;  // Certifique-se de ter uma conexão configurada
      Query.SQL.Text :=
        'INSERT INTO TAXA_CARTAO (ID_TAXA_CARTAO, ID_PAGAMENTO, PARCELA_MINIMA, PARCELA_MAXIMA, TAXA) ' +
        'VALUES (:ID_TAXA_CARTAO, :ID_PAGAMENTO, :PARCELA_MINIMA, :PARCELA_MAXIMA, :TAXA)';

      // Passa os valores para os parâmetros
      Query.ParamByName('ID_TAXA_CARTAO').AsInteger := AIDTaxaCartao;
      Query.ParamByName('ID_PAGAMENTO').AsInteger := AIDPagamento;
      Query.ParamByName('PARCELA_MINIMA').AsInteger := AParcelaMinima;
      Query.ParamByName('PARCELA_MAXIMA').AsInteger := AParcelaMaxima;
      Query.ParamByName('TAXA').AsFloat := ATaxa;

      // Executa o comando
      Query.ExecSQL;

     // ShowMessage('Taxa de cartão gravada com sucesso!');
    except
      on E: Exception do
        raise Exception.Create('Erro ao gravar taxa de cartão: ' + E.Message);
    end;
  finally
    Query.Free;
  end;
end;



procedure TFrmFormaPag.PageControl1Change(Sender: TObject);
begin
  if TabListagem.Showing then
   begin
  //   TabDados.Enabled :=
   end;
end;

procedure TFrmFormaPag.btnGravarClick(Sender: TObject);
begin
  if TabDados.Showing then
  begin
    try
      if Inserir then
        DM.SqlFormasID_PAGAMENTO.AsInteger := ProxID;

      if CBPix.Checked then
        DM.SqlFormasPIX.AsString := 'S'
      else
        DM.SqlFormasPIX.AsString := 'N';

      if CBCartao.Checked then
        DM.SqlFormasCARTAO.AsString := 'S'
      else
        DM.SqlFormasCARTAO.AsString := 'N';

      if CBBaixa.Checked then
        DM.SqlFormasBAIXA_AUTOMATICA.AsString := 'S'
      else
        DM.SqlFormasBAIXA_AUTOMATICA.AsString := 'N';

      if CBCheque.Checked then
        DM.SqlFormasCHEQUE.AsString := 'S'
      else
        DM.SqlFormasCHEQUE.AsString := 'N';

      if CBParcela.Checked then
        DM.SqlFormasPARCELA.AsString := 'S'
      else
        DM.SqlFormasPARCELA.AsString := 'N';

      if RGStatus.ItemIndex = 0 then
        DM.SqlFormasSTATUS.AsString := 'A'
      else
        DM.SqlFormasSTATUS.AsString := 'I';

      case RGTipoCartao.ItemIndex of
        0:
          DM.SqlFormasTIPO_CARTAO.AsString := 'C';
        1:
          DM.SqlFormasTIPO_CARTAO.AsString := 'D';
      end;

      DM.SqlFormas.Post;
    finally
      MessageDlg('Dados gravados com Sucesso!', mtInformation, [mbOK], 0);
      TabDados.Enabled := False;
      DM.SqlFormas.Refresh;
      TabListagem.Show;
    end;
  end;
end;
end.
