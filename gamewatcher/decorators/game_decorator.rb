class GameDecorator < BaseDecorator

  include ScoreHelper
  include ActionView::Helpers::TextHelper

  def description
    h.simple_format object.description
  end

  def releases
    if object.released_in('eu').eql? object.released_in('us')
      h.content_tag('div', '', class: 'global-release') do
        h.content_tag('span', '', {class: 'eu'}) + h.content_tag('span', '', {class: 'us'}) + single_release
      end
    else
      release('eu') + release('us')
    end
  end

  def single_release
    release_html("EU & US", formatted_date('us'))
  end

  def release_date
    object.releases.pluck(:eu_released_at,:us_released_at ).flatten.compact.min.to_s(:human)
  end

  def release(region)
    release_date = formatted_date(region)
    release_html(region.upcase, release_date, region)
  end

  def upcoming_release_date
    object.most_recent
  end

  def upcoming_release
    date = upcoming_release_date
    days = (date - Date.today).to_i
    days > 1 ? "#{days} days" : 'tomorrow'
  end

  def formatted_date(region)
    value = object.released_in(region) || 'n/a'
    value.is_a?(Date) ? value.to_s(:human) : value
  end

  def release_html(label, date, div_class=nil)
    h.content_tag 'div', class: "pull-left #{div_class}" do
      h.content_tag 'b' do
        "#{label} Release date: #{date}"
      end
    end
  end

  def news_count
    number_with_delimiter object.news.published.count
  end

  def features_count
    number_with_delimiter object.count_features
  end

  def downloads_count
    number_with_delimiter object.downloads.without_mods.count
  end

  def mods_count
    number_with_delimiter object.downloads.only_mods.count
  end

  def videos_count
    number_with_delimiter object.published_videos.size
  end

  def screens_count
    number_with_delimiter object.screenshots.count
  end

  def mods_downloads
    pluralize(number_with_delimiter(object.mods_download_count), 'download')
  end

  def review_score
    round(object.review_score)
  end

  def current_score(sort_column)
    sort_column.present? ? round(object.user_score)  : review_score
  end

  def current_score_mark(sort_column)
    sort_column.present? ?  score_mark(object.user_score) : score_mark(object.review_score)
  end

  def review_score_mark()
    score_mark(object.review_score)
  end

  def user_score_mark
    score_mark(object.user_score)
  end

  def featured_mods
    object.downloads.includes(:counter).by_type(:mod).popular.first(10).shuffle.first(3)
  end

  def search_result_name
    return object.name if object.name.downcase.include?('game')

    "#{object.name} Game"
  end

  def link_tags
    result = []
    tags.split(',').each{|tag| result << h.link_to(tag, h.tag_path(tag.parameterize)) }
    return result.join(', ').html_safe
  end
end
