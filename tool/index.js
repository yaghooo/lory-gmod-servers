const path = require('path')
const del = require('del')
var copy = require('recursive-copy')

;(async () => {
  const scheme = require('../servers/.server-scheme.json')
  const options = process.argv.slice(2)

  const isDev = options.some((s) => s === '--dev')
  const servers = options.filter((s) => !s.startsWith('--'))

  await del('../build', { force: true })

  for (const server of servers) {
    const paths = [
      ...(scheme.production[server].paths || []),
      ...(isDev && scheme.developing[server].paths || []),
    ].map(p => path.join('../servers', p).replace(/\\/g, '/'))

    const filters = [
      "*",
      ...(scheme.production[server].filters || []),
      ...(isDev && scheme.developing[server].filters || []),
    ]

    for (const relativePath of paths) {      
      await copy(relativePath, path.join('../build/', server), { filter: filters })
    }
  }

  console.log('Build succeed')
})()
