const Handlebars = require('./handlebars.min-v4.7.6');
const fs = require('fs');
const path = require('path');

// Read in command line arguments
if (process.argv.length < 3) {
    console.warn("Not enough arguments: must specify a template and an output file on the CLI.");
    process.exit(1);
}

let template = process.argv[2];

// Set up Handlebars templates
Handlebars.registerHelper("ifEqual", function(a, b, options) {
    if (a == b) {
        options.fn(this);
    }
});
Handlebars.registerHelper("join", (items, separator) => {
    return items.join(separator);
});

const templateString = fs.readFileSync(path.resolve(__dirname, `../generated/js/${template}.handlebars`), { encoding: 'utf-8' });
const templateFn = Handlebars.compile(templateString);
const logFile = fs.open(path.resolve(__dirname, "debug.log"), "a", (err, fd) => {
    fs.writeSync(fd, "About to set up event listeners on STDIN\n");
    let chunks = [];
    process.stdin.setEncoding('utf-8');
    process.stdin.on('readable', () => {
        fs.writeSync(fd, "Read a chunk");
        let chunk;
        while(null !== (chunk = process.stdin.read())) {
            chunks.push(chunk);
        }
    });
    process.stdin.on('end', () => {
        fs.writeSync(fd, "Read the last chunk");
        const templateVars = JSON.parse(chunks.join(""));
        fs.writeFile(process.stdout.fd, templateFn(templateVars), (err) => {
            if (err) {
                console.error(`Couldn't create output file: ${err}`);
                process.exit(1);
            }
        });
        fs.writeSync(fd, "All done, quitting.");
    });
    fs.writeSync(fd, "Event listeners all configured.\n");
    process.stdin.resume();
    fs.writeSync(fd, "Attempted to resume stdin.\n");
});
