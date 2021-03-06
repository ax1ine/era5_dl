unit getera5_settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  IniFiles;

type

  { Tfrmsettings }

  Tfrmsettings = class(TForm)
    btnPython: TButton;
    btnInstallPackages: TButton;
    eKey: TEdit;
    ePythonPath: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox5: TGroupBox;
    Memo1: TMemo;
    OD: TOpenDialog;
    seUID: TSpinEdit;

    procedure btnPythonClick(Sender: TObject);
    procedure btnInstallPackagesClick(Sender: TObject);
    procedure ePythonPathChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);

  private
    procedure SaveSettings;
  public

  end;

var
  frmsettings: Tfrmsettings;

implementation

{$R *.lfm}

{ Tfrmsettings }

uses getera5_code;


procedure Tfrmsettings.FormShow(Sender: TObject);
Var
  Ini: TIniFile;
  dat:text;
  st:string;
begin
  Ini:=TIniFile.Create(IniFileName);
    ePythonPath.Text:=Ini.ReadString('main', 'PythonPath', '');
  Ini.Free;

  if FileExists(GetUserDir+'.cdsapirc') then begin
    AssignFile(dat, GetUserDir+'.cdsapirc'); reset(dat);
     readln(dat, st);
     readln(dat, st);
     st:=copy(st, 5, length(st));
     seUID.Text:=trim(copy(st, 1, Pos(':', st)-1));
     eKey.Text:=trim(copy(st, Pos(':', st)+1, length(st)));
    CloseFile(dat);
  end;
end;

procedure Tfrmsettings.btnPythonClick(Sender: TObject);
begin
  OD.Filter:='Python.exe|Python.exe';
  if OD.Execute then begin
   ePythonPath.Text:= OD.FileName;
   SaveSettings;
  end;
end;

procedure Tfrmsettings.ePythonPathChange(Sender: TObject);
begin
  {$IFDEF WINDOWS}
   if FileExists(ePythonPath.Text) then
     ePythonPath.Font.Color:=clGreen else
     ePythonPath.Font.Color:=clRed;
  {$ENDIF}
end;

procedure Tfrmsettings.SaveSettings;
Var
  Ini:TIniFile;
  dat:text;
begin
  Ini:=TIniFile.Create(IniFileName);
  Ini.WriteString('main', 'PythonPath', ePythonPath.Text);
  Ini.Free;

  if trim(eKey.Text)<>'' then begin
    AssignFile(dat, GetUserDir+'.cdsapirc'); rewrite(dat);
     writeln(dat, 'url: https://cds.climate.copernicus.eu/api/v2');
     writeln(dat, 'key: '+seUID.Text+':'+eKey.Text);
    CloseFile(dat);
  end;
end;

procedure Tfrmsettings.btnInstallPackagesClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
memo1.Clear;
 Ini := TIniFile.Create(IniFileName);
  try
   Ini.WriteString ( 'main', 'PythonPath', ePythonPath.Text);
  finally
   Ini.Free;
  end;

  frmmain.RunScript(1, '-m pip install cdsapi', memo1);
end;

procedure Tfrmsettings.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  SaveSettings;
end;

end.

