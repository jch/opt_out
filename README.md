# OptOut

OptOut is a rubygem for tracking unsubscriptions to newsletters.

## Usage

```ruby
OptOut.unsubscribe('newsletters', '5')  # unsubscribe user id '5' from 'newsletters'
OptOut.subscribed?('newsletters', '5')
=> false

OptOut.subscribe('newsletters', '5')  # re-subscribe a user to 'newsletters'
OptOut.subscribed?('newsletters', '5')
=> true

OptOut.unsubscribed?('newsletters', '5')  # another way to query
=> false

OptOut.subscribed('newsletters', '8')  # users are subscribed by default unless explicitly unsubscribed
=> true

['1', '2', '3'].each {|user_id| OptOut.unsubscribe('newsletters', user_id)}
OptOut.unsubscribers  # returns a list of unsubscribed user ids
=> ['1', '2', '3']
```

## Configuration

The persistence backend can be configured to be one of:

* [MemoryAdapter](lib/opt_out/adapters/memory_adapter.rb)
* [RedisAdapter](lib/opt_out/adapters/redis_adapter.rb)
* [ActiveRecordAdapter](lib/opt_out/adapters/active_record_adapter.rb)

For example, to configure OptOut to store unsubscriptions in Redis:

```ruby
OptOut.configure do |c|
  c.adapter = OptOut::Adapters::RedisAdapter
  c.options = {
    :url => 'redis://localhost:6379'
  }
end
```

See individual adapter classes for setup and configuration options. To write a
custom adapter, take a look at [AbstractAdapter](lib/opt_out/adapters/abstract_adapter.rb)


## Development

To run tests, you will need a running redis instance. Add a `.env` file to the
project root to configure where redis lives:

```
REDIS_URL=redis://localhost:6379
```

To run tests:

```sh
$ rake
```
