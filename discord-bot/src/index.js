const Discord = require('discord.js')
const commands = require('./commands')

const client = new Discord.Client()

client.on('ready', () => {
    console.log(`Logged in as ${client.user.tag}!`)
})

client.on('message', async msg => {
    if (msg[0] === '!') {
        commands(msg);
    }
})

client.login(process.env.DISCORD_TOKEN)
