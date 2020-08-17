xml.rss( :version => '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' ) do
  xml.channel do
    xml.title( 'Treaties subject to CRAG laid before the UK Parliament' )
    xml.description( 'Updates whenever a treaty subject to the Constitutional Reform and Governance Act 2010 is laid before a House in the UK Parliament' )
    xml.link( 'https://tweaty-twacker.herokuapp.com/' )
    xml.copyright( 'https://www.parliament.uk/site-information/copyright-parliament/open-parliament-licence/' )
    xml.language( 'en-uk' )
    xml.managingEditor( 'somervillea@parliament.uk (Anya Somerville)' )
    xml.pubDate( @instruments.first.date_laid.rfc822 )
    xml.tag!( 'atom:link', { :href => "https://tweaty-twacker.herokuapp.com/instruments.rss", :rel => 'self', :type => 'application/rss+xml' } )
    xml << render(:partial => 'instrument', :collection => @instruments )
  end
end


