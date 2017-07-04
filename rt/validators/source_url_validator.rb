class SourceUrlValidator < ActiveModel::Validator
  require 'addressable/uri'

  DOMAINS = %w(com ac ad ae af ag ai al am ao ar as at au az ba bd be bf bg bh bi bj bn bo br bs bt bw by bz ca kh cc cd cf cat cg ch ci ck cl cm cn co cr cu cv cx cy cz de dj dk dm do dz ec ee eg es et eu fi fj fm fr ga ge gf gg gh gi gl gm gp gr gt gy hk hn hr ht hu id iq ie il im in io is it je jm jo jp ke ki kg kr kw kz la lb lc li lk ls lt lu lv ly ma md me mg mk ml mm mn ms mt mu mv mw mx my mz na ne nf ng ni nl no np nr nu nz om pk pa pe ph pl pg pn pr ps pt py qa ro rs ru rw sa sb sc se sg sh si sk sl sn sm so st sr sv td tg th tj tk tl tm to tn tr tt tw tz ua ug uk us uy uz vc ve vg vi vn vu ws za zm zw).freeze

  def validate(record)
    reviews_host = only_host Addressable::URI.parse(record.reviews_url.to_s)&.host&.without_www
    source_host = only_host record.source&.website&.without_www

    return if reviews_host&.casecmp(source_host)&.zero?
    record.errors.add(:reviews_url, I18n.t('errors.same_domain_url'))
  end

  private

  def only_host(url)
    host_domains = url.split('.')
    host_domains = host_domains.reject { |d| DOMAINS.include?(d) }
    host_domains.join('.')
  end
end
