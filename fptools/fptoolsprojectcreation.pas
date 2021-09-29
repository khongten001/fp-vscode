unit fptoolsprojectcreation;

{$i fptools.inc}

interface

uses
  fpjson;

procedure ProjectCreation(ARequest: TJSONData);

implementation

uses
  SysUtils,
  LazFileUtils,
  // fptools
  fptoolsutils;

function TemplateSettings(AName, APlataform: string;
  VOptions: string = '-Jeutf-8 -Ji''' + 'rtl.js' + ''' -Jc -Jminclude'): string;
begin
  Result := '{' + LE;
  Result += '    "project": "' + Ternary(AName = '', '",', './' + AName + '.lpr",') + LE;
  Result += '    "searchDir": [],' + LE;
  Result += '    "includeDir": [],' + LE;
  Result += '    "outputDir": "",' + LE;
  Result += '    "plataform": "' + APlataform + '",' + LE;
  Result += '    "customOptions": "' + VOptions + '"' + LE;
  Result += '}';
end;

function TemplateProject(AName: string; AIsLibrary: boolean = False): string;
begin
  Result := Ternary(AIsLibrary, 'library ', 'program ') + AName + ';' + LE + LE;
  Result += '{$mode objfpc}{$H+}' + LE + LE;
  Result += 'uses' + LE;
  Result += '  Classes;' + LE + LE;
  Result += 'begin' + LE;
  Result += 'end.';
end;

function TemplateProjectHttpServer(AName, AType: string): string;

  function ServerLibs(AType: string): string;
  begin
    case AType of
      'CGI': Result := 'fpcgi';
      'FASTCGI': Result := 'fpfcgi';
      'StandAlone': Result := 'fphttpapp';
    end;
  end;

begin
  Result := 'program ' + AName + ';' + LE + LE;
  Result += '{$mode objfpc}{$H+}' + LE + LE;
  Result += 'uses' + LE;
  Result += '  {$ifdef UNIX}' + LE;
  Result += '  cthreads,' + LE;
  Result += '  {$endif}' + LE;
  Result += '  Classes,' + LE;
  Result += '  ' + ServerLibs(AType) + ',' + LE;
  Result += '  HTTPDefs,' + LE;
  Result += '  HTTPRoute;' + LE + LE;
  Result += '  procedure Ping(ARequest: TRequest; AResponse: TResponse);' + LE;
  Result += '  begin' + LE;
  Result += '    AResponse.Content := ''Pong'';' + LE;
  Result += '  end;' + LE + LE;
  Result += 'begin' + LE;
  Result += '  HTTPRouter.RegisterRoute(''Ping'', @Ping, True);' + LE + LE;
  Result += '  Application.Title := ''' + AName + ''';' + LE;
  Result += Ternary(AType = 'StandAlone', '  Application.Port := 8080;' + LE, '');
  Result += '  Application.Run;' + LE;
  Result += 'end.';
end;

function TemplateHtml(AName: string): string;
begin
  Result := '<!doctype html>' + LE;
  Result += '<html lang="en">' + LE;
  Result += '<head>' + LE;
  Result += '    <meta http-equiv="Content-type" content="text/html; charset=utf-8">'
    + LE;
  Result += '    <meta name="viewport" content="width=device-width, initial-scale=1">'
    + LE;
  Result += '    <title>' + AName + '</title>' + LE;
  Result += '    <script src="./' + AName + '.js"></script>' + LE;
  Result += '</head>' + LE;
  Result += '<body>' + LE;
  Result += '    <script>rtl.run();</script>' + LE;
  Result += '</body>' + LE;
  Result += '</html>';
end;

procedure CreateAplication(ADir, AName: string);
var
  VProject: string;
  VSettings: string;
  VResponse: TJSONObject;
begin
  if (not (DirectoryIsWritable(ADir))) then
  begin
    WriteStdout('Invalid project directory: "' + ADir + '"');
  end;
  VProject := AppendPathDelim(ADir) + AName + '.lpr';
  if (FileExistsUTF8(VProject)) then
  begin
    WriteStdout(AName + '.lpr already exists');
  end;
  VSettings := AppendPathDelim(ADir) + AName + '.lpr.json';
  if (FileExistsUTF8(VSettings)) then
  begin
    WriteStdout(AName + '.lpr.json already exists');
  end;
  // Save
  WriteFile(VProject, TemplateProject(AName));
  WriteFile(VSettings, TemplateSettings(AName, '', ''));
  VResponse := TJSONObject.Create();
  VResponse.Add('project', VProject);
  VResponse.Add('settings', VSettings);
  WriteStdout(VResponse, True);
end;

procedure CreateAplicationHttpServer(ADir, AName, AType: string);
var
  VProject: string;
  VSettings: string;
  VResponse: TJSONObject;
begin
  if (not (DirectoryIsWritable(ADir))) then
  begin
    WriteStdout('Invalid project directory: "' + ADir + '"');
  end;
  VProject := AppendPathDelim(ADir) + AName + '.lpr';
  if (FileExistsUTF8(VProject)) then
  begin
    WriteStdout(AName + '.lpr already exists');
  end;
  VSettings := AppendPathDelim(ADir) + AName + '.lpr.json';
  if (FileExistsUTF8(VSettings)) then
  begin
    WriteStdout(AName + '.lpr.json already exists');
  end;
  // Save
  WriteFile(VProject, TemplateProjectHttpServer(AName, AType));
  WriteFile(VSettings, TemplateSettings(AName, '', ''));
  VResponse := TJSONObject.Create();
  VResponse.Add('project', VProject);
  VResponse.Add('settings', VSettings);
  WriteStdout(VResponse, True);
end;

procedure CreateAplicationNode(ADir, AName: string);
var
  VProject: string;
  VSettings: string;
  VResponse: TJSONObject;
begin
  if (not (DirectoryIsWritable(ADir))) then
  begin
    WriteStdout('Invalid project directory: "' + ADir + '"');
  end;
  VProject := AppendPathDelim(ADir) + AName + '.lpr';
  if (FileExistsUTF8(VProject)) then
  begin
    WriteStdout(AName + '.lpr already exists');
  end;
  VSettings := AppendPathDelim(ADir) + AName + '.lpr.json';
  if (FileExistsUTF8(VSettings)) then
  begin
    WriteStdout(AName + '.lpr.json already exists');
  end;
  // Save
  WriteFile(VProject, TemplateProject(AName));
  WriteFile(VSettings, TemplateSettings(AName, 'node'));
  VResponse := TJSONObject.Create();
  VResponse.Add('project', VProject);
  VResponse.Add('settings', VSettings);
  WriteStdout(VResponse, True);
end;

procedure CreateAplicationWebBrowser(ADir, AName: string);
var
  VProject: string;
  VSettings: string;
  VHtml: string;
  VResponse: TJSONObject;
begin
  if (not (DirectoryIsWritable(ADir))) then
  begin
    WriteStdout('Invalid project directory: "' + ADir + '"');
  end;
  VProject := AppendPathDelim(ADir) + AName + '.lpr';
  if (FileExistsUTF8(VProject)) then
  begin
    WriteStdout(AName + '.lpr already exists');
  end;
  VSettings := AppendPathDelim(ADir) + AName + '.lpr.json';
  if (FileExistsUTF8(VSettings)) then
  begin
    WriteStdout(AName + '.lpr.json already exists');
  end;
  VHtml := AppendPathDelim(ADir) + AName + '.html';
  if (FileExistsUTF8(VHtml)) then
  begin
    WriteStdout(AName + '.html already exists');
  end;
  // Save
  WriteFile(VProject, TemplateProject(AName));
  WriteFile(VSettings, TemplateSettings(AName, 'webbrowser'));
  WriteFile(VHtml, TemplateHtml(AName));
  VResponse := TJSONObject.Create();
  VResponse.Add('project', VProject);
  VResponse.Add('settings', VSettings);
  VResponse.Add('html', VSettings);
  WriteStdout(VResponse, True);
end;

procedure CreateLibrary(ADir, AName: string);
var
  VProject: string;
  VSettings: string;
  VResponse: TJSONObject;
begin
  if (not (DirectoryIsWritable(ADir))) then
  begin
    WriteStdout('Invalid project directory: "' + ADir + '"');
  end;
  VProject := AppendPathDelim(ADir) + AName + '.lpr';
  if (FileExistsUTF8(VProject)) then
  begin
    WriteStdout(AName + '.lpr already exists');
  end;
  VSettings := AppendPathDelim(ADir) + AName + '.lpr.json';
  if (FileExistsUTF8(VSettings)) then
  begin
    WriteStdout(AName + '.lpr.json already exists');
  end;
  // Save
  WriteFile(VProject, TemplateProject(AName, True));
  WriteFile(VSettings, TemplateSettings(AName, '', ''));
  VResponse := TJSONObject.Create();
  VResponse.Add('project', VProject);
  VResponse.Add('settings', VSettings);
  WriteStdout(VResponse, True);
end;

procedure CreateSettings(ADir, AName: string);
var
  VSettings: string;
  VResponse: TJSONObject;
begin
  if (not (DirectoryIsWritable(ADir))) then
  begin
    WriteStdout('Invalid project directory: "' + ADir + '"');
  end;
  VSettings := AppendPathDelim(ADir) + AName + '.lpr.json';
  if (FileExistsUTF8(VSettings)) then
  begin
    WriteStdout(AName + '.lpr.json already exists');
  end;
  // Save
  WriteFile(VSettings, TemplateSettings('', '', ''));
  VResponse := TJSONObject.Create();
  VResponse.Add('settings', VSettings);
  WriteStdout(VResponse, True);
end;

procedure ProjectCreation(ARequest: TJSONData);
var
  VDir: string;
  VName: string;
  VTemplate: string;
begin
  VDir := ARequest.Path('project.dir', '');
  VName := ARequest.Path('command.project.name', '');
  VTemplate := ARequest.Path('command.project.template', '');
  case VTemplate of
    'Application':
      CreateAplication(VDir, VName);
    'Application Http Server(CGI)':
      CreateAplicationHttpServer(VDir, VName, 'CGI');
    'Application Http Server(FastCGI)':
      CreateAplicationHttpServer(VDir, VName, 'FastCGI');
    'Application Http Server(StandAlone)':
      CreateAplicationHttpServer(VDir, VName, 'StandAlone');
    'Application Node':
      CreateAplicationNode(VDir, VName);
    'Application Web Browser':
      CreateAplicationWebBrowser(VDir, VName);
    'Library':
      CreateLibrary(VDir, VName);
    'Settings':
      CreateSettings(VDir, VName);
    else
    begin
      WriteStdout('Invalid project template');
    end;
  end;
end;

end.
