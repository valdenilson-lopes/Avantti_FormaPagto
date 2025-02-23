program FormasPagamento;

uses
  Vcl.Forms,
  UFrmFormaPag in 'UFrmFormaPag.pas' {FrmFormaPag},
  UFuncoes in '..\Avantti_Uteis\UFuncoes.pas',
  UDM in '..\Avantti_Conexao\UDM.pas' {DM: TDataModule},
  UEnumsPermissoes in '..\Avantti_Uteis\UEnumsPermissoes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFrmFormaPag, FrmFormaPag);
  Application.Run;
end.
