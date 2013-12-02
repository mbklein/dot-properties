if defined?(RUBY_ENGINE) and (RUBY_ENGINE == 'ruby') and (RUBY_VERSION >= '1.9')
  require 'simplecov'
  SimpleCov.start
end
$:.push(File.join(File.dirname(__FILE__),'..','lib'))

require 'dot_properties'

describe DotProperties do
  let(:propfile) { File.expand_path('../fixtures/sample.properties', __FILE__) }
  subject { DotProperties.load(propfile) }

  let(:properties) { 21 }
  let(:comments)   { 16 }
  let(:blanks)     { 11 }

  it { should be_an_instance_of(DotProperties) }

  describe "values" do
    it "should have the right number of properties" do
      expect(subject.keys.length).to eq(properties)
    end

    it "should have the right values" do
      expect(subject['foo.normal']).to eq('bar.normal.value')
      expect(subject['bar.normal']).to eq('baz.normal.value')
      expect(subject['foo.whitespace']).to eq('bar.whitespace.value')
      expect(subject['foo.extraspace']).to eq('bar.extraspace.value')
      expect(subject['bar.extraspace']).to eq('baz.extraspace.value')
      expect(subject['foo bar']).to eq('bar baz')
      expect(subject['bar:baz']).to eq('baz quux')
      expect(subject['foo bar:baz= quux']).to eq('this is getting ridiculous')
      expect(subject['lots of fruit']).to eq('apple, peach, kiwi, mango, banana, strawberry, raspberry')
      expect(subject['some.veggies']).to eq('carrot, potato, broccoli')
      expect(subject['space.key1']).to eq('space.Value1')
      expect(subject['space.key2']).to eq('space.Value2')
      expect(subject['space.key3']).to eq('space.Multi word value')
      expect(subject['foo.empty']).to be_empty
      expect(subject['bar.empty']).to be_empty
      expect(subject['baz.empty']).to be_empty
      expect(subject['quux.empty']).to be_empty
    end

    it "#auto_expand" do
      expect(subject['present']).to eq('This value contains two resolvable references, bar.normal.value and baz.extraspace.value')
      expect(subject['missing']).to eq('This value contains one resolvable reference, bar.normal.value, and one unresolvable reference, ${quux.missing}')
    end

    it "#auto_expand=false" do
      subject.auto_expand = false
      expect(subject['present']).to eq('This value contains two resolvable references, ${foo.normal} and ${bar.extraspace}')
      expect(subject['missing']).to eq('This value contains one resolvable reference, ${foo.normal}, and one unresolvable reference, ${quux.missing}')
    end
  end

  describe "delimiters" do
    it "should retain original delimiters and spacing" do
      expect(subject.to_a.find { |l| l =~ /^foo\.extraspace/ }).to eq('foo.extraspace   = bar.extraspace.value')
    end

    it "should retain delimiters even after #set" do
      subject['bar.extraspace'] = 'new value'
      expect(subject.to_a.find { |l| l =~ /^bar\.extraspace/ }).to eq('bar.extraspace :   new value')
    end

    it "should #normalize delimiters!" do
      subject.normalize_delimiters!
      expect(subject.to_a.find { |l| l =~ /^foo\.extraspace/ }).to eq('foo.extraspace=bar.extraspace.value')
    end

    it "#default_delimiter" do
      subject.default_delimiter = ' : '
      subject['new key'] = 'new value'
      expect(subject.to_a.last).to eq('new\\ key : new value')
    end
  end

  describe "comments and blanks" do
    it "should leave comments and blanks alone" do
      expect(subject.to_a.length).to eq(properties + comments + blanks)
    end

    it "should strip comments" do
      subject.strip_comments!
      expect(subject.to_a.length).to eq(properties + blanks)
    end

    it "should strip blanks" do
      subject.strip_blanks!
      expect(subject.to_a.length).to eq(properties + comments)
    end

    it "should strip comments and blanks" do
      subject.compact!
      expect(subject.to_a.length).to eq(properties)
    end
  end

  describe "serialization" do
    it "#inspect" do
      expect(subject.inspect).to match(/\{.+\}/)
    end

    it "should round-trip" do
      hash = subject.to_h.dup
      array = subject.to_a
      duplicate = DotProperties.parse(subject.to_s)
      expect(duplicate.to_h).to eq(hash)
      expect(duplicate.to_a).to eq(array)
    end
  end

  describe "content escapes" do
    it "should parse Java-escaped unicode" do
      expect(subject['unicode']).to eq("Command\t\u2318\nOption\t\u2325")
    end

    it "should unescape escaped entities" do
      expect(subject['key with:several=escapes']).to eq('value with#several\escapes')
    end
  end

  describe "additional methods" do
    it "#<<" do
      subject << ""
      subject << "# This is a comment on some.new.property"
      subject << "some.new.property = some.new.value"
      expect(subject['some.new.property']).to eq('some.new.value')
      expect(subject.to_h.length).to eq(properties + 1)
      expect(subject.to_a.length).to eq(properties + comments + blanks + 3)
    end

    it "#delete" do
      expect(subject.delete('foo bar')).to eq('bar baz')
      expect(subject).not_to have_key('foo bar')
    end
  end


end