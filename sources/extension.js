const vscode = require("vscode"); 
const { codeCompletion } = require("./codecompletion");
const { CodeDefinition } = require("./codedefinition");
const { codeIndentation } = require("./codeindentation");
const { CodeSuggestion } = require("./codesuggestion");
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
        
        // Languages
        vscode.languages.registerDefinitionProvider("objectpascal", new CodeDefinition),
        vscode.languages.registerCompletionItemProvider("objectpascal", new CodeSuggestion, "."),
    ])
};

module.exports = {
    activate
};