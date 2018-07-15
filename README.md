# Aliyun

**TODO: Add description**

## Configuration

```elixir
config :aliyun,
  access_key_id: "<your access key id>",
  access_key_secret: "<your access key secret>"
```

## Installation

Add `aliyun` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:aliyun, git: "git@github.com:zhuoyue95/aliyun-elixir-sdk.git"}
  ]
end
```

If the SSH private key is encrypted with a paraphrase and you get an error fetching this dependency, [store your paraphrase in the keychain](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#adding-your-ssh-key-to-the-ssh-agent) would solve this issue.


To remove sensible data from the repository's history:
```bash
git checkout --orphan TEMP_BRANCH
git add -A
git commit -am "Initial commit"
git branch -D master
git branch -m master
git push -f origin master
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm).