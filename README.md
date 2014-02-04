# Kakurenbo

Kakurenbo provides soft delete.
Kakurenbo is a re-implementation of [paranoia](http://github.com/radar/paranoia) and [acts\_as\_paranoid](http://github.com/technoweenie/acts_as_paranoid) for Rails4 and 3. implemented a function that other gems are not enough.

The usage of the Kakurenbo is very very very simple. Only add `deleted_at`(datetime) to column.
Of course you can use `acts_as_paranoid`.In addition, Kakurenbo has many advantageous.


# Installation


```ruby
gem 'kakurenbo'
```

# Usage
You need only to add 'deleted_at' to model.

```shell
rails generate migration AddDeletedAtToModels deleted_at:datetime
```
The model having deleted_at becomes able to soft-delete automatically.

_Kakurenbo provides `acts_as_paranoid` method for compatibility._


## Basic Example

### soft-delete

``` ruby
model.destroy

# This is usable, too.
Model.destroy(id)
Model.destroy([id1,id2,id3])
```

when want without callbacks.

``` ruby
model.delete
```

### restore a record

``` ruby
model.restore!

# This is usable, too.
Model.restore(id)
Model.restore([id1,id2,id3])
```

When restore, call restore callbacks.`before_restore` `after_restore`


### hard-delete


``` ruby
model = Model.new
model.destroy!
```

### check if a record is fotdeleted

``` ruby
model.destroyed?
```

### find with soft-deleted

``` ruby
Model.with_deleted
```


### find only the soft-deleted

``` ruby
Model.only_deleted
```


# License
This gem is released under the MIT license.
