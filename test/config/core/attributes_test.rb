require 'helper'

describe Config::Core::Attributes do

  let(:klass) {
    Class.new do
      include Config::Core::Attributes

      # This attribute has no default, so it must
      # be defined and may not be nil.
      desc "The name"
      key  :name

      # This attribute has a default of nil, so it
      # does not need to be defined and may be nil.
      desc "The value"
      attr :value, nil

      # This attribute has a default value, so it
      # does not need to be defined but may not be nil.
      desc "Another value"
      attr :other, "ok"

      def to_s
        "[Test Class]"
      end
    end
  }

  describe "the class" do

    subject { klass }

    it "has key attrs" do
      subject.key_attrs.values.must_equal [
        Config::Core::Attributes::ClassMethods::Attr.new(:name, :undefined, "The name")
      ]
    end

    it "has other attrs" do
      subject.other_attrs.values.must_equal [
        Config::Core::Attributes::ClassMethods::Attr.new(:value, nil, "The value"),
        Config::Core::Attributes::ClassMethods::Attr.new(:other, "ok", "Another value")
      ]
    end

    it "allows key to be defined without a description" do
      klass.key :foo
      attr = klass.key_attrs[:foo]
      attr.name.must_equal :foo
      attr.description.must_equal nil
    end

    it "allows an attr to be defined without a description" do
      klass.attr :foo
      attr = klass.other_attrs[:foo]
      attr.name.must_equal :foo
      attr.description.must_equal nil
    end

    describe "#error_messages" do

      describe "when the attribute has no default value" do

        subject { klass.key_attrs[:name] }

        it "is an error for the value to be nil" do
          subject.error_messages(nil).must_equal [
            "missing value for :name (The name)"
          ]
        end
      end

      describe "when the attribute has a default of nil" do

        subject { klass.other_attrs[:value] }

        it "is ok for the value to be nil" do
          subject.error_messages(nil).must_equal []
        end
      end

      describe "when the attribute has a default of NOT nil" do

        subject { klass.other_attrs[:other] }

        it "is an error for the value to be nil" do
          subject.error_messages(nil).must_equal [
            "missing value for :other - default: \"ok\" (Another value)"
          ]
        end
      end

      describe "in general" do

        subject { klass.key_attrs[:name] }

        it "is an error for the value to be an empty string" do
          ["", "  "].each do |str|
            subject.error_messages(str).must_equal [
              "#{str.inspect} is an invalid value for :name (The name)"
            ]
          end
        end

        specify "any other value is ok" do
          ["yay", 123, 5.5, Object.new].each do |value|
            subject.error_messages(value).must_equal []
          end
        end

        it "is an error to not have a description" do
          subject.description = nil
          subject.error_messages("ok").must_equal [
            "missing description for :name"
          ]
        end
      end
    end
  end

  describe "the instance" do

    subject { klass.new }

    it "has default attributes" do
      subject.attributes.must_equal(
        :name => nil,
        :value => nil,
        :other => "ok"
      )
    end

    it "has key attributes" do
      subject.key_attributes.must_equal :name => nil
    end

    it "has other attributes" do
      subject.other_attributes.must_equal :value => nil, :other => "ok"
    end

    it "allows attributes to be read" do
      subject.name.must_equal nil
    end

    it "allows attributes to be written" do
      subject.name = "test"
      subject.name.must_equal "test"
      subject.attributes[:name].must_equal "test"
      subject.key_attributes[:name].must_equal "test"
    end

    it "does not have valid attributes if any have errors" do
      subject.wont_be :valid_attributes?
      subject.name = "foo"
      subject.must_be :valid_attributes?
    end

    it "describes attribute errors" do
      subject.attribute_errors.must_equal [
        "[Test Class] missing value for :name (The name)"
      ]
    end
  end

  describe "a subclassed instance" do

    let(:subclass) { Class.new(klass) }

    subject { subclass.new }

    before do
      skip "subclassing is broken"
    end

    it "has default attributes" do
      subject.attributes.must_equal(
        :name => nil,
        :value => nil,
        :other => "ok"
      )
    end
  end

  describe "uniqueness, conflict and equality" do

    let(:object1) { klass.new }
    let(:object2) { klass.new }

    describe "two objects with equal keys and equal attributes" do
      before  do
        object1.name = "test"
        object2.name = "test"
        object1.value = 123
        object2.value = 123
      end
      specify "#== is true" do
        (object1 == object2).must_equal true
        (object2 == object1).must_equal true
      end
      specify "#eql? is true" do
        (object1.eql? object2).must_equal true
        (object2.eql? object1).must_equal true
      end
      specify "#hash is equal" do
        object1.hash.must_equal object2.hash
      end
      specify "#conflict? is false" do
        (object1.conflict?(object2)).must_equal false
        (object2.conflict?(object1)).must_equal false
      end
    end

    describe "two objects with equal keys and inequal attributes" do
      before do
        object1.name = "test"
        object2.name = "test"
        object1.value = 123
        object2.value = 456
      end
      specify "#== is false" do
        (object1 == object2).must_equal false
        (object2 == object1).must_equal false
      end
      specify "#eql? is true" do
        (object1.eql? object2).must_equal true
        (object2.eql? object1).must_equal true
      end
      specify "#hash is equal" do
        object1.hash.must_equal object2.hash
      end
      specify "#conflict? is true" do
        (object1.conflict? object2).must_equal true
        (object2.conflict? object1).must_equal true
      end
    end

    describe "two objects with inequal keys" do
      before do
        object1.name = "foo"
        object2.name = "bar"
      end
      specify "#== is false" do
        (object1 == object2).must_equal false
        (object2 == object1).must_equal false
      end
      specify "#eql? is false" do
        (object1.eql? object2).must_equal false
        (object2.eql? object1).must_equal false
      end
      specify "#hash is not equal" do
        object1.hash.wont_equal object2.hash
      end
      specify "#conflict? is false" do
        (object1.conflict? object2).must_equal false
        (object2.conflict? object1).must_equal false
      end
    end
  end

  describe "equality of different classes with equivalent attributes" do

    let(:klass2) {
      Class.new do
        include Config::Core::Attributes
        key  :name
        attr :value
        attr :other, "ok"
      end
    }

    let(:object1) { klass.new }
    let(:object2) { klass2.new }

    describe "two objects with equivalent attributes" do
      before do
        object1.name = "test"
        object2.name = "test"
        object1.value = 123
        object2.value = 123
      end
      specify "their attributes are equal" do
        object1.attributes.must_equal object2.attributes
      end
      specify "#== is false" do
        (object1 == object2).must_equal false
        (object2 == object1).must_equal false
      end
      specify "#eql? is false" do
        (object1.eql? object2).must_equal false
        (object2.eql? object1).must_equal false
      end
      specify "#hash is not equal" do
        object1.hash.wont_equal object2.hash
      end
      specify "#conflict? is false" do
        (object1.conflict? object2).must_equal false
        (object2.conflict? object1).must_equal false
      end
    end
  end
end
