let verbose = false;
const logger = console;

module.exports = {
    setVerbose: v => {
        verbose = v;
    },
    trace: (...messages) => {
        if (verbose) {
            logger.info(...messages);
        }
    },    
    log: (...messages) => {
        logger.log(...messages);
    },    
    warn: (...messages) => {
        if (verbose) {
            logger.warn(...messages);
        }
    },    
    error: (...messages) => {
        logger.error(...messages);
    }
};