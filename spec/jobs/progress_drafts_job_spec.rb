require 'rails_helper'

RSpec.describe ProgressDraftsJob, type: :job do
  context "when given draft" do
    let(:draft) { create(:draft) }

    context "started" do
      let(:draft) { create(:draft, :started) }

      context "and current selection exceeded draft selection seconds" do
        it "starts the next selection and ends the current selection"
      end

      context "and current selection has not ended" do

      end

      context "started and current selection has not ended" do

      end

      context "and a user" do
        it "sets a virtual attribute on the selection for turbo"
      end
    end


    context "started and current selection has not ended" do

    end

    context "not started" do

    end

    context "ended" do

    end
  end
end
