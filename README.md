#Vintage fork
This fork supports ruby 1.8.7 and RSpec 1.x with the old syntax.

# rspec-kickstarter

rspec-kickstarter supports you writing tests for existing code.

[![Build Status](https://travis-ci.org/ifad/rspec-kickstarter-vintage.png)](https://travis-ci.org/ifad/rspec-kickstarter-vintage)
[![Code Climate](https://codeclimate.com/github/ifad/rspec-kickstarter-vintage.png)](https://codeclimate.com/github/ifad/rspec-kickstarter-vintage)

## RubyKaigi 2013

Lightning talk about rspec-kickstarter at RubyKaigi 2013

http://rubykaigi.org/2013/lightning_talks#seratch

https://speakerdeck.com/seratch/a-test-code-generator-for-rspec-users


## Installation

    gem 'rspec-kickstarter', :github => "ifad/rspec-kickstarter-vintage"

## Usage

    rspec-kickstarter ./app
    rspec-kickstarter ./lib
    rspec-kickstarter ./lib/yourapp/util.rb

## Options

```
$ rspec-kickstarter -h
Usage: rspec-kickstarter [options]
    -f                               Create if absent or append to the existing spec
        --force
    -n                               Dry run mode (shows generated code to console)
        --dry-run
    -r                               Run in Rails mode
        --rails
    -o VAL                           Output directory (default: ./spec)
        --output-dir VAL
    -D VAL                           Delta tempalte path (e.g. ./rails_controller_delta.erb)
        --delta-template VAL
    -F VAL                           Full template path (e.g. ./rails_controller_full.erb)
        --full-template VAL
    -v                               Print version
        --version
```

## Output example

Unfortunately, `lib/foo/bar_baz.rb` has no test. That's too bad...

```ruby
module Foo
  class BarBaz

    def self.xxx(a, b = "aaa")
    end

    def yyy()
    end

    private

    def zzz(a)
    end

  end
end
```

OK, run `rspec-kickstarter` now!

```sh
$ rspec-kickstarter lib/foo/bar_baz.rb
./spec/foo/bar_baz_spec.rb created.
```

`spec/foo/bar_baz_spec.rb` will be created as follows.

```ruby
# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'foo/bar_baz'

describe Foo::BarBaz do

  # TODO auto-generated
  describe '#xxx' do
    it 'works' do
      a = double('a')
      b = double('b')
      result = Foo::BarBaz.xxx(a, b)
      expect(result).not_to be_nil
    end
  end

  # TODO auto-generated
  describe '#yyy' do
    it 'works' do
      bar_baz = Foo::BarBaz.new
      result = bar_baz.yyy()
      expect(result).not_to be_nil
    end
  end

end
```

## Appending lacking test templates

`-f` option allows appending lacking test templates to existing specs.

For instance, `additiona_ops` method is added after spec creation.

```ruby
module Foo
  class BarBaz

    def self.xxx(a, b = "aaa")
    end

    def yyy()
    end

    def additional_ops
    end

    private

    def zzz(a)
    end

  end
end
```

Execute command.

`rspec-kickstarter -f lib/foo/bar_baz.rb`

The following code will be appended.

```ruby

  # TODO auto-generated
  describe '#additional_ops' do
    it 'works' do
      bar_baz = Foo::BarBaz.new
      result = bar_baz.additional_ops()
      expect(result).not_to be_nil
    end
  end

end
```

## Rails mode

In Rails mode, rspec-kcikstarter generates Rails way spec code for controllers and helpers.

```
$ rspec-kickstarter -r app/controllers/root_controller.rb
```

Output for scaffold:

```ruby
# -*- encoding: utf-8 -*-

require 'spec_helper'

describe CommentsController do

  # TODO auto-generated
  describe 'GET index' do
    it 'works' do
      get :index, {}, {}
      expect(response.status).to eq(200)
    end
  end

  # TODO auto-generated
  describe 'GET show' do
    it 'works' do
      get :show, {}, {}
      expect(response.status).to eq(200)
    end
  end

  # TODO auto-generated
  describe 'GET new' do
    it 'works' do
      get :new, {}, {}
      expect(response.status).to eq(200)
    end
  end

  # TODO auto-generated
  describe 'GET edit' do
    it 'works' do
      get :edit, {}, {}
      expect(response.status).to eq(200)
    end
  end

  # TODO auto-generated
  describe 'POST create' do
    it 'works' do
      post :create, {}, {}
      expect(response.status).to eq(200)
    end
  end

  # TODO auto-generated
  describe 'PUT update' do
    it 'works' do
      put :update, {}, {}
      expect(response.status).to eq(200)
    end
  end

  # TODO auto-generated
  describe 'DELETE destroy' do
    it 'works' do
      delete :destroy, {}, {}
      expect(response.status).to eq(200)
    end
  end

end
```


## Customizable code template

Try the template_samples.

```
ruby -Ilib bin/rspec-kickstarter --delta-template=samples/delta_template.erb --full-template=samples/full_template.erb lib/foo.rb -n
```

When you use customized templates for your apps, `gem install rspec-kickstarter` and do like this:

```
rspec-kickstarter lib -D misc/delta_template.erb -F misc/full_template.erb
```

## License

Copyright (c) 2013 Kazuhiro Sera

MIT License

https://github.com/seratch/rspec-kickstarter/blob/master/LICENSE.txt

