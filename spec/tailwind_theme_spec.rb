# frozen_string_literal: true

RSpec.describe TailwindTheme do
  it "has a version number" do
    expect(TailwindTheme::VERSION).not_to be nil
  end

  describe "#load_file" do
    let(:theme_file) { File.expand_path("fixtures/test-theme.yml", __dir__) }

    it "returns the Theme from a file" do
      expect(described_class.load_file(theme_file)).to be_kind_of(TailwindTheme::Theme)
    end
  end

  describe "#missing_classname" do
    subject(:missing_classname) { described_class.missing_classname %w[test path] }

    context "when self.missing_classname = nil" do
      before { described_class.missing_classname = nil }

      it "returns the default missing classname" do
        expect(missing_classname).to eq "missing-test-path"
      end
    end

    context "when self.missing_classname = true" do
      before { described_class.missing_classname = true }

      it "returns the default missing classname" do
        expect(missing_classname).to eq "missing-test-path"
      end
    end

    context "when self.missing_classname = false" do
      before { described_class.missing_classname = false }

      it "returns the default missing classname" do
        expect(missing_classname).to be_nil
      end
    end

    context "when self.missing_classname = :custom_class" do
      before { described_class.missing_classname = :custom_class }

      it "returns 'custom_class'" do
        expect(missing_classname).to eq "custom_class"
      end
    end

    context "when self.missing_classname = 'custom-class'" do
      before { described_class.missing_classname = "custom-class" }

      it "returns 'custom_class'" do
        expect(missing_classname).to eq "custom-class"
      end
    end

    context "when self.missing_classname = Proc" do
      before { described_class.missing_classname = ->(path) { "oops-#{path.join "-"}-missing" } }

      it "returns 'custom_class'" do
        expect(missing_classname).to eq "oops-test-path-missing"
      end
    end
  end
end
