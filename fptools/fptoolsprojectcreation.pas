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

function TemplateSettings(AName, APlataform, VOptions: string): string;
var
  VTemplate: string;
begin
  VTemplate := '{' + LE;
  VTemplate += '    "project": "./' + AName + '.lpr",' + LE;
  VTemplate += '    "searchDir": [],' + LE;
  VTemplate += '    "includeDir": [],' + LE;
  VTemplate += '    "outputDir": "",' + LE;
  VTemplate += '    "plataform": "' + APlataform + '",' + LE;
  VTemplate += '    "customOptions": "' + VOptions + '"' + LE;
  VTemplate += '}';
  Result := VTemplate;
end;

function TemplateProject(AName: string; AIsLibrary: boolean = False): string;
var
  VTemplate: string;
begin
  if (AIsLibrary) then
  begin
    VTemplate := 'library ' + AName + ';' + LE + LE;
  end
  else
  begin
    VTemplate := 'program ' + AName + ';' + LE + LE;
  end;
  VTemplate += '{$mode objfpc}{$H+}' + LE + LE;
  VTemplate += 'uses' + LE;
  VTemplate += '  Classes;' + LE + LE;
  VTemplate += 'begin' + LE;
  VTemplate += 'end.';
  Result := VTemplate;
end;

function TemplateHtml(AName: string): string;
var
  VTemplate: string;
begin
  VTemplate := '<!doctype html>' + LE;
  VTemplate += '<html lang="en">' + LE;
  VTemplate += '<head>' + LE;
  VTemplate += '    <meta http-equiv="Content-type" content="text/html; charset=utf-8">'
    + LE;
  VTemplate += '    <meta name="viewport" content="width=device-width, initial-scale=1">'
    + LE;
  VTemplate += '    <title>' + AName + '</title>' + LE;
  VTemplate += '    <script src="./' + AName + '.js"></script>' + LE;
  VTemplate += '</head>' + LE;
  VTemplate += '<body>' + LE;
  VTemplate += '    <script>rtl.run();</script>' + LE;
  VTemplate += '</body>' + LE;
  VTemplate += '</html>';
  Result := VTemplate;
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
  WriteFile(VSettings, TemplateSettings(AName, 'node',
    '-Jeutf-8 -Jirtl.js -Jc -Jminclude'));
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
  WriteFile(VSettings, TemplateSettings(AName, 'webbrowser',
    '-Jeutf-8 -Ji./rtl.js -Jc -Jminclude'));
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
    'Application': CreateAplication(VDir, VName);
    'Application Node': CreateAplicationNode(VDir, VName);
    'Application Web Browser': CreateAplicationWebBrowser(VDir, VName);
    'Library': CreateLibrary(VDir, VName);
    else
    begin
      WriteStdout('Invalid project template');
    end;
  end;
end;

end.
