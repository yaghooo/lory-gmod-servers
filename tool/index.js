const path = require('path')
const makeDir = require('make-dir')
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

    const serverPath = 'build/' + server
    await makeDir(serverPath)

    for (const relativePath of paths) {
      console.log(relativePath)
      console.log(filters);
      
      await copy(relativePath, path.join('..', serverPath), { filter: filters })
    }
  }

  console.log('Build succeed')
})()
