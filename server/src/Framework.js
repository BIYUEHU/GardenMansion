// @ts-check

import { createServer } from 'node:http'

export const createServerPrim = (callback) => (parseMethod) =>
  createServer((req, res) => {
    let body = ''
    req.on('data', (chunk) => {
      body += chunk.toString()
    })

    req.on('end', () => {
      const url = new URL(req.url ?? '', `http://${req.headers.host}`)
      try {
        callback(
          {
            query: new Map(url.searchParams.entries()),
            body,
            path: url.pathname,
            headers: new Map(Object.entries(req.headers)),
            url: req.url ?? '',
            method: parseMethod(req.method ?? 'GET')
          },
          res
        )
      } catch (error) {
        console.error('PureScript Error:', error)
        res.statusCode = 500
        res.end('Internal Server Error')
      }
    })
  })

export const setResponse = (resPrim) => (code) => (headers) => (body) => {
  resPrim.statusCode = code
  for (const [key, value] of headers) {
    resPrim.setHeader(key, value)
  }
  resPrim.end(JSON.stringify(body))
}
