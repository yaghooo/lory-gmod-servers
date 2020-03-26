const yargs = require('yargs');
const { start } = require('./core');
const { setVerbose } = require('./utils/logger');

yargs
    .middleware((argv) => {
        setVerbose(argv.verbose);
    })
    .command('start [servers...] [options]', 'Start the server', (yargs) => {
        yargs
            .positional('servers', {
                describe: 'Servers to start',
                array: true
            })
            .positional('dir', {
                describe: 'Install location',
                default: '.',
                type: 'string'
            })
            .positional('dev', {
                describe: 'Run on dev mode',
                boolean: true,
            })
            .positional('watch', {
                describe: 'Watch files',
                boolean: true
            })
            .positional('force', {
                describe: 'Force install everything',
                alias: 'f',
                boolean: true
            })
    }, start)
    .option('verbose', {
        alias: 'v',
        boolean: true,
        description: 'Run with verbose logging'
    })
    .help()
    .argv;