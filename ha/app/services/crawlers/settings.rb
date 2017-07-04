module Crawlers
  class Settings
    def self.title_selectors
      [
        'article header .entry-title',
        '.article header .entry-title',
        '.entry-title',
        'article header h2',
        'article header a',
        '#title-block a',
        '.blogItem a',
        '.post-header h1',
        '.content .stamp',
        '.article-page header h2',
        '#content .title a',
        '.articlecontent .articletitle',
        'article h1',
        '.posttitle',
        '.page_title',
        '.post-title'
      ].freeze
    end

    def self.text_selectors
      [
        'article .entry-content',
        '.entry-content',
        'article .body',
        'article .content',
        'article .post-content',
        '.blogItem',
        'article.entry',
        '#content .entry',
        '.articlecontent',
        '#layout .content',
        'article .contenido',
        'article .panel-body',
        'article .post_content',
        '.post-content',
        'article'
      ].freeze
    end

    def self.date_selectors
      [
        '.post-info abbr',
        '.header-article .read-more',
        '.blogItem h3',
        'article header time',
        'article header .entry-meta',
        'article .posted-on time',
        '.published time',
        '.post-info .published',
        '.entry-content .published',
        '.entry-content .post-info',
        '.body article footer',
        '.article-page header time',
        '#content .meta .date',
        '.header-article p',
        '#post .entry-meta .date',
        'article .info',
        'time',
        '.post-date',
        '.entry-date',
        '.entry-date.published',
        ['meta[property="article:published_time"]', 'content'],
        '.post-meta',
        '.postmeta'
      ].freeze
    end

    def self.author_selectors
      [
        '.post-info .author a',
        '.post-info a',
        '.author-details a.url',
        '.blogMeta a[href="#"]',
        'article .entry-meta .author a',
        'article header .meta .author a',
        'article footer address',
        '#content .meta .posted a',
        '.header-article .article-info',
        'article .info a.url',
        '.entry-meta a[href*="author"]',
        '.author a',
        '.post-author'
      ].freeze
    end

    def self.category_selectors
      [
        '.nav li.active a',
        'nav li.active a',
        '.category-column li.active a',
        '#sidebar li.active a',
        '.author-details a[href*="category"]',
        '.blogMeta a[href*="category"]',
        '.post-info a[href*="category"]',
        '.post-meta a[href*="category"]',
        '.article-meta a[href*="category"]',
        '#content .meta a[href*="category"]',
        'article header .entry-cat a',
        '.sidebarcategory a[href*="category"]',
        'article .info a[href*="category"]',
        'li a[href*="category"]',
        '.entry-meta a[href*="category"]',
        '.cat-links a[href*="category"]'
      ].freeze
    end
  end
end
