[![Build Status](http://travis-ci.org/ajsharp/bldr.png)](http://travis-ci.org/ajsharp/bldr)


# Bldr

Bldr is a minimalist templating library that provides a simple DSL for generating
json documents from ruby objects. It currently supports Sinatra out of
the box -- Rails 3 support is planned for the near future.

If you would like to contribute, pull requests with specs are warmly accepted :)

## Features

* Simple json templating DSL
* Uses Tilt's built-in rendering and template caching for better
  performance

## Installation

There are two ways to use Bldr in your Sinatra app, depending on whether
you are using Sinatra's classic or module application style:

```ruby

# Method 1: Classic style

require 'sinatra/bldr'

get '/hello' do
  bldr :hello
end


# Method 2: Modular style

require 'sinatra/bldr'

class MyApp < Sinatra::Base
  register Sinatra::Bldr
end
```

## Usage

In your sinatra endpoints/actions, use the `bldr` helper method to
render templates.

```ruby
get "/posts" do
  # ...
  posts = Post.all
  bldr :'path/to/template.json', {}, {:posts => posts}
end

# template file

collection :posts => posts do
  attributes :title
  attribute :comment_count { |post| post.comments.count }

  # current_object
  collection :comments => current_object.comments do

  end
end
```

## Examples

### Rendering a simple list of attributes

```ruby
object :post => post do
  attributes :title, :body
end
```

Output:
```javascript
{
  "post": {
    "title": "my title",
      "body": "..."
  }
}
```

### Dynamic attributes

```ruby
object :post => post do
  attribute :comment_count do |post|
    post.comments.count
  end
end
```

Output:

```javascript
{
  "post": {
    "comment_count": 1
  }
}

```

### Attribute aliases

```ruby
object :post => post do
  attributes :title, :body

  object :author => post.author do
    attribute :surname => :last_name
  end
end
```

Output:

```javascript
{
  "post": {
    "title": "my title",
    "body": "...",
    "author": {
      "surname": "Doe"
    }
  }
}
```

### Nested objects

```ruby
object :post => post do
  attributes :title, :body

  object :author => post.author do
    attributes :first_name, :last_name, :email

    attribute(:full_name) { |author| "#{author.first_name}
#{author.last_name}" }
  end
end
```

Output:

```javascript
{
  "post": {
    "title": "my title",
    "body": "...",
    "author": {
      "first_name": "John",
      "last_name": "Doe",
      "email": "john@doe.com",
      "full_name": "John Doe"
    }
  }
}
```

### Root-level attributes

```ruby
get '/redirector' do
  url = params['redirect_url']
  bldr :'redirect.json', :locals => {:url => url}
end

# views/redirect.json.bldr
object do
  attribute(:redirect_to) { url }
end
```

Output:

```javascript
{"redirect_to": "http://example.org"}
```

### Collections

All the examples above can be used inside a collection block:

```ruby
collection :posts => posts do
  attributes :title
  attribute :comment_count { |post| post.comments.count }

  # current_object
  collection :comments => current_object.comments do
    attributes :body, :author_name, :author_email
  end
end
```

Output:

```javascript
{
  "posts": [
    {
      "title": "my title",
        "comment_count": 2,
        "comments": [
          {
            "body": "...",
            "author_name": "Comment Troll",
            "email": "troll@trolling.edu"
          },
          {
            "body": "...",
            "author_name": "Uber Troll",
            "email": "uber.troll@earthlink.net"
          }
        ]
    }
  ]
}
```

When inside of a collection block, you can use the `current_object`
method to access the member of the collection.

### Templates

Your templates should be named with the content type extension before
the .bldr extension. For example: `my_template.json.bldr`. The templates
themselves are just pure ruby code. They are evaluated in the context of a
`Bldr::Node` instance.

## Editor Syntax Support

To get proper syntax highlighting in vim, add this line to your .vimrc:

```
au BufRead,BufNewFile *.bldr set filetype=ruby
```

## TODO

* Rails 3 support
* Replace current_object with a block param for collection methods
* XML support

## Acknowledgements

* [RABL](http://github.com/nesquena/rabl) - Inspiration

## Copyright

Copyright (c) 2011 Alex Sharp. See the MIT-LICENSE file for full
copyright information.
