const Handlebars = require('./handlebars.min-v4.7.6');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

const DEBUG = true;

const AWAITING_COMMAND = 1;
const AWAITING_DATA = 2;
const VALID_COMMANDS = ["render_index", "render_show", "quit"];
let state = { command: undefined, mode: AWAITING_COMMAND };

if (process.argv.length != 3) {
    console.error("Usage: node renderer.js /path/to/generated/dir");
    process.exit(1);
}
const templateDir = process.argv[2];

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
    index: Handlebars.compile(fs.readFileSync(path.resolve(templateDir, 'js/index.handlebars'), { encoding: 'utf8' }),
        { knownHelpers: { ifEqual: true, join: true }, knownHelpersOnly: true }),
    show: Handlebars.compile(fs.readFileSync(path.resolve(templateDir, 'js/show.handlebars'), { encoding: 'utf8' }),
        { knownHelpers: { ifEqual: true, join: true }, knownHelpersOnly: true })
};

// Open a log file, set up our inputs/outputs, and wait for commands.
const logFile = fs.open(path.resolve(__dirname, "debug.log"), "a", (err, fd) => {
    let log = (msg) => {
        if (DEBUG) {
            fs.writeSync(fd, `${new Date()}: ${msg}\n`);
        }
    };

    log("Setting up stdin/stdout");
    log(`TemplateDir was ${templateDir}`);

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
                let attempts = 0;
                while (attempts <= 3) {
                    try {
                        if ("render_index" == state.command) {
                            fs.writeSync(process.stdout.fd, templates["index"](templateVars));
                        } else if ("render_show" == state.command) {
                            fs.writeSync(process.stdout.fd, templates["show"](templateVars));
                        }
                        fs.writeSync(process.stdout.fd, "\n\x1C\n");
                    } catch (e) {
                        if (e instanceof Error && 'EAGAIN' == e.code && attempts < 3) {
                            log(`Failed write attempt ${attempts} for ${state.command}`);
                            attempts += 1;
                        } else {
                            throw e;
                        }
                    }
                }
                log("Finished writing template, awaiting next command");
                state.mode = AWAITING_COMMAND;
            } catch (e) {
                log(`Couldn't generate template for ${state.command}: our input line was ${line}`);
                throw e;
            }
        } else {
            log(`Unexpected input ${line}`);
        }
    });
});
