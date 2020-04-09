module.exports = new (class {
    #commands = {}

    addCommand(command, requiredRole, evaluator) {
        this.#commands.push({
            command,
            requiredRole,
            evaluator
        })
    }

    evaluate(msg) {
        const parts = msg.content.split(' ')
        const command = this.#commands.find(c => '!' + c.command === parts[0])

        if (command) {
            if (message.member.roles.find(r => r.name.toLowerCase() === command.requiredRole)){
                command.evaluator()
            }
        }
    }
})()