const vscode = require("vscode");
const { runFpTools } = require("./fptools");
const { editorAddContent, editorModifiedFiles } = require("./utils");

async function codeCompletion() {
    let editor = vscode.window.activeTextEditor;
    if (!editor) {
        return
    };
    let response = await runFpTools({
        action: "codeCompletion",
        path: editor.document.uri.fsPath,
        line: editor.selection.anchor.line + 1,
        column: editor.selection.anchor.character + 1,
        updates: await editorModifiedFiles()
    });
    if (!response.success) {
        return
    }
    await editorAddContent(
        editor,
        response.data.source,
        response.data.line - 1,
        response.data.column - 1
    );
};

module.exports = {
    codeCompletion
};