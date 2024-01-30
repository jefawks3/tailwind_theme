# frozen_string_literal: true

require "spec_helper"
require "ostruct"

RSpec.describe TailwindTheme::Theme do
  subject(:theme) { TailwindTheme.load_file theme_file }

  let(:theme_file) { File.expand_path("../fixtures/test-theme.yml", __dir__) }

  let(:test_object) do
    OpenStruct.new values: :foo, value_with_theme: :missing, boolean: false, foo: :bar
  end

  describe ".css" do
    it "raises an IndexError on not found and raise options is true" do
      expect { theme.css!("test.path", raise: true) }.to raise_error IndexError
    end

    it "resolves an array path" do
      expect(theme.css(%i[multipart key])).to eq "multi-part-key"
    end

    it "resolves an string path" do
      expect(theme.css("multipart.key")).to eq "multi-part-key"
    end

    it "appends the class name" do
      expect(theme.css("multipart.key", append: "p-6")).to eq "multi-part-key p-6"
    end

    it "prepend the class name" do
      expect(theme.css("multipart.key", prepend: "p-6")).to eq "p-6 multi-part-key"
    end

    context "when string css path" do
      it "returns a css string" do
        expect(theme.css("basic")).to eq "basic-classes"
      end

      it "returns a missing css string" do
        expect(theme.css("foo.bar")).to eq "missing-foo-bar"
      end
    end

    context "when object theme path" do
      it "raises ArgumentError when object and attribute option is not defined" do
        expect { theme.css(:complex) }.to raise_error ArgumentError
      end

      it "returns the css classnames for an object" do
        expect(theme.css(:complex, object: test_object))
          .to eq "complex-base variant-base values-base values-foo boolean boolean-false"
      end

      it "returns the css classnames for given attributes" do
        expect(theme.css(:complex, attributes: { boolean: false }))
          .to eq "complex-base boolean boolean-false"
      end

      it "does not have the missing attribute classname" do
        expect(theme.css(:complex, object: test_object)).not_to include("missing-attribute")
      end

      it "overrides the object attribute value" do
        expect(theme.css(:complex, object: test_object, attributes: { boolean: true }))
          .to eq "complex-base variant-base values-base values-foo boolean boolean-true"
      end
    end
  end

  describe ".css!" do
    it "calls the css method with raise: true option" do
      expect { theme.css!("test.path") }.to raise_error IndexError
    end
  end

  describe ".merge_css" do
    it "returns the merged paths" do
      expect(theme.merge_css(%w[basic complex], object: test_object))
        .to eq "basic-classes complex-base variant-base values-base values-foo boolean boolean-false"
    end
  end

  describe ".merge_css!" do
    it "calls the css method with raise: true option" do
      expect { theme.merge_css!(["test.path", :complex]) }.to raise_error IndexError
    end
  end

  describe ".key?" do
    it "returns true when key is defined" do
      expect(theme).to be_key :complex
    end

    it "returns false when key is not defined" do
      expect(theme).not_to be_key %i[foo bar]
    end
  end
end
