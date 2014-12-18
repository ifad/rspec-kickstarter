# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'rspec_kickstarter/generator'

describe RSpecKickstarter::Generator do

  let(:generator) { RSpecKickstarter::Generator.new('tmp/spec') }

  describe '#new' do
    it 'works without params' do
      result = RSpecKickstarter::Generator.new
      result.should_not be_nil
    end
    it 'works' do
      spec_dir = './spec'

      result = RSpecKickstarter::Generator.new(spec_dir)
      result.should_not be_nil
    end
  end

  describe '#get_complete_class_name' do
    it 'works' do
      parent = double(:parent, :name => nil)
      c = double(:c, :parent => parent)
      name = 'ClassName'

      result = generator.get_complete_class_name(c, name)
      result.should == 'ClassName'
    end
  end

  describe '#instance_name' do
    it 'works' do
      c = double(:c, :name => 'generator')

      result = generator.instance_name(c)
      result.should == 'generator'
    end
  end

  describe '#to_param_names_array' do
    it 'works' do
      params = "(a, b = 'foo', c = 123)"

      result = generator.to_param_names_array(params)
      result.should == ['a', 'b', 'c']
    end
  end

  describe '#get_params_initialization_code' do
    it 'works' do
      method = double(:method, :params => "(a = 1,b = 'aaaa')")

      result = generator.get_params_initialization_code(method)
      result.should == "      a = double('a')\n      b = double('b')\n"
    end
  end

  describe '#get_instantiation_code' do
    it 'works with modules' do
      method = double(:method, :singleton => true, :name => 'do_something')
      c = double(:c, :name => 'Foo', :method_list => [method])

      result = generator.get_instantiation_code(c, method)
      result.should == ''
    end

    it 'works with classes' do
      parent = double(:parent, :name => nil)
      method = double(:method, :singleton => false, :name => 'do_something')
      c = double(:c, :name => 'Foo', :parent => parent, :method_list => [method])

      result = generator.get_instantiation_code(c, method)
      result.should == "      foo = Foo.new\n"
    end
  end

  describe '#get_method_invocation_code' do
    it 'works with modules' do
      parent = double(:parent, :name => nil)
      method = double(:method, :singleton => true, :name => 'do_something', :params => '(a, b)', :block_params => '')
      c = double(:c, :name => 'Module', :parent => parent, :method_list => [method])

      result = generator.get_method_invocation_code(c, method)
      result.should == 'Module.do_something(a, b)'
    end
    it 'works with classes' do
      parent = double(:parent, :name => 'Module')
      method = double(:method, :singleton => false, :name => 'do_something', :params => '(a, b)', :block_params => '')
      c = double(:c, :name => 'ClassName', :parent => parent, :method_list => [method])

      result = generator.get_method_invocation_code(c, method)
      result.should == 'class_name.do_something(a, b)'
    end
  end

  describe '#get_block_code' do
    it 'works with no arg' do
      method = double(:method, :block_params => '')

      result = generator.get_block_code(method)
      result.should == ''
    end
    it 'works with 1 arg block' do
      method = double(:method, :block_params => 'a')

      result = generator.get_block_code(method)
      result.should == ' { |a| }'
    end
    it 'works with 2 args block' do
      method = double(:method, :block_params => 'a, b')

      result = generator.get_block_code(method)
      result.should == ' { |a, b| }'
    end
  end

  class CannotExtractTargetClass < RSpecKickstarter::Generator
    def extract_target_class_or_module(top_level)
      nil
    end
  end

  describe '#write_spec' do

    it 'just works' do
      file_path = 'lib/rspec_kickstarter.rb'
      generator.write_spec(file_path)
    end

    it 'works with -f option' do
      file_path = 'lib/rspec_kickstarter.rb'
      generator.write_spec(file_path, true)
    end

    it 'works with -n option' do
      file_path = 'lib/rspec_kickstarter.rb'
      generator.write_spec(file_path, false, true)
    end

    it 'works with no target class' do
      file_path = 'lib/rspec_kickstarter.rb'
      CannotExtractTargetClass.new.write_spec(file_path, true)
    end

    it 'creates new spec with full_tempalte' do
      FileUtils.rm_rf('tmp/spec') if File.exist?('tmp/spec')
      FileUtils.mkdir_p('tmp/spec')

      code = <<CODE
class Foo
  def hello; 'aaa'; end
end
CODE
      FileUtils.mkdir_p('tmp/lib')
      File.open('tmp/lib/foo.rb', 'w') { |f| f.write(code) }

      generator.full_template = 'samples/full_template.erb'
      generator.write_spec('tmp/lib/foo.rb')
    end

    it 'appends new cases' do
      FileUtils.rm_rf('tmp/spec') if File.exist?('tmp/spec')
      FileUtils.mkdir_p('tmp/spec')

      code = <<CODE
