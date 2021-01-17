const Handlebars = require('./handlebars.min-v4.7.6');
const fs = require('fs');

// Read in command line arguments
if (process.argv.length < 4) {
    console.warn("Not enough arguments: must specify a template and an output file on the CLI.");
    process.exit(1);
}

let template = process.argv[2];
let outputFile = process.argv[3];

// Set up Handlebars templates
Handlebars.registerHelper("ifEqual", function(a, b, options) {
    if (a == b) {
        options.fn(this);
    }
});
Handlebars.registerHelper("join", (items, separator) => {
    return items.join(separator);
});

const templateString = fs.readFileSync(`../generated/js/${template}.handlebars`, { encoding: 'utf-8' });
const templateFn = Handlebars.compile(templateString);
const json = JSON.parse(fs.readFileSync(process.stdin.fd, { encoding: 'utf-8' }));

console.log(`Rendering template to ${outputFile}...`)
fs.writeFile(outputFile, templateFn(json), (err) => {
    if (err) {
        console.error(`Couldn't create output file: ${err}`);
        process.exit(1);
    } else {
        console.log("Done.");
    }
});
