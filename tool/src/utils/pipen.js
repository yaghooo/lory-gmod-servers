class Pipe {
    _currentQuantity = 0;

    constructor({
        index,
        action,
        max = 0
    }) {
        this.index = index;
        this._action = action;
        this._max = max;
    }

    async execute(nextFactory, state) {
        if (typeof this._action !== 'function') {
            throw new Error('Parameter action should be a function');
        }

        if (this._max > 0 && ++this._currentQuantity > this._max) {
            return;
        }

        try {
            await this._action.call(globalThis, nextFactory(this.index), state);
        } finally {
            this._currentQuantity--;
        }
    }
}

module.exports = class {
    _pipes = [];
    _middlewares = [];

    pipe = options => {
        if (typeof options === 'function') {
            options = {
                action: options
            }
        }

        this._pipes.push(new Pipe({
            ...options,
            index: this._pipes.length
        }))

        return this;
    }

    middleware = action => {
        this._middlewares.push(action);
        return this;
    }

    start = state => new Promise(async (resolve, reject) => {
        if (this._pipes.length === 0) {
            reject('No pipes to execute');
        }

        const nextFactory = currentIndex => state => {
            const nextPipe = this._pipes[currentIndex + 1];

            if (nextPipe) {
                this._middlewares.forEach(m => m.call(globalThis, state, currentIndex));
                nextPipe.execute(nextFactory, state);
            } else {
                resolve(state);
            }
        };

        const result = await this._pipes[0].execute(nextFactory, state);
        resolve(result);
    });
}