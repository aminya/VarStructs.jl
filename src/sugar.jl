# syntax sugar
const U = Union

# TODO UN{t...} = U{Nothing, t...}
UN{t} = U{Nothing, t}
