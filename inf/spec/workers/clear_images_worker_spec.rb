require 'rails_helper'

describe ClearImagesWorker do
  context 'when no unused images' do
    before(:each) do
      Timecop.freeze(2.days.from_now)
      create(:article, :with_image)
    end

    it 'removes nothing' do
      expect { subject.perform }.not_to change { ArticleImage.count }
    end
  end

  context 'when no old images' do
    before(:each) do
      Timecop.freeze(Time.current)
      create(:article_image)
      create(:article_image)
      create(:article_image)
    end

    it 'removes nothing' do
      expect { subject.perform }.not_to change { ArticleImage.count }
    end
  end

  context 'when old and unused images exists' do
    before(:each) do
      Timecop.freeze(Time.current)
      create(:article_image)
      create(:article_image)
      Timecop.travel(2.days.from_now)
      create(:article_image)
      create(:article, :with_image)
    end

    it 'removes all unused images' do
      expect { subject.perform }.to change { ArticleImage.count }.by(-2)
    end
  end
end
