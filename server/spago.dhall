{ name = "my-project"
, dependencies =
  [ "console"
  , "effect"
  , "either"
  , "lists"
  , "maybe"
  , "prelude"
  , "strings"
  , "tuples"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
