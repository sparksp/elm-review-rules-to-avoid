# elm-review-rules-to-avoid

Provides some elm-analyse rules for [`elm-review`](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) that we don't want to publish. These are written to demonstrate that just because you can write a rule doesn't mean you should!


## Provided rules

- [`NoSingleFieldRecord`](https://elm-doc-preview.netlify.app/NoSingleFieldRecord?repo=sparksp/elm-review-rules-to-avoid) - Reports records containing a single field.


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
elm-review --template sparksp/elm-review-rules-to-avoid/preview
```
