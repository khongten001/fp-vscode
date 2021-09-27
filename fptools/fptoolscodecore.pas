unit fptoolscodecore;

{$i fptools.inc}

interface

uses
  fpjson;

procedure CodetoolsLoad(ARequest: TJSONData);
procedure CodetoolsUpdate(ARequest: TJSONData);

implementation

uses
  SysUtils,
  LazFileUtils,
  CodeToolManager,
  CodeToolsConfig,
  DefineTemplates,
  CodeCache,
  SourceChanger,
  // fptools
  fptoolsutils;

procedure CodetoolsLoad(ARequest: TJSONData);
var
  VDir: string;
  VSettings: TJSONData;
  VPlataform: string;
  VConfigFile: string;
  VCompilerExecutable: string;
  VCompilerSources: string;
  VCodeToolsOptions: TCodeToolsOptions;
  VIndex: integer;   
  VSearchDirs: TJSONData;
  VSearchDir: string;  
  VIncludeDirs: TJSONData;
  VIncludeDir: string;
begin
  try
    VDir := ARequest.Path('project.dir', '');
    if (not (DirectoryIsWritable(VDir))) then
    begin
      WriteStdout('Invalid project directory: "' + VDir + '"');
    end;
    VSettings := TJSONData.ParseFile(ARequest.Path('project.settings', ''));
    if (not (Assigned(VSettings))) then
    begin
      WriteStdout('Invalid project settings: "' +
        ARequest.Path('project.settings', '') + '"');
    end;
    VPlataform := VSettings.Path('plataform', '');
    if (VPlataform = 'node') or (VPlataform = 'webbrowser') then
    begin
      VConfigFile := AppendPathDelim(ExtractFilePath(ParamStr(0))) + 'pas2js.xml';
      VCompilerExecutable := ARequest.Path('config.pas2js.executable', '');
      VCompilerSources := ARequest.Path('config.pas2js.sources', '');
    end
    else
    begin
      VConfigFile := AppendPathDelim(ExtractFilePath(ParamStr(0))) + 'fpc.xml';
      VCompilerExecutable := ARequest.Path('config.freepascal.executable', '');
      VCompilerSources := ARequest.Path('config.freepascal.sources', '');
    end;
    // Initialize
    if (FileExistsUTF8(VConfigFile)) then
    begin
      CodeToolBoss.SimpleInit(VConfigFile);
    end;
    // Recreate
    if (FileExistsUTF8(VCompilerExecutable)) and
      (DirectoryExistsUTF8(VCompilerSources)) and
      (AppendPathDelim(VCompilerSources) <> AppendPathDelim(
      CodeToolBoss.GlobalValues[ExternalMacroStart + 'FPCSrcDir'])) then
    begin
      try
        VCodeToolsOptions := TCodeToolsOptions.Create;
        VCodeToolsOptions.InitWithEnvironmentVariables;
        VCodeToolsOptions.FPCPath := VCompilerExecutable;
        VCodeToolsOptions.FPCSrcDir := VCompilerSources;
        // Initialize
        CodeToolBoss.Init(VCodeToolsOptions);
        // Save
        VCodeToolsOptions.SaveToFile(VConfigFile);
      finally
        FreeAndNil(VCodeToolsOptions);
      end;
    end;
    // Mapping directories
    // Project dir
    CodeToolBoss.DefineTree.Add(TDefineTemplate.Create('project dir',
      'project dir', SrcPathMacroName, SrcPathMacro + ';' +
      ExpandPaths(VDir, ''), da_DefineRecurse));
    // Search dir
    VSearchDirs := VSettings.Path('searchDir');
    if (Assigned(VSearchDirs)) then
    begin
      VSearchDir := '';
      for VIndex := 0 to (VSearchDirs.Count - 1) do
      begin
        if (VIndex = 0) then
        begin
          VSearchDir += VSearchDirs.Items[VIndex].AsString;
        end
        else
        begin
          VSearchDir += ';' + VSearchDirs.Items[VIndex].AsString;
        end;
      end;
      if (VSearchDir <> '') then
      begin
        CodeToolBoss.DefineTree.Add(TDefineTemplate.Create('search dir',
          'search dir', SrcPathMacroName, SrcPathMacro + ';' +
          ExpandPaths(VSearchDir, VDir), da_DefineRecurse));
      end;
    end;
    // Include dir
    VIncludeDirs := VSettings.Path('includeDir');
    if (Assigned(VIncludeDirs)) then
    begin
      VIncludeDir := '';
      for VIndex := 0 to (VIncludeDirs.Count - 1) do
      begin
        if (VIndex = 0) then
        begin
          VIncludeDir += VIncludeDirs.Items[VIndex].AsString;
        end
        else
        begin
          VIncludeDir += ';' + VIncludeDirs.Items[VIndex].AsString;
        end;
      end;
      if (VIncludeDir <> '') then
      begin
        CodeToolBoss.DefineTree.Add(TDefineTemplate.Create('include dir',
          'include dir', IncludePathMacroName, IncludePathMacro +
          ';' + ExpandPaths(VIncludeDir, VDir), da_DefineRecurse));
      end;
    end;
  except
    on E: Exception do
    begin
      // Reset
      DeleteFileUTF8(VConfigFile);
      // Return
      WriteStdout(E.Message);
    end;
  end;
end;

procedure CodetoolsUpdate(ARequest: TJSONData);
var
  VIndex: integer;
  VUpdates: TJSONData;
  VUpdate: TJSONData;
  VPath: string;
  VSource: string;
  VCodeBuffer: TCodeBuffer;
  VCodeTool: TCodeTool;
begin
  VUpdates := ARequest.Path('command.updates');
  if (Assigned(VUpdates)) and (VUpdates.Count > 0) then
  begin
    for VIndex := 0 to (VUpdates.Count - 1) do
    begin
      VUpdate := VUpdates.Items[VIndex];
      if (Assigned(VUpdate)) then
      begin
        VPath := VUpdate.Path('path', '');
        VSource := VUpdate.Path('source', '');
        if (VPath <> '') and (VSource <> '') then
        begin
          VCodeBuffer := CodeToolBoss.LoadFile(VPath, False, False);
          if (CodeToolBoss.Explore(VCodeBuffer, VCodeTool, False, False)) then
          begin
            CodeToolBoss.SourceChangeCache.MainScanner := VCodeTool.Scanner;
            CodeToolBoss.SourceChangeCache.Replace(gtNone, gtNone,
              1, VCodeTool.Scanner.CleanedLen + 1, VSource);
            CodeToolBoss.SourceChangeCache.Apply;
          end;
        end;
      end;
    end;
  end;
end;

end.
