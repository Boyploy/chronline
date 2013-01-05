class Newsletter

  def send(test_email=nil)
    gb = Gibbon.new(Settings.mailchimp.api_key)
    cid = create_campaign(gb)
    if test_email.nil?
      gb.campaign_send_now(cid: cid)
    else
      gb.campaign_send_test(cid: cid, test_emails: [test_email])
    end
  end


  protected

  def issue_date
    Date.today.to_s
  end


  private

  def advertisement
    # TODO: make this configurable by non-developers
    src = "http://#{Settings.content_cdn}/advertisements/#{Settings.mailchimp.ad_image}"
    %{<a href="#{Settings.mailchimp.ad_href}"><img src="#{src}"/></a>}
  end

  def create_campaign(gb)
    gb.campaign_create({type: :regular,
                         # TODO: have editor revise this information
                         options: {
                           list_id: Settings.mailchimp.list_id,
                           subject: subject,
                           from_email: Settings.mailchimp.from_email,
                           from_name: Settings.mailchimp.from_name,
                           template_id: Settings.mailchimp.template_id,
                         },
                         content: {
                           html_MAIN: content,
                           html_ADIMAGE: advertisement,
                           html_ISSUEDATE: issue_date,
                         },
                       })
  end

end

class ArticleNewsletter < Newsletter
  attr_accessor :article


  def initialize(article)
    if article.is_a? Article
      @article = article
    elsif not article.nil?
      Article.find(article_id, include: :authors)
    end
  end

  def content
    # TODO: look into executing in an actual controller context with helpers
    template = File.read(File.join(%w{app views newsletter article.html.haml}))
    Haml::Engine.new(template).render(Rails.application.routes.url_helpers, article: @article)
  end

  private

  def subject
    @article.title
  end

end