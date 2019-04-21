# NOpa

An implementation of the algorithm for solving the problem of order preserving assignments without contiguity (N-Opa) created and proved by Dimitris Alevras here:
https://www.sciencedirect.com/science/article/pii/0012365X9500325Q

The N-Opa problem is to maximize the weighted assignments of items to slots while each
successive slot assignment does not break the order of the items (please see the paper for a more precise mathematical definition). You can imagine modeling this problem with a bipartite graph where the final assignment edges never cross.

The primary use for this gem is to determine accurate transit stop distances along route lines where such data is not provided. See https://github.com/transitland/transitland-datastore/pull/1271

The implementation is iterative instead of recursive, and allows for costs instead of profits.

D Alevras,  
Order preserving assignments without contiguity  
Discrete Mathematics, 163 (1997), pp. 1-11

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'n_opa', git: 'git@github.com:doublestranded/n_opa', branch: 'master'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install n_opa

## Usage

```
algo = NOpa::DynamicAlgorithm.new(input_matrix)
algo.compute
```

access assignments with `algo.assignments`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/doublestranded/n_opa.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
