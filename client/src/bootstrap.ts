/// <reference path="./t.d.ts" />

import 'uno.css'
import './assets/style.css'
import { Elm } from './Main.elm'


if (process.env.NODE_ENV === 'development') {
  const ElmDebugTransform = await import('elm-debug-transformer')

  ElmDebugTransform.register({
    simple_mode: true
  })
}

const root = document.querySelector('#app')

if (root === null) {
  throw new Error('Root element not found')
}

const _app = Elm.Main.init({ node: root })
