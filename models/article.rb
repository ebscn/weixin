class Article
  include DataMapper::Resource

  property :id,         Serial
  property :title,  String
  property :description,      String
  property :pic_url,       String
  property :url,       String
  
  belongs_to :picture_message  # defaults to :required => true
  def weixin_xml
    template_xml = <<Text
<item>
 <Title><![CDATA[#{title}]]></Title>
 <Description><![CDATA[#{description}]]></Description>
 <PicUrl><![CDATA[#{pic_url}]]></PicUrl>
 <Url><![CDATA[#{url}]]></Url>
</item> 
Text
  end
end
