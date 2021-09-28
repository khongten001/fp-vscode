const vscode = require("vscode"); 
const { codeCompletion } = require("./codecompletion");
const { codeIndentation } = require("./codeindentation");
const { codeRefactoring } = require("./coderefactoring");
const { provideCompletionItems } = require("./codesuggestion");
const { provideDefinition } = require("./codedefinition");
const { projectBuilding } = require("./projectbuilding");
const { projectCreation } = require("./projectcreation");
const { projectLoading } = require("./projectsettings");

const activate = (context) => {  
    context.subscriptions.push([  
        // Commands  
        vscode.commands.registerCommand("freepascal.projectLoading", projectLoading),
        vscode.commands.registerCommand("freepascal.projectCreation", projectCreation),
        vscode.commands.registerCommand("freepascal.projectBuilding", projectBuilding),  
        vscode.commands.registerCommand('freepascal.codeCompletion', codeCompletion),
        vscode.commands.registerCommand('freepascal.codeIndentation', codeIndentation),
        vscode.commands.registerCommand('freepascal.codeRefactoring', codeRefactoring),
        
        // Languages
        vscode.languages.registerDefinitionProvider("objectpascal", { provideDefinition }),
        vscode.languages.registerCompletionItemProvider("objectpascal", { provideCompletionItems }, "."),
    ])
};

module.exports = {
    activate
};