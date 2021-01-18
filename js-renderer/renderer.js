const Handlebars = require('./handlebars.min-v4.7.6');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

const AWAITING_COMMAND = 1;
const AWAITING_DATA = 2;
const VALID_COMMANDS = ["render_index", "render_show", "render_navigation", "quit"];
let state = { command: undefined, mode: AWAITING_COMMAND };

// Set up Handlebars templates
Handlebars.registerHelper("ifEqual", function(a, b, options) {
    if (a == b) {
        options.fn(this);
    }
});
Handlebars.registerHelper("join", (items, separator) => {
    return items.join(separator);
});

const templates = {
    index: Handlebars.compile(fs.readFileSync(path.resolve(__dirname, `../generated/js/index.handlebars`), { encoding: 'utf8' }),
        { knownHelpers: { ifEqual: true, join: true }, knownHelpersOnly: true }),
    show: Handlebars.compile(fs.readFileSync(path.resolve(__dirname, `../generated/js/show.handlebars`), { encoding: 'utf8' }),
        { knownHelpers: { ifEqual: true, join: true }, knownHelpersOnly: true }),
    navigation: Handlebars.compile(fs.readFileSync(path.resolve(__dirname, `../generated/js/navigation.handlebars`), { encoding: 'utf8' }),
        { knownHelpers: { ifEqual: true, join: true }, knownHelpersOnly: true })
};

// Open a log file, set up our inputs/outputs, and wait for commands.
const logFile = fs.open(path.resolve(__dirname, "debug.log"), "a", (err, fd) => {
    let log = (msg) => fs.writeSync(fd, `${new Date()}: ${msg}\n`);

    log("Setting up stdin/stdout");

    process.stdin.setEncoding('utf-8');
    process.stdout.setEncoding('utf-8');
    const io = readline.createInterface({ input: process.stdin, output: process.stdout });

    io.on('line', (line) => {
        if (AWAITING_COMMAND == state.mode && VALID_COMMANDS.includes(line)) {
            log(`Received command ${line}`);
            state.command = line;
            state.mode = AWAITING_DATA;

            if ("quit" == state.command) {
                log("Quitting on request");
                process.exit(0);
            }
        } else if (AWAITING_DATA == state.mode) {
            log(`Generating page ${state.command}.`);

            try {
                let templateVars = JSON.parse(line);
                if ("render_index" == state.command) {
                    fs.writeSync(process.stdout.fd, templates["index"](templateVars));
                } else if ("render_show" == state.command) {
                    fs.writeSync(process.stdout.fd, templates["show"](templateVars));
                } else if ("render_navigation" == state.command) {
                    fs.writeSync(process.stdout.fd, templates["navigation"](templateVars));
                }
                fs.writeSync(process.stdout.fd, "\n\x1C\n");
                log("Finished writing template, awaiting next command");
                state.mode = AWAITING_COMMAND;
            } catch (e) {
                log(`Couldn't generate template: our input line was ${line}`);
                throw e;
            }
        } else {
            log(`Unexpected input ${line}`);
        }
    });
});
