{ name = "my-project"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "arrays"
  , "bifunctors"
  , "console"
  , "effect"
  , "either"
  , "foreign"
  , "lists"
  , "maybe"
  , "nonempty"
  , "prelude"
  , "simple-json"
  , "strings"
  , "transformers"
  , "tuples"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
