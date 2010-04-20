require 'spec_helper'

describe Sitemap do
  it "should output an xml sitemap" do
    public = Rails.root.join('public').to_s
    
    file1 = mock("file1")
    File.should_receive(:open).with("#{public}/sitemap.xml", "w").and_return(file1)
    file1.should_receive(:<<).with("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
    file1.should_receive(:<<).with("<sitemapindex xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">")
    file1.should_receive(:<<).with("<sitemap>")
    file1.should_receive(:<<).with("<loc>http://domain.org/sitemaps/sitemap1.xml.gz</loc>")
    file1.should_receive(:<<).with("<lastmod>2010-02-01T00:00:00+00:00</lastmod>")
    file1.should_receive(:<<).with("</sitemap>")
    file1.should_receive(:<<).with("</sitemapindex>")
    file1.should_receive(:close)

    file2 = mock("file2")
    Zlib::GzipWriter.should_receive(:open).with("#{public}/sitemaps/sitemap1.xml.gz").and_return(file2)
    file2.should_receive(:<<).with("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
    file2.should_receive(:<<).with("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">")
    file2.should_receive(:<<).with("<url><loc>http://domain.org/</loc><changefreq>hourly</changefreq><lastmod>2010-02-01T00:00:00+00:00</lastmod></url>")
    file2.should_receive(:<<).with("<url><loc>http://domain.org/foo</loc><changefreq>daily</changefreq><lastmod>2010-01-01T00:00:00+00:00</lastmod></url>")
    file2.should_receive(:<<).with("</urlset>")
    file2.should_receive(:close)

    s = Sitemap.new("domain.org", public, "")

    s.add_url "/", :changefreq => :hourly, :lastmod => DateTime.new(2010, 2, 1)
    s.add_url "/foo", :changefreq => :daily, :lastmod => DateTime.new(2010, 1, 1)
    s.finish
    #s.notify_search_engines
  end
  
  it "should have the path to one of the sitemaps" do
    public = Rails.root.join('public').to_s
    s = Sitemap.new("domain.org", public, "")
    s.sitemap_url.should == "http://domain.org/sitemaps/sitemap1.xml.gz"
    s.sitemap_path.should == "#{public}/sitemaps/sitemap1.xml.gz"
    s.finish
  end
  
  it "should have the path to the sitemap index" do
    public = Rails.root.join('public').to_s
    s = Sitemap.new("domain.org", public, "")
    s.sitemap_index_url.should == "http://domain.org/sitemap.xml"
    s.sitemap_index_path.should == "#{public}/sitemap.xml"
    s.finish
  end
end
