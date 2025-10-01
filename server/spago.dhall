{ name = "my-project"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "console"
  , "effect"
  , "either"
  , "lists"
  , "maybe"
  , "prelude"
  , "strings"
  , "transformers"
  , "tuples"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
