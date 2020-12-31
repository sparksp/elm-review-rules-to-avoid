# elm-review-rules-to-avoid

Provides [`elm-review`](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) rules to REPLACEME.


## Provided rules

- [`NoSingleFieldRecord`](https://package.elm-lang.org/packages/sparksp/elm-review-rules-to-avoid/1.0.0/NoSingleFieldRecord) - Reports REPLACEME.


## Configuration

```elm
module ReviewConfig exposing (config)

import NoSingleFieldRecord
import Review.Rule exposing (Rule)

config : List Rule
config =
    [ NoSingleFieldRecord.rule
    ]
```


## Try it out

You can try the example configuration above out by running the following command:

```bash
elm-review --template sparksp/elm-review-rules-to-avoid/example
```
