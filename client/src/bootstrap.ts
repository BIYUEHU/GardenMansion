import 'uno.css'
import "./assets/style.css"
import { Elm } from './Main.elm'

Elm.Main.init({ node: document.querySelector('#app') as HTMLElement })
