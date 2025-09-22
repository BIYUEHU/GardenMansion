import { createServer } from 'node:http'

const server = createServer(async (req, res) => {
  const url = new URL(req.url ?? '', `http://${req.headers.host}`)
  const query = Object.fromEntries(url.searchParams.entries())

  let body = ''
  req.on('data', (chunk) => {
    body += chunk.toString()
  })

  req.on('end', () => {
    let parsedBody = {}
    if (req.headers['content-type'] === 'application/json' && body) {
      try {
        parsedBody = JSON.parse(body)
      } catch {
        res.statusCode = 400
        res.end(JSON.stringify({ error: 'Invalid JSON' }))
        return
      }
    }

    // 扩展 req 对象
    const enhancedReq = {
      query,
      b: body,
      body: parsedBody,
      path: url.pathname,
      method: req.method,
      headers: req.headers,
      url: req.url ?? '',
      ip: req.socket.remoteAddress ?? ''
    }

    console.log(enhancedReq)

    res.statusCode = 404
    res.setHeader('Content-Type', 'application/json')
    res.end(JSON.stringify({ error: 'Not found' }))
  })
})

server.listen(3000, () => {
  console.log('Server running on http://localhost:3000')
})