class Foo
  def hello; 'aaa'; end
end
CODE
      FileUtils.mkdir_p('tmp/lib')
      File.open('tmp/lib/foo.rb', 'w') { |f| f.write(code) }

      generator.write_spec('tmp/lib/foo.rb')

      code2 = <<CODE
class Foo
  def hello; 'aaa'; end
  def bye; 'aaa'; end
end
CODE
      File.open('tmp/lib/foo.rb', 'w') { |f| f.write(code2) }
      generator.write_spec('tmp/lib/foo.rb', true, true)
      generator.write_spec('tmp/lib/foo.rb', true)
    end

    it 'appends new cases with delta_template' do
      FileUtils.rm_rf('tmp/spec') if File.exist?('tmp/spec')
      FileUtils.mkdir_p('tmp/spec')

      code = <<CODE
class Foo
  def hello; 'aaa'; end
end
CODE
      FileUtils.mkdir_p('tmp/lib')
      File.open('tmp/lib/foo.rb', 'w') { |f| f.write(code) }

      generator.delta_template = 'sample/delta_template.erb'
      generator.write_spec('tmp/lib/foo.rb')

      code2 = <<CODE
class Foo
  def hello; 'aaa'; end
  def bye; 'aaa'; end
end
CODE
      File.open('tmp/lib/foo.rb', 'w') { |f| f.write(code2) }
      generator.write_spec('tmp/lib/foo.rb', true, true)
      generator.write_spec('tmp/lib/foo.rb', true)
    end

    it 'works with rails controllers' do 
      FileUtils.rm_rf('tmp/spec') if File.exist?('tmp/spec')
      FileUtils.mkdir_p('tmp/spec')

      code = <<CODE
class FooController
end
CODE
      FileUtils.mkdir_p('tmp/app/controllers')
      File.open('tmp/app/controllers/foo_controller.rb', 'w') { |f| f.write(code) }
      generator.write_spec('tmp/app/controllers/foo_controller.rb', true, false, true)

      code = <<CODE
class FooController
  def foo
  end
end
CODE
      File.open('tmp/app/controllers/foo_controller.rb', 'w') { |f| f.write(code) }
      generator.write_spec('tmp/app/controllers/foo_controller.rb', true, false, true)
    end

    it 'works with rails helpers' do
      FileUtils.rm_rf('tmp/spec') if File.exist?('tmp/spec')
      FileUtils.mkdir_p('tmp/spec')

      code = <<CODE
class FooHelper
end
CODE
      FileUtils.mkdir_p('tmp/app/helpers')
      File.open('tmp/app/helpers/foo_helper.rb', 'w') { |f| f.write(code) }
      generator.write_spec('tmp/app/helpers/foo_helper.rb', true, false, true)

      code = <<CODE
class FooHelper
  def foo
  end
end
CODE
      File.open('tmp/app/helpers/foo_helper.rb', 'w') { |f| f.write(code) }
      generator.write_spec('tmp/app/helpers/foo_helper.rb', true, false, true)
    end

  end

  describe '#get_spec_path' do
    it 'works' do
      file_path = 'lib/foo/bar.rb'
      result = generator.get_spec_path(file_path)
      result.should == 'tmp/spec/foo/bar_spec.rb'
    end
    it 'works with path which starts with current dir' do
      file_path = './lib/foo/bar.rb'
      result = generator.get_spec_path(file_path)
      result.should == 'tmp/spec/foo/bar_spec.rb'
    end
  end

  describe '#to_string_value_to_require' do
    it 'works' do
      file_path = 'lib/foo/bar.rb'
      result = generator.to_string_value_to_require(file_path)
      result.should == 'foo/bar'
    end
  end


  describe '#get_rails_helper_method_invocation_code' do
    it 'works' do
      parent = double(:parent, :name => nil)
      c = double(:c, :name => 'ClassName', :parent => parent)
      method = double(:method, :singleton => false, :name => 'do_something', :params => '(a, b)', :block_params => '')

      result = generator.get_rails_helper_method_invocation_code(method)
      result.should == 'do_something(a, b)'
    end
  end

  describe '#get_rails_http_method' do
    it 'works' do
      generator.get_rails_http_method('foo').should == 'get'
      generator.get_rails_http_method('index').should == 'get'
      generator.get_rails_http_method('new').should == 'get'
      generator.get_rails_http_method('create').should == 'post'
      generator.get_rails_http_method('show').should == 'get'
      generator.get_rails_http_method('edit').should == 'get'
      generator.get_rails_http_method('update').should == 'put'
      generator.get_rails_http_method('destroy').should == 'delete'
    end
  end

end
