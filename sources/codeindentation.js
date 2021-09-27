const vscode = require("vscode");
const { runFpTools } = require("./fptools");
const { editorAddContent, editorModifiedFiles, showError } = require("./utils");

async function codeIndentation() { 
    let editor = vscode.window.activeTextEditor;
    if (!editor) {
        return
    };  
    let response = await runFpTools({
        action: "codeIndentation",
        path: editor.document.uri.fsPath, 
        updates: await editorModifiedFiles()
    }); 
    if (!response.success) {
        return showError(response.data); 
    }
    editorAddContent(editor, response.data, 0, 0); 
};

module.exports = {
    codeIndentation
}; 