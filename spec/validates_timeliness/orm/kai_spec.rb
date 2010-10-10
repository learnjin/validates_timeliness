require 'spec_helper'

require 'mongoid'
require 'validates_timeliness/orm/mongoid'
# require 'formtastic'


Mongoid.configure do |config|
  name = "validates_timeliness_test"
  host = "localhost"
  config.master = Mongo::Connection.new.db(name)
  config.persist_in_safe_mode = false
end

class Article
  ::ValidatesTimeliness.use_plugin_parser = true
  ::ValidatesTimeliness.enable_date_time_select_extension!
  #::ValidatesTimeliness.enable_multiparameter_extension!

  include Mongoid::Document
  field :publish_date, :type => Date
  field :publish_time, :type => Time
  field :publish_datetime, :type => DateTime
  validates_date :publish_date, :allow_nil => true
  validates_time :publish_time, :allow_nil => true
  validates_datetime :publish_datetime, :allow_nil => true
  ::ValidatesTimeliness.use_plugin_parser = false
end



describe ValidatesTimeliness, 'Mongoid' do
  attr_reader :article, :params

  context "multiparameter handler" do

    it 'handles invalid dates' do
      #instantiate_time_object('publish_date', [2000, 2, 31]).should == '2000-02-31'
      instantiate_time_object('publish_date', [2000, 2, 31]).should == nil
    end

    #it 'handlesinvalid datetimes' do
    #  instantiate_time_object('publish_datetime', [2000, 2, 31, 12, 0, 0]).should == '2000-02-31 12:00:00'
    #end

    #it 'returns Time value for valid datetimes' do
    #  instantiate_time_object('publish_datetime', [2000, 2, 28, 12, 0, 0]).should be_kind_of(Time)
    #end

    def instantiate_time_object(name, values)
      prms = {}
      values.each_with_index{|v,i| prms["#{name}(#{i+1}i)"] = v.to_s}
      #puts "Article.new(#{prms.inspect}).send :#{name}"
      t = Article.new(prms).send name.to_sym
      #puts "#{t.class}"
      t   
    end 
  end

  context "date time select" do
    include ActionView::Helpers::DateHelper

    before do
      @article = Article.new
      @params = {}
    end

    it "should use param values when attribute is nil" do
      params["article"] = {
        "publish_date(1i)" => "2009",
        "publish_date(2i)" => "2",
        "publish_date(3i)" => "29",
      }
      output = date_select(:article, :publish_date, :include_blank => true)
      output.should have_tag('select[id=article_publish_date_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=article_publish_date_2i] option[selected=selected]', 'February')
      output.should have_tag('select[id=article_publish_date_3i] option[selected=selected]', '29')
    end
  end

  #TODO: write a working formtastic test case

#  context "formtastic" do
#    include ActionView::TestCase
#    before do
#      @article = Article.new
#      @params = {}
#      @output_buffer = ''
#    end
#
#    it "should use param values when attribute is nil" do
#      params["article"] = {
#        "publish_date(1i)" => "2009",
#        "publish_date(2i)" => "2",
#        "publish_date(3i)" => "29",
#      }
#
#      output = semantic_form_for(@article, :url => "") do |builder|
#        concat(builder.input(:article, :publish_date, :include_blank => true))
#      end
#        
#      output.should have_tag('select[id=article_publish_date_1i] option[selected=selected]', '2009')
#      output.should have_tag('select[id=article_publish_date_2i] option[selected=selected]', 'February')
#      output.should have_tag('select[id=article_publish_date_3i] option[selected=selected]', '29')
#    end
#  end
#



end
