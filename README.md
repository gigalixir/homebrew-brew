# Gigalixir Brew

## How do I install these formulae?
`brew install gigalixir/brew/<formula>`

Or `brew tap gigalixir/brew` and then `brew install <formula>`.


## Formulas
Currently only the `gigalixir` formula is available.


## Documentation
`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).



## Generating new formulae

Use the docker setup to ensure new packages are used:
```
docker build . --no-cache -t gigalixir/brew
docker run -it -v $(pwd):/brew gigalixir/brew
```


## Deploying new formulae

Push the changes up to the default branch
