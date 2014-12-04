class AdvertisingCell < BaseCell

  def header_meta
    @block = ad_block 'header_meta'

    render view: :block_raw if @block
  end

  def reskin
    @background = ad_block 'reskin_bg'
    @header = ad_block 'reskin_header_1100x148'

    render if reskin?
  end

  def sidebar
    if reskin?
      @block = ad_block 'reskin_sidebar_320x636'
      render view: :sidebar_reskin unless @block.blank?
    else
      @block = ad_block get_spot_name('main_roadb_300x250')
      render view: :sidebar_roadblock unless @block.blank?
    end
  end

  def sidebar_standard
    @block = ad_block get_spot_name('main_roadb_300x250')
    render view: :sidebar_roadblock unless @block.blank?
  end

  def top_banner
    @name = 'main_roadb_728x90'
    @block = ad_block get_spot_name(@name)
    render view: :block if @block
  end

  def ad_spot(name)
    @name = name
    @block = ad_block name
    render view: :block if @block
  end


  private

  def get_spot_name(string)
    controller.controller_name == 'home' ? "#{string}_home" : string
  end

  def ad_block(name)
    return nil unless controller.current_ad_profile
    controller.current_ad_blocks[name]
  end

  def reskin?
    !!controller.current_ad_profile.try(:reskin?)
  end
end
