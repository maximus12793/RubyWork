# this is the snagger for html data grabbing
# this file automates the login tasks 

require 'rubygems'
require 'nokogiri'
require 'open-uri'
# gem "watir", "~>4.0"
require 'watir-webdriver'



page = Nokogiri::HTML(open("http://www.mymathlab.com"))   
puts page.class   # => Nokogiri::HTML::Document

system 'echo hello this is a test shell command'


browser = Watir::Browser.new
browser.goto 'http://www.mymathlab.com'

browser.link(:text =>"Sign in").when_present.click


browser.text_field(:name => 'loginname').set 'random@yahoo.com'
browser.text_field(:name => 'password').set 'password'
browser.button(:type => 'submit').click
# login page

browser.link(:text =>"Calculus II Summer II 2014 CRN 16716").click
browser.div(:id => "navcontainer").li(:id => 'digitalVellum_dijit_MenuListItem_1').when_present.click
# get to homework 



browser.links.each do |link|
          puts link
end



