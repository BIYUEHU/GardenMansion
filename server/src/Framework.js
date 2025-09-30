// @ts-check
import { createServer } from 'node:http'

export const createServerPrim = (callback) => tuple => (parseMethod) => () =>
  createServer((req, res) => {
    let body = ''
    req.on('data', (chunk) => {
      body += chunk.toString()
    })
      const url = new URL(req.url ?? '', `http://${req.headers.host}`)
    req.on('end', () => {
      try {
        callback(
          // TODO: improve structure
          {
            query: Array.from(url.searchParams).map(([k,v]) => tuple(k)(v)),
            body,
            path: url.pathname,
            headers: Object.entries(req.headers).map(([k,v]) => tuple(k)(v ? Array.isArray(v) ? v.join(',') : v : '')),
            url: req.url ?? '',
            method: parseMethod(req.method ?? 'GET')
          })(res)()
      } catch (error) {
        console.error('PureScript Error:', error)
        res.statusCode = 500
        res.end('Internal Server Error')
      }
    })
  })

export const setResponsePrim = (resPrim) => (code) => (headers) => (body) => () => {
  resPrim.statusCode = code
  for (const [key, value] of headers) {
    resPrim.setHeader(key, value)
  }
  resPrim.end(body)
}

export const listen = (server) => (port) => (callback) => () => {
  server.listen(port, () => {
    callback()
  })
}

export const close = (server) => () => {
  server.close()
}
