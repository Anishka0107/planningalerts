require 'spec_helper'

describe "comments/_comment" do
  before do
    Timecop.freeze(Time.parse('2015-01-26 08:32:34 +1100'))
  end

  after do
    Timecop.return
  end

  it "should remove links in the comment text" do
    application = mock_model(Application)
    comment = mock_model(Comment, :name => "Matthew", :updated_at => Time.now, :application => application,
      :text => 'This is a link to <a href="http://openaustralia.org">openaustralia.org</a>')
    render :partial => "comment", :object => comment
    rendered.should == <<-EOF
<figure class='comment panel'>
<blockquote class='comment-text'><p>This is a link to <a href="http://openaustralia.org" rel="nofollow">openaustralia.org</a></p></blockquote>
<figcaption class='comment-meta'>
<span class='comment-author'>by Matthew</span>
<time class='comment-time' datetime='2015-01-26'>
less than a minute ago
</time>
</figcaption>
</figure>
    EOF
  end

  it "should format simple text in separate paragraphs with p tags" do
    application = mock_model(Application)
    comment = mock_model(Comment, :name => "Matthew", :updated_at => Time.now, :application => application,
      :text => "This is the first paragraph\nAnd the next line\n\nThis is a new paragraph")
    render :partial => "comment", :object => comment
    rendered.should == <<-EOF
<figure class='comment panel'>
<blockquote class='comment-text'><p>This is the first paragraph
<br>And the next line</p>

<p>This is a new paragraph</p></blockquote>
<figcaption class='comment-meta'>
<span class='comment-author'>by Matthew</span>
<time class='comment-time' datetime='2015-01-26'>
less than a minute ago
</time>
</figcaption>
</figure>
    EOF
  end

  it "should get rid of nasty javascript and strip out images" do
    application = mock_model(Application)
    comment = mock_model(Comment, :name => "Matthew", :updated_at => Time.now, :application => application,
      :text => "<a href=\"javascript:document.location='http://www.google.com/'\">A nasty link</a><img src=\"http://foo.co\">")
    render :partial => "comment", :object => comment
    rendered.should == <<-EOF
<figure class='comment panel'>
<blockquote class='comment-text'><p><a rel="nofollow">A nasty link</a></p></blockquote>
<figcaption class='comment-meta'>
<span class='comment-author'>by Matthew</span>
<time class='comment-time' datetime='2015-01-26'>
less than a minute ago
</time>
</figcaption>
</figure>
    EOF
  end
end
