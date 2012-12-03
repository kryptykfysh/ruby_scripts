# scrape_fec.rb

module FECImages
  
  def FECImages.search(name_term)
  # prereqs: A partial search term (name_term) by which to find committees  
  
  # does: Submits a POST request to /cgi-bin/fecimg with the given `name` parameter
  
  # returns: A Hash object containing: 
  #  'page'=> the raw HTML of the results page 
  #  'links'=> the Nokogiri::XML::Elements for each link to a committee page
  
    request_url = "http://query.nictusa.com/cgi-bin/fecimg"
    if page = RestClient.post(request_url, {'name'=>name_term, 'submit'=>'Get+Listing'})
      puts "\tFECImages.search::\tSuccess finding search term: #{name_term}"  
      npage = Nokogiri::HTML(page)
      links = npage.css('div#fec_mainContent table tr td a')    
      return {'page'=>page, 'links'=>links}    
    end
    
  end
end

module FECImages
  
  def FECImages.get_filings_list(committee_url)
  # prereqs: `committee_url` goes to a committee page and follows this format:
  # => http://query.nictusa.com/cgi-bin/fecimg/?COMMITTEE_CODE
  
  # does: Retreives the page at `committee_url` and parses the HTML for links
  
  # returns: A Hash object containing:
  #   'page'=> the raw HTML of the filings page
  #   'links'=> the Nokogiri::XML::Elements for each link to each PDF report
  
    c_url_format = 'http://query.nictusa.com/cgi-bin/fecimg/?'
  
    if !(committee_url.match(c_url_format))
      # Raise an error:
      raise "\tFECImages.get_filings_list::\tIncorrect committee url: #{committee_url} does not look like: #{c_url_format}"
    end
    
    begin
      page = RestClient.get(committee_url)
    rescue StandardError=>e
      puts "\tFECImages.get_filings_list::\tCould not retrieve filings; Error: #{e}"
      
      return nil
    else
      puts "\tFECImages.get_filings_list::\tSuccess in retrieving filings from #{committee_url}"
      npage = Nokogiri::HTML(page)
      links = npage.css('div#fec_mainContent table tr td a').select{|a| a.text.match('PDF')}
      
      return {'page'=>page, 'links'=>links}
    end
  end
end

module FECImages
  
  def FECImages.get_filing_pdf(pdf_url)
  # prereqs: `pdf_url` follows either of the two formats:
  #   1.  http://query.nictusa.com/pdf/000/0000000/00000000.pdf#navpanes=0
  #   2.  http://query.nictusa.com/cgi-bin/fecimg/?XXXXXXXXXX
    
  # does: if case #1, then retrieve PDF file
  #       if case #2, then retrieve "Generate PDF" page. Then generate the proper
  #           POST request. Then download dynamically generated PDF
  
  # returns: File object containing binary data for PDF
  
  
  # caution: this currently does not handle large PDF requests and will return nil
  #   if the server returns an error
  
    # using a regular expression for validation
    case_1_fmt = /query.nictusa.com\/pdf\/.+?\.pdf/
    case_2_fmt = 'query.nictusa.com/cgi-bin/fecimg/'
    
    
    pdf_file = nil

    begin # sloppy (but good enough for now) error-handling
    
      
      if pdf_url.match(case_1_fmt)
        puts "\tFECImages.get_filing_pdf::\tDownloading actual PDF file: #{pdf_url}"

        pdf_file = RestClient.get(pdf_url)
      
      elsif pdf_url.match(case_2_fmt)
        puts "\tFECImages.get_filing_pdf::\tRetrieving Generate PDF button page: #{pdf_url}"
      
        if form_page = Nokogiri::HTML(RestClient.get(pdf_url))
          button = form_page.css('input[type="hidden"]')[0]
          data_hash =  {button['name']=>button['value'], 'PDF'=>'Generate+PDF'}

          # POST request
          cgi_url = 'http://query.nictusa.com/cgi-bin/fecgifpdf/'
          puts "\tFECImages.get_filing_pdf::\tSubmitting POST request: \t#{cgi_url}\t#{data_hash.inspect} ..."

          pdf_resp = RestClient.post(cgi_url,data_hash)
          if embed = Nokogiri::HTML(pdf_resp).css('embed')[0]
            pdf_name = embed['src']
            puts "\tFECImages.get_filing_pdf::\tPDF dynamically generated: #{pdf_name}"
            
            pdf_file = RestClient.get(pdf_name)
          end      
       end
      else 
       
       raise "\tFECImages.get_filing_pdf::\tIncorrect PDF url: #{pdf_url} does not look like: #{case_1_fmt} or #{case_2_fmt}"
       
      end 
      
    rescue StandardError=>e
      puts "\tFECImages.get_filing_pdf::\tCould not retrieve PDF; Error: #{e}"
    ensure

      return pdf_file
    end
  end

end

# main loop

require 'restclient'
require 'nokogiri'
require 'fileutils'

require 'fecimg-module'


HOST_URL = 'http://query.nictusa.com'
term = "obama"
links_limit = 5

puts "Starting scrape for committees that match `#{term}`"
results_committee_listing = FECImages.search(term)


#######   Save the results listing for `term`
results_local_dir = "data-hold/#{term}"
FileUtils.makedirs(results_local_dir)
File.open("#{results_local_dir}/committees_listing.html", 'w'){|f| f.write(results_committee_listing['page'])}

results_committee_listing['links'].to_a.shuffle.first(links_limit).each do |committee_link|
  c_name = committee_link.text
  c_href = "#{HOST_URL}#{committee_link['href']}"
  
  puts "Retrieving filings for committee: #{c_name}"
  if results_filings_listing = FECImages.get_filings_list(c_href)
    puts "#{results_filings_listing['links'].length} filings found"
  
    #######  Save the filings listing for `c_name`
    filings_listing_dir = "#{results_local_dir}/#{c_name}"
    FileUtils.makedirs(filings_listing_dir)
    File.open("#{filings_listing_dir}/filings_listing.html", 'w'){|f| f.write(results_filings_listing['page'])}
  
    #######  Now get all the PDFs
  
    results_filings_listing['links'].to_a.shuffle.first(links_limit).each do |pdf_link|
      
      # get the filing id: this regex should always work if the link is of correct format
      pdf_href = "#{HOST_URL}#{pdf_link['href']}"
      f_id = pdf_link['href'].split('/')[-1].match(/(\w+)(?:\.pdf)?/i)[1]       
      
      puts "Retrieving PDF at #{pdf_href}"
      sleep(1.0 + rand)
      
      #######  Save PDF
      if pdf_file = FECImages.get_filing_pdf(pdf_href)  
        File.open("#{filings_listing_dir}/#{f_id}.pdf", 'w'){|f| f.write(pdf_file)}
      else
        puts "* FAILED to get filing #{f_id}"
      end
    end
  
  
  else # get_filings_list failed
    puts "* FAILED to get filings for committee: #{c_name}"
  end
end