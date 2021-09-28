const vscode = require("vscode");
const { runFpTools } = require("./fptools");
const { editorAddContent, editorModifiedFiles, showListBox } = require("./utils");

const codeRefactoringEmptyMethods = async (editor) => {
    let response = await runFpTools({
        action: "codeRefactoringEmptyMethods",
        path: editor.document.uri.fsPath,
        line: editor.selection.anchor.line + 1,
        column: editor.selection.anchor.character + 1,
        updates: await editorModifiedFiles()
    });
    if (!response.success || !response.data.modifield) {
        return
    };
    await editorAddContent(editor, response.data.source, 0, 0);
};

const codeRefactoringUnusedUnits = async (editor) => {
    let response = await runFpTools({
        action: "codeRefactoringUnusedUnits",
        path: editor.document.uri.fsPath,
        updates: await editorModifiedFiles()
    });
    if (!response.success || !response.data.modifield) {
        return
    };
    await editorAddContent(editor, response.data.source, 0, 0);
};

const codeRefactoring = async () => {
    let options = [
        "Remove empty methods",
        "Remove unsed units"
    ];
    let index = options.indexOf(await showListBox("Select an option...", options));
    if (index < 0) {
        return
    };
    let editor = vscode.window.activeTextEditor;
    if (!editor) {
        return
    };
    switch (index) {
        case 0:
            codeRefactoringEmptyMethods(editor);
            break;
        case 1:
            codeRefactoringUnusedUnits(editor);
            break;
    };
};

module.exports = {
    codeRefactoring
}; 