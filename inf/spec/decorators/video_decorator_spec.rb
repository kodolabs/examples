require 'rails_helper'

describe VideoDecorator do
  context 'youtube' do
    let(:video_1) { build(:video, url: 'http://youtu.be/cCnrX1w5luM?autoplay=1').decorate }
    let(:video_2) { build(:video, url: 'youtu.be/cCnrX1w5luM ').decorate }
    let(:video_3) { build(:video, url: 'http://test.com/video.mp4').decorate }

    specify 'is youtube' do
      expect(video_1.youtube?).to be_truthy
      expect(video_2.youtube?).to be_truthy
      expect(video_3.youtube?).to be_falsey
    end

    specify 'youtube url' do
      expect(video_1.youtube_url).to eq 'http://youtu.be/cCnrX1w5luM?autoplay=0&controls=1'
    end
  end

  specify 'source type' do
    mp4_video = build :video, url: 'http://test.com/video.mp4'
    hls_video = build :video, url: 'http://test.com/video.m3u8'

    expect(mp4_video.decorate.source_type).to eq 'video/mp4'
    expect(hls_video.decorate.source_type).to eq 'application/x-mpegURL'
  end
end
