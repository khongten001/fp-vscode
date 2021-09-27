const vscode = require("vscode");
const cp = require("child_process");

const isDarwin = () => /^darwin/.test(process.platform);

const isLinux = () => /^linux/.test(process.platform);

const isWin = () => /^win/.test(process.platform);

const showError = (message) => {
    return vscode.window.showErrorMessage(message);
};

const showInputBox = (placeHolder, defaultValue, validationFunction) => {
    return vscode.window.showInputBox({
        placeHolder: placeHolder,
        value: defaultValue,
        validateInput: validationFunction
    });
};

const showListBox = (title, list) => {
    return vscode.window.showQuickPick(list, {
        matchOnDescription: true,
        placeHolder: title
    });
};

const runCommand = (bin, stdin) => {
    return new Promise((resolve, reject) => {
        let stdout = "";
        let stderr = "";
        let process = cp.spawn(bin);
        process.stdin.write(stdin, "utf8");
        process.stdin.end();
        process.stdout.on("data", (data) => {
            stdout += data.toString();
        });
        process.stderr.on("data", (data) => {
            stderr += data.toString();
        });
        process.on("error", (error) => {
            reject(error.message);
        });
        process.on("close", (code) => {
            code === 0 ? resolve(stdout) : reject(stderr);
        });
    });
};

const runTask = async (command, name, problemMatchers) => {
    let task = new vscode.Task(
        { type: "shell" }, 
        vscode.TaskScope.Workspace, 
        name, 
        name
    ); 
    task.execution = new vscode.ShellExecution(command);
    task.problemMatchers = problemMatchers;
    task.presentationOptions = {
        echo: false,
        reveal: vscode.TaskRevealKind.Always,
        panel: vscode.TaskPanelKind.Shared,
        clear: true,
        focus: true,
        showReuseMessage: false
    };
    if (vscode.tasks.taskExecutions.length === 0) {
        vscode.tasks.executeTask(task);
    };
};

const editorAddContent = (editor, content, newLine, newColumn) => {
    return new Promise(async (resolve) => {
        let result = await editor.edit((builder) => {
            builder.replace(
                new vscode.Range(0, 0, Number.MAX_VALUE, Number.MAX_VALUE), 
                content
            );
        });
        // Move to
        if (newLine > -1 && newColumn > -1) {
            let position = new vscode.Position(newLine, newColumn);
            editor.selection = new vscode.Selection(position, position);
            editor.revealRange(new vscode.Range(position, position));
        };
        resolve(result);
    });
};

const editorOpenFile = async (file) => {
    let document = await vscode.workspace.openTextDocument(file);
    return vscode.window.showTextDocument(document);
};

const editorModifiedFiles = () => {
    return new Promise((resolve) => {
        let files = [];
        let documents = vscode.workspace.textDocuments;
        for (let document of documents) {
            if (document.isDirty) {
                files.push({
                    path: document.fileName,
                    source: document.getText()
                });
            };
        };
        resolve(files);
    });
};

const createLocation = (path, line, column) => {
    return new vscode.Location(
        vscode.Uri.file(path),
        new vscode.Position(line, column)
    );
};

const getRootDir = () => {
    if (vscode.workspace.workspaceFolders) {
        return vscode.workspace.workspaceFolders[0].uri.fsPath;
    } else {
        return undefined
    }
};

module.exports = {
    isDarwin, isLinux, isWin, showError, showInputBox, showListBox,
    runCommand, runTask, editorAddContent, editorModifiedFiles, editorOpenFile,
    getRootDir, createLocation
};