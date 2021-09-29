const { showError, runTask } = require("./utils");
const { runFpTools } = require("./fptools");

const projectBuilding = async () => {  
    let response = await runFpTools({
        action: "projectBuilding"
    });
    if (!response.success) {
        return showError(response.data);
    };
    // Task
    runTask(response.data, "fp-vscode", ["$freepascal"]); 
};

module.exports = {
    projectBuilding
};
