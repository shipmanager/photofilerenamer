program FileRenamer;

uses
  Forms,
  Main in 'Main.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '�������������� ������';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
