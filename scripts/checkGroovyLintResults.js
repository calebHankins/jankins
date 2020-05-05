const fs = require('fs');

// Load and parse linting results
const resultPath = process.argv[2] ? process.argv[2] : './logs/groovyLintResults.json';
console.log(`Attempting to load linting results from ${resultPath}`);
const lintResultsJSON = fs.readFileSync(resultPath);
const lintResults = JSON.parse(lintResultsJSON);

// Check if we have any issues
const { totalFoundNumber } = lintResults.summary;
const logPreamble = 'Groovy linting detected issues!';

if (totalFoundNumber) {
    // If we found issues, print detailed results
    console.error(JSON.stringify(lintResults, null, 1));
    console.error(`${logPreamble} total issues detected: ${totalFoundNumber}`);
} else {
    // If we didn't find issues, print a limited summary
    console.info('No issues detected in groovy linting results.');
}

// Exit with a non-zero return if there were issues detected
process.exit(totalFoundNumber);
