# -*- coding: utf-8 -*-
# See also
#   http://kerryb.github.com/iprug-rspec-presentation/#1
#   http://www.slideshare.net/Sixeight/introduce-rspecs-matchers
#   http://www.slideshare.net/mitim/rspec-3094456

describe "Introduce RSpec's Matchers" do
  before :all do; end # per-context setup
  before      do; end # per-example setup

  context 'イコール系' do
    it "==:.. 比較の結果が同じか" do
      (2 + 2).should == 4
      [1, 2, 3].should == [1, 2, 3]
    end
    it "eql:. eql?による評価(同じ値か)" do
      a = b = 1
      a.should eql b
    end
    it "equal:. equal?による評価(同じオブジェクトか)" do
      s1 = 'hoge'; s2 = s1; s3 = s1.dup
      s1.should equal s2
      s1.should_not equal s3
    end
    it "match:. 正規表現" do
      'this is a string'.should =~ /^this/
      'this is a string'.should_not =~ /^that/
    end
    it ' ' do; end  # 空行
  end

  context 'be_系' do
    it "be_true:.. 真か"   do; true.should be_true; end
    it "be_false:.. 偽か"  do; false.should be_false; end
    it "be_nil:.. nilか"   do; nil.should be_nil; end
    it "be_empty:.. empty?による評価" do
      Array.new.should be_empty
      Hash.new.should be_empty
      expect {Time.new.should be_empty}.to raise_error(NoMethodError)
    end
    it "be_an_instance_of:. instance_of?による評価" do
      'hoge'.should be_an_instance_of(String)
      'hoge'.should_not be_an_instance_of(Object)
    end
    it "be_a_kind_of:. kind_of?による評価" do
      'hoge'.should be_a_kind_of(String)
      'hoge'.should be_a_kind_of(Object)
    end
    it ' ' do; end  # 空行
  end

  context 'コレクションオブジェクト系' do
    it "have(n).items:.. n個の要素を持っているか" do
      [1, 2, 3].should have(3).items
    end
    it "have_exactly(n).items:. n個の要素を持っているか(should_not☓)" do
      [1, 2, 3].should have_exactly(3).items
    end
    it "have_at_least(n).items:. n個以上の要素を持っているか(should_not☓)" do
      [1, 2, 3].should have_at_least(2).items
    end
    it "have_at_most(n).items:. n個以下の要素を持っているか(should_not☓)" do
      [1, 2, 3].should have_at_most(4).items
    end
    it "have_key:... keyが存在するか" do
      {:a => 'A', :b => 'B', :c => 'C'}.should have_key :a
    end
    it "include:... 値が含まれているか" do
      [1, 2, 3].should include 3
      hash = {:a => 'A', :b => 'B', :c => 'C'}
      hash.should include :a
      hash.should include(:a => 'A')
      # include?による評価
      hash[:a].should include 'A'
    end
    it ' ' do; end  # 空行
  end

  context '例外系' do
    it "to_not raise_error:.. 例外が発生しないか" do
      expect {4 / 2}.to_not raise_error
    end
    it "to raise_error:.. 例外が発生するか" do
      expect {4 / 0}.to raise_error
    end
    it "to raise_error(e):.. e型の例外が発生するか" do
      expect {4 / 0}.to raise_error(ZeroDivisionError)
    end
    it "to raise_error(e,m):. e型でメッセージmの例外が発生するか" do
      expect {4 / 0}.to raise_error(ZeroDivisionError, 'divided by 0')
      # 正規表現も使える
      expect {4 / 0}.to raise_error(ZeroDivisionError, /^divided/)
    end
    it "to throw_symbol:.. シンボルがthrowされるか(？？？)" do
      expect {throw :foo}.to throw_symbol
      expect {throw :foo}.to throw_symbol(:foo)
      expect {throw :foo, 7}.to throw_symbol(:foo, 7)
    end
    it ' ' do; end  # 空行
  end

  context 'その他' do
    it "be_within(5).of(1):.. 数値が1-5の範囲に収まっているか" do
      # 3.should be_close 1, 5 => deprecated
      3.should be_within(5).of(1)
    end
    it "change:... Procオブジェクトが指定された値で変化するか(should_not☓)" do
      array = Array.new(0)
      # sizeが0から1に変化。
      lambda {array << 0}.should change {array.size}.from(0).to(1)
      # sizeが1から2に変化。(別の書き方)
      expect {array << 0}.to change {array.size}.from(1).to(2)
      # さらに1つ増えた(shouldでもtoでも良いみたい)
      expect {array << 0}.should change {array.size}.by(1)
      expect {array << 0}.to change {array.size}.by(1)
    end
    it "satisfy:... ブロックの実行結果が真か" do
      10.should satisfy {|v| v % 5 == 0}
    end
    it "renpond_to(m, m...):. 指定メソッドを全て持つか" do
      'foo'.should respond_to(:upcase)
      'foo'.should respond_to(:upcase, :downcase)
    end
    it "renpond_to(m).with(1).arguments: 指定メソッドとパラメータを持つか" do
      'foo'.should respond_to(:split).with(0).arguments
    end
    it 'be_a_multiple_of: カスタムmatcher' do
      describe 10 do
        it { should be_a_multiple_of(5) } # see Custom matchers.
      end
    end
  end

  after      do; end # per-example teardown
  after :all do; end # per-context teardown
end

### Custom matcherの作り方 ###
RSpec::Matchers.define :be_a_multiple_of do |expected|
  match do |actual|
    actual % expected == 0
  end
  failure_message_for_should do |actual|
    "expected that #{actual} would be a multiple of #{expected}"
  end
  failure_message_for_should_not do |actual|
    "expected that #{actual} would not be a multiple of #{expected}"
  end
  description do
    "be multiple of #{expected}"
  end
end

require 'rspec/core/formatters/documentation_formatter'
module RSpec
  module Core
    module Formatters
      class DocumentationFormatter
        def passed_output(example)
          example.description.gsub!(/:\.+/) do |matched|
            matched.gsub(/\./, "\t")
          end
          green("#{current_indentation}#{example.description}")
        end
      end
    end
  end
end
