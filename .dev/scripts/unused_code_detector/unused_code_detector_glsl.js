const fs = require('fs');
const path = require('path');

// const folderPath = './.dev/scripts/unused_code_detector/input';
const folderPath = "C:/Users/diysh/AppData/Roaming/PollyMC/instances/1.21.6-pre2/.minecraft/aperture_patched";
const contentFiles = [];

class FileData {
  constructor(content) {
    this.content = content;
    this._matchFunctions();
    this._matchVariables()

    this.findUnusedFunctions();
    this.findUnusedVariables();
  }
  content;
  functions = [];
  variables = [];
  unusedFunctions = [];
  unusedVariables = [];
  
  _matchFunctions() {
    const funcDefRegex = /(\w[\w\d_<>]*\s+)+(\w+)\s*\([^)]*\)\s*\{/g;
    
    for (const match of this.content.matchAll(funcDefRegex)) {
      if (!this.functions.includes(match[2])) {
        this.functions.push(match[2]);
      }
    }
  }
  _matchVariables() {
    const varRegex = /(\w[\w\d_<>]*)\s+(\w+)\s*(=\s*[^;]+)?\s*;/g;
    
    for (const match of this.content.matchAll(varRegex)) {;
      const varName = match[2];
      
      if (this.variables.includes(varName)) {
        this.variables.push(varName);
      }
    }
  }
  
  findUnusedFunctions() {
    let lines = this.content.split(";");
    
    for (let func of this.functions) {
      let used = false;
      
      const callRegex = new RegExp(`\\b${func}\\s*\\(`);
      const funcDefRegex = new RegExp(`\\b${func}\\s*\\([^)]*\\)\\s*\\{`);
      for (let line of lines) {
        if (funcDefRegex.test(line)) {
          continue; // Skip function definition
        }

        if (callRegex.test(line)) {
          used = true;
          break; // No need to check further, function is used
        }
      }

      if (!used) {
        this.unusedFunctions.push(func);
      }
    }
  }

  findUnusedVariables() {
    let lines = this.content.split(";");

    for (let variable of this.variables) {
      let used = false;

      const varDefRegex = new RegExp(`\\b\\w+[\\s\\*]+${variable}\\b`);
      const usageRegex = new RegExp(`\\b${variable}\\b`);
      for (let line of lines) {
        if (varDefRegex.test(line)) {
          continue;
        }

        if (usageRegex.test(line)) {
          used = true;
          break;
        }
      }

      if (!used) {
        this.unusedVariables.push(variable);
      }
    }
  }
}


fs.readdir(folderPath, (err, files) => {
  if (err) {
    console.error('Error reading directory:', err);
    return;
  }
  
  files.forEach(file => {
    const fullPath = path.join(folderPath, file);
    
    fs.readFile(fullPath, 'utf8', (err, content) => {
      if (err) {
        console.error(`Error reading file ${fullPath}:`, err);
        return;
      }
      
      let fileResult = new FileData(content);
      contentFiles.push(fileResult);

      console.log("File: "+file)
      console.log("Unused Functions: \n"+fileResult.unusedFunctions.map(fn => `- ${fn}`).join('\n'));
      console.log("Unused Variables: \n"+fileResult.unusedVariables.map(fn => `- ${fn}`).join('\n'));
      console.log("")
    });
  });
});