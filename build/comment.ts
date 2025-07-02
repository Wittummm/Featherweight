import * as fs from 'fs';

const filePath = './shaders/options.ts'; // change to your target file

const content = fs.readFileSync(filePath, 'utf8');
const lines = content.split('\n');

const commentedLines = lines.map(line => {
  if (line.includes('generateLangDummy')) {
    if (!line.trimStart().startsWith('//')) {
      return '//' + line;
    }
  }
  if (line.includes('generateLang()') || line.includes('build/generateLang"')) {
    if (line.trimStart().startsWith('//')) {
      return line.replace(/^(\s*)\/\/\s?/, '');
    }
  }
  return line;
});

fs.writeFileSync(filePath, commentedLines.join('\n'), 'utf8');
console.log("Comment in")