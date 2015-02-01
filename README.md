# Kakurenbo

Kakurenbo provides soft delete.
Kakurenbo is a re-implementation of [paranoia](http://github.com/radar/paranoia) and [acts\_as\_paranoid](http://github.com/technoweenie/acts_as_paranoid) for Rails4. implemented a function that other gems are not enough.

The usage of the Kakurenbo is very very very simple. Only add `deleted_at`(datetime) to column.
Of course you can use `acts_as_paranoid`.In addition, Kakurenbo has many advantageous.

# Warning
### kakurenbo is deprecated if you use in a new rails project!
### You should use [kakurenbo-puti](http://github.com/alfa-jpn/kakurenbo-puti)!


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
# if action is cancelled by callbacks, return false.
model.destroy

# if action is cancelled by callbacks, raise ActiveRecord::RecordNotDestroyed.
model.destroy!

# selected model will be destroyed.
Model.where(:foo => 'bar').destroy_all
```

when want without callbacks.

``` ruby
model.delete

# selected model will be deleted.
Model.where(:foo => 'bar').delete_all
```

### restore a record

``` ruby
# if action is cancelled by callbacks, return false.
model.restore

# if action is cancelled by callbacks, raise ActiveRecord::RecordNotRestored.
model.restore!
```
When restore, call restore callbacks.`before_restore` `after_restore`


### hard-delete
 Use hard option.
``` ruby
model.destroy(hard: true)

# without callbacks.
model.delete(hard: true)

# selected model will be destroyed.
Model.where(:foo => 'bar').destroy_all(nil, hard: true)

# selected model will be destroyed.
Model.where(:foo => 'bar').delete_all(nil, hard: true)
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
