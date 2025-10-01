export const setResponsePrim = (resPrim) => (code) => (headers) => (body) => () => {
  resPrim.statusCode = code
  for (const [key, value] of headers) {
    resPrim.setHeader(key, value)
  }
  resPrim.end(body)
}
