declare module '*Main.elm' {
  export namespace Elm {
    export namespace Main {
      function init(options: { node: Element }): object;
    }
  }
}

declare const process: { env: { NODE_ENV: string } };
