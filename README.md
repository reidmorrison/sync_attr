sync_attr
=========

Thread-safe Ruby class and instance attributes

* http://github.com/reidmorrison/sync_attr

## Status

DEPRECATED

As of Ruby 1.9 thread safe class variables are now built into Ruby.


Example showing thread-safe behavior now built into Ruby:

```ruby
class A
  def self.value
    @@value ||= begin
      sleep 5
      5
    end
  end
end

first = Thread.new { puts "FIRST: #{A.value}" }
10.times do |i|
  Thread.new { puts "#{i}: #{A.value}" }
end
```

The following output is displayed after 5 seconds:

```
FIRST: 5
0: 5
1: 5
2: 5
3: 5
4: 5
5: 5
6: 5
7: 5
8: 5
9: 5
```

Clearly all the other threads are blocked until the first has completed initializing
the class instance variable `@@value`
